from collections import defaultdict

from schema_match.evaluations.calculate_result import (
    run_schema_matching_evaluation,
    recalculate_result,
    table_selection_func_map,
)


def test_update_llm_based_experiment_result():
    from schema_match.data_models.evaluation_report import (
        OntologyMatchingEvaluationReport,
    )

    version = 2
    from schema_match.evaluations.latex_report.full_experiment_f1_score import (
        schema_name_mapping,
    )

    for item in OntologyMatchingEvaluationReport.objects(
        strategy__in=["coma"],
        source_database__in=list(schema_name_mapping.keys()),
        rewrite_llm="original",
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
        "column_matching_llm": "gpt-3.5-turbo",
        "column_matching_strategy": "llm",
        "rewrite_llm": "original",
        "source_db": "cprd_aurum",
        "target_db": "omop",
        "table_selection_llm": "gpt-3.5-turbo",
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
    from schema_match.data_models.evaluation_report import (
        OntologyMatchingEvaluationReport,
    )

    # table_selection1 = get_llm_table_selection_result(flt)
    run_schema_matching_evaluation(flt.copy(), refresh_existing_result=False)

    result = OntologyMatchingEvaluationReport.objects(**flt).first()
    print("\nOriginal", result.precision, result.recall, result.f1_score)
    details1 = result.details
    flt["rewrite_llm"] = "gpt-4o"
    run_schema_matching_evaluation(flt.copy(), refresh_existing_result=False)
    result = OntologyMatchingEvaluationReport.objects(**flt).first()
    print("GPT-4o", result.precision, result.recall, result.f1_score)
    details2 = result.details
    assert details1
    assert details2

    # table_selection2 = get_llm_table_selection_result(flt)

    from schema_match.data_models.experiment_models import OntologySchemaRewrite

    translation_map = defaultdict(dict)
    for item in OntologySchemaRewrite.objects(
        database__in=[flt["source_database"], flt["target_database"]],
        llm_model=flt["rewrite_llm"],
    ):
        translation_map[item.database][f"{item.table}.{item.column}"] = (
            f"{item.original_table}.{item.original_column}"
        )

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
                list(
                    f"{item} ({translation_map[flt['target_database']][item]})"
                    for item in details2[key]["Expected"]
                ),
            )
            print(
                "Result",
                original_result["Predicted"],
                list(
                    f"{item} ({translation_map[flt['target_database']][item]})"
                    for item in details2[key]["Predicted"]
                ),
            )
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
        "rewrite_llm": "original",
        "table_selection_strategy": "llm",
        "table_selection_llm": "gpt-4o-mini",
        "column_matching_strategy": "llm",
        "column_matching_llm": "gpt-4o-mini",
        # "context_size": context_size,
    }
    from schema_match.data_models.experiment_models import (
        OntologyAlignmentExperimentResult,
    )

    refresh = False
    if refresh:
        res = OntologyAlignmentExperimentResult.objects(
            operation_specs__operation="table_candidate_selection",
            operation_specs__table_selection_llm=run_specs["table_selection_llm"],
            operation_specs__source_db=run_specs["source_db"],
            operation_specs__target_db=run_specs["target_db"],
            operation_specs__rewrite_llm=run_specs["rewrite_llm"],
            operation_specs__table_selection_strategy=run_specs[
                "table_selection_strategy"
            ],
        ).delete()
        print(res)
    # res = get_llm_table_selection_result(run_specs)
    res = run_schema_matching_evaluation(run_specs, refresh_existing_result=False)
    print(res.f1_score)


def test_print_all_result():
    from schema_match.evaluations.ontology_matching_evaluation import all_strategy_f1

    # import_coma_matching_result()
    all_strategy_f1()


def test_model_family_studies():
    from schema_match.evaluations.ontology_matching_evaluation import (
        model_family_studies,
    )

    res = model_family_studies()
    print(res)


