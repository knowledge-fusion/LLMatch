def test_describe_db_column():
    from llm_ontology_alignment.data_processors.describe_db_column import load_and_save_schema

    llm = "gpt4o"
    table = "table"
    schema = load_and_save_schema(filename='MIMIC_OMOP_target_schema.json', dataset='MIMIC_OMOP', matching_role='target')
    schema


def test_create_vector_index():
    from llm_ontology_alignment.data_models.experiment_models import create_vector_index
    create_vector_index()

def test_query_vector_index():
    from llm_ontology_alignment.data_models.experiment_models import OntologyAlignmentData
    from mongoengine import Q
    filter = Q(dataset__ne='OMOP_Synthea')
    res = OntologyAlignmentData.vector_search(index="default_embedding", query_text="the date the allergy was diagnosed.", filter=filter)
    res = list(res)
    for item in res:
        print(item)