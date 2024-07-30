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
    from llm_ontology_alignment.alignment_strategies.valentine_matching import run_valentine

    for dataset in ["imdb-sakila", "omop-cms", "mimic_iii-omop", "cprd_aurum-omop", "cprd_gold-omop"]:
        for llm in ["gpt-4o", "gpt-3.5-turbo", "original"]:
            source_db, target_db = dataset.split("-")
            run_specs = {
                "source_db": source_db,
                "target_db": target_db,
                "rewrite_llm": llm,
            }
            run_valentine(run_specs)


if __name__ == "__main__":
    main()
