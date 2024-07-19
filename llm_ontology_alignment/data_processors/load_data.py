import json
from collections import defaultdict
import os
from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite

script_dir = os.path.dirname(os.path.abspath(__file__))


def import_ground_truth():
    import os

    # Get the directory of the current script
    database_data = defaultdict(lambda: defaultdict(dict))
    table_descriptions = defaultdict(dict)
    ground_truth_data = defaultdict(list)
    for filename in [
        # "OMOP_Synthea_Data.csv",
        "MIMIC_III-OMOP_ground_truth.csv",
    ]:
        # Define the relative path to the CSV file
        database1 = "mimic_iii"
        database2 = "omop"
        file_path = os.path.join(script_dir, "..", "..", "dataset", filename)
        # Open the CSV file and read its contents
        with open(file_path, mode="r", newline="", encoding="utf-8-sig") as file:
            for row in file:
                # database1, database2, _ = filename.lower().split("_")
                tokens = row.split(",")
                table1, column1 = tokens[0].lower(), tokens[1].lower()
                table2, column2 = tokens[2].lower(), tokens[3].lower()
                ground_truth_data[f"{database1}-{database2}"].append(
                    {
                        "source_table": table1,
                        "source_column": column1,
                        "target_table": table2,
                        "target_column": column2,
                    }
                )
    for dataset, mappings in ground_truth_data.items():
        from llm_ontology_alignment.data_models.experiment_models import OntologyAlignmentGroundTruth

        res = OntologyAlignmentGroundTruth.upsert_many(
            [
                {
                    "dataset": dataset,
                    "data": mappings,
                }
            ]
        )
        print(res)


def load_and_save_table():
    import os
    import csv
    from llm_ontology_alignment.data_models.experiment_models import (
        OntologyAlignmentOriginalSchema,
    )

    # Get the directory of the current script
    database_data = defaultdict(lambda: defaultdict(dict))
    table_descriptions = defaultdict(dict)
    ground_truth_data = defaultdict(list)
    for filename in [
        # "OMOP_Synthea_Data.csv",
        "OMOP_CMS_data.csv",
        "OMOP_Synthea_Data2.csv",
    ]:
        # Define the relative path to the CSV file

        file_path = os.path.join(script_dir, "..", "..", "dataset", filename)
        # Open the CSV file and read its contents
        with open(file_path, mode="r", newline="", encoding="utf-8-sig") as file:
            csv_reader = csv.DictReader(file)
            for row in csv_reader:
                database1, database2, _ = filename.lower().split("_")
                table1, column1 = row[database1].lower().split("-")
                table2, column2 = row[database2].lower().split("-")
                table1_description, column1_description = row["d1"], row["d2"]
                table2_description, column2_description = row["d3"], row["d4"]
                table_descriptions[database1][table1] = table1_description
                table_descriptions[database2][table2] = table2_description
                database_data[database1][table1][column1] = {"name": column1, "description": column1_description}
                database_data[database2][table2][column2] = {"name": column2, "description": column2_description}
                label = row["label"]
                if int(label) == 1:
                    ground_truth_data[f"{database1}_{database2}"].append(
                        {
                            "source_table": table1,
                            "source_column": column1,
                            "target_table": table2,
                            "target_column": column2,
                        }
                    )
    for dataset, mappings in ground_truth_data.items():
        from llm_ontology_alignment.data_models.experiment_models import OntologyAlignmentGroundTruth

        res = OntologyAlignmentGroundTruth.upsert_many(
            [
                {
                    "dataset": dataset,
                    "data": mappings,
                }
            ]
        )
        print(res)
    # for filename in [
    #     "MIMIC_Schema.csv",
    #     "OMOP_Schema.csv",
    # ]:
    #     file_path = os.path.join(script_dir, "..", "..", "dataset", filename)
    #     # Open the CSV file and read its contents
    #     with open(file_path, mode="r", newline="", encoding="utf-8-sig") as file:
    #         csv_reader = csv.DictReader(file)
    #         for row in csv_reader:
    #             database = filename.lower().split("_")[0]
    #             # TableName,TableDesc,ColumnName,ColumnDesc,ColumnType,IsPK,IsFK,FK
    #             table, table_description, column, column_description = (
    #                 row.pop("TableName"),
    #                 row.pop("TableDesc"),
    #                 row.pop("ColumnName"),
    #                 row.pop("ColumnDesc"),
    #             )
    #             table = table.lower().strip()
    #             column = column.lower().strip()
    #             table_description = table_description.strip()
    #             column_data = database_data[database].get(table, {}).get(column, {})
    #             if column_data:
    #                 row.update(column_data)
    #             row["name"] = column
    #             row["description"] = row.get("description", "") + column_description
    #             database_data[database.lower()][table.lower()][column.lower()] = row
    #             if len(table_description) > len(table_descriptions[database.lower()].get(table.lower(), "")):
    #                 table_descriptions[database.lower()][table.lower()] = table_description
    records = []
    existing_databases = OntologyAlignmentOriginalSchema.objects().distinct("database")
    for database, tables in database_data.items():
        if database in existing_databases:
            continue
        for table, columns in tables.items():
            table_description = table_descriptions[database][table]
            assert table_description is not None
            for column, column_data in columns.items():
                column_data["table_description"] = table_description.replace("\u00a0", " ").strip()
                column_data["description"] = column_data["description"].replace("\u00a0", " ").strip()
                records.append(
                    {
                        "database": database.lower().strip(),
                        "table": table.lower().strip(),
                        "column": column,
                        "extra_data": column_data,
                        "version": 0,
                    }
                )

    # OntologyAlignmentOriginalSchema.objects.delete()
    res = OntologyAlignmentOriginalSchema.upsert_many(records)
    print(res)


