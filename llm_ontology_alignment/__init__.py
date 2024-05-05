# load MIMIC 2 data from the dataset
# Path: llm_ontology_alignment/__init__.py
import uuid


def load_dataset(filename):
    import pandas as pd

    data = pd.read_csv(filename)
    return data


def separate_dataset(data):
    from collections import defaultdict

    source_schema = defaultdict(dict)
    target_schema = defaultdict(dict)
    for index, row in data.iterrows():
        source_table, source_column = row["omop"].split("-")
        target_table, target_column = row["table"].split("-")
        source_table_description, source_column_description = row["d1"], row["d2"]
        target_table_description, target_column_description = row["d3"], row["d4"]
        source_schema[source_table][source_column] = {
            "column_description": source_column_description,
            "id": uuid.uuid4().hex,
            "table": source_table,
            "column": source_column,
            "table_description": source_table_description,
        }
        target_schema[target_table][target_column] = {
            "column_description": target_column_description,
            "id": uuid.uuid4().hex,
            "table": target_table,
            "column": target_column,
            "table_description": target_table_description,
        }

    return source_schema, target_schema


def save_embeddings(dataset, source_schema, target_schema):
    import json
    import os

    current_file_path = os.path.dirname(__file__)
    from llm_ontology_alignment.services.vector_db import get_embeddings

    schema = source_schema
    for table in schema:
        for column in schema[table]:
            schema[table][column]["embedding"] = get_embeddings(
                f'table={table}, column={column}, table description={source_schema[table][column]["table_description"]}, column description={source_schema[table][column]["column_description"]}'
            )

    schema = target_schema
    for table in schema:
        for column in schema[table]:
            schema[table][column]["embedding"] = get_embeddings(
                f'table={table}, column={column}, table description={target_schema[table][column]["table_description"]}, column description={target_schema[table][column]["column_description"]}'
            )

    file_path = current_file_path + f"/../dataset/{dataset}_source_schema.json"
    with open(file_path, "w") as file:
        file.write(json.dumps(source_schema, indent=2))

    file_path = current_file_path + f"/../dataset/{dataset}_target_schema.json"
    with open(file_path, "w") as file:
        file.write(json.dumps(target_schema, indent=2))


def main():
    import os

    current_dir = os.path.dirname(__file__)
    data = load_dataset(current_dir + "/../dataset/OMOP_Synthea_Data.csv")
    data


if __name__ == "__main__":
    main()
