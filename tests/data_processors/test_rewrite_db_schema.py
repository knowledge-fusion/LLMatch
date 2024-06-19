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
                "rewritten_table": item.table,
                "rewritten_column": item.column,
                "rewritten_table_description": item.extra_data["table_description"],
                "rewritten_column_description": item.extra_data["description"],
                "database": item.database,
            }
        )
    res = OntologySchemaRewrite.upsert_many(updates)
    llm_models = OntologySchemaRewrite.objects.distinct("llm_model")
    for model in llm_models[:-1]:
        rewrite_db_columns({"rewrite_llm": model})


def test_query_vector_index():
    from llm_ontology_alignment.data_models.experiment_models import (
        OntologyAlignmentData,
    )
    from mongoengine import Q

    filter = Q(dataset="OMOP_Synthea")
    record = OntologyAlignmentData.objects(filter).first()
    similar_items = record.similar_target_items()
    print(similar_items)


def test_query_rewritten_vector_index():
    from llm_ontology_alignment.data_models.experiment_models import (
        SchemaRewrite,
    )
    from mongoengine import Q

    filter = Q(dataset="OMOP_Synthea") & Q(llm_model="gpt-3.5-turbo")
    res = SchemaRewrite.vector_search(
        query_text="the date the allergy was diagnosed.",
        filter=filter,
    )
    for item in res:
        print(
            round(item["score"], 2),
            item["original_table"],
            item["original_column"],
            item["rewritten_table"],
            item["rewritten_column"],
        )


def test_calculate_alternative_embeddings():
    from llm_ontology_alignment.data_processors.rewrite_db_schema import (
        calculate_alternative_embeddings,
    )

    calculate_alternative_embeddings()
