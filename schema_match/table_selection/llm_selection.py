import json

from schema_match.constants import EXPERIMENTS
from schema_match.schema_preparation.simplify_schema import get_merged_schema
from schema_match.services.language_models import complete


def split_dictionary_based_on_context_size(prompt_template, data: dict, run_specs):
    """Returns the number of tokens in a text string."""

    # encoding = tiktoken.encoding_for_model(run_specs["table_selection_llm"])
    batches = []
    temp_dict = {}
    context_size = run_specs.get("context_size", 200000)
    template_words = len(json.dumps(prompt_template).split())
    for key, values in data.items():
        temp_dict[key] = values
        num_words = template_words + len(json.dumps(temp_dict).split())
        if num_words > context_size:
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
    from schema_match.data_models.experiment_models import OntologySchemaRewrite
    from schema_match.data_models.experiment_models import (
        OntologyAlignmentExperimentResult,
    )

    source_database, target_database = (
        run_specs.get("source_db", run_specs.get("source_database")),
        run_specs.get("target_db", run_specs.get("target_database")),
    )
    assert source_database
    assert target_database
    from schema_match.data_models.table_selection import OntologyTableSelectionResult

    assert run_specs["table_selection_strategy"] in [
        "llm",
        "llm-reasoning",
        "llm-limit_context",
        "llm-no_description",
        "llm-no_foreign_keys",
        "llm-no_description_no_foreign_keys",
    ]
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
    if res and (not refresh_existing_result) and res.data:
        return res.data, res.total_tokens

    if refresh_existing_result:
        res = OntologyAlignmentExperimentResult.objects(
            operation_specs__operation="table_candidate_selection",
            operation_specs__source_db=source_database,
            operation_specs__target_db=target_database,
            operation_specs__rewrite_llm=run_specs["rewrite_llm"],
            operation_specs__table_selection_llm=run_specs["table_selection_llm"],
            operation_specs__table_selection_strategy=run_specs[
                "table_selection_strategy"
            ],
        ).delete()
        print(f"Deleted {res} existing results")

    import os

    script_dir = os.path.dirname(os.path.abspath(__file__))

    file_path = os.path.join(script_dir, "table_matching_prompt.md")
    with open(file_path) as file:
        prompt_template = file.read()

    source_db, target_db = run_specs["source_db"], run_specs["target_db"]
    result = dict()
    total_tokens = 0
    include_description = True
    include_foreign_keys = True
    if run_specs["column_matching_strategy"] in [
        "llm-no_description",
        "llm-no_description_no_foreign_keys",
    ]:
        include_description = False
    if run_specs["column_matching_strategy"] in [
        "llm-no_foreign_keys",
        "llm-no_description_no_foreign_keys",
    ]:
        include_foreign_keys = False

    linking_candidates = {}

    if source_db.find("merged") == -1:
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
        for target_table, target_table_data in target_table_descriptions.items():
            if include_foreign_keys:
                linking_candidates[target_table] = {
                    "non_foreign_key_columns": ",".join(
                        [
                            item["name"]
                            for item in target_table_data["columns"].values()
                            if not item.get("is_foreign_key")
                        ]
                    ),
                    "foreign_keys": ",".join(
                        [
                            f"{item['name']}=>{item['linked_entry']}"
                            for item in target_table_data["columns"].values()
                            if item.get("is_foreign_key")
                        ]
                    ),
                }
            else:
                linking_candidates[target_table] = {
                    "columns": ",".join(
                        [item["name"] for item in target_table_data["columns"].values()]
                    )
                }
            if include_description:
                linking_candidates[target_table]["description"] = target_table_data[
                    "table_description"
                ]
    else:
        source_table_descriptions = get_merged_schema(source_db)
        target_table_descriptions = get_merged_schema(target_db)
        for target_table, target_table_data in target_table_descriptions.items():
            linking_candidates[target_table] = {
                "columns": ",".join(target_table_data["columns"].keys())
            }
            if include_description:
                linking_candidates[target_table]["description"] = target_table_data[
                    "table_description"
                ]

    for source_table, source_table_data in source_table_descriptions.items():
        if not source_table_data.get("columns"):
            continue

        prompt_source_template = prompt_template.replace(
            "{{source_table}}", json.dumps(source_table_data, indent=2)
        )

        batches_linking_candidate = split_dictionary_based_on_context_size(
            prompt_template=prompt_source_template,
            data=linking_candidates,
            run_specs=run_specs,
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
            if run_specs["table_selection_strategy"] == "llm-limit_context":
                operation_specs["context_size"] = run_specs["context_size"]
                candidates = list(batch_linking_candidates.keys())
                candidates.sort()
                operation_specs["batch_linking_candidates"] = candidates
            res = (
                OntologyAlignmentExperimentResult.objects(
                    operation_specs__operation="table_candidate_selection",
                    operation_specs__source_table=source_table,
                    operation_specs__source_db=source_db,
                    operation_specs__target_db=target_db,
                    operation_specs__rewrite_llm=run_specs["rewrite_llm"],
                    operation_specs__table_selection_llm=run_specs[
                        "table_selection_llm"
                    ],
                    operation_specs__table_selection_strategy=run_specs[
                        "table_selection_strategy"
                    ],
                )
                .order_by("-created_at")
                .first()
            )
            if res:
                try:
                    for source, targets in res.json_result.items():
                        assert source == source_table, f"{source} != {source_table}"
                        for target in targets:
                            assert target["target_table"] in linking_candidates, (
                                f"{target['target_table']} => {list(linking_candidates.keys())}"
                            )

                    result.update(res.json_result)
                    total_tokens += res.total_tokens

                    continue
                except Exception as e:
                    # res.delete()
                    total_tokens += res.total_tokens

            prompt = prompt_source_template.replace(
                "{{target_tables}}", json.dumps(batch_linking_candidates, indent=2)
            )

            response = complete(
                prompt, run_specs["table_selection_llm"], run_specs=run_specs
            )
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
        result_no_reasoning[key] = list({val["target_table"] for val in vals})
    flt["data"] = result_no_reasoning
    flt["total_tokens"] = total_tokens
    # res = OntologyTableSelectionResult.upsert(flt)
    return result_no_reasoning, total_tokens


def generate_llm_table_selection():
    for table_selection_strategy in [
        "llm-no_description_no_foreign_keys",
        "llm-no_description",
        "llm-no_foreign_keys",
    ]:
        for experiment in EXPERIMENTS:
            source, target = experiment.split("-")
            run_specs = {
                "column_matching_llm": "gpt-4o-mini",
                "column_matching_strategy": "llm",
                "rewrite_llm": "original",
                "source_db": source,
                "table_selection_llm": "gpt-4o-mini",
                "table_selection_strategy": table_selection_strategy,
                "target_db": target,
            }
            res = get_llm_table_selection_result(
                run_specs, refresh_existing_result=False
            )
            print(res)


if __name__ == "__main__":
    table_selection_strategy = "llm"
    for experiment in EXPERIMENTS:
        source, target = experiment.split("-")
        run_specs = {
            "column_matching_llm": "gpt-4o-mini",
            "column_matching_strategy": "llm",
            "rewrite_llm": "original",
            "source_db": source,
            "table_selection_llm": "gpt-4o-mini",
            "table_selection_strategy": table_selection_strategy,
            "target_db": target,
        }
        res, tokens = get_llm_table_selection_result(
            run_specs, refresh_existing_result=False
        )
        print(res, tokens)
