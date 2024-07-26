import json
from collections import defaultdict

from llm_ontology_alignment.utils import get_embeddings


def get_table_mapping(run_specs):
    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite
    from llm_ontology_alignment.data_models.experiment_models import OntologyAlignmentExperimentResult
    import os

    script_dir = os.path.dirname(os.path.abspath(__file__))

    file_path = os.path.join(script_dir, "table_matching_prompt.md")
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
            result.update(res.json_result)
            continue

        prompt = prompt_template.replace("{{source_table}}", json.dumps(source_table_data, indent=2))

        from llm_ontology_alignment.services.language_models import complete

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


def get_target_table_info(run_specs, target_db):
    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite

    target_table_embeddings = dict()
    target_linked_tables = defaultdict(list)
    target_table_descriptions = OntologySchemaRewrite.get_database_description(
        target_db, run_specs["rewrite_llm"], include_foreign_keys=False
    )
    for target_table, target_table_data in target_table_descriptions.items():
        if not target_table_data.get("columns"):
            continue
        target_embedding = get_embeddings(json.dumps(target_table_data))
        target_table_embeddings[target_table] = target_embedding

        target_linked_tables[f"{target_table}"].append(
            {
                "table_description": target_table_data["table_description"],
                # "primary_key": f"{target_primary_key.table}.{target_primary_key.column}",
                # "columns": OntologySchemaRewrite.objects(
                #     table=target_primary_key.table, llm_model=run_specs["rewrite_llm"], database=target_db
                # ).distinct("column"),
            }
        )
    return target_linked_tables, target_table_embeddings


def run_matching_with_schema_understanding(run_specs):
    from llm_ontology_alignment.alignment_strategies.llm_mapping import get_llm_mapping
    from llm_ontology_alignment.data_models.experiment_models import (
        OntologyAlignmentExperimentResult,
    )
    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite

    assert run_specs["strategy"] == "schema_understanding"

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
            target_data[target_table] = target_table_descriptions[target_table]

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
            response = get_llm_mapping(
                json.dumps(source_data, indent=2),
                json.dumps(target_data, indent=2),
                run_specs=run_specs,
            )
            data = response["extra"]["extracted_json"]
            data
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
