def test_sanitize_schema():
    from llm_ontology_alignment.data_processors.load_data import sanitize_schema

    sanitize_schema()


def test_load_and_save_table():
    from llm_ontology_alignment.data_processors.load_data import load_and_save_table

    load_and_save_table()


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


def test_migrate_scheam_rewrite():
    from llm_ontology_alignment.data_processors.load_data import migrate_schema_rewrite

    migrate_schema_rewrite()
