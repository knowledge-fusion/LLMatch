import json
from collections import defaultdict

from schema_match.data_models.experiment_models import OntologySchemaRewrite
from schema_match.schema_preparation.simplify_schema import (
    get_merged_schema,
    get_column_rename_mapping,
    get_renamed_ground_truth,
)
from schema_match.services.language_models import complete
from schema_match.utils import get_cache


def run_matching(run_specs, table_selections):
    from schema_match.data_models.experiment_models import (
        OntologyAlignmentExperimentResult,
    )
    from schema_match.data_models.experiment_models import OntologySchemaRewrite

    ground_truths = get_renamed_ground_truth(
        source_db=run_specs["source_db"].split("-merged")[0],
        target_db=run_specs["target_db"].split("-merged")[0],
    )
    assert run_specs["column_matching_strategy"] in [
        "llm",
        "llm-reasoning",
        "llm-no_description",
        "llm-no_foreign_keys",
        "llm-no_description_no_foreign_keys",
        "llm-one_table_to_one_table",
    ]

    source_db, target_db = (
        run_specs["source_db"].lower(),
        run_specs["target_db"].lower(),
    )

    include_description = True
    if run_specs["column_matching_strategy"] in [
        "llm-no_description",
        "llm-no_description_no_foreign_keys",
    ]:
        include_description = False
    include_foreign_keys = True
    if run_specs["column_matching_strategy"] in [
        "llm-no_foreign_keys",
        "llm-no_description_no_foreign_keys",
    ]:
        include_foreign_keys = False

    if source_db.find("-merged") == -1:
        source_table_descriptions = OntologySchemaRewrite.get_database_description(
            source_db,
            run_specs["rewrite_llm"],
            include_foreign_keys=include_foreign_keys,
            include_description=include_description,
        )
        target_table_descriptions = OntologySchemaRewrite.get_database_description(
            target_db,
            run_specs["rewrite_llm"],
            include_foreign_keys=include_foreign_keys,
            include_description=include_description,
        )

        if not include_foreign_keys:
            for table in source_table_descriptions:
                for column in source_table_descriptions[table]["columns"]:
                    source_table_descriptions[table]["columns"][column].pop(
                        "is_foreign_key", None
                    )
                    source_table_descriptions[table]["columns"][column].pop(
                        "linked_entry", None
                    )

            for table in target_table_descriptions:
                for column in target_table_descriptions[table]["columns"]:
                    target_table_descriptions[table]["columns"][column].pop(
                        "is_foreign_key", None
                    )
                    target_table_descriptions[table]["columns"][column].pop(
                        "linked_entry", None
                    )
    else:
        source_table_descriptions = get_merged_schema(
            source_db, with_original_columns=False
        )
        target_table_descriptions = get_merged_schema(
            target_db, with_original_columns=False
        )
        source_rename_mapping = get_column_rename_mapping(source_db.split("-merged")[0])
        target_rename_mapping = get_column_rename_mapping(target_db.split("-merged")[0])
    for source_table, target_tables in table_selections:
        assert isinstance(target_tables, list)
        assert isinstance(target_tables[0], str)
        source_data = {source_table: source_table_descriptions[source_table]}
        target_data = {}
        for table in target_tables:
            target_data[table] = target_table_descriptions[table]
        assert source_data and target_data
        operation_specs = {
            "operation": "column_matching",
            "source_table": source_table,
            "target_tables": target_tables,
            "source_db": source_db,
            "target_db": target_db,
            "rewrite_llm": run_specs["rewrite_llm"],
            "column_matching_strategy": run_specs["column_matching_strategy"],
            "column_matching_llm": run_specs["column_matching_llm"],
        }
        res = None
        for item in OntologyAlignmentExperimentResult.objects(
            operation_specs__operation="column_matching",
            operation_specs__source_table=source_table,
            operation_specs__source_db=source_db,
            operation_specs__target_db=target_db,
            operation_specs__rewrite_llm=run_specs["rewrite_llm"],
            operation_specs__column_matching_strategy=run_specs[
                "column_matching_strategy"
            ],
            operation_specs__column_matching_llm=run_specs["column_matching_llm"],
        ):
            if set(item.operation_specs["target_tables"]) == set(target_tables):
                res = item
                break
        if res:
            assert res.operation_specs["source_table"] == source_table
            assert set(res.operation_specs["target_tables"]) == set(target_tables)
            result = res.json_result
            print(result)
            continue
            # res.delete()
        try:
            has_more = True
            matching_result = defaultdict(list)
            while has_more:
                response = prompt_schema_matching(run_specs, source_data, target_data)
                data = response["extra"]["cleaned_json"]
                assert data
                has_more = False
                for item in data.get("mappings", []):
                    source_table, source_column = item["source_column"].split(".")
                    assert source_data[source_table]["columns"][source_column]
                    for target in item["target_mappings"]:
                        target_table, target_column = target["mapping"].split(".")
                        original_target_data = target_data[target_table]["columns"].pop(
                            target_column, None
                        )
                        if not target_data[target_table]["columns"]:
                            target_data.pop(target_table)
                        if original_target_data:
                            matching_result[f"{source_table}.{source_column}"].append(
                                f"{target_table}.{target_column}"
                            )
                            has_more = True
                print(data)
            if source_db.find("-merged") > -1:
                original_mappings = get_original_mappings(
                    run_specs,
                    matching_result,
                    source_rename_mapping,
                    target_rename_mapping,
                )
                response["extra"]["extracted_json"]["original_mappings"] = (
                    original_mappings
                )
                errors = print_debug_info(ground_truths, original_mappings)

            res = OntologyAlignmentExperimentResult.upsert_llm_result(
                operation_specs=operation_specs,
                result=response,
            )
            assert res.operation_specs == operation_specs
        except Exception as e:
            raise e
            OntologyAlignmentExperimentResult(
                operation_specs=operation_specs,
                dataset=f"{source_db}-{target_db}",
                text_result=str(e),
                json_result={},
            ).save()


