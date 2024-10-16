import json
import os
from collections import defaultdict

from llm_ontology_alignment.services.language_models import complete
from llm_ontology_alignment.utils import calculate_f1, camel_to_snake
from dotenv import load_dotenv

load_dotenv()


def run_rematch_single_table_evaluation():
    import datetime

    for dir_name, data in get_single_table_experiment_data().items():
        source_samples = data["source_samples"]
        target_samples = data["target_samples"]
        mapping_data = data["mapping_data"]
        source_columns, target_columns = [], []
        for idx, key in enumerate(data["source_columns"]):
            source_columns.append(
                f"ENT: source ATT: {key.split('(')[0]}, Examples:" + ",".join([item[idx] for item in source_samples])
            )
        for idx, key in enumerate(data["target_columns"]):
            target_columns.append(
                f"ENT: target, ATT: {key.split('(')[0]}, Examples:" + ",".join([item[idx] for item in target_samples])
            )

        for strategy in ["llm-rematch"]:
            start = datetime.datetime.utcnow()
            run_specs = {
                "source_database": dir_name + "_source",
                "target_database": dir_name + "_target",
                "rewrite_llm": "original",
                "column_matching_strategy": strategy,
                "column_matching_llm": "gpt-4o",
                "table_selection_strategy": "column_to_table_vector_similarity",
                "table_selection_llm": "None",
            }
            from llm_ontology_alignment.alignment_strategies.rematch import create_top_k_mapping

            response = create_top_k_mapping(
                source_table="source",
                source_docs={"source": json.dumps(source_columns)},
                candidate_tables=["target"],
                target_docs={"target": json.dumps(target_columns)},
                run_specs=run_specs,
            ).json()

            end = datetime.datetime.utcnow()
            json_result = response["extra"]["extracted_json"]
            predictions = dict()
            for item in json_result.values():
                if not item:
                    continue
                source_table = item["SRC_ENT"]
                source_column = item["SRC_ATT"]
                source = f"{source_column}"
                targets = []
                if item.get("TGT_ENT1", "NA") != "NA" and item.get("TGT_ATT1", "NA") != "NA":
                    targets.append(item["TGT_ATT1"])
                if item.get("TGT_ENT2", "NA") != "NA" and item.get("TGT_ATT2", "NA") != "NA":
                    targets.append(item["TGT_ATT2"])
                predictions[source] = list(set(targets))

            end = datetime.datetime.utcnow()
            tp, fp, fn = 0, 0, 0
            for source, targets in predictions.items():
                for target in targets:
                    if target == mapping_data.get(source, None):
                        tp += 1
                    else:
                        fp += 1
            for source, target in mapping_data.items():
                if target not in predictions.get(source, []):
                    fn += 1
            precision, recall, f1 = calculate_f1(tp, fp, fn)
            run_specs["precision"] = precision
            run_specs["recall"] = recall
            run_specs["f1_score"] = f1
            run_specs["total_duration"] = (end - start).total_seconds()
            from llm_ontology_alignment.data_models.evaluation_report import OntologyMatchingEvaluationReport

            print(run_specs)
            OntologyMatchingEvaluationReport.upsert(run_specs)


def run_schema_understanding_single_table_evaluation():
    import datetime

    for dir_name, data in get_single_table_experiment_data().items():
        source_samples = data["source_samples"]
        target_samples = data["target_samples"]
        mapping_data = data["mapping_data"]
        source_columns, target_columns = list(), list()
        for idx, key in enumerate(data["source_columns"]):
            source_columns.append(
                {
                    "table": "source",
                    "column": key.split("(")[0],
                    "type": key.split("(")[1].split(")")[0],
                    "examples": [item[idx] for item in source_samples],
                }
            )
        for idx, key in enumerate(data["target_columns"]):
            target_columns.append(
                {
                    "table": "target",
                    "column": key.split("(")[0],
                    "type": key.split("(")[1].split(")")[0],
                    "examples": [item[idx] for item in target_samples],
                }
            )

        script_dir = os.path.dirname(os.path.abspath(__file__))
        file_path = os.path.join(
            script_dir,
            "../alignment_strategies/column_matching_prompt_no_reasoning.md",
        )
        with open(file_path, "r") as file:
            prompt_template = file.read()

        for strategy in ["llm"]:
            start = datetime.datetime.utcnow()
            run_specs = {
                "source_database": dir_name + "_source",
                "target_database": dir_name + "_target",
                "rewrite_llm": "original",
                "column_matching_strategy": strategy,
                "column_matching_llm": "gpt-4o",
                "table_selection_strategy": "llm",
                "table_selection_llm": "gpt-4o",
            }
            prompt = prompt_template.replace("{{source_columns}}", json.dumps(source_columns, indent=2))
            prompt = prompt.replace("{{target_columns}}", json.dumps(target_columns, indent=2))
            response = complete(prompt, run_specs["column_matching_llm"], run_specs=run_specs).json()

            end = datetime.datetime.utcnow()
            json_result = response["extra"]["extracted_json"]
            predictions = dict()
            for source, targets in json_result.items():
                if not targets:
                    continue
                source_column = source.split(".")[-1]
                source = f"{source_column}"
                target_columns = []
                for target in targets:
                    if target.get("mapping") not in ["None", ""]:
                        target_columns.append(target["mapping"].split(".")[-1])
                predictions[source] = list(set(target_columns))

            end = datetime.datetime.utcnow()
            tp, fp, fn = 0, 0, 0
            for source, targets in predictions.items():
                for target in targets:
                    if target == mapping_data.get(source, None):
                        tp += 1
                    else:
                        fp += 1
            for source, target in mapping_data.items():
                if target not in predictions.get(source, []):
                    fn += 1
            precision, recall, f1 = calculate_f1(tp, fp, fn)
            run_specs["precision"] = precision
            run_specs["recall"] = recall
            run_specs["f1_score"] = f1
            run_specs["total_duration"] = (end - start).total_seconds()
            from llm_ontology_alignment.data_models.evaluation_report import OntologyMatchingEvaluationReport

            print(run_specs)
            OntologyMatchingEvaluationReport.upsert(run_specs)


