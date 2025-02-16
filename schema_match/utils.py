import os
import uuid
import re


def calculate_metrics(ground_truth, prediction):
    TP = FP = FN = 0  # True Positives, False Positives, False Negatives

    all_keys = set(ground_truth.keys()) | set(prediction.keys())

    details = {}
    for key in all_keys:
        gt_set = set(ground_truth.get(key, []))
        pred_set = set(prediction.get(key, []))

        TP += len(gt_set & pred_set)  # Items correctly predicted
        FP += len(pred_set - gt_set)  # Items incorrectly predicted
        FN += len(gt_set - pred_set)  # Items missed in prediction
        details[key] = {
            "TP": list(gt_set & pred_set),
            "FP": list(pred_set - gt_set),
            "FN": list(gt_set - pred_set),
            "Expected": list(gt_set),
            "Predicted": list(pred_set),
        }

    precision = TP / (TP + FP) if (TP + FP) > 0 else 0
    recall = TP / (TP + FN) if (TP + FN) > 0 else 0
    f1_score = (
        2 * precision * recall / (precision + recall) if (precision + recall) > 0 else 0
    )

    return {
        "precision": precision,
        "recall": recall,
        "f1_score": f1_score,
        "details": details,
    }


def camel_to_snake(name):
    # Insert an underscore before each capital letter, except the first one
    s1 = re.sub("(.)([A-Z][a-z]+)", r"\1_\2", name)
    # Insert an underscore before a capital letter followed by another capital letter (for acronyms)
    return re.sub("([a-z0-9])([A-Z])", r"\1_\2", s1).lower()


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
                    f"table={table}, column={column}, table description={source_schema[table][column]['table_description']}, column description={source_schema[table][column]['column_description']}"
                )
            schema[table][column] = dict(schema[table][column])

    schema = target_schema
    for table in schema:
        for column in schema[table]:
            if "embedding" not in schema[table][column]:
                schema[table][column]["embedding"] = get_embeddings(
                    f"table={table}, column={column}, table description={target_schema[table][column]['table_description']}, column description={target_schema[table][column]['column_description']}"
                )
            schema[table][column] = dict(schema[table][column])
    file_path = current_file_path + f"/../dataset/{dataset}_source_schema.json"
    with open(file_path, "w") as file:
        file.write(json.dumps(source_schema, indent=2))

    file_path = current_file_path + f"/../dataset/{dataset}_target_schema.json"
    with open(file_path, "w") as file:
        file.write(json.dumps(target_schema, indent=2))


def get_cache():
    from dotenv import load_dotenv

    load_dotenv()
    from cachelib import MongoDbCache

    url = os.getenv("MONGODB_HOST")
    cache = MongoDbCache(
        client=url,
        db="finance",
        collection="cache",
        prefix="schema_match",
        default_timeout=3600 * 24 * 7,
    )
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


def get_embeddings(text):
    import requests

    embedding = None
    url = os.getenv("EMBEDDING_SERVICE") + "/get_embeddings"
    res = requests.post(url=url, json=[text], timeout=150)
    if res.status_code == 200:
        embedding = res.json()
    return embedding
