import json
import logging

from llm_ontology_alignment.services.vector_db import query_vector_db

logger = logging.getLogger(__name__)


def rank_top_tables(dataset_name, source_table, source_column, source_schema):
    data = source_schema[source_table][source_column]
    query_vector = data.pop("embedding")
    query_text = f"{source_table} {source_column} {json.dumps(data)}"
    from qdrant_client import models

    must = [
        models.FieldCondition(
            key="dataset",
            match=models.MatchValue(
                value=dataset_name,
            ),
        ),
        models.FieldCondition(
            key="alignment_role",
            match=models.MatchValue(
                value="target",
            ),
        ),
    ]
    filter = models.Filter(must=must)
    hits = query_vector_db(
        text=query_text, query_vector=query_vector, query_filter=filter, limit=5
    )
    tables = [hit.payload["table"] for hit in hits]
    return tables


def table_to_doc(schema):
    docs = dict()
    for table in schema:
        table_description = None
        primary_keys = []
        foreign_keys = []
        other_columns = []
        schema_rows = []
        for index, column in enumerate(schema[table]):
            schema_rows.append(f"{index}, {table}, {column}")
            data = schema[table][column]
            column_text = (
                f"{column} ({data['ColumnType']}): {data['column_description']}"
            )
            if not table_description:
                table_description = data["table_description"]
            if data["IsPK"] == "YES":
                primary_keys.append(column_text)
            elif data["IsFK"] == "YES":
                foreign_keys.append(column_text + f". References to: {data['FK']}")
            else:
                other_columns.append(column_text)
        primary_keys_str = "\n".join(primary_keys)
        foreign_keys_str = "\n".join(foreign_keys)
        other_columns_str = "\n".join(other_columns)
        schema_str = "\n".join(schema_rows)
        docs[table] = (
            f"{schema_str} \n\n{table}\n {table_description}\nPrimary Keys: \n{primary_keys_str}\nForeign Keys: \n{foreign_keys_str}\nOther Columns: \n{other_columns_str}"
        )

    return docs


def create_top_k_mapping(source_table, source_docs, candidate_tables, target_docs, llm):
    from litellm import completion

    target_texts = dict()
    for candidate_table in candidate_tables:
        target_texts[candidate_table] = target_docs[candidate_table]

    prompt = TEMPLATE % (source_docs[source_table], "\n".join(target_texts.values()))
    messages = [{"content": prompt, "role": "user"}]

    response = completion(
        model="gpt-3.5-turbo",
        seed=42,
        temperature=0.5,
        max_tokens=4096,
        top_p=0.9,
        frequency_penalty=0,
        presence_penalty=0,
        messages=messages,
        response_format={"type": "json_object"},
    )
    return response


def run_experiment(dataset):
    from llm_ontology_alignment.utils import load_embeddings
    from datetime import datetime
    from llm_ontology_alignment.data_models.experiment_result import (
        OntologyAlignmentExperimentResult,
    )

    J = 1
    model = "gpt-3.5-turbo"
    run_id = f"rematch-J_{J}-model_{model}"
    source_schema, target_schema = load_embeddings(dataset)
    source_docs = table_to_doc(source_schema)
    target_docs = table_to_doc(target_schema)
    for source_table in source_schema:
        candidate_tables = []
        for source_column in source_schema[source_table]:
            tables = rank_top_tables(
                dataset_name=dataset,
                source_table=source_table,
                source_column=source_column,
                source_schema=source_schema,
            )
            print(f"Top tables for {source_table}.{source_column}: {tables}")
            candidate_tables.extend(tables[0:J])
        table_run_id = f"{run_id}-{source_table}"
        if OntologyAlignmentExperimentResult.objects(run_id=table_run_id).count() > 0:
            continue
        start = datetime.utcnow()
        try:
            result = create_top_k_mapping(
                source_table,
                source_docs,
                candidate_tables,
                target_docs,
                llm=model,
            )
            end = datetime.utcnow()
            text = result.choices[0]["model_extra"]["message"]["content"]
            record = {
                "run_id": table_run_id,
                "start": start,
                "end": end,
                "duration": (end - start).total_seconds(),
                "text_result": text,
                "dataset": dataset,
                "prompt_tokens": result.model_extra["usage"]["model_extra"][
                    "prompt_tokens"
                ],
                "completion_tokens": result.model_extra["usage"]["model_extra"][
                    "completion_tokens"
                ],
                "total_tokens": result.model_extra["usage"]["model_extra"][
                    "total_tokens"
                ],
            }
            try:
                json_result = json.loads(text)
                record["json_result"] = json_result
            except Exception:
                pass
            print(record)
            res = OntologyAlignmentExperimentResult.upsert(record)
            print(res)
        except Exception as e:
            logger.exception(e)


