import json
from collections import defaultdict
import os
from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite

script_dir = os.path.dirname(os.path.abspath(__file__))


def import_coma_matching_result():
    from llm_ontology_alignment.data_models.experiment_models import OntologyAlignmentExperimentResult

    source_dbs = ["cprd_aurum", "cprd_gold", "mimic_iii"]
    target_dbs = ["omop"]
    rewrite_llms = ["gpt-3.5-turbo", "original"]
    for source_db in source_dbs:
        for target_db in target_dbs:
            for rewrite_llm in rewrite_llms:
                filename = f"{source_db}-{target_db}-{rewrite_llm.replace('-', '_')}.txt"
                file_path = os.path.join(script_dir, "..", "..", "dataset/match_result/coma", filename)
                with open(file_path, "r") as file:
                    data = defaultdict(list)
                    for item in file:
                        if item.startswith(" - "):
                            tokens = item.strip().split(" ")
                            assert len(tokens) == 5
                            source = tokens[1]
                            target = tokens[3][:-1]
                            if source.find(".") > -1:
                                data[source].append(target)
                            else:
                                source
                    run_specs = {
                        "source_db": source_db,
                        "target_db": target_db,
                        "rewrite_llm": rewrite_llm,
                        "strategy": "coma",
                    }
                    run_specs = {key: run_specs[key] for key in sorted(run_specs.keys())}
                    OntologyAlignmentExperimentResult.objects(run_id_prefix=json.dumps(run_specs)).delete()
                    OntologyAlignmentExperimentResult.upsert(
                        {
                            "run_id_prefix": json.dumps(run_specs),
                            "dataset": f'{run_specs["source_db"]} - {run_specs["target_db"]}',
                            "json_result": data,
                            "sub_run_id": "coma",
                        }
                    )


def import_ground_truth():
    import os

    # Get the directory of the current script
    for filename in [
        "MIMIC_III-OMOP-ground_truth.csv",
        # "CPRD_AURUM-OMOP-ground_truth.csv",
        # "CPRD_GOLD-OMOP-ground_truth.csv",
    ]:
        # Define the relative path to the CSV file
        tokens = filename.lower().split("-")
        database1 = tokens[0]
        database2 = tokens[1]

        source_alias, target_alias = dict(), dict()
        for item in OntologySchemaRewrite.objects(database=database1, llm_model="original", linked_table__ne=None):
            source_alias[f"{item.table}.{item.column}"] = f"{item.linked_table}.{item.linked_column}"
        for item in OntologySchemaRewrite.objects(database=database2, llm_model="original", linked_table__ne=None):
            target_alias[f"{item.table}.{item.column}"] = f"{item.linked_table}.{item.linked_column}"

        file_path = os.path.join(script_dir, "..", "..", "dataset/ground_truth_files", filename)
        # Open the CSV file and read its contents
        ground_truth_data = defaultdict(set)
        with open(file_path, mode="r", newline="", encoding="utf-8-sig") as file:
            for row in file:
                if not row.strip():
                    continue
                tokens = row.strip().split(",")
                assert len(tokens) >= 4, row
                table1, column1 = tokens[0].lower().strip(), tokens[1].lower().strip()
                table2, column2 = tokens[2].lower().strip(), tokens[3].lower().strip()
                if f"{table1}.{column1}" in source_alias and f"{table2}.{column2}" in target_alias:
                    table1, column1 = source_alias[f"{table1}.{column1}"].split(".")
                    table2, column2 = target_alias[f"{table2}.{column2}"].split(".")
                source_record = OntologySchemaRewrite.objects(
                    table=table1, column=column1, llm_model="original", database=database1
                ).first()
                assert source_record, database1 + row
                target_record = OntologySchemaRewrite.objects(
                    table=table2, column=column2, llm_model="original", database=database2
                ).first()
                assert target_record, database1 + row
                ground_truth_data[f"{table1}.{column1}"].add(f"{table2}.{column2}")
        mappings = dict()
        for source, targets in ground_truth_data.items():
            mappings[source] = list(targets)
        from llm_ontology_alignment.data_models.experiment_models import OntologyAlignmentGroundTruth

        res = OntologyAlignmentGroundTruth.upsert_many(
            [
                {
                    "dataset": f"{database1}-{database2}",
                    "data": mappings,
                }
            ]
        )
        assert res


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


