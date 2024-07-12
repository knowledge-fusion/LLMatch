import json
from collections import defaultdict

from llm_ontology_alignment.utils import get_embeddings, cosine_distance


def get_primary_key_matches(run_specs, source_db, target_db):
    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite
    from llm_ontology_alignment.data_models.experiment_models import OntologyAlignmentExperimentResult

    result = dict()

    target_linked_tables, target_table_embeddings = None, None
    for source_primary_key in OntologySchemaRewrite.objects(
        database=source_db, is_primary_key=True, llm_model=run_specs["rewrite_llm"]
    ):
        mapping_key = f"primary_key_mapping - {source_primary_key.table}"
        res = OntologyAlignmentExperimentResult.get_llm_result(
            run_specs=run_specs,
            sub_run_id=mapping_key,
        )
        if res:
            result.update(res.json_result)
            continue
        if not target_linked_tables:
            target_linked_tables, target_table_embeddings = get_target_table_info(run_specs, target_db)
        source_table_columns = OntologySchemaRewrite.objects(
            table=source_primary_key.table,
            llm_model=run_specs["rewrite_llm"],
            database=source_db,
            is_foreign_key__ne=True,
        ).distinct("column")
        source_embedding = get_embeddings(
            f"{source_primary_key.table}, {source_primary_key.table_description} {' '.join(source_table_columns)}"
        )
        cosine_similarities = dict()
        for target_table, target_embedding in target_table_embeddings.items():
            cosine_similarities[target_table] = cosine_distance(source_embedding, target_embedding)
        cosine_similarities = dict(sorted(cosine_similarities.items(), key=lambda x: x[1], reverse=True))
        linking_candidates = {}
        for idx, (table, score) in enumerate(cosine_similarities.items()):
            if idx < 3 or score > 0.5:
                linking_candidates[table] = target_linked_tables[table]

        prompt = (
            "You are an expert database schema matcher. "
            "You care given two databases, one from the source and one from the target. "
            "You are given the description of one source table and multiple target table candidates. "
            "The source table description is:\n"
        )
        prompt += json.dumps(
            {
                "table": f"{source_primary_key.table}",
                "columns": source_table_columns,
                "table_description": source_primary_key.table_description,
            },
            indent=2,
        )
        prompt += "\n\nThe target tables are as follows:\n"
        prompt += json.dumps(linking_candidates, indent=2)
        prompt += "\n\nTask: list all the tables in the target database that could be a match. "
        prompt += "\n\nTry to match the entire input by list down all potential mappings. Return the results in the following json format."
        prompt += """

    {
        'source_table': ['target_table1', 'target_table2', ...]
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


def get_target_table_info(run_specs, target_db):
    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite

    target_table_embeddings = dict()
    target_linked_tables = defaultdict(list)

    for target_primary_key in OntologySchemaRewrite.objects(
        database=target_db, is_primary_key=True, llm_model=run_specs["rewrite_llm"]
    ):
        target_embedding = get_embeddings(
            f"{target_primary_key.table} {target_primary_key.table_description} {OntologySchemaRewrite.objects(table=target_primary_key.table, llm_model=run_specs['rewrite_llm'], database=target_db).distinct('column')}"
        )
        target_table_embeddings[f"{target_primary_key.table}"] = target_embedding

        target_linked_tables[f"{target_primary_key.table}"].append(
            {
                "table_description": target_primary_key.table_description,
                "primary_key": f"{target_primary_key.table}.{target_primary_key.column}",
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

    assert run_specs["strategy"] == "match_with_schema_understanding"

    source_db, target_db = run_specs["source_db"].lower(), run_specs["target_db"].lower()

    primary_key_mapping_result = get_primary_key_matches(run_specs, source_db, target_db)

    reverse_primary_key_mapping_result = defaultdict(list)
    for source_table, target_tables in primary_key_mapping_result.items():
        reverse_primary_key_mapping_result[" ".join(target_tables)].append(source_table)

    source_linked_columns = OntologySchemaRewrite.get_reverse_normalized_columns(source_db, run_specs["rewrite_llm"])
    target_linked_columns = OntologySchemaRewrite.get_reverse_normalized_columns(target_db, run_specs["rewrite_llm"])

    target_primary_key_tables = OntologySchemaRewrite.get_primary_key_tables(target_db, run_specs["rewrite_llm"])
    for target_tables, source_tables in reverse_primary_key_mapping_result.items():
        if not target_tables:
            continue
        source_data = dict()
        for source_table in source_tables:
            source_data = json.loads(json.dumps(source_linked_columns[source_table]))

        target_data = dict()
        for target_table in target_tables.split(" "):
            target_data = json.loads(json.dumps(target_linked_columns[target_table]))

        sub_run_id = f"primary_key_table_matching-{' '.join(source_tables)}"
        res = OntologyAlignmentExperimentResult.get_llm_result(
            run_specs=run_specs,
            sub_run_id=sub_run_id,
        )
        if res:
            continue
            # res.delete()
        print(sub_run_id)

        response = get_llm_mapping(
            json.dumps(source_data, indent=2),
            json.dumps(target_data, indent=2),
            run_specs=run_specs,
        )
        data = response["extra"]["extracted_json"]
        OntologyAlignmentExperimentResult.upsert_llm_result(
            run_specs=run_specs,
            sub_run_id=sub_run_id,
            result=response,
        )
