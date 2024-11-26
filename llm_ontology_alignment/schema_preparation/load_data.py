import json
from collections import defaultdict
import os

from llm_ontology_alignment.constants import EXPERIMENTS
from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite

script_dir = os.path.dirname(os.path.abspath(__file__))


def import_coma_matching_result():
    from llm_ontology_alignment.data_models.experiment_models import OntologyAlignmentExperimentResult

    # source_dbs = ["cprd_aurum", "cprd_gold", "mimic_iii"]
    # target_dbs = ["omop"]
    rewrite_llms = ["original"]
    for experiment in EXPERIMENTS:
        for rewrite_llm in rewrite_llms:
            filename = f"{experiment}-{rewrite_llm.replace('-', '_')}.txt"
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
                source_db, target_db = experiment.split("-")
                run_specs = {
                    "source_database": source_db,
                    "target_database": target_db,
                    "rewrite_llm": rewrite_llm,
                    "column_matching_strategy": "coma",
                    "column_matching_llm": "None",
                    "table_selection_strategy": "None",
                    "table_selection_llm": "None",
                }
                run_specs = {key: run_specs[key] for key in sorted(run_specs.keys())}
                OntologyAlignmentExperimentResult.upsert(
                    {
                        "dataset": experiment,
                        "json_result": data,
                        "operation_specs": run_specs,
                    }
                )


def import_ground_truth(source_db, target_db):
    import os

    # Get the directory of the current script
    for filename in [
        f"{source_db.upper()}-{target_db.upper()}-ground_truth.csv",
    ]:
        # Define the relative path to the CSV file
        tokens = filename.lower().split("-")
        database1 = tokens[0]
        database2 = tokens[1]
        file_path = os.path.join(script_dir, "..", "..", "dataset/ground_truth_files", filename)
        # Open the CSV file and read its contents
        ground_truth_data = defaultdict(set)
        source_queryset = OntologySchemaRewrite.objects(database=database1, llm_model="original")
        target_queryset = OntologySchemaRewrite.objects(database=database2, llm_model="original")
        with open(file_path, mode="r", newline="", encoding="utf-8-sig") as file:
            for row in file:
                if not row.strip():
                    continue
                if row[0] == "#":
                    continue
                tokens = row.lower().strip().split(",")
                assert len(tokens) >= 4, row
                tokens = [item.strip() for item in tokens]
                source_table, source_column, target_table, target_column = tokens[0], tokens[1], tokens[2], tokens[3]
                if target_table == "stem":
                    source_table, source_column, target_table, target_column = (
                        tokens[0],
                        tokens[1],
                        tokens[-2],
                        tokens[-1],
                    )

                source_record = source_queryset.filter(table=source_table, column=source_column).first()
                assert source_record, database1 + ": " + row
                if source_record.linked_table:
                    source_record = source_queryset.filter(
                        table=source_record.linked_table, column=source_record.linked_column
                    ).first()
                assert source_record, database1 + ": " + row
                assert not source_record.linked_table, database1 + ": " + row

                target_record = target_queryset.filter(
                    table=target_table,
                    column=target_column,
                ).first()
                if not target_record:
                    row
                assert target_record, database1 + ": " + row + f"{tokens}"
                if target_record.linked_table:
                    target_record = target_queryset.filter(
                        table=target_record.linked_table, column=target_record.linked_column
                    ).first()
                assert target_record, database1 + ": " + row
                assert not target_record.linked_table, target_table

                ground_truth_data[f"{source_record.table}.{source_record.column}"].add(
                    f"{target_record.table}.{target_record.column}"
                )
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
                line = line.strip()
                if (
                    line.startswith("--")
                    or line.startswith("DROP TABLE")
                    or line.startswith("PRIMARY KEY")
                    or line.startswith("KEY")
                    or line.startswith("CONSTRAINT")
                    or line.startswith(")")
                    or line.startswith("SET")
                    or line.startswith("DELIMITER")
                    or line.startswith("FULLTEXT")
                    or line.startswith("UNIQUE KEY")
                    or line.startswith("FOREIGN KEY")
                ):
                    continue
                    # Initialize the list for storing table and column information

                    # Read the statement line by line
                # Check for table name
                if line.startswith("CREATE TABLE"):
                    parts = line.split()
                    table_name = parts[2].replace("@cdmDatabaseSchema.", "").strip("()").lower()

                # Check for column definitions
                elif line and line.replace(" ", "").strip() not in ["(", ");"] and (not line.startswith("CONSTRAINT")):
                    tokens = line.lower().split()
                    column_name, column_type = tokens[0].strip(","), tokens[1].strip(",")
                    if column_type not in valid_types and column_type.find("varchar") == -1:
                        column_type
                        # assert column_type in valid_types
                    table_columns[table_name][column_name] = {
                        "table": table_name,
                        "column": column_name,
                        "original_table": table_name,
                        "original_column": column_name,
                        "column_type": column_type,
                        "database": database,
                        "llm_model": llm_model,
                    }
                    res = OntologySchemaRewrite.objects(
                        original_table=table_name, database=database, original_column=column_name
                    ).update(set__column_type=column_type)
                    if not res:
                        res
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
                    assert matches, line
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


