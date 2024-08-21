import json
import os
from collections import defaultdict
from datetime import datetime
from dotenv import load_dotenv
import logging

from mongoengine import (
    DateTimeField,
    DictField,
    Document,
    IntField,
    StringField,
    FloatField,
    connect,
    ListField,
    BooleanField,
)
from pymongo.errors import BulkWriteError

from llm_ontology_alignment.alignment_strategies.schema_understanding import SCHEMA_UNDERSTANDING_STRATEGIES

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
        flt = cls.get_filter(record.copy())
        now = datetime.utcnow()

        result = cls._get_collection().find_one(flt)

        if not result:
            record["created_at"] = now
            record["updated_at"] = now
            cls(**record).validate()
            result = cls._get_collection().update_one(
                flt,
                {
                    "$set": cls(**record).to_mongo(),
                },
                upsert=True,
            )
            record["id"] = result.upserted_id
            result = cls(**record)
        else:
            result["id"] = result.pop("_id")
            result = cls(**result)
            changed = False
            for key, val in record.items():
                if getattr(result, key) != val:
                    setattr(result, key, val)
                    changed = True
            if changed:
                result = result.save()
        return result

    @classmethod
    def upsert_many(cls, records):
        from pymongo import UpdateOne

        now = datetime.utcnow()
        bulk_operations = []
        filters = dict()
        for record in records:
            cls(**record).validate()
            flt = cls.get_filter(record.copy())
            filters[f"{flt}"] = {"flt": flt, "record": cls(**record).to_mongo()}

        for operation in filters.values():
            bulk_operations.append(
                UpdateOne(
                    operation["flt"],
                    {
                        "$set": operation["record"],
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
                bulk_updated_at_operations = []
                upserted_idx = [item["index"] for item in result.bulk_api_result["upserted"]]
                for idx, operation in enumerate(filters.values()):
                    if idx in upserted_idx:
                        continue
                    bulk_updated_at_operations.append(
                        UpdateOne(
                            operation["flt"],
                            {
                                "$set": {"updated_at": now},
                            },
                            upsert=False,
                        )
                    )

                result2 = cls._get_collection().bulk_write(bulk_updated_at_operations, ordered=False)

                if result2.modified_count == 0:
                    logging.error(
                        "modified_count",
                        extra={
                            "upsert_result": result.bulk_api_result,
                            "update_timestamp": result2.bulk_api_result,
                            "bulk_updated_at_operations": len(bulk_updated_at_operations),
                            "bulk_operations": len(bulk_operations),
                        },
                    )
        except BulkWriteError as e:
            from sentry_sdk import configure_scope

            with configure_scope() as scope:
                scope.set_extra("details", e.details)
                scope.set_extra("error", e.details.get("writeErrors")[0].get("op", {}).get("q"))
                logging.error(e, exc_info=True)
            res["errors"].append(e.details)
        return res


class OntologyAlignmentOriginalSchema(BaseDocument):
    database = StringField(required=True)
    table = StringField(required=True)
    column = StringField(required=True, unique_with=["table", "database"])
    is_primary_key = BooleanField()
    is_foreign_key = BooleanField()
    linked_table = StringField()
    linked_column = StringField()
    extra_data = DictField()
    version = IntField()

    @classmethod
    def get_filter(cls, record):
        flt = {
            cls.database.name: record.pop(cls.database.name),
            cls.table.name: record.pop(cls.table.name),
            cls.column.name: record.pop(cls.column.name),
        }
        return flt

    def __str__(self):
        return f"{self.database} {self.table} {self.column}"

    @classmethod
    def get_linked_columns(cls, database):
        primary_keys = cls.objects(database=database, is_primary_key=True)
        results = defaultdict(list)
        for primary_key in primary_keys:
            key = f"{primary_key.table}.{primary_key.column}"
            for foreign_key in cls.objects(
                database=database, linked_table=primary_key.table, linked_column=primary_key.column
            ):
                results[key].append(f"{foreign_key.table}.{foreign_key.column}")
        return results


"""
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
    is_primary_key = BooleanField()
    is_foreign_key = BooleanField()
    linked_table = StringField()
    extra_data = DictField()
    version = IntField()

    @classmethod
    def get_filter(cls, record):
        flt = {
            cls.dataset.name: record.pop(cls.dataset.name),
            cls.table_name.name: record.pop(cls.table_name.name),
            cls.column_name.name: record.pop(cls.column_name.name),
        }
        return flt

    def __str__(self):
        return f"{self.dataset} {self.table_name} {self.column_name}"
"""


class OntologySchemaRewrite(BaseDocument):
    meta = {"indexes": ["version"]}
    original_table = StringField(required=True)
    original_column = StringField(required=True)
    llm_model = StringField(required=True, unique_with=["database", "original_table", "original_column"])
    table = StringField(required=True)
    column = StringField(required=True, unique_with=["table", "column", "database", "llm_model"])
    table_description = StringField(required=True)
    column_description = StringField(required=True)
    column_type = StringField()
    database = StringField(required=True)
    is_primary_key = BooleanField()
    is_foreign_key = BooleanField()
    linked_table = StringField()
    linked_column = StringField()
    version = IntField()

    def reverse_normalized_columns(self, include_description=True):
        res = dict()
        if not self.is_primary_key:
            return res

        for foreign_key_table in self.__class__.objects(
            database=self.database, linked_table=self.table, llm_model=self.llm_model, table__ne=self.table
        ).distinct("table"):
            foreign_keys = self.__class__.objects(
                database=self.database,
                table=foreign_key_table,
                llm_model=self.llm_model,
            )

            if foreign_keys.filter(is_primary_key=True).count() > 0:
                continue

            res[foreign_key_table] = {"table": foreign_key_table, "columns": []}

            for item in foreign_keys:
                if item.linked_table != self.table:
                    continue
                record = {
                    "column": item.column,
                }
                if include_description:
                    record["description"] = item.column_description
                if item.is_primary_key:
                    record["is_primary_key"] = True
                if item.is_foreign_key:
                    record["is_foreign_key"] = True
                    record["linked_entry"] = f"{item.linked_table}.{item.linked_column}"
                res[item.table]["table_description"] = item.table_description
                res[item.table]["columns"].append(record)
        res[self.table] = {"table": self.table, "columns": []}
        for item in self.__class__.objects(database=self.database, table=self.table, llm_model=self.llm_model):
            record = {
                "column": item.column,
            }
            if include_description:
                record["description"] = item.column_description
            res[item.table]["table_description"] = item.table_description
            res[item.table]["columns"].append(record)
        return dict(res)

    @classmethod
    def get_database_description(
        cls, database, llm_model="got-4o", include_foreign_keys=True, include_description=True
    ):
        tables = cls.objects(database=database, llm_model=llm_model).distinct("table")
        result = dict()
        for table in tables:
            result[table] = cls.get_table_columns_description(
                database, table, llm_model, include_foreign_keys, include_description
            )
        return result

    @classmethod
    def get_table_columns_description(cls, database, table, llm_model, include_foreign_keys, include_description):
        table_description = None
        column_descriptions = {}
        for item in cls.objects(table=table, database=database, llm_model=llm_model):
            if not table_description:
                table_description = item.table_description
            assert item.column not in column_descriptions
            if item.is_foreign_key and not include_foreign_keys:
                continue
            column_descriptions[item.column] = {
                "name": item.column,
            }
            if include_description:
                column_descriptions[item.column]["description"] = item.column_description

            if item.is_primary_key:
                column_descriptions[item.column]["is_primary_key"] = True
                column_descriptions[item.column]["foreign_keys"] = []
                for foreign_key in cls.objects(
                    database=database, linked_table=table, linked_column=item.column, llm_model=llm_model
                ):
                    column_descriptions[item.column]["foreign_keys"].append(f"{foreign_key.table}.{foreign_key.column}")
            if item.is_foreign_key:
                column_descriptions[item.column]["is_foreign_key"] = True
                column_descriptions[item.column]["linked_entry"] = f"{item.linked_table}.{item.linked_column}"
        res = {
            "table": table,
            "columns": column_descriptions,
        }
        if include_description:
            res["table_description"] = table_description

        return res

    @classmethod
    def get_primary_key_tables(cls, database, llm_model):
        result = dict()
        for item in cls.objects(database=database, is_primary_key=True, llm_model=llm_model):
            result[f"{item.table}"] = {
                "table": item.table,
                "columns": [{"column": item.column, "description": item.column_description}],
                "table_description": item.table_description,
            }
        return result

    @classmethod
    def get_reverse_normalized_columns(cls, database, llm_model, with_column_description=True):
        results = dict()
        primary_keys = cls.objects(database=database, is_primary_key=True, llm_model=llm_model)
        for primary_key in primary_keys:
            linked_columns = primary_key.reverse_normalized_columns(include_description=with_column_description)
            results[f"{primary_key.table}"] = linked_columns
        for table in cls.objects(database=database, llm_model=llm_model).distinct("table"):
            if table in results:
                continue
            results[table] = cls.get_table_columns_description(database, table, llm_model, include_foreign_keys=False)
        return results

    @classmethod
    def get_linked_columns(cls, database, llm_model):
        results = dict()
        primary_keys = cls.objects(database=database, is_primary_key=True, llm_model=llm_model)
        for primary_key in primary_keys:
            linked_columns = cls.objects(
                database=database, linked_table=primary_key.table, linked_column=primary_key.column, llm_model=llm_model
            )
            results[f"{primary_key.table}.{primary_key.column}"] = [
                f"{item.table}.{item.column}" for item in linked_columns
            ]
        return results

    @classmethod
    def get_filter(cls, record):
        return {
            cls.database.name: record.pop(cls.database.name),
            cls.original_table.name: record.pop(cls.original_table.name),
            cls.original_column.name: record.pop(cls.original_column.name),
            cls.llm_model.name: record.pop(cls.llm_model.name),
        }

    def __unicode__(self):
        return f"{self.database} {self.original_table} {self.original_column} => ({self.llm_model}) {self.table} {self.column}"

    def get_similar_items(self, embedding_strategy, target_db):
        embedding_record = OntologySchemaEmbedding.objects(
            database=self.database,
            table=self.original_table,
            column=self.original_column,
            llm_model=self.llm_model,
            embedding_strategy=embedding_strategy,
        ).first()
        assert embedding_record
        return embedding_record.get_similar_items(target_db)


"""
class SchemaRewrite(BaseDocument):
    meta = {"indexes": ["version"]}
    original_table = StringField(required=True)
    original_column = StringField(required=True)
    table = StringField(required=True)
    column = StringField(required=True)
    table_description = StringField(required=True)
    column_description = StringField(required=True)
    dataset = StringField(required=True)
    matching_role = StringField(required=True)
    version = IntField()
    llm_model = StringField(required=True, unique_with=["dataset", "original_table", "original_column"])

    @classmethod
    def get_filter(cls, record):
        return {
            cls.dataset.name: record.pop(cls.dataset.name),
            cls.original_table.name: record.pop(cls.original_table.name),
            cls.original_column.name: record.pop(cls.original_column.name),
            cls.llm_model.name: record.pop(cls.llm_model.name),
        }

    def __unicode__(self):
        return f"{self.dataset} {self.original_table} {self.original_column} => ({self.llm_model}) {self.table} {self.column}"
"""


class OntologySchemaEmbedding(BaseDocument):
    database = StringField(required=True)
    table = StringField(required=True)
    column = StringField(required=True)
    llm_model = StringField(required=True)
    embedding_strategy = StringField(unique_with=["database", "table", "column", "llm_model"])
    embedding = ListField(FloatField(), required=True)
    embedding_text = StringField()
    similar_items = DictField()
    version = IntField()

    @classmethod
    def get_filter(cls, record):
        return {
            cls.database.name: record.pop(cls.database.name),
            cls.table.name: record.pop(cls.table.name),
            cls.column.name: record.pop(cls.column.name),
            cls.llm_model.name: record.pop(cls.llm_model.name),
            cls.embedding_strategy.name: record.pop(cls.embedding_strategy.name),
        }

    def get_similar_items(self, target_db):
        if target_db not in self.similar_items:
            embeddings = []
            items = []
            for item in OntologySchemaEmbedding.objects(
                database=target_db, llm_model=self.llm_model, embedding_strategy=self.embedding_strategy
            ):
                embeddings.append(item.embedding)
                items.append(
                    {
                        "database": item.database,
                        "table": item.table,
                        "column": item.column,
                        "embedding_strategy": item.embedding_strategy,
                        "embedding_text": item.embedding_text,
                        "llm_model": item.llm_model,
                    }
                )
            import numpy as np

            single_vector = np.array(self.embedding)
            batch_of_vectors = np.array(embeddings)
            distances = np.linalg.norm(batch_of_vectors - single_vector, axis=1)
            sorted_indices = np.argsort(distances)
            similar_items = []
            for i in sorted_indices:
                similar_items.append(items[i])
            self.similar_items[target_db] = {
                "database": target_db,
                "similar_items": similar_items,
                "updated_at": datetime.utcnow(),
            }
            self.save()
        return self.similar_items[target_db]["similar_items"]

    def __str__(self):
        return f"{self.database} {self.table} {self.column} {self.llm_model} {self.embedding_strategy}"


"""
class SchemaEmbedding(BaseDocument):
    meta = {
        "indexes": [
            "version",
            {
                "fields": [
                    "dataset",
                    "table",
                    "column",
                    "llm_model",
                ]
            },
            {"fields": ["dataset", "table", "column", "llm_model", "matching_role"]},
        ]
    }
    dataset = StringField(required=True)
    table = StringField(required=True)
    column = StringField(required=True)
    llm_model = StringField(required=True)
    embedding_strategy = StringField(unique_with=["dataset", "table", "column", "llm_model"])

    embedding = ListField(FloatField(), required=True)
    matching_role = StringField(required=True)
    embedding_text = StringField()
    similar_items = ListField(DictField())
    version = IntField()

    @classmethod
    def get_filter(cls, record):
        return {
            cls.dataset.name: record.pop(cls.dataset.name),
            cls.table.name: record.pop(cls.table.name),
            cls.column.name: record.pop(cls.column.name),
            cls.llm_model.name: record.pop(cls.llm_model.name),
            cls.embedding_strategy.name: record.pop(cls.embedding_strategy.name),
        }

    def __str__(self):
        return f"{self.dataset} {self.table} {self.column} {self.llm_model} {self.embedding_strategy}"

    def similar_target_items(self, limit=100):
        assert self.matching_role == "source"
        if self.similar_items:
            return self.similar_items
        search_spec = {
            "index": "vector_index",
            "path": "embedding",
            "queryVector": self.embedding,
            "numCandidates": limit * 10,
            "limit": limit,
        }
        search_spec["filter"] = {
            "dataset": self.dataset,
            "llm_model": self.llm_model,
            "matching_role": "target",
            "embedding_strategy": self.embedding_strategy,
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
            for key in ["embedding", "created_at", "updated_at"]:
                item.pop(key, None)
            item["score"] = round(item["score"], 4)
            result.append(item)
        self.__class__.objects(
            embedding=self.embedding,
            dataset=self.dataset,
            llm_model=self.llm_model,
            matching_role="source",
            embedding_strategy=self.embedding_strategy,
        ).update(set__similar_items=result)
        return result
"""


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
    estimated_cost = FloatField()

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
            "prompt_tokens": result.model_extra["usage"]["model_extra"]["prompt_tokens"],
            "completion_tokens": result.model_extra["usage"]["model_extra"]["completion_tokens"],
            "total_tokens": result.model_extra["usage"]["model_extra"]["total_tokens"],
        }
        try:
            json_result = json.loads(text)
            record["json_result"] = json_result
        except Exception:
            pass

        return cls.upsert(record)


class OntologyAlignmentGroundTruth(BaseDocument):
    dataset = StringField(required=True, unique=True)
    data = DictField()
    extra_data = DictField()

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
    def get_llm_result(cls, run_specs, sub_run_id=None):
        run_specs = {key: run_specs[key] for key in sorted(run_specs.keys())}
        if sub_run_id:
            return cls.objects(run_id_prefix=json.dumps(run_specs), sub_run_id__startswith=sub_run_id).first()
        else:
            return cls.objects(run_id_prefix=json.dumps(run_specs))

    @classmethod
    def upsert_llm_result(cls, run_specs, sub_run_id, result):
        assert "template" not in run_specs
        run_specs = {key: run_specs[key] for key in sorted(run_specs.keys())}
        record = {
            "run_id_prefix": json.dumps(run_specs),
            "sub_run_id": sub_run_id,
            "start": result["extra"]["start"],
            "end": result["extra"]["end"],
            "duration": result["extra"]["duration"],
            "text_result": json.dumps(result),
            "dataset": f'{run_specs["source_db"]}-{run_specs["target_db"]}',
            "prompt_tokens": result["usage"]["prompt_tokens"],
            "completion_tokens": result["usage"]["completion_tokens"],
            "total_tokens": result["usage"]["total_tokens"],
            "json_result": result["extra"]["extracted_json"],
        }
        return cls.upsert(record)


class OntologyMatchingEvaluationReport(BaseDocument):
    meta = {
        "indexes": [
            "version",
            {
                "fields": [
                    "source_database",
                    "target_database",
                    "strategy",
                    "matching_llm",
                    "rewrite_llm",
                ],
                "unique": True,  # unique index
            },
        ]
    }
    source_database = StringField(required=True)
    target_database = StringField(required=True)
    strategy = StringField(
        required=True,
        choices=[
            "coma",
            "rematch",
            "unicorn",
            "similarity_flooding",
            "cupid",
            "schema_understanding-coma",
            "schema_understanding-cupid",
            "schema_understanding-similarity_flooding",
            "gpt-3.5-turbo",
            "gpt-4o",
        ]
        + SCHEMA_UNDERSTANDING_STRATEGIES,
    )
    matching_llm = StringField()
    rewrite_llm = StringField()
    rewrite_prompt_tokens = IntField()
    rewrite_completion_tokens = IntField()
    rewrite_duration = FloatField()
    matching_prompt_tokens = IntField()
    matching_completion_tokens = IntField()
    matching_duration = FloatField()
    total_duration = FloatField()
    precision = FloatField(required=True)
    recall = FloatField(required=True)
    f1_score = FloatField(required=True)
    total_model_cost = FloatField()
    version = IntField()

    @classmethod
    def get_filter(cls, record):
        flt = {
            cls.source_database.name: record.pop(cls.source_database.name),
            cls.target_database.name: record.pop(cls.target_database.name),
            cls.strategy.name: record.pop(cls.strategy.name),
        }
        if "matching_llm" in record:
            flt[cls.matching_llm.name] = record.pop(cls.matching_llm.name)
        if "rewrite_llm" in record:
            flt[cls.rewrite_llm.name] = record.pop(cls.rewrite_llm.name)
        return flt
