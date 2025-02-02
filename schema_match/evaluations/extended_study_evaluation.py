from collections import defaultdict

from schema_match.data_models.evaluation_report import OntologyMatchingEvaluationReport
from schema_match.data_models.experiment_models import (
    OntologyAlignmentGroundTruth,
    OntologySchemaRewrite,
    SchemaMatchingSurveyResult,
)
from schema_match.evaluations.ontology_matching_evaluation import (
    get_full_results,
    load_ground_truth,
)
from schema_match.constants import EXPERIMENTS, DATABASES


def dataset_statistics_rows():
    rows = []
    for dataset in DATABASES:
        from schema_match.data_models.experiment_models import OntologySchemaRewrite

        schema_descriptions = OntologySchemaRewrite.get_database_description(
            dataset, "original"
        )
        number_of_table = len(schema_descriptions)
        number_of_columns = sum(
            [len(schema["columns"]) for schema in schema_descriptions.values()]
        )
        number_of_foreign_keys = 0
        number_of_primary_keys = 0
        for schema in schema_descriptions.values():
            for field in schema["columns"].values():
                if field.get("is_foreign_key"):
                    number_of_foreign_keys += 1
                if field.get("is_primary_key"):
                    number_of_primary_keys += 1

        rows.append(
            [
                dataset,
                number_of_table,
                number_of_columns,
                number_of_foreign_keys,
                number_of_primary_keys,
            ]
        )
    return rows


def ground_truth_statistics():
    result = []
    for experiment in EXPERIMENTS:
        source_queryset = OntologySchemaRewrite.objects(
            database=experiment.split("-")[0], llm_model="original"
        )
        target_queryset = OntologySchemaRewrite.objects(
            database=experiment.split("-")[1], llm_model="original"
        )
        # source_pks = source_queryset.filter(is_primary_key=True)
        # target_pks = target_queryset.filter(is_primary_key=True)
        total_mappings = set()
        table_mappings = defaultdict(set)
        column_mappings = defaultdict(set)
        reverse_column_mappings = defaultdict(set)
        groud_truth = load_ground_truth(
            "original", experiment.split("-")[0], experiment.split("-")[1]
        )
        for source, targets in groud_truth.items():
            source = source_queryset.get(
                table=source.split(".")[0], column=source.split(".")[1]
            )
            if source.is_foreign_key:
                source = source_queryset.get(
                    table=source.linked_table, column=source.linked_column
                )
            # if source.is_primary_key:
            #     source_pks.add(f"{source.table}.{source.column}")
            for target in targets:
                target = target_queryset.get(
                    table=target.split(".")[0], column=target.split(".")[1]
                )

                if target.is_foreign_key:
                    target = target_queryset.get(
                        table=target.linked_table, column=target.linked_column
                    )
                # if target.is_primary_key:
                #     target_pks.add(f"{target.table}.{target.column}")
                column_mappings[f"{source.table}.{source.column}"].add(
                    f"{target.table}.{target.column}"
                )
                table_mappings[source.table].add(target.table)
                reverse_column_mappings[f"{target.table}.{target.column}"].add(
                    f"{source.table}.{source.column}"
                )
                total_mappings.add(
                    (source.table, source.column, target.table, target.column)
                )
        record = {
            "dataset": experiment,
        }
        record["total_mappings"] = len(total_mappings)
        record["source_pks"] = source_queryset.filter(is_primary_key=True).count()
        record["target_pks"] = target_queryset.filter(is_primary_key=True).count()
        record["source_fks"] = source_queryset.filter(is_foreign_key=True).count()
        record["target_fks"] = target_queryset.filter(is_foreign_key=True).count()
        record["average_target_tables_per_source_table"] = sum(
            [len(item) for item in table_mappings.values()]
        ) / len(source_queryset.distinct("table"))
        record["max_target_tables_per_source_table"] = max(
            [len(item) for item in table_mappings.values()]
        )
        record["average_target_columns_per_source_column"] = (
            sum([len(item) for item in column_mappings.values()])
            / source_queryset.count()
        )
        record["max_target_columns_per_source_column"] = max(
            [len(item) for item in column_mappings.values()]
        )
        # calculate percentage of 1:1 mapping
        record["1:1_mappings"] = 0
        for source, targets in column_mappings.items():
            if (
                len(targets) == 1
                and len(reverse_column_mappings[list(targets)[0]]) == 1
            ):
                record["1:1_mappings"] += 1
        record["1:1_mappings_ratio"] = record["1:1_mappings"] / len(column_mappings)
        record["source_column_mapping_ratio"] = (
            len(column_mappings) + record["source_fks"]
        ) / len(source_queryset)
        record["target_column_mapping_ratio"] = (
            len(reverse_column_mappings) + record["target_fks"]
        ) / len(target_queryset)
        result.append(record)
        print(record)
    return result


