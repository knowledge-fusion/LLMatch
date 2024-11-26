def test_matching_with_schema_understanding():
    run_specs = {
        "source_db": "cprd_aurum",
        "target_db": "omop",
        "matching_llm": "gpt-3.5-turbo",
        "rewrite_llm": "gpt-3.5-turbo",
        "strategy": "schema_understanding",
    }

    run_specs = {key: run_specs[key] for key in sorted(run_specs.keys())}
    from schema_match.column_match.schema_understanding import run_matching

    run_matching(run_specs)
