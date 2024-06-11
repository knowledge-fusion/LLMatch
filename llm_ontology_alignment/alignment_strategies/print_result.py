import json
from collections import defaultdict


def print_result(run_specs):
    from llm_ontology_alignment.alignment_strategies.rematch import get_ground_truth

    dataset = run_specs["dataset"]
    ground_truths = get_ground_truth(dataset)

    from llm_ontology_alignment.data_models.experiment_models import (
        OntologyAlignmentGroundTruth,
    )

    OntologyAlignmentGroundTruth.upsert({"dataset": dataset, "data": ground_truths})

    duration, prompt_token, completion_token = 0, 0, 0

    from llm_ontology_alignment.data_models.experiment_models import (
        OntologyAlignmentExperimentResult,
        OntologyAlignmentData,
    )

    top1_predictions = defaultdict(dict)
    top2_predictions = defaultdict(dict)

    alignment_data = {}
    descriptions = defaultdict(dict)
    for item in OntologyAlignmentData.objects(dataset=dataset):
        alignment_data[str(item.extra_data["matching_index"])] = {
            "table": item.table_name,
            "column": item.column_name,
            "description": item["llm_description"],
        }
        descriptions[item.table_name][item.column_name] = item.llm_description

    run_id_prefix = json.dumps(run_specs)
    for result in OntologyAlignmentExperimentResult.objects(
        run_id_prefix=run_id_prefix, dataset=dataset
    ):
        json_result = result.json_result
        duration += result.duration
        prompt_token += result.prompt_tokens
        completion_token += result.completion_tokens
        for source_id, target_ids in json_result.items():
            source = alignment_data[source_id[1:]]
            if target_ids:
                top1_predictions[source["table"]][source["column"]] = alignment_data[
                    target_ids[0][1:]
                ]
            if len(target_ids) > 1:
                top2_predictions[source["table"]][source["column"]] = alignment_data[
                    target_ids[1][1:]
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
        if (
            top1_prediction.get("table", "NA") == target_table
            and top1_prediction.get("column", "NA") == target_column
        ):
            top1_accurate = 1

        if (
            top2_prediction.get("table", "NA") == target_table
            and top2_prediction.get("column", "NA") == target_column
        ):
            top2_accurate = 1

        print(
            f"\n\n{source_table}.{source_column}",
            "==>",
            f"{target_table}.{target_column}",
            f"\n{descriptions[source_table].get(source_column, 'NA')}",
            "==>",
            f"{descriptions[target_table].get(target_column, 'NA')}",
            f"\nTop 1: {top1_accurate=}",
            f'{top1_prediction.get("table", "NA")}.{top1_prediction.get("column", "NA")}',
            f',{descriptions.get(top1_prediction.get("table", "NA"), {}).get(top1_prediction.get("column", "NA"), "")}',
            f"\nTop 2: {top2_accurate=}",
            f'{top2_prediction.get("table", "NA")}.{top2_prediction.get("column", "NA")}',
            f',{descriptions.get(top2_prediction.get("table", "NA"), {}).get(top2_prediction.get("column", "NA"), "")}',
        )

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


def print_result_one_to_many(run_specs):
    dataset = run_specs["dataset"]

    duration, prompt_token, completion_token = 0, 0, 0

    from llm_ontology_alignment.data_models.experiment_models import (
        OntologyAlignmentExperimentResult,
        OntologyAlignmentData,
        OntologyAlignmentGroundTruth,
    )

    ground_truths = defaultdict(lambda: defaultdict(list))
    predictions = defaultdict(lambda: defaultdict(list))

    alignment_data = {}
    descriptions = defaultdict(dict)
    for item in OntologyAlignmentData.objects(dataset=dataset):
        alignment_data[str(item.extra_data["matching_index"])] = {
            "table": item.table_name,
            "column": item.column_name,
            "description": item["llm_description"],
        }
        descriptions[item.table_name][item.column_name] = item.llm_description

    run_id_prefix = json.dumps(run_specs)
    for result in OntologyAlignmentExperimentResult.objects(
        run_id_prefix=run_id_prefix, dataset=dataset
    ):
        json_result = result.json_result
        duration += result.duration
        prompt_token += result.prompt_tokens
        completion_token += result.completion_tokens
        for source_id, target_ids in json_result.items():
            source = alignment_data[source_id[1:]]
            for target_id in target_ids:
                record = alignment_data[target_id[1:]]
                predictions[source["table"]][source["column"]].append(
                    f"{record['table']}.{record['column']}"
                )

    for line in OntologyAlignmentGroundTruth.objects(dataset=dataset).first().data:
        source_table = line["source_table"]
        source_column = line["source_column"]
        target_table = line["target_table"]
        target_column = line["target_column"]
        ground_truths[source_table][source_column].append(
            f"{target_table}.{target_column}"
        )

    # predictions = json.loads(json.dumps(predictions))
    ground_truths = json.loads(json.dumps(ground_truths))
    tp, fp, fn, tn = 0, 0, 0, 0
    for source_table in ground_truths.keys():
        for source_column in ground_truths[source_table].keys():
            print(
                f"\n\n{source_table}.{source_column}",
                "==>",
                f"\nGround Truth:{ground_truths[source_table][source_column]}",
                f"\nPredictions: {predictions.get(source_table, {}).get(source_column, [])}",
            )
            tp += len(
                set(ground_truths[source_table][source_column])
                & set(predictions[source_table].get(source_column, []))
            )
            fp += len(
                set(predictions[source_table].get(source_column, []))
                - set(ground_truths[source_table][source_column])
            )
            fn += len(
                set(ground_truths[source_table][source_column])
                - set(predictions[source_table].get(source_column, []))
            )

    print(f"{tp=} {fp=} {fn=} {tn=}")

    print(
        f"{duration=}, {prompt_token=}, {completion_token=} total_token={prompt_token + completion_token}"
    )
