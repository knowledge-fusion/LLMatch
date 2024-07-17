def test_sanitize_schema():
    from llm_ontology_alignment.data_processors.load_data import sanitize_schema

    sanitize_schema()


def test_load_sql_file():
    from llm_ontology_alignment.data_processors.load_data import load_sql_file

    load_sql_file()


def test_load_and_save_table():
    from llm_ontology_alignment.data_processors.load_data import load_and_save_table

    load_and_save_table()


def test_print_schema():
    from llm_ontology_alignment.data_processors.load_data import print_schema

    print_schema("cms")


def test_label_primary_key():
    from llm_ontology_alignment.data_processors.load_data import label_primary_key

    label_primary_key()


def test_migrate_scheam_rewrite():
    from llm_ontology_alignment.data_processors.load_data import migrate_schema_rewrite

    migrate_schema_rewrite()


def test_migrate_schema_rewrite_embedding():
    from llm_ontology_alignment.data_processors.load_data import migrate_schema_rewrite_embedding

    migrate_schema_rewrite_embedding()


def test_load_schema_constrain():
    from llm_ontology_alignment.data_processors.load_data import load_schema_constrain

    load_schema_constrain()
