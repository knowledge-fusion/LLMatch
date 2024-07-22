def test_load_sql_file():
    from llm_ontology_alignment.data_processors.load_data import load_sql_file

    load_sql_file()


def test_import_ground_truth():
    from llm_ontology_alignment.data_processors.load_data import import_ground_truth

    import_ground_truth()


def test_load_and_save_table():
    from llm_ontology_alignment.data_processors.load_data import load_and_save_table

    load_and_save_table()


def test_print_schema():
    from llm_ontology_alignment.data_processors.load_data import print_schema

    print_schema("cms")


def test_load_sql_schema():
    from llm_ontology_alignment.data_processors.load_data import load_sql_schema

    load_sql_schema("MIMIC_III")


def test_load_schema_constrain():
    from llm_ontology_alignment.data_processors.load_data import load_schema_constraint_sql

    load_schema_constraint_sql("MIMIC_III")


def test_write_database_schema():
    from llm_ontology_alignment.data_processors.load_data import write_database_schema

    write_database_schema()


def test_export_sql_statements():
    from llm_ontology_alignment.data_processors.load_data import export_sql_statements

    for database in ["omop", "cprd_gold", "cprd_aurum", "mimic_iii"]:
        export_sql_statements(database)


def test_temp():
    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite

    # for database in OntologySchemaRewrite.objects(llm_model="original", linked_table__ne=None).distinct("database"):
    # for llm_model in OntologySchemaRewrite.objects(llm_model__ne="original", database=database).distinct("llm_model"):
    for database in ["omop", "cprd_gold", "cprd_aurum", "mimic_iii"]:
        for llm_model in ["gpt-3.5-turbo"]:
            for item in OntologySchemaRewrite.objects(llm_model="original", database=database, linked_table__ne=None):
                primary_key = OntologySchemaRewrite.objects(
                    llm_model=llm_model,
                    database=database,
                    original_table=item.linked_table,
                    original_column=item.linked_column,
                ).first()
                if not primary_key:
                    primary_key
                assert primary_key
                primary_key.is_primary_key = True
                primary_key.is_foreign_key = None
                primary_key.save()
                foreign_key = OntologySchemaRewrite.objects(
                    llm_model=llm_model, database=database, original_table=item.table, original_column=item.column
                ).first()

                if not foreign_key:
                    foreign_key
                assert foreign_key

                foreign_key.linked_table = primary_key.table
                foreign_key.linked_column = primary_key.column
                foreign_key.is_primary_key = None
                foreign_key.is_foreign_key = True
                foreign_key.save()
