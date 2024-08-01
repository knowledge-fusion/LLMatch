from llm_ontology_alignment.evaluations.evaluation import run_schema_matching_evaluation


def test_update_llm_based_experiment_result():
    from llm_ontology_alignment.data_models.experiment_models import OntologyMatchingEvaluationReport
    from llm_ontology_alignment.alignment_strategies.rematch import get_predictions as rematch_get_predictions
    from llm_ontology_alignment.alignment_strategies.schema_understanding import (
        get_predictions as schema_understanding_get_predictions,
    )
    from llm_ontology_alignment.alignment_strategies.coma_alignment import get_predictions as coma_get_predictions
    from llm_ontology_alignment.alignment_strategies.valentine_alignment import (
        get_predictions as valentine_get_predictions,
    )
    from llm_ontology_alignment.evaluations.evaluation import calculate_result_one_to_many

    func_map = {
        "rematch": rematch_get_predictions,
        "schema_understanding_no_reasoning": schema_understanding_get_predictions,
        "schema_understanding": schema_understanding_get_predictions,
        "coma": coma_get_predictions,
        "similarity_flooding": valentine_get_predictions,
        "cupid": valentine_get_predictions,
    }
    version = 1
    for item in OntologyMatchingEvaluationReport.objects(strategy__in=list(func_map.keys()), version__ne=version):
        run_specs = {
            "source_db": item.source_database,
            "target_db": item.target_database,
            "strategy": item.strategy,
            "rewrite_llm": item.rewrite_llm,
        }

        if item.matching_llm:
            run_specs["matching_llm"] = item.matching_llm
        try:
            calculate_result_one_to_many(run_specs, get_predictions_func=func_map[item.strategy])
        except Exception as e:
            print(e)
            print(run_specs)
            continue


def test_save_alignment_result():
    from llm_ontology_alignment.alignment_strategies.rematch import get_predictions

    from llm_ontology_alignment.evaluations.evaluation import calculate_result_one_to_many

    datasets = ["omop-cms", "imdb-sakila", "mimic_iii-omop", "cprd_aurum-omop", "cprd_gold-omop"]
    for dataset in datasets[0:1]:
        source_db, target_db = dataset.split("-")
        for llm_model in ["gpt-4o"]:
            run_specs = {
                "source_db": source_db,
                "target_db": target_db,
                "strategy": "rematch",
                "rewrite_llm": llm_model,
                "matching_llm": llm_model,
            }
            # save_coma_alignment_result(run_specs)
            calculate_result_one_to_many(run_specs, get_predictions_func=get_predictions)


def test_print_result():
    run_specs = {
        "source_db": "mimic_iii",
        "target_db": "omop",
        "matching_llm": "gpt-3.5-turbo",
        "rewrite_llm": "original",
        "strategy": "rematch",
    }
    run_specs = {key: run_specs[key] for key in sorted(run_specs.keys())}
    # import_ground_truth(run_specs["source_db"], run_specs["target_db"])

    run_schema_matching_evaluation(run_specs)


def test_print_all_result():
    from llm_ontology_alignment.evaluations.evaluation import all_strategy_f1

    all_strategy_f1()


def test_temp():
    from llm_ontology_alignment.evaluations.single_table_alignment import run_gpt_evaluation

    run_gpt_evaluation()
