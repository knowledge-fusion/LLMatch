import json
from collections import defaultdict

from schema_match.evaluations.latex_report.full_experiment_f1_score import (
    format_max_value,
)
from schema_match.constants import EXPERIMENTS, SINGLE_TABLE_EXPERIMENTS
from schema_match.utils import get_cache, calculate_metrics

prompt_token_cost = {
    "gpt-3.5-turbo": 0.5,
    "gpt-4o": 5,
    "gpt-4o-mini": 0.15,
    "gpt-4": 30,
    "original": 0,
    "deepinfra/meta-llama/Meta-Llama-3.1-8B-Instruct": 0.06,
    "deepinfra/meta-llama/Meta-Llama-3.1-70B-Instruct": 0.52,
    "deepinfra/meta-llama/Meta-Llama-3.1-405B-Instruct": 2.7,
}

completion_token_cost = {
    "gpt-3.5-turbo": 0.5,
    "gpt-4o": 15,
    "gpt-4": 60,
    "gpt-4o-mini": 0.6,
    "original": 0,
    "deepinfra/meta-llama/Meta-Llama-3.1-8B-Instruct": 0.06,
    "deepinfra/meta-llama/Meta-Llama-3.1-70B-Instruct": 0.75,
    "deepinfra/meta-llama/Meta-Llama-3.1-405B-Instruct": 2.7,
}


def calculate_rewrite_cost(database, rewrite_model):
    from schema_match.data_models.experiment_models import CostAnalysis

    assert rewrite_model in prompt_token_cost
    if rewrite_model == "original":
        return 0, 0, 0
    input_token, output_token, duration = 0, 0, 0
    from schema_match.data_models.experiment_models import OntologySchemaRewrite

    queryset = CostAnalysis.objects(
        model=rewrite_model, run_specs__operation="rewrite_db_schema"
    )
    for new_table_name in OntologySchemaRewrite.objects(
        database=database, llm_model=rewrite_model
    ).distinct("table"):
        candidates = queryset.filter(
            text_result__icontains=new_table_name, json_result__ne=None
        ).order_by("-updated_at")
        if not candidates:
            print(f"No candidates found for rewrite {new_table_name}")
        item = candidates.first()
        input_token += item.prompt_tokens
        output_token += item.completion_tokens
        duration += item.duration

    return input_token, output_token, duration


def calculate_result_one_to_many(run_specs, get_predictions_func, table_selections):
    run_specs = {key: run_specs[key] for key in sorted(run_specs.keys())}

    rewrite_llm = run_specs["rewrite_llm"]

    ground_truths = load_ground_truth(
        rewrite_llm,
        run_specs["source_db"].split("-merged")[0],
        run_specs["target_db"].split("-merged")[0],
    )
    predictions, token_cost = get_predictions_func(run_specs, table_selections)
    predictions = json.loads(json.dumps(predictions))
    scores = calculate_metrics(ground_truths, predictions)

    print(run_specs)
    print(ground_truths)
    print(predictions)
    print(scores)
    from schema_match.data_models.evaluation_report import (
        OntologyMatchingEvaluationReport,
    )

    result = {
        "source_database": run_specs["source_db"],
        "target_database": run_specs["target_db"],
        "rewrite_llm": run_specs["rewrite_llm"],
        "column_matching_strategy": run_specs["column_matching_strategy"],
        "column_matching_llm": run_specs["column_matching_llm"],
        "table_selection_strategy": run_specs["table_selection_strategy"],
        "table_selection_llm": run_specs["table_selection_llm"],
        "version": 5,
        "column_matching_tokens": token_cost,
    }

    if run_specs.get("context_size"):
        result["context_size"] = run_specs["context_size"]
    result.update(scores)
    # if run_specs["column_matching_strategy"].find("llm") > -1 and run_specs["column_matching_strategy"] not in [
    #     "llm-limit_context"
    # ]:
    return OntologyMatchingEvaluationReport.upsert(result)


