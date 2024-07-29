# load MIMIC 2 data from the dataset
# Path: llm_ontology_alignment/__init__.py
import json
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
    from llm_ontology_alignment.alignment_strategies.evaluation import print_table_mapping_result
    from llm_ontology_alignment.data_models.experiment_models import OntologyMatchingEvaluationReport

    # "imdb-sakila", "omop-cms", "mimic_iii-omop", "cprd_aurum-omop", "cprd_gold-omop"
    for dataset in ["imdb-sakila", "omop-cms", "mimic_iii-omop", "cprd_aurum-omop", "cprd_gold-omop"]:
        for matching_llm in ["gpt-4o", "gpt-3.5-turbo"]:
            source_db, target_db = dataset.split("-")
            run_specs = {
                "source_db": source_db,
                "target_db": target_db,
                "matching_llm": matching_llm,
                "rewrite_llm": "gpt-3.5-turbo",
                "strategy": "schema_understanding_no_reasoning",
            }
            record = OntologyMatchingEvaluationReport.objects(
                **{
                    "source_database": run_specs["source_db"],
                    "target_database": run_specs["target_db"],
                    "matching_llm": run_specs["matching_llm"],
                    "rewrite_llm": run_specs["rewrite_llm"],
                    "strategy": run_specs["strategy"],
                }
            ).first()
            # if record:
            #     continue
            run_specs = {key: run_specs[key] for key in sorted(run_specs.keys())}

            # from llm_ontology_alignment.data_processors.load_data import import_ground_truth
            # import_ground_truth(run_specs["source_db"], run_specs["target_db"])

            rewrite = False
            if rewrite:
                from llm_ontology_alignment.data_processors.rewrite_db_schema import rewrite_db_columns

                rewrite_db_columns(run_specs)
                from llm_ontology_alignment.data_processors.load_data import update_rewrite_schema_constraints

                update_rewrite_schema_constraints(run_specs["source_db"])
                update_rewrite_schema_constraints(run_specs["target_db"])

            from llm_ontology_alignment.data_models.experiment_models import OntologyAlignmentExperimentResult

            OntologyAlignmentExperimentResult.objects(run_id_prefix=json.dumps(run_specs)).delete()
            run_id_prefix = json.dumps(run_specs)
            print("\n", run_id_prefix)
            print_table_mapping_result(run_specs)

            from llm_ontology_alignment.alignment_strategies.schema_understanding import run_matching, get_predictions

            run_matching(run_specs)
            from llm_ontology_alignment.alignment_strategies.evaluation import print_result_one_to_many

            print_result_one_to_many(run_specs, get_predictions_func=get_predictions)


if __name__ == "__main__":
    main()
