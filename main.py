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
    from llm_ontology_alignment.alignment_models.rematch import evaluate_experiment

    from llm_ontology_alignment.alignment_models.rematch import run_experiment

    J = -2
    model = "gpt-4o"
    template = "top5"
    dataset = "IMDB_Saki"

    run_id_prefix = f"rematch-J_{J}-model_{model}-template_{template}"

    run_experiment(dataset=dataset, model=model, J=J, template=template)

    evaluate_experiment(dataset=dataset, run_id_prefix=run_id_prefix)


if __name__ == "__main__":
    main()
