def test_sanitize_schema():
    from llm_ontology_alignment.data_processors.load_data import sanitize_schema

    sanitize_schema()


def test_link_foreign_key():
    from llm_ontology_alignment.data_processors.load_data import link_foreign_key

    link_foreign_key()


def test_print_schema():
    from llm_ontology_alignment.data_processors.load_data import print_schema

    run_specs = {"dataset": "MIMIC_OMOP"}
    print_schema(run_specs)


def test_label_primary_key():
    from llm_ontology_alignment.data_processors.load_data import label_primary_key

    label_primary_key()
