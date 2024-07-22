import json
from collections import defaultdict


def calculate_metrics(TP, FP, FN):
    try:
        precision = TP / (TP + FP)
        recall = TP / (TP + FN)
        f1_score = 2 * (precision * recall) / (precision + recall)
        return round(precision, 2), round(recall, 2), round(f1_score, 2)
    except ZeroDivisionError:
        return 0, 0, 0


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
    for result in OntologyAlignmentExperimentResult.objects(run_id_prefix=run_id_prefix, dataset=dataset):
        json_result = result.json_result
        duration += result.duration
        prompt_token += result.prompt_tokens
        completion_token += result.completion_tokens
        for source_id, target_ids in json_result.items():
            source = alignment_data[source_id[1:]]
            if target_ids:
                top1_predictions[source["table"]][source["column"]] = alignment_data[target_ids[0][1:]]
            if len(target_ids) > 1:
                top2_predictions[source["table"]][source["column"]] = alignment_data[target_ids[1][1:]]

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
        if top1_prediction.get("table", "NA") == target_table and top1_prediction.get("column", "NA") == target_column:
            top1_accurate = 1

        if top2_prediction.get("table", "NA") == target_table and top2_prediction.get("column", "NA") == target_column:
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
    print(f"{duration=}, {prompt_token=}, {completion_token=} total_token={prompt_token + completion_token}")


def print_result_one_to_many_old(run_specs):
    dataset = run_specs["dataset"]

    duration, prompt_token, completion_token = 0, 0, 0

    from llm_ontology_alignment.data_models.experiment_models import (
        OntologyAlignmentExperimentResult,
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
    for result in OntologyAlignmentExperimentResult.objects(run_id_prefix=run_id_prefix, dataset=dataset):
        json_result = result.json_result
        duration += result.duration
        prompt_token += result.prompt_tokens
        completion_token += result.completion_tokens
        for source_id, target_ids in json_result.items():
            source = alignment_data[source_id[1:]]
            for target_id in target_ids:
                record = alignment_data[target_id[1:]]
                predictions[source["table"]][source["column"]].append(f"{record['table']}.{record['column']}")

    for line in OntologyAlignmentGroundTruth.objects(dataset=dataset).first().data:
        source_table = line["source_table"]
        source_column = line["source_column"]
        target_table = line["target_table"]
        target_column = line["target_column"]
        ground_truths[source_table][source_column].append(f"{target_table}.{target_column}")

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
                set(ground_truths[source_table][source_column]) & set(predictions[source_table].get(source_column, []))
            )
            fp += len(
                set(predictions[source_table].get(source_column, [])) - set(ground_truths[source_table][source_column])
            )
            fn += len(
                set(ground_truths[source_table][source_column]) - set(predictions[source_table].get(source_column, []))
            )

    print(f"{tp=} {fp=} {fn=} {tn=}")

    print(f"{duration=}, {prompt_token=}, {completion_token=} total_token={prompt_token + completion_token}")


