import json

from llm_ontology_alignment.alignment_strategies.schema_understanding import SCHEMA_UNDERSTANDING_STRATEGIES
from llm_ontology_alignment.evaluations.ontology_matching_evaluation import calculate_result_one_to_many

from llm_ontology_alignment.alignment_strategies.rematch import (
    get_predictions as rematch_get_predictions,
    run_matching as rematch_run_matching,
)
from llm_ontology_alignment.alignment_strategies.schema_understanding import (
    get_predictions as schema_understanding_get_predictions,
    run_matching as schema_understanding_run_matching,
)
from llm_ontology_alignment.alignment_strategies.coma_alignment import get_predictions as coma_get_predictions
from llm_ontology_alignment.alignment_strategies.valentine_alignment import (
    get_predictions as valentine_get_predictions,
    run_matching as valentine_run_matching,
)
from llm_ontology_alignment.data_models.experiment_models import OntologyAlignmentExperimentResult
from llm_ontology_alignment.data_processors.load_data import update_rewrite_schema_constraints
from llm_ontology_alignment.data_processors.rewrite_db_schema import rewrite_db_columns
from llm_ontology_alignment.table_selection.nested_join import get_nested_join_table_selection_result
from llm_ontology_alignment.table_selection.llm_selection import get_llm_table_selection_result
from llm_ontology_alignment.table_selection.embedding_selection import (
    get_table_to_table_vector_similarity_table_selection_result,
    get_column_to_table_vector_similarity_table_selection_result,
)

table_selection_func_map = {
    "nested_join": get_nested_join_table_selection_result,
    "llm": get_llm_table_selection_result,
    "llm-reasoning": get_llm_table_selection_result,
    "table_to_table_vector_similarity": get_table_to_table_vector_similarity_table_selection_result,
    "column_to_table_vector_similarity": get_column_to_table_vector_similarity_table_selection_result,
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
}


def run_schema_matching_evaluation(run_specs, refresh_rewrite=False, refresh_existing_result=False):
    for strategy in SCHEMA_UNDERSTANDING_STRATEGIES:
        run_match_func_map[strategy] = schema_understanding_run_matching
        get_prediction_func_map[strategy] = schema_understanding_get_predictions

    if refresh_rewrite:
        rewrite_db_columns(run_specs)
        update_rewrite_schema_constraints(run_specs["source_db"])
        update_rewrite_schema_constraints(run_specs["target_db"])

    if refresh_existing_result:
        OntologyAlignmentExperimentResult.objects(run_id_prefix=json.dumps(run_specs)).delete()
    table_selections = {}
    if run_specs["table_selection_strategy"] != "None":
        table_selections = table_selection_func_map[run_specs["table_selection_strategy"]](run_specs)

    run_match_func_map[run_specs["column_matching_strategy"]](run_specs, table_selections)

    run_id_prefix = json.dumps(run_specs)
    print("\n", run_id_prefix)
    # print_table_mapping_result(run_specs)
    calculate_result_one_to_many(
        run_specs, get_predictions_func=get_prediction_func_map[run_specs["column_matching_strategy"]]
    )
