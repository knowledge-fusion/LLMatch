import json
import os
from datetime import datetime
from dotenv import load_dotenv

from mongoengine import (
    DateTimeField,
    DictField,
    Document,
    IntField,
    MultipleObjectsReturned,
    Q,
    StringField,
    FloatField,
    connect,
    ListField,
)
from pymongo.errors import BulkWriteError

load_dotenv()
connect(host=os.environ["MONGODB_HOST"])


class BaseDocument(Document):
    meta = {"abstract": True, "indexes": [{"fields": ["updated_at"]}, "version"]}

    created_at = DateTimeField(required=True)
    updated_at = DateTimeField(required=True)
    version = IntField()

    def validate(self, clean=True):
        if not self.created_at:
            self.created_at = datetime.utcnow()
        self.updated_at = datetime.utcnow()
        return super().validate(clean)

    @classmethod
    def upsert(cls, record=None):
        now = datetime.utcnow()
        record["updated_at"] = now

        flt = cls.get_filter(record)
        update = {}
        for key in record.keys():
            update["set__%s" % key] = record[key]
        try:
            result = cls.objects(**flt).upsert_one(**update)
            if result.created_at is None:
                result.created_at = now
                result.save()
        except MultipleObjectsReturned:
            cls.objects(**flt).delete()
            result = cls.objects(**flt).upsert_one(**update)
        return result

    @classmethod
    def upsert_many(cls, records):
        from pymongo import UpdateOne

        now = datetime.utcnow()
        bulk_operations = []
        filters = []
        for record in records:
            flt = cls.get_filter(record)

            filters.append(flt)
            if not record:
                bulk_operations.append(
                    UpdateOne(
                        flt,
                        {"$setOnInsert": {"created_at": now, "updated_at": now}},
                        upsert=True,
                    )
                )
            else:
                bulk_operations.append(
                    UpdateOne(
                        flt,
                        {
                            "$set": record,
                            "$setOnInsert": {"created_at": now, "updated_at": now},
                        },
                        upsert=True,
                    )
                )
        res = {"errors": []}

        if not bulk_operations:
            return res
        try:
            result = cls._get_collection().bulk_write(bulk_operations, ordered=False)
            res.update(result.bulk_api_result)
            if result.modified_count > 0:
                queries = None
                for flt in filters:
                    if queries:
                        queries |= Q(**flt)
                    else:
                        queries = Q(**flt)

        except BulkWriteError as e:
            # from sentry_sdk import configure_scope
            #
            # with configure_scope() as scope:
            #     scope.set_extra("details", e.details)
            #     scope.set_extra(
            #         "error", e.details.get("writeErrors")[0].get("op", {}).get("q")
            #     )
            #     logging.error(e, exc_info=True)
            res["errors"].append(e.details)
        return res


class OntologyAlignmentData(BaseDocument):
    meta = {
        "indexes": [
            "dataset"
            # {
            #     "fields": [
            #         {
            #             "numDimensions": 768,
            #             "path": "default_embedding",
            #             "similarity": "cosine",
            #             "type": "vector",
            #         },
            #         {"type": "filter", "path": "dataset"},
            #     ]
            # }
        ]
    }

    dataset = StringField(required=True)
    table_name = StringField(required=True)
    column_name = StringField(required=True, unique_with=["table_name", "dataset"])
    matching_role = StringField(required=True)
    extra_data = DictField()
    default_embedding = ListField(FloatField())
    version = IntField()
    """
    collection.create_search_index(
    {"definition":
        {"mappings": {"dynamic": True, "fields": {
            EMBEDDING_FIELD_NAME : {
                "dimensions": 768,
                "similarity": "cosine",
                "type": "vector"
                }}}},
     "name": default_embedding
    }
)
    """

    @classmethod
    def get_filter(cls, record):
        flt = {
            cls.dataset.name: record.pop(cls.dataset.name),
            cls.table_name.name: record.pop(cls.table_name.name),
            cls.column_name.name: record.pop(cls.column_name.name),
        }
        return flt

    def similar_target_items(self, limit=11):
        search_spec = {
            "index": "column_name_vector_index",
            "path": "default_embedding",
            "queryVector": self.default_embedding,
            "numCandidates": limit * 10,
            "limit": limit,
        }
        search_spec["filter"] = {"dataset": self.dataset, "matching_role": "target"}
        res = self.__class__.objects.aggregate(
            [
                {"$vectorSearch": search_spec},
                {"$addFields": {"score": {"$meta": "vectorSearchScore"}}},
            ]
        )
        result = []
        for item in res:
            if str(item["_id"]) == str(self.id):
                continue
            result.append(
                {
                    "dataset": item["dataset"],
                    "_id": item["_id"],
                    "score": item["score"],
                    "table_name": item["table_name"],
                    "column_name": item["column_name"],
                    "table_description": item["extra_data"]["table_description"],
                    "column_description": item["extra_data"]["column_description"],
                    "matching_role": item["matching_role"],
                    "extra_data": item["extra_data"],
                    "version": item["version"],
                }
            )
        return result

    def __str__(self):
        return f"{self.dataset} {self.table_name} {self.column_name}"