def export_scalability_study_data():
    full_results = get_full_results()
    dataset_statistics = dataset_statistics_rows()
    strategy_mappings = [
        ("coma Rewrite: original", "Coma"),
        ("similarity_flooding Rewrite: original", "Similarity Flooding"),
        # ("cupid Rewrite: original", "Cupid"),
        ("unicorn Rewrite: original", "Unicorn"),
        ("rematch Rewrite: original Matching: gpt-4o", "Rematch (gpt-4o)"),
        # (
        # '{"strategy": "schema_understanding_no_reasoning", "rewrite_llm": "gpt-3.5-turbo", "matching_llm": "gpt-3.5-turbo"}',
        # "Schema Understanding (rewrite:gpt-4o/matching:gpt-3.5)"),
        # ('{"strategy": "schema_understanding_no_reasoning", "rewrite_llm": "gpt-3.5-turbo", "matching_llm": "gpt-4o"}',
        #  "Schema Understanding (rewrite:gpt-3.5/matching:gpt-4o)"),
        # (
        #     "schema_understanding_no_reasoning Rewrite: gpt-4o Matching: gpt-4o",
        #     "Schema Understanding (gpt-4o)",
        # ),
        (
            "schema_understanding_no_reasoning Rewrite: gpt-3.5-turbo Matching: gpt-4o",
            "Schema Understanding (rewrite:gpt-3.5/matching:gpt-4o)",
        ),
    ]
    experiment_columns_mapping = {}
    source_tables = {}
    for dataset in EXPERIMENTS:
        source_db, target_db = dataset.split("-")
        source_columns = [
            item[2] for item in dataset_statistics if item[0] == source_db
        ][0]
        target_columns = [
            item[2] for item in dataset_statistics if item[0] == target_db
        ][0]
        experiment_columns_mapping[dataset] = source_columns + target_columns
        source_tables[dataset] = [
            item[1] for item in dataset_statistics if item[0] == source_db
        ][0]

    header = [dataset, "Number of Columns", "Number of Source Tables"] + [
        item[1] for item in strategy_mappings
    ]

    result = defaultdict(list)
    for config, strategy in strategy_mappings:
        for dataset in EXPERIMENTS:
            try:
                result[dataset].append(full_results[config][dataset].total_duration)
                print(
                    dataset,
                    strategy,
                    full_results[config][dataset].total_duration,
                    full_results[config][dataset].rewrite_duration,
                    full_results[config][dataset].matching_duration,
                )
            except Exception as e:
                pass
                # raise e
    rows = [header]
    for dataset in EXPERIMENTS:
        rows.append(
            [dataset, experiment_columns_mapping[dataset], source_tables[dataset]]
            + result[dataset]
        )

    # save to csv file
    import csv
    import os

    script_dir = os.path.dirname(__file__)
    file_path = os.path.join(
        script_dir,
        "../..",
        "dataset/match_result/scalability_study.csv",
    )
    with open(file_path, "w", newline="") as file:
        writer = csv.writer(file)
        writer.writerows(rows)
    return rows


