from collections import defaultdict

from llm_ontology_alignment.evaluations.ontology_matching_evaluation import get_full_results
from llm_ontology_alignment.evaluations.latex_report.full_experiment_f1_score import schema_name_mapping
from llm_ontology_alignment.constants import EXPERIMENTS, DATABASES


def dataset_statistics_rows():
    rows = []
    for dataset in DATABASES:
        from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite

        schema_descriptions = OntologySchemaRewrite.get_database_description(dataset, "original")
        number_of_table = len(schema_descriptions)
        number_of_columns = sum([len(schema["columns"]) for schema in schema_descriptions.values()])
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
        source_columns = [item[2] for item in dataset_statistics if item[0] == source_db][0]
        target_columns = [item[2] for item in dataset_statistics if item[0] == target_db][0]
        experiment_columns_mapping[dataset] = source_columns + target_columns
        source_tables[dataset] = [item[1] for item in dataset_statistics if item[0] == source_db][0]

    header = [dataset, "Number of Columns", "Number of Source Tables"] + [item[1] for item in strategy_mappings]

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
        rows.append([dataset, experiment_columns_mapping[dataset], source_tables[dataset]] + result[dataset])

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
        ("schema_understanding_no_reasoning Rewrite: gpt-3.5-turbo Matching: gpt-3.5-turbo", "gpt-3.5", "gpt-3.5"),
        ("schema_understanding_no_reasoning Rewrite: gpt-3.5-turbo Matching: gpt-4o", "gpt-3.5", "gpt-4o"),
        ("schema_understanding_no_reasoning Rewrite: gpt-4o Matching: gpt-4o", "gpt-4o", "gpt-4o"),
        ("schema_understanding_no_reasoning Rewrite: gpt-4o Matching: gpt-3.5-turbo", "gpt-4o", "gpt-3.5"),
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
                    rows.append([x + 1, y + 1, result[dataset][rewrite_model][matching_model]])
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
        ("schema_understanding_no_reasoning Rewrite: gpt-4o Matching: gpt-4o", "Schema Understanding (gpt-4o)"),
        ("rematch Rewrite: original Matching: gpt-4o", "Rematch (gpt-4o)"),
    ]
    rows = [["dataset", "method", "f1", "token cost"]]
    for strategy, strategy_name in strategy_mappings:
        for dataset, experimen_result in full_result[strategy].items():
            print(dataset, experimen_result.f1_score, experimen_result.total_model_cost)
            # result[dataset][strategy_name]= experimen_result.total_duration
            rows.append([dataset, strategy_name, experimen_result.f1_score, experimen_result.total_model_cost])

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
    return parameter_study(strategy_mappings, "matching_table_candidate_selection_method.csv")


def effect_of_rewrite_gpt35():
    strategy_mappings = [
        (
            "schema_understanding_no_reasoning Rewrite: original Matching: gpt-3.5-turbo",
            "No Rewrite",
        ),
        (
            "schema_understanding_no_reasoning Rewrite: gpt-3.5-turbo Matching: gpt-3.5-turbo",
            "GPT-3.5 Rewrite",
        ),
        (
            "schema_understanding_no_reasoning Rewrite: gpt-4o Matching: gpt-3.5-turbo",
            "GPT-4o Rewrite",
        ),
    ]
    return parameter_study(strategy_mappings, "effect_of_rewrite_gpt35.csv")


def effect_of_rewrite_gpt4o():
    strategy_mappings = [
        (
            "schema_understanding_no_reasoning Rewrite: original Matching: gpt-4o",
            "No Rewrite",
        ),
        (
            "schema_understanding_no_reasoning Rewrite: gpt-3.5-turbo Matching: gpt-4o",
            "GPT-3.5 Rewrite",
        ),
        (
            "schema_understanding_no_reasoning Rewrite: gpt-4o Matching: gpt-4o",
            "GPT-4o Rewrite",
        ),
    ]
    return parameter_study(strategy_mappings, "effect_of_rewrite_gpt4o.csv")


