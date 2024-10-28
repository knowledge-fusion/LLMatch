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
    # OntologyMatchingEvaluationReport.objects.update(unset__details=True)
    run_specs = {
        "column_matching_llm": "gpt-4o-mini",
        "column_matching_strategy": "llm",
        "rewrite_llm": "gpt-4o",
        "source_db": "synthea",
        "table_selection_llm": "gpt-4o-mini",
        "table_selection_strategy": "llm",
        "target_db": "omop",
    }
    from llm_ontology_alignment.table_selection.llm_selection import get_llm_table_selection_result

    res = get_llm_table_selection_result(run_specs, refresh_existing_result=True)

    run_schema_matching_evaluation(run_specs, refresh_existing_result=True)


def test_compare_performance():
    flt = {
        "column_matching_llm": "gpt-4o-mini",
        "column_matching_strategy": "llm",
        "rewrite_llm": "original",
        "source_database": "synthea",
        "table_selection_llm": "gpt-4o-mini",
        "table_selection_strategy": "llm",
        "target_database": "omop",
    }
    from llm_ontology_alignment.data_models.evaluation_report import OntologyMatchingEvaluationReport

    result = OntologyMatchingEvaluationReport.objects(**flt).first()
    print("\nOriginal", result.precision, result.recall, result.f1_score)
    details1 = result.details
    flt["rewrite_llm"] = "gpt-4o"
    result = OntologyMatchingEvaluationReport.objects(**flt).first()
    print("GPT-4o", result.precision, result.recall, result.f1_score)
    details2 = result.details
    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite

    translation_map = {}
    for item in OntologySchemaRewrite.objects(
        database__in=[flt["source_database"], flt["target_database"]],
        llm_model=flt["rewrite_llm"],
    ):
        translation_map[f"{item.table}.{item.column}"] = f"{item.original_table}.{item.original_column}"

    result = {}
    tables = []
    for key in details2:
        original_result = details1[translation_map[key]]
        if (
            len(original_result["TP"]) > len(details2[key]["TP"])
            or len(original_result["FP"]) < len(details2[key]["FP"])
            or len(original_result["FN"]) < len(details2[key]["FN"])
        ):
            print("\n", key)
            print(
                "TP", len(original_result["TP"]), len(details2[key]["TP"]), original_result["TP"], details2[key]["TP"]
            )
            print(
                "FP", len(original_result["FP"]), len(details2[key]["FP"]), original_result["FP"], details2[key]["FP"]
            )
            print(
                "FN", len(original_result["FN"]), len(details2[key]["FN"]), original_result["FN"], details2[key]["FN"]
            )
            print("Expected", list(f"{item} ({translation_map[item]})" for item in details2[key]["Expected"]))
            print("Result", original_result["Predicted"], details2[key]["Predicted"])
            tables.append(key.split(".")[0])
        result[key] = {"original": original_result, "gpt-4o": details2[key]}
    print(tables)
    # print(json.dumps(result, indent=2))


def test_print_result():
    run_specs = {
        "source_db": "cms",
        "target_db": "omop",
        "rewrite_llm": "gpt-4o",
        "table_selection_strategy": "llm",
        "table_selection_llm": "gpt-4o-mini",
        "column_matching_strategy": "llm",
        "column_matching_llm": "gpt-4o-mini",
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
