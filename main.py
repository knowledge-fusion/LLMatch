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
    from llm_ontology_alignment.alignment_strategies.schema_understanding import run_matching_with_schema_understanding

    for model in ["gpt-4o-mini"]:
        run_specs = {
            "source_db": "imdb",
            "target_db": "saki",
            "matching_llm": model,
            "rewrite_llm": "gpt-4o",
            "strategy": "schema_understanding",
            "template": "top2-no-na",
        }
        # rewrite_db_columns(run_specs)

        run_matching_with_schema_understanding(run_specs)

    return


if __name__ == "__main__":
    main()
