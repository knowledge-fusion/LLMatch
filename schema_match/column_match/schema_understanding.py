import json
from collections import defaultdict

from schema_match.data_models.experiment_models import OntologySchemaRewrite
from schema_match.services.language_models import complete
from schema_match.utils import get_cache

cache = get_cache()


def split_dictionary_based_on_context_size(prompt_template, data: dict, run_specs):
    """Returns the number of tokens in a text string."""

    # encoding = tiktoken.encoding_for_model(run_specs["table_selection_llm"])
    batches = []
    temp_dict = {}
    template_words = len(json.dumps(prompt_template).split())
    context_size = run_specs.get("context_size", 2000000)
    for key, values in data.items():
        temp_dict[key] = values
        num_words = template_words + len(json.dumps(temp_dict).split())
        if num_words > context_size:
            batch_dict = json.loads(json.dumps(temp_dict))
            batches.append(batch_dict)
            temp_dict = {}
    if temp_dict:
        batches.append(temp_dict)
    # print(f"Number of batches: {run_specs} {len(batches)}")
    # if len(batches)> 1:
    #     print(f"Number of batches: {run_specs} {len(batches)}")
    return batches


def run_matching(run_specs, table_selections):
    from schema_match.data_models.experiment_models import (
        OntologyAlignmentExperimentResult,
    )
    from schema_match.data_models.experiment_models import OntologySchemaRewrite

    import os

    assert run_specs["column_matching_strategy"] in [
        "llm",
        "llm-reasoning",
        "llm-no_description",
        "llm-no_foreign_keys",
        "llm-no_description_no_foreign_keys",
        "llm-one_table_to_one_table",
        "llm-limit_context",
        "llm-data",
    ]

    script_dir = os.path.dirname(os.path.abspath(__file__))

    file_path = os.path.join(script_dir, "column_matching_prompt.md")
    with open(file_path) as file:
        prompt_template = file.read()

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
    include_sample_data = False
    if run_specs["column_matching_strategy"] in ["llm-data"]:
        include_sample_data = True
    source_table_descriptions = OntologySchemaRewrite.get_database_description(
        source_db,
        run_specs["rewrite_llm"],
        include_foreign_keys=include_foreign_keys,
        include_description=include_description,
        include_sample_data=include_sample_data,
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

    for source_table, target_tables in table_selections:
        assert isinstance(target_tables, list)
        assert isinstance(target_tables[0], str)
        source_data = {source_table: source_table_descriptions[source_table]}
        target_data = {}
        for table in target_tables:
            target_data[table] = target_table_descriptions[table]
        assert source_data and target_data
        prompt = prompt_template.replace(
            "{{source_columns}}", json.dumps(source_data, indent=2)
        )

        batches = split_dictionary_based_on_context_size(prompt, target_data, run_specs)
        cache_key = f"{json.dumps(dict(sorted(run_specs.items())))}-{source_table}"
        batch_values = [list(item.keys()) for item in batches]
        print(cache_key, batch_values)
        cache.set(cache_key, batch_values)
        for idx, batch_linking_candidates in enumerate(batches):
            target_tables = list(batch_linking_candidates.keys())
            target_tables.sort()
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
            if run_specs["column_matching_strategy"] == "llm-limit_context":
                operation_specs["column_matching_strategy"] = "llm"
            query = OntologyAlignmentExperimentResult.objects(
                operation_specs__operation="column_matching",
                operation_specs__source_table=source_table,
                operation_specs__source_db=source_db,
                operation_specs__target_db=target_db,
                operation_specs__rewrite_llm=operation_specs["rewrite_llm"],
                operation_specs__column_matching_strategy=operation_specs[
                    "column_matching_strategy"
                ],
                operation_specs__column_matching_llm=operation_specs[
                    "column_matching_llm"
                ],
                operation_specs__target_tables=target_tables,
            )

            res = query.first()

            if not res:
                for item in OntologyAlignmentExperimentResult.objects(
                    operation_specs__operation="column_matching",
                    operation_specs__source_table=source_table,
                    operation_specs__source_db=source_db,
                    operation_specs__target_db=target_db,
                    operation_specs__rewrite_llm=operation_specs["rewrite_llm"],
                    operation_specs__column_matching_strategy=operation_specs[
                        "column_matching_strategy"
                    ],
                    operation_specs__column_matching_llm=operation_specs[
                        "column_matching_llm"
                    ],
                ):
                    expected = set(target_tables)
                    actual = set(item.operation_specs["target_tables"])
                    if expected == actual:
                        res = item
                        break
            if res:
                assert res.operation_specs["source_table"] == source_table
                assert set(res.operation_specs["target_tables"]) == set(target_tables)
                continue
                # res.delete()
            try:
                prompt = prompt.replace(
                    "{{target_columns}}", json.dumps(batch_linking_candidates, indent=2)
                )
                response = complete(
                    prompt, run_specs["column_matching_llm"], run_specs=run_specs
                ).json()
                data = response["extra"]["extracted_json"]
                if not data:
                    # try again
                    response = complete(
                        prompt, run_specs["column_matching_llm"], run_specs=run_specs
                    ).json()
                    data = response["extra"]["extracted_json"]
                assert data
                res = OntologyAlignmentExperimentResult.upsert_llm_result(
                    operation_specs=operation_specs,
                    result=response,
                )
                assert res.operation_specs == operation_specs
                print(data)
            except Exception as e:
                # raise e
                print(e)
                OntologyAlignmentExperimentResult(
                    operation_specs=operation_specs,
                    dataset=f"{source_db}-{target_db}",
                    text_result=str(e),
                    json_result={},
                ).save()


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
        "llm-limit_context",
    ]
    column_matching_strategy = run_specs["column_matching_strategy"]
    if run_specs["column_matching_strategy"] == "llm-limit_context":
        column_matching_strategy = "llm"
    duration, prompt_token, completion_token = 0, 0, 0
    predictions = dict()
    for source, targets in table_selections:
        if not targets:
            continue
        prediction_results = None
        cache_key = f"{json.dumps(dict(sorted(run_specs.items())))}-{source}"
        batch_values = cache.get(cache_key)

        if not batch_values:
            raise Exception(f"no batch values found for {cache_key}")
        for idx, target_tables in enumerate(batch_values):
            target_tables.sort()
            for item in OntologyAlignmentExperimentResult.objects(
                operation_specs__operation="column_matching",
                operation_specs__source_table=source,
                operation_specs__source_db=run_specs["source_db"],
                operation_specs__target_db=run_specs["target_db"],
                operation_specs__rewrite_llm=run_specs["rewrite_llm"],
                operation_specs__column_matching_strategy=column_matching_strategy,
                operation_specs__column_matching_llm=run_specs["column_matching_llm"],
            ).order_by("-created_at"):
                if set(item.operation_specs["target_tables"]) == set(target_tables):
                    prediction_results = item
                    break

            duration += prediction_results.duration or 0
            prompt_token += prediction_results.prompt_tokens or 0
            completion_token += prediction_results.completion_tokens or 0
            predictions.update(get_sanitized_result(prediction_results))
    return predictions, (prompt_token + completion_token)


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