def generate_model_variation_study():
    full_result = get_full_results()
    result = defaultdict(lambda: defaultdict(dict))
    strategy_mappings = [
        (
            "schema_understanding_no_reasoning Rewrite: gpt-3.5-turbo Matching: gpt-3.5-turbo",
            "gpt-3.5",
            "gpt-3.5",
        ),
        (
            "schema_understanding_no_reasoning Rewrite: gpt-3.5-turbo Matching: gpt-4o",
            "gpt-3.5",
            "gpt-4o",
        ),
        (
            "schema_understanding_no_reasoning Rewrite: gpt-4o Matching: gpt-4o",
            "gpt-4o",
            "gpt-4o",
        ),
        (
            "schema_understanding_no_reasoning Rewrite: gpt-4o Matching: gpt-3.5-turbo",
            "gpt-4o",
            "gpt-3.5",
        ),
    ]

    # strategy_mappings_llama = [
    #     (
    #         "schema_understanding_no_reasoning Rewrite: deepinfra/meta-llama/Meta-Llama-3.1-70B-Instruct Matching: deepinfra/meta-llama/Meta-Llama-3.1-405B-Instruct",
    #         "llama-70b",
    #         "llama-405b",
    #     ),
    #     (
    #         "schema_understanding_no_reasoning Rewrite: deepinfra/meta-llama/Meta-Llama-3.1-405B-Instruct Matching: deepinfra/meta-llama/Meta-Llama-3.1-405B-Instruct",
    #         "llama-405b",
    #         "llama-405b",
    #     ),
    #     (
    #         "schema_understanding_no_reasoning Rewrite: deepinfra/meta-llama/Meta-Llama-3.1-70B-Instruct Matching: deepinfra/meta-llama/Meta-Llama-3.1-70B-Instruct",
    #         "llama-70b",
    #         "llama-70b",
    #     ),
    #     (
    #         "schema_understanding_no_reasoning Rewrite: deepinfra/meta-llama/Meta-Llama-3.1-405B-Instruct Matching: deepinfra/meta-llama/Meta-Llama-3.1-70B-Instruct",
    #         "llama-405b",
    #         "llama-70b",
    #     ),
    # ]
    for strategy, rewrite_model, matching_model in strategy_mappings:
        for dataset, experimen_result in full_result[strategy].items():
            result[dataset][rewrite_model][matching_model] = experimen_result.f1_score
    rows = []
    for dataset in EXPERIMENTS:
        rows.append(["x", "y", dataset])
        for x, rewrite_model in enumerate(["gpt-3.5", "gpt-4o"]):
            for y, matching_model in enumerate(["gpt-3.5", "gpt-4o"]):
                try:
                    rows.append(
                        [x + 1, y + 1, result[dataset][rewrite_model][matching_model]]
                    )
                except Exception as e:
                    raise e

    # write to csv
    import csv
    import os

    script_dir = os.path.dirname(__file__)
    file_path = os.path.join(
        script_dir,
        "../..",
        "dataset/match_result/model_selection_study.csv",
    )
    with open(file_path, "w", newline="") as file:
        writer = csv.writer(file)
        writer.writerows(rows)


def token_cost_study():
    full_result = get_full_results()
    result = defaultdict(lambda: defaultdict(dict))
    strategy_mappings = [
        (
            "schema_understanding_no_reasoning Rewrite: gpt-3.5-turbo Matching: gpt-4o",
            "Schema Understanding (mixed model)",
        ),
        (
            "schema_understanding_no_reasoning Rewrite: gpt-4o Matching: gpt-4o",
            "Schema Understanding (gpt-4o)",
        ),
        ("rematch Rewrite: original Matching: gpt-4o", "Rematch (gpt-4o)"),
    ]
    rows = [["dataset", "method", "f1", "token cost"]]
    for strategy, strategy_name in strategy_mappings:
        for dataset, experimen_result in full_result[strategy].items():
            print(dataset, experimen_result.f1_score, experimen_result.total_model_cost)
            # result[dataset][strategy_name]= experimen_result.total_duration
            rows.append(
                [
                    dataset,
                    strategy_name,
                    experimen_result.f1_score,
                    experimen_result.total_model_cost,
                ]
            )

    # write to csv
    import csv
    import os

    script_dir = os.path.dirname(__file__)
    file_path = os.path.join(
        script_dir,
        "../..",
        "dataset/match_result/token_cost_study.csv",
    )
    with open(file_path, "w", newline="") as file:
        writer = csv.writer(file)
        writer.writerows(rows)


