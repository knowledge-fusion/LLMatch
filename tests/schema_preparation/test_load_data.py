from schema_match.constants import EXPERIMENTS


def test_load_sql_file():
    from schema_match.schema_preparation.load_data import load_sql_file

    load_sql_file()


def test_print_schema():
    from schema_match.schema_preparation.load_data import print_schema

    print_schema("cms")


def test_load_sql_schema():
    from schema_match.schema_preparation.load_data import load_sql_schema
    from schema_match.schema_preparation.load_data import load_schema_constraint_sql
    from schema_match.schema_preparation.load_data import export_sql_statements

    for database in ["bank1", "bank2"]:
        load_sql_schema(database)
        load_schema_constraint_sql(database)
        export_sql_statements(database)


def test_export_ground_truth():
    from schema_match.schema_preparation.load_data import export_ground_truth
    from schema_match.schema_preparation.load_data import import_ground_truth

    for experiment in EXPERIMENTS[-2:]:
        source_db, target_db = experiment.split("-")
        import_ground_truth(source_db=source_db, target_db=target_db)
        export_ground_truth(source_db=source_db, target_db=target_db)


def test_write_database_schema():
    from schema_match.schema_preparation.load_data import write_database_schema

    write_database_schema()


def test_export_sql_statements():
    from schema_match.schema_preparation.load_data import export_sql_statements

    for database in [
        "cms",
        "omop",
        "mimic_iii",
        "cprd_aurum",
        "cprd_gold",
        "sakila",
        "imdb",
        "synthea",
    ]:
        export_sql_statements(database)
