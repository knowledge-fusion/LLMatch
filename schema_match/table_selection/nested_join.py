def generate_table_selection_nested_join_result():
    from schema_match.data_models.experiment_models import OntologySchemaRewrite
    from schema_match.constants import EXPERIMENTS
    from schema_match.data_models.table_selection import OntologyTableSelectionResult

    for experiment in EXPERIMENTS:
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
                table_mapping[source_table] = list([target] for target in target_table_descriptions.keys())

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


def get_nested_join_table_selection_result(run_specs, refresh_existing_result=False):
    from schema_match.data_models.table_selection import OntologyTableSelectionResult

    source_database, target_database = run_specs["source_db"], run_specs["target_db"]
    assert run_specs["table_selection_strategy"] == "nested_join"
    res = OntologyTableSelectionResult.objects(
        **{
            "table_selection_llm": "",
            "table_selection_strategy": run_specs["table_selection_strategy"],
            "source_database": source_database,
            "target_database": target_database,
            "rewrite_llm": run_specs["rewrite_llm"],
        }
    ).first()
    assert res
    return res.data, 0


if __name__ == "__main__":
    generate_table_selection_nested_join_result()
