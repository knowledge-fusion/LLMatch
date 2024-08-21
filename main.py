# load MIMIC 2 data from the dataset
# Path: llm_ontology_alignment/__init__.py
import json
import logging
from dotenv import load_dotenv
import sentry_sdk
from slack_logger import SlackFormatter, SlackHandler, FormatConfig
from sentry_sdk.integrations.logging import LoggingIntegration
import os

from llm_ontology_alignment.evaluations.ontology_matching_evaluation import run_schema_matching_evaluation
from llm_ontology_alignment.matching_table_candidate_selector.nested_join import (
    generate_table_selection_nested_join_result,
)

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
    from llm_ontology_alignment.data_models.experiment_models import OntologyAlignmentExperimentResult

    generate_table_selection_nested_join_result()
    return
    version = 1
    for item in OntologyAlignmentExperimentResult.objects(
        run_id_prefix__contains="schema_understanding", version__ne=version
    ):
        if item.run_id_prefix.find("table_selection_llm") != -1:
            item.version = version
            item.save()
            continue

        run_specs = json.loads(item.run_id_prefix)
        column_matching_strategy = None
        for strategy in ["coma", "cupid", "similarity_flooding"]:
            if run_specs["strategy"] == f"schema_understanding-{strategy}":
                column_matching_strategy = strategy

        if run_specs["strategy"] in ["schema_understanding_embedding_selection"]:
            run_specs["table_selection_llm"] = "vector_similarity"
            run_specs["table_selection_strategy"] = ""
        elif run_specs["strategy"] in ["schema_understanding_one_table_to_one_table"]:
            run_specs["table_selection_llm"] = "nested_join"
            run_specs["table_selection_strategy"] = ""
        elif column_matching_strategy:
            run_specs["table_selection_llm"] = "gpt-4o"
            run_specs["table_selection_strategy"] = "llm"
        else:
            run_specs["table_selection_llm"] = run_specs["matching_llm"]
            run_specs["table_selection_strategy"] = "llm"

        if column_matching_strategy:
            run_specs["column_matching_llm"] = ""
            run_specs["column_matching_strategy"] = column_matching_strategy
        else:
            if "matching_llm" not in run_specs:
                run_specs
            run_specs["column_matching_strategy"] = "llm"
            run_specs["column_matching_llm"] = run_specs["matching_llm"]
        run_specs = {key: run_specs[key] for key in sorted(run_specs.keys())}
        item.run_id_prefix = json.dumps(run_specs)
        item.save()

    return

    from llm_ontology_alignment.alignment_strategies.valentine_alignment import run_valentine_experiments

    run_valentine_experiments()
    return
    from llm_ontology_alignment.data_models.experiment_models import OntologyMatchingEvaluationReport

    from llm_ontology_alignment.evaluations.latex_report.full_experiment_f1_score import experiments

    for dataset in experiments:
        source_db, target_db = dataset.split("-")
        run_specs = {
            "source_db": source_db,
            "target_db": target_db,
            "strategy": "schema_understanding_pairwise_clustering",
            "matching_llm": "gpt-4o",
            "rewrite_llm": "original",
            "table_selection_strategy": "schema_understanding",
        }
        if True:
            record = OntologyMatchingEvaluationReport.objects(
                strategy=run_specs["strategy"],
                source_database=run_specs["source_db"],
                target_database=run_specs["target_db"],
                rewrite_llm=run_specs["rewrite_llm"],
                matching_llm=run_specs["matching_llm"],
            ).first()
            if record:
                continue
            try:
                run_schema_matching_evaluation(run_specs, refresh_existing_result=False, refresh_rewrite=False)
                print(run_specs)
            except Exception as e:
                print(e)
                print(run_specs)
                raise e


if __name__ == "__main__":
    main()
