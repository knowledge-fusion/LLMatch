import os

from qdrant_client import QdrantClient
from qdrant_client.http.models import Record
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
    #
    # DIM = 768
    # from qdrant_client.models import Distance, VectorParams
    #
    # client.recreate_collection(
    #     collection_name=DB,
    #     vectors_config=VectorParams(size=DIM, distance=Distance.COSINE),
    # )
    #
    # from qdrant_client.http.models import PayloadSchemaType
    # client.create_payload_index(DB, "mongo_id", field_schema=PayloadSchemaType.TEXT)

    return client


client = get_vector_db()


def upload_vector_records(records, table_name):
    records = [Record(**item) for item in records]

    res = client.upload_points(collection_name=table_name, points=records)
    return res


def delete_vector_records(ids, table_name):
    res = []
    ids = [item for item in ids if item]
    if ids:
        try:
            res = client.delete(collection_name=table_name, points_selector=ids)
        except Exception as e:
            e
    return res


def retrieve_vector_records(ids, table_name):
    res = client.retrieve(
        collection_name=table_name, ids=ids, with_payload=True, with_vectors=False
    )
    return res


def delete_nonexistent_records(table_name):
    from qdrant_client.http.models import Filter, IsEmptyCondition

    selector = Filter(must=[IsEmptyCondition(is_empty={"key": "version"})])
    res = client.delete(collection_name=table_name, points_selector=selector)
    return res


def update_vector_payload(ids, payload, table_name):
    res = client.set_payload(
        collection_name=table_name, wait=False, payload=payload, points=ids
    )
    return res
