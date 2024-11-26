def test_update_db_rewrite():
    from llm_ontology_alignment.schema_preparation.rewrite_db_schema import update_db_table_rewrites

    run_specs = {"rewrite_llm": "gpt-4o"}
    update_db_table_rewrites(run_specs, "omop", "visit_occurrence")


def test_rewrite_db_columns():
    from llm_ontology_alignment.schema_preparation.rewrite_db_schema import rewrite_table_schema

    for model in ["gpt-3.5-turbo", "gpt-4o"]:
        run_specs = {"rewrite_llm": model, "source_db": "synthea", "target_db": "omop"}
        rewrite_table_schema(run_specs, "synthea", "providers")


def test_rewrite_statistics():
    from llm_ontology_alignment.data_models.experiment_models import (
        OntologySchemaRewrite,
    )

    database = "mimic"
    model = "gpt-4o"
    tables = OntologySchemaRewrite.objects(database=database, llm_model="original").distinct("table")
    original_tables = OntologySchemaRewrite.objects(database=database, llm_model=model).distinct("original_table")
    assert len(tables) == len(original_tables)
    assert set(tables) == set(original_tables)
    for table in tables:
        original_columns = OntologySchemaRewrite.objects(database=database, table=table, llm_model="original").distinct(
            "column"
        )
        rewrite_columns = OntologySchemaRewrite.objects(
            database=database, llm_model=model, original_table=table
        ).distinct("original_column")
        assert len(original_columns) == len(rewrite_columns)
        assert set(original_columns) == set(rewrite_columns)
