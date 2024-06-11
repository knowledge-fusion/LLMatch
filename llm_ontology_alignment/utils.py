import os
import uuid


def load_dataset(filename):
    import pandas as pd

    data = pd.read_csv(filename)
    return data


def format_dataset(data):
    from collections import defaultdict

    # data = data.rename(columns={"TableName": "table", "TableDesc": "table_description", "ColumnName": "column", "ColumnDesc": "column_description"})
    schema = defaultdict(dict)

    for index, row in data.iterrows():
        table = row["table"]
        column = row["column"]
        row["id"] = uuid.uuid4().hex
        schema[table][column] = row

    return schema


def separate_dataset(data, source, target):
    from collections import defaultdict

    source_schema = defaultdict(dict)
    target_schema = defaultdict(dict)
    ground_truth = []
    for index, row in data.iterrows():
        source_table, source_column = row[source].split("-")
        target_table, target_column = row[target].split("-")
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
        if row["label"] == 1:
            ground_truth.append(
                {
                    "source_table": source_table,
                    "source_column": source_column,
                    "target_table": target_table,
                    "target_column": target_column,
                }
            )

    return source_schema, target_schema, ground_truth


def save_embeddings(dataset, source_schema, target_schema):
    import json
    import os

    current_file_path = os.path.dirname(__file__)

    schema = source_schema
    for table in schema:
        for column in schema[table]:
            if "embedding" not in schema[table][column]:
                schema[table][column]["embedding"] = get_embeddings(
                    f'table={table}, column={column}, table description={source_schema[table][column]["table_description"]}, column description={source_schema[table][column]["column_description"]}'
                )
            schema[table][column] = dict(schema[table][column])

    schema = target_schema
    for table in schema:
        for column in schema[table]:
            if "embedding" not in schema[table][column]:
                schema[table][column]["embedding"] = get_embeddings(
                    f'table={table}, column={column}, table description={target_schema[table][column]["table_description"]}, column description={target_schema[table][column]["column_description"]}'
                )
            schema[table][column] = dict(schema[table][column])
    file_path = current_file_path + f"/../dataset/{dataset}_source_schema.json"
    with open(file_path, "w") as file:
        file.write(json.dumps(source_schema, indent=2))

    file_path = current_file_path + f"/../dataset/{dataset}_target_schema.json"
    with open(file_path, "w") as file:
        file.write(json.dumps(target_schema, indent=2))


def get_cache():
    from cachelib import MongoDbCache

    cache = MongoDbCache(client=os.getenv("MONGODB_HOST"))
    return cache


def split_list_into_chunks(lst, chunk_size):
    """
    Splits the given list into chunks of specified size.

    Args:
        lst (list): The list to be split.
        chunk_size (int): The size of each chunk.

    Returns:
        list: A list of lists, where each sublist is a chunk of the original list.
    """
    return [lst[i : i + chunk_size] for i in range(0, len(lst), chunk_size)]


def cosine_distance(a, b):
    from numpy import dot
    from numpy.linalg import norm

    if isinstance(a, str) and isinstance(b, str):
        a = get_embeddings(a)
        b = get_embeddings(b)

    cos_sim = dot(a, b) / (norm(a) * norm(b))
    res = "%.3f" % cos_sim
    return float(res)


def load_embeddings(dataset):
    import json
    import os

    current_file_path = os.path.dirname(__file__)

    file_path = current_file_path + f"/../dataset/{dataset}_source_schema.json"
    with open(file_path, "r") as file:
        source_schema = json.loads(file.read())

    file_path = current_file_path + f"/../dataset/{dataset}_target_schema.json"
    with open(file_path, "r") as file:
        target_schema = json.loads(file.read())

    for table in source_schema:
        for column in source_schema[table]:
            source_schema[table][column].update(
                {
                    "alignment_role": "source",
                    "dataset": dataset,
                }
            )

    for table in target_schema:
        for column in target_schema[table]:
            target_schema[table][column].update(
                {
                    "alignment_role": "target",
                    "dataset": dataset,
                }
            )
    return source_schema, target_schema


def store_embeddings(source_schema, target_schema):
    from llm_ontology_alignment.services.vector_db import upload_vector_records

    records = []
    for table in source_schema:
        for column in source_schema[table]:
            records.append(source_schema[table][column])

    for table in target_schema:
        for column in target_schema[table]:
            records.append(target_schema[table][column])

    upload_vector_records(records)


def get_embeddings(text):
    import requests

    embedding = None
    url = os.getenv("EMBEDDING_SERVICE") + "/get_embeddings"
    res = requests.post(url=url, json=[text], timeout=150)
    if res.status_code == 200:
        embedding = res.json()
    return embedding
