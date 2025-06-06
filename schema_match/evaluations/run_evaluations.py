from collections import defaultdict

from schema_match.constants import EXPERIMENTS


def run_valentine_experiments():
    rewrite_llms = ["original", "gpt-3.5-turbo"]
    table_selection_strategies = [
        "None",
        "table_to_table_vector_similarity",
        "column_to_table_vector_similarity",
        "nested_join",
        "llm",
        "ground_truth",
    ]
    table_selection_llms = ["gpt-3.5-turbo", "gpt-4o"]

    for column_matching_strategy in ["coma", "similarity_flooding", "cupid"][0:2]:
        for table_selection_strategy in table_selection_strategies[1:2]:
            for dataset in EXPERIMENTS:
                for llm in rewrite_llms:
                    source_db, target_db = dataset.split("-")
                    run_specs = {
                        "source_db": source_db,
                        "target_db": target_db,
                        "rewrite_llm": llm,
                        "table_selection_strategy": "ground_truth",
                        "table_selection_llm": "None",
                        "column_matching_strategy": column_matching_strategy,
                        "column_matching_llm": "None",
                    }
                    if table_selection_strategy == "llm":
                        run_specs["table_selection_llm"] = "gpt-3.5-turbo"
                    from schema_match.evaluations.calculate_result import (
                        run_schema_matching_evaluation,
                    )

                    run_schema_matching_evaluation(run_specs)


def run_schema_understanding_evaluations():
    from itertools import product

    rewrite_llms = ["gpt-3.5-turbo", "gpt-4o"]
    table_selection_strategies = [
        # "table_to_table_top_10_vector_similarity",
        # "llm-limit_context",
        # "llm",
        "None",
        "nested_join",
        "table_to_table_vector_similarity",
        "column_to_table_vector_similarity",
        "ground_truth",
    ]
    table_selection_llms = ["gpt-4o-mini"]
    context_sizes = [100, 200, 500, 1000, 2000, 5000, 10000, 20000]
    experiments = list(
        product(
            context_sizes[-1:],
            table_selection_strategies,
            table_selection_llms,
            EXPERIMENTS,
        )
    )
    # random.shuffle(experiments)

    for experiment in experiments:
        context_size, table_selection_strategy, llm, dataset = experiment
        source_db, target_db = dataset.split("-")
        run_specs = {
            "source_db": source_db,
            "target_db": target_db,
            "rewrite_llm": "gpt-3.5-turbo",
            "table_selection_strategy": "ground_truth",
            "table_selection_llm": "None",
            "column_matching_strategy": "llm-rematch",
            "column_matching_llm": "gpt-4o-mini",
            # "context_size": context_size,
        }
        from schema_match.evaluations.calculate_result import table_selection_func_map

        if table_selection_strategy.find("llm") > -1:
            run_specs["table_selection_llm"] = "gpt-4o"
        table_selections = table_selection_func_map[
            run_specs["table_selection_strategy"]
        ](run_specs)
        from schema_match.evaluations.calculate_result import (
            run_schema_matching_evaluation,
        )

        run_schema_matching_evaluation(run_specs, refresh_existing_result=False)

        # table_selection_result = print_table_mapping_result(run_specs)
        print(f" {run_specs=} {run_specs['source_db']}-{run_specs['target_db']}")


def run_context_size_evaluations():
    context_sizes = [1000, 2000, 5000, 10000]
    result = defaultdict(dict)
    for experiment in EXPERIMENTS[2:3]:
        for context_size in context_sizes[1:2]:
            source_db, target_db = experiment.split("-")
            run_specs = {
                "source_db": source_db,
                "target_db": target_db,
                "rewrite_llm": "original",
                "table_selection_strategy": "llm-limit_context",
                "table_selection_llm": "gpt-4o-mini",
                "column_matching_strategy": "llm-limit_context",
                "column_matching_llm": "gpt-4o-mini",
                "context_size": context_size,
            }

            # table_selections = table_selection_func_map[run_specs["table_selection_strategy"]](run_specs)
            from schema_match.evaluations.calculate_result import (
                run_schema_matching_evaluation,
            )

            res = run_schema_matching_evaluation(
                run_specs, refresh_existing_result=False
            )
            result[experiment][context_size] = res.f1_score
            # table_selection_result = print_table_mapping_result(run_specs)
    return result


if __name__ == "__main__":
    run_schema_understanding_evaluations()

    run_valentine_experiments()