def print_result_one_to_many(run_specs):
    duration, prompt_token, completion_token = 0, 0, 0
    import networkx as nx

    rewrite_llm = run_specs["rewrite_llm"]
    from llm_ontology_alignment.data_models.experiment_models import (
        OntologyAlignmentExperimentResult,
        OntologyAlignmentGroundTruth,
        OntologySchemaRewrite,
    )

    ground_truths = defaultdict(lambda: defaultdict(list))
    predictions = defaultdict(lambda: defaultdict(list))
    source_db, target_db = run_specs["source_db"], run_specs["target_db"]

    G = nx.MultiGraph()
    reverse_source_alias, reverse_target_alias = defaultdict(list), defaultdict(list)
    source_alias, target_alias = dict(), dict()
    for item in OntologySchemaRewrite.objects(
        database=source_db, llm_model=rewrite_llm, linked_table__ne=None, linked_column__ne=None
    ):
        source_alias[f"{item.table}.{item.column}"] = f"{item.linked_table}.{item.linked_column}"
        reverse_source_alias[f"{item.linked_table}.{item.linked_column}"].append(f"{item.table}.{item.column}")
        G.add_edge(f"{item.table}.{item.column}", f"{item.linked_table}.{item.linked_column}")

    for item in OntologySchemaRewrite.objects(
        database=target_db, llm_model=rewrite_llm, linked_table__ne=None, linked_column__ne=None
    ):
        target_alias[f"{item.table}.{item.column}"] = f"{item.linked_table}.{item.linked_column}"
        reverse_target_alias[f"{item.linked_table}.{item.linked_column}"].append(f"{item.table}.{item.column}")
        G.add_edge(f"{item.table}.{item.column}", f"{item.linked_table}.{item.linked_column}")

    rewrite_queryset = OntologySchemaRewrite.objects(database__in=[source_db, target_db], llm_model=rewrite_llm)
    for item in rewrite_queryset:
        G.add_node(f"{item.table}.{item.column}")
        if item.linked_column:
            G.add_edge(f"{item.table}.{item.column}", f"{item.linked_table}.{item.linked_column}")

    for item in OntologySchemaRewrite.objects(database=source_db, llm_model=rewrite_llm):
        ground_truths[item.table][item.column] = []

    for result in OntologyAlignmentExperimentResult.get_llm_result(run_specs=run_specs):
        json_result = result.json_result
        duration += result.duration or 0
        prompt_token += result.prompt_tokens or 0
        completion_token += result.completion_tokens or 0
        for source, targets in json_result.items():
            if source.find(".") == -1:
                # primary key
                source_table = source
                source_record = OntologySchemaRewrite.objects(
                    table=source_table, llm_model=run_specs["rewrite_llm"], database=source_db, is_primary_key=True
                ).first()
                if not source_record:
                    raise ValueError(f"{source_table=} primary key not found   ")
                source_column = source_record.column
            else:
                source_table, source_column = source.split(".")
            for target_entry in targets:
                if not target_entry:
                    continue
                if isinstance(target_entry, str):
                    target = target_entry
                else:
                    if "mapping" not in target_entry:
                        target_entry
                    target = target_entry["mapping"]
                if target.find(".") == -1:
                    # primary key
                    record = OntologySchemaRewrite.objects(
                        table=target, llm_model=run_specs["rewrite_llm"], database=target_db, is_primary_key=True
                    ).first()
                    if not record:
                        continue
                    target_column = record.column
                    target = f"{target}.{target_column}"
                G.add_edge(f"{source_table}.{source_column}", target)
                predictions[source_table][source_column].append(target)

    dataset = f"{source_db}-{target_db}"
    for line in OntologyAlignmentGroundTruth.objects(dataset__in=[dataset, dataset.lower()]).first().data:
        source_table = line["source_table"]
        source_column = line["source_column"]
        target_table = line["target_table"]
        target_column = line["target_column"]
        if source_table == "NA":
            continue
        source_entry = rewrite_queryset.filter(
            original_table__in=[source_table, source_table.lower()],
            original_column__in=[source_column, source_column.lower()],
        ).first()
        target_entry = rewrite_queryset.filter(
            original_table__in=[target_table, target_table.lower()],
            original_column__in=[target_column, target_column.lower()],
        ).first()
        if not (source_entry):
            source_entry
            raise ValueError(f"Source entry not found: {source_table}.{source_column}")
        source = f"{source_entry.table}.{source_entry.column}"
        if target_entry:
            target = f"{target_entry.table}.{target_entry.column}"
            ground_truths[source.split(".")[0]][source.split(".")[1]].append(target)

    predictions = json.loads(json.dumps(predictions))
    TP, FP, FN, TN = 0, 0, 0, 0
    for source_table in ground_truths.keys():
        for source_column in ground_truths[source_table].keys():
            predict_targets = set(predictions.get(source_table, {}).get(source_column, []))
            ground_truth_targets = set(ground_truths.get(source_table, {}).get(source_column, []))
            tp, fp, fn = 0, 0, 0
            for ground_truth_target in ground_truth_targets:
                connected = nx.has_path(G, f"{source_table}.{source_column}", ground_truth_target)
                if connected:
                    tp += 1
                else:
                    fn += 1

            for predict_target in predict_targets:
                connected = True
                for ground_truth_target in ground_truth_targets:
                    if ground_truth_target == "detailed_visit_information.visit_occurrence_identifier":
                        ground_truth_target
                    connected = nx.has_path(G, predict_target, ground_truth_target)
                if not connected:
                    fp += 1

            # tp = len(predict_targets & ground_truth_targets)
            # fp = len(predict_targets - ground_truth_targets)
            # fn = len(ground_truth_targets - predict_targets)
            print(
                f"\n\n{source_table}.{source_column}",
                "==>",
                f"\nGround Truth:{ground_truth_targets}",
                f"\nPredictions: {predict_targets}",
                f"{tp=} {fp=} {fn=}",
            )
            TP += tp
            FP += fp
            FN += fn

    precision, recall, f1_score = calculate_metrics(TP, FP, FN)
    print(f"{TP=} {FP=} {FN=} {precision=} {recall=} {f1_score=}")

    print(
        f"{dataset=}, {duration=}, {prompt_token=}, {completion_token=} total_token={prompt_token + completion_token}"
    )
