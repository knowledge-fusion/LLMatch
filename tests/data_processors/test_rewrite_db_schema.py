def test_create_vector_index():
    from llm_ontology_alignment.data_models.experiment_models import create_vector_index

    create_vector_index()


def test_rewrite_db_columns():
    from llm_ontology_alignment.data_processors.rewrite_db_schema import rewrite_db_columns
    from llm_ontology_alignment.data_models.experiment_models import (
        OntologyAlignmentOriginalSchema,
        OntologySchemaRewrite,
    )

    updates = []
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