def update_rewrite_schema_constraints(database):
    for item in OntologySchemaRewrite.objects(database=database, llm_model="original", linked_table__ne=None):
        pk_table = item.linked_table
        pk_column = item.linked_column
        fk_table = item.table
        fk_column = item.column
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


def load_schema_constraint_sql(database):
    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite

    for filename in [
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
            if not match:
                pattern = (
                    r"ALTER TABLE (\w+)\s+ADD CONSTRAINT \w+\s+FOREIGN KEY \((\w+)\)\s+REFERENCES (\w+) \((\w+)\);"
                )
                match = re.search(pattern, row)

            assert match, row
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
                    raise ValueError("sql constrain not linked", fk_table, fk_column, pk_table, pk_column)
            except Exception as e:
                raise e
        update_rewrite_schema_constraints(database)


def write_database_schema():
    for database in OntologySchemaRewrite.objects(llm_model="original").distinct("database"):
        result = OntologySchemaRewrite.get_database_description(database=database, llm_model="original")

        # Specify the file path where you want to save the JSON
        file_path = os.path.join(script_dir, "..", "..", "dataset/schemas", f"{database}-schema.json")
        import json

        # Write JSON data to file
        with open(file_path, "w") as json_file:
            json.dump(result, json_file, indent=4)


def export_ground_truth(source_db, target_db):
    from llm_ontology_alignment.data_models.experiment_models import OntologyAlignmentGroundTruth

    for dataset in [f"{source_db}-{target_db}"]:
        mappings = OntologyAlignmentGroundTruth.objects(dataset=dataset).first().data
        source_db, target_db = dataset.split("-")
        for llm_model in ["original"]:
            mapping_exports = []
            target_queryset = OntologySchemaRewrite.objects(database=target_db, llm_model=llm_model)
            if target_queryset.count() == 0:
                continue
            for table in OntologySchemaRewrite.objects(database=source_db, llm_model=llm_model).distinct("table"):
                for source_column in OntologySchemaRewrite.objects(
                    database=source_db, llm_model=llm_model, table=table
                ):
                    if f"{source_column.original_table}.{source_column.original_column}" in mappings:
                        for target in mappings[f"{source_column.original_table}.{source_column.original_column}"]:
                            target_column = target_queryset.filter(
                                original_table=target.split(".")[0].strip(),
                                original_column=target.split(".")[1].strip(),
                            ).first()
                            assert target_column, f"{target=},{source_column=},{llm_model=}"
                            mapping_exports.append(
                                f"{source_column.table}.{source_column.column} -> {target_column.table}.{target_column.column} -> {target_column.linked_table}.{target_column.linked_column}"
                            )

                    else:
                        mapping_exports.append(f"{source_column.table}.{source_column.column} -> NA,NA ")
            file_path = os.path.join(script_dir, "..", "..", "dataset/ground_truth_files", f"{dataset}-{llm_model}.csv")
            with open(file_path, "w") as f:
                f.write("\n".join(mapping_exports))


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
    for llm_model in ["original", "gpt-4o", "gpt-3.5-turbo"]:
        statements = []
        for table in OntologySchemaRewrite.objects(database=database, llm_model=llm_model).distinct("table"):
            columns = OntologySchemaRewrite.objects(database=database, llm_model=llm_model, table=table)
            table_description = columns[0].table_description
            try:
                columns = [
                    {
                        "name": column.column,
                        "type": column.column_type.upper() if column.column_type else "VARCHAR(255)",
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
