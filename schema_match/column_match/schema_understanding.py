import json
from collections import defaultdict

from schema_match.data_models.experiment_models import OntologySchemaRewrite
from schema_match.schema_preparation.simplify_schema import (
    get_merged_schema,
    get_renames,
    get_column_rename_mapping,
)
from schema_match.services.language_models import complete
from schema_match.utils import get_cache

cache = get_cache()


tools = [
    {
        "type": "function",
        "function": {
            "name": "ask_for_expert_match_result",
            "description": "Given a list of mappings, each with source and target table/column, return a list of booleans indicating if they match.",
            "parameters": {
                "type": "object",
                "properties": {
                    "mappings": {
                        "type": "array",
                        "items": {
                            "type": "object",
                            "properties": {
                                "source_table": {
                                    "type": "string",
                                    "description": "Name of the source table",
                                },
                                "source_column": {
                                    "type": "string",
                                    "description": "Name of the source column",
                                },
                                "target_table": {
                                    "type": "string",
                                    "description": "Name of the target table",
                                },
                                "target_column": {
                                    "type": "string",
                                    "description": "Name of the target column",
                                },
                            },
                            "required": [
                                "source_table",
                                "source_column",
                                "target_table",
                                "target_column",
                            ],
                        },
                    }
                },
                "required": ["mappings"],
            },
        },
    }
]

source_db, target_db = None, None


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

    # response_format = None
    # if run_specs["column_matching_llm"] in ["gpt-4o", "gpt-4o-mini"]:
    #     with open(file_path.split(".md")[0] + "_response_format.json") as file:
    #         response_format = json.load(file)
    #     assert response_format
    prompt = prompt_template.replace(
        "{{source_columns}}", json.dumps(source_data, indent=2)
    )
    prompt = prompt.replace("{{target_columns}}", json.dumps(target_data, indent=2))

    def _prompt():
        response = complete(
            prompt,
            run_specs["column_matching_llm"],
            run_specs=run_specs,
        ).json()
        data = response["extra"]["extracted_json"]
        if isinstance(data, list) or not data:
            response = complete(
                prompt,
                run_specs["column_matching_llm"],
                run_specs=run_specs,
            ).json()
            data = response["extra"]["extracted_json"]
        cleaned_data = {}
        for source, targets in data.items():
            if source.count(".") != 1 or source == "None":
                continue
            source_table, source_column = source.split(".")
            if source not in source_data:
                if source_table not in source_data:
                    continue
                if source_column not in source_data[source_table]["columns"]:
                    continue
                assert source_data[source_table]["columns"][source_column]
            cleaned_mappings = []
            for target in targets:
                if target["mapping"] == "None" or target["mapping"].count(".") != 1:
                    continue
                if target["mapping"] in target_data:
                    cleaned_mappings.append(target)
                    continue
                target_table, target_column = target["mapping"].split(".")
                if target_table not in target_data:
                    continue
                if target_column not in target_data[target_table]["columns"]:
                    continue
                cleaned_mappings.append(target)
            if cleaned_mappings:
                cleaned_data[source] = cleaned_mappings
        response["extra"]["cleaned_json"] = cleaned_data
        return response

    response = _prompt()
    cache.set(key, response)
    print(len(key))
    return cache.get(key)


def ask_for_expert_match_result(mappings):
    """
    Takes a list of dicts:
    [
      {
        "source_table": ...,
        "source_column": ...,
        "target_table": ...,
        "target_column": ...
      },
      ...
    ]
    Returns a list of boolean values.
    """
    from schema_match.evaluations.ontology_matching_evaluation import load_ground_truth

    ground_truths = load_ground_truth("original", source_db, target_db)
    results = []
    for mapping in mappings:
        source_table = mapping["source_table"].lower()
        source_col = mapping["source_column"].lower()
        target_col = mapping["target_column"].lower()
        target_table = mapping["target_table"].lower()
        source = f"{source_table}.{source_col}"
        target = f"{target_table}.{target_col}"
        # Simple logic: just check if column names match (case-insensitive)
        is_match = target in ground_truths[source]
        mapping["is_match"] = is_match
        results.append(mapping)
    print("expert results", results)
    return json.dumps(results)


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