cache = get_cache()


def prompt_schema_matching(run_specs, source_data, target_data):
    import os

    if list(source_data.values())[0].get("columns") is not None:
        source_columns = [list(item["columns"].keys()) for item in source_data.values()]
        target_columns = [list(item["columns"].keys()) for item in target_data.values()]
    else:
        source_columns = list(source_data.keys())
        target_columns = list(target_data.keys())
    source_columns.sort()
    target_columns.sort()
    key = (
        json.dumps(run_specs) + json.dumps(source_columns) + json.dumps(target_columns)
    )
    cache_result = cache.get(key)
    if cache_result:
        return cache_result

    script_dir = os.path.dirname(os.path.abspath(__file__))

    file_path = os.path.join(
        script_dir,
        "column_matching_prompt.md"
        if run_specs["column_matching_strategy"] == "llm-reasoning"
        else "column_matching_prompt.md",
    )
    with open(file_path) as file:
        prompt_template = file.read()

    response_format = None
    if run_specs["column_matching_llm"] in ["gpt-4o", "gpt-4o-mini"]:
        with open(file_path.split(".md")[0] + "_response_format.json") as file:
            response_format = json.load(file)
        assert response_format
    prompt = prompt_template.replace(
        "{{source_columns}}", json.dumps(source_data, indent=2)
    )
    prompt = prompt.replace("{{target_columns}}", json.dumps(target_data, indent=2))

    def _prompt():
        response = complete(
            prompt,
            run_specs["column_matching_llm"],
            run_specs=run_specs,
            response_format=response_format,
        ).json()
        data = response["extra"]["extracted_json"]
        cleaned_data = []
        for item in data.get("mappings", []):
            if item["source_column"].count(".") != 1 or item["source_column"] == "None":
                continue
            source_table, source_column = item["source_column"].split(".")
            if item["source_column"] not in source_data:
                if source_table not in source_data:
                    continue
                if source_column not in source_data[source_table]["columns"]:
                    continue
                assert source_data[source_table]["columns"][source_column]
            cleaned_mappings = []
            for target in item["target_mappings"]:
                if target["mapping"] == "None" or target["mapping"].count(".") != 1:
                    continue
                if target["mapping"] in target_data:
                    cleaned_mappings.append(target)
                    continue
                target_table, target_column = target["mapping"].split(".")
                if target_table not in target_data:
                    continue
                cleaned_mappings.append(target)
            if cleaned_mappings:
                item["target_mappings"] = cleaned_mappings
                cleaned_data.append(item)
        response["extra"]["cleaned_json"] = {"mappings": cleaned_data}
        return response

    response = _prompt()
    cache.set(key, response)
    return cache.get(key)


def _get_original_columns(merged_table, merged_column, rename_mapping):
    result = rename_mapping[f"{merged_table}.{merged_column}"]
    for key in list(result.keys()):
        if result[key].get("original_columns"):
            for column in result[key]["original_columns"]:
                result[column] = rename_mapping[column]
            result.pop(key)
    assert result
    return result


def get_original_mappings(
    run_specs, mapping_results, source_rename_mapping, target_rename_mapping
):
    # mapping_results.pop("original_mappings", None)
    if mapping_results.get("original_mappings"):
        return mapping_results

    original_mappings = defaultdict(list)
    for source, targets in mapping_results.items():
        source_table, source_column = source.split(".")
        original_sources = _get_original_columns(
            merged_table=source_table,
            merged_column=source_column,
            rename_mapping=source_rename_mapping,
        )
        original_targets = {}
        for target in targets:
            target_table, target_column = target.split(".")
            if not target_rename_mapping.get(f"{target_table}.{target_column}"):
                continue
            original_targets.update(
                _get_original_columns(
                    merged_table=target_table,
                    merged_column=target_column,
                    rename_mapping=target_rename_mapping,
                )
            )

            # drilldown matching
        for original_source in original_sources:
            response = prompt_schema_matching(
                run_specs,
                {source: original_sources[original_source]},
                original_targets,
            )
            data = response["extra"]["cleaned_json"]

            for item in data.get("mappings", []):
                for target in item["target_mappings"]:
                    original_mappings[item["source_column"]].append(target["mapping"])

    return original_mappings


