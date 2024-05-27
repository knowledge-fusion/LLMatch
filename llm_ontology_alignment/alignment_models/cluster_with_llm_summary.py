import json


def get_clusters(dataset, vector_field, n_clusters=3):
    from sklearn.cluster import KMeans
    import numpy as np

    # Extract vector values
    vectors = [d[vector_field] for d in dataset]

    # Convert vectors to numpy array
    vectors_array = np.array(vectors)

    # Perform KMeans clustering
    kmeans = KMeans(n_clusters=n_clusters)
    kmeans.fit(vectors_array)

    # Get cluster labels
    cluster_labels = kmeans.labels_

    # Add cluster labels to data
    for i, d in enumerate(dataset):
        d["cluster"] = cluster_labels[i]

    return dataset

def run_cluster_with_llm_summary(dataset):
    from llm_ontology_alignment.data_models.experiment_models import OntologyAlignmentData
    data = []
    for item in OntologyAlignmentData.objects(dataset=dataset):
        if "mapping_index" not in item.extra_data:
            item.extra_data["mapping_index"] = len(data)
            item.save()
        data.append({
            "table_name": item.table_name,
            "column_name": item.column_name,
            "llm_summary_embedding": item.llm_summary_embedding,
            "description": item['extra_data']['llm_description'],
            "matching_role": item.extra_data['matching_role'],
            "id": item.extra_data["mapping_index"],
        })
    n_clusters = 3
    clustered_data = get_clusters(data, "llm_summary_embedding", n_clusters=n_clusters)

    for cluster_id in range(n_clusters):
        source_candidates, target_candidates = [], []
        for similar_item in clustered_data:
            if similar_item["cluster"] != cluster_id:
                continue
            entry = {
                "table_name": similar_item['table_name'],
                "column_name": similar_item['column_name'],
                "description": similar_item['description'],
                "id": similar_item['id'],
            }
            if similar_item['matching_role'] == 'source':
                source_candidates.append(entry)
            else:
                target_candidates.append(entry)

        from llm_ontology_alignment.alignment_models.llm_mapping import get_llm_mapping
        llm= 'gpt-3.5-turbo'
        template= 'top2-no-na'
        run_specs = {
            "dataset": dataset,
            "sub_run_id": cluster_id,
            "llm": llm,
            "template": template,
            "strategy": "cluster_with_llm_summary"
        }
        from llm_ontology_alignment.data_models.experiment_models import OntologyAlignmentExperimentResult
        record = OntologyAlignmentExperimentResult.objects(run_id=json.dumps(run_specs)).first()
        if record:
            # continue
            record.delete()
        from datetime import datetime
        start = datetime.utcnow()
        response = get_llm_mapping(source_candidates, target_candidates,  llm=llm, template=template)
        end = datetime.utcnow()
        res = OntologyAlignmentExperimentResult.upsert_llm_result(run_specs=run_specs, result=response, start=start, end=end)

