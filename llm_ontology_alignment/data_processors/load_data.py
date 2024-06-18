import json
from collections import defaultdict


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
    from llm_ontology_alignment.data_models.experiment_models import OntologyAlignmentData

    # OntologyAlignmentData.objects.update(unset__is_foreign_key=True, unset__is_primary_key=True)
    for item in OntologyAlignmentData.objects(dataset="MIMIC_OMOP"):
        try:
            item.extra_data["table_description"] = item.extra_data["table_description"].replace("\u00a0", " ").strip()
            item.extra_data["column_description"] = item.extra_data["column_description"].replace("\u00a0", " ").strip()
            if (
                item.extra_data.get("IsFk", "") in ["YES"]
                or item.extra_data.get("IsFK", "") in ["YES"]
                or item.extra_data["column_description"].lower().find("foreign key") > -1
            ):
                item.is_foreign_key = True
                if isinstance(item.extra_data.get("FK table"), str):
                    item.linked_table = item.extra_data["FK table"].strip()
                elif isinstance(item.extra_data.get("FK"), str):
                    linked_table, linked_column = item.extra_data["FK"][1:-1].split(",")
                    item.linked_table = linked_table.strip()

            elif (
                item.extra_data.get("IsPk", "") in ["YES"]
                or item.extra_data.get("IsPK", "") in ["YES"]
                or item.extra_data["column_description"].lower().find("primary key") > -1
            ):
                item.is_primary_key = True
            elif item.extra_data["column_description"].lower().find("alphanumeric unique identifier") > -1:
                item.is_foreign_key = True
            item.save()
        except Exception as exp:
            print(exp)


def link_foreign_key():
    from mongoengine import Q
    from llm_ontology_alignment.services.language_models import complete
    from llm_ontology_alignment.data_models.experiment_models import OntologyAlignmentData

    datasets = OntologyAlignmentData.objects().distinct("dataset")
    for dataset in datasets:
        for matching_role in ["source", "target"]:
            table_names = OntologyAlignmentData.objects(dataset=dataset, matching_role=matching_role).distinct(
                "table_name"
            )
            # assert each table has one and only one primary key
            table_descriptions = {}
            for table in table_names:
                if table in ["CDM_SOURCE", "cdm_source"]:
                    continue
                queryset = OntologyAlignmentData.objects(dataset=dataset, table_name=table, matching_role=matching_role)
                if queryset.filter(Q(is_primary_key=True) | Q(is_foreign_key=True)).count() == 0:
                    raise ValueError(f"Table {table} in {dataset} has no primary/foreign keys")
                if queryset.filter(is_primary_key=True).count() > 0:
                    table_descriptions[table] = queryset.first().extra_data["table_description"]
            for item in OntologyAlignmentData.objects(
                dataset=dataset, matching_role=matching_role, is_foreign_key=True, linked_table=None
            ):
                try:
                    prompt = "select the table that the foreign key references"
                    prompt += f"\nForeign Key: {item.column_name} in {item.table_name}."
                    prompt += f"\nColumn Description: {item.extra_data['column_description']}"
                    prompt += f"\nTable Description: {item.extra_data['table_description']}"
                    prompt += f"\nTable options: {table_names}"
                    prompt += f"\nTable Descriptions: {table_descriptions}"
                    prompt += "\n If no matching found, leave the field empty."
                    prompt += "\n only output a json object of the format and no other text {'table_name': 'selected_table_name'}"
                    response = complete(
                        prompt,
                        "gpt-3.5-turbo",
                        {
                            "dataset": dataset,
                            "matching_role": matching_role,
                            "llm_column_name": item.column_name,
                            "table_name": item.table_name,
                            "task": "link_foreign_key",
                        },
                    )
                    selected_table = response.json()["extra"]["extracted_json"]["table_name"]
                    item.linked_table = selected_table
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
