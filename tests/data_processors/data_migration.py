import json

from llm_ontology_alignment.data_models.evaluation_report import OntologyMatchingEvaluationReport


def test_migrate_table_selection_result():
    from llm_ontology_alignment.data_models.experiment_models import OntologyAlignmentExperimentResult

    version = 9
    item = OntologyAlignmentExperimentResult.objects(
        sub_run_id__contains="table_candidate_selection", version__ne=version
    ).first()
    while item:
        run_specs = json.loads(item.run_id_prefix)
        from llm_ontology_alignment.table_selection.llm_selection import get_llm_table_selection_result

        res = get_llm_table_selection_result(run_specs)

        print(res)
        res2 = OntologyAlignmentExperimentResult.objects(
            run_id_prefix=item.run_id_prefix, sub_run_id__contains="table_candidate_selection"
        ).update(set__version=version)
        assert res2
        item = OntologyAlignmentExperimentResult.objects(
            sub_run_id__contains="table_candidate_selection", version__ne=version
        ).first()


configs = {
    "schema_understanding-cupid": {
        "table_selection_strategy": "llm",
        "column_matching_strategy": "cupid",
    },
    "cupid": {
        "table_selection_strategy": "None",
        "column_matching_strategy": "cupid",
    },
    "similarity_flooding": {
        "table_selection_strategy": "None",
        "column_matching_strategy": "similarity_flooding",
    },
    "schema_understanding_no_reasoning": {
        "table_selection_strategy": "llm",
        "column_matching_strategy": "llm",
    },
    "gpt-4o": {"table_selection_strategy": "None", "column_matching_strategy": "llm", "column_matching_llm": "gpt-4o"},
    "gpt-3.5-turbo": {
        "table_selection_strategy": "None",
        "column_matching_strategy": "llm",
        "column_matching_llm": "gpt-3.5-turbo",
    },
    "schema_understanding_embedding_selection": {
        "table_selection_strategy": "vector_similarity",
        "column_matching_strategy": "llm",
    },
    "schema_understanding_no_foreign_keys": {
        "table_selection_strategy": "llm",
        "column_matching_strategy": "llm-no_foreign_keys",
    },
    "unicorn": {
        "table_selection_strategy": "None",
        "column_matching_strategy": "unicorn",
    },
    "coma": {
        "table_selection_strategy": "None",
        "column_matching_strategy": "coma",
    },
    "schema_understanding_no_description": {
        "table_selection_strategy": "llm",
        "column_matching_strategy": "llm-no_description",
    },
    "schema_understanding_one_table_to_one_table": {
        "table_selection_strategy": "nested_join",
        "column_matching_strategy": "llm",
    },
    "schema_understanding": {
        "table_selection_strategy": "llm-reasoning",
        "column_matching_strategy": "llm-reasoning",
    },
    "rematch": {
        "table_selection_strategy": "column_to_table_vector_similarity",
        "column_matching_strategy": "llm-rematch",
    },
    "schema_understanding-coma": {
        "table_selection_strategy": "llm",
        "column_matching_strategy": "coma",
    },
}


def update_result():
    version = 4
    for item in OntologyMatchingEvaluationReport.objects(version__ne=version):
        item.column_matching_strategy = configs[item.strategy]["column_matching_strategy"]
        item.table_selection_strategy = configs[item.strategy]["table_selection_strategy"]
        if item.table_selection_strategy.find("llm") > -1:
            item.table_selection_llm = item.matching_llm
        else:
            item.table_selection_llm = "None"

        if item.column_matching_strategy.find("llm") == -1:
            item.column_matching_llm = "None"
        else:
            item.column_matching_llm = item.matching_llm
        if item.table_selection_strategy == "vector_similarity":
            item.table_selection_strategy = "column_to_table_vector_similarity"
        item.version = version
        item.save()
