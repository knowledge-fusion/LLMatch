import json
from collections import defaultdict


from llm_ontology_alignment.utils import cosine_distance, get_cache


def get_column_data(run_specs, item):
    if run_specs["use_translation"]:
        table_name, table_description, column_name, column_description = (
            item.table_name_rewritten,
            item.table_description_rewritten,
            item.column_name_rewritten,
            item.column_description_rewritten,
        )
    else:
        table_name, table_description, column_name, column_description = (
            item.table_name,
            item.extra_data["table_description"],
            item.column_name,
            item.extra_data["column_description"],
        )
    return table_name, table_description, column_name, column_description


def run_cluster_with_llm_summary(run_specs):
    from llm_ontology_alignment.data_models.experiment_models import (
        OntologyAlignmentData,
    )
    from llm_ontology_alignment.alignment_strategies.llm_mapping import get_llm_mapping
    from llm_ontology_alignment.data_models.experiment_models import (
        OntologyAlignmentExperimentResult,
    )

    assert run_specs["strategy"] == "cluster_at_table_level_with_llm_summary_and_llm_column_name"
    cache = get_cache()
    data = {}
    table_descriptions = {}
    source_schema = defaultdict(lambda: defaultdict(list))
    target_schema = defaultdict(lambda: defaultdict(list))
    for item in OntologyAlignmentData.objects(dataset=run_specs["dataset"]):
        try:
            schema_to_use = source_schema if item.extra_data["matching_role"] == "source" else target_schema
            table_name, table_description, column_name, column_description = get_column_data(run_specs, item)
            schema_to_use[table_name]["columns"].append(column_name)
            schema_to_use[table_name]["description"] = table_description
            schema_to_use[table_name]["table_name"] = table_description

            table_descriptions[table_name] = table_description
            data[str(item.extra_data["matching_index"])] = {
                "table": table_name,
                "column": column_name,
                # "llm_summary_embedding": item.llm_summary_embedding,
                "description": column_description,
                "id": item.extra_data["matching_index"],
                "matching_role": item.extra_data["matching_role"],
            }
        except Exception:
            raise

    source_schema, target_schema = (
        json.loads(json.dumps(source_schema)),
        json.loads(json.dumps(target_schema)),
    )
    table_clustering_cache_key = json.dumps(run_specs) + "table_clustering"
    clustered_data = cache.get(table_clustering_cache_key)
    if not clustered_data:
        clustered_data = get_table_mapping(source_schema, target_schema, n_clusters=run_specs["n_clusters"])
        cache.set(table_clustering_cache_key, clustered_data, timeout=60 * 60 * 24)

    clusters = defaultdict(lambda: defaultdict(set))
    for source_table, target_tables in clustered_data.items():
        cluster_found = False
        for index, cluster_info in clusters.items():
            if set([source_table] + target_tables) & cluster_info["members"]:
                clusters[index]["members"].update([source_table] + target_tables)
                clusters[index]["source"].add(source_table)
                clusters[index]["target"].update(target_tables)
                cluster_found = True
                break
        if not cluster_found:
            index = len(clusters)
            clusters[index]["members"] = set([source_table] + target_tables)
            clusters[index]["source"] = set([source_table])
            clusters[index]["target"] = set(target_tables)

    for cluster_id, item in clusters.items():
        tables = item["members"]
        if len(tables) < 2:
            continue
        source_candidates, target_candidates = defaultdict(list), defaultdict(list)
        for similar_item in data.values():
            if similar_item["table"] not in tables and similar_item["matching_role"] == "source":
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
    source_schema = defaultdict(lambda: defaultdict(list))
    target_schema = defaultdict(lambda: defaultdict(list))
    for item in OntologyAlignmentData.objects(dataset=run_specs["dataset"]):
        column_name = get_column_data(run_specs, item)
        data[str(len(data))] = {
            "table": item.table_name,
            "column": column_name,
            "default_embedding": item.default_embedding,
            "llm_summary_embedding": item.llm_summary_embedding,
            "description": item.llm_description,
        }
        if data.extra_data["matching_role"] == "source":
            source_schema[item.table_name]["description"] = item.extra_data["table_description"]
            source_schema[item.table_name]["columns"].append(column_name)
        else:
            target_schema[item.table_name]["description"] = item.extra_data["table_description"]
            target_schema[item.table_name]["columns"].append(column_name)

        descriptions[item.table_name][column_name] = item.llm_description
        default_embeddings[item.table_name][column_name] = item.default_embedding
        llm_embeddings[item.table_name][column_name] = item.llm_summary_embedding

    clustered_data = get_table_mapping(dict(source_schema), dict(target_schema), n_clusters=run_specs["n_clusters"])
    cluster_info = defaultdict(dict)
    for item in clustered_data.values():
        cluster_info[item["table"]][item["column"]] = item["cluster"]

    matched_cluster = 0
    non_matched_cluster = 0
    for item in OntologyAlignmentGroundTruth.objects(dataset=run_specs["dataset"]):
        print(item.dataset)
        for mapping in item.data:
            if mapping["target_table"] == "NA":
                continue
            source_cluster = cluster_info[mapping["source_table"]][mapping["source_column"]]
            target_cluster = cluster_info[mapping["target_table"]][mapping["target_column"]]

            if source_cluster == target_cluster:
                matched_cluster += 1
                print(
                    "in one cluster",
                    "llm distance: ",
                    cosine_distance(
                        llm_embeddings[mapping["source_table"]][mapping["source_column"]],
                        llm_embeddings[mapping["target_table"]][mapping["target_column"]],
                    ),
                )
            else:
                non_matched_cluster += 1

                print(
                    "\n\nnot in one cluster, default distance: ",
                    cosine_distance(
                        default_embeddings[mapping["source_table"]][mapping["source_column"]],
                        default_embeddings[mapping["target_table"]][mapping["target_column"]],
                    ),
                    "llm distance: ",
                    cosine_distance(
                        llm_embeddings[mapping["source_table"]][mapping["source_column"]],
                        llm_embeddings[mapping["target_table"]][mapping["target_column"]],
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
