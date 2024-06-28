import json


def match_primary_keys(run_specs, source_db, target_db):
    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite
    from llm_ontology_alignment.data_models.experiment_models import OntologyAlignmentExperimentResult

    res = OntologyAlignmentExperimentResult.get_llm_result(
        run_specs=run_specs,
        sub_run_id="primary_keys",
    )
    if res:
        primary_key_mapping_result = res.json_result
        return primary_key_mapping_result
    source_linked_columns = OntologySchemaRewrite.get_reverse_normalized_columns(
        source_db, run_specs["rewrite_llm"], with_column_description=False
    )
    target_linked_columns = OntologySchemaRewrite.get_reverse_normalized_columns(
        target_db, run_specs["rewrite_llm"], with_column_description=False
    )
    prompt = (
        "You are an expert database schema matcher. You care given two databases, one from the source and one from the target. "
        "You are given the primary key and linked_columns of the tables in the source database. You are asked to match the primary keys of the tables in the target database. "
        "The primary keys of the tables in the source database are as follows:\n"
    )
    prompt += json.dumps(source_linked_columns, indent=2)
    prompt += "\n\nThe primary keys of the tables in the target database are as follows:\n"
    prompt += json.dumps(target_linked_columns, indent=2)
    prompt += "\n\nFor each table in the source database, you are asked to list all the tables in the target database that could be a match. "
    prompt += "\n\nTry to match the entire input by list down all potential mappings. Return the results in the following json format."
    prompt += """

{
    'source_key1': ['target_key1', 'target_key99', ...]
    'source_key2': ...',
    ...
    }
}
"""
    prompt += "Return only a json object with the mappings with no other text."
    from llm_ontology_alignment.services.language_models import complete

    response = complete(prompt, run_specs["matching_llm"], run_specs=run_specs)
    response = response.json()
    data = response["extra"]["extracted_json"]
    res = OntologyAlignmentExperimentResult.upsert_llm_result(
        run_specs=run_specs,
        sub_run_id="primary_keys",
        result=response,
    )
    return data


def run_matching_with_schema_understanding(run_specs):
    from llm_ontology_alignment.alignment_strategies.llm_mapping import get_llm_mapping
    from llm_ontology_alignment.data_models.experiment_models import (
        OntologyAlignmentExperimentResult,
    )
    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite

    assert run_specs["strategy"] == "match_with_schema_understanding"

    source_db, target_db = run_specs["dataset"].lower().split("_")

    primary_key_mapping_result = match_primary_keys(run_specs, source_db, target_db)
    source_linked_columns = OntologySchemaRewrite.get_reverse_normalized_columns(source_db, run_specs["rewrite_llm"])
    target_linked_columns = OntologySchemaRewrite.get_reverse_normalized_columns(target_db, run_specs["rewrite_llm"])

    target_primary_key_tables = OntologySchemaRewrite.get_primary_key_tables(target_db, run_specs["rewrite_llm"])
    for source_primary_key, target_primary_keys in primary_key_mapping_result.items():
        for target_primary_key in target_primary_keys:
            source_data = source_linked_columns[source_primary_key]
            target_data = json.loads(json.dumps(target_linked_columns[target_primary_key]))
            for key, value in target_primary_key_tables.items():
                if key not in target_data:
                    target_data[key] = value

            for source_table, source_table_description in source_data.items():
                sub_run_id = f"primary_key_table_matching-{source_table}-{target_primary_key}"
                res = OntologyAlignmentExperimentResult.get_llm_result(
                    run_specs=run_specs,
                    sub_run_id=sub_run_id,
                )
                if res:
                    continue
                    # res.delete()
                print(sub_run_id)

                response = get_llm_mapping(
                    json.dumps(source_table_description, indent=2),
                    json.dumps(target_data, indent=2),
                    run_specs=run_specs,
                )
                data = response["extra"]["extracted_json"]
                OntologyAlignmentExperimentResult.upsert_llm_result(
                    run_specs=run_specs,
                    sub_run_id=sub_run_id,
                    result=response,
                )
