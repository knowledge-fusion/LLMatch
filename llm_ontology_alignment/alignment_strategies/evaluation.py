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


prompt_token_cost = {
    "gpt-3.5-turbo": 0.5,
    "gpt-4o": 5,
    "gpt-4o-mini": 0.15,
    "original": 0,
}

completion_token_cost = {
    "gpt-3.5-turbo": 0.5,
    "gpt-4o": 15,
    "gpt-4o-mini": 0.6,
    "original": 0,
}


def calculate_rewrite_cost(database, rewrite_model):
    from llm_ontology_alignment.data_models.experiment_models import CostAnalysis

    assert rewrite_model in prompt_token_cost
    if rewrite_model == "original":
        return 0, 0, 0
    input_token, output_token, duration = 0, 0, 0
    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite

    queryset = CostAnalysis.objects(model=rewrite_model, run_specs__operation="rewrite_db_schema")
    for new_table_name in OntologySchemaRewrite.objects(database=database, llm_model=rewrite_model).distinct("table"):
        candidates = queryset.filter(text_result__icontains=new_table_name, json_result__ne=None).order_by(
            "-updated_at"
        )
        if not candidates:
            print("No candidates found for rewrite {}".format(new_table_name))
        item = candidates.first()
        input_token += item.prompt_tokens
        output_token += item.completion_tokens
        duration += item.duration

    return input_token, output_token, duration


def calculate_token_cost(run_specs):
    rewrite_prompt_tokens, rewrite_completion_tokens, rewrite_duration = 0, 0, 0
    # rewrite cost
    for database in [run_specs["source_db"], run_specs["target_db"]]:
        p, c, d = calculate_rewrite_cost(database, run_specs["rewrite_llm"])
        rewrite_prompt_tokens += p
        rewrite_completion_tokens += c
        rewrite_duration += d

    # matching cost
    from llm_ontology_alignment.data_models.experiment_models import OntologyAlignmentExperimentResult

    queryset = OntologyAlignmentExperimentResult.objects(run_id_prefix=json.dumps(run_specs))
    assert queryset
    matching_prompt_tokens, matching_completion_tokens, matching_duration = 0, 0, 0
    for item in queryset:
        matching_prompt_tokens += item.prompt_tokens or 0
        matching_completion_tokens += item.completion_tokens or 0
        matching_duration += item.duration or 0
    total_cost = round(
        (
            rewrite_prompt_tokens * prompt_token_cost[run_specs["rewrite_llm"]]
            + rewrite_completion_tokens * completion_token_cost[run_specs["rewrite_llm"]]
            + matching_prompt_tokens * prompt_token_cost[run_specs["matching_llm"]]
            + matching_completion_tokens * completion_token_cost[run_specs["matching_llm"]]
        )
        / 1000000,
        3,
    )
    res = {
        "matching_duration": matching_duration,
        "matching_prompt_tokens": matching_prompt_tokens,
        "matching_completion_tokens": matching_completion_tokens,
        "rewrite_duration": rewrite_duration,
        "rewrite_prompt_tokens": rewrite_prompt_tokens,
        "rewrite_completion_tokens": rewrite_completion_tokens,
        "total_model_cost": total_cost,
        "total_duration": rewrite_duration + matching_duration,
    }
    return res


def print_result_one_to_many(run_specs, get_predictions_func):
    import networkx as nx

    run_specs = {key: run_specs[key] for key in sorted(run_specs.keys())}

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
    predictions = get_predictions_func(run_specs, G)
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

    print(f"{dataset=}")
    print(run_specs)
    from llm_ontology_alignment.data_models.experiment_models import OntologyMatchingEvaluationReport

    result = {
        "source_database": run_specs["source_db"],
        "target_database": run_specs["target_db"],
        "rewrite_llm": run_specs["rewrite_llm"],
        "strategy": run_specs["strategy"],
        "precision": precision,
        "recall": recall,
        "f1_score": f1_score,
    }
    if run_specs["strategy"] != "coma":
        token_costs = calculate_token_cost(run_specs)
        result["matching_llm"] = run_specs["matching_llm"]

        result.update(token_costs)
    OntologyMatchingEvaluationReport.upsert(result)


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


def print_all_result():
    from llm_ontology_alignment.data_models.experiment_models import OntologyMatchingEvaluationReport

    # "imdb-sakila", "omop-cms", "mimic_iii-omop", "cprd_aurum-omop", "cprd_gold-omop"
    for dataset in ["cprd_aurum-omop"]:
        source_db, target_db = dataset.split("-")
        for strategy in ["coma", "rematch", "schema_understanding"]:
            for record in OntologyMatchingEvaluationReport.objects(
                **{
                    "source_database": source_db,
                    "target_database": target_db,
                    "strategy": strategy,
                }
            ):
                print(
                    f"\n{record.source_database}-{record.target_database},  {record.strategy}, {record.matching_llm=},{record.rewrite_llm=},{record.precision}, {record.recall}, {record.f1_score}, {record.total_duration}\t {record.total_model_cost}"
                )
