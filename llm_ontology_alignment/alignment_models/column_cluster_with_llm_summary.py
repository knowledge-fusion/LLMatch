import json
from collections import defaultdict


from llm_ontology_alignment.utils import cosine_distance


def get_clusters(dataset, vector_field, n_clusters=3):
    from sklearn.cluster import KMeans
    import numpy as np

    # Extract vector values
    vectors = [d.pop(vector_field) for d in dataset.values()]

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
        d["cluster"] = cluster_labels[i]

    return dataset


def run_cluster_with_llm_summary(run_specs):
    from llm_ontology_alignment.data_models.experiment_models import (
        OntologyAlignmentData,
    )
    from llm_ontology_alignment.alignment_models.llm_mapping import get_llm_mapping

    from llm_ontology_alignment.data_models.experiment_models import (
        OntologyAlignmentExperimentResult,
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

    clustered_data = get_clusters(
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


def print_ground_truth_cluster(run_specs):
    from llm_ontology_alignment.data_models.experiment_models import (
        OntologyAlignmentGroundTruth,
    )

    from llm_ontology_alignment.data_models.experiment_models import (
        OntologyAlignmentData,
    )

    descriptions = defaultdict(dict)
    default_embeddings = defaultdict(dict)
    llm_embeddings = defaultdict(dict)
    data = {}
    for item in OntologyAlignmentData.objects(dataset=run_specs["dataset"]):
        data[str(len(data))] = {
            "table": item.table_name,
            "column": item.column_name,
            "default_embedding": item.default_embedding,
            "llm_summary_embedding": item.llm_summary_embedding,
            "description": item.llm_description,
        }
        descriptions[item.table_name][item.column_name] = item.llm_description
        default_embeddings[item.table_name][item.column_name] = item.default_embedding
        llm_embeddings[item.table_name][item.column_name] = item.llm_summary_embedding

    clustered_data = get_clusters(
        data, "llm_summary_embedding", n_clusters=run_specs["n_clusters"]
    )
    cluster_info = defaultdict(dict)
    for item in clustered_data.values():
        cluster_info[item["table"]][item["column"]] = item["cluster"]

    matched_cluster = 0
    non_matched_cluster = 0
    for item in OntologyAlignmentGroundTruth.objects(dataset="MIMIC_OMOP"):
        print(item.dataset)
        for mapping in item.data:
            if mapping["target_table"] == "NA":
                continue
            source_cluster = cluster_info[mapping["source_table"]][
                mapping["source_column"]
            ]
            target_cluster = cluster_info[mapping["target_table"]][
                mapping["target_column"]
            ]

            if source_cluster == target_cluster:
                matched_cluster += 1
                print(
                    "in one cluster",
                    "llm distance: ",
                    cosine_distance(
                        llm_embeddings[mapping["source_table"]][
                            mapping["source_column"]
                        ],
                        llm_embeddings[mapping["target_table"]][
                            mapping["target_column"]
                        ],
                    ),
                )
            else:
                non_matched_cluster += 1

                print(
                    "\n\nnot in one cluster, default distance: ",
                    cosine_distance(
                        default_embeddings[mapping["source_table"]][
                            mapping["source_column"]
                        ],
                        default_embeddings[mapping["target_table"]][
                            mapping["target_column"]
                        ],
                    ),
                    "llm distance: ",
                    cosine_distance(
                        llm_embeddings[mapping["source_table"]][
                            mapping["source_column"]
                        ],
                        llm_embeddings[mapping["target_table"]][
                            mapping["target_column"]
                        ],
                    ),
                )
                print(
                    "source: ",
                    mapping["source_table"],
                    mapping["source_column"],
                    source_cluster,
                    descriptions[mapping["source_table"]][mapping["source_column"]],
                )
                print(
                    "target: ",
                    mapping["target_table"],
                    mapping["target_column"],
                    target_cluster,
                    descriptions[mapping["target_table"]][mapping["target_column"]],
                )
    print("matched_cluster", matched_cluster)
    print("non_matched_cluster", non_matched_cluster)
