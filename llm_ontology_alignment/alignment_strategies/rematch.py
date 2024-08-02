import json
import logging
from collections import defaultdict

from llm_ontology_alignment.utils import get_embeddings, cosine_distance, split_list_into_chunks

logger = logging.getLogger(__name__)


def table_to_doc(schema):
    docs = dict()
    index = 0
    for table, table_data in schema.items():
        primary_keys = []
        foreign_keys = []
        other_columns = []
        schema_rows = ["ID, ENT, ATT"]
        for idx, column in enumerate(table_data["columns"]):
            schema_rows.append(f"{idx}, {table}, {column}")
            column_data = table_data["columns"][column]
            column_text = f"{column}: {column_data['description']}"
            if column_data.get("is_primary_key"):
                primary_keys.append(column_text)
            elif column_data.get("is_foreign_key"):
                foreign_keys.append(column_text + f". References to: {column_data['linked_entry']}")
            else:
                other_columns.append(column_text)
        primary_keys_str = "\n".join(primary_keys)
        foreign_keys_str = "\n".join(foreign_keys)
        other_columns_str = "\n".join(other_columns)
        schema_str = "\n".join(schema_rows)
        docs[table] = (
            f"Table: {table}\n{table_data['table_description']}\n{schema_str} \n\n{table}\n Primary Keys: \n{primary_keys_str}\nForeign Keys: \n{foreign_keys_str}\nOther Columns: \n{other_columns_str}"
        )

    return docs


def create_top_k_mapping(source_table, source_docs, candidate_tables, target_docs, run_specs):
    import os

    script_dir = os.path.dirname(os.path.abspath(__file__))

    file_path = os.path.join(script_dir, "rematch_prompt_template.md")
    with open(file_path, "r") as file:
        prompt_template = file.read()

    target_texts = dict()
    for candidate_table in candidate_tables:
        target_texts[candidate_table] = target_docs[candidate_table]

    prompt = prompt_template.replace("{{source_docs}}", source_docs[source_table])

    prompt = prompt.replace("{{target_docs}}", "\n".join(target_texts.values()))

    from llm_ontology_alignment.services.language_models import complete

    response = complete(prompt=prompt, model=run_specs["matching_llm"], run_specs=run_specs)
    return response


def run_matching(run_specs):
    from llm_ontology_alignment.data_models.experiment_models import (
        OntologyAlignmentExperimentResult,
    )

    assert run_specs["strategy"] == "rematch"
    J = 2
    K = 5
    source_db, target_db = run_specs["source_db"], run_specs["target_db"]
    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite

    source_descriptions = OntologySchemaRewrite.get_database_description(
        source_db, run_specs["rewrite_llm"], include_foreign_keys=True
    )
    target_descriptions = OntologySchemaRewrite.get_database_description(
        target_db, run_specs["rewrite_llm"], include_foreign_keys=True
    )
    target_docs = table_to_doc(target_descriptions)
    target_embeddings = dict()
    for target_table, target_doc in target_docs.items():
        target_embeddings[target_table] = get_embeddings(target_doc)

    source_docs = table_to_doc(source_descriptions)
    target_docs = table_to_doc(target_descriptions)
    for source_table in source_docs:
        candidate_tables = list(target_descriptions.keys())
        if J > 0:
            candidate_tables = []
            for source_column, source_column_data in source_descriptions[source_table]["columns"].items():
                source_embedding = get_embeddings(json.dumps(source_column_data))
                scores = dict()
                for target_table, target_embedding in target_embeddings.items():
                    scores[target_table] = cosine_distance(source_embedding, target_embedding)
                tables = sorted(scores, key=lambda x: scores[x], reverse=True)
                print(f"Top tables for {source_table}.{source_column}: {tables}")
                for table in tables[0:J]:
                    candidate_tables.append(table)
        if len(candidate_tables) > 5 and run_specs["matching_llm"].find("gpt-4") == -1:
            batches = split_list_into_chunks(candidate_tables, chunk_size=2)
        for batch_tables in batches:
            try:
                sub_run_id = f"rematch - {source_table}- {'|'.join(batch_tables)}"
                record = OntologyAlignmentExperimentResult.get_llm_result(run_specs=run_specs, sub_run_id=sub_run_id)
                if record:
                    continue
                response = create_top_k_mapping(
                    source_table,
                    source_docs,
                    batch_tables,
                    target_docs,
                    run_specs=run_specs,
                ).json()
                data = response["extra"]["extracted_json"]
                assert data

                OntologyAlignmentExperimentResult.upsert_llm_result(
                    run_specs=run_specs,
                    sub_run_id=sub_run_id,
                    result=response,
                )
            except Exception as e:
                logger.exception(e)


def get_predictions(run_specs, G):
    from llm_ontology_alignment.data_models.experiment_models import OntologyAlignmentExperimentResult

    prediction_results = OntologyAlignmentExperimentResult.get_llm_result(run_specs=run_specs)
    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite

    assert run_specs["strategy"] == "rematch"
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
        for item in json_result.values():
            if not item:
                continue
            source_table = item["SRC_ENT"]
            source_column = item["SRC_ATT"]
            source = f"{source_table}.{source_column}"
            if source not in G:
                print(f"Invalid source: {source}")
                continue
            source_entry = rewrite_queryset.filter(
                table__in=[source_table, source_table.lower()],
                column__in=[source_column, source_column.lower()],
            ).first()
            assert source_entry, source_entry
            targets = []
            if item.get("TGT_ENT1", "NA") != "NA":
                targets.append(item["TGT_ENT1"] + "." + item["TGT_ATT1"])
            if item.get("TGT_ENT2", "NA") != "NA":
                targets.append(item["TGT_ENT2"] + "." + item["TGT_ATT2"])
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
                # G.add_edge(f"{source_table}.{source_column}", target)
                predictions[target_entry.table][target_entry.column].append(source)
                print(f"{source_entry.table}.{source_entry.column} ==> {target_entry.table}.{target_entry.column}")
    return predictions
