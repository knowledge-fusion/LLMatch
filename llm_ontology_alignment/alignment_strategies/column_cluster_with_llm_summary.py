import json
from collections import defaultdict


def get_dbscan_clusters(dataset, vector_field, eps=0.3, min_samples=2):
    from sklearn.cluster import DBSCAN

    # Sample data: a list of vectors (2D array)
    vectors = [d.get(vector_field) for d in dataset.values()]

    # DBSCAN parameters

    # Applying DBSCAN
    dbscan = DBSCAN(eps=eps, min_samples=min_samples)
    dbscan.fit(vectors)

    # Extracting labels and core samples
    labels = dbscan.labels_
    core_samples = dbscan.core_sample_indices_
    for i, d in enumerate(dataset.values()):
        d["dbscan_cluster"] = labels[i]

    return dataset


def get_kmeans_clusters(dataset, vector_field, n_clusters=3):
    from sklearn.cluster import KMeans
    import numpy as np

    # Extract vector values
    vectors = [d.get(vector_field) for d in dataset.values()]

    # Convert vectors to numpy array
    vectors_array = np.array(vectors)

    # pca = PCA(n_components=30)
    # reduced_embeddings = pca.fit_transform(vectors_array)

    # Perform KMeans clustering
    kmeans = KMeans(n_clusters=n_clusters)
    kmeans.fit(vectors_array)

    # Get cluster labels
    cluster_labels = kmeans.labels_

    # Add cluster labels to data
    for i, d in enumerate(dataset.values()):
        d["kmeans_cluster"] = cluster_labels[i]

    return dataset


def run_cluster_with_llm_summary(run_specs):
    from llm_ontology_alignment.alignment_strategies.llm_mapping import get_llm_mapping
    from llm_ontology_alignment.data_models.experiment_models import (
        OntologyAlignmentExperimentResult,
    )
    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite

    assert run_specs["strategy"] == "cluster_at_table_level_with_llm_summary_and_llm_column_name"
    embedding_strategy = "rewritten_column,rewritten_column_description,rewritten_table"
    mapping_candidates = defaultdict(dict)
    table_descriptions = {}
    table_names = []
    column_names = []
    source_db, target_db = run_specs["dataset"].lower().split("_")

    source_linked_columns = OntologySchemaRewrite.get_reverse_normalized_columns(source_db, run_specs["rewrite_llm"])
    target_linked_columns = OntologySchemaRewrite.get_reverse_normalized_columns(target_db, run_specs["rewrite_llm"])
    table_descriptions = defaultdict(list)
    for table_name in OntologySchemaRewrite.objects(
        database__in=[source_db, target_db], llm_model=run_specs["rewrite_llm"]
    ).distinct("rewritten_table"):
        record = OntologySchemaRewrite.objects(rewritten_table=table_name).first()
        table_descriptions[record.database].append(
            {"description": record.rewritten_table_description, "table_name": record.rewritten_table}
        )

    response = get_llm_mapping(
        json.dumps(table_descriptions, indent=2),
        json.dumps([item["primary_record"] for item in source_linked_columns.values()], indent=2),
        json.dumps([item["primary_record"] for item in target_linked_columns.values()], indent=2),
        run_specs,
    )
    primary_key_mapping_result = response["extra"]["extracted_json"]
    res = OntologyAlignmentExperimentResult.upsert_llm_result(
        run_specs=run_specs,
        sub_run_id="primary_keys",
        result=response,
    )

    for item in OntologySchemaRewrite.objects(
        database=[source_db, target_db],
        llm_model=run_specs["rewrite_llm"],
    ):
        # table_descriptions[item.table_name] = item.extra_data["table_description"]
        record = {
            "table": item.rewritten_table,
            "column": item.rewritten_column,
            "column_description": item.rewritten_column_description,
            "database": item.database,
            "similar_items": item.get_similar_items(embedding_strategy, target_db)[0:10],
        }
        mapping_candidates[item.database][f"{item.original_table}.{item.original_column}"] = record
        table_names.append(item.original_table)
        column_names.append(item.original_column)
        for similar_item in record["similar_items"]:
            table_names.append(similar_item["table"])
            column_names.append(similar_item["column"])
        table_descriptions[item.rewritten_table] = item.rewritten_table_description

    for source_table, target_tables in primary_key_mapping_result.items():
        source_table = source_table[1:]
        source = mapping_candidates[source_db][source_table]
        for target_table in target_tables:
            target_table = target_table[1:]
            target = mapping_candidates[target_db][target_table]
            print("\n\nsource", source)
            print("target", target)
            print("\n\n")
    # map primary keys
    for key, record in mapping_candidates.items():
        linked_columns = record["linked_columns"]
        if linked_columns:
            linked_columns
    for cluster_id in range(run_specs["n_clusters"]):
        source_candidates, target_candidates = defaultdict(list), defaultdict(list)
        for similar_item in clustered_data.values():
            if similar_item["cluster"] != cluster_id:
                continue
            entry = {
                "table": similar_item["table"],
                "column": similar_item["column"],
                "description": similar_item["description"],
                "id": similar_item["id"],
                "matching_role": similar_item["matching_role"],
            }
            if similar_item["matching_role"] == "source":
                entry["id"] = f"S{entry['id']}"
                source_candidates[entry["table"]].append(entry)
            else:
                entry["id"] = f"T{entry['id']}"
                target_candidates[entry["table"]].append(entry)

        source_text = ""
        for table, columns in source_candidates.items():
            source_text += f"Table: {table}: {table_descriptions[table]}\n"
            source_text += f"\n Columns: {json.dumps(columns, indent=2)}\n"

        target_text = ""
        for table, columns in target_candidates.items():
            target_text += f"Table: {table}: {table_descriptions[table]}\n"
            target_text += f"\n Columns: {json.dumps(columns, indent=2)}\n"

        if not source_candidates or not target_candidates:
            continue
        record = OntologyAlignmentExperimentResult.objects(
            run_id_prefix=json.dumps(run_specs), sub_run_id=str(cluster_id)
        ).first()
        if record:
            # continue
            record.delete()
        from datetime import datetime

        start = datetime.utcnow()
        response = get_llm_mapping(
            table_descriptions,
            source_text,
            target_text,
            llm=run_specs["llm"],
            template=run_specs["template"],
        )
        end = datetime.utcnow()
        res = OntologyAlignmentExperimentResult.upsert_llm_result(
            run_specs=run_specs,
            sub_run_id=str(cluster_id),
            result=response,
            start=start,
            end=end,
        )
        for source_id, target_ids in res.json_result.items():
            source = mapping_candidates[source_id[1:]]
            assert source["matching_role"] == "source"
            print("\n\nsource", source)
            if target_ids:
                target1 = mapping_candidates[target_ids[0][1:]]
                if not target1["matching_role"] == "target":
                    print("error, matched to source")
                else:
                    print("target1", target1)
            if len(target_ids) > 1:
                target2 = mapping_candidates[target_ids[1][1:]]
                if not target2["matching_role"] == "target":
                    print("error, matched to source")
                else:
                    print("target2", target2)
