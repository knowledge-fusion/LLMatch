def test_label_schema_primary_foreign_keys():
    from llm_ontology_alignment.data_processors.label_schema_pk_fk import label_schema_primary_foreign_keys

    label_schema_primary_foreign_keys()


def test_link_foreign_key():
    from llm_ontology_alignment.data_processors.label_schema_pk_fk import link_foreign_key

    link_foreign_key()


def test_resolve_primary_key():
    from llm_ontology_alignment.data_processors.label_schema_pk_fk import resolve_primary_key

    resolve_primary_key()
