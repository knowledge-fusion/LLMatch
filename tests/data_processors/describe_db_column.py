def test_describe_db_column():
    from llm_ontology_alignment.data_processors.load_data import (
        load_and_save_schema,
    )

    run_specs1 = {
        "dataset": "MIMIC_OMOP",
        "schemas": [
            {"matching_role": "source", "filename": "MIMIC_OMOP_source_schema.json"},
            {"matching_role": "target", "filename": "MIMIC_OMOP_target_schema.json"},
        ],
    }
    run_specs2 = {
        "dataset": "OMOP_Synthea",
        "schemas": [
            {"matching_role": "source", "filename": "OMOP_Synthea_source_schema.json"},
            {"matching_role": "target", "filename": "OMOP_Synthea_target_schema.json"},
        ],
    }
    run_specs3 = {
        "dataset": "IMDB_Saki",
        "schemas": [
            {"matching_role": "source", "filename": "IMDB_Saki_source_schema.json"},
            {"matching_role": "target", "filename": "IMDB_Saki_target_schema.json"},
        ],
    }
    for run_specs in [run_specs1, run_specs2, run_specs3]:
        load_and_save_schema(run_specs)


def test_update_schema():
    from llm_ontology_alignment.data_processors.load_data import update_schema

    runspecs = {
        "dataset": "MIMIC_OMOP",
        "schemas": [
            {"matching_role": "source", "filename": "MIMIC_OMOP_source_schema.json"},
            {"matching_role": "target", "filename": "MIMIC_OMOP_target_schema.json"},
        ],
    }
    update_schema(runspecs)


def test_create_vector_index():
    from llm_ontology_alignment.data_models.experiment_models import create_vector_index

    create_vector_index()


def test_query_vector_index():
    from llm_ontology_alignment.data_models.experiment_models import (
        OntologyAlignmentData,
    )
    from mongoengine import Q

    filter = Q(dataset__ne="OMOP_Synthea")
    res = OntologyAlignmentData.vector_search(
        index="default_embedding",
        query_text="the date the allergy was diagnosed.",
        filter=filter,
    )
    res = list(res)
    for item in res:
        print(item)