def print_debug_info(ground_truths, original_mappings):
    errors = []
    for source_column, target_columns in original_mappings.items():
        expected_columns = ground_truths[source_column]
        if set(target_columns) != set(expected_columns):
            print(
                f"Different ground truth for {source_column}, predicted: {target_columns}, expected {expected_columns}"
            )
            errors.append(source_column)
    return errors


def get_predictions(run_specs, table_selections):
    from schema_match.data_models.experiment_models import (
        OntologyAlignmentExperimentResult,
    )

    assert run_specs["column_matching_strategy"] in [
        "llm",
        "llm-reasoning",
        "llm-no_description",
        "llm-no_foreign_keys",
        "llm-no_description_no_foreign_keys",
        "llm-one_table_to_one_table",
    ]

    duration, prompt_token, completion_token = 0, 0, 0
    predictions = dict()
    for source, targets in table_selections:
        if not targets:
            continue
        prediction_results = None
        for item in OntologyAlignmentExperimentResult.objects(
            operation_specs__operation="column_matching",
            operation_specs__source_table=source,
            operation_specs__source_db=run_specs["source_db"],
            operation_specs__target_db=run_specs["target_db"],
            operation_specs__rewrite_llm=run_specs["rewrite_llm"],
            operation_specs__column_matching_strategy=run_specs[
                "column_matching_strategy"
            ],
            operation_specs__column_matching_llm=run_specs["column_matching_llm"],
        ):
            if set(item.operation_specs["target_tables"]) == set(targets):
                prediction_results = item
                break

        duration += prediction_results.duration or 0
        prompt_token += prediction_results.prompt_tokens or 0
        completion_token += prediction_results.completion_tokens or 0
        predictions.update(get_sanitized_result(prediction_results))
    return predictions


def get_sanitized_result(experiment_result):
    if experiment_result.sanitized_result:
        return experiment_result.sanitized_result
    source_rewrite_queryset = OntologySchemaRewrite.objects(
        database=experiment_result.operation_specs["source_db"],
        llm_model=experiment_result.operation_specs["rewrite_llm"],
    )
    target_rewrite_queryset = OntologySchemaRewrite.objects(
        database=experiment_result.operation_specs["target_db"],
        llm_model=experiment_result.operation_specs["rewrite_llm"],
    )
    predictions = defaultdict(list)
    result = experiment_result.json_result
    mappings = []
    if "mappings" in result:
        result = result["mappings"]
        for item in result:
            mappings.append((item["source_column"], item["target_mappings"]))
    else:
        for source, targets in experiment_result.json_result.items():
            mappings.append((source, targets))
    for source, targets in mappings:
        if source.count(".") < 1:
            continue
        if source.count(".") > 1:
            source = ".".join(source.split(".")[0:2])
        source_table, source_column = source.split(".")
        source_entry = source_rewrite_queryset.filter(
            table__in=[source_table, source_table.lower()],
            column__in=[source_column, source_column.lower()],
        ).first()
        if not source_entry:
            print(f"source not found {source}")
            continue
        if source_entry.linked_table:
            source_entry = source_rewrite_queryset.filter(
                table=source_entry.linked_table,
                column=source_entry.linked_column,
            ).first()
        assert source_entry, source
        if targets is None:
            targets = []
        for target in targets:
            if (not target) or target in ["None"]:
                continue
            if isinstance(target, dict):
                try:
                    target = target["mapping"]
                except Exception as e:
                    continue
            if (not target) or target in ["None"]:
                continue
            if target.count(".") > 1:
                tokens = target.split(".")
                target = ".".join([tokens[-2], tokens[-1]])
            if isinstance(target, list):
                target
            if len(target.split(".")) < 2:
                print(f"no table in target {targets=}")
                continue
            target_entry = target_rewrite_queryset.filter(
                table__in=[target.split(".")[0], target.split(".")[0].lower()],
                column__in=[target.split(".")[1], target.split(".")[1].lower()],
            ).first()
            if not target_entry:
                print(f"target not found {target}")
                continue
            if target_entry.linked_table:
                target_entry = target_rewrite_queryset.filter(
                    table=target_entry.linked_table,
                    column=target_entry.linked_column,
                ).first()
            assert target_entry, target
            if (
                f"{target_entry.table}.{target_entry.column}"
                not in predictions[f"{source_entry.table}.{source_entry.column}"]
            ):
                predictions[f"{source_entry.table}.{source_entry.column}"].append(
                    f"{target_entry.table}.{target_entry.column}"
                )
    experiment_result.sanitized_result = predictions
    experiment_result.save()
    return experiment_result.sanitized_result