def load_ground_truth(rewrite_llm, source_db, target_db):
    from schema_match.data_models.experiment_models import OntologySchemaRewrite
    from schema_match.data_models.experiment_models import OntologyAlignmentGroundTruth

    ground_truths = dict()

    rewrite_queryset = OntologySchemaRewrite.objects(
        database__in=[source_db, target_db], llm_model=rewrite_llm
    )
    for item in rewrite_queryset.filter(database=source_db):
        ground_truths[f"{item.table}.{item.column}"] = []
    for source, targets in (
        OntologyAlignmentGroundTruth.objects(dataset=f"{source_db}-{target_db}")
        .first()
        .data.items()
    ):
        source_table, source_column = source.split(".")
        source_entry = rewrite_queryset.filter(
            original_table=source_table,
            original_column=source_column,
        ).first()
        assert source_entry, (
            f"{source=},{source_table=},{source_column=} {rewrite_llm=}"
        )
        assert not source_entry.linked_table, (
            f"{source=},{source_table=},{source_column=} {rewrite_llm=}"
        )
        for target in targets:
            target_table, target_column = target.split(".")
            target_entry = rewrite_queryset.filter(
                original_table=target_table,
                original_column=target_column,
            ).first()
            assert target_entry, target
            assert not target_entry.linked_table, target
            ground_truths[f"{source_entry.table}.{source_entry.column}"].append(
                f"{target_entry.table}.{target_entry.column}"
            )

    return ground_truths


cache = get_cache()


def print_table_mapping_result(run_specs):
    source_db, target_db = run_specs["source_db"], run_specs["target_db"]
    dataset = f"{source_db}-{target_db}"
    from schema_match.data_models.experiment_models import (
        OntologyAlignmentGroundTruth,
    )

    run_specs = {key: run_specs[key] for key in sorted(run_specs.keys())}
    cache_key = json.dumps(run_specs) + "table_selection_result"
    cache_result = cache.get(cache_key)
    if cache_result:
        return cache_result

    from schema_match.data_models.experiment_models import OntologySchemaRewrite

    source_table_description = OntologySchemaRewrite.get_database_description(
        source_db, "original", include_foreign_keys=True
    )
    target_table_description = OntologySchemaRewrite.get_database_description(
        target_db, "original", include_foreign_keys=True
    )

    source_table_name_mapping = dict()
    target_table_name_mapping = dict()
    for item in OntologySchemaRewrite.objects(
        database__in=[source_db, target_db], llm_model=run_specs["rewrite_llm"]
    ):
        if item.database == source_db:
            source_table_name_mapping[item.original_table] = item.table
        if item.database == target_db:
            target_table_name_mapping[item.original_table] = item.table

    ground_truth_table_mapping = defaultdict(set)

    for source, targets in (
        OntologyAlignmentGroundTruth.objects(dataset__in=[dataset, dataset.lower()])
        .first()
        .data.items()
    ):
        source_table, source_column = source.split(".")
        source_column_data = source_table_description[source_table]["columns"][
            source_column
        ]
        sources = [(source_table, source_column)]
        if source_column_data.get("linked_entry"):
            source_table, source_column = source_column_data["linked_entry"].split(".")
            sources.append((source_table, source_column))
        for target in targets:
            target_table, target_column = target.split(".")
            target_column_data = target_table_description[target_table]["columns"][
                target_column
            ]
            if target_column_data.get("linked_entry"):
                target_table, target_column = target_column_data["linked_entry"].split(
                    "."
                )
            for source_table, source_column in sources:
                ground_truth_table_mapping[source_table_name_mapping[source_table]].add(
                    target_table_name_mapping[target_table]
                )
    # pprint.pp(ground_truth_table_mapping)
    from schema_match.evaluations.calculate_result import table_selection_func_map

    table_selections = table_selection_func_map[run_specs["table_selection_strategy"]](
        run_specs
    )

    TP, FP, FN = 0, 0, 0
    hits = 0
    total = 0
    hits_table = []
    if True:
        for source, ground_truth_tables in ground_truth_table_mapping.items():
            if not ground_truth_tables:
                continue
            predicted_target_tables = table_selections.get(source, [])
            if predicted_target_tables and (
                not isinstance(predicted_target_tables[0], str)
            ):
                predicted_target_tables = [
                    item["target_table"] for item in predicted_target_tables
                ]
            ground_truth_tables = ground_truth_table_mapping.get(source, [])
            tp = len(set(ground_truth_tables) & set(predicted_target_tables))
            fp = len(set(predicted_target_tables) - set(ground_truth_tables))
            fn = len(set(ground_truth_tables) - set(predicted_target_tables))
            TP += tp
            FP += fp
            FN += fn
            if tp:
                hits += 1
                hits_table.append(source)
            total += 1
    precision, recall, f1_score = calculate_f1(TP, FP, FN)
    from datetime import timedelta

    print(hits_table)
    result = {
        "precision": precision,
        "recall": recall,
        "f1_score": f1_score,
        "hits": hits,
        "total": total,
        "accuracy": hits / total,
    }
    cache.set(
        cache_key,
        result,
        timeout=timedelta(days=1).total_seconds(),
    )
    res = cache.get(cache_key)
    return res


