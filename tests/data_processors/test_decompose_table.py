def test_decompose_table():
    from llm_ontology_alignment.data_processors.decompose_schema import decompose_table

    decompose_table("omop", "cohort")
