# load MIMIC 2 data from the dataset
# Path: llm_ontology_alignment/__init__.py
import logging
from dotenv import load_dotenv
import sentry_sdk
from slack_logger import SlackFormatter, SlackHandler, FormatConfig
from sentry_sdk.integrations.logging import LoggingIntegration
import os

from llm_ontology_alignment.evaluations.ontology_matching_evaluation import run_schema_matching_evaluation

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
    #
    from llm_ontology_alignment.data_models.experiment_models import OntologyMatchingEvaluationReport

    for item in OntologyMatchingEvaluationReport.objects(target_database="cms"):
        # for dataset in experiments:
        #     for rewrite_llm in ["original", "gpt-4o", "gpt-3.5-turbo"]:
        if item.strategy in ["unicorn"]:
            continue
        if item.strategy == "SimilarityFlooding":
            item.strategy = "similarity_flooding"
            try:
                item.save()
            except Exception as e:
                item.delete()
                continue
        if True:
            run_specs = {

                "source_db": item.target_database,
                "target_db": item.source_database,
                "strategy": item.strategy,
                "matching_llm": item.matching_llm,
                "rewrite_llm": item.rewrite_llm,
            }

            record = OntologyMatchingEvaluationReport.objects(
                strategy=run_specs["strategy"],
                source_database=run_specs["source_db"],
                target_database=run_specs["target_db"],
                rewrite_llm=run_specs["rewrite_llm"],
                matching_llm=run_specs["matching_llm"],
            ).first()
            if record:
                continue
            try:
                run_schema_matching_evaluation(run_specs, refresh_existing_result=False, refresh_rewrite=False)
                print(run_specs)
            except Exception as e:
                print(e)
                print(run_specs)
                raise e


if __name__ == "__main__":
    main()
