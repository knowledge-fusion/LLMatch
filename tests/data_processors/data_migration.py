import json


def test_migrate_table_selection_result():
    from llm_ontology_alignment.data_models.experiment_models import OntologyAlignmentExperimentResult
    from llm_ontology_alignment.data_models.table_selection import OntologyTableSelectionResult

    for item in OntologyAlignmentExperimentResult.objects(sub_run_id="get_table_mapping_embedding_selection"):
        run_specs = json.loads(item.run_id_prefix)
        source_database, target_database = run_specs["source_db"], run_specs["target_db"]
        res = OntologyTableSelectionResult.upsert(
            {
                "table_selection_llm": "",
                "table_selection_strategy": "vector_similarity",
                "source_database": source_database,
                "target_database": target_database,
                "rewrite_llm": item["rewrite_llm"],
                "data": item["json_result"],
            }
        )
        print(res)
