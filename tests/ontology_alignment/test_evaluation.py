from collections import defaultdict

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
        "source_db": "imdb",
        "target_db": "sakila",
        "table_selection_llm": "gpt-4o-mini",
        "table_selection_strategy": "llm",
    }

    # res = get_llm_table_selection_result(run_specs, refresh_existing_result=False)

    run_schema_matching_evaluation(run_specs, refresh_existing_result=False)


def test_compare_performance():
    flt = {
        "source_database": "imdb",
        "target_database": "sakila",
        "column_matching_llm": "gpt-4o-mini",
        "column_matching_strategy": "llm",
        "rewrite_llm": "original",
        "table_selection_llm": "gpt-4o-mini",
        "table_selection_strategy": "llm",
    }
    from llm_ontology_alignment.data_models.evaluation_report import OntologyMatchingEvaluationReport

    # table_selection1 = get_llm_table_selection_result(flt)

    result = OntologyMatchingEvaluationReport.objects(**flt).first()
    print("\nOriginal", result.precision, result.recall, result.f1_score)
    details1 = result.details
    flt["rewrite_llm"] = "gpt-4o"
    result = OntologyMatchingEvaluationReport.objects(**flt).first()
    print("GPT-4o", result.precision, result.recall, result.f1_score)
    details2 = result.details
    assert details1
    assert details2

    # table_selection2 = get_llm_table_selection_result(flt)

    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite

    translation_map = defaultdict(dict)
    for item in OntologySchemaRewrite.objects(
        database__in=[flt["source_database"], flt["target_database"]],
        llm_model=flt["rewrite_llm"],
    ):
        translation_map[item.database][f"{item.table}.{item.column}"] = f"{item.original_table}.{item.original_column}"

    result = {}
    tables = []
    for key in details2:
        original_result = details1.get(translation_map[flt["source_database"]][key], {})
        if not original_result:
            original_result
        if (
            len(original_result["TP"]) != len(details2[key]["TP"])
            or len(original_result["FP"]) != len(details2[key]["FP"])
            or len(original_result["FN"]) != len(details2[key]["FN"])
        ):
            print("\n", key, translation_map[flt["source_database"]][key])
            print("TP", original_result["TP"], details2[key]["TP"])
            print("FP", original_result["FP"], details2[key]["FP"])
            print("FN", original_result["FN"], details2[key]["FN"])
            print(
                "Expected",
                list(f"{item} ({translation_map[flt['target_database']][item]})" for item in details2[key]["Expected"]),
            )
            print("Result", original_result["Predicted"], details2[key]["Predicted"])
            # print(
            #     "Table Selection",
            #     table_selection1[translation_map[flt["source_database"]][key].split(".")[0]],
            #     table_selection2[key.split(".")[0]],
            # )
        result[key] = {"original": original_result, "gpt-4o": details2[key]}
    print(tables)
    # print(json.dumps(result, indent=2))


def test_print_result():
    run_specs = {
        "source_db": "imdb",
        "target_db": "sakila",
        "rewrite_llm": "gpt-4o",
        "table_selection_strategy": "llm",
        "table_selection_llm": "gpt-4o-mini",
        "column_matching_strategy": "llm",
        "column_matching_llm": "gpt-4o-mini",
        # "context_size": context_size,
    }
    from llm_ontology_alignment.table_selection.llm_selection import get_llm_table_selection_result
    from llm_ontology_alignment.data_models.experiment_models import OntologyAlignmentExperimentResult

    refresh = False
    if refresh:
        res = OntologyAlignmentExperimentResult.objects(
            operation_specs__operation="table_candidate_selection",
            operation_specs__table_selection_llm=run_specs["table_selection_llm"],
            operation_specs__source_db=run_specs["source_db"],
            operation_specs__target_db=run_specs["target_db"],
            operation_specs__rewrite_llm=run_specs["rewrite_llm"],
            operation_specs__table_selection_strategy=run_specs["table_selection_strategy"],
        ).delete()
        print(res)
    res = get_llm_table_selection_result(run_specs)
    run_schema_matching_evaluation(run_specs, refresh_existing_result=refresh)


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
