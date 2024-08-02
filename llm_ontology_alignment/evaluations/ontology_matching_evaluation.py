import json
import pprint
from collections import defaultdict

from llm_ontology_alignment.utils import calculate_f1

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


def calculate_result_one_to_many(run_specs, get_predictions_func):
    import networkx as nx

    run_specs = {key: run_specs[key] for key in sorted(run_specs.keys())}

    rewrite_llm = run_specs["rewrite_llm"]

    G, ground_truths, reverse_target_alias, schema_rewrites, target_alias = load_ground_truth(
        rewrite_llm, run_specs["source_db"], run_specs["target_db"]
    )
    predictions = get_predictions_func(run_specs, G)
    for u, v, key, data in G.edges(data=True, keys=True):
        assert data.get("edge_type"), (u, v, key, data)
    predictions = json.loads(json.dumps(predictions))
    TP, FP, FN = 0, 0, 0
    for target_table in ground_truths.keys():
        for target_column in ground_truths[target_table].keys():
            predict_sources = set(predictions.get(target_table, {}).get(target_column, []))
            ground_truth_sources = set(ground_truths.get(target_table, {}).get(target_column, []))
            connected_nodes = nx.node_connected_component(G, f"{target_table}.{target_column}")
            connected_sources = [node for node in connected_nodes if G.nodes[node].get("matching_role") == "source"]
            # if len(connected_sources) != len(ground_truth_sources):
            #     edge_type = G.edges[f"{target_table}.{target_column}", connected_sources[0], 0].get("edge_type")
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
                    if connected:
                        continue
                    connected = nx.has_path(G, predict_source, ground_truth_source)
                if connected:
                    tp += 1
                else:
                    fn += 1

            for predict_source in predict_sources:
                if predict_source not in connected_sources:
                    fp += 1

            # tp = len(ground_truth_sources & predict_sources)
            # fp = len(predict_sources - ground_truth_sources)
            # fn = len(ground_truth_sources - predict_sources)
            if fp + fn > 0:
                try:
                    print(
                        schema_rewrites[f"{target_table}.{target_column}"],
                        "==>",
                        f"\nLabelled Ground Truth:{[schema_rewrites[item] for item in ground_truth_sources]}",
                        f"\nConnected Sources: {[schema_rewrites[item] for item in connected_sources]}",
                        f"\nPredictions: {[schema_rewrites[item] for item in predict_sources]}",
                        f"\nMissed: {[schema_rewrites[item] for item in ground_truth_sources - predict_sources]}",
                        f"\nExtra: {[schema_rewrites[item] for item in predict_sources - ground_truth_sources]}",
                        f"{tp=} {fp=} {fn=}\n\n",
                    )
                    if schema_rewrites[f"{target_table}.{target_column}"] == "carrierclaims.clm_id":
                        pprint.pp(predictions)
                except Exception as e:
                    pprint.pp(run_specs)
                    raise e
            TP += tp
            FP += fp
            FN += fn

    precision, recall, f1_score = calculate_f1(TP, FP, FN)
    print(f"{TP=} {FP=} {FN=} {precision=} {recall=} {f1_score=}")
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
        "version": 2,
    }
    if run_specs["strategy"] in ["rematch", "schema_understanding", "schema_understanding_no_reasoning"]:
        token_costs = calculate_token_cost(run_specs)
        result["matching_llm"] = run_specs["matching_llm"]

        result.update(token_costs)
    OntologyMatchingEvaluationReport.upsert(result)