class SchemaRewrite(BaseDocument):
    original_table = StringField(required=True)
    original_column = StringField(required=True)
    rewritten_table = StringField(required=True)
    rewritten_column = StringField(required=True)
    rewritten_table_description = StringField(required=True)
    rewritten_column_description = StringField(required=True)
    dataset = StringField(required=True)
    matching_role = StringField(required=True)
    column_embedding = ListField(FloatField(), required=True)
    table_embedding = ListField(FloatField(), required=True)
    version = IntField()
    llm_model = StringField(
        required=True, unique_with=["dataset", "original_table", "original_column"]
    )

    @classmethod
    def get_filter(cls, record):
        return {
            cls.dataset.name: record.pop(cls.dataset.name),
            cls.original_table.name: record.pop(cls.original_table.name),
            cls.original_column.name: record.pop(cls.original_column.name),
            cls.llm_model.name: record.pop(cls.llm_model.name),
        }

    def similar_target_items(self, limit=11):
        assert self.matching_role == "source"
        search_spec = {
            "index": "column_name_vector_index",
            "path": "column_embedding",
            "queryVector": self.column_embedding,
            "numCandidates": limit * 10,
            "limit": limit,
        }
        search_spec["filter"] = {
            "dataset": self.dataset,
            "llm_model": self.llm_model,
            "matching_role": "target",
        }
        res = self.__class__.objects.aggregate(
            [
                {"$vectorSearch": search_spec},
                {"$addFields": {"score": {"$meta": "vectorSearchScore"}}},
            ]
        )
        result = []
        for item in res:
            if str(item["_id"]) == str(self.id):
                continue
            result.append(
                {
                    "dataset": item["dataset"],
                    "llm_model": item["llm_model"],
                    "_id": item["_id"],
                    "score": item["score"],
                    "table_name": item["rewritten_table"],
                    "column_name": item["rewritten_column"],
                    "table_description": item["rewritten_table_description"],
                    "column_description": item["rewritten_column_description"],
                    "matching_role": item["matching_role"],
                    "original_table": item["original_table"],
                    "original_column": item["original_column"],
                    "version": item["version"],
                }
            )
        return result

    @classmethod
    def vector_search(cls, query_text, limit=10, filter=None):
        from llm_ontology_alignment.utils import get_embeddings

        search_spec = {
            "index": "column_name_vector_index",
            "path": "column_embedding",
            "queryVector": get_embeddings(query_text),
            "numCandidates": limit * 10,
            "limit": limit,
        }
        if filter:
            search_spec["filter"] = filter.to_query(cls)
        res = cls.objects.aggregate(
            [
                {"$vectorSearch": search_spec},
                {"$addFields": {"score": {"$meta": "vectorSearchScore"}}},
            ]
        )
        return res