def print_schema(database):
    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite

    tables = OntologySchemaRewrite.objects(
        database=database,
        llm_model="gpt-4o",
    ).distinct("table")
    for table in tables:
        table_description = OntologySchemaRewrite.get_table_columns_description(database, table)
        table_description["columns"] = list(table_description["columns"].keys())
        print("\n", json.dumps(table_description, indent=2))


def load_sql_file():
    for filename in [
        # "OMOP-comment.sql",
        "MIMIC_III-comment.sql",
    ]:
        # Define the relative path to the CSV file

        file_path = os.path.join(script_dir, "..", "..", "dataset", filename)
        # Open the CSV file and read its contents
        database_data = defaultdict(dict)
        updates = []
        database = filename.lower().split(".")[0]
        table_name = None
        table_description = None
        with open(file_path, mode="r") as f:
            sql_script = f.read()

            # Split the content by ';' and remove any leading/trailing whitespace from each statement
            sql_statements = [stmt.strip() for stmt in sql_script.split(";") if stmt.strip()]
            for row in sql_statements:
                row = row.strip()
                if row.find("COMMENT ON") > -1:
                    tokens = row.split("'")
                    if row.find("ON TABLE") > -1:
                        table_name = [item for item in tokens[0].strip().split(" ") if item][-2].lower()
                        assert table_name
                        table_description = tokens[1].strip()
                        assert table_description
                    if row.find("ON COLUMN") > -1:
                        column_name = tokens[0].split(".")[-1].strip().split(" ")[0].strip().lower()
                        assert column_name
                        column_description = tokens[1].strip()
                        assert column_description
                        record = {
                            "column": column_name,
                            "column_description": column_description,
                            "table_description": table_description,
                            "table": table_name,
                            "database": database,
                            "original_column": column_name,
                            "original_table": table_name,
                            "llm_model": "original",
                        }
                        database_data[table_name][column_name] = record
                        updates.append(database_data[table_name][column_name])
        from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite

        res1 = OntologySchemaRewrite.objects(database=database, llm_model="original").delete()
        res2 = OntologySchemaRewrite.upsert_many(updates)


