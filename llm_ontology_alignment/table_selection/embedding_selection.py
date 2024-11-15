import json
from collections import defaultdict

from llm_ontology_alignment.utils import get_embeddings, cosine_distance


def generate_table_selection_column_to_table_vector_similarity_result():
    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite
    from llm_ontology_alignment.constants import EXPERIMENTS
    from llm_ontology_alignment.data_models.table_selection import OntologyTableSelectionResult

    strategy = "column_to_table_vector_similarity"
    for experiment in EXPERIMENTS:
        for rewrite_llm in ["original"]:
            source_db, target_db = experiment.split("-")
            res = OntologyTableSelectionResult.objects(
                **{
                    "source_database": source_db,
                    "target_database": target_db,
                    "table_selection_llm": "None",
                    "table_selection_strategy": strategy,
                    "rewrite_llm": rewrite_llm,
                }
            ).first()
            if res:
                continue
            source_table_descriptions = OntologySchemaRewrite.get_database_description(
                source_db, rewrite_llm, include_foreign_keys=True
            )
            target_table_descriptions = OntologySchemaRewrite.get_database_description(
                target_db, rewrite_llm, include_foreign_keys=True
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
                json_result[source_table] = list(target_tables)

            res = OntologyTableSelectionResult.upsert(
                {
                    "source_database": source_db,
                    "target_database": target_db,
                    "table_selection_llm": "None",
                    "table_selection_strategy": strategy,
                    "rewrite_llm": rewrite_llm,
                    "data": json_result,
                }
            )
            print(json_result)
            print(res)


def generate_table_selection_table_to_table_vector_similarity_result():
    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite
    from llm_ontology_alignment.constants import EXPERIMENTS
    from llm_ontology_alignment.data_models.table_selection import OntologyTableSelectionResult

    strategy = "table_to_table_vector_similarity"
    for experiment in EXPERIMENTS:
        for rewrite_llm in ["gpt-3.5-turbo", "gpt-4o", "original"]:
            source_db, target_db = experiment.split("-")
            res = OntologyTableSelectionResult.objects(
                **{
                    "source_database": source_db,
                    "target_database": target_db,
                    "table_selection_llm": "None",
                    "table_selection_strategy": strategy,
                    "rewrite_llm": rewrite_llm,
                }
            ).first()
            if res:
                continue
            source_table_descriptions = OntologySchemaRewrite.get_database_description(
                source_db, rewrite_llm, include_foreign_keys=True
            )
            target_table_descriptions = OntologySchemaRewrite.get_database_description(
                target_db, rewrite_llm, include_foreign_keys=True
            )
            target_embeddings = dict()
            for target_table, target_doc in target_table_descriptions.items():
                target_embeddings[target_table] = get_embeddings(json.dumps(target_doc))

            table_mapping = dict()
            for source_table, source_table_data in source_table_descriptions.items():
                source_embedding = get_embeddings(json.dumps(source_table_data))
                scores = dict()
                for target_table, target_embedding in target_embeddings.items():
                    scores[target_table] = cosine_distance(source_embedding, target_embedding)
                tables = sorted(scores, key=lambda x: scores[x], reverse=True)
                print(f"Top tables for {source_table}: {tables}")
                table_mapping[source_table] = tables

            json_result = dict()
            for source_table, target_tables in table_mapping.items():
                json_result[source_table] = list(target_tables)

            res = OntologyTableSelectionResult.upsert(
                {
                    "source_database": source_db,
                    "target_database": target_db,
                    "table_selection_llm": "None",
                    "table_selection_strategy": strategy,
                    "rewrite_llm": rewrite_llm,
                    "data": json_result,
                }
            )
            print(json_result)
            print(res)


def get_column_to_table_vector_similarity_table_selection_result(run_specs, refresh_existing_result=False):
    strategy = "column_to_table_vector_similarity"
    assert run_specs["table_selection_strategy"] == strategy
    from llm_ontology_alignment.data_models.table_selection import OntologyTableSelectionResult

    res = OntologyTableSelectionResult.objects(
        **{
            "source_database": run_specs["source_db"],
            "target_database": run_specs["target_db"],
            "table_selection_llm": "None",
            "table_selection_strategy": strategy,
            "rewrite_llm": run_specs["rewrite_llm"],
        }
    ).first()
    if not res:
        res
    return res.data, 0


def get_table_to_table_vector_top10_similarity_table_selection_result(run_specs, refresh_existing_result=False):
    return get_table_to_table_vector_similarity_table_selection_result(run_specs, top_k=10)


def get_table_to_table_vector_top15_similarity_table_selection_result(run_specs, refresh_existing_result=False):
    return get_table_to_table_vector_similarity_table_selection_result(run_specs, top_k=15)


def get_table_to_table_vector_top5_similarity_table_selection_result(run_specs, refresh_existing_result=False):
    return get_table_to_table_vector_similarity_table_selection_result(run_specs, top_k=5)


def get_table_to_table_vector_similarity_table_selection_result(run_specs, top_k):
    strategy = [
        "table_to_table_vector_similarity",
        "table_to_table_top_10_vector_similarity",
        "table_to_table_top_15_vector_similarity",
    ]
    assert run_specs["table_selection_strategy"] in strategy
    from llm_ontology_alignment.data_models.table_selection import OntologyTableSelectionResult

    res = OntologyTableSelectionResult.objects(
        **{
            "source_database": run_specs["source_db"],
            "target_database": run_specs["target_db"],
            "table_selection_llm": "None",
            "table_selection_strategy": "table_to_table_vector_similarity",
            "rewrite_llm": run_specs["rewrite_llm"],
        }
    ).first()
    result = dict()
    for key, vals in res.data.items():
        result[key] = vals[:top_k]
    return result, 0