def get_evaluation_result_table(experiments):
    # "imdb-sakila", "omop-cms", "mimic_iii-omop", "cprd_aurum-omop", "cprd_gold-omop"
    result = get_full_results()
    strategy_mappings = [
        ("coma Rewrite: original", "Coma"),
        ("similarity_flooding Rewrite: original", "Similarity Flooding"),
        ("cupid Rewrite: original", "Cupid"),
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
        # (
        #     "schema_understanding_no_reasoning Rewrite: deepinfra/meta-llama/Meta-Llama-3.1-8B-Instruct Matching: gpt-4o",
        #     "Schema Understanding (Llama3.1-8b/gpt-4o)",
        # ),
        # (
        #     "schema_understanding_no_reasoning Rewrite: deepinfra/meta-llama/Meta-Llama-3.1-8B-Instruct Matching: deepinfra/meta-llama/Meta-Llama-3.1-70B-Instruct",
        #     "Schema Understanding (Llama3.1-70b/Llama3.1-70b)",
        # ),
        # (
        #     "schema_understanding_no_reasoning Rewrite: deepinfra/meta-llama/Meta-Llama-3.1-8B-Instruct Matching: deepinfra/meta-llama/Meta-Llama-3.1-405B-Instruct",
        #     "Schema Understanding (Llama3.1-405b/Llama3.1-405b)",
        # ),
    ]
    rows = []
    for config, strategy in strategy_mappings:
        row = [strategy]
        for dataset in experiments:
            try:
                # row.append(result[config][dataset].precision)
                # row.append(result[config][dataset].recall)
                row.append(result[config][dataset].f1_score)
            except Exception as e:
                raise e
        rows.append(row)

    rows = format_max_value(rows, underline_second_best=True)

    return rows


def all_strategy_f1():
    # "imdb-sakila", "omop-cms", "mimic_iii-omop", "cprd_aurum-omop", "cprd_gold-omop"
    result = get_full_results()
    rows = []
    header = ["strategy"] + EXPERIMENTS + SINGLE_TABLE_EXPERIMENTS
    rows.append(header)
    for strategy in result:
        row = [strategy.replace("_", " ").title()]
        for dataset in EXPERIMENTS + SINGLE_TABLE_EXPERIMENTS:
            try:
                # row.append(result[strategy][dataset].precision)
                # row.append(result[strategy][dataset].recall)
                row.append(round(result[strategy][dataset].f1_score, 2))
            except Exception as e:
                row.append("None")
        rows.append(row)
    save_to_csv(rows, "evaluation_result_all_f1.csv")


