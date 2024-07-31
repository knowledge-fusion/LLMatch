import json


def test_save_coma_alignment_result():
    from llm_ontology_alignment.alignment_strategies.valentine_alignment import get_predictions

    from llm_ontology_alignment.evaluations.evaluation import calculate_result_one_to_many

    datasets = ["omop-cms", "imdb-sakila", "mimic_iii-omop", "cprd_aurum-omop", "cprd_gold-omop"]
    for dataaset in datasets:
        source_db, target_db = dataaset.split("-")
        for llm_model in ["gpt-4o", "gpt-3.5-turbo", "original"]:
            run_specs = {
                "source_db": source_db,
                "target_db": target_db,
                "strategy": "similarity_flooding",
                "rewrite_llm": llm_model,
            }
            # save_coma_alignment_result(run_specs)
            calculate_result_one_to_many(run_specs, get_predictions_func=get_predictions)


def test_print_result():
    from llm_ontology_alignment.evaluations.evaluation import print_table_mapping_result

    run_specs = {
        "source_db": "omop",
        "target_db": "cms",
        "matching_llm": "gpt-4o",
        "rewrite_llm": "gpt-3.5-turbo",
        "strategy": "schema_understanding_no_reasoning",
    }
    run_specs = {key: run_specs[key] for key in sorted(run_specs.keys())}
    # import_ground_truth(run_specs["source_db"], run_specs["target_db"])

    rewrite = False
    if rewrite:
        from llm_ontology_alignment.data_processors.rewrite_db_schema import rewrite_db_columns

        rewrite_db_columns(run_specs)
        from llm_ontology_alignment.data_processors.load_data import update_rewrite_schema_constraints

        update_rewrite_schema_constraints(run_specs["source_db"])
        update_rewrite_schema_constraints(run_specs["target_db"])

    from llm_ontology_alignment.data_models.experiment_models import OntologyAlignmentExperimentResult

    OntologyAlignmentExperimentResult.objects(run_id_prefix=json.dumps(run_specs)).delete()
    run_id_prefix = json.dumps(run_specs)
    print("\n", run_id_prefix)
    print_table_mapping_result(run_specs)

    from llm_ontology_alignment.alignment_strategies.schema_understanding import run_matching, get_predictions

    run_matching(run_specs)
    from llm_ontology_alignment.evaluations.evaluation import calculate_result_one_to_many

    calculate_result_one_to_many(run_specs, get_predictions_func=get_predictions)


def test_print_all_result():
    from llm_ontology_alignment.evaluations.evaluation import all_strategy_f1

    all_strategy_f1()


def test_temp():
    from llm_ontology_alignment.evaluations.single_table_alignment import run_gpt_evaluation

    run_gpt_evaluation()
