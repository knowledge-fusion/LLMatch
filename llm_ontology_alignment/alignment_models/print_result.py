import json
from collections import defaultdict


def print_result(run_specs):
    from llm_ontology_alignment.alignment_models.rematch import get_ground_truth

    dataset = run_specs["dataset"]
    ground_truths = get_ground_truth(dataset)
    duration, prompt_token, completion_token = 0, 0, 0

    from llm_ontology_alignment.data_models.experiment_models import (
        OntologyAlignmentExperimentResult,
        OntologyAlignmentData,
    )

    top1_predictions = defaultdict(dict)
    top2_predictions = defaultdict(dict)

    alignment_data = {}
    for item in OntologyAlignmentData.objects(dataset=dataset):
        alignment_data[str(item.extra_data["mapping_index"])] = {
            "table": item.table_name,
            "column": item.column_name,
            "description": item["extra_data"]["llm_description"],
        }
    run_id_prefix = json.dumps(run_specs)
    for result in OntologyAlignmentExperimentResult.objects(
        run_id_prefix=run_id_prefix, dataset=dataset
    ):
        json_result = result.json_result
        duration += result.duration
        prompt_token += result.prompt_tokens
        completion_token += result.completion_tokens
        for source_id, target_ids in json_result.items():
            source = alignment_data[source_id]
            if target_ids:
                top1_predictions[source["table"]][source["column"]] = alignment_data[
                    target_ids[0]
                ]
            if len(target_ids) > 1:
                top2_predictions[source["table"]][source["column"]] = alignment_data[
                    target_ids[1]
                ]

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
            "==>",
            f"{target_table}.{target_column}",
            "Top 1:",
            f'{top1_prediction.get("table")}.{top1_prediction.get("column")}',
            "Top 2:",
            f'{top2_prediction.get("table")}.{top2_prediction.get("column")}',
        )

        if (
            top1_prediction
            and top1_prediction.get("table", "") == target_table
            and top1_prediction.get("column", "") == target_column
        ):
            top1_accurate = 1

        if (
            top2_prediction
            and top2_prediction.get("table", "") == target_table
            and top2_prediction.get("column", "") == target_column
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
        f"{duration=}, {prompt_token=}, {completion_token=} total_token={prompt_token + completion_token}"
    )