def matching_table_candidate_selection_study():
    strategy_mappings = [
        (
            "schema_understanding_no_reasoning Rewrite: gpt-3.5-turbo Matching: gpt-4o",
            "LLM Selection",
        ),
        (
            "schema_understanding_embedding_selection Rewrite: gpt-3.5-turbo Matching: gpt-4o",
            "Vector Similarity (column to table)",
        ),
    ]
    return parameter_study(
        strategy_mappings, "matching_table_candidate_selection_method.csv"
    )


def effect_of_rewrite_gpt35():
    result = defaultdict(dict)
    for rewrite_llm in ["original", "gpt-4o"]:
        for dataset in EXPERIMENTS:
            for column_matching_strategy in ["llm-no_description_no_foreign_keys"]:
                source_db, target_db = dataset.split("-")
                flt = {
                    "source_database": source_db,
                    "target_database": target_db,
                    "rewrite_llm": rewrite_llm,
                    "column_matching_strategy": column_matching_strategy,
                    "column_matching_llm": "gpt-4o-mini",
                    "table_selection_strategy": column_matching_strategy,
                    "table_selection_llm": "gpt-4o-mini",
                }
                record = OntologyMatchingEvaluationReport.objects(**flt).first()
                if True:
                    from schema_match.evaluations.calculate_result import (
                        run_schema_matching_evaluation,
                    )

                    run_schema_matching_evaluation(
                        {
                            "source_db": source_db,
                            "target_db": target_db,
                            "rewrite_llm": flt["rewrite_llm"],
                            "column_matching_strategy": column_matching_strategy,
                            "column_matching_llm": flt["column_matching_llm"],
                            "table_selection_strategy": flt["table_selection_strategy"],
                            "table_selection_llm": flt["table_selection_llm"],
                        },
                        refresh_existing_result=False,
                    )
                    record = OntologyMatchingEvaluationReport.objects(**flt).first()
                assert record, flt
                key = f"{column_matching_strategy} Rewrite: {rewrite_llm}"
                result[key][dataset] = record.f1_score
    print(result)


def effect_of_description():
    result = defaultdict(dict)
    for column_matching_strategy in ["llm", "llm-no_description"]:
        for dataset in EXPERIMENTS:
            for rewrite_llm in ["original"]:
                source_db, target_db = dataset.split("-")
                flt = {
                    "source_database": source_db,
                    "target_database": target_db,
                    "rewrite_llm": rewrite_llm,
                    "column_matching_strategy": column_matching_strategy,
                    "column_matching_llm": "gpt-4o-mini",
                    "table_selection_strategy": column_matching_strategy,
                    "table_selection_llm": "gpt-4o-mini",
                }
                record = OntologyMatchingEvaluationReport.objects(**flt).first()
                assert record, flt
                # if not record:
                #     from schema_match.evaluations.calculate_result import run_schema_matching_evaluation
                #
                #     run_schema_matching_evaluation(
                #         {
                #             "source_db": source_db,
                #             "target_db": target_db,
                #             "rewrite_llm": flt["rewrite_llm"],
                #             "column_matching_strategy": column_matching_strategy,
                #             "column_matching_llm": flt["column_matching_llm"],
                #             "table_selection_strategy": flt["table_selection_strategy"],
                #             "table_selection_llm": flt["table_selection_llm"],
                #         },
                #         refresh_existing_result=False,
                #     )
                #     record = OntologyMatchingEvaluationReport.objects(**flt).first()
                assert record, flt
                key = f"{column_matching_strategy}"
                result[key][dataset] = record.f1_score
    print(result)


def effect_of_foreign_keys():
    result = defaultdict(dict)
    for column_matching_strategy in ["llm", "llm-no_foreign_keys"]:
        for dataset in EXPERIMENTS:
            for rewrite_llm in ["original"]:
                source_db, target_db = dataset.split("-")
                flt = {
                    "source_database": source_db,
                    "target_database": target_db,
                    "rewrite_llm": rewrite_llm,
                    "column_matching_strategy": column_matching_strategy,
                    "column_matching_llm": "gpt-4o-mini",
                    "table_selection_strategy": column_matching_strategy,
                    "table_selection_llm": "gpt-4o-mini",
                }
                record = OntologyMatchingEvaluationReport.objects(**flt).first()
                assert record, flt
                key = f"{column_matching_strategy}"
                result[key][dataset] = record.f1_score
    print(result)


