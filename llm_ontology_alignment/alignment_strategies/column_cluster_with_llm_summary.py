import json
from collections import defaultdict


def plot_distribution(dataset, vector_field, model_name):
    import numpy as np
    import matplotlib.pyplot as plt
    from sklearn.neighbors import NearestNeighbors

    # Generate sample data
    X = [d.get(vector_field) for d in dataset.values()]

    # Compute the k-nearest neighbors
    k = 5  # usually 4 for DBSCAN (3 neighbors + the point itself)
    neighbors = NearestNeighbors(n_neighbors=k)
    neighbors_fit = neighbors.fit(X)
    distances, indices = neighbors_fit.kneighbors(X)

    # Sort the distances (4th column, i.e., distance to the 3rd nearest neighbor)
    distances = np.sort(distances[:, k - 1], axis=0)

    # Plot the k-NN distances
    plt.plot(distances)
    plt.xlabel("Points sorted by distance")
    plt.ylabel("k-NN distance")
    plt.title(f"{model_name} k-NN Distance for determining eps")
    plt.savefig(f"plots/{model_name}_k{k}_nn_distance_plot.png")


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
    from llm_ontology_alignment.data_models.experiment_models import (
        OntologyAlignmentData,
    )
    from llm_ontology_alignment.alignment_strategies.llm_mapping import get_llm_mapping

    from llm_ontology_alignment.data_models.experiment_models import (
        OntologyAlignmentExperimentResult,
    )

    assert (
        run_specs["strategy"]
        == "cluster_at_table_level_with_llm_summary_and_llm_column_name"
    )

    data = {}
    table_descriptions = {}
    for item in OntologyAlignmentData.objects(dataset=run_specs["dataset"]):
        try:
            table_descriptions[item.table_name] = item.extra_data["table_description"]
            data[str(item.extra_data["matching_index"])] = {
                "table": item.table_name,
                "column": item.column_name,
                "llm_summary_embedding": item.llm_summary_embedding,
                "description": item.llm_description,
                "id": item.extra_data["matching_index"],
                "matching_role": item.extra_data["matching_role"],
            }
        except Exception:
            raise

    clustered_data = get_kmeans_clusters(
        data, "llm_summary_embedding", n_clusters=run_specs["n_clusters"]
    )

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
            source = data[source_id[1:]]
            assert source["matching_role"] == "source"
            print("\n\nsource", source)
            if target_ids:
                target1 = data[target_ids[0][1:]]
                if not target1["matching_role"] == "target":
                    print("error, matched to source")
                else:
                    print("target1", target1)
            if len(target_ids) > 1:
                target2 = data[target_ids[1][1:]]
                if not target2["matching_role"] == "target":
                    print("error, matched to source")
                else:
                    print("target2", target2)


