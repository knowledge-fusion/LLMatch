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

    # for item in list(
    #     SchemaEmbedding.objects(
    #         dataset=datasets[0], similar_items=None, llm_model__in=models[0:2], matching_role="source"
    #     )
    # ):
    #     print(item)
    #     item.similar_target_items()
    print("Calculating alternative embeddings")
    # calculate_alternative_embeddings()
    for dataset in datasets:
        for model in models[0:1]:
            run_specs = {
                "dataset": dataset,
                "matching_llm": "gpt-4o",
                "rewrite_llm": model,
                "strategy": "match_with_schema_understanding",
                "template": "top2-no-na",
                "use_translation": True,
                "n_clusters": 3,
            }

            run_specs = {key: run_specs[key] for key in sorted(run_specs.keys())}

            # load_and_save_schema(run_specs)
            # update_column_name(run_specs)
            # update_schema(run_specs)

            # print_ground_truth(run_specs)

            run_matching_with_schema_understanding(run_specs)
            from llm_ontology_alignment.alignment_strategies.print_result import (
                print_result_one_to_many,
            )

            print_result_one_to_many(run_specs)


if __name__ == "__main__":
    main()
