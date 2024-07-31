import json

import networkx as nx

template = "[ATT] {att} [VAL] {val}"


def export_single_table_unicorn_data():
    import os
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
        statements = []
        for source_key, source_val in source_data.items():
            for target_key, target_val in target_data.items():
                source_statement = template.format(att=f"{source_key}", val=f"{source_val['type']}")
                target_statement = template.format(att=f"{target_key}", val=f"{target_val['type']}")
                connected = mapping_data.get(source_key) == target_key
                statements.append([source_statement, target_statement, 1 if connected else 0])

            script_dir = os.path.dirname(__file__)
            fileout_path = os.path.join(
                script_dir,
                "..",
                "..",
                "dataset/test_data/unicorn",
                f"{dir_name}-original.json",
            )
            with open(fileout_path, "w") as f:
                f.write(json.dumps(statements))


def export_unicorn_test_data(run_specs):
    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite
    from llm_ontology_alignment.evaluations.evaluation import load_ground_truth

    for llm_model in ["original", "gpt-4o", "gpt-3.5-turbo"]:
        G, ground_truths, _, _, _ = load_ground_truth(llm_model, run_specs["source_db"], run_specs["target_db"])
        statements = []
        for source in OntologySchemaRewrite.objects(database=run_specs["source_db"], llm_model=llm_model):
            for target in OntologySchemaRewrite.objects(database=run_specs["target_db"], llm_model=llm_model):
                source_statement = template.format(
                    att=f"{source.table}.{source.column}", val=f"{source.table_description} {source.column_description}"
                )
                target_statement = template.format(
                    att=f"{target.table}.{target.column}", val=f"{target.table_description} {target.column_description}"
                )
                connected = False
                for ground_truth_source in ground_truths.get(target.table, {}).get(target.column, []):
                    connected = nx.has_path(G, f"{source.table}.{source.column}", ground_truth_source)
                    if connected:
                        break

                statements.append([source_statement, target_statement, 1 if connected else 0])

        fileout_path = os.path.join(
            script_dir,
            "..",
            "..",
            "dataset/test_data/unicorn",
            f"{run_specs['source_db']}-{run_specs['target_db']}-{llm_model}.json",
        )
        with open(fileout_path, "w") as f:
            f.write(json.dumps(statements))


def import_unicorn_single_table_result():
    import os

    script_dir = os.path.dirname(__file__)
    file_path = os.path.join(
        script_dir,
        "..",
        "..",
        "dataset/match_result/unicorn_result_single_table.json",
    )
    with open(file_path, "r") as f:
        data = json.loads(f.read())
    for dataset, result in data.items():
        from llm_ontology_alignment.data_models.experiment_models import OntologyMatchingEvaluationReport

        dataset = dataset.split("-")[0]
        OntologyMatchingEvaluationReport.upsert(
            {
                "source_database": dataset.split("_")[0],
                "target_database": dataset.split("_")[1],
                "rewrite_llm": "original",
                "strategy": "unicorn",
                "matching_duration": round(result["duration"], 3),
                "total_duration": round(result["duration"], 3),
                "precision": round(result["acc"], 3),
                "recall": round(result["recall"], 3),
                "f1_score": round(result["f1"], 3),
            }
        )


def import_unicorn_result():
    import os
    from llm_ontology_alignment.data_models.experiment_models import OntologyMatchingEvaluationReport

    script_dir = os.path.dirname(__file__)
    file_path = os.path.join(
        script_dir,
        "..",
        "..",
        "dataset/match_result/unicorn_result.json",
    )
    with open(file_path, "r") as f:
        data = json.loads(f.read())
    for dataset in ["imdb-sakila", "omop-cms", "mimic_iii-omop", "cprd_aurum-omop", "cprd_gold-omop"]:
        for llm_model in ["original", "gpt-3.5-turbo", "gpt-4o"]:
            key = f"{dataset}-{llm_model.split('.')[0]}"
            result = data[key]
            OntologyMatchingEvaluationReport.upsert(
                {
                    "source_database": dataset.split("-")[0],
                    "target_database": dataset.split("-")[1],
                    "rewrite_llm": llm_model,
                    "strategy": "unicorn",
                    "matching_duration": round(result["duration"], 3),
                    "total_duration": round(result["duration"], 3),
                    "precision": round(result["acc"], 3),
                    "recall": round(result["recall"], 3),
                    "f1_score": round(result["f1"], 3),
                }
            )


if __name__ == "__main__":
    import_unicorn_single_table_result()
    # for dataset in ["imdb-sakila", "omop-cms", "mimic_iii-omop", "cprd_aurum-omop", "cprd_gold-omop"]:
    #     source_db, target_db = dataset.split("-")
    #     run_specs = {
    #         "source_db": source_db,
    #         "target_db": target_db,
    #
    #     }
    #     export_unicorn_test_data(run_specs)
