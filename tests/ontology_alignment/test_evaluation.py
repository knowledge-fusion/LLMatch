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
    run_specs = {
        "column_matching_llm": "gpt-4o-mini",
        "column_matching_strategy": "llm",
        "rewrite_llm": "original",
        "source_db": "cprd_aurum",
        "table_selection_llm": "gpt-3.5-turbo",
        "table_selection_strategy": "llm",
        "target_db": "omop",
    }

    run_schema_matching_evaluation(run_specs, refresh_existing_result=False)


def test_print_result():
    run_specs = {
        "source_db": "cms",
        "target_db": "omop",
        "rewrite_llm": "original",
        "table_selection_strategy": "llm",
        "table_selection_llm": "gpt-4o",
        "column_matching_strategy": "llm",
        "column_matching_llm": "gpt-4o",
        # "context_size": context_size,
    }
    from llm_ontology_alignment.table_selection.llm_selection import get_llm_table_selection_result

    res = get_llm_table_selection_result(run_specs)
    run_schema_matching_evaluation(run_specs, refresh_existing_result=True)


def test_print_all_result():
    from llm_ontology_alignment.evaluations.ontology_matching_evaluation import all_strategy_f1

    all_strategy_f1()


def test_model_family_studies():
    from llm_ontology_alignment.evaluations.ontology_matching_evaluation import model_family_studies

    res = model_family_studies()
    print(res)


def test_table_selection_strategies():
    from llm_ontology_alignment.evaluations.ontology_matching_evaluation import table_selection_strategies

    res = table_selection_strategies()
    print(res)


def test_recalculate_result():
    recalculate_result()


def test_effect_of_rewrite_gpt35():
    from llm_ontology_alignment.evaluations.extended_study_evaluation import effect_of_rewrite_gpt35

    effect_of_rewrite_gpt35()


def test_gpt4_family_difference():
    from llm_ontology_alignment.evaluations.extended_study_evaluation import gpt4_family_difference

    gpt4_family_difference()