def print_ground_truth(run_specs):
    from llm_ontology_alignment.data_models.experiment_models import (
        OntologyAlignmentGroundTruth,
    )

    mappings = OntologyAlignmentGroundTruth.objects(dataset=run_specs["dataset"]).first().data
    for mapping in mappings:
        print(mapping)


def sanitize_schema():
    from llm_ontology_alignment.data_models.experiment_models import OntologyAlignmentOriginalSchema

    version = 3
    # OntologyAlignmentOriginalSchema.objects.update(
    #     unset__is_foreign_key=True, unset__is_primary_key=True, unset__linked_table=True, unset__linked_column=True
    # )
    for item in OntologyAlignmentOriginalSchema.objects(version__ne=version):
        try:
            if (
                item.extra_data.get("IsFk", "") in ["YES"]
                or item.extra_data.get("IsFK", "") in ["YES"]
                or item.extra_data["description"].lower().find("foreign key") > -1
            ):
                item.is_foreign_key = True
                linked_table, linked_column = None, None
                if isinstance(item.extra_data.get("FK table"), str):
                    linked_table = item.extra_data["FK table"].strip().lower()
                    linked_column = item.extra_data["FK column"].strip().lower()
                elif isinstance(item.extra_data.get("FK"), str):
                    linked_table, linked_column = item.extra_data["FK"][1:-1].lower().split(",")
                    linked_table = linked_table.strip()
                    linked_column = linked_column.strip()
                if linked_table:
                    if not linked_column:
                        linked_column = OntologyAlignmentOriginalSchema.objects(
                            database=item.database, table=linked_table, is_primary_key=True
                        ).first()
                        if linked_column:
                            linked_column = linked_column.column
                        else:
                            linked_column = OntologyAlignmentOriginalSchema.objects(
                                database=item.database, table=linked_table, column=f"{linked_table}_id"
                            ).first()
                            if linked_column:
                                linked_column = linked_column.column
                            else:
                                linked_column

                    primary_key = OntologyAlignmentOriginalSchema.objects(
                        database=item.database, table=linked_table, column=linked_column
                    ).first()
                    if not primary_key:
                        raise ValueError(f"Primary key not found for {linked_table}.{linked_column}")
                    primary_key.is_primary_key = True
                    primary_key.save()
                    item.linked_table = linked_table
                    item.linked_column = linked_column

            elif (
                item.extra_data.get("IsPk", "") in ["YES"]
                or item.extra_data.get("IsPK", "") in ["YES"]
                or item.extra_data["description"].lower().find("primary key") > -1
                or item.extra_data["description"].lower() in ["beneficiary code"]
            ):
                item.is_primary_key = True
            elif item.extra_data["description"].lower().find("alphanumeric unique identifier") > -1:
                item.is_foreign_key = True
            item.version = version
            item.save()
        except Exception as exp:
            print(exp)


def label_primary_key():
    from llm_ontology_alignment.data_models.experiment_models import OntologyAlignmentOriginalSchema
    from llm_ontology_alignment.services.language_models import complete

    databases = OntologyAlignmentOriginalSchema.objects().distinct("database")
    for database in databases:
        primary_keys = dict()
        for item in OntologyAlignmentOriginalSchema.objects(is_primary_key=True, database=database):
            primary_keys[item.table] = item.column
        for table in OntologyAlignmentOriginalSchema.objects(
            table__nin=primary_keys.keys(), database=database
        ).distinct("table"):
            column_descriptions = {}
            table_description = None
            for item in OntologyAlignmentOriginalSchema.objects(table=table, database=database):
                column_descriptions[item.column] = item.extra_data["description"]
                table_description = item.extra_data["table_description"]
            try:
                prompt = "select the primary key for the table"
                prompt += f"\nTable: {table}."
                prompt += f"\nTable Description: {table_description}"
                prompt += f"\nColumn options: {column_descriptions}"
                prompt += "\n only output a json object of the format and no other text {'primary_key_column_name': 'selected_column_name'}"
                response = complete(
                    prompt,
                    "gpt-4o",
                    {
                        "database": database,
                        "table_name": table,
                        "task": "label_primary_key",
                    },
                )
                selected_column = response.json()["extra"]["extracted_json"]["primary_key_column_name"]
                OntologyAlignmentOriginalSchema.objects(database=database, table=table, column=selected_column).update(
                    is_primary_key=True
                )
            except Exception as exp:
                print(exp)


