import json
import pprint
from collections import defaultdict


def calculate_metrics(TP, FP, FN):
    try:
        precision = TP / (TP + FP)
        recall = TP / (TP + FN)
        f1_score = 2 * (precision * recall) / (precision + recall)
        return round(precision, 2), round(recall, 2), round(f1_score, 2)
    except ZeroDivisionError:
        return 0, 0, 0


def print_result_one_to_many(run_specs, get_predictions_func):
    duration, prompt_token, completion_token = 0, 0, 0
    import networkx as nx

    rewrite_llm = run_specs["rewrite_llm"]
    from llm_ontology_alignment.data_models.experiment_models import (
        OntologyAlignmentGroundTruth,
        OntologySchemaRewrite,
    )

    ground_truths = defaultdict(lambda: defaultdict(list))
    source_db, target_db = run_specs["source_db"], run_specs["target_db"]

    G = nx.MultiGraph()
    reverse_source_alias, reverse_target_alias = defaultdict(list), defaultdict(list)
    source_alias, target_alias = dict(), dict()
    schema_rewrites = dict()
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
        schema_rewrites[f"{item.table}.{item.column}"] = f"{item.original_table}.{item.original_column}"
        if item.linked_column:
            G.add_edge(f"{item.table}.{item.column}", f"{item.linked_table}.{item.linked_column}")

    for item in OntologySchemaRewrite.objects(database=target_db, llm_model=rewrite_llm):
        ground_truths[item.table][item.column] = []

    dataset = f"{source_db}-{target_db}"
    for source, targets in (
        OntologyAlignmentGroundTruth.objects(dataset__in=[dataset, dataset.lower()]).first().data.items()
    ):
        target_table, target_column = source.split(".")
        source_entry = rewrite_queryset.filter(
            original_table__in=[target_table, target_table.lower()],
            original_column__in=[target_column, target_column.lower()],
        ).first()
        if not (source_entry):
            raise ValueError(f"Source entry in ground truth data not found: {target_table}.{target_column}")

        for target in targets:
            target_table, target_column = target.split(".")
            target_entry = rewrite_queryset.filter(
                original_table__in=[target_table, target_table.lower()],
                original_column__in=[target_column, target_column.lower()],
            ).first()

            if target_entry:
                ground_truths[target_entry.table][target_entry.column].append(
                    f"{source_entry.table}.{source_entry.column}"
                )
            else:
                raise ValueError(f"Target entry in ground truth data not found: {target_table}.{target_column}")
    predictions, duration, prompt_token, completion_token = get_predictions_func(run_specs, G)
    predictions = json.loads(json.dumps(predictions))
    TP, FP, FN, TN = 0, 0, 0, 0
    for target_table in ground_truths.keys():
        for target_column in ground_truths[target_table].keys():
            predict_sources = set(predictions.get(target_table, {}).get(target_column, []))
            ground_truth_sources = set(ground_truths.get(target_table, {}).get(target_column, []))
            tp, fp, fn = 0, 0, 0

            if not predict_sources:
                if target_alias.get(f"{target_table}.{target_column}"):
                    alias = target_alias[f"{target_table}.{target_column}"]
                    predict_sources.update(predictions.get(alias.split(".")[0], {}).get(alias.split(".")[1], []))

                for alias in reverse_target_alias.get(f"{target_table}.{target_column}", []):
                    predict_sources.update(predictions.get(alias.split(".")[0], {}).get(alias.split(".")[1], []))

            for ground_truth_source in ground_truth_sources:
                connected = False
                for predict_source in predict_sources:
                    connected = nx.has_path(G, predict_source, ground_truth_source)
                    if connected:
                        break
                if connected:
                    tp += 1
                else:
                    fn += 1

            for predict_source in predict_sources:
                connected = False
                for ground_truth_source in ground_truth_sources:
                    connected = nx.has_path(G, predict_source, ground_truth_source) | nx.has_path(
                        G, predict_source, f"{target_table}.{target_column}"
                    )
                    if connected:
                        break
                if not connected:
                    fp += 1

            # tp = len(ground_truth_sources & predict_sources)
            # fp = len(predict_sources - ground_truth_sources)
            # fn = len(ground_truth_sources - predict_sources)
            if fp + fn > 0:
                print(
                    schema_rewrites[f"{target_table}.{target_column}"],
                    "==>",
                    f"\nGround Truth:{[schema_rewrites[item] for item in ground_truth_sources]}",
                    f"\nPredictions: {[schema_rewrites[item] for item in predict_sources]}",
                    f"\nMissed: {[schema_rewrites[item] for item in ground_truth_sources - predict_sources]}",
                    f"\nExtra: {[schema_rewrites[item] for item in predict_sources - ground_truth_sources]}",
                    f"{tp=} {fp=} {fn=}\n\n",
                )
            TP += tp
            FP += fp
            FN += fn

    precision, recall, f1_score = calculate_metrics(TP, FP, FN)
    print(f"{TP=} {FP=} {FN=} {precision=} {recall=} {f1_score=}")

    print(
        f"{dataset=}, {duration=}, {prompt_token=}, {completion_token=} total_token={prompt_token + completion_token}"
    )
    print(run_specs)


def print_table_mapping_result(run_specs):
    source_db, target_db = run_specs["source_db"], run_specs["target_db"]
    dataset = f"{source_db}-{target_db}"
    from llm_ontology_alignment.data_models.experiment_models import (
        OntologyAlignmentGroundTruth,
        OntologyAlignmentExperimentResult,
    )
    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite

    source_table_description = OntologySchemaRewrite.get_database_description(
        source_db, "original", include_foreign_keys=True
    )
    target_table_description = OntologySchemaRewrite.get_database_description(
        target_db, "original", include_foreign_keys=True
    )

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
        source_table, source_column = source.split(".")
        source_column_data = source_table_description[source_table]["columns"][source_column]
        if source_column_data.get("linked_entry"):
            source_table, source_column = source_column_data["linked_entry"].split(".")
        for target in targets:
            target_table, target_column = target.split(".")
            target_column_data = target_table_description[target_table]["columns"][target_column]
            if target_column_data.get("linked_entry"):
                target_table, target_column = target_column_data["linked_entry"].split(".")
            ground_truth_table_mapping[source_table_name_mapping[source_table]].add(
                target_table_name_mapping[target_table]
            )
    pprint.pp(ground_truth_table_mapping)
    for line in OntologyAlignmentExperimentResult.objects(
        run_id_prefix=json.dumps(run_specs), dataset=dataset, sub_run_id__startswith="primary_key_mapping"
    ):
        json_result = line.json_result
        for source, predicted_target_tables in json_result.items():
            if not predicted_target_tables:
                continue

            if not isinstance(predicted_target_tables[0], str):
                predicted_target_tables = [item["target_table"] for item in predicted_target_tables]
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

            # if fn and fn == len(ground_truth_tables):
            #     line.delete()
            # if fn:
            #     line.delete()
