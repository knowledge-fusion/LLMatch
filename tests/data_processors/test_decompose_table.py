def test_decompose_table():
    from llm_ontology_alignment.schema_preparation.decompose_schema import decompose_table

    decompose_table("omop", "cohort")