def load_sql_schema(database):
    llm_model = "original"
    table_columns = defaultdict(dict)

    for filename in [
        f"{database}.sql",
    ]:
        file_path = os.path.join(script_dir, "..", "..", "dataset/original_schema_files", filename)
        # Open the CSV file and read its contents
        database = filename.lower().split(".")[0]
        with open(file_path, mode="r", newline="", encoding="utf-8-sig") as file:
            result = []
            table_name = ""
            for line in file:
                if line.startswith("--") or line.startswith("DROP TABLE"):
                    continue
                    # Initialize the list for storing table and column information

                    # Read the statement line by line
                line = line.strip()
                # Check for table name
                if line.startswith("CREATE TABLE"):
                    parts = line.split()
                    table_name = parts[2].replace("@cdmDatabaseSchema.", "").strip("()").lower()
                # Check for column definitions
                elif line and line.strip() not in ["(", ");"]:
                    tokens = line.lower().split()
                    column_name, column_type = tokens[0].strip(","), tokens[1].strip(",")
                    table_columns[table_name][column_name] = {
                        "table": table_name,
                        "column": column_name,
                        "column_type": column_type,
                        "database": database,
                        "llm_model": llm_model,
                    }
                # Convert the result list to JSON

                # Print the JSON result

    for filename in [
        f"{database}-comment.sql",
    ]:
        file_path = os.path.join(script_dir, "..", "..", "dataset/original_schema_files", filename)
        # Open the CSV file and read its contents
        rows = []
        with open(file_path, mode="r", newline="", encoding="utf-8-sig") as file:
            for line in file:
                line = line.strip()
                if line.startswith("--"):
                    continue
                if line:
                    rows.append(line)
        statements = " ".join(rows).split(";")
        for line in statements:
            line = line.replace("\n", " ").strip() + ";"
            # Check for table name
            if line.startswith("COMMENT ON TABLE"):
                parts = line.split()
                table_name = parts[3].replace("@cdmDatabaseSchema.", "").strip("()").lower()
                table_description = " ".join(parts[5:]).strip("'")
                assert table_description
                for column, column_data in table_columns[table_name].items():
                    column_data["table_description"] = table_description
            # Check for column definitions
            elif line.startswith("COMMENT ON COLUMN"):
                try:
                    import re

                    # Regular expression pattern
                    pattern = r"COMMENT ON COLUMN (\w+)\.(\w+) IS '(.*)';"

                    # Search for the pattern in the SQL statement
                    matches = re.findall(pattern, line)
                    if not matches:
                        pattern = r"COMMENT ON COLUMN (\w+)\.(\w+) is '(.*)';"
                        matches = re.findall(pattern, line)
                    assert matches
                    # Initialize the list for storing the extracted information

                    for match in matches:
                        table_name, column_name, description = match
                        assert description
                        table_columns[table_name.lower()][column_name.lower()]["column_description"] = description
                except Exception as e:
                    e
    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite

    updates = []
    for table, columns in table_columns.items():
        for column, column_data in columns.items():
            column_data["original_table"] = table
            column_data["original_column"] = column
            updates.append(column_data)
    res = OntologySchemaRewrite.upsert_many(updates)
    res


