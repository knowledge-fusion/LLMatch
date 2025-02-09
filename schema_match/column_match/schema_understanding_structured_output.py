import json
from collections import defaultdict

from schema_match.data_models.experiment_models import OntologySchemaRewrite
from schema_match.schema_preparation.simplify_schema import get_merged_schema
from schema_match.services.language_models import complete


def run_matching(run_specs, table_selections):
    from schema_match.data_models.experiment_models import (
        OntologyAlignmentExperimentResult,
    )
    from schema_match.data_models.experiment_models import OntologySchemaRewrite

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
            source_db, with_orginal_columns=False
        )
        target_table_descriptions = get_merged_schema(
            target_db, with_orginal_columns=False
        )
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
            response = prompt_schema_matching(run_specs, source_data, target_data)
            data = response["extra"]["extracted_json"]
            assert data
            print(data)
            if source_db.find("-merged") > -1:
                response["extra"]["extracted_json"] = get_original_mappings(
                    run_specs, data
                )
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


def prompt_schema_matching(run_specs, source_data, target_data):
    import os

    script_dir = os.path.dirname(os.path.abspath(__file__))

    file_path = os.path.join(
        script_dir,
        "column_matching_prompt.md"
        if run_specs["column_matching_strategy"] == "llm-reasoning"
        else "column_matching_prompt_no_reasoning.md",
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
    response = complete(
        prompt,
        run_specs["column_matching_llm"],
        run_specs=run_specs,
        response_format=response_format,
    ).json()
    return response


def _get_original_columns(
    merged_table, merged_column, merged_schema_description, original_schema_description
):
    original_columns = (
        merged_schema_description[merged_table]["columns"]
        .get(merged_column, {})
        .get("original_columns", [])
    )
    if not original_columns:
        return {}
    # flattern list
    result = {}
    for column in original_columns:
        table, column = column.split(".")
        column_details = original_schema_description[table]["columns"].get(column, {})
        if column_details.get("linked_entry"):
            table, column = column_details["linked_entry"].split(".")
            column_details = original_schema_description[table]["columns"][column]
        result[f"{table}.{column}"] = column_details
    return result


def get_original_mappings(run_specs, mapping_results):
    # mapping_results.pop("original_mappings", None)
    if mapping_results.get("original_mappings"):
        return mapping_results
    source_db, target_db = run_specs["source_db"], run_specs["target_db"]
    merged_source_schema_description = get_merged_schema(
        source_db, with_orginal_columns=True
    )
    merged_target_schema_description = get_merged_schema(
        target_db, with_orginal_columns=True
    )
    original_source_schema_description = OntologySchemaRewrite.get_database_description(
        source_db.split("-merged")[0],
        run_specs["rewrite_llm"],
        include_foreign_keys=True,
        include_description=True,
    )
    original_target_schema_description = OntologySchemaRewrite.get_database_description(
        target_db.split("-merged")[0],
        run_specs["rewrite_llm"],
        include_foreign_keys=True,
        include_description=True,
    )
    original_mappings = defaultdict(list)
    for mapping in mapping_results["mappings"]:
        source_table, source_column = mapping["source_column"].split(".")
        original_sources = _get_original_columns(
            merged_table=source_table,
            merged_column=source_column,
            merged_schema_description=merged_source_schema_description,
            original_schema_description=original_source_schema_description,
        )
        target_mappings = mapping["target_mappings"]
        for mapping in target_mappings:
            if mapping.get("mapping", "").find(".") == -1:
                continue
            target_table, target_column = mapping["mapping"].split(".")
            original_targets = _get_original_columns(
                merged_table=target_table,
                merged_column=target_column,
                merged_schema_description=merged_target_schema_description,
                original_schema_description=original_target_schema_description,
            )
            if len(original_sources) > 1 or len(original_targets) > 1:
                print(
                    f"Multiple original columns found for {source_table}.{source_column} -> {target_table}.{target_column}"
                )
                for source, source_details in original_sources.items():
                    source_table = source.split(".")[0]
                    table_description = original_source_schema_description[
                        source_table
                    ]["table_description"]
                    source_details["table_description"] = table_description

                for target, target_details in original_targets.items():
                    target_table = target.split(".")[0]
                    table_description = original_target_schema_description[
                        target_table
                    ]["table_description"]
                    target_details["table_description"] = table_description

                # drilldown matching
                response = prompt_schema_matching(
                    run_specs,
                    original_sources,
                    original_targets,
                )
                data = response["extra"]["extracted_json"]
                for mapping in data.get("mappings", []):
                    source_column = mapping["source_column"]
                    for target in mapping["target_mappings"]:
                        target_column = target["mapping"]
                        original_mappings[f"{source_column}"].append(f"{target_column}")
            else:
                if original_sources and original_targets:
                    original_mappings[list(original_sources.keys())[0]].append(
                        list(original_targets.keys())[0]
                    )
    mapping_results["original_mappings"] = original_mappings
    return mapping_results


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