def get_single_table_experiment_data():
    import os
    import json

    result = dict()

    script_dir = os.path.dirname(__file__)
    file_path = os.path.join(script_dir, "../../dataset/test_data/valentine/Wikidata/Musicians")
    for dir_name in os.listdir(file_path):
        if dir_name.startswith("."):
            continue
        mapping_data, source_data, target_data = dict(), None, None
        with open(os.path.join(file_path, dir_name, f"{dir_name.lower()}_mapping.json"), "r") as f:
            for item in json.loads(f.read())["matches"]:
                mapping_data[item["source_column"]] = item["target_column"]
        with open(os.path.join(file_path, dir_name, f"{dir_name.lower()}_source.json"), "r") as f:
            source_data = json.loads(f.read())
        with open(os.path.join(file_path, dir_name, f"{dir_name.lower()}_target.json"), "r") as f:
            target_data = json.loads(f.read())
        source_columns, target_columns = [], []
        for key, val in source_data.items():
            source_columns.append(f"{key} ({val['type']})")
        for key, val in target_data.items():
            target_columns.append(f"{key} ({val['type']})")

        import csv

        source_samples = []

        # Open the CSV file
        with open(os.path.join(file_path, dir_name, f"{dir_name.lower()}_source.csv"), mode="r") as file:
            csv_reader = csv.reader(file)
            for row in csv_reader:
                empty_items = [item for item in row if not item]
                if not empty_items:
                    source_samples.append(row)
                if len(source_samples) > 6:
                    break

        target_samples = []
        with open(os.path.join(file_path, dir_name, f"{dir_name.lower()}_target.csv"), mode="r") as file:
            csv_reader = csv.reader(file)
            for row in csv_reader:
                empty_items = [item for item in row if not item]
                if len(empty_items) < 2:
                    target_samples.append(row)
                if len(target_samples) > 6:
                    break
        assert len(source_samples) > 1
        assert len(target_samples) > 1

        result[dir_name] = {
            "source_columns": source_columns,
            "target_columns": target_columns,
            "source_samples": source_samples[1:],
            "target_samples": target_samples[1:],
            "mapping_data": mapping_data,
        }
    return result


def run_valentine_evaluation():
    import pandas as pd
    import datetime

    for dir_name, data in get_single_table_experiment_data().items():
        source_samples = data["source_samples"]
        target_samples = data["target_samples"]
        source_columns = data["source_columns"]
        target_columns = data["target_columns"]
        mapping_data = data["mapping_data"]
        df1 = pd.DataFrame(source_samples, columns=source_columns)
        df2 = pd.DataFrame(target_samples, columns=target_columns)

        from valentine.algorithms import SimilarityFlooding, Cupid, Coma
        from valentine import valentine_match

        for algorithm_cls in [SimilarityFlooding, Cupid, Coma]:
            start = datetime.datetime.utcnow()
            record = {
                "source_database": dir_name + "_source",
                "target_database": dir_name + "_target",
                "rewrite_llm": "original",
            }
            record["column_matching_strategy"] = camel_to_snake(algorithm_cls.__name__)

            matcher = algorithm_cls()
            matches = valentine_match(df1, df2, matcher)
            end = datetime.datetime.utcnow()

            print(f"Found the following {len(matches)} matches using {algorithm_cls.__name__}:")

            one_to_one = matches.one_to_one()
            tp, fp, fn = 0, 0, 0
            predictions = defaultdict(list)
            for ((_, source), (_, target)), score in one_to_one.items():
                source = source.split(" ")[0]
                target = target.split(" ")[0]
                predictions[source].append(target)

            for source, targets in predictions.items():
                for target in targets:
                    if target == mapping_data.get(source, None):
                        tp += 1
                    else:
                        fp += 1
            for source, target in mapping_data.items():
                if target not in predictions[source]:
                    fn += 1
            precision, recall, f1 = calculate_f1(tp, fp, fn)
            record["precision"] = precision
            record["recall"] = recall
            record["f1_score"] = f1
            record["matching_duration"] = (end - start).total_seconds()
            record["total_duration"] = (end - start).total_seconds()
            record["table_selection_strategy"] = "None"
            record["table_selection_llm"] = "None"
            record["column_matching_llm"] = "None"

            from llm_ontology_alignment.data_models.evaluation_report import OntologyMatchingEvaluationReport

            print(record)
            OntologyMatchingEvaluationReport.upsert(record)


if __name__ == "__main__":
    run_schema_understanding_single_table_evaluation()
