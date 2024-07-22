def test_print_result():
    from llm_ontology_alignment.alignment_strategies.evaluation import print_table_mapping_result

    # import_ground_truth()
    # import_coma_matching_result()
    # run_specs = {
    #     "source_db": "cprd_aurum",
    #     "target_db": "omop",
    #     "rewrite_llm": "gpt-3.5-turbo",
    #     "strategy": "schema-understanding",
    #
    # }
    run_specs = {
        "source_db": "mimic_iii",
        "target_db": "omop",
        "matching_llm": "gpt-4o",
        "rewrite_llm": "gpt-3.5-turbo",
        "strategy": "schema_understanding",
        "template": "top2-no-na",
    }
    run_specs = {key: run_specs[key] for key in sorted(run_specs.keys())}

    # OntologyAlignmentExperimentResult.objects(run_id_prefix=json.dumps(run_specs)).delete()
    print_table_mapping_result(run_specs)
    from llm_ontology_alignment.alignment_strategies.schema_understanding import get_primary_key_matches

    primary_key_mapping_result = get_primary_key_matches(run_specs)

    # print_result_one_to_many(run_specs)