def single_table_f1_score():
    # "imdb-sakila", "omop-cms", "mimic_iii-omop", "cprd_aurum-omop", "cprd_gold-omop"
    from schema_match.data_models.evaluation_report import (
        OntologyMatchingEvaluationReport,
    )

    rows = []
    rows.append(
        [
            "strategy",
            "prospect-horizontal",
            "wikidata-musicians",
            "wikidata-musicians2",
            "wikidata-musicians3",
        ]
    )
    for strategy in OntologyMatchingEvaluationReport.objects(
        source_database="prospect"
    ).distinct("strategy"):
        row = [strategy]
        for dataset in [
            "prospect-horizontal",
            "wikidata-musicians",
            "wikidata-musicians2",
            "wikidata-musicians3",
        ]:
            try:
                record = OntologyMatchingEvaluationReport.objects(
                    source_database=dataset.split("-")[0],
                    target_database=dataset.split("-")[1],
                    strategy=strategy,
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


def get_full_results_df():
    from schema_match.data_models.evaluation_report import (
        OntologyMatchingEvaluationReport,
    )
    import pandas as pd

    queryset = OntologyMatchingEvaluationReport.objects.all()
    data = list(queryset.as_pymongo())
    df = pd.DataFrame(data)
    df.drop(columns=["_id", "created_at", "updated_at", "strategy"], inplace=True)
    return df


def effect_of_k_in_table_to_table_vector_similarity(llm):
    from schema_match.data_models.evaluation_report import (
        OntologyMatchingEvaluationReport,
    )

    row_names = [
        "table_to_table_vector_similarity",
        "table_to_table_top_10_vector_similarity",
    ]

    result = dict()
    for experiment in EXPERIMENTS:
        row = []
        for row_name in row_names:
            queryset = OntologyMatchingEvaluationReport.objects(
                source_database=experiment.split("-")[0],
                target_database=experiment.split("-")[1],
                rewrite_llm=llm,
                table_selection_strategy=row_name,
                column_matching_strategy="llm",
                column_matching_llm=llm,
            )
            if queryset.count() > 1:
                queryset = queryset.filter(table_selection_llm=llm)
            assert queryset.count() == 1, f" {experiment}, {queryset.count()} {llm}"
            record = queryset.first()
            row.append(record.f1_score)
        result[experiment] = row

    import pandas as pd

    df = pd.DataFrame(result, index=row_names)

    styled_df = hightlight_df(df)

    # Display the styled dataframe
    return styled_df


def effect_of_context_size_in_table_selection(llm):
    row_names = [100, 200, 500, 1000, 2000, 5000, 10000, 20000]

    result = dict()
    for experiment in EXPERIMENTS:
        row = []
        for context_size in row_names:
            source_db, target_db = experiment.split("-")
            run_specs = {
                "source_db": source_db,
                "target_db": target_db,
                "rewrite_llm": "original",
                "table_selection_strategy": "llm-limit_context",
                "table_selection_llm": llm,
                "column_matching_strategy": "llm",
                "column_matching_llm": llm,
                "context_size": context_size,
            }

            table_selection_result = print_table_mapping_result(run_specs)
            row.append(table_selection_result["f1_score"])
        result[experiment] = row

    import pandas as pd

    df = pd.DataFrame(result, index=row_names)

    styled_df = hightlight_df(df)

    # Display the styled dataframe
    return styled_df


def effect_of_context_size_in_table_selection_hits(llm):
    row_names = [100, 200, 500, 1000, 2000, 5000, 10000, 20000]

    result = dict()
    for experiment in EXPERIMENTS:
        row = []
        for context_size in row_names:
            source_db, target_db = experiment.split("-")
            run_specs = {
                "source_db": source_db,
                "target_db": target_db,
                "rewrite_llm": "original",
                "table_selection_strategy": "llm-limit_context",
                "table_selection_llm": llm,
                "column_matching_strategy": "llm",
                "column_matching_llm": llm,
                "context_size": context_size,
            }

            table_selection_result = print_table_mapping_result(run_specs)
            row.append(table_selection_result["accuracy"])
        result[experiment] = row

    import pandas as pd

    df = pd.DataFrame(result, index=row_names)

    styled_df = hightlight_df(df)

    # Display the styled dataframe
    return styled_df


def effect_of_context_length(llm):
    from schema_match.data_models.evaluation_report import (
        OntologyMatchingEvaluationReport,
    )

    row_names = ["llm", "llm-one_table_to_one_table"]

    result = dict()
    for experiment in EXPERIMENTS:
        row = []
        for column_matching_strategy in row_names:
            queryset = OntologyMatchingEvaluationReport.objects(
                source_database=experiment.split("-")[0],
                target_database=experiment.split("-")[1],
                rewrite_llm="original",
                table_selection_strategy="llm",
                column_matching_strategy=column_matching_strategy,
                column_matching_llm=llm,
            )
            if queryset.count() > 1:
                queryset = queryset.filter(table_selection_llm=llm)
            assert queryset.count() == 1, f" {experiment}, {queryset.count()} {llm}"
            record = queryset.first()
            row.append(record.f1_score)
        result[experiment] = row

    import pandas as pd

    df = pd.DataFrame(result, index=row_names)

    styled_df = hightlight_df(df)

    # Display the styled dataframe
    return styled_df


def effect_of_rewrite(
    table_selection_strategy,
    table_selection_llm,
    column_matching_strategy,
    column_matching_llm,
):
    from schema_match.data_models.evaluation_report import (
        OntologyMatchingEvaluationReport,
    )

    row_names = ["original", table_selection_llm]

    result = dict()
    for experiment in EXPERIMENTS:
        row = []
        for rewrite_llm in row_names:
            queryset = OntologyMatchingEvaluationReport.objects(
                source_database=experiment.split("-")[0],
                target_database=experiment.split("-")[1],
                rewrite_llm=rewrite_llm,
                table_selection_strategy=table_selection_strategy,
                column_matching_strategy=column_matching_strategy,
                column_matching_llm=column_matching_llm,
            )
            if queryset.count() > 1:
                queryset = queryset.filter(table_selection_llm=table_selection_llm)
            assert queryset.count() == 1, (
                f" {experiment}, {queryset.count()} {rewrite_llm}"
            )
            record = queryset.first()
            row.append(record.f1_score)
        result[experiment] = row

    import pandas as pd

    df = pd.DataFrame(result, index=row_names)

    styled_df = hightlight_df(df)

    # Display the styled dataframe
    return styled_df


def effect_of_table_selection_strategy(
    rewrite_llm, column_matching_strategy, column_matching_llm
):
    from schema_match.data_models.evaluation_report import (
        OntologyMatchingEvaluationReport,
    )

    configs = [
        ("gpt-3.5-turbo", "column_to_table_vector_similarity", "llm", "gpt-3.5-turbo"),
        ("gpt-3.5-turbo", "table_to_table_vector_similarity", "llm", "gpt-3.5-turbo"),
        ("gpt-3.5-turbo", "nested_join", "llm", "gpt-3.5-turbo"),
        ("gpt-3.5-turbo", "llm", "llm", "gpt-3.5-turbo"),
        # ("gpt-4o", "llm", "llm", "gpt-4o"),
    ]
    row_names = ["Column2Table", "Table2Table", "NestedJoin", "LLM"]

    result = dict()
    for experiment in EXPERIMENTS:
        row = []
        for config in configs:
            queryset = OntologyMatchingEvaluationReport.objects(
                source_database=experiment.split("-")[0],
                target_database=experiment.split("-")[1],
                rewrite_llm=rewrite_llm,
                table_selection_strategy=config[1],
                column_matching_strategy=column_matching_strategy,
                column_matching_llm=column_matching_llm,
            )
            if queryset.count() > 1:
                queryset = queryset.filter(table_selection_llm=config[3])
            assert queryset.count() == 1, f"{config}, {experiment}, {queryset.count()}"
            record = queryset.first()
            row.append(record.f1_score)
        result[experiment] = row

    import pandas as pd

    df = pd.DataFrame(result, index=row_names)

    styled_df = hightlight_df(df)

    # Display the styled dataframe
    return styled_df


def get_baseline_performance():
    from schema_match.data_models.evaluation_report import (
        OntologyMatchingEvaluationReport,
    )

    configs = [
        ("original", "None", "coma", "None"),
        ("original", "None", "similarity_flooding", "None"),
        # ("original", "None", "cupid", "None"),
        ("original", "None", "unicorn", "None"),
        (
            "original",
            "column_to_table_vector_similarity",
            "llm-rematch",
            "gpt-3.5-turbo",
        ),
        ("original", "column_to_table_vector_similarity", "llm-rematch", "gpt-4o"),
        ("gpt-3.5-turbo", "llm", "llm", "gpt-3.5-turbo"),
        ("gpt-4o", "llm", "llm", "gpt-4o"),
    ]
    row_names = [
        "Coma",
        "SimilarityFlood",
        "Unicorn",
        "Rematch-gpt-3.5",
        "Rematch-gpt-4o",
        "Ours-gpt-3.5",
        "Ours-gpt-4o",
    ]

    result = dict()
    for experiment in EXPERIMENTS:
        row = []
        for config in configs:
            queryset = OntologyMatchingEvaluationReport.objects(
                source_database=experiment.split("-")[0],
                target_database=experiment.split("-")[1],
                rewrite_llm=config[0],
                table_selection_strategy=config[1],
                column_matching_strategy=config[2],
                column_matching_llm=config[3],
            )
            if queryset.count() > 1:
                queryset = queryset.filter(table_selection_llm=config[3])
            assert queryset.count() == 1, f"{config}, {experiment}, {queryset.count()}"
            record = queryset.first()
            row.append(record.f1_score)
        result[experiment] = row

    import pandas as pd

    df = pd.DataFrame(result, index=row_names)

    styled_df = hightlight_df(df)

    # Display the styled dataframe
    return styled_df


def hightlight_df(df):
    # Function to underscore the second-largest and bold the largest value in each row
    def highlight_max_and_second_max(s):
        sorted_unique_values = s.sort_values(ascending=False).unique()

        # Determine the largest and second-largest values
        if len(sorted_unique_values) > 1:
            largest = sorted_unique_values[0]
            second_largest = sorted_unique_values[1]
        else:
            largest = sorted_unique_values[0]
            second_largest = None  # No second-largest if only one unique value

        # Apply styles: bold for the largest, underscore for the second-largest
        return [
            "font-weight: bold"
            if v == largest
            else "text-decoration: underline"
            if v == second_largest
            else ""
            for v in s
        ]

    # Apply the function to the dataframe across rows
    # formatted_df = df.style.format("{:.3f}")
    styled_df = df.style.apply(highlight_max_and_second_max, axis=0).format("{:.3f}")
    return styled_df


def get_full_results():
    from schema_match.data_models.evaluation_report import (
        OntologyMatchingEvaluationReport,
    )
    from schema_match.evaluations.latex_report.full_experiment_f1_score import (
        EXPERIMENTS,
    )

    result = defaultdict(dict)

    for (
        column_matching_strategy,
        column_matching_llm,
        table_selection_strategy,
        table_selection_llm,
    ) in [
        # ("coma", None, None, None),
        # ("similarity_flooding", None, None, None),
        # ("cupid", None, None, None),
        # ("unicorn", None, None, None),
        # ("llm-rematch", "gpt-3.5-turbo", "column_to_table_vector_similarity", None),
        # ("llm-rematch", "gpt-4o-mini", "column_to_table_vector_similarity", None),
        ("llm", "gpt-3.5-turbo", "llm", "gpt-3.5-turbo"),
        ("llm", "gpt-4o-mini", "llm", "gpt-4o-mini"),
    ]:
        for dataset in EXPERIMENTS:
            source_db, target_db = dataset.split("-")
            flt = {
                "source_database": source_db + "-merged",
                "target_database": target_db + "-merged",
                "rewrite_llm": "original",
                "column_matching_strategy": column_matching_strategy,
                "column_matching_llm": str(column_matching_llm),
                "table_selection_strategy": str(table_selection_strategy),
                "table_selection_llm": str(table_selection_llm),
            }
            queryset = OntologyMatchingEvaluationReport.objects(**flt)
            if queryset.count() == 0:
                from schema_match.evaluations.calculate_result import (
                    run_schema_matching_evaluation,
                )

                run_schema_matching_evaluation(
                    {
                        "source_db": source_db,
                        "target_db": target_db,
                        "rewrite_llm": "original",
                        "column_matching_strategy": column_matching_strategy,
                        "column_matching_llm": str(column_matching_llm),
                        "table_selection_strategy": str(table_selection_strategy),
                        "table_selection_llm": str(table_selection_llm),
                    },
                    refresh_existing_result=False,
                )
                queryset = OntologyMatchingEvaluationReport.objects(**flt)
            assert queryset.count() == 1, f"{flt=}, {queryset.count()}"
            for record in queryset:
                print(
                    f"\n{record.source_database}-{record.target_database},  {record.column_matching_strategy}, {record.column_matching_llm=},{record.rewrite_llm=},{record.precision=}, {record.recall=}, {record.f1_score=}, {record.total_duration}\t {record.total_model_cost}"
                )

                key = f"{record.column_matching_strategy} Rewrite: {record.rewrite_llm}"

                if record.column_matching_llm not in ["None"]:
                    key += f" Matching: {record.column_matching_llm}|"

                result[key][dataset] = record
    return result


def model_family_studies():
    from schema_match.data_models.evaluation_report import (
        OntologyMatchingEvaluationReport,
    )
    from schema_match.evaluations.latex_report.full_experiment_f1_score import (
        EXPERIMENTS,
    )

    result = defaultdict(dict)

    for column_matching_strategy, column_matching_llm in [
        ("llm-rematch", "gpt-4o"),
        ("llm-rematch", "gpt-3.5-turbo"),
        ("llm", "gpt-4o"),
        ("llm", "gpt-3.5-turbo"),
    ]:
        for dataset in EXPERIMENTS:
            source_db, target_db = dataset.split("-")
            flt = {
                "source_database": source_db,
                "target_database": target_db,
                "rewrite_llm": "original",
                "column_matching_strategy": column_matching_strategy,
                "column_matching_llm": str(column_matching_llm),
            }
            queryset = OntologyMatchingEvaluationReport.objects(**flt)
            if queryset.count() == 0:
                print(flt)
                continue
            for record in queryset:
                print(
                    f"\n{record.source_database}-{record.target_database},  {record.column_matching_strategy}, {record.column_matching_llm=},{record.rewrite_llm=},{record.precision}, {record.recall}, {record.f1_score}, {record.total_duration}\t {record.total_model_cost}"
                )

                key = f"{record.column_matching_strategy} Rewrite: {record.column_matching_llm}"

                # if record.column_matching_llm:
                #     key += f" Matching: {record.column_matching_llm}|"

                result[key][dataset] = record.f1_score
    return result


def get_single_table_experiment_full_results():
    from schema_match.data_models.evaluation_report import (
        OntologyMatchingEvaluationReport,
    )
    from schema_match.evaluations.single_table_alignment import (
        get_single_table_experiment_data,
    )

    experiments = get_single_table_experiment_data()
    result = defaultdict(dict)
    for strategy in ["coma", "similarity_flooding", "cupid", "unicorn"]:
        for dataset in experiments:
            for record in OntologyMatchingEvaluationReport.objects(
                **{
                    "source_database": dataset + "_source",
                    "target_database": dataset + "_target",
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


def table_selection_strategies():
    from schema_match.data_models.evaluation_report import (
        OntologyMatchingEvaluationReport,
    )
    from schema_match.evaluations.latex_report.full_experiment_f1_score import (
        EXPERIMENTS,
    )

    result = defaultdict(dict)

    for table_selection_strategy, table_selection_llm in [
        # ("None", "None"),
        # ("nested_join", "None"),
        # ("column_to_table_vector_similarity", "None"),
        # ("table_to_table_vector_similarity", "None"),
        # ("table_to_table_top_10_vector_similarity", "None"),
        # ("table_to_table_top_15_vector_similarity", "None"),
        # ("llm", "gpt-3.5-turbo"),
        ("llm", "gpt-4o-mini"),
    ]:
        for dataset in EXPERIMENTS:
            source_db, target_db = dataset.split("-")
            flt = {
                "source_database": source_db + "-merged",
                "target_database": target_db + "-merged",
                "rewrite_llm": "original",
                "column_matching_strategy": "llm",
                "column_matching_llm": "gpt-4o-mini",
                "table_selection_strategy": table_selection_strategy,
                "table_selection_llm": table_selection_llm,
            }
            queryset = OntologyMatchingEvaluationReport.objects(**flt)

            # average target tables per source table

            # queryset.delete()
            if False:
                from schema_match.evaluations.calculate_result import (
                    run_schema_matching_evaluation,
                )

                run_schema_matching_evaluation(
                    {
                        "source_db": source_db,
                        "target_db": target_db,
                        "rewrite_llm": "original",
                        "column_matching_strategy": "llm",
                        "column_matching_llm": "gpt-4o-mini",
                        "table_selection_strategy": table_selection_strategy,
                        "table_selection_llm": table_selection_llm,
                    },
                    refresh_existing_result=False,
                )
                queryset = OntologyMatchingEvaluationReport.objects(**flt)
            assert queryset.count() == 1
            for record in queryset:
                print(
                    f"\n{record.source_database}-{record.target_database},  {record.column_matching_strategy}, {record.column_matching_llm=},{record.rewrite_llm=},{record.precision}, {record.recall}, {record.f1_score}, {record.total_duration}\t {record.total_model_cost}"
                )

                # key = f"{record.table_selection_strategy}-{record.table_selection_llm}-{record.column_matching_strategy}-{record.column_matching_llm}"

                # if record.column_matching_llm:
                #     key += f" Matching: {record.column_matching_llm}|"

                result[key][dataset] = round(record.f1_score, 2)
    return result


if __name__ == "__main__":
    get_evaluation_result_table(EXPERIMENTS)
