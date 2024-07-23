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
    from llm_ontology_alignment.alignment_strategies.evaluation import (
        print_result_one_to_many,
    )

    print_result_one_to_many(run_specs)


def test_print_result():
    from llm_ontology_alignment.alignment_strategies.evaluation import print_table_mapping_result

    # import_ground_truth()
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
        "rewrite_llm": "gpt-4o",
        "strategy": "schema_understanding",
        "template": "top2-no-na",
    }
    run_specs = {key: run_specs[key] for key in sorted(run_specs.keys())}
    if False:
        from llm_ontology_alignment.data_processors.rewrite_db_schema import rewrite_db_columns

        rewrite_db_columns(run_specs)
        from llm_ontology_alignment.data_processors.load_data import load_schema_constraint_sql

        load_schema_constraint_sql(run_specs["source_db"])
        load_schema_constraint_sql(run_specs["target_db"])
    # OntologyAlignmentExperimentResult.objects(run_id_prefix=json.dumps(run_specs)).delete()
    print_table_mapping_result(run_specs)

    from llm_ontology_alignment.alignment_strategies.schema_understanding import get_table_mapping

    primary_key_mapping_result = get_table_mapping(run_specs)
    # from llm_ontology_alignment.alignment_strategies.schema_understanding import run_matching_with_schema_understanding
    #
    # run_matching_with_schema_understanding(run_specs)
    # from llm_ontology_alignment.alignment_strategies.evaluation import print_result_one_to_many
    #
    # print_result_one_to_many(run_specs)
