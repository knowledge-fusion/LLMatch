import json
from collections import defaultdict

from llm_ontology_alignment.services.language_models import complete
from llm_ontology_alignment.utils import split_list_into_chunks, get_embeddings, cosine_distance

SCHEMA_UNDERSTANDING_STRATEGIES = [
    "schema_understanding",
    "schema_understanding_no_reasoning",
    "schema_understanding_embedding_selection",
    "schema_understanding_no_foreign_keys",
    "schema_understanding_no_description",
]


def get_table_mapping_embedding_selection(run_specs):
    assert run_specs["strategy"] == "schema_understanding_embedding_selection"
    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite
    from llm_ontology_alignment.data_models.experiment_models import OntologyAlignmentExperimentResult

    run_specs = {key: run_specs[key] for key in sorted(run_specs.keys())}
    run_id_prefix = json.dumps(run_specs)
    res = OntologyAlignmentExperimentResult.get_llm_result(
        run_specs=run_specs,
        sub_run_id="get_table_mapping_embedding_selection",
    )
    if res:
        return res.json_result
    source_db, target_db = run_specs["source_db"], run_specs["target_db"]
    source_table_descriptions = OntologySchemaRewrite.get_database_description(
        source_db, run_specs["rewrite_llm"], include_foreign_keys=True
    )
    target_table_descriptions = OntologySchemaRewrite.get_database_description(
        target_db, run_specs["rewrite_llm"], include_foreign_keys=True
    )
    target_embeddings = dict()
    for target_table, target_doc in target_table_descriptions.items():
        target_embeddings[target_table] = get_embeddings(json.dumps(target_doc))

    table_mapping = defaultdict(set)
    for source_table, source_table_data in source_table_descriptions.items():
        for source_column, source_column_data in source_table_data["columns"].items():
            source_embedding = get_embeddings(json.dumps(source_column_data))
            scores = dict()
            for target_table, target_embedding in target_embeddings.items():
                scores[target_table] = cosine_distance(source_embedding, target_embedding)
            tables = sorted(scores, key=lambda x: scores[x], reverse=True)
            print(f"Top tables for {source_table}.{source_column}: {tables}")
            for table in tables[0:2]:
                table_mapping[source_table].add(table)

    json_result = dict()
    for source_table, target_tables in table_mapping.items():
        json_result[source_table] = [{"target_table": target_table} for target_table in target_tables]

    res = OntologyAlignmentExperimentResult.upsert(
        {
            "dataset": f"{run_specs['source_db']}-{run_specs['target_db']}",
            "run_id_prefix": run_id_prefix,
            "sub_run_id": "get_table_mapping_embedding_selection",
            "json_result": json_result,
        }
    )
    return json_result


def get_table_mapping(run_specs):
    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite
    from llm_ontology_alignment.data_models.experiment_models import OntologyAlignmentExperimentResult
    import os

    assert run_specs["strategy"] in SCHEMA_UNDERSTANDING_STRATEGIES

    if run_specs["strategy"] == "schema_understanding_embedding_selection":
        return get_table_mapping_embedding_selection(run_specs)

    script_dir = os.path.dirname(os.path.abspath(__file__))

    file_path = os.path.join(
        script_dir,
        "table_matching_prompt.md"
        if run_specs["strategy"] == "schema_understanding"
        else "table_matching_prompt_no_reasoning.md",
    )
    with open(file_path, "r") as file:
        prompt_template = file.read()

    source_db, target_db = run_specs["source_db"], run_specs["target_db"]
    result = dict()
    include_description = True if run_specs["strategy"] != "schema_understanding_no_description" else False
    # include_foreignkey = True if run_specs["strategy"] != "schema_understanding_no_foreign_keys" else False
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
    prompt_template = prompt_template.replace("{{target_tables}}", json.dumps(linking_candidates, indent=2))
    for source_table, source_table_data in source_table_descriptions.items():
        if not source_table_data.get("columns"):
            continue
        mapping_key = f"table_candidate_selection - {source_table}"
        res = OntologyAlignmentExperimentResult.get_llm_result(
            run_specs=run_specs,
            sub_run_id=mapping_key,
        )
        if res:
            try:
                for source, targets in res.json_result.items():
                    assert source == source_table, f"{source} != {source_table}"
                    for target in targets:
                        assert (
                            target["target_table"] in linking_candidates
                        ), f'{target["target_table"]} => {list(linking_candidates.keys())}'

                result.update(res.json_result)
                print(res.json_result)
                continue
            except Exception as e:
                res.delete()

        prompt = prompt_template.replace("{{source_table}}", json.dumps(source_table_data, indent=2))

        response = complete(prompt, run_specs["matching_llm"], run_specs=run_specs)
        response = response.json()
        data = response["extra"]["extracted_json"]
        data
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
            run_specs=run_specs,
            sub_run_id=mapping_key,
            result=response,
        )
        assert res
        result.update(response["extra"]["extracted_json"])
    return result


