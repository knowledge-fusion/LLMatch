# load MIMIC 2 data from the dataset
# Path: llm_ontology_alignment/__init__.py
import logging
from dotenv import load_dotenv
import sentry_sdk
from slack_logger import SlackFormatter, SlackHandler, FormatConfig
from sentry_sdk.integrations.logging import LoggingIntegration
import os

from llm_ontology_alignment.data_processors.rename_db_column import update_column_name

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
    # from llm_ontology_alignment.alignment_models.rematch import evaluate_experiment
    #
    # from llm_ontology_alignment.alignment_models.rematch import run_experiment
    #
    # J = -2
    # model = "gpt-4o"
    # template = "top5"
    # dataset = "OMOP_Synthea"
    #
    # run_id_prefix = f"rematch-J_{J}-model_{model}-template_{template}"
    #
    # run_experiment(dataset=dataset, model=model, J=J, template=template, split=2)
    #
    # evaluate_experiment(dataset=dataset, run_id_prefix=run_id_prefix)

    run_specs = {
        "dataset": "OMOP_Synthea",
        "llm": "gpt-4o",
        "strategy": "cluster_at_table_level_with_llm_summary_and_llm_column_name",
        "template": "top2-no-na",
        "n_clusters": 3,
    }
    run_specs = {key: run_specs[key] for key in sorted(run_specs.keys())}

    # update_schema(run_specs)
    # print_ground_truth_cluster(run_specs)
    update_column_name(run_specs)
    return
    from llm_ontology_alignment.alignment_models.table_cluster_with_llm_summary import (
        run_cluster_with_llm_summary,
    )

    run_cluster_with_llm_summary(run_specs)
    from llm_ontology_alignment.alignment_models.print_result import (
        print_result_one_to_many,
    )

    print_result_one_to_many(run_specs)


if __name__ == "__main__":
    main()