def load_sql_schema(database):
    llm_model = "original"
    table_columns = defaultdict(dict)
    column_types = OntologySchemaRewrite.objects.distinct("column_type")
    invalid_types = [item for item in column_types if item.find(" ") > -1 or item.find("_") > -1 or item in [";"]]
    valid_types = [item for item in column_types if item not in invalid_types]
    OntologySchemaRewrite.objects(column_type__in=invalid_types).delete()
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
                elif line and line.replace(" ", "").strip() not in ["(", ");"] and (not line.startswith("CONSTRAINT")):
                    tokens = line.lower().split()
                    column_name, column_type = tokens[0].strip(","), tokens[1].strip(",")
                    if column_type not in valid_types:
                        column_type
                    assert column_type in valid_types
                    table_columns[table_name][column_name] = {
                        "table": table_name,
                        "column": column_name,
                        "original_table": table_name,
                        "original_column": column_name,
                        "column_type": column_type,
                        "database": database,
                        "llm_model": llm_model,
                    }

    for filename in [
        f"{database}-comment.sql",
    ]:
        file_path = os.path.join(script_dir, "..", "..", "dataset/original_schema_files", filename)
        # Open the CSV file and read its contents
        rows = []
        with open(file_path, mode="r", newline="") as file:
            for line in file:
                line = line.strip()
                if line.startswith("--"):
                    continue
                if line:
                    rows.append(line)
        statements = " ".join(rows).split(";")
        for line in statements:
            line = line.replace("\n", " ").strip() + ";"
            line = " ".join([item.strip() for item in line.split() if item])
            line = line.encode(
                "utf-8",
            ).decode("utf-8")
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

                    # Search for the pattern in the SQL statement
                    matches = re.findall(r"COMMENT ON COLUMN (\w+)\.(\w+) IS '([^']*)'", line)
                    if not matches:
                        matches = re.findall(r"COMMENT ON COLUMN (\w+)\.(\w+) is '([^']*)'", line)
                    assert matches
                    # Initialize the list for storing the extracted information

                    for match in matches:
                        table_name, column_name, description = match
                        assert description
                        table_columns[table_name.lower()][column_name.lower()]["column_description"] = description
                except Exception as e:
                    print(f"match not found {line}")
                    raise e

    updates = []
    for table, columns in table_columns.items():
        for column, column_data in columns.items():
            column_data["original_table"] = table
            column_data["original_column"] = column
            try:
                assert column_data["column_description"]
                assert column_data["table_description"]
                updates.append(column_data)
            except Exception as e:
                raise ValueError("no description found", column_data)
    res = OntologySchemaRewrite.upsert_many(updates)
    res


def load_schema_constraint_sql(database):
    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite

    for filename in [
        # "OMOP_Synthea_Data.csv",
        f"{database}-constraints.sql",
    ]:
        # Define the relative path to the CSV file
        database = filename.lower().split("-")[0]
        OntologySchemaRewrite.objects(database=database).update(
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
                    table=fk_table, column=fk_column, database=database, llm_model="original"
                ).update(
                    set__is_foreign_key=True,
                    set__linked_table=pk_table,
                    set__linked_column=pk_column,
                    unset__is_primary_key=True,
                )
                res2 = OntologySchemaRewrite.objects(
                    table=pk_table, column=pk_column, database=database, llm_model="original"
                ).update(set__is_primary_key=True, unset__is_foreign_key=True)
                if not (res1 and res2):
                    print("not linked", fk_table, fk_column, pk_table, pk_column)

                # copy table linking
                for primary_key in OntologySchemaRewrite.objects(
                    original_table=pk_table, original_column=pk_column, database=database, llm_model__ne="original"
                ):
                    primary_key.is_primary_key = True
                    primary_key.save()
                    OntologySchemaRewrite.objects(
                        original_table=fk_table,
                        original_column=fk_column,
                        database=database,
                        llm_model=primary_key.llm_model,
                    ).update(
                        set__linked_table=primary_key.table,
                        set__linked_column=primary_key.column,
                        set__is_foreign_key=True,
                    )

            except Exception as e:
                raise e


def write_database_schema():
    for database in OntologySchemaRewrite.objects(llm_model="original").distinct("database"):
        result = OntologySchemaRewrite.get_database_description(database=database, llm_model="original")

        # Specify the file path where you want to save the JSON
        file_path = os.path.join(script_dir, "..", "..", "dataset/schemas", f"{database}-schema.json")
        import json

        # Write JSON data to file
        with open(file_path, "w") as json_file:
            json.dump(result, json_file, indent=4)


def generate_create_table_statement(table_name, table_description, columns):
    """
    Generates a CREATE TABLE statement for the given table name and columns.

    :param table_name: The name of the table.
    :param columns: A list of dictionaries where each dictionary represents a column with
                    'name', 'type', and optional 'constraints' keys.
    :return: The CREATE TABLE statement as a string.
    """
    columns_definitions = []
    comment_statements = [f"COMMENT ON TABLE {table_name} IS '{table_description}';"]
    for column in columns:
        column_definition = f"{column['name']} {column['type']}"
        if "constraints" in column:
            column_definition += f" {column['constraints']}"
        columns_definitions.append(column_definition)
        comment_statements.append(f"COMMENT ON COLUMN {table_name}.{column['name']} IS '{column['comment']}';")

    columns_definitions_str = ",\n    ".join(columns_definitions)
    create_table_statement = f"CREATE TABLE {table_name} (\n    {columns_definitions_str} \n);"
    create_table_statement += "\n\n" + "\n".join(comment_statements)
    return create_table_statement


def export_sql_statements(database):
    OntologySchemaRewrite.objects(database=database).distinct("llm_model")
    for llm_model in ["original", "gpt-3.5-turbo"]:
        statements = []
        for table in OntologySchemaRewrite.objects(database=database, llm_model=llm_model).distinct("table"):
            columns = OntologySchemaRewrite.objects(database=database, llm_model=llm_model, table=table)
            table_description = columns[0].table_description
            try:
                columns = [
                    {
                        "name": column.column,
                        "type": column.column_type.upper(),
                        "comment": column.column_description.replace("'", "'"),
                    }
                    for column in columns
                ]
            except Exception as e:
                raise e
            create_table_statement = generate_create_table_statement(table, table_description, columns)
            statements.append(create_table_statement)

        file_path = os.path.join(script_dir, "..", "..", "dataset/schema_export", f"{database}-{llm_model}.sql")
        with open(file_path, "w") as f:
            f.write("\n\n".join(statements))
