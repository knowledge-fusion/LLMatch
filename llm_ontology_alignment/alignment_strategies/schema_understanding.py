import json
from collections import defaultdict


from llm_ontology_alignment.services.language_models import complete
from llm_ontology_alignment.utils import split_list_into_chunks

SCHEMA_UNDERSTANDING_STRATEGIES = [
    "schema_understanding",
    "schema_understanding_no_reasoning",
    "schema_understanding_embedding_selection",
    "schema_understanding_no_foreign_keys",
    "schema_understanding_no_description",
    "schema_understanding_one_table_to_one_table",
]


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

    reverse_table_mapping = []
    if isinstance(table_selections, dict):
        temp_mapping = defaultdict(list)
        for source_table, target_tables in table_selections.items():
            if not target_tables:
                continue
            if not isinstance(target_tables[0], str):
                target_tables = [item["target_table"] for item in target_tables]
            temp_mapping[" ".join(target_tables)].append(source_table)
        reverse_table_mapping = list(temp_mapping.items())

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

    for target_tables, source_tables in reverse_table_mapping:
        if not target_tables:
            continue
        source_data = dict()
        for source_table in source_tables:
            if source_table not in source_table_descriptions:
                source_table
            source_data[source_table] = source_table_descriptions[source_table]

        OntologyAlignmentExperimentResult.objects(run_id_prefix=json.dumps(run_specs))
        source_batches = [source_tables]
        target_tables = target_tables.split(" ")
        target_batches = [target_tables]
        if len(source_tables) + len(target_tables) > 2 and run_specs["column_matching_llm"].find("gpt-4") == -1:
            source_batches = split_list_into_chunks(source_tables, chunk_size=2)
            target_batches = split_list_into_chunks(target_tables, chunk_size=2)
        if run_specs["column_matching_strategy"] == "llm-one_table_to_one_table":
            source_batches = split_list_into_chunks(source_tables, chunk_size=1)
            target_batches = split_list_into_chunks(target_tables, chunk_size=1)
        for batch_source_tables in source_batches:
            for batch_target_tables in target_batches:
                target_data = dict()
                for target_table in batch_target_tables:
                    target_data[target_table] = target_table_descriptions[target_table]

                batch_source_data = {source_table: source_data[source_table] for source_table in batch_source_tables}
                sub_run_id = f"schema_matching - {' '.join(batch_source_tables)} - {' '.join(batch_target_tables)}"
                res = OntologyAlignmentExperimentResult.get_llm_result(
                    run_specs=run_specs,
                    sub_run_id=sub_run_id,
                )
                if res:
                    continue
                    # res.delete()
                print(sub_run_id)
                try:
                    prompt = prompt_template.replace("{{source_columns}}", json.dumps(batch_source_data, indent=2))
                    prompt = prompt.replace("{{target_columns}}", json.dumps(target_data, indent=2))
                    response = complete(prompt, run_specs["column_matching_llm"], run_specs=run_specs).json()
                    data = response["extra"]["extracted_json"]
                    assert data
                    print(data)
                    OntologyAlignmentExperimentResult.upsert_llm_result(
                        run_specs=run_specs,
                        sub_run_id=sub_run_id,
                        result=response,
                    )
                except Exception as e:
                    print(e)
                    print(source_data)
                    print(target_data)
                    print(sub_run_id)


def get_predictions(run_specs):
    from llm_ontology_alignment.data_models.experiment_models import OntologyAlignmentExperimentResult

    prediction_results = OntologyAlignmentExperimentResult.get_llm_result(run_specs=run_specs)
    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite

    assert run_specs["column_matching_strategy"] in [
        "llm",
        "llm-reasoning",
        "llm-no_description",
        "llm-no_foreign_keys",
        "llm-one_table_to_one_table",
    ]
    rewrite_queryset = OntologySchemaRewrite.objects(
        database__in=[run_specs["source_db"], run_specs["target_db"]], llm_model=run_specs["rewrite_llm"]
    )

    duration, prompt_token, completion_token = 0, 0, 0
    assert prediction_results
    predictions = defaultdict(list)
    for result in prediction_results:
        json_result = result.json_result
        duration += result.duration or 0
        prompt_token += result.prompt_tokens or 0
        completion_token += result.completion_tokens or 0
        if result.sub_run_id.find("schema_matching") == -1:
            continue
        for source, targets in json_result.items():
            source_table, source_column = source.split(".")
            source_entry = rewrite_queryset.filter(
                table__in=[source_table, source_table.lower()],
                column__in=[source_column, source_column.lower()],
            ).first()
            if source_entry.linked_table:
                source_entry = rewrite_queryset.filter(
                    table=source_entry.linked_table,
                    column=source_entry.linked_column,
                ).first()
            assert source_entry, source
            if targets is None:
                targets = []
            for target in targets:
                if not target or target in ["None"]:
                    continue
                if isinstance(target, dict):
                    try:
                        target = target["mapping"]
                    except Exception as e:
                        print(json_result)
                        continue
                if target.count(".") > 1:
                    tokens = target.split(".")
                    target = ".".join([tokens[-2], tokens[-1]])
                target_entry = rewrite_queryset.filter(
                    table__in=[target.split(".")[0], target.split(".")[0].lower()],
                    column__in=[target.split(".")[1], target.split(".")[1].lower()],
                ).first()
                if target_entry.linked_table:
                    target_entry = rewrite_queryset.filter(
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
    return predictions
