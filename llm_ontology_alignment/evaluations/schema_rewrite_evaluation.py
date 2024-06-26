import json
from collections import defaultdict

from llm_ontology_alignment.alignment_strategies.column_cluster_with_llm_summary import (
    get_kmeans_clusters,
    get_dbscan_clusters,
)


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


def print_ground_truth_cluster(dataset):
    from llm_ontology_alignment.data_models.experiment_models import (
        OntologyAlignmentGroundTruth,
    )

    from llm_ontology_alignment.data_models.experiment_models import (
        SchemaRewrite,
    )

    column_descriptions = defaultdict(lambda: defaultdict(dict))
    column_embeddings = defaultdict(lambda: defaultdict(dict))
    result = defaultdict(lambda: defaultdict(dict))

    for item in SchemaRewrite.objects(dataset=dataset):
        column_descriptions[item.llm_model][item.original_table][item.original_column] = item.column_description
        column_embeddings[item.llm_model][item.original_table][item.original_column] = item.column_embedding
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
        clustered_data = get_dbscan_clusters(clustered_data, "embedding", eps=0.78, min_samples=2)

        knn_cluster_info = defaultdict(dict)
        dbscan_cluster_info = defaultdict(dict)
        kmeans_cluster_data = defaultdict(list)
        dbscan_cluster_data = defaultdict(list)
        for item in clustered_data.values():
            knn_cluster_info[item["table"]][item["column"]] = item["kmeans_cluster"]
            dbscan_cluster_info[item["table"]][item["column"]] = item["dbscan_cluster"]
            kmeans_cluster_data[item["kmeans_cluster"]].append((item["table"], item["column"]))
            dbscan_cluster_data[item["dbscan_cluster"]].append((item["table"], item["column"]))
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
                    knn_source_cluster = knn_cluster_info[mapping["source_table"]][mapping["source_column"]]
                    knn_target_cluster = knn_cluster_info[mapping["target_table"]][mapping["target_column"]]

                    if knn_source_cluster == knn_target_cluster:
                        knn_matched_cluster += 1
                    else:
                        knn_non_matched_cluster += 1

                    dbscan_source_cluster = dbscan_cluster_info[mapping["source_table"]][mapping["source_column"]]
                    dbscan_target_cluster = dbscan_cluster_info[mapping["target_table"]][mapping["target_column"]]

                    if dbscan_source_cluster == dbscan_target_cluster and dbscan_target_cluster != -1:
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


def print_ground_truth(dataset):
    from llm_ontology_alignment.data_models.experiment_models import SchemaRewrite, OntologyAlignmentGroundTruth

    rewrite_query = SchemaRewrite.objects(dataset=dataset, llm_model="gpt-4o")
    data = []
    for item in OntologyAlignmentGroundTruth.objects(dataset=dataset):
        print(item.dataset)
        for mapping in item.data:
            if mapping["target_table"] == "NA":
                continue
            data.append(
                [
                    mapping["source_table"],
                    mapping["source_column"],
                    mapping["target_table"],
                    mapping["target_column"],
                    rewrite_query.filter(
                        original_table=mapping["source_table"], original_column=mapping["source_column"]
                    )
                    .first()
                    .column_description,
                    rewrite_query.filter(
                        original_table=mapping["target_table"], original_column=mapping["target_column"]
                    )
                    .first()
                    .column_description,
                ]
            )
        import csv

        with open(f"{dataset}_ground_truth.csv", mode="w", newline="") as file:
            writer = csv.writer(file)
            writer.writerows(data)


