import json
from collections import defaultdict

from llm_ontology_alignment.utils import get_embeddings, cosine_distance


def generate_table_selection_vector_similarity_result():
    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite
    from llm_ontology_alignment.evaluations.latex_report.full_experiment_f1_score import experiments
    from llm_ontology_alignment.data_models.table_selection import OntologyTableSelectionResult

    for experiment in experiments:
        for rewrite_llm in ["gpt-3.5-turbo", "gpt-4o", "original"]:
            source_db, target_db = experiment.split("-")
            res = OntologyTableSelectionResult.objects(
                **{
                    "source_database": source_db,
                    "target_database": target_db,
                    "table_selection_llm": "",
                    "table_selection_strategy": "vector_similarity",
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
                    "table_selection_llm": "",
                    "table_selection_strategy": "vector_similarity",
                    "rewrite_llm": rewrite_llm,
                    "data": json_result,
                }
            )
            print(json_result)
            print(res)


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
