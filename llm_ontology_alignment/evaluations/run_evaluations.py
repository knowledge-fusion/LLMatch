from llm_ontology_alignment.constants import EXPERIMENTS


def run_valentine_experiments():
    rewrite_llms = ["original", "gpt-3.5-turbo", "gpt-4o"]
    table_selection_strategies = [
        "table_to_table_vector_similarity",
        "None",
        "column_to_table_vector_similarity",
        "nested_join",
        "llm",
    ]
    table_selection_llms = ["gpt-3.5-turbo", "gpt-4o"]

    for column_matching_strategy in ["coma", "similarity_flooding"]:
        for table_selection_strategy in table_selection_strategies[:-1]:
            for dataset in EXPERIMENTS:
                for llm in ["gpt-4o", "gpt-3.5-turbo"]:
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
                    from llm_ontology_alignment.evaluations.calculate_result import run_schema_matching_evaluation

                    run_schema_matching_evaluation(run_specs)


def run_schema_understanding_evaluations():
    rewrite_llms = ["original", "gpt-3.5-turbo", "gpt-4o"]
    table_selection_strategies = [
        "table_to_table_vector_similarity",
        "nested_join",
        "column_to_table_vector_similarity",
        "llm",
    ]
    table_selection_llms = ["gpt-3.5-turbo", "gpt-4o"]

    for column_matching_strategy in ["llm"]:
        for table_selection_strategy in table_selection_strategies[:-1]:
            for dataset in EXPERIMENTS:
                for llm in [
                    "gpt-3.5-turbo",
                    "gpt-4o",
                ]:
                    source_db, target_db = dataset.split("-")
                    run_specs = {
                        "source_db": source_db,
                        "target_db": target_db,
                        "rewrite_llm": llm,
                        "table_selection_strategy": table_selection_strategy,
                        "table_selection_llm": "None",
                        "column_matching_strategy": column_matching_strategy,
                        "column_matching_llm": llm,
                        # "strategy": "schema_understanding",
                    }
                    from llm_ontology_alignment.evaluations.calculate_result import run_schema_matching_evaluation

                    run_schema_matching_evaluation(run_specs)


if __name__ == "__main__":
    run_valentine_experiments()
