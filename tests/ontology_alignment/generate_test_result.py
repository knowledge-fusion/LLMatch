def print_result():
    run_specs = {
        "source_db": "cprd_aurum",
        "target_db": "omop",
        "matching_llm": "gpt-4o",
        "rewrite_llm": "gpt-3.5-turbo",
        "strategy": "coma",
        "template": "top2-no-na",
        "use_translation": False,
    }
    from llm_ontology_alignment.alignment_strategies.print_result import (
        print_result_one_to_many,
    )

    print_result_one_to_many(run_specs)
