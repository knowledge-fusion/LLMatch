from llm_ontology_alignment.evaluations.calculate_result import run_schema_matching_evaluation, recalculate_result


def test_update_llm_based_experiment_result():
    from llm_ontology_alignment.data_models.evaluation_report import OntologyMatchingEvaluationReport

    version = 2
    from llm_ontology_alignment.evaluations.latex_report.full_experiment_f1_score import schema_name_mapping

    for item in OntologyMatchingEvaluationReport.objects(
        strategy__in=["coma"], source_database__in=list(schema_name_mapping.keys()), rewrite_llm="original"
    ):
        run_specs = {
            "source_db": item.source_database,
            "target_db": item.target_database,
            "strategy": item.strategy,
            "rewrite_llm": item.rewrite_llm,
        }

        if item.matching_llm:
            run_specs["matching_llm"] = item.matching_llm
        try:
            run_schema_matching_evaluation(run_specs)
        except Exception as e:
            raise


def test_save_alignment_result():
    datasets = ["omop-cms", "imdb-sakila", "mimic_iii-omop", "cprd_aurum-omop", "cprd_gold-omop"]
    for dataset in datasets[0:1]:
        source_db, target_db = dataset.split("-")
        for llm_model in ["gpt-4o"]:
            run_specs = {
                "source_db": source_db,
                "target_db": target_db,
                "strategy": "schema_understanding_no_reasoning",
                "rewrite_llm": "gpt-3.5-turbo",
                "matching_llm": llm_model,
            }

            run_schema_matching_evaluation(run_specs, refresh_existing_result=False)


def test_print_result():
    run_specs = {
        "source_db": "cprd_gold",
        "target_db": "omop",
        "matching_llm": "gpt-3.5-turbo",
        "rewrite_llm": "gpt-4o",
        "strategy": "schema_understanding_no_reasoning",
    }
    run_specs = {key: run_specs[key] for key in sorted(run_specs.keys())}
    # import_ground_truth(run_specs["source_db"], run_specs["target_db"])

    run_schema_matching_evaluation(run_specs, refresh_existing_result=True)


def test_print_all_result():
    from llm_ontology_alignment.evaluations.ontology_matching_evaluation import all_strategy_f1

    all_strategy_f1()


def test_recalculate_result():
    recalculate_result()

