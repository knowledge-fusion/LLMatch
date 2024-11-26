import json


from schema_match.constants import EXPERIMENTS

template = "[ATT] {att} [VAL] {val}"


def export_single_table_unicorn_data():
    import os
    import json

    from schema_match.evaluations.single_table_alignment import get_single_table_experiment_data

    experiment_data = get_single_table_experiment_data()
    for dir_name, data in experiment_data.items():
        source_columns = data["source_columns"]
        target_columns = data["target_columns"]
        source_samples = data["source_samples"]
        target_samples = data["target_samples"]
        mapping_data = data["mapping_data"]
        statements = []
        for source_idx, source in enumerate(source_columns):
            for target_idx, target in enumerate(target_columns):
                source_statement = f"[ATT] {source} [VAL] " + " [VAL] ".join(
                    [item[source_idx] for item in source_samples if item[source_idx]]
                )
                target_statement = f"[ATT] {target} [VAL] " + " [VAL] ".join(
                    [item[target_idx] for item in target_samples if item[target_idx]]
                )
                connected = mapping_data.get(source.split(" ")[0]) == target.split(" ")[0]
                if connected:
                    print(dir_name)
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
    from schema_match.data_models.experiment_models import OntologySchemaRewrite
    from schema_match.evaluations.ontology_matching_evaluation import load_ground_truth

    for llm_model in ["original"]:
        ground_truths = load_ground_truth(llm_model, run_specs["source_db"], run_specs["target_db"])
        statements = []
        for source in OntologySchemaRewrite.objects(database=run_specs["source_db"], llm_model=llm_model):
            for target in OntologySchemaRewrite.objects(database=run_specs["target_db"], llm_model=llm_model):
                source_statement = template.format(
                    att=f"{source.table}.{source.column}", val=f"{source.table_description} {source.column_description}"
                )
                target_statement = template.format(
                    att=f"{target.table}.{target.column}", val=f"{target.table_description} {target.column_description}"
                )

                source_entry = f"{source.table}.{source.column}"
                if source.linked_table:
                    source_entry = f"{source.linked_table}.{source.linked_column}"
                target_entry = f"{target.table}.{target.column}"
                if target.linked_table:
                    target_entry = f"{target.linked_table}.{target.linked_column}"

                connected = False
                for target in ground_truths[source_entry]:
                    if target == target_entry:
                        connected = True
                        break
                if connected:
                    print(source, target)

                statements.append([source_statement, target_statement, 1 if connected else 0])
        import os

        script_dir = os.path.dirname(__file__)
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
        from schema_match.data_models.evaluation_report import OntologyMatchingEvaluationReport

        dataset = dataset.split("-")[0]
        record = {
            "source_database": dataset + "_source",
            "target_database": dataset + "_target",
            "rewrite_llm": "original",
            "column_matching_strategy": "unicorn",
            "table_selection_strategy": "None",
            "table_selection_llm": "None",
            "column_matching_llm": "None",
            "rewrite_duration": 0,
            "matching_duration": round(result["duration"], 3),
            "total_duration": round(result["duration"], 3),
            "precision": round(result["acc"], 3),
            "recall": round(result["recall"], 3),
            "f1_score": round(result["f1"], 3),
        }
        print(record)
        res = OntologyMatchingEvaluationReport.upsert(record)
        res = OntologyMatchingEvaluationReport.objects(**record).first()
        assert res.total_duration == record["total_duration"], f"{res.total_duration} != {record['total_duration']}"
        print(f"{res.total_duration} != {record['total_duration']}")


def import_unicorn_result():
    import os
    from schema_match.data_models.evaluation_report import OntologyMatchingEvaluationReport

    script_dir = os.path.dirname(__file__)
    file_path = os.path.join(
        script_dir,
        "..",
        "..",
        "dataset/match_result/unicorn_result.json",
    )
    with open(file_path, "r") as f:
        data = json.loads(f.read())
    for dataset in EXPERIMENTS:
        for llm_model in ["original"]:
            key = f"{dataset}-{llm_model.split('.')[0]}"
            result = data[key]
            OntologyMatchingEvaluationReport.upsert(
                {
                    "source_database": dataset.split("-")[0],
                    "target_database": dataset.split("-")[1],
                    "rewrite_llm": llm_model,
                    "column_matching_strategy": "unicorn",
                    "table_selection_strategy": "None",
                    "table_selection_llm": "None",
                    "column_matching_llm": "None",
                    "matching_duration": round(result["duration"], 3),
                    "total_duration": round(result["duration"], 3),
                    "precision": round(result["acc"], 3),
                    "recall": round(result["recall"], 3),
                    "f1_score": round(result["f1"], 3),
                }
            )


if __name__ == "__main__":
    import_unicorn_result()
    import_unicorn_single_table_result()
