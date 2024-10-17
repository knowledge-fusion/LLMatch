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
    # for item in OntologyAlignmentExperimentResult.objects():
    #     run_specs = json.loads(item.run_id_prefix)
    #     if "matching_llm" in run_specs:
    #         run_specs.pop("matching_llm", None)
    #         run_specs = {key: run_specs[key] for key in sorted(run_specs.keys())}
    #         item.run_id_prefix = json.dumps(run_specs)
    #         try:
    #             item.save()
    #         except Exception as e:
    #             item.delete()

    from llm_ontology_alignment.evaluations.run_evaluations import (
        run_valentine_experiments,
        run_schema_understanding_evaluations,
    )

    run_schema_understanding_evaluations()
    run_valentine_experiments()

    return


if __name__ == "__main__":
    main()