def run_matching(run_specs):
    from llm_ontology_alignment.data_models.experiment_models import (
        OntologyAlignmentExperimentResult,
    )
    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite

    import os

    assert run_specs["strategy"] in SCHEMA_UNDERSTANDING_STRATEGIES

    script_dir = os.path.dirname(os.path.abspath(__file__))

    file_path = os.path.join(
        script_dir,
        "column_matching_prompt.md"
        if run_specs["strategy"] == "schema_understanding"
        else "column_matching_prompt_no_reasoning.md",
    )
    with open(file_path, "r") as file:
        prompt_template = file.read()

    source_db, target_db = run_specs["source_db"].lower(), run_specs["target_db"].lower()

    table_mapping = get_table_mapping(run_specs)

    reverse_table_mapping = defaultdict(list)
    for source_table, target_tables in table_mapping.items():
        if not target_tables:
            continue
        if not isinstance(target_tables[0], str):
            target_tables = [item["target_table"] for item in target_tables]
        reverse_table_mapping[" ".join(target_tables)].append(source_table)

    include_description = True if run_specs["strategy"] != "schema_understanding_no_description" else False
    # include_foreignkey = True if run_specs["strategy"] != "schema_understanding_no_foreign_keys" else False

    source_table_descriptions = OntologySchemaRewrite.get_database_description(
        source_db, run_specs["rewrite_llm"], include_foreign_keys=True, include_description=include_description
    )
    target_table_descriptions = OntologySchemaRewrite.get_database_description(
        target_db, run_specs["rewrite_llm"], include_foreign_keys=True, include_description=include_description
    )

    if run_specs["strategy"] == "schema_understanding_no_foreign_keys":
        for table in source_table_descriptions:
            for column in source_table_descriptions[table]["columns"]:
                source_table_descriptions[table]["columns"][column].pop("is_foreign_key", None)
                source_table_descriptions[table]["columns"][column].pop("linked_entry", None)

        for table in target_table_descriptions:
            for column in target_table_descriptions[table]["columns"]:
                target_table_descriptions[table]["columns"][column].pop("is_foreign_key", None)
                target_table_descriptions[table]["columns"][column].pop("linked_entry", None)

    for target_tables, source_tables in reverse_table_mapping.items():
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
        if len(source_tables) + len(target_tables) > 2 and run_specs["matching_llm"].find("gpt-4") == -1:
            source_batches = split_list_into_chunks(source_tables, chunk_size=2)
            target_batches = split_list_into_chunks(target_tables, chunk_size=2)
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
                    response = complete(prompt, run_specs["matching_llm"], run_specs=run_specs).json()
                    data = response["extra"]["extracted_json"]
                    assert data

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


def get_predictions(run_specs, G):
    from llm_ontology_alignment.data_models.experiment_models import OntologyAlignmentExperimentResult

    prediction_results = OntologyAlignmentExperimentResult.get_llm_result(run_specs=run_specs)
    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite

    assert run_specs["strategy"] in SCHEMA_UNDERSTANDING_STRATEGIES
    rewrite_queryset = OntologySchemaRewrite.objects(
        database__in=[run_specs["source_db"], run_specs["target_db"]], llm_model=run_specs["rewrite_llm"]
    )

    duration, prompt_token, completion_token = 0, 0, 0
    assert prediction_results
    predictions = defaultdict(lambda: defaultdict(list))
    for result in prediction_results:
        json_result = result.json_result
        duration += result.duration or 0
        prompt_token += result.prompt_tokens or 0
        completion_token += result.completion_tokens or 0
        if result.sub_run_id.find("schema_matching") == -1:
            continue
        for source, targets in json_result.items():
            if source not in G:
                print(f"Invalid source: {source}")
                continue
            source_table, source_column = source.split(".")
            source_entry = rewrite_queryset.filter(
                table__in=[source_table, source_table.lower()],
                column__in=[source_column, source_column.lower()],
            ).first()
            assert source_entry, source_entry
            if targets is None:
                targets = []
            for target in targets:
                if not target:
                    continue
                if isinstance(target, dict):
                    target = target["mapping"]
                if target.count(".") > 1:
                    tokens = target.split(".")
                    target = ".".join([tokens[-2], tokens[-1]])
                if target not in G:
                    print(f"Invalid target: {target}")
                    continue
                target_entry = rewrite_queryset.filter(
                    table__in=[target.split(".")[0], target.split(".")[0].lower()],
                    column__in=[target.split(".")[1], target.split(".")[1].lower()],
                ).first()
                assert target_entry, target
                # G.add_edge(f"{source_table}.{source_column}", target)
                predictions[target_entry.table][target_entry.column].append(source)
                print(f"{source_entry.table}.{source_entry.column} ==> {target_entry.table}.{target_entry.column}")
    return predictions
