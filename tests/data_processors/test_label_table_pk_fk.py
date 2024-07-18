def test_label_schema_primary_foreign_keys():
    from llm_ontology_alignment.data_processors.label_schema_pk_fk import label_schema_primary_foreign_keys

    label_schema_primary_foreign_keys()


def test_check_primary_foreign_key_labels():
    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite

    database = "cprd_aurum"
    for primary_key in OntologySchemaRewrite.objects(
        database=database, llm_model="gpt-3.5-turbo", column_description__icontains="primary key"
    ):
        if not primary_key.is_primary_key:
            OntologySchemaRewrite.objects(
                llm_model=primary_key.llm_model, database=primary_key.database, table=primary_key.table
            ).update(unset__is_primary_key=True, unset__is_foreign_key=True)
            print("not labelled as primary key", primary_key.table, primary_key.column, primary_key.column_description)

    for foreign_key in OntologySchemaRewrite.objects(
        database=database, llm_model="gpt-4o", column_description__icontains="foreign key"
    ):
        if not (foreign_key.is_foreign_key or foreign_key.is_primary_key):
            OntologySchemaRewrite.objects(
                llm_model=foreign_key.llm_model, database=foreign_key.database, table=foreign_key.table
            ).update(unset__is_primary_key=True, unset__is_foreign_key=True)
            print("not labelled as foreign key", foreign_key.table, foreign_key.column, foreign_key.column_description)


def test_link_foreign_key():
    from llm_ontology_alignment.data_processors.label_schema_pk_fk import link_foreign_key

    link_foreign_key()


def test_resolve_primary_key():
    from llm_ontology_alignment.data_processors.label_schema_pk_fk import resolve_primary_key

    resolve_primary_key()


def test_print_linked_tables():
    import json
    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite

    res = OntologySchemaRewrite.get_linked_columns(database="mimic_iii", llm_model="gpt-4o")
    print(json.dumps(res, indent=2))


def test_print_database_constrain_accuracy():
    from llm_ontology_alignment.data_processors.label_schema_pk_fk import print_database_constrain_accuracy

    print_database_constrain_accuracy()


def test_label_cprd_aurum_primary_foreign_keys():
    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite

    mappings = {
        "patid": "patient",
        "consid": "consultation",
        "staffid": "staff",
        "pracid": "practice",
        "obsid": "observation",
        "issueid": "drugissue",
    }
    database = "cprd_aurum"
    llm_model = "original"
    OntologySchemaRewrite.objects(database=database, llm_model=llm_model).update(
        unset__is_primary_key=True, unset__is_foreign_key=True, unset__linked_table=True, unset__linked_column=True
    )
    for column, table in mappings.items():
        OntologySchemaRewrite.objects(database=database, llm_model=llm_model, column=column, table=table).update(
            set__is_primary_key=True
        )
        res = OntologySchemaRewrite.objects(
            database=database, llm_model=llm_model, column=column, table__ne=table
        ).update(unset__is_primary_key=True, set__is_foreign_key=True, linked_table=table, linked_column=column)
        res