def load_ground_truth(rewrite_llm, source_db, target_db):
    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite
    import networkx as nx
    from llm_ontology_alignment.data_models.experiment_models import OntologyAlignmentGroundTruth

    ground_truths = defaultdict(lambda: defaultdict(list))
    source_db, target_db = source_db, target_db
    G = nx.MultiGraph()
    reverse_source_alias, reverse_target_alias = defaultdict(list), defaultdict(list)
    source_alias, target_alias = dict(), dict()
    schema_rewrites = dict()
    for item in OntologySchemaRewrite.objects(
        database=source_db, llm_model=rewrite_llm, linked_table__ne=None, linked_column__ne=None
    ):
        source_alias[f"{item.table}.{item.column}"] = f"{item.linked_table}.{item.linked_column}"
        reverse_source_alias[f"{item.linked_table}.{item.linked_column}"].append(f"{item.table}.{item.column}")
        # G.add_edge(f"{item.table}.{item.column}", f"{item.linked_table}.{item.linked_column}", edge_type='foreign_key')

    for item in OntologySchemaRewrite.objects(
        database=target_db, llm_model=rewrite_llm, linked_table__ne=None, linked_column__ne=None
    ):
        target_alias[f"{item.table}.{item.column}"] = f"{item.linked_table}.{item.linked_column}"
        reverse_target_alias[f"{item.linked_table}.{item.linked_column}"].append(f"{item.table}.{item.column}")
        # G.add_edge(f"{item.table}.{item.column}", f"{item.linked_table}.{item.linked_column}", edge_type="foreign_key")

    rewrite_queryset = OntologySchemaRewrite.objects(database__in=[source_db, target_db], llm_model=rewrite_llm)
    for item in rewrite_queryset:
        G.add_node(f"{item.table}.{item.column}", matching_role="source" if item.database == source_db else "target")
        schema_rewrites[f"{item.table}.{item.column}"] = f"{item.original_table}.{item.original_column}"
        if item.linked_column:
            G.add_edge(
                f"{item.table}.{item.column}",
                f"{item.linked_table}.{item.linked_column}",
                key=0,
                edge_type="foreign_key",
            )

    for item in OntologySchemaRewrite.objects(database=target_db, llm_model=rewrite_llm):
        ground_truths[item.table][item.column] = []

    for source, targets in (
        OntologyAlignmentGroundTruth.objects(dataset=f"{source_db}-{target_db}").first().data.items()
    ):
        source_table, source_column = source.split(".")
        source_entry = rewrite_queryset.filter(
            original_table=source_table,
            original_column=source_column,
        ).first()
        assert source_entry, source

        for target in targets:
            target_table, target_column = target.split(".")
            target_entry = rewrite_queryset.filter(
                original_table=target_table,
                original_column=target_column,
            ).first()
            assert target_entry, target
            ground_truths[target_entry.table][target_entry.column].append(f"{source_entry.table}.{source_entry.column}")
            if source_entry.column == "date_of_birth":
                print(f"{source_entry.table}.{source_entry.column} ==>", f"{target_entry.table}.{target_entry.column}")
            G.add_edge(
                f"{source_entry.table}.{source_entry.column}",
                f"{target_entry.table}.{target_entry.column}",
                key=0,
                edge_type="ground_truth",
            )

    return G, ground_truths, reverse_target_alias, schema_rewrites, target_alias


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


def get_evaluation_result_table(experiments):
    # "imdb-sakila", "omop-cms", "mimic_iii-omop", "cprd_aurum-omop", "cprd_gold-omop"
    result = get_full_results()
    strategy_mappings = [
        ("coma Rewrite: original", "Coma"),
        ("similarity_flooding Rewrite: original", "Similarity Flooding"),
        ("unicorn Rewrite: original", "Unicorn"),
        ("rematch Rewrite: original Matching: gpt-3.5-turbo", "Rematch (gpt-3.5)"),
        ("rematch Rewrite: original Matching: gpt-4o", "Rematch (gpt-4o)"),
        (
            "schema_understanding_no_reasoning Rewrite: gpt-3.5-turbo Matching: gpt-3.5-turbo",
            "Schema Understanding (gpt-3.5)",
        ),
        # (
        # '{"strategy": "schema_understanding_no_reasoning", "rewrite_llm": "gpt-3.5-turbo", "matching_llm": "gpt-3.5-turbo"}',
        # "Schema Understanding (rewrite:gpt-4o/matching:gpt-3.5)"),
        # ('{"strategy": "schema_understanding_no_reasoning", "rewrite_llm": "gpt-3.5-turbo", "matching_llm": "gpt-4o"}',
        #  "Schema Understanding (rewrite:gpt-3.5/matching:gpt-4o)"),
        (
            "schema_understanding_no_reasoning Rewrite: gpt-4o Matching: gpt-4o",
            "Schema Understanding (gpt-4o)",
        ),
        # (
        #     "schema_understanding_no_reasoning Rewrite: gpt-3.5-turbo Matching: gpt-4o",
        #     "Schema Understanding (rewrite:gpt-3.5/matching:gpt-4o)",
        # ),
    ]
    rows = []
    for config, strategy in strategy_mappings:
        row = [strategy]
        for dataset in experiments:
            try:
                row.append(result[config][dataset].precision)
                row.append(result[config][dataset].recall)
                row.append(result[config][dataset].f1_score)
            except Exception as e:
                raise e
        rows.append(row)

    # bold best performance and underline second best performance for each column
    for i in range(1, len(rows[0])):
        col = [row[i] for row in rows[1:]]
        best = max(col)
        second_best = sorted(col)[-2]
        for row in rows:
            if row[i] == best:
                row[i] = f"\\textbf{{{f'{row[i]:.3f}'}}}"
            if row[i] == second_best:
                row[i] = f"\\underline{{{f'{row[i]:.3f}'}}}"

    return rows


def all_strategy_f1():
    # "imdb-sakila", "omop-cms", "mimic_iii-omop", "cprd_aurum-omop", "cprd_gold-omop"
    result = get_full_results()
    test_cases = ["IMDBSakila", "CprdAurumOMOP", "CprdGoldOMOP", "OMOPCMS", "MIMICOMOP"]
    rows = []
    header = ["strategy"]
    for test_case in test_cases:
        header += [f"{test_case}Precision", f"{test_case}Recall", f"{test_case}F"]
    rows.append(header)
    for strategy in result:
        row = [strategy.replace("_", " ").title()]
        for dataset in ["imdb-sakila", "cprd_aurum-omop", "cprd_gold-omop", "omop-cms", "mimic_iii-omop"]:
            try:
                row.append(result[strategy][dataset].precision)
                row.append(result[strategy][dataset].recall)
                row.append(result[strategy][dataset].f1_score)
            except Exception as e:
                e
        rows.append(row)
    save_to_csv(rows, "evaluation_result_all_f1.csv")