def effect_of_foreign_keys_and_description(llm_model):
    result = defaultdict(dict)
    for column_matching_strategy in [
        "llm",
        "llm-no_description_no_foreign_keys",
        "llm-no_description",
        "llm-no_foreign_keys",
    ]:
        for dataset in EXPERIMENTS:
            for rewrite_llm in ["original"]:
                source_db, target_db = dataset.split("-")
                flt = {
                    "source_database": source_db,
                    "target_database": target_db,
                    "rewrite_llm": rewrite_llm,
                    "column_matching_strategy": column_matching_strategy,
                    "column_matching_llm": llm_model,
                    "table_selection_strategy": column_matching_strategy,
                    "table_selection_llm": llm_model,
                }
                record = OntologyMatchingEvaluationReport.objects(**flt).first()
                if not record:
                    from schema_match.evaluations.calculate_result import (
                        run_schema_matching_evaluation,
                    )

                    run_schema_matching_evaluation(
                        flt.copy(),
                        refresh_existing_result=False,
                    )
                    record = OntologyMatchingEvaluationReport.objects(**flt).first()
                assert record, flt
                key = f"{column_matching_strategy}"
                result[key][dataset] = record.f1_score
    return result


def effect_of_data(llm_model):
    result = defaultdict(dict)
    for column_matching_strategy in ["llm", "llm-data", "llm-human_in_the_loop"]:
        for dataset in EXPERIMENTS:
            for rewrite_llm in ["original"]:
                source_db, target_db = dataset.split("-")
                flt = {
                    "source_database": source_db,
                    "target_database": target_db,
                    "rewrite_llm": rewrite_llm,
                    "column_matching_strategy": column_matching_strategy,
                    "column_matching_llm": llm_model,
                    "table_selection_strategy": "llm",
                    "table_selection_llm": llm_model,
                }
                record = OntologyMatchingEvaluationReport.objects(**flt).first()
                if not record:
                    from schema_match.evaluations.calculate_result import (
                        run_schema_matching_evaluation,
                    )

                    run_schema_matching_evaluation(
                        flt.copy(),
                        refresh_existing_result=False,
                    )
                    record = OntologyMatchingEvaluationReport.objects(**flt).first()
                assert record, flt
                key = f"{column_matching_strategy}"
                result[key][dataset] = record.f1_score
    return result


def gpt4_family_difference():
    result = defaultdict(dict)
    for rewrite_llm in ["original"]:
        for dataset in EXPERIMENTS:
            for column_matching_llm in ["gpt-4o-mini", "gpt-4o"]:
                source_db, target_db = dataset.split("-")
                flt = {
                    "source_database": source_db,
                    "target_database": target_db,
                    "rewrite_llm": rewrite_llm,
                    "column_matching_strategy": "llm",
                    "table_selection_strategy": "ground_truth",
                    "table_selection_llm": "None",
                    "column_matching_llm": column_matching_llm,
                }
                record = OntologyMatchingEvaluationReport.objects(**flt).first()
                if not record:
                    from schema_match.evaluations.calculate_result import (
                        run_schema_matching_evaluation,
                    )

                    run_schema_matching_evaluation(
                        {
                            "source_db": source_db,
                            "target_db": target_db,
                            "rewrite_llm": flt["rewrite_llm"],
                            "column_matching_strategy": flt["column_matching_strategy"],
                            "column_matching_llm": flt["column_matching_llm"],
                            "table_selection_strategy": flt["table_selection_strategy"],
                            "table_selection_llm": flt["table_selection_llm"],
                        },
                        refresh_existing_result=False,
                    )
                    record = OntologyMatchingEvaluationReport.objects(**flt).first()
                assert record, flt
                key = f"llm: {column_matching_llm}"
                result[key][dataset] = record.f1_score
    print(result)


