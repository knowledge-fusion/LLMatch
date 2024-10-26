import json

from llm_ontology_alignment.constants import EXPERIMENTS
from llm_ontology_alignment.evaluations.ontology_matching_evaluation import calculate_result_one_to_many

from llm_ontology_alignment.alignment_strategies.rematch import (
    get_predictions as rematch_get_predictions,
    run_matching as rematch_run_matching,
    get_sanitized_result as rematch_get_sanitized_result,
)
from llm_ontology_alignment.alignment_strategies.schema_understanding import (
    get_predictions as schema_understanding_get_predictions,
    run_matching as schema_understanding_run_matching,
    get_sanitized_result as schema_understanding_get_sanitized_result,
)
from llm_ontology_alignment.alignment_strategies.coma_alignment import get_predictions as coma_get_predictions
from llm_ontology_alignment.alignment_strategies.valentine_alignment import (
    get_predictions as valentine_get_predictions,
    run_matching as valentine_run_matching,
)
from llm_ontology_alignment.data_models.experiment_models import OntologyAlignmentExperimentResult
from llm_ontology_alignment.data_processors.load_data import update_rewrite_schema_constraints
from llm_ontology_alignment.data_processors.rewrite_db_schema import rewrite_db_columns
from llm_ontology_alignment.table_selection.grund_tuth import (
    get_ground_truth_table_selection_result,
    get_all_to_all_table_selection_result,
)
from llm_ontology_alignment.table_selection.nested_join import get_nested_join_table_selection_result
from llm_ontology_alignment.table_selection.llm_selection import get_llm_table_selection_result
from llm_ontology_alignment.table_selection.embedding_selection import (
    get_table_to_table_vector_similarity_table_selection_result,
    get_column_to_table_vector_similarity_table_selection_result,
    get_table_to_table_vector_top10_similarity_table_selection_result,
)

table_selection_func_map = {
    "nested_join": get_nested_join_table_selection_result,
    "llm": get_llm_table_selection_result,
    "llm-reasoning": get_llm_table_selection_result,
    "llm-limit_context": get_llm_table_selection_result,
    "table_to_table_vector_similarity": get_table_to_table_vector_similarity_table_selection_result,
    "table_to_table_top_10_vector_similarity": get_table_to_table_vector_top10_similarity_table_selection_result,
    "column_to_table_vector_similarity": get_column_to_table_vector_similarity_table_selection_result,
    "ground_truth": get_ground_truth_table_selection_result,
    "None": get_all_to_all_table_selection_result,
}
run_match_func_map = {
    "llm-rematch": rematch_run_matching,
    "coma": valentine_run_matching,
    "similarity_flooding": valentine_run_matching,
    "cupid": valentine_run_matching,
    "llm": schema_understanding_run_matching,
    "llm-reasoning": schema_understanding_run_matching,
    "llm-no_foreign_keys": schema_understanding_run_matching,
    "llm-no_description": schema_understanding_run_matching,
    "llm-one_table_to_one_table": schema_understanding_run_matching,
}

get_prediction_func_map = {
    "llm-rematch": rematch_get_predictions,
    "coma": coma_get_predictions,
    "similarity_flooding": valentine_get_predictions,
    "cupid": valentine_get_predictions,
    "llm": schema_understanding_get_predictions,
    "llm-reasoning": schema_understanding_get_predictions,
    "llm-no_foreign_keys": schema_understanding_get_predictions,
    "llm-no_description": schema_understanding_get_predictions,
    "llm-one_table_to_one_table": schema_understanding_get_predictions,
}


def sanitized_llm_result():
    for experiment in EXPERIMENTS:
        for rewrite_llm in ["original", "gpt-3.5-turbo"]:
            source_db, target_db = experiment.split("-")

            for item in OntologyAlignmentExperimentResult.objects(
                operation_specs__operation="column_matching",
                operation_specs__source_db=source_db,
                operation_specs__target_db=target_db,
                operation_specs__rewrite_llm=rewrite_llm,
                operation_specs__column_matching_llm__ne="None",
                sanitized_result=None,
            ):
                if item.operation_specs["column_matching_strategy"] in ["llm-rematch"]:
                    res = rematch_get_sanitized_result(item)
                else:
                    res = schema_understanding_get_sanitized_result(item)
                print(res)


def run_schema_matching_evaluation(run_specs, refresh_rewrite=False, refresh_existing_result=False):
    from llm_ontology_alignment.data_models.evaluation_report import OntologyMatchingEvaluationReport

    flt = json.loads(json.dumps(run_specs))
    if "source_database" not in flt:
        flt["source_database"] = flt.pop("source_db")
        flt["target_database"] = flt.pop("target_db")
    result = OntologyMatchingEvaluationReport.objects(**flt).first()
    if result and (not refresh_existing_result) and result.details:
        print(f"Already calculated for {run_specs} {result.f1_score}")
        return

    if "source_db" not in run_specs:
        run_specs["source_db"] = run_specs["source_database"]
        run_specs["target_db"] = run_specs["target_database"]
    if refresh_rewrite:
        rewrite_db_columns(run_specs)
        update_rewrite_schema_constraints(run_specs["source_db"])
        update_rewrite_schema_constraints(run_specs["target_db"])

    if refresh_existing_result:
        res = OntologyAlignmentExperimentResult.objects(
            operation_specs__operation="column_matching",
            operation_specs__source_db=run_specs["source_db"],
            operation_specs__target_db=run_specs["target_db"],
            operation_specs__rewrite_llm=run_specs["rewrite_llm"],
            operation_specs__column_matching_strategy=run_specs["column_matching_strategy"],
            operation_specs__column_matching_llm=run_specs["column_matching_llm"],
        ).delete()
        print(f"Deleted {res} existing results")
    table_selections = table_selection_func_map[run_specs["table_selection_strategy"]](run_specs)
    # flattern target tables
    experiments = []
    for source_table, target_tables in table_selections.items():
        if not target_tables:
            continue
        if isinstance(target_tables[0], str):
            experiments.append((source_table, target_tables))
        else:
            for subtargets in target_tables:
                assert isinstance(subtargets[0], str)
                experiments.append((source_table, subtargets))
    run_match_func_map[run_specs["column_matching_strategy"]](run_specs, experiments)

    calculate_result_one_to_many(
        run_specs,
        get_predictions_func=get_prediction_func_map[run_specs["column_matching_strategy"]],
        table_selections=experiments,
    )


def recalculate_result():
    for experiment in EXPERIMENTS:
        version = 50
        for run_id_prefix in OntologyAlignmentExperimentResult.objects(
            dataset=experiment, version__ne=version
        ).distinct("run_id_prefix"):
            run_specs = json.loads(run_id_prefix)
            if run_specs["rewrite_llm"] == "deepinfra/meta-llama/Meta-Llama-3-8B-Instruct":
                continue
            if run_specs["table_selection_strategy"] == "vector_similarity":
                run_specs["table_selection_strategy"] = "column_to_table_vector_similarity"
                OntologyAlignmentExperimentResult.objects(run_id_prefix=run_id_prefix).update(
                    run_id_prefix=json.dumps(run_specs)
                )
            calculate_result_one_to_many(
                run_specs, get_predictions_func=get_prediction_func_map[run_specs["column_matching_strategy"]]
            )
            OntologyAlignmentExperimentResult.objects(run_id_prefix=run_id_prefix).update(set__version=version)
