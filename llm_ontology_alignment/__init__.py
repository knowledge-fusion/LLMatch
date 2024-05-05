# load MIMIC 2 data from the dataset
# Path: llm_ontology_alignment/__init__.py
import logging
import uuid
from dotenv import load_dotenv
import sentry_sdk
from slack_logger import SlackFormatter, SlackHandler, FormatConfig
from sentry_sdk.integrations.logging import LoggingIntegration
import os

logger = logging.getLogger(__name__)


load_dotenv()

sentry_logging = LoggingIntegration(
    level=logging.INFO,  # Capture info and above as breadcrumbs
    event_level=logging.ERROR,  # Send errors as events
)
formatter = SlackFormatter.default(
    config=FormatConfig(service="news_crawler", environment="dev")
)  # plain message, no decorations
handler = SlackHandler.from_webhook(os.environ["SLACK_NOTIFICATION_URL"])
handler.setFormatter(formatter)
handler.setLevel(logging.WARN)
logger.addHandler(handler)

sentry_sdk.init(
    dsn=os.getenv("SENTRY_DSN"),
    integrations=[
        sentry_logging,
    ],
)


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

    return source_schema, target_schema


def save_embeddings(dataset, source_schema, target_schema):
    import json
    import os

    current_file_path = os.path.dirname(__file__)
    from llm_ontology_alignment.services.vector_db import get_embeddings

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


def main():
    from llm_ontology_alignment.alignment_models.rematch import run_experiment

    run_experiment("MIMIC_OMOP")


if __name__ == "__main__":
    main()
