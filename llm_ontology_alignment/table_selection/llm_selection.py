import json

from llm_ontology_alignment.services.language_models import complete


def split_dictionary_based_on_context_size(prompt_template, data: dict, run_specs):
    """Returns the number of tokens in a text string."""

    # encoding = tiktoken.encoding_for_model(run_specs["table_selection_llm"])
    batches = []
    temp_dict = {}
    for key, values in data.items():
        temp_dict[key] = values
        num_words = len(json.dumps(temp_dict).split())
        if num_words > run_specs.get("context_size", 200000):
            batch_dict = json.loads(json.dumps(temp_dict))
            batch_dict.pop(key)
            batches.append(batch_dict)
            temp_dict = {}
            temp_dict[key] = values
    if temp_dict:
        batches.append(temp_dict)
    # print(f"Number of batches: {run_specs} {len(batches)}")
    # if len(batches)> 1:
    #     print(f"Number of batches: {run_specs} {len(batches)}")
    return batches


def get_llm_table_selection_result(run_specs, refresh_existing_result=False):
    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite
    from llm_ontology_alignment.data_models.experiment_models import OntologyAlignmentExperimentResult

    source_database, target_database = (
        run_specs.get("source_db", run_specs.get("source_database")),
        run_specs.get("target_db", run_specs.get("target_database")),
    )
    assert source_database
    assert target_database
    from llm_ontology_alignment.data_models.table_selection import OntologyTableSelectionResult

    assert run_specs["table_selection_strategy"] in ["llm", "llm-reasoning", "llm-limit_context"]
    assert run_specs["table_selection_llm"] != "None"
    assert run_specs["table_selection_llm"]
    flt = {
        "table_selection_llm": run_specs["table_selection_llm"],
        "table_selection_strategy": run_specs["table_selection_strategy"],
        "source_database": source_database,
        "target_database": target_database,
        "rewrite_llm": run_specs["rewrite_llm"],
    }
    if run_specs["table_selection_strategy"] == "llm-limit_context":
        flt["context_size"] = int(run_specs["context_size"])
    res = OntologyTableSelectionResult.objects(**flt).first()
    # if res and (not refresh_existing_result) and res.data:
    #     return res.data

    if refresh_existing_result:
        res = OntologyAlignmentExperimentResult.objects(
            operation_specs__operation="table_candidate_selection",
            operation_specs__source_db=source_database,
            operation_specs__target_db=target_database,
            operation_specs__rewrite_llm=run_specs["rewrite_llm"],
            operation_specs__table_selection_llm=run_specs["table_selection_llm"],
            operation_specs__table_selection_strategy=run_specs["table_selection_strategy"],
        ).delete()
        print(f"Deleted {res} existing results")

    import os

    script_dir = os.path.dirname(os.path.abspath(__file__))

    file_path = os.path.join(
        script_dir,
        "table_matching_prompt.md"
        if run_specs["table_selection_strategy"] == "llm-reasoning"
        else "table_matching_prompt_single_source_table.md",
    )
    with open(file_path, "r") as file:
        prompt_template = file.read()

    source_db, target_db = run_specs["source_db"], run_specs["target_db"]
    result = dict()
    include_description = True
    source_table_descriptions = OntologySchemaRewrite.get_database_description(
        source_db, run_specs["rewrite_llm"], include_foreign_keys=True, include_description=include_description
    )
    target_table_descriptions = OntologySchemaRewrite.get_database_description(
        target_db, run_specs["rewrite_llm"], include_foreign_keys=True, include_description=include_description
    )
    linking_candidates = {}

    for target_table, target_table_data in target_table_descriptions.items():
        linking_candidates[target_table] = {
            "non_foreign_key_columns": ",".join(
                [item["name"] for item in target_table_data["columns"].values() if not item.get("is_foreign_key")]
            ),
            "foreign_keys": ",".join(
                [
                    f'{item["name"]}=>{item["linked_entry"]}'
                    for item in target_table_data["columns"].values()
                    if item.get("is_foreign_key")
                ]
            ),
        }
        if include_description:
            linking_candidates[target_table]["description"] = target_table_data["table_description"]
    for source_table, source_table_data in source_table_descriptions.items():
        if not source_table_data.get("columns"):
            continue

        prompt_source_template = prompt_template.replace("{{source_table}}", json.dumps(source_table_data, indent=2))

        batches_linking_candidate = split_dictionary_based_on_context_size(
            prompt_template=prompt_source_template, data=linking_candidates, run_specs=run_specs
        )
        for idx, batch_linking_candidates in enumerate(batches_linking_candidate):
            operation_specs = {
                "operation": "table_candidate_selection",
                "source_table": source_table,
                "source_db": source_db,
                "target_db": target_db,
                "rewrite_llm": run_specs["rewrite_llm"],
                "table_selection_llm": run_specs["table_selection_llm"],
                "table_selection_strategy": run_specs["table_selection_strategy"],
            }

            res = OntologyAlignmentExperimentResult.objects(operation_specs=operation_specs).first()
            if res:
                try:
                    for source, targets in res.json_result.items():
                        assert source == source_table, f"{source} != {source_table}"
                        for target in targets:
                            assert (
                                target["target_table"] in linking_candidates
                            ), f'{target["target_table"]} => {list(linking_candidates.keys())}'

                    result.update(res.json_result)
                    continue
                except Exception as e:
                    res.delete()
            prompt = prompt_source_template.replace("{{target_tables}}", json.dumps(batch_linking_candidates, indent=2))

            response = complete(prompt, run_specs["table_selection_llm"], run_specs=run_specs)
            response = response.json()
            data = response["extra"]["extracted_json"]
            assert data
            try:
                sanitized_targets = []
                for source, targets in data.items():
                    if not isinstance(targets, list):
                        continue
                    # assert source == source_table, f"{source} != {source_table}"
                    for target in targets:
                        if target["target_table"] in linking_candidates:
                            sanitized_targets.append(target)
                response["extra"]["extracted_json"] = {source_table: sanitized_targets}
            except Exception as e:
                raise e
            res = OntologyAlignmentExperimentResult.upsert_llm_result(
                operation_specs=operation_specs,
                result=response,
            )
            assert res
            result.update(response["extra"]["extracted_json"])

    result_no_reasoning = dict()
    for key, vals in result.items():
        result_no_reasoning[key] = list(set([val["target_table"] for val in vals]))
    flt["data"] = result_no_reasoning
    res = OntologyTableSelectionResult.upsert(flt)
    return result_no_reasoning