def get_original_mappings(
    run_specs, mapping_results, source_rename_mapping, target_rename_mapping
):
    # mapping_results.pop("original_mappings", None)
    if mapping_results.get("original_mappings"):
        return mapping_results

    def _get_original_columns(merged_table, merged_column, rename_mapping):
        result = rename_mapping[f"{merged_table}.{merged_column}"]
        for key in list(result.keys()):
            if result[key].get("original_columns"):
                for column in result[key]["original_columns"]:
                    if column not in rename_mapping:
                        continue
                    result[column] = rename_mapping[column]
                result.pop(key)
        assert result
        return result

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
            target_table, target_column = target["mapping"].split(".")
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
        # for original_source in original_sources:
        if len(original_sources) > 1 or len(original_targets) > 1:
            response = prompt_schema_matching(
                run_specs,
                original_sources,
                original_targets,
            )
            data = response["extra"]["cleaned_json"]

            for source, targets in data.items():
                original_mappings[source].extend(targets)
        else:
            original_mappings[source].extend(targets)
    assert original_mappings
    return original_mappings


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
        "llm-human_in_the_loop",
        "llm-candidate-generation",
    ]

    script_dir = os.path.dirname(os.path.abspath(__file__))

    global source_db, target_db
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
    if source_db.find("-merged") == -1:
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
    else:
        source_table_descriptions = get_merged_schema(source_db)
        target_table_descriptions = get_merged_schema(target_db)
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

        batches = split_dictionary_based_on_context_size("", target_data, run_specs)
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
                matching_result, response = generate_matching_candidate(
                    run_specs, source_data, target_data
                )

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
                res = OntologyAlignmentExperimentResult.upsert_llm_result(
                    operation_specs=operation_specs,
                    result=response,
                )
                assert res.operation_specs == operation_specs
            except Exception as e:
                raise e
                print(e)
                OntologyAlignmentExperimentResult(
                    operation_specs=operation_specs,
                    dataset=f"{source_db}-{target_db}",
                    text_result=str(e),
                    json_result={},
                ).save()


def generate_matching_candidate(run_specs, source_data, target_data):
    matching_result = defaultdict(list)
    target_batch = [target_data]
    if run_specs["column_matching_strategy"] == "llm-candidate-generation":
        target_batch = [{key: value} for key, value in target_data.items()]
    for batch_target_data in target_batch:
        response = prompt_schema_matching(run_specs, source_data, batch_target_data)
        data = response["extra"]["cleaned_json"]
        for source, targets in data.items():
            matching_result[source].extend(targets)

    return matching_result, response


def _get_final_answers(messages, run_specs):
    if run_specs["column_matching_strategy"] == "llm-human_in_the_loop":
        data = complete(
            prompt=None,
            model=run_specs["column_matching_llm"],
            messages=messages,
            run_specs=run_specs,
            tools=tools,
            tool_choice="auto",
        ).json()
    else:
        data = complete(
            prompt=None,
            model=run_specs["column_matching_llm"],
            messages=messages,
            run_specs=run_specs,
        ).json()
    while data["choices"][0]["finish_reason"] == "tool_calls":
        messages.append(data["choices"][0]["message"])
        for tool_call in data["choices"][0]["message"]["tool_calls"]:
            function_name = tool_call["function"]["name"]
            arguments = json.loads(tool_call["function"]["arguments"])
            if function_name == "ask_for_expert_match_result":
                column_match_result = ask_for_expert_match_result(**arguments)
                messages.append(
                    {
                        "tool_call_id": tool_call["id"],
                        "role": "tool",
                        "name": function_name,
                        "content": column_match_result,
                    }
                )
        final_response = complete(
            model=run_specs["column_matching_llm"],
            prompt=None,
            run_specs={},
            messages=messages,
            tools=tools,
            tool_choice="none",
        )
        data = final_response.json()
    return data


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
        "llm-data",
        "llm-human_in_the_loop",
        "llm-candidate-generation",
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
            batch_values = [targets]
        #     raise Exception(f"no batch values found for {cache_key}")
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
    if experiment_result.operation_specs["source_db"].find("-merged") > -1:
        source_rename = get_renames(
            experiment_result.operation_specs["source_db"].split("-merged")[0]
        )
        target_rename = get_renames(
            experiment_result.operation_specs["target_db"].split("-merged")[0]
        )
        result = dict()
        for source, targets in experiment_result.json_result[
            "original_mappings"
        ].items():
            result[source_rename.get(source, source)] = [
                target_rename.get(target["mapping"], target["mapping"])
                for target in targets
            ]
    else:
        result = experiment_result.json_result

    if experiment_result.sanitized_result:
        return experiment_result.sanitized_result
    source_rewrite_queryset = OntologySchemaRewrite.objects(
        database=experiment_result.operation_specs["source_db"].split("-merged")[0],
        llm_model=experiment_result.operation_specs["rewrite_llm"],
    )
    target_rewrite_queryset = OntologySchemaRewrite.objects(
        database=experiment_result.operation_specs["target_db"].split("-merged")[0],
        llm_model=experiment_result.operation_specs["rewrite_llm"],
    )
    predictions = defaultdict(set)

    mappings = []
    if "mappings" in result:
        result = result["mappings"]
        for item in result:
            mappings.append((item["source_column"], item["target_mappings"]))
    else:
        for source, targets in result.items():
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
                predictions[f"{source_entry.table}.{source_entry.column}"].add(
                    f"{target_entry.table}.{target_entry.column}"
                )
    for key in predictions:
        predictions[key] = list(predictions[key])
    experiment_result.sanitized_result = predictions
    experiment_result.save()
    return experiment_result.sanitized_result