def load_schema_constraint_sql(database):
    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite

    llm_model = "original"

    for filename in [
        # "OMOP_Synthea_Data.csv",
        f"{database}-constraints.sql",
    ]:
        # Define the relative path to the CSV file
        database = filename.lower().split("-")[0]
        OntologySchemaRewrite.objects(database=database, llm_model=llm_model).update(
            unset__is_foreign_key=True, unset__is_primary_key=True, unset__linked_table=True, unset__linked_column=True
        )
        file_path = os.path.join(script_dir, "..", "..", "dataset/original_schema_files", filename)
        # Open the CSV file and read its contents
        rows = []
        with open(file_path, mode="r", newline="", encoding="utf-8-sig") as file:
            for row in file:
                row = row.strip()
                if row.startswith("--"):
                    continue
                if row:
                    rows.append(row)

        statements = " ".join(rows).split(";")
        for row in statements:
            row = row.replace("\n", " ").strip() + ";"
            if not (row.find("FOREIGN KEY") > -1 and row.find("ADD CONSTRAINT") > -1):
                continue
            import re

            # Example SQL statement

            # Regular expression pattern
            pattern = r"ALTER TABLE \@cdmDatabaseSchema\.(\w+)  ADD CONSTRAINT \w+ FOREIGN KEY \((\w+)\) REFERENCES \@cdmDatabaseSchema\.(\w+) \((\w+)\);"

            # Search for the pattern in the SQL statement
            match = re.search(pattern, row)
            if not match:
                pattern = r"ALTER TABLE (\w+)\s+ADD CONSTRAINT \w+\s+FOREIGN KEY \((\w+)\)\s+REFERENCES (\w+)\((\w+)\);"
                match = re.search(pattern, row)
            assert match
            # Extract the matched groups
            fk_table = match.group(1).lower()
            fk_column = match.group(2).lower()
            pk_table = match.group(3).lower()
            pk_column = match.group(4).lower()
            try:
                res1 = OntologySchemaRewrite.objects(
                    table=fk_table, column=fk_column, database=database, llm_model=llm_model
                ).update(
                    set__is_foreign_key=True,
                    set__linked_table=pk_table,
                    set__linked_column=pk_column,
                    unset__is_primary_key=True,
                )
                res2 = OntologySchemaRewrite.objects(
                    table=pk_table, column=pk_column, database=database, llm_model=llm_model
                ).update(set__is_primary_key=True, unset__is_foreign_key=True)
                if not (res1 and res2):
                    print("not linked", fk_table, fk_column, pk_table, pk_column)
            except Exception as e:
                e


def write_database_schema():
    for database in OntologySchemaRewrite.objects(llm_model="original").distinct("database"):
        result = OntologySchemaRewrite.get_database_description(database=database, llm_model="original")

        # Specify the file path where you want to save the JSON
        file_path = os.path.join(script_dir, "..", "..", "dataset/schemas", f"{database}-schema.json")
        import json

        # Write JSON data to file
        with open(file_path, "w") as json_file:
            json.dump(result, json_file, indent=4)


def generate_create_table_statement(table_name, columns):
    """
    Generates a CREATE TABLE statement for the given table name and columns.

    :param table_name: The name of the table.
    :param columns: A list of dictionaries where each dictionary represents a column with
                    'name', 'type', and optional 'constraints' keys.
    :return: The CREATE TABLE statement as a string.
    """
    columns_definitions = []

    for column in columns:
        column_definition = f"{column['name']} {column['type']}"
        if "constraints" in column:
            column_definition += f" {column['constraints']}"
        columns_definitions.append(column_definition)

    columns_definitions_str = ",\n    ".join(columns_definitions)
    create_table_statement = f"CREATE TABLE {table_name} (\n    {columns_definitions_str} \n);"

    return create_table_statement


def export_sql_statements(database):
    for llm_model in OntologySchemaRewrite.objects(database=database).distinct("llm_model"):
        statements = []
        for table in OntologySchemaRewrite.objects(database=database, llm_model=llm_model).distinct("table"):
            columns = OntologySchemaRewrite.objects(database=database, llm_model=llm_model, table=table)
            columns = [{"name": column.column, "type": "VARCHAR(50)"} for column in columns]
            create_table_statement = generate_create_table_statement(table, columns)
            statements.append(create_table_statement)

        file_path = os.path.join(script_dir, "..", "..", "dataset/schema_export", f"{database}-{llm_model}.sql")
        with open(file_path, "w") as f:
            f.write("\n\n".join(statements))
