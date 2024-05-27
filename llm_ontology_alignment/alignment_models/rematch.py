import json
import logging

from llm_ontology_alignment.alignment_models.llm_mapping_templates import TEMPLATES
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


def table_to_doc(schema, is_target=False):
    docs = dict()
    index = 0
    for table in schema:
        table_description = None
        primary_keys = []
        foreign_keys = []
        other_columns = []
        schema_rows = ["ID, ENT, ATT"]
        for idx, column in enumerate(schema[table]):
            index += 1
            if is_target:
                schema_rows.append(f"T{index}, {table}, {column}")
            else:
                schema_rows.append(f"S{index}, {table}, {column}")
            data = schema[table][column]
            column_text = (
                f"{column} ({data.get('ColumnType')}): {data['column_description']}"
            )
            if not table_description:
                table_description = data["table_description"]
            if data.get("IsPK") == "YES":
                primary_keys.append(column_text)
            elif data.get("IsFK") == "YES":
                foreign_keys.append(column_text + f". References to: {data['FK']}")
            else:
                other_columns.append(column_text)
        primary_keys_str = "\n".join(primary_keys)
        foreign_keys_str = "\n".join(foreign_keys)
        other_columns_str = "\n".join(other_columns)
        schema_str = "\n".join(schema_rows)
        docs[table] = (
            f"Table: {table}\n{table_description}\n{schema_str} \n\n{table}\n Primary Keys: \n{primary_keys_str}\nForeign Keys: \n{foreign_keys_str}\nOther Columns: \n{other_columns_str}"
        )

    return docs


def create_top_k_mapping(
    source_table, source_docs, candidate_tables, target_docs, llm, template
):
    from litellm import completion

    target_texts = dict()
    for candidate_table in candidate_tables:
        target_texts[candidate_table] = target_docs[candidate_table]

    if source_table:
        prompt = TEMPLATES[template] % (
            source_docs[source_table],
            "\n".join(target_texts.values()),
        )
    else:
        source_text = "\n\n".join(list(source_docs.values()))
        prompt = TEMPLATES[template] % (source_text, "\n".join(target_texts.values()))

    messages = [{"content": prompt, "role": "user"}]

    response = completion(
        model=llm,
        seed=42,
        temperature=0.5,
        top_p=0.9,
        max_tokens=4096,
        frequency_penalty=0,
        presence_penalty=0,
        messages=messages,
        response_format={"type": "json_object"},
    )
    return response


def run_experiment(dataset, model="gpt-3.5-turbo", J=1, template="top5"):
    from llm_ontology_alignment.utils import load_embeddings
    from datetime import datetime
    from llm_ontology_alignment.data_models.experiment_models import (
        OntologyAlignmentExperimentResult,
    )

    run_id = f"rematch-J_{J}-model_{model}-template_{template}"
    source_schema, target_schema = load_embeddings(dataset)
    source_docs = table_to_doc(source_schema, is_target=False)
    target_docs = table_to_doc(target_schema, is_target=True)
    for source_table in source_schema:
        if J == -2:
            source_table = None

        table_run_id = f"{run_id}-{source_table}"
        OntologyAlignmentExperimentResult.objects(
            run_id=table_run_id, dataset=dataset
        ).delete()
        if (
            OntologyAlignmentExperimentResult.objects(
                run_id=table_run_id, dataset=dataset
            ).count()
            > 0
        ):
            continue

        candidate_tables = list(target_schema.keys())
        if J > 0:
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

        start = datetime.utcnow()

        try:
            result = create_top_k_mapping(
                source_table,
                source_docs,
                candidate_tables,
                target_docs,
                llm=model,
                template=template,
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
            if J == -2:
                break
        except Exception as e:
            logger.exception(e)


def get_ground_truth(dataset):
    import csv
    import os

    current_file_path = os.path.dirname(__file__)

    file_path = current_file_path + f"/../../dataset/{dataset}_Mapping.csv"
    result = []
    with open(file_path, "r") as file:
        for line in csv.DictReader(file):
            result.append(line)
    return result


def evaluate_experiment(dataset, run_id_prefix):
    from llm_ontology_alignment.data_models.experiment_models import (
        OntologyAlignmentExperimentResult,
    )
    from collections import defaultdict
    from llm_ontology_alignment.utils import load_embeddings

    source_schema, target_schema = load_embeddings(dataset)
    source_columns = {"NA": {"table": "NA", "column": "NA"}}
    target_columns = {"NA": {"table": "NA", "column": "NA"}}
    idx = 0
    for columns in source_schema.values():
        for column, column_data in columns.items():
            idx += 1
            source_columns[f"S{idx}"] = column_data
    idx = 0
    for columns in target_schema.values():
        for column, column_data in columns.items():
            idx += 1
            target_columns[f"T{idx}"] = column_data
    ground_truths = get_ground_truth(dataset)
    top1_predictions = defaultdict(dict)
    top2_predictions = defaultdict(dict)
    duration, prompt_token, completion_token = 0, 0, 0
    for result in OntologyAlignmentExperimentResult.objects(
        run_id__startswith=run_id_prefix, dataset=dataset
    ):
        try:
            json_result = result.json_result
            duration += result.duration
            prompt_token += result.prompt_tokens
            completion_token += result.completion_tokens
            for idx, result in json_result.items():
                if isinstance(result, str):
                    source = source_columns[idx]
                    target = target_columns[result]
                    top1_predictions[source["table"]][source["column"]] = {
                        "TGT_ENT": target["table"],
                        "TGT_ATT": target["column"],
                    }
                else:
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
    for line in ground_truths:
        source_table = line["source_table"]
        source_column = line["source_column"]
        target_table = line["target_table"]
        target_column = line["target_column"]
        top1_accurate = 0
        top2_accurate = 0
        top1_prediction = top1_predictions.get(source_table, {}).get(source_column, {})
        top2_prediction = top2_predictions.get(source_table, {}).get(source_column, {})

        print(
            f"{source_table}.{source_column}",
            f"{target_table}.{target_column}",
            "top 1==>",
            top1_prediction.get("TGT_ENT"),
            top1_prediction.get("TGT_ATT"),
        )
        print(
            f"{source_table}.{source_column}",
            f"{target_table}.{target_column}",
            "top 2==>",
            top2_prediction.get("TGT_ENT"),
            top2_prediction.get("TGT_ATT"),
        )

        if (
            top1_prediction
            and top1_prediction.get("TGT_ENT", "") == target_table
            and top1_prediction.get("TGT_ATT", "") == target_column
        ):
            top1_accurate = 1

        if (
            top2_prediction
            and top2_prediction.get("TGT_ENT", "") == target_table
            and top2_prediction.get("TGT_ATT", "") == target_column
        ):
            top2_accurate = 1

        accuracy_at_1.append(top1_accurate)
        accuracy_at_2.append(1 if top1_accurate + top2_accurate > 0 else 0)

    accuracy_at_1 = sum(accuracy_at_1) / len(accuracy_at_1)
    accuracy_at_2 = sum(accuracy_at_2) / len(accuracy_at_2)
    print(run_id_prefix)
    print(f"Accuracy at 1: {accuracy_at_1}")
    print(f"Accuracy at 2: {accuracy_at_2}")
    print(
        f"{duration=}, {prompt_token=}, {completion_token=} total_token={prompt_token+completion_token}"
    )