TEMPLATE = """
You are an expert in databases, and schema matching at top k specifically. Your task is to create matches between source and target tables and
attributes. For each attribute from the source you always suggest the top 2 most relevant tables and columns from the target. You are excellent at
this task.
If none of the columns are relevant, the last table and column should be "NA", "NA". This value may appear only once per mapping!
Your job is to match the schemas. You never provide explanations, code or anything else, only results. Below are the two schemas.
Create top k matches between source and target tables and columns.
Make sure to match the entire input. Make sure to return the results in the following json format with top 2 target results foreach input in source.
Expected output format:
{
  '1': {
    'SRC_ENT': 'SOURCE_TABLE_NAME',
    'SRC_ATT': 'SOURCE_COLUMN_NAME',
    'TGT_ENT1': 'TARGET_TABLE_NAME1',
    'TGT_ATT1': 'TARGET_COLUMN_NAME1',
    'TGT_ENT2': 'TARGET_TABLE_NAME2',
    'TGT_ATT2': 'TARGET_COLUMN_NAME2'
  },
  '2': {
    'SRC_ENT': 'SOURCE_TABLE_NAME',
    'SRC_ATT': 'SOURCE_COLUMN_NAME',
    'TGT_ENT1': 'TARGET_TABLE_NAME1',
    'TGT_ATT1': 'TARGET_COLUMN_NAME1',
    'TGT_ENT2': 'TARGET_TABLE_NAME2',
    'TGT_ATT2': 'TARGET_COLUMN_NAME2'
  }
}...

Source Schema:
,SRC_ENT, SRC_ATT
%s

Target Schema:
,TGT_ENT,TGT_ATT
%s
Remember to match the entire input. Make sure to return only the results!
"""


def get_ground_truth(dataset):
    import csv
    import os
    from collections import defaultdict

    current_file_path = os.path.dirname(__file__)

    file_path = current_file_path + f"/../../dataset/{dataset}_Mapping.csv"
    result = defaultdict(dict)
    with open(file_path, "r") as file:
        for line in csv.DictReader(file):
            result[line["SRC_ENT"]][line["SRC_ATT"]] = line
    return dict(result)


def evaluate_experiment(dataset, run_id_prefix):
    from llm_ontology_alignment.data_models.experiment_result import (
        OntologyAlignmentExperimentResult,
    )
    from collections import defaultdict

    ground_truth = get_ground_truth(dataset)
    top1_predictions = defaultdict(dict)
    top2_predictions = defaultdict(dict)
    for result in OntologyAlignmentExperimentResult.objects(
        run_id__startswith=run_id_prefix, dataset=dataset
    ):
        try:
            json_result = result.json_result
            for idx, result in json_result.items():
                top1_predictions[result["SRC_ENT"]][result["SRC_ATT"]] = {
                    "TGT_ENT": result["TGT_ENT1"],
                    "TGT_ATT": result["TGT_ATT1"],
                }
                top2_predictions[result["SRC_ENT"]][result["SRC_ATT"]] = {
                    "TGT_ENT": result["TGT_ENT2"],
                    "TGT_ATT": result["TGT_ATT2"],
                }
        except Exception as e:
            logger.exception(e)
    top1_predictions = dict(top1_predictions)
    top2_predictions = dict(top2_predictions)

    accuracy_at_1 = []
    accuracy_at_2 = []
    for table in ground_truth:
        for column, mapping in ground_truth[table].items():
            top1_accurate = 0
            top2_accurate = 0
            top1_prediction = top1_predictions.get(table, {}).get(column, {})
            top2_prediction = top2_predictions.get(table, {}).get(column, {})
            if (
                top1_prediction
                and top1_prediction.get("TGT_ENT", "") == mapping["TGT_ENT"]
                and top1_prediction.get("TGT_ENT", "") == mapping["TGT_ATT"]
            ):
                top1_accurate = 1

            if (
                top2_prediction
                and top2_prediction.get("TGT_ENT", "") == mapping["TGT_ENT"]
                and top2_prediction.get("TGT_ATT", "") == mapping["TGT_ATT"]
            ):
                top2_accurate = 1

            accuracy_at_1.append(top1_accurate)
            accuracy_at_2.append(1 if top1_accurate + top2_accurate > 0 else 0)

    accuracy_at_1 = sum(accuracy_at_1) / len(accuracy_at_1)
    accuracy_at_2 = sum(accuracy_at_2) / len(accuracy_at_2)
    print(f"Accuracy at 1: {accuracy_at_1}")
    print(f"Accuracy at 2: {accuracy_at_2}")
