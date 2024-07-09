import json
from collections import defaultdict

from llm_ontology_alignment.utils import get_embeddings, cosine_distance


def get_primary_key_matches(run_specs, source_db, target_db):
    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite
    from llm_ontology_alignment.data_models.experiment_models import OntologyAlignmentExperimentResult

    result = dict()

    target_table_embeddings = dict()
    target_linked_tables = defaultdict(list)
    for target_primary_key in OntologySchemaRewrite.objects(
        database=target_db, is_primary_key=True, llm_model=run_specs["rewrite_llm"]
    ):
        target_embedding = get_embeddings(
            f"{target_primary_key.table}, {target_primary_key.column} {target_primary_key.table_description}"
        )
        target_table_embeddings[f"{target_primary_key.table}.{target_primary_key.column}"] = target_embedding

        target_linked_tables[f"{target_primary_key.table}.{target_primary_key.column}"].append(
            {
                "table_description": target_primary_key.table_description,
                "primary_key": f"{target_primary_key.table}.{target_primary_key.column}",
                # "columns": OntologySchemaRewrite.objects(
                #     table=target_primary_key.table, llm_model=run_specs["rewrite_llm"], database=target_db
                # ).distinct("column"),
            }
        )
    for source_primary_key in OntologySchemaRewrite.objects(
        database=source_db, is_primary_key=True, llm_model=run_specs["rewrite_llm"]
    ):
        mapping_key = f"primary_key_mapping - {source_primary_key.table}.{source_primary_key.column}"
        res = OntologyAlignmentExperimentResult.get_llm_result(
            run_specs=run_specs,
            sub_run_id=mapping_key,
        )
        if res:
            result.update(res.json_result)
            continue
        source_embedding = get_embeddings(
            f"{source_primary_key.table}, {source_primary_key.column} {source_primary_key.table_description}"
        )
        cosine_similarities = dict()
        for target_key, target_embedding in target_table_embeddings.items():
            cosine_similarities[target_key] = cosine_distance(source_embedding, target_embedding)
        cosine_similarities = dict(sorted(cosine_similarities.items(), key=lambda x: x[1], reverse=True))
        linking_candidates = {}
        for idx, (table, score) in enumerate(cosine_similarities.items()):
            if idx < 3 or score > 0.5:
                linking_candidates[table] = target_linked_tables[table]

        source_table_description = OntologySchemaRewrite.get_table_columns_description(
            database=source_db, table=source_primary_key.table, llm_model=run_specs["rewrite_llm"]
        )
        prompt = (
            "You are an expert database schema matcher. "
            "You care given two databases, one from the source and one from the target. "
            "You are given the primary key and linked_columns of the tables in the source database. "
            "You are asked to match the primary keys of the tables in the target database. Only focus on the primary keys."
            "The primary keys of the tables in the source database are as follows:\n"
        )
        prompt += json.dumps(
            {
                "primary_key": f"{source_primary_key.table}.{source_primary_key.column}",
                "details": source_table_description,
            },
            indent=2,
        )
        prompt += "\n\nThe primary keys of the tables in the target database are as follows:\n"
        prompt += json.dumps(linking_candidates, indent=2)
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
            sub_run_id=mapping_key,
            result=response,
        )
        result.update(data)
    return result


def run_matching_with_schema_understanding(run_specs):
    from llm_ontology_alignment.alignment_strategies.llm_mapping import get_llm_mapping
    from llm_ontology_alignment.data_models.experiment_models import (
        OntologyAlignmentExperimentResult,
    )
    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite

    assert run_specs["strategy"] == "match_with_schema_understanding"

    source_db, target_db = run_specs["source_db"].lower(), run_specs["target_db"].lower()

    primary_key_mapping_result = get_primary_key_matches(run_specs, source_db, target_db)
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
