def test_print_result():
    from llm_ontology_alignment.data_processors.load_data import import_ground_truth

    import_ground_truth()
    from llm_ontology_alignment.data_processors.load_data import import_coma_matching_result

    import_coma_matching_result()
    run_specs = {
        "source_db": "cprd_aurum",
        "target_db": "omop",
        "rewrite_llm": "gpt-3.5-turbo",
        "strategy": "coma",
    }
    from llm_ontology_alignment.alignment_strategies.print_result import (
        print_result_one_to_many,
    )

    print_result_one_to_many(run_specs)
