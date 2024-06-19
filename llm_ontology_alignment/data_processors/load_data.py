import json
from collections import defaultdict


def load_and_save_table():
    import os
    import csv
    from llm_ontology_alignment.data_models.experiment_models import (
        OntologyAlignmentOriginalSchema,
    )

    # Get the directory of the current script
    script_dir = os.path.dirname(os.path.abspath(__file__))
    database_data = defaultdict(lambda: defaultdict(dict))
    table_descriptions = defaultdict(dict)
    for filename in [
        "IMDB_Saki_Data.csv",
        "OMOP_Synthea_Data.csv",
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

    for filename in [
        "MIMIC_Schema.csv",
        "OMOP_Schema.csv",
    ]:
        file_path = os.path.join(script_dir, "..", "..", "dataset", filename)
        # Open the CSV file and read its contents
        with open(file_path, mode="r", newline="", encoding="utf-8-sig") as file:
            csv_reader = csv.DictReader(file)
            for row in csv_reader:
                database = filename.lower().split("_")[0]
                # TableName,TableDesc,ColumnName,ColumnDesc,ColumnType,IsPK,IsFK,FK
                table, table_description, column, column_description = (
                    row.pop("TableName"),
                    row.pop("TableDesc"),
                    row.pop("ColumnName"),
                    row.pop("ColumnDesc"),
                )
                table = table.lower().strip()
                column = column.lower().strip()
                table_description = table_description.strip()
                column_data = database_data[database].get(table, {}).get(column, {})
                if column_data:
                    row.update(column_data)
                row["name"] = column
                row["description"] = row.get("description", "") + column_description
                database_data[database.lower()][table.lower()][column.lower()] = row
                if len(table_description) > len(table_descriptions[database.lower()].get(table.lower(), "")):
                    table_descriptions[database.lower()][table.lower()] = table_description
    records = []
    for database, tables in database_data.items():
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

    OntologyAlignmentOriginalSchema.objects.delete()
    res = OntologyAlignmentOriginalSchema.upsert_many(records)
    print(res)


def load_and_save_schema(run_specs):
    import json
    import os
    from llm_ontology_alignment.data_models.experiment_models import (
        OntologyAlignmentData,
    )

    # Get the directory of the current script
    script_dir = os.path.dirname(os.path.abspath(__file__))
    records = []
    for filespec in [
        {
            "filename": run_specs["dataset"] + "_source_schema.json",
            "matching_role": "source",
        },
        {
            "filename": run_specs["dataset"] + "_target_schema.json",
            "matching_role": "target",
        },
    ]:
        # Define the relative path to the CSV file

        file_path = os.path.join(script_dir, "..", "..", "dataset", filespec["filename"])
        matching_role = filespec["matching_role"]
        # Open the CSV file and read its contents
        with open(file_path, mode="r", newline="") as file:
            data = json.load(file)

        for table_name, columns in data.items():
            for column_name, column in columns.items():
                if column_name in ["NaN", "nan"]:
                    continue
                column.pop("id", None)
                embedding = column.pop("embedding", None)
                column["matching_role"] = matching_role
                column["matching_index"] = len(records)
                if column["column_description"] in ["NaN", "nan"]:
                    column["column_description"] = ""
                records.append(
                    {
                        "dataset": run_specs["dataset"],
                        "table_name": column["table"],
                        "column_name": column["column"],
                        "default_embedding": embedding,
                        "extra_data": column,
                        "version": 0,
                    }
                )
    res = OntologyAlignmentData.upsert_many(records)
    print(res)


def print_schema(run_specs):
    from llm_ontology_alignment.data_models.experiment_models import SchemaRewrite

    source_schema = defaultdict(list)
    target_schema = defaultdict(list)
    for record in SchemaRewrite.objects(
        dataset=run_specs["dataset"],
        llm_model="gpt-4o",
    ):
        if record.matching_role == "source":
            source_schema[record.rewritten_table].append(record.rewritten_column)
        else:
            target_schema[record.rewritten_table].append(record.rewritten_column)
        # column_description = record.extra_data

    print("Source Schema", json.dumps(source_schema, indent=2))
    print("Target Schema", json.dumps(target_schema, indent=2))


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
            ):
                item.is_primary_key = True
            elif item.extra_data["description"].lower().find("alphanumeric unique identifier") > -1:
                item.is_foreign_key = True
            item.version = version
            item.save()
        except Exception as exp:
            print(exp)


