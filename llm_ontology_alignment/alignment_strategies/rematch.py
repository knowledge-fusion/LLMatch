import json
import logging

from llm_ontology_alignment.utils import get_embeddings, cosine_distance

logger = logging.getLogger(__name__)


def table_to_doc(schema):
    docs = dict()
    index = 0
    for table, table_data in schema.items():
        primary_keys = []
        foreign_keys = []
        other_columns = []
        schema_rows = ["ID, ENT, ATT"]
        for idx, column in enumerate(table_data["columns"]):
            schema_rows.append(f"{idx}, {table}, {column}")
            column_data = table_data["columns"][column]
            column_text = f"{column}: {column_data['description']}"
            if column_data.get("is_primary_key"):
                primary_keys.append(column_text)
            elif column_data.get("is_foreign_key"):
                foreign_keys.append(column_text + f". References to: {column_data['linked_entry']}")
            else:
                other_columns.append(column_text)
        primary_keys_str = "\n".join(primary_keys)
        foreign_keys_str = "\n".join(foreign_keys)
        other_columns_str = "\n".join(other_columns)
        schema_str = "\n".join(schema_rows)
        docs[table] = (
            f"Table: {table}\n{table_data['table_description']}\n{schema_str} \n\n{table}\n Primary Keys: \n{primary_keys_str}\nForeign Keys: \n{foreign_keys_str}\nOther Columns: \n{other_columns_str}"
        )

    return docs


def create_top_k_mapping(source_table, source_docs, candidate_tables, target_docs, run_specs):
    import os

    script_dir = os.path.dirname(os.path.abspath(__file__))

    file_path = os.path.join(script_dir, "table_matching_prompt.md")
    with open(file_path, "r") as file:
        prompt_template = file.read()

    target_texts = dict()
    for candidate_table in candidate_tables:
        target_texts[candidate_table] = target_docs[candidate_table]

    prompt = prompt_template.replace("{{source_docs}}", source_docs[source_table])

    prompt = prompt.replace("{{target_docs}}", "\n".join(target_texts.values()))

    from llm_ontology_alignment.services.language_models import complete

    response = complete(prompt=prompt, model=run_specs["matching_llm"], run_specs=run_specs)
    return response


def run_matching(run_specs):
    from llm_ontology_alignment.data_models.experiment_models import (
        OntologyAlignmentExperimentResult,
    )

    assert run_specs["strategy"] == "rematch"
    J = 2
    K = 5
    source_db, target_db = run_specs["source_db"], run_specs["target_db"]
    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite

    source_descriptions = OntologySchemaRewrite.get_database_description(
        source_db, run_specs["rewrite_llm"], include_foreign_keys=True
    )
    target_descriptions = OntologySchemaRewrite.get_database_description(
        target_db, run_specs["rewrite_llm"], include_foreign_keys=True
    )
    target_docs = table_to_doc(target_descriptions)
    target_embeddings = dict()
    for target_table, target_doc in target_docs.items():
        target_embeddings[target_table] = get_embeddings(target_doc)

    source_docs = table_to_doc(source_descriptions)
    target_docs = table_to_doc(target_descriptions)
    for source_table in source_docs:
        sub_run_id = f"rematch - {source_table}"
        record = OntologyAlignmentExperimentResult.get_llm_result(run_specs=run_specs, sub_run_id=sub_run_id)
        if record:
            continue

        candidate_tables = list(target_descriptions.keys())
        if J > 0:
            candidate_tables = []
            for source_column, source_column_data in source_descriptions[source_table]["columns"].items():
                source_embedding = get_embeddings(json.dumps(source_column_data))
                scores = dict()
                for target_table, target_embeddings in target_embeddings.items():
                    scores[target_table] = cosine_distance(source_embedding, target_embeddings)
                tables = sorted(scores, key=lambda x: scores[x], reverse=True)
                print(f"Top tables for {source_table}.{source_column}: {tables}")
                for table in tables[0:J]:
                    candidate_tables.append(table)

        try:
            response = create_top_k_mapping(
                source_table,
                source_docs,
                candidate_tables,
                target_docs,
                run_specs=run_specs,
            ).json()
            data = response["extra"]["extracted_json"]
            assert data

            OntologyAlignmentExperimentResult.upsert_llm_result(
                run_specs=run_specs,
                sub_run_id=sub_run_id,
                result=response,
            )
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
    for result in OntologyAlignmentExperimentResult.objects(run_id__startswith=run_id_prefix, dataset=dataset):
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
    print(f"{duration=}, {prompt_token=}, {completion_token=} total_token={prompt_token+completion_token}")
