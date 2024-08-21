import json


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


def update_run_specs():
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
        "schema_understanding_embedding_selection": {
            "table_selection_strategy": "vector_similarity",
            "column_matching_strategy": "llm",
        },
        "schema_understanding_no_foreign_keys": {
            "table_selection_strategy": "llm",
            "column_matching_strategy": "llm-no_foreign_keys",
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
    from llm_ontology_alignment.data_models.experiment_models import OntologyAlignmentExperimentResult

    version = 8
    for item in OntologyAlignmentExperimentResult.objects(
        version__ne=version, run_id_prefix__icontains="llm-reasoning"
    ):
        run_specs = json.loads(item.run_id_prefix)
        column_matching_strategy = configs[run_specs["strategy"]]["column_matching_strategy"]
        table_selection_strategy = configs[run_specs["strategy"]]["table_selection_strategy"]
        run_specs["table_selection_strategy"] = table_selection_strategy
        if table_selection_strategy.find("llm") > -1:
            run_specs["table_selection_llm"] = run_specs["matching_llm"]
        else:
            run_specs["table_selection_llm"] = "None"

        run_specs["column_matching_strategy"] = column_matching_strategy
        if column_matching_strategy.find("llm") == -1:
            run_specs["column_matching_llm"] = "None"
        else:
            if "matching_llm" not in run_specs:
                run_specs
            run_specs["column_matching_llm"] = run_specs["matching_llm"]
        run_specs = {key: run_specs[key] for key in sorted(run_specs.keys())}
        for key in [
            "table_selection_llm",
            "table_selection_strategy",
            "column_matching_llm",
            "column_matching_strategy",
        ]:
            assert run_specs[key], f"{run_specs} => {key}"
        item.run_id_prefix = json.dumps(run_specs)
        item.version = version
        item.save()

    return
