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
    ground_truth_data = defaultdict(list)
    for filename in [
        # "OMOP_Synthea_Data.csv",
        "OMOP_CMS_data.csv",
        "OMOP_MIMIC_Data.csv",
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

        print(table, json.dumps(table_description, indent=2))


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
            "table": record.table.lower().strip(),
            "column": record.column.lower().strip(),
            "column_description": record.column_description,
            "table_description": record.table_description,
            "llm_model": record.llm_model,
            "version": 0,
        }
    res = OntologySchemaRewrite.upsert_many(updates.values())
    res


def migrate_schema_rewrite_embedding():
    from llm_ontology_alignment.data_models.experiment_models import SchemaEmbedding, OntologySchemaEmbedding

    OntologySchemaEmbedding.objects.delete()
    updates = dict()
    for record in SchemaEmbedding.objects():
        db1, db2 = record.dataset.lower().split("_")
        db = db1 if record.matching_role == "source" else db2
        table, column = record.table.strip().lower(), record.column.strip().lower()
        key = f"{db}_{table}_{column}_{record.llm_model}_{record.embedding_strategy}"

        updates[key] = {
            "database": db,
            "table": table,
            "column": column,
            "llm_model": record.llm_model,
            "embedding_strategy": record.embedding_strategy,
            "embedding_text": record.embedding_text,
            "embedding": record.embedding,
            "version": 0,
        }
        if record.similar_items:
            similar_item = record.similar_items[0]
            db1, db2 = similar_item["dataset"].lower().split("_")
            db = db1 if similar_item["matching_role"] == "source" else db2
            updates[key]["similar_items"] = {db: {"database": db, "similar_items": record.similar_items}}

        if len(updates) > 1000:
            res = OntologySchemaEmbedding.upsert_many(updates.values())
            print(res)
            updates = dict()
    res = OntologySchemaEmbedding.upsert_many(updates.values())
    res
