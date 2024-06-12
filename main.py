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
    datasets = ["IMDB_Saki", "OMOP_Synthea", "MIMIC_OMOP"]
    models = ["gpt-4o", "gpt-3.5-turbo", "mistral-7b", "llama3-8b"]
    from llm_ontology_alignment.alignment_strategies.column_cluster_with_llm_summary import (
        print_ground_truth_cluster,
    )

    print_ground_truth_cluster(datasets[0])
    return
    for dataset in datasets:
        for model in models[2:]:
            run_specs = {
                "dataset": dataset,
                "matching_llm": "gpt-4o",
                "rewrite_llm": model,
                "strategy": "cluster_at_table_level_with_llm_summary_and_llm_column_name",
                "template": "top2-no-na",
                "use_translation": True,
                "n_clusters": 3,
            }

            run_specs = {key: run_specs[key] for key in sorted(run_specs.keys())}

            # load_and_save_schema(run_specs)
            # update_column_name(run_specs)

            # print_ground_truth(run_specs)

            # update_schema(run_specs)

            # from llm_ontology_alignment.alignment_strategies.table_cluster_with_llm_summary import (
            #     run_cluster_with_llm_summary,
            # )
            #
            # run_cluster_with_llm_summary(run_specs)
            # from llm_ontology_alignment.alignment_strategies.print_result import (
            #     print_result_one_to_many,
            # )
            #
            # print_result_one_to_many(run_specs)


if __name__ == "__main__":
    main()
