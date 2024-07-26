# load MIMIC 2 data from the dataset
# Path: llm_ontology_alignment/__init__.py
import logging
from dotenv import load_dotenv
import sentry_sdk
from slack_logger import SlackFormatter, SlackHandler, FormatConfig
from sentry_sdk.integrations.logging import LoggingIntegration
import os


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
    datasets = ["IMDB_Saki", "OMOP_Synthea", "OMOP_CMS", "OMOP_MIMIC"]
    models = ["gpt-4o", "gpt-3.5-turbo", "mistral-7b", "llama3-8b"]
    from llm_ontology_alignment.alignment_strategies.schema_understanding import run_matching

    for model in ["gpt-4"]:
        run_specs = {
            "source_db": "imdb",
            "target_db": "sakila",
            "matching_llm": model,
            "rewrite_llm": "gpt-4o",
            "strategy": "schema_understanding",
            "template": "top2-no-na",
        }
        from llm_ontology_alignment.data_processors.rewrite_db_schema import rewrite_db_columns

        rewrite_db_columns(run_specs)
        from llm_ontology_alignment.data_processors.load_data import update_rewrite_schema_constraints

        update_rewrite_schema_constraints(run_specs["source_db"])
        update_rewrite_schema_constraints(run_specs["target_db"])
        run_matching(run_specs)

        from llm_ontology_alignment.alignment_strategies.evaluation import print_result_one_to_many

        print_result_one_to_many(run_specs)


if __name__ == "__main__":
    main()
