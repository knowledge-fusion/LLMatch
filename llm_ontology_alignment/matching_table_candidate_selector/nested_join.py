def generate_table_selection_nested_join_result():
    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite
    from llm_ontology_alignment.evaluations.latex_report.full_experiment_f1_score import experiments
    from llm_ontology_alignment.data_models.table_selection import OntologyTableSelectionResult

    for experiment in experiments:
        for rewrite_llm in ["gpt-3.5-turbo", "gpt-4o", "original"]:
            source_db, target_db = experiment.split("-")
            res = OntologyTableSelectionResult.objects(
                **{
                    "source_database": source_db,
                    "target_database": target_db,
                    "table_selection_llm": "",
                    "table_selection_strategy": "nested_join",
                    "rewrite_llm": rewrite_llm,
                }
            ).first()
            if res:
                continue
            source_table_descriptions = OntologySchemaRewrite.get_database_description(
                source_db, rewrite_llm, include_foreign_keys=True
            )
            target_table_descriptions = OntologySchemaRewrite.get_database_description(
                target_db, rewrite_llm, include_foreign_keys=True
            )

            table_mapping = dict()
            for source_table in source_table_descriptions.keys():
                table_mapping[source_table] = list(target_table_descriptions.keys())

            res = OntologyTableSelectionResult.upsert(
                {
                    "source_database": source_db,
                    "target_database": target_db,
                    "table_selection_llm": "",
                    "table_selection_strategy": "nested_join",
                    "rewrite_llm": rewrite_llm,
                    "data": table_mapping,
                }
            )
            print(table_mapping)
            print(res)
