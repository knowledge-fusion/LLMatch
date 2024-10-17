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
    # recalculate_result()

    from llm_ontology_alignment.evaluations.calculate_result import run_schema_matching_evaluation

    run_specs = {
        "source_db": "mimic_iii",
        "target_db": "omop",
        "column_matching_strategy": "llm",
        "rewrite_llm": "original",
        "table_selection_strategy": "llm",
        "column_matching_llm": "gpt-3.5-turbo",
        "table_selection_llm": "gpt-3.5-turbo",
    }
    run_schema_matching_evaluation(run_specs, refresh_existing_result=True)

    return


if __name__ == "__main__":
    main()