def print_ground_truth_cluster(dataset):
    from llm_ontology_alignment.data_models.experiment_models import (
        OntologyAlignmentGroundTruth,
    )

    from llm_ontology_alignment.data_models.experiment_models import (
        OntologyAlignmentData,
        SchemaRewrite,
    )

    column_descriptions = defaultdict(lambda: defaultdict(dict))
    column_embeddings = defaultdict(lambda: defaultdict(dict))
    result = defaultdict(lambda: defaultdict(dict))
    for item in OntologyAlignmentData.objects(dataset=dataset):
        column_descriptions["original"][item.table_name][item.column_name] = (
            item.extra_data["column_description"]
        )
        column_embeddings["original"][item.table_name][item.column_name] = (
            item.default_embedding
        )

    for item in SchemaRewrite.objects(dataset=dataset):
        column_descriptions[item.llm_model][item.original_table][
            item.original_column
        ] = item.rewritten_column_description
        column_embeddings[item.llm_model][item.original_table][item.original_column] = (
            item.column_embedding
        )
    for model in column_embeddings:
        data = {}
        for table in column_embeddings[model]:
            for column in column_embeddings[model][table]:
                data[str(len(data))] = {
                    "table": table,
                    "column": column,
                    "embedding": column_embeddings[model][table][column],
                    "description": column_descriptions[model][table][column],
                }

        clustered_data = get_kmeans_clusters(data, "embedding", n_clusters=5)
        plot_distribution(clustered_data, "embedding", model)
        clustered_data = get_dbscan_clusters(
            clustered_data, "embedding", eps=0.78, min_samples=2
        )

        knn_cluster_info = defaultdict(dict)
        dbscan_cluster_info = defaultdict(dict)
        kmeans_cluster_data = defaultdict(list)
        dbscan_cluster_data = defaultdict(list)
        for item in clustered_data.values():
            knn_cluster_info[item["table"]][item["column"]] = item["kmeans_cluster"]
            dbscan_cluster_info[item["table"]][item["column"]] = item["dbscan_cluster"]
            kmeans_cluster_data[item["kmeans_cluster"]].append(
                (item["table"], item["column"])
            )
            dbscan_cluster_data[item["dbscan_cluster"]].append(
                (item["table"], item["column"])
            )
        try:
            knn_matched_cluster = 0
            knn_non_matched_cluster = 0
            dbscan_matched_cluster = 0
            dbscan_non_matched_cluster = 0
            for item in OntologyAlignmentGroundTruth.objects(dataset=dataset):
                print(item.dataset)
                for mapping in item.data:
                    if mapping["target_table"] == "NA":
                        continue
                    knn_source_cluster = knn_cluster_info[mapping["source_table"]][
                        mapping["source_column"]
                    ]
                    knn_target_cluster = knn_cluster_info[mapping["target_table"]][
                        mapping["target_column"]
                    ]

                    if knn_source_cluster == knn_target_cluster:
                        knn_matched_cluster += 1
                    else:
                        knn_non_matched_cluster += 1

                    dbscan_source_cluster = dbscan_cluster_info[
                        mapping["source_table"]
                    ][mapping["source_column"]]
                    dbscan_target_cluster = dbscan_cluster_info[
                        mapping["target_table"]
                    ][mapping["target_column"]]

                    if (
                        dbscan_source_cluster == dbscan_target_cluster
                        and dbscan_target_cluster != -1
                    ):
                        dbscan_matched_cluster += 1
                    else:
                        dbscan_non_matched_cluster += 1

            result[dataset][model]["knn"] = {
                "matched": knn_matched_cluster,
                "non_matched": knn_non_matched_cluster,
            }
            result[dataset][model]["dbscan"] = {
                "matched": dbscan_matched_cluster,
                "non_matched": dbscan_non_matched_cluster,
            }

            print(dataset, model, result[dataset][model])
        except Exception as e:
            print(e)

    print(json.dumps(result, indent=2))
    return result


def print_average_match_ranking(dataset):
    from llm_ontology_alignment.data_models.experiment_models import (
        OntologyAlignmentGroundTruth,
        OntologyAlignmentData,
        SchemaRewrite,
    )

    rankings = defaultdict(lambda: defaultdict(list))
    for item in OntologyAlignmentGroundTruth.objects(dataset=dataset):
        print(item.dataset)
        for mapping in item.data:
            print(
                mapping["source_table"],
                mapping["source_column"],
                mapping["target_table"],
                mapping["target_column"],
            )
            source = OntologyAlignmentData.objects(
                dataset=dataset,
                table_name=mapping["source_table"],
                column_name=mapping["source_column"],
            ).first()
            similar_items = source.similar_target_items()
            for idx, item in enumerate(similar_items):
                assert item["matching_role"] == "target"
                if (
                    item["table_name"] == mapping["target_table"]
                    and item["column_name"] == mapping["target_column"]
                ):
                    rankings[dataset]["original"].append(idx)
                    break
            else:
                rankings[dataset]["original"].append(11)

            for rewrite_item in SchemaRewrite.objects(
                dataset=dataset,
                original_table=mapping["source_table"],
                original_column=mapping["source_column"],
            ):
                similar_items = rewrite_item.similar_target_items()
                for idx, item in enumerate(similar_items):
                    assert item["matching_role"] == "target"
                    assert item["dataset"] == dataset
                    assert item["llm_model"] == rewrite_item.llm_model
                    if (
                        item["original_table"] == mapping["target_table"]
                        and item["original_column"] == mapping["target_column"]
                    ):
                        rankings[dataset][rewrite_item.llm_model].append(idx)
                        break
                else:
                    rankings[dataset][rewrite_item.llm_model].append(11)

    for dataset in rankings:
        for model in rankings[dataset]:
            print(
                dataset,
                model,
                sum(rankings[dataset][model]) / len(rankings[dataset][model]),
            )
