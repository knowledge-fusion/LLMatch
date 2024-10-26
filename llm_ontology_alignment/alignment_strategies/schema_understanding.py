import json
from collections import defaultdict

from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite
from llm_ontology_alignment.services.language_models import complete


def run_matching(run_specs, table_selections):
    from llm_ontology_alignment.data_models.experiment_models import (
        OntologyAlignmentExperimentResult,
    )
    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite

    import os

    assert run_specs["column_matching_strategy"] in [
        "llm",
        "llm-reasoning",
        "llm-no_description",
        "llm-no_foreign_keys",
        "llm-one_table_to_one_table",
    ]

    script_dir = os.path.dirname(os.path.abspath(__file__))

    file_path = os.path.join(
        script_dir,
        "column_matching_prompt.md"
        if run_specs["column_matching_strategy"] == "llm-reasoning"
        else "column_matching_prompt_no_reasoning.md",
    )
    with open(file_path, "r") as file:
        prompt_template = file.read()

    source_db, target_db = run_specs["source_db"].lower(), run_specs["target_db"].lower()

    include_description = True if run_specs["column_matching_strategy"] != "llm-no_description" else False
    source_table_descriptions = OntologySchemaRewrite.get_database_description(
        source_db, run_specs["rewrite_llm"], include_foreign_keys=True, include_description=include_description
    )
    target_table_descriptions = OntologySchemaRewrite.get_database_description(
        target_db, run_specs["rewrite_llm"], include_foreign_keys=True, include_description=include_description
    )

    if run_specs["column_matching_strategy"] == "llm-no_foreign_keys":
        for table in source_table_descriptions:
            for column in source_table_descriptions[table]["columns"]:
                source_table_descriptions[table]["columns"][column].pop("is_foreign_key", None)
                source_table_descriptions[table]["columns"][column].pop("linked_entry", None)

        for table in target_table_descriptions:
            for column in target_table_descriptions[table]["columns"]:
                target_table_descriptions[table]["columns"][column].pop("is_foreign_key", None)
                target_table_descriptions[table]["columns"][column].pop("linked_entry", None)

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
        res = OntologyAlignmentExperimentResult.objects(operation_specs=operation_specs).first()
        if res:
            assert res.operation_specs["source_table"] == source_table
            assert res.operation_specs["target_tables"] == target_tables
            print(res.json_result)
            continue
            # res.delete()
        try:
            prompt = prompt_template.replace("{{source_columns}}", json.dumps(source_data, indent=2))
            prompt = prompt.replace("{{target_columns}}", json.dumps(target_data, indent=2))
            response = complete(prompt, run_specs["column_matching_llm"], run_specs=run_specs).json()
            data = response["extra"]["extracted_json"]
            assert data
            print(data)
            OntologyAlignmentExperimentResult.upsert_llm_result(
                operation_specs=operation_specs,
                result=response,
            )
        except Exception as e:
            print(e)
            OntologyAlignmentExperimentResult(
                operation_specs=operation_specs,
                dataset=f"{source_db}-{target_db}",
                text_result=str(e),
                json_result={},
            ).save()


def get_predictions(run_specs, table_selections):
    from llm_ontology_alignment.data_models.experiment_models import OntologyAlignmentExperimentResult

    assert run_specs["column_matching_strategy"] in [
        "llm",
        "llm-reasoning",
        "llm-no_description",
        "llm-no_foreign_keys",
        "llm-one_table_to_one_table",
    ]

    duration, prompt_token, completion_token = 0, 0, 0
    predictions = dict()
    for source, targets in table_selections:
        if not targets:
            continue
        prediction_results = OntologyAlignmentExperimentResult.objects(
            operation_specs__operation="column_matching",
            operation_specs__source_table=source,
            operation_specs__source_db=run_specs["source_db"],
            operation_specs__target_db=run_specs["target_db"],
            operation_specs__rewrite_llm=run_specs["rewrite_llm"],
            operation_specs__column_matching_strategy=run_specs["column_matching_strategy"],
            operation_specs__column_matching_llm=run_specs["column_matching_llm"],
            operation_specs__target_tables=targets,
        )

        assert len(prediction_results) == 1, str(len(prediction_results)) + str(run_specs) + str(source) + str(targets)
        prediction_results = prediction_results.first()
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
    for source, targets in experiment_result.json_result.items():
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
