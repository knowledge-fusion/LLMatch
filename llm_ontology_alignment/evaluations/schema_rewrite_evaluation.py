import json
from collections import defaultdict

from llm_ontology_alignment.alignment_strategies.column_cluster_with_llm_summary import get_kmeans_clusters, \
    get_dbscan_clusters
from llm_ontology_alignment.utils import cosine_distance, get_embeddings


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

def print_vector_distances(dataset):
    from llm_ontology_alignment.data_models.experiment_models import OntologyAlignmentGroundTruth, OntologyAlignmentData, SchemaRewrite
    original_query = OntologyAlignmentData.objects(dataset=dataset)
    rewrite_query = SchemaRewrite.objects(dataset=dataset)
    models = rewrite_query.distinct("llm_model")
    print(dataset)
    for item in OntologyAlignmentGroundTruth.objects(dataset=dataset):
        for mapping in item.data:
            if mapping["target_table"] == "NA":
                continue
            source = OntologyAlignmentData.objects(dataset=dataset, table_name=mapping["source_table"], column_name=mapping["source_column"]).first()
            target = OntologyAlignmentData.objects(dataset=dataset, table_name=mapping["target_table"], column_name=mapping["target_column"]).first()
            print("original", cosine_distance(source.default_embedding, target.default_embedding), source.column_name, target.column_name)
            for model in models:
                source = SchemaRewrite.objects(dataset=dataset, original_table=mapping["source_table"], original_column=mapping["source_column"], llm_model=model).first()
                target = SchemaRewrite.objects(dataset=dataset, original_table=mapping["target_table"], original_column=mapping["target_column"], llm_model=model).first()
                print(model, cosine_distance(source.column_embedding, target.column_embedding), source.rewritten_column, target.rewritten_column)
                print(model+"column+description", cosine_distance(
                    get_embeddings(source.rewritten_column+": " + source.rewritten_column_description),
                    get_embeddings(target.rewritten_column+": "+ target.rewritten_column_description)), source.rewritten_column, target.rewritten_column)
            break
def print_average_match_ranking(dataset):
    from llm_ontology_alignment.data_models.experiment_models import (
        OntologyAlignmentGroundTruth,
        OntologyAlignmentData,
        SchemaRewrite,
    )

    rankings = defaultdict(lambda: defaultdict(list))
    for item in OntologyAlignmentGroundTruth.objects(dataset=dataset):
        for mapping in item.data:
            if mapping["target_table"] == "NA":
                continue
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
                "null count",
                len([r for r in rankings[dataset][model] if r == 11]),
            )