def parameter_study(strategy_mappings, filename):
    full_result = get_full_results()

    result = defaultdict(lambda: defaultdict(list))
    rows = [["dataset", "strategy", "P", "Recall", "f1"]]
    for strategy, strategy_name in strategy_mappings:
        assert full_result[strategy], f"Strategy {strategy} not found"
        for dataset, experiment_result in full_result[strategy].items():
            rows.append(
                [
                    dataset,
                    strategy_name,
                    experiment_result.precision,
                    experiment_result.recall,
                    experiment_result.f1_score,
                ]
            )
            result[strategy_name][dataset] = [
                experiment_result.precision,
                experiment_result.recall,
                experiment_result.f1_score,
            ]
    # write to csv
    import csv
    import os

    script_dir = os.path.dirname(__file__)
    file_path = os.path.join(
        script_dir,
        "../..",
        f"dataset/match_result/{filename}",
    )
    with open(file_path, "w", newline="") as file:
        writer = csv.writer(file)
        writer.writerows(rows)
    return result


def generate_human_experiment_result():
    source_query = OntologySchemaRewrite.objects(database="imdb", llm_model="original")
    target_query = OntologySchemaRewrite.objects(
        database="sakila", llm_model="original"
    )
    ground_truth = OntologyAlignmentGroundTruth.objects(dataset="imdb-sakila").first()
    data = ground_truth.data
    data
    source_table, target_table = set(), set()
    for source, targets in data.items():
        source_table.add(source.split(".")[0])
        for target in targets:
            target_table.add(target.split(".")[0])
    target_table = ["actor", "film"]
    source_columns = source_query.filter(table__in=source_table)
    target_columns = target_query.filter(table__in=target_table)
    result = dict()
    result["source"] = []
    result["target"] = []
    for table in source_table:
        table_data = {"table": table, "columns": []}
        for column in source_columns.filter(table=table):
            table_data["columns"].append(column.column)
        result["source"].append(table_data)
    for table in target_table:
        table_data = {"table": table, "columns": []}
        for column in target_columns.filter(table=table):
            table_data["columns"].append(column.column)
        result["target"].append(table_data)
    return result


def user_study():
    result = defaultdict(dict)
    machine_answer = [
        {"source": "name_basics.nconst", "target": "actor.actor_id"},
        {"source": "name_basics.primaryname", "target": "actor.first_name"},
        {"source": "title_akas.language", "target": "language.language_id"},
        {"source": "title_akas.title", "target": "film.title"},
        {"source": "title_basics.genres", "target": "category.category_id"},
        {"source": "title_basics.isadult", "target": "film.rating"},
        {"source": "title_basics.originaltitle", "target": "film.title"},
        {"source": "title_basics.primarytitle", "target": "actor.first_name"},
        {"source": "title_basics.runtimeminutes", "target": "film.length"},
        {"source": "title_basics.startyear", "target": "film.release_year"},
        {"source": "title_basics.tconst", "target": "film.film_id"},
        {"source": "title_principals.category", "target": "category.category_id"},
        {"source": "title_ratings.averagerating", "target": "film.rating"},
    ]
    ground_truths = load_ground_truth("original", "imdb", "sakila")
    from schema_match.utils import calculate_metrics

    machine_prediction = defaultdict(set)
    for item in machine_answer:
        machine_prediction[item["source"]].add(item["target"])
    machine_result = calculate_metrics(ground_truths, machine_prediction)
    for item in SchemaMatchingSurveyResult.objects():
        print(item.answers)
        predictions = defaultdict(set)
        for answer in item.answers:
            predictions[answer["source"]].add(answer["target"])

        scores = calculate_metrics(ground_truths, predictions)
        f1 = scores["f1_score"]
        result[item.evaluation_session][item.with_machine_help] = f1
    print(result)
    human_scores = []
    maching_scores = []
    for user, user_score in result.items():
        if len(user_score) == 2 and user_score[True] > 0.5:
            maching_scores.append(user_score[False])
            human_scores.append(user_score[True])
    print(machine_result["f1_score"])

    print(
        len(maching_scores),
        len(human_scores),
        sum(maching_scores) / len(human_scores),
        sum(human_scores) / len(human_scores),
    )


if __name__ == "__main__":
    # effect_of_rewrite_gpt4o_no_description()
    # effect_of_foreign_key()
    # effect_of_description()
    # effect_of_rewrite_gpt4o()
    # effect_of_rewrite_gpt35()
    # effect_of_reasoning()
    # token_cost_study()
    # matching_table_candidate_selection_study()
    # generate_model_variation_study()
    export_scalability_study_data()
    print("Done")