def link_foreign_key():
    from mongoengine import Q
    from llm_ontology_alignment.services.language_models import complete
    from llm_ontology_alignment.data_models.experiment_models import OntologyAlignmentOriginalSchema

    database = OntologyAlignmentOriginalSchema.objects().distinct("database")
    for database in database:
        table_names = OntologyAlignmentOriginalSchema.objects(database=database).distinct("table")
        # assert each table has one and only one primary key
        table_descriptions = {}
        for table in table_names:
            if table in ["CDM_SOURCE", "cdm_source"]:
                continue
            queryset = OntologyAlignmentOriginalSchema.objects(database=database, table=table)
            if queryset.filter(Q(is_primary_key=True) | Q(is_foreign_key=True)).count() == 0:
                raise ValueError(f"Table {table} in {database} has no primary/foreign keys")

            table_descriptions[table] = queryset.first().extra_data["table_description"]
        for item in OntologyAlignmentOriginalSchema.objects(database=database, is_foreign_key=True, linked_table=None):
            try:
                prompt = "select the table that the foreign key references"
                prompt += f"\nForeign Key: {item.column} in {item.table}."
                prompt += f"\nColumn Description: {item.extra_data['description']}"
                prompt += f"\nTable Description: {item.extra_data['table_description']}"
                prompt += f"\nTable options: {table_names}"
                prompt += f"\nTable Descriptions: {table_descriptions}"
                prompt += "\n If no matching found, leave the field empty."
                prompt += (
                    "\n only output a json object of the format and no other text {'table_name': 'selected_table_name'}"
                )
                response = complete(
                    prompt,
                    "gpt-3.5-turbo",
                    {
                        "database": database,
                        "column": item.column,
                        "table": item.table,
                        "task": "link_foreign_key",
                    },
                )
                selected_table = response.json()["extra"]["extracted_json"]["table_name"]
                primary_key = OntologyAlignmentOriginalSchema.objects(
                    database=database, table=selected_table, is_primary_key=True
                ).first()
                if not primary_key:
                    primary_key
                else:
                    item.linked_table = primary_key.table
                    item.linked_column = primary_key.column
                    item.save()
            except Exception as exp:
                print(exp)


def label_primary_key():
    from llm_ontology_alignment.data_models.experiment_models import OntologyAlignmentData
    from llm_ontology_alignment.services.language_models import complete

    datasets = OntologyAlignmentData.objects().distinct("dataset")
    for dataset in datasets:
        for matching_role in ["source", "target"]:
            primary_keys = dict()
            for item in OntologyAlignmentData.objects(
                is_primary_key=True, dataset=dataset, matching_role=matching_role
            ):
                primary_keys[item.table_name] = item.column_name
            for table in OntologyAlignmentData.objects(
                linked_table__nin=primary_keys.keys(), dataset=dataset, matching_role=matching_role
            ).distinct("linked_table"):
                column_descriptions = {}
                table_description = None
                if OntologyAlignmentData.objects(dataset=dataset, table_name=table).count() == 0:
                    if table not in ["store", "CONCEPT"]:
                        raise ValueError(f"Table {table} in {dataset} has no columns")
                for item in OntologyAlignmentData.objects(dataset=dataset, table_name=table):
                    column_descriptions[item.column_name] = item.extra_data["column_description"]
                    if table_description is None:
                        table_description = item.extra_data["table_description"]

                try:
                    prompt = "select the primary key for the table"
                    prompt += f"\nTable: {table}."
                    prompt += f"\nTable Description: {table_description}"
                    prompt += f"\nColumn options: {column_descriptions}"
                    prompt += "\n only output a json object of the format and no other text {'primary_key_column_name': 'selected_column_name'}"
                    response = complete(
                        prompt,
                        "gpt-3.5-turbo",
                        {
                            "dataset": dataset,
                            "table_name": table,
                            "task": "label_primary_key",
                        },
                    )
                    selected_column = response.json()["extra"]["extracted_json"]["primary_key_column_name"]
                    OntologyAlignmentData.objects(
                        dataset=dataset, table_name=table, column_name=selected_column, matching_role=matching_role
                    ).update(is_primary_key=True)
                except Exception as exp:
                    print(exp)


def migrate_schema_rewrite():
    from llm_ontology_alignment.data_models.experiment_models import SchemaRewrite, OntologySchemaRewrite

    OntologySchemaRewrite.objects.delete()
    updates = dict()
    for record in SchemaRewrite.objects():
        db1, db2 = record.dataset.lower().split("_")
        db = db1 if record.matching_role == "source" else db2
        table, column = record.original_table.strip().lower(), record.original_column.strip().lower()
        key = f"{db}_{table}_{column}_{record.llm_model}"
        updates[key] = {
            "database": db,
            "original_table": table,
            "original_column": column,
            "rewritten_table": record.rewritten_table.lower().strip(),
            "rewritten_column": record.rewritten_column.lower().strip(),
            "rewritten_column_description": record.rewritten_column_description,
            "rewritten_table_description": record.rewritten_table_description,
            "llm_model": record.llm_model,
            "version": 0,
        }
    res = OntologySchemaRewrite.upsert_many(updates.values())
    res
