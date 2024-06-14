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
    from llm_ontology_alignment.data_models.experiment_models import (
        OntologyAlignmentData,
    )

    source_schema = defaultdict(list)
    target_schema = defaultdict(list)
    for record in OntologyAlignmentData.objects(dataset=run_specs["dataset"]):
        matching_role = record.extra_data["matching_role"]
        if matching_role == "source":
            source_schema[record.table_name].append(record.llm_column_name)
        else:
            target_schema[record.table_name].append(record.llm_column_name)
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
