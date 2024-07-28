def test_load_sql_file():
    from llm_ontology_alignment.data_processors.load_data import load_sql_file

    load_sql_file()


def test_load_and_save_table():
    from llm_ontology_alignment.data_processors.load_data import load_and_save_table

    load_and_save_table()


def test_print_schema():
    from llm_ontology_alignment.data_processors.load_data import print_schema

    print_schema("cms")


def test_load_sql_schema():
    from llm_ontology_alignment.data_processors.load_data import load_sql_schema
    from llm_ontology_alignment.data_processors.load_data import load_schema_constraint_sql

    for database in ["imdb", "sakila"]:
        load_sql_schema(database.upper())
        load_schema_constraint_sql(database.upper())


def test_export_ground_truth():
    from llm_ontology_alignment.data_processors.load_data import export_ground_truth
    from llm_ontology_alignment.data_processors.load_data import import_ground_truth

    source_db = "omop"
    target_db = "cms"
    import_ground_truth(source_db=source_db, target_db=target_db)
    export_ground_truth(source_db=source_db, target_db=target_db)


def test_write_database_schema():
    from llm_ontology_alignment.data_processors.load_data import write_database_schema

    write_database_schema()


def test_export_sql_statements():
    from llm_ontology_alignment.data_processors.load_data import export_sql_statements

    for database in ["cms"]:
        export_sql_statements(database)


def test_temp():
    import os
    import csv

    # Get the directory of the current script
    for filename in [
        "OMOP_CMS_data.csv",
    ]:
        rows = []
        # Define the relative path to the CSV file
        tokens = filename.lower().split("_")
        database1 = tokens[0]
        database2 = tokens[1]
        script_dir = os.path.dirname(os.path.abspath(__file__))
        file_path = os.path.join(script_dir, "..", "..", "dataset/ground_truth_files", filename)
        # Open the CSV file and read its contents
        from collections import defaultdict

        ground_truth_data = defaultdict(set)
        from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite

        source_queryset = OntologySchemaRewrite.objects(database=database1, llm_model="original")
        target_queryset = OntologySchemaRewrite.objects(database=database2, llm_model="original")
        with open(file_path, mode="r", newline="", encoding="utf-8-sig") as file:
            for row in csv.DictReader(file):
                source, target, label = row[database1], row[database2], row["label"]
                assert len(label) == 1, row
                if label == "0":
                    continue
                source_table, source_column = source.split("-")
                target_table, target_column = target.split("-")
                check_record = False
                if check_record:
                    # if (
                    #     f"{source_table}.{source_column}" in source_alias
                    #     and f"{target_table}.{target_column}" in target_alias
                    # ):
                    #     source_table, source_column = source_alias[f"{source_table}.{source_column}"].split(".")
                    #     target_table, target_column = target_alias[f"{target_table}.{target_column}"].split(".")
                    source_record = source_queryset.filter(table=source_table, column=source_column).first()
                    assert source_record, database1 + ": " + row
                    target_record = target_queryset.filter(
                        table=target_table,
                        column=target_column,
                    ).first()
                    assert target_record, database1 + ": " + row
                rows.append([source_table, source_column, target_table, target_column, label])
        # Specify the filename
        file_path = os.path.join(script_dir, "..", "..", "dataset/ground_truth_files", "OMOP-CMS-ground_truth.csv")
        import csv

        # Write to the CSV file
        with open(file_path, mode="w", newline="") as file:
            writer = csv.writer(file)
            writer.writerows(rows)

        print(f"Data written to {filename}")