class CostAnalysis(BaseDocument):
    run_specs = DictField()
    model = StringField()
    text_result = StringField()
    json_result = DictField()
    start = DateTimeField()
    end = DateTimeField()
    duration = FloatField()
    prompt_tokens = IntField()
    completion_tokens = IntField()
    total_tokens = IntField()
    extra_data = DictField()

    @classmethod
    def get_filter(cls, record):
        flt = {
            cls.run_id_prefix.name: record.pop(cls.run_id_prefix.name),
            cls.sub_run_id.name: record.pop(cls.sub_run_id.name),
        }
        return flt

    @classmethod
    def upsert_llm_result(cls, run_specs, sub_run_id, result, start, end):
        run_specs = {key: run_specs[key] for key in sorted(run_specs.keys())}
        text = result.choices[0]["model_extra"]["message"]["content"]
        record = {
            "run_id_prefix": json.dumps(run_specs),
            "sub_run_id": sub_run_id,
            "start": start,
            "end": end,
            "duration": (end - start).total_seconds(),
            "text_result": text,
            "dataset": run_specs["dataset"],
            "prompt_tokens": result.model_extra["usage"]["model_extra"][
                "prompt_tokens"
            ],
            "completion_tokens": result.model_extra["usage"]["model_extra"][
                "completion_tokens"
            ],
            "total_tokens": result.model_extra["usage"]["model_extra"]["total_tokens"],
        }
        try:
            json_result = json.loads(text)
            record["json_result"] = json_result
        except Exception:
            pass

        return cls.upsert(record)


class OntologyAlignmentGroundTruth(BaseDocument):
    dataset = StringField(required=True)
    data = ListField(DictField())

    @classmethod
    def get_filter(self, record):
        return {self.dataset.name: record.pop(self.dataset.name)}


class OntologyAlignmentExperimentResult(BaseDocument):
    dataset = StringField(required=True)
    run_id_prefix = StringField()
    sub_run_id = StringField(required=True, unique_with="run_id_prefix")
    text_result = StringField()
    json_result = DictField()
    start = DateTimeField()
    end = DateTimeField()
    duration = FloatField()
    prompt_tokens = IntField()
    completion_tokens = IntField()
    total_tokens = IntField()
    extra_data = DictField()

    @classmethod
    def get_filter(cls, record):
        flt = {
            cls.run_id_prefix.name: record.pop(cls.run_id_prefix.name),
            cls.sub_run_id.name: record.pop(cls.sub_run_id.name),
        }
        return flt

    @classmethod
    def upsert_llm_result(cls, run_specs, sub_run_id, result, start, end):
        run_specs = {key: run_specs[key] for key in sorted(run_specs.keys())}
        text = result.choices[0]["model_extra"]["message"]["content"]
        record = {
            "run_id_prefix": json.dumps(run_specs),
            "sub_run_id": sub_run_id,
            "start": start,
            "end": end,
            "duration": (end - start).total_seconds(),
            "text_result": text,
            "dataset": run_specs["dataset"],
            "prompt_tokens": result.model_extra["usage"]["model_extra"][
                "prompt_tokens"
            ],
            "completion_tokens": result.model_extra["usage"]["model_extra"][
                "completion_tokens"
            ],
            "total_tokens": result.model_extra["usage"]["model_extra"]["total_tokens"],
        }
        try:
            json_result = json.loads(text)
            record["json_result"] = json_result
        except Exception:
            pass

        return cls.upsert(record)


def create_vector_index():
    from pymongo.operations import SearchIndexModel

    # Initialize MongoDB client

    # Get the database

    # Add a search index (if it doesn't already exist):
    collection = OntologyAlignmentData._get_collection()

    # Check if the search index already exists
    index_name = "default_embedding"
    if index_name not in collection.index_information():
        print("Creating search index...")

        # Create a text index on the 'embedding' field for vector search
        res = collection.create_search_index(
            SearchIndexModel(
                {
                    "mappings": {
                        "dynamic": True,
                        "fields": {
                            "default_embedding": {
                                "dimensions": 768,
                                "similarity": "cosine",
                                "type": "vector",
                            }
                        },
                    }
                },
                name=index_name,
            )
        )
        res
        print("Done.")
    else:
        print("Vector search index already exists")
