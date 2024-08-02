# load MIMIC 2 data from the dataset
# Path: llm_ontology_alignment/__init__.py
import logging
from dotenv import load_dotenv
import sentry_sdk
from slack_logger import SlackFormatter, SlackHandler, FormatConfig
from sentry_sdk.integrations.logging import LoggingIntegration
import os

from llm_ontology_alignment.evaluations.evaluation import run_schema_matching_evaluation

logger = logging.getLogger(__name__)


load_dotenv()

sentry_logging = LoggingIntegration(
    level=logging.INFO,  # Capture info and above as breadcrumbs
    event_level=logging.ERROR,  # Send errors as events
)
formatter = SlackFormatter.default(
    config=FormatConfig(service="news_crawler", environment="dev")
)  # plain message, no decorations
handler = SlackHandler.from_webhook(os.environ["SLACK_NOTIFICATION_URL"])
handler.setFormatter(formatter)
handler.setLevel(logging.WARN)
logger.addHandler(handler)

sentry_sdk.init(
    dsn=os.getenv("SENTRY_DSN"),
    integrations=[
        sentry_logging,
    ],
)


def main():
    from llm_ontology_alignment.data_models.experiment_models import OntologyMatchingEvaluationReport

    # "imdb-sakila", "omop-cms", "mimic_iii-omop", "cprd_aurum-omop", "cprd_gold-omop"
    for dataset in ["cprd_gold-omop"]:
        version = 2
        for item in OntologyMatchingEvaluationReport.objects(
            strategy__in=["rematch", "schema_understanding_no_reasoning"], version__ne=version
        ):
            run_specs = {
                "source_db": item.source_database,
                "target_db": item.target_database,
                "strategy": item.strategy,
                "rewrite_llm": item.rewrite_llm,
            }

            if item.matching_llm:
                run_specs["matching_llm"] = item.matching_llm
            try:
                run_schema_matching_evaluation(run_specs, refresh_existing_result=True)
            except Exception as e:
                print(e)
                print(run_specs)
                continue


if __name__ == "__main__":
    main()
