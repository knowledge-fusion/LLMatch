from collections import defaultdict

from llm_ontology_alignment.services.language_models import complete
from llm_ontology_alignment.utils import calculate_f1, camel_to_snake
from dotenv import load_dotenv

load_dotenv()


def run_gpt_evaluation():
    import os
    import datetime
    import json

    script_dir = os.path.dirname(__file__)
    file_path = os.path.join(script_dir, "../../dataset/test_data/valentine/")
    for dir_name in os.listdir(file_path):
        if dir_name.startswith("."):
            continue
        mapping_data, source_data, target_data = dict(), None, None
        with open(os.path.join(file_path, dir_name, "mapping.json"), "r") as f:
            for item in json.loads(f.read())["matches"]:
                mapping_data[item["source_column"]] = item["target_column"]
        with open(os.path.join(file_path, dir_name, "source.json"), "r") as f:
            source_data = json.loads(f.read())
        with open(os.path.join(file_path, dir_name, "target.json"), "r") as f:
            target_data = json.loads(f.read())
        source_columns, target_columns = [], []
        for key, val in source_data.items():
            source_columns.append(f"{key} ({val['type']})")
        for key, val in target_data.items():
            target_columns.append(f"{key} ({val['type']})")

        for llm_model in ["gpt-3.5-turbo", "gpt-4o"]:
            start = datetime.datetime.utcnow()
            record = {
                "source_database": dir_name.split("_")[0],
                "target_database": dir_name.split("_")[1],
                "rewrite_llm": "original",
                "matching_llm": llm_model,
            }
            record["strategy"] = llm_model

            prompt = "Match the following columns from the source and target databases:"
            prompt += "Source columns:\n" + "\n".join(source_columns)
            prompt += "\nTarget columns:\n" + "\n".join(target_columns)
            prompt += "\n\nOutput in following json format:\n"
            prompt += "{'source_column': 'target_column'}"
            prompt += "\n\n Only return a json object and no other text"

            response = complete(prompt, run_specs=record, model=llm_model)
            res = response.json()["extra"]["extracted_json"]
            end = datetime.datetime.utcnow()
            tp, fp, fn = 0, 0, 0
            predictions = defaultdict(list)
            for source, target in res.items():
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
            record["total_duration"] = (end - start).total_seconds()
            from llm_ontology_alignment.data_models.experiment_models import OntologyMatchingEvaluationReport

            print(record)
            OntologyMatchingEvaluationReport.upsert(record)


def run_valentine_evaluation():
    import os
    import pandas as pd
    import datetime
    import json

    script_dir = os.path.dirname(__file__)
    file_path = os.path.join(script_dir, "../../dataset/test_data/valentine/")
    for dir_name in os.listdir(file_path):
        if dir_name.startswith("."):
            continue
        mapping_data, source_data, target_data = dict(), None, None
        with open(os.path.join(file_path, dir_name, "mapping.json"), "r") as f:
            for item in json.loads(f.read())["matches"]:
                mapping_data[item["source_column"]] = item["target_column"]
        with open(os.path.join(file_path, dir_name, "source.json"), "r") as f:
            source_data = json.loads(f.read())
        with open(os.path.join(file_path, dir_name, "target.json"), "r") as f:
            target_data = json.loads(f.read())
        source_columns, target_columns = [], []
        for key, val in source_data.items():
            source_columns.append(f"{key} ({val['type']})")
        for key, val in target_data.items():
            target_columns.append(f"{key} ({val['type']})")

        df1 = pd.DataFrame([], columns=source_columns)
        df2 = pd.DataFrame([], columns=target_columns)

        from valentine.algorithms import SimilarityFlooding, Cupid, Coma
        from valentine import valentine_match

        for algorithm_cls in [SimilarityFlooding, Cupid, Coma]:
            start = datetime.datetime.utcnow()
            record = {
                "source_database": dir_name.split("_")[0],
                "target_database": dir_name.split("_")[1],
                "rewrite_llm": "original",
            }
            record["strategy"] = camel_to_snake(algorithm_cls.__name__)

            matcher = algorithm_cls()
            matches = valentine_match(df1, df2, matcher)
            print(f"Found the following {len(matches)} matches using {algorithm_cls.__name__}:")

            one_to_one = matches.one_to_one()
            end = datetime.datetime.utcnow()
            tp, fp, fn = 0, 0, 0
            predictions = defaultdict(list)
            for (source, target), score in one_to_one.items():
                source = source[1].split(" ")[0]
                target = target[1].split(" ")[0]
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
            record["total_duration"] = (end - start).total_seconds()
            from llm_ontology_alignment.data_models.experiment_models import OntologyMatchingEvaluationReport

            OntologyMatchingEvaluationReport.upsert(record)


if __name__ == "__main__":
    run_gpt_evaluation()