def generate_average_match_ranking(dataset):
    from llm_ontology_alignment.data_models.experiment_models import OntologyAlignmentGroundTruth, SchemaEmbedding

    # models = SchemaEmbedding.objects.distinct("llm_model")
    models = ["original", "mistral-7b", "gpt-4o"]
    embedding_strategies = SchemaEmbedding.objects.distinct("embedding_strategy")
    rankings = defaultdict(lambda: defaultdict(list))

    for ground_truth_record in list(OntologyAlignmentGroundTruth.objects(dataset=dataset)):
        for mapping in list(ground_truth_record.data):
            if mapping["target_table"] == "NA":
                continue
            source_table, source_column = mapping["source_table"], mapping["source_column"]
            target_table, target_column = mapping["target_table"], mapping["target_column"]

            for model in models:
                queryset = SchemaEmbedding.objects(
                    dataset=dataset,
                    llm_model__in=models,
                    matching_role="source",
                    table=source_table,
                    column=source_column,
                )
                for strategy in embedding_strategies:
                    key = f"{source_table}-{source_column}=>{target_table}-{target_column}[{model}-{strategy}]"
                    rank = ground_truth_record.extra_data.get("embedding_ranking", {}).get(key, {})
                    if not rank:
                        source = queryset.filter(
                            llm_model=model,
                            embedding_strategy=strategy,
                        ).first()
                        assert source
                        similar_items = source.similar_target_items()
                        assert similar_items
                        for idx, item in enumerate(similar_items[0:10]):
                            assert item["matching_role"] == "target"
                            assert item["dataset"] == dataset
                            assert item["llm_model"] == source.llm_model
                            if item["table"] == target_table and item["column"] == target_column:
                                rank = {
                                    "idx": idx,
                                    "table": item["table"],
                                    "column": item["column"],
                                    "embedding_text": item["embedding_text"],
                                }
                                break
                        else:
                            rank = {"idx": 11}
                        assert rank
                        if not ground_truth_record.extra_data.get("embedding_ranking"):
                            ground_truth_record.extra_data["embedding_ranking"] = {}
                        ground_truth_record.extra_data["embedding_ranking"][key] = rank
                        print(key, rank)
                    ground_truth_record.save()
                    rankings[model][strategy].append(rank)


import re


def split_key(key):
    # Define the regex pattern to match the different components
    pattern = re.compile(
        r"(?P<source_table>[^-]+)-(?P<source_column>[^=]+)=>(?P<target_table>[^-]+)-(?P<target_column>[^\[]+)\[(?P<model>[^-]+)-(?P<strategy>[^\]]+)\]"
    )
    # Search for the pattern in the key
    match = pattern.search(key)

    if match:
        return match.groupdict()
    else:
        raise ValueError("Key format is incorrect")


def print_average_match_ranking(dataset):
    from llm_ontology_alignment.data_models.experiment_models import OntologyAlignmentGroundTruth

    ground_truth_record = OntologyAlignmentGroundTruth.objects(dataset=dataset).first()
    rankings = defaultdict(lambda: defaultdict(list))
    reverse_rankings = defaultdict(lambda: defaultdict(lambda: defaultdict(list)))
    for key, value in ground_truth_record.extra_data.get("embedding_ranking").items():
        try:
            data = split_key(key)
            rankings[data["model"]][data["strategy"]].append(value)
            reverse_rankings[data["model"]][data["strategy"]][value["idx"]].append(key.split("[")[0])
        except Exception as e:
            print(e)
            print(key)

    for model in rankings:
        for strategy in rankings[model]:
            scores = [r["idx"] for r in rankings[model][strategy]]
            print(
                model,
                strategy,
                round(sum(scores) / len(scores), 3),
                "total count",
                len(rankings[model][strategy]),
                "null count",
                len([r for r in scores if r == 11]),
            )

        print(json.dumps(reverse_rankings, indent=2))
        for model in rankings:
            strategy_best_at = defaultdict(list)
            for idx in range(0, len(rankings[model].values())):
                best_ranking = 11
                best_strategy = "None"
                for strategy in rankings[model]:
                    rank = rankings[model][strategy][idx]
                    if rank["idx"] < best_ranking:
                        best_ranking = rank["idx"]
                        best_strategy = strategy
                mapping = ground_truth_record.data[idx]
                source_table, source_column = mapping["source_table"], mapping["source_column"]
                target_table, target_column = mapping["target_table"], mapping["target_column"]
                strategy_best_at[best_strategy].append(
                    f"{source_table}.{source_column}=>{target_table}.{target_column}"
                )
        print(model, "strategy_best_at")
        print(json.dumps(strategy_best_at, indent=2))
