import json
from collections import defaultdict

from llm_ontology_alignment.services.language_models import complete


def get_table_mapping(run_specs):
    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite
    from llm_ontology_alignment.data_models.experiment_models import OntologyAlignmentExperimentResult
    import os

    assert run_specs["strategy"] in ["schema_understanding", "schema_understanding_no_reasoning"]
    script_dir = os.path.dirname(os.path.abspath(__file__))

    file_path = os.path.join(
        script_dir, "table_matching_prompt.md" if run_specs["strategy"] else "table_matching_prompt_no_reasoning.md"
    )
    with open(file_path, "r") as file:
        prompt_template = file.read()

    source_db, target_db = run_specs["source_db"], run_specs["target_db"]
    result = dict()
    source_table_descriptions = OntologySchemaRewrite.get_database_description(
        source_db, run_specs["rewrite_llm"], include_foreign_keys=True
    )
    target_table_descriptions = OntologySchemaRewrite.get_database_description(
        target_db, run_specs["rewrite_llm"], include_foreign_keys=True
    )
    linking_candidates = {}
    for target_table, target_table_data in target_table_descriptions.items():
        linking_candidates[target_table] = {
            "table_description": target_table_data["table_description"],
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
    prompt_template = prompt_template.replace("{{target_tables}}", json.dumps(linking_candidates, indent=2))
    for table, source_table_data in source_table_descriptions.items():
        if not source_table_data.get("columns"):
            continue
        mapping_key = f"table_candidate_selection - {table}"
        res = OntologyAlignmentExperimentResult.get_llm_result(
            run_specs=run_specs,
            sub_run_id=mapping_key,
        )
        if res:
            try:
                for source, targets in res.json_result.items():
                    assert source == table
                    for target in targets:
                        assert target["target_table"] in linking_candidates, target["target_table"]

                result.update(res.json_result)

                continue
            except Exception as e:
                res.delete()

        prompt = prompt_template.replace("{{source_table}}", json.dumps(source_table_data, indent=2))

        response = complete(prompt, run_specs["matching_llm"], run_specs=run_specs)
        response = response.json()
        data = response["extra"]["extracted_json"]
        data
        for source, targets in data.items():
            assert source == table
            for target in targets:
                assert target["target_table"] in linking_candidates, target["target_table"]
        res = OntologyAlignmentExperimentResult.upsert_llm_result(
            run_specs=run_specs,
            sub_run_id=mapping_key,
            result=response,
        )
        assert res
        result.update(data)
    return result


def run_matching(run_specs):
    from llm_ontology_alignment.data_models.experiment_models import (
        OntologyAlignmentExperimentResult,
    )
    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite

    import os

    assert run_specs["strategy"] in ["schema_understanding", "schema_understanding_no_reasoning"]

    script_dir = os.path.dirname(os.path.abspath(__file__))

    file_path = os.path.join(
        script_dir, "column_matching_prompt.md" if run_specs["strategy"] else "column_matching_prompt_no_reasoning.md"
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

    source_table_descriptions = OntologySchemaRewrite.get_database_description(
        source_db, run_specs["rewrite_llm"], include_foreign_keys=True
    )
    target_table_descriptions = OntologySchemaRewrite.get_database_description(
        target_db, run_specs["rewrite_llm"], include_foreign_keys=True
    )

    for target_tables, source_tables in reverse_table_mapping.items():
        if not target_tables:
            continue
        source_data = dict()
        for source_table in source_tables:
            source_data[source_table] = source_table_descriptions[source_table]

        target_data = dict()
        for target_table in target_tables.split(" "):
            if target_table == "Medicare_Beneficiary_Summary":
                target_table
            target_data[target_table] = target_table_descriptions[target_table]
        OntologyAlignmentExperimentResult.objects(run_id_prefix=json.dumps(run_specs))
        sub_run_id = f"schema_matching - {' '.join(source_tables)}"
        res = OntologyAlignmentExperimentResult.get_llm_result(
            run_specs=run_specs,
            sub_run_id=sub_run_id,
        )
        if res:
            continue
            # res.delete()
        print(sub_run_id)
        try:
            prompt = prompt_template.replace("{{source_columns}}", json.dumps(source_data, indent=2))
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

    assert run_specs["strategy"] in ["schema_understanding", "schema_understanding_no_reasoning"]
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
            for target in targets:
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
                G.add_edge(f"{source_table}.{source_column}", target)
                predictions[target_entry.table][target_entry.column].append(source)
                print(f"{source_entry.table}.{source_entry.column} ==> {target_entry.table}.{target_entry.column}")
    return predictions
