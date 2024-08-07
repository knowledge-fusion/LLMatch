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
    from llm_ontology_alignment.evaluations.latex_report.full_experiment_f1_score import experiments

    models = ["deepinfra/meta-llama/Meta-Llama-3.1-70B-Instruct", "deepinfra/meta-llama/Meta-Llama-3.1-405B-Instruct"]
    for dataset in experiments:
        for matching_llm in models:
            for rewrite_llm in models:
                run_specs = {
                    "source_db": dataset.split("-")[0],
                    "target_db": dataset.split("-")[1],
                    "strategy": "schema_understanding_no_reasoning",
                    "matching_llm": matching_llm,
                    "rewrite_llm": rewrite_llm,
                }
                from llm_ontology_alignment.data_models.experiment_models import OntologyMatchingEvaluationReport

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
                    run_schema_matching_evaluation(run_specs, refresh_existing_result=False, refresh_rewrite=True)
                    print(run_specs)
                except Exception as e:
                    print(e)
                    print(run_specs)
                    raise e


if __name__ == "__main__":
    main()