def single_table_f1_score():
    # "imdb-sakila", "omop-cms", "mimic_iii-omop", "cprd_aurum-omop", "cprd_gold-omop"
    from llm_ontology_alignment.data_models.experiment_models import OntologyMatchingEvaluationReport

    rows = []
    rows.append(["strategy", "prospect-horizontal", "wikidata-musicians", "wikidata-musicians2", "wikidata-musicians3"])
    for strategy in OntologyMatchingEvaluationReport.objects(source_database="prospect").distinct("strategy"):
        row = [strategy]
        for dataset in ["prospect-horizontal", "wikidata-musicians", "wikidata-musicians2", "wikidata-musicians3"]:
            try:
                record = OntologyMatchingEvaluationReport.objects(
                    source_database=dataset.split("-")[0], target_database=dataset.split("-")[1], strategy=strategy
                ).first()
                row.append(record.f1_score)
            except Exception as e:
                e
        rows.append(row)
    save_to_csv(rows, "evaluation_single_table_f1.csv")


def save_to_csv(rows, filename):
    import os

    script_dir = os.path.dirname(__file__)
    file_path = os.path.join(script_dir, "..", "..", "dataset/match_result", filename)
    with open(file_path, "w") as f:
        for row in rows:
            f.write(",".join([str(item) for item in row]) + "\n")


def get_full_results():
    from llm_ontology_alignment.data_models.experiment_models import OntologyMatchingEvaluationReport

    result = defaultdict(dict)
    for strategy in [
        "coma",
        "similarity_flooding",
        "cupid",
        "unicorn",
        "rematch",
        "schema_understanding",
        "schema_understanding_no_reasoning",
    ]:
        for dataset in ["imdb-sakila", "cprd_aurum-omop", "cprd_gold-omop", "omop-cms", "mimic_iii-omop"]:
            source_db, target_db = dataset.split("-")
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

                key = f"{record.strategy} Rewrite: {record.rewrite_llm}"

                if record.matching_llm:
                    key += f" Matching: {record.matching_llm}"

                # key = " ".join([item for item in [record.strategy, record.rewrite_llm, record.matching_llm] if item])
                result[key][dataset] = record
    return result


if __name__ == "__main__":
    get_evaluation_result_table()


def run_schema_matching_evaluation(run_specs, refresh_rewrite=False, refresh_existing_result=False):
    from llm_ontology_alignment.alignment_strategies.rematch import (
        get_predictions as rematch_get_predictions,
        run_matching as rematch_run_matching,
    )
    from llm_ontology_alignment.alignment_strategies.schema_understanding import (
        get_predictions as schema_understanding_get_predictions,
        run_matching as schema_understanding_run_matching,
    )
    from llm_ontology_alignment.alignment_strategies.coma_alignment import get_predictions as coma_get_predictions
    from llm_ontology_alignment.alignment_strategies.valentine_alignment import (
        get_predictions as valentine_get_predictions,
        run_matching as valentine_run_matching,
    )
    from llm_ontology_alignment.data_models.experiment_models import OntologyAlignmentExperimentResult
    from llm_ontology_alignment.data_processors.load_data import update_rewrite_schema_constraints
    from llm_ontology_alignment.data_processors.rewrite_db_schema import rewrite_db_columns

    run_match_func_map = {
        "rematch": rematch_run_matching,
        "schema_understanding_no_reasoning": schema_understanding_run_matching,
        "schema_understanding": schema_understanding_run_matching,
        "coma": valentine_run_matching,
        "similarity_flooding": valentine_run_matching,
        "cupid": valentine_run_matching,
    }
    get_prediction_func_map = {
        "rematch": rematch_get_predictions,
        "schema_understanding_no_reasoning": schema_understanding_get_predictions,
        "schema_understanding": schema_understanding_get_predictions,
        "coma": coma_get_predictions,
        "similarity_flooding": valentine_get_predictions,
        "cupid": valentine_get_predictions,
    }

    if refresh_rewrite:
        rewrite_db_columns(run_specs)
        update_rewrite_schema_constraints(run_specs["source_db"])
        update_rewrite_schema_constraints(run_specs["target_db"])

    if refresh_existing_result:
        OntologyAlignmentExperimentResult.objects(run_id_prefix=json.dumps(run_specs)).delete()
        run_match_func_map[run_specs["strategy"]](run_specs)

    run_id_prefix = json.dumps(run_specs)
    print("\n", run_id_prefix)
    # print_table_mapping_result(run_specs)
    calculate_result_one_to_many(run_specs, get_predictions_func=get_prediction_func_map[run_specs["strategy"]])