def test_table_selection_strategies():
    from schema_match.evaluations.ontology_matching_evaluation import (
        table_selection_strategies,
    )

    res = table_selection_strategies()
    print(res)


def test_table_selection_strategies_output_size():
    from schema_match.evaluations.latex_report.full_experiment_f1_score import (
        EXPERIMENTS,
    )

    result = defaultdict(dict)

    for table_selection_strategy, table_selection_llm in [
        ("None", "None"),
        ("nested_join", "None"),
        # ("column_to_table_vector_similarity", "None"),
        ("table_to_table_vector_similarity", "None"),
        ("table_to_table_top_10_vector_similarity", "None"),
        ("table_to_table_top_15_vector_similarity", "None"),
        ("llm", "gpt-3.5-turbo"),
        ("llm", "gpt-4o"),
    ]:
        for dataset in EXPERIMENTS:
            source_db, target_db = dataset.split("-")
            flt = {
                "source_database": source_db,
                "target_database": target_db,
                "rewrite_llm": "original",
                "column_matching_strategy": "llm",
                "column_matching_llm": "gpt-4o-mini",
                "table_selection_strategy": table_selection_strategy,
                "table_selection_llm": table_selection_llm,
            }
            # queryset.delete()
            if True:
                run_specs = {
                    "source_db": source_db,
                    "target_db": target_db,
                    "rewrite_llm": "original",
                    "column_matching_strategy": "llm",
                    "column_matching_llm": "gpt-4o-mini",
                    "table_selection_strategy": table_selection_strategy,
                    "table_selection_llm": table_selection_llm,
                }
                table_selections, token_count = table_selection_func_map[
                    run_specs["table_selection_strategy"]
                ](run_specs, refresh_existing_result=False)

                key = f"{run_specs['table_selection_strategy']}-{run_specs['table_selection_llm']}"
                experiments = []
                for source_table, target_tables in table_selections.items():
                    if not target_tables:
                        continue
                    if isinstance(target_tables[0], str):
                        experiments.append((source_table, target_tables))
                    else:
                        for subtargets in target_tables:
                            assert isinstance(subtargets[0], str)
                            experiments.append((source_table, subtargets))
                # if record.column_matching_llm:
                #     key += f" Matching: {record.column_matching_llm}|"
                average_table_selection_values_size = sum(
                    len(val) for key, val in experiments
                ) / len(experiments)
                result[key][dataset] = average_table_selection_values_size

    print(result)
    return result


def test_recalculate_result():
    recalculate_result()


def test_effect_of_rewrite_gpt35():
    from schema_match.evaluations.extended_study_evaluation import (
        effect_of_rewrite_gpt35,
    )

    effect_of_rewrite_gpt35()


def test_gpt4_family_difference():
    from schema_match.evaluations.extended_study_evaluation import (
        gpt4_family_difference,
    )

    gpt4_family_difference()


def test_user_study():
    from schema_match.evaluations.extended_study_evaluation import user_study

    user_study()


def test_effect_of_foreign_keys_and_description():
    from schema_match.evaluations.extended_study_evaluation import (
        effect_of_foreign_keys_and_description,
    )

    res = effect_of_foreign_keys_and_description("gpt-3.5-turbo")
    print(res)


def test_serialization():
    from schema_match.data_models.experiment_models import OntologySchemaRewrite

    res = OntologySchemaRewrite.get_database_description("bank1")
    import json

    print(json.dumps(res, indent=2))


def test_llm_methods():
    from schema_match.evaluations.ontology_matching_evaluation import get_full_results

    result = get_full_results()

    f1_score = defaultdict(dict)
    token_consumption = defaultdict(dict)
    for method, experiments in result.items():
        if method.find("llm") == -1:
            continue
        for experiment, val in experiments.items():
            f1_score[method][experiment] = round(val.f1_score, 2)
            token_consumption[method][experiment] = val.column_matching_tokens
    print(f1_score)
    print(token_consumption)
