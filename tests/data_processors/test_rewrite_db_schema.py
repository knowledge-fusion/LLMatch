def test_create_vector_index():
    from llm_ontology_alignment.data_models.experiment_models import create_vector_index

    create_vector_index()


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
