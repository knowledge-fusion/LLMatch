def test_create_vector_index():
    from llm_ontology_alignment.data_models.experiment_models import create_vector_index

    create_vector_index()


def test_update_db_rewrite():
    from llm_ontology_alignment.data_processors.rewrite_db_schema import update_db_table_rewrites

    run_specs = {"rewrite_llm": "gpt-4o"}
    update_db_table_rewrites(run_specs, "omop", "specimen")


def test_rewrite_db_columns():
    from llm_ontology_alignment.data_processors.rewrite_db_schema import rewrite_db_columns
    from llm_ontology_alignment.data_models.experiment_models import (
        OntologyAlignmentOriginalSchema,
        OntologySchemaRewrite,
    )

    updates = []
    drop_original = False
    if drop_original:
        OntologySchemaRewrite.objects(llm_model="original").delete()
        for item in OntologyAlignmentOriginalSchema.objects.all():
            updates.append(
                {
                    "llm_model": "original",
                    "original_table": item.table,
                    "original_column": item.column,
                    "table": item.table,
                    "column": item.column,
                    "table_description": item.extra_data["table_description"],
                    "column_description": item.extra_data["description"],
                    "database": item.database,
                }
            )
        res = OntologySchemaRewrite.upsert_many(updates)
    llm_models = OntologySchemaRewrite.objects.distinct("llm_model")
    for model in ["gpt-4o"]:
        rewrite_db_columns({"rewrite_llm": model})


def test_calculate_alternative_embeddings():
    from llm_ontology_alignment.data_processors.rewrite_db_schema import (
        calculate_alternative_embeddings,
    )

    calculate_alternative_embeddings()


def test_rewrite_statistics():
    from llm_ontology_alignment.data_models.experiment_models import (
        OntologyAlignmentOriginalSchema,
        OntologySchemaRewrite,
    )

    database = "mimic"
    model = "gpt-4o"
    tables = OntologyAlignmentOriginalSchema.objects(database=database).distinct("table")
    original_tables = OntologySchemaRewrite.objects(database=database, llm_model=model).distinct("original_table")
    assert len(tables) == len(original_tables)
    assert set(tables) == set(original_tables)
    for table in tables:
        original_columns = OntologyAlignmentOriginalSchema.objects(database=database, table=table).distinct("column")
        rewrite_columns = OntologySchemaRewrite.objects(
            database=database, llm_model=model, original_table=table
        ).distinct("original_column")
        assert len(original_columns) == len(rewrite_columns)
        assert set(original_columns) == set(rewrite_columns)
