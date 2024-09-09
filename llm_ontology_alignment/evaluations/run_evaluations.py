from llm_ontology_alignment.constants import EXPERIMENTS


def run_valentine_experiments():
    rewrite_llms = ["original", "gpt-3.5-turbo", "gpt-4o"]
    table_selection_strategies = [
        "None",
        "table_to_table_vector_similarity",
        "column_to_table_vector_similarity",
        "nested_join",
        "llm",
    ]
    table_selection_llms = ["gpt-3.5-turbo", "gpt-4o"]

    for column_matching_strategy in ["coma", "similarity_flooding"]:
        for table_selection_strategy in table_selection_strategies:
            for dataset in EXPERIMENTS:
                for llm in ["gpt-3.5-turbo"]:
                    source_db, target_db = dataset.split("-")
                    run_specs = {
                        "source_db": source_db,
                        "target_db": target_db,
                        "rewrite_llm": llm,
                        "table_selection_strategy": table_selection_strategy,
                        "table_selection_llm": "None",
                        "column_matching_strategy": column_matching_strategy,
                        "column_matching_llm": "None",
                    }
                    if table_selection_strategy == "llm":
                        run_specs["table_selection_llm"] = "gpt-3.5-turbo"
                    from llm_ontology_alignment.evaluations.calculate_result import run_schema_matching_evaluation

                    run_schema_matching_evaluation(run_specs)


def run_schema_understanding_evaluations():
    rewrite_llms = ["gpt-3.5-turbo", "gpt-4o"]
    table_selection_strategies = [
        "table_to_table_vector_similarity",
        "table_to_table_top_10_vector_similarity"
        "nested_join",
        "column_to_table_vector_similarity",
        "llm",
        "llm-limit_context",
    ]
    table_selection_llms = ["gpt-3.5-turbo", "gpt-4o"]

    # for column_matching_strategy in ["llm"]:
    for context_size in reversed([2000, 4000, 6000, 8000, 10000, 12000]):
        for table_selection_strategy in table_selection_strategies[-1:]:
            for dataset in EXPERIMENTS:
                for llm in table_selection_llms:
                    source_db, target_db = dataset.split("-")
                    run_specs = {
                        "source_db": source_db,
                        "target_db": target_db,
                        "rewrite_llm": "original",
                        "table_selection_strategy": table_selection_strategy,
                        "table_selection_llm": llm,
                        "column_matching_strategy": "llm",
                        "column_matching_llm": llm,
                        "context_size": context_size,
                    }
                    from llm_ontology_alignment.evaluations.calculate_result import table_selection_func_map

                    table_selections = table_selection_func_map[run_specs["table_selection_strategy"]](run_specs)
                    from llm_ontology_alignment.evaluations.ontology_matching_evaluation import \
                        print_table_mapping_result
                    table_selection_result = print_table_mapping_result(run_specs)
                    print(
                        f"{run_specs['context_size']=} {run_specs['table_selection_llm']=} {run_specs['source_db']}-{run_specs['target_db']} {table_selection_result}")

                    # from llm_ontology_alignment.evaluations.calculate_result import run_schema_matching_evaluation

                    # run_schema_matching_evaluation(run_specs, refresh_rewrite=True)


if __name__ == "__main__":
    run_schema_understanding_evaluations()
