import os

from qdrant_client import QdrantClient, models
from dotenv import load_dotenv

load_dotenv()


def get_embeddings(text):
    import requests

    embedding = None
    url = os.getenv("EMBEDDING_SERVICE") + "/get_embeddings"
    res = requests.post(url=url, json=[text], timeout=150)
    if res.status_code == 200:
        embedding = res.json()
    return embedding


def get_vector_db():
    client = QdrantClient(url=f"http://{os.getenv('QDRANT_HOST')}", timeout=30)
    return client


client = get_vector_db()


def get_or_create_vector_db(table_name="ontology_alignment_dataset"):
    collections = client.get_collections()
    table_names = [item.name for item in collections.collections]
    if table_name not in table_names:
        DIM = 768

        client.create_collection(
            collection_name=table_name,
            vectors_config=models.VectorParams(
                size=DIM, distance=models.Distance.COSINE
            ),
        )
        # from qdrant_client.http.models import PayloadSchemaType
        # client.create_payload_index(DB, "mongo_id", field_schema=PayloadSchemaType.TEXT)


def upload_vector_records(records, table_name="ontology_alignment_dataset"):
    points = []
    for record in records:
        points.append(
            models.Record(
                id=record.pop("id"),
                vector=record.pop("embedding"),
                payload=record,
            )
        )

    res = client.upload_points(collection_name=table_name, points=points)
    return res


def delete_vector_records(ids, table_name="ontology_alignment_dataset"):
    res = []
    ids = [item for item in ids if item]
    if ids:
        try:
            res = client.delete(collection_name=table_name, points_selector=ids)
        except Exception as e:
            e
    return res


def retrieve_vector_records(ids, table_name="ontology_alignment_dataset"):
    res = client.retrieve(
        collection_name=table_name, ids=ids, with_payload=True, with_vectors=False
    )
    return res


def delete_nonexistent_records(table_name="ontology_alignment_dataset"):
    from qdrant_client.http.models import Filter, IsEmptyCondition

    selector = Filter(must=[IsEmptyCondition(is_empty={"key": "version"})])
    res = client.delete(collection_name=table_name, points_selector=selector)
    return res


def update_vector_payload(ids, payload, table_name="ontology_alignment_dataset"):
    res = client.set_payload(
        collection_name=table_name, wait=False, payload=payload, points=ids
    )
    return res


def query_vector_db(
    text,
    query_vector=None,
    limit=5,
    score_threshold=0.5,
    query_filter=None,
    table_name="ontology_alignment_dataset",
):
    if not query_vector:
        query_vector = get_embeddings(text)
    hits = client.search(
        collection_name=table_name,
        query_vector=query_vector,
        score_threshold=score_threshold,
        query_filter=query_filter,  # Don't use any filters for now, search across all indexed points
        append_payload=True,  # Also return a stored payload for found points
        limit=limit,  # Return 5 closest points
        search_params={"exact": True},
    )

    return hits
