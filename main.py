# load MIMIC 2 data from the dataset
# Path: llm_ontology_alignment/__init__.py
import logging
from dotenv import load_dotenv
import sentry_sdk
from slack_logger import SlackFormatter, SlackHandler, FormatConfig
from sentry_sdk.integrations.logging import LoggingIntegration
import os

from llm_ontology_alignment.constants import EXPERIMENTS

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
    from llm_ontology_alignment.evaluations.extended_study_evaluation import effect_of_foreign_keys_and_description

    result = effect_of_foreign_keys_and_description()
    print(result)
    return
    for rewrite_llm in ["gpt-4o", "original"]:
        for experiment in EXPERIMENTS:
            source, target = experiment.split("-")
            run_specs = {
                "column_matching_llm": "gpt-3.5-turbo",
                "column_matching_strategy": "llm-no_description_no_foreign_keys",
                "rewrite_llm": "original",
                "source_db": source,
                "table_selection_llm": "gpt-3.5-turbo",
                "table_selection_strategy": "llm-no_description_no_foreign_keys",
                "target_db": target,
            }
            # res = OntologyAlignmentExperimentResult.objects(
            #     operation_specs__operation="table_candidate_selection",
            #     # operation_specs__source_db=source,
            #     # operation_specs__target_db=target,
            #     operation_specs__rewrite_llm=run_specs["rewrite_llm"],
            #     operation_specs__table_selection_llm=run_specs["table_selection_llm"],
            #     operation_specs__table_selection_strategy=run_specs["table_selection_strategy"],
            #     created_at__lte=datetime.datetime.utcnow() - datetime.timedelta(days=1),
            # ).delete()

            from llm_ontology_alignment.evaluations.calculate_result import run_schema_matching_evaluation

            # res = get_llm_table_selection_result(run_specs, refresh_existing_result=False)
            run_schema_matching_evaluation(run_specs, refresh_existing_result=False)
    # result = gpt4_family_difference()

    # effect_of_rewrite_gpt35()
    # run_valentine_experiments()

    return


if __name__ == "__main__":
    main()
