def test_matching_with_schema_understanding():
    run_specs = {
        "source_db": "cprd_aurum",
        "target_db": "omop",
        "matching_llm": "gpt-3.5-turbo",
        "rewrite_llm": "gpt-3.5-turbo",
        "strategy": "schema_understanding",
    }

    run_specs = {key: run_specs[key] for key in sorted(run_specs.keys())}
    from llm_ontology_alignment.alignment_strategies.schema_understanding import run_matching

    run_matching(run_specs)


def test_print_result_one_to_many():
    from llm_ontology_alignment.alignment_strategies.print_result import print_result_one_to_many

    # import_ground_truth()
    run_specs = {
        "source_db": "mimic_iii",
        "target_db": "omop",
        "matching_llm": "gpt-4o",
        "rewrite_llm": "gpt-4o",
        "strategy": "schema_understanding",
    }
    print_result_one_to_many(run_specs)