def effect_of_rewrite_gpt4o_no_description():
    strategy_mappings = [
        (
            "schema_understanding_no_description Rewrite: original Matching: gpt-4o",
            "No Rewrite",
        ),
        (
            "schema_understanding_no_description Rewrite: gpt-3.5-turbo Matching: gpt-4o",
            "GPT-3.5 Rewrite",
        ),
        (
            "schema_understanding_no_description Rewrite: gpt-4o Matching: gpt-4o",
            "GPT-4o Rewrite",
        ),
    ]
    return parameter_study(strategy_mappings, "effect_of_rewrite_gpt4o_no_description.csv")


def effect_of_description():
    strategy_mappings = [
        (
            "schema_understanding_no_description Rewrite: gpt-3.5-turbo Matching: gpt-4o",
            "No Description",
        ),
        (
            "schema_understanding_no_reasoning Rewrite: gpt-3.5-turbo Matching: gpt-4o",
            "Description",
        ),
    ]
    return parameter_study(strategy_mappings, "effect_of_description_gpt4o.csv")


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


def effect_of_rewrite_study():
    full_result = get_full_results()
    strategy_mappings = [
        (
            "schema_understanding_no_reasoning Rewrite: original Matching: gpt-4o",
            "No Rewrite",
        ),
        (
            "schema_understanding_no_reasoning Rewrite: gpt-3.5-turbo Matching: gpt-4o",
            "GPT-3.5 Rewrite",
        ),
        (
            "schema_understanding_no_reasoning Rewrite: gpt-4o Matching: gpt-4o",
            "GPT-4o Rewrite",
        ),
    ]
    result = defaultdict(lambda: defaultdict(list))
    rows = [["dataset", "Rewrite Strategy", "P", "Recall", "f1"]]
    for strategy, strategy_name in strategy_mappings:
        for dataset, experimen_result in full_result[strategy].items():
            source_db, target_db = dataset.split("-")
            dataset_name = schema_name_mapping[source_db] + "-" + schema_name_mapping[target_db]
            rows.append(
                [
                    dataset_name,
                    strategy_name,
                    experimen_result.precision,
                    experimen_result.recall,
                    experimen_result.f1_score,
                ]
            )
            result[strategy_name][dataset] = [
                experimen_result.precision,
                experimen_result.recall,
                experimen_result.f1_score,
            ]
    # write to csv
    import csv
    import os

    script_dir = os.path.dirname(__file__)
    file_path = os.path.join(
        script_dir,
        "../..",
        "dataset/match_result/effect_of_schema_rewrite.csv",
    )
    with open(file_path, "w", newline="") as file:
        writer = csv.writer(file)
        writer.writerows(rows)
    return result


def effect_of_foreign_key():
    full_result = get_full_results()
    strategy_mappings = [
        (
            "schema_understanding_no_reasoning Rewrite: gpt-3.5-turbo Matching: gpt-4o",
            "With Foreign Key",
        ),
        (
            "schema_understanding_no_foreign_keys Rewrite: gpt-3.5-turbo Matching: gpt-4o",
            "Without Foreign Key",
        ),
    ]
    result = defaultdict(lambda: defaultdict(list))
    rows = [["dataset", "Mathing Strategy", "P", "Recall", "f1"]]
    for strategy, strategy_name in strategy_mappings:
        for dataset, experimen_result in full_result[strategy].items():
            source_db, target_db = dataset.split("-")
            dataset_name = schema_name_mapping[source_db] + "-" + schema_name_mapping[target_db]
            rows.append(
                [
                    dataset_name,
                    strategy_name,
                    experimen_result.precision,
                    experimen_result.recall,
                    experimen_result.f1_score,
                ]
            )
            result[strategy_name][dataset] = [
                experimen_result.precision,
                experimen_result.recall,
                experimen_result.f1_score,
            ]
    # write to csv
    import csv
    import os

    script_dir = os.path.dirname(__file__)
    file_path = os.path.join(
        script_dir,
        "../..",
        "dataset/match_result/effect_of_foreign_key.csv",
    )
    with open(file_path, "w", newline="") as file:
        writer = csv.writer(file)
        writer.writerows(rows)
    return result


def effect_of_reasoning():
    strategy_mappings = [
        (
            "schema_understanding_no_reasoning Rewrite: gpt-3.5-turbo Matching: gpt-4o",
            "No Reasoning",
        ),
        (
            "schema_understanding Rewrite: gpt-3.5-turbo Matching: gpt-4o",
            "Reasoning",
        ),
    ]
    return parameter_study(strategy_mappings, "effect_of_reasoning.csv")


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
