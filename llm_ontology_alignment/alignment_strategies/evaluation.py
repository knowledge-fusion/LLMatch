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

    prediction_results = OntologyAlignmentExperimentResult.get_llm_result(run_specs=run_specs)
    assert prediction_results
    for result in prediction_results:
        if result.sub_run_id.find("primary_key_mapping") > -1:
            continue
        json_result = result.json_result
        duration += result.duration or 0
        prompt_token += result.prompt_tokens or 0
        completion_token += result.completion_tokens or 0
        for source, targets in json_result.items():
            source_table, source_column = source.split(".")
            source_entry = rewrite_queryset.filter(
                table__in=[source_table, source_table.lower()],
                column__in=[source_column, source_column.lower()],
            ).first()
            if not source_entry:
                continue
            for target in targets:
                if isinstance(target, dict):
                    target = target["mapping"]
                if target.count(".") > 1:
                    tokens = target.split(".")
                    target = ".".join([tokens[-2], tokens[-1]])
                if target.find(".") == -1:
                    print(f"Invalid target: {target}")
                    continue
                target_entry = rewrite_queryset.filter(
                    table__in=[target.split(".")[0], target.split(".")[0].lower()],
                    column__in=[target.split(".")[1], target.split(".")[1].lower()],
                ).first()
                if target_entry:
                    G.add_edge(f"{source_table}.{source_column}", target)
                    predictions[source_table][source_column].append(target)

    dataset = f"{source_db}-{target_db}"
    for source, targets in (
        OntologyAlignmentGroundTruth.objects(dataset__in=[dataset, dataset.lower()]).first().data.items()
    ):
        source_table, source_column = source.split(".")
        source_entry = rewrite_queryset.filter(
            original_table__in=[source_table, source_table.lower()],
            original_column__in=[source_column, source_column.lower()],
        ).first()
        if not (source_entry):
            raise ValueError(f"Source entry in ground truth data not found: {source_table}.{source_column}")

        for target in targets:
            target_table, target_column = target.split(".")
            target_entry = rewrite_queryset.filter(
                original_table__in=[target_table, target_table.lower()],
                original_column__in=[target_column, target_column.lower()],
            ).first()

            if target_entry:
                ground_truths[source_entry.table][source_entry.column].append(
                    f"{target_entry.table}.{target_entry.column}"
                )

    predictions = json.loads(json.dumps(predictions))
    TP, FP, FN, TN = 0, 0, 0, 0
    for source_table in ground_truths.keys():
        for source_column in ground_truths[source_table].keys():
            predict_targets = set(predictions.get(source_table, {}).get(source_column, []))
            ground_truth_targets = set(ground_truths.get(source_table, {}).get(source_column, []))
            tp, fp, fn = 0, 0, 0
            for ground_truth_target in ground_truth_targets:
                connected = False
                for predict_target in predict_targets:
                    connected = nx.has_path(G, predict_target, ground_truth_target)
                    if connected:
                        break
                if connected:
                    tp += 1
                else:
                    fn += 1

            for predict_target in predict_targets:
                connected = False
                for ground_truth_target in ground_truth_targets:
                    if ground_truth_target == "detailed_visit_information.visit_occurrence_identifier":
                        ground_truth_target
                    connected = nx.has_path(G, predict_target, ground_truth_target) | nx.has_path(
                        G, predict_target, f"{source_table}.{source_column}"
                    )
                    if connected:
                        break
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


def print_table_mapping_result(run_specs):
    source_db, target_db = run_specs["source_db"], run_specs["target_db"]
    dataset = f"{source_db}-{target_db}"
    from llm_ontology_alignment.data_models.experiment_models import (
        OntologyAlignmentGroundTruth,
        OntologyAlignmentExperimentResult,
    )
    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite

    source_table_name_mapping = dict()
    target_table_name_mapping = dict()
    for item in OntologySchemaRewrite.objects(database__in=[source_db, target_db], llm_model=run_specs["rewrite_llm"]):
        if item.database == source_db:
            source_table_name_mapping[item.original_table] = item.table
        if item.database == target_db:
            target_table_name_mapping[item.original_table] = item.table

    ground_truth_table_mapping = defaultdict(set)
    for source, targets in (
        OntologyAlignmentGroundTruth.objects(dataset__in=[dataset, dataset.lower()]).first().data.items()
    ):
        source_table, _ = source.split(".")
        for target in targets:
            target_table, _ = target.split(".")
            ground_truth_table_mapping[source_table_name_mapping[source_table]].add(
                target_table_name_mapping[target_table]
            )

    for line in OntologyAlignmentExperimentResult.objects(
        run_id_prefix=json.dumps(run_specs), dataset=dataset, sub_run_id__startswith="primary_key_mapping"
    ):
        json_result = line.json_result
        for source, predicted_target_tables in json_result.items():
            ground_truth_tables = ground_truth_table_mapping.get(source, [])
            tp = len(set(ground_truth_tables) & set(predicted_target_tables))
            fp = len(set(predicted_target_tables) - set(ground_truth_tables))
            fn = len(set(ground_truth_tables) - set(predicted_target_tables))
            if fn:
                print(
                    f"\n\n{source}",
                    "==>",
                    f"\nGround Truth:{ground_truth_tables}",
                    f"\nPredictions: {predicted_target_tables}",
                )
                print(f"Missed tables: {set(ground_truth_tables) - set(predicted_target_tables)}")
                # for missed_table in set(ground_truth_tables) - set(predicted_target_tables):
                #     print(
                #         "Missed table:",
                #         json.dumps(
                #             OntologySchemaRewrite.get_table_columns_description(
                #                 table=missed_table,
                #                 llm_model=run_specs["rewrite_llm"],
                #                 database=target_db,
                #                 include_foreign_keys=True,
                #             ),
                #             indent=2,
                #         ),
                #     )
                # for predicted_table in set(predicted_target_tables) - set(ground_truth_tables):
                #     print(
                #         "Extra table:",
                #         json.dumps(
                #             OntologySchemaRewrite.get_table_columns_description(
                #                 table=predicted_table,
                #                 llm_model=run_specs["rewrite_llm"],
                #                 database=target_db,
                #                 include_foreign_keys=True,
                #             ),
                #             indent=2,
                #         ),
                #     )
            # if fn:
            #     line.delete()
