import json
import os
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
    BooleanField,
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
    completion_tokens_details = DictField()
    prompt_tokens_details = DictField()

    def __unicode__(self):
        return self.run_specs


class OntologyAlignmentGroundTruth(BaseDocument):
    dataset = StringField(required=True, unique=True)
    data = DictField()
    extra_data = DictField()

    def __unicode__(self):
        return self.dataset

    @classmethod
    def get_filter(self, record):
        return {self.dataset.name: record.pop(self.dataset.name)}


class OntologyAlignmentExperimentResult(BaseDocument):
    dataset = StringField(required=True)
    operation_specs = DictField(unique=True)
    text_result = StringField()
    json_result = DictField()
    sanitized_result = DictField()
    start = DateTimeField()
    end = DateTimeField()
    duration = FloatField()
    prompt_tokens = IntField()
    completion_tokens = IntField()
    total_tokens = IntField()
    extra_data = DictField()
    version = IntField()

    def __unicode__(self):
        return json.dumps(self.operation_specs)

    @classmethod
    def get_filter(cls, record):
        flt = {
            cls.operation_specs.name: record.pop(cls.operation_specs.name),
        }
        return flt

    @classmethod
    def upsert_llm_result(cls, operation_specs, result):
        assert operation_specs["operation"] in ["column_matching", "table_candidate_selection"]
        record = {
            "sanitized_result": None,
            "operation_specs": operation_specs,
            "start": result["extra"]["start"],
            "end": result["extra"]["end"],
            "duration": result["extra"]["duration"],
            "text_result": json.dumps(result),
            "dataset": f'{operation_specs["source_db"]}-{operation_specs["target_db"]}',
            "prompt_tokens": result["usage"]["prompt_tokens"],
            "completion_tokens": result["usage"]["completion_tokens"],
            "total_tokens": result["usage"]["total_tokens"],
            "json_result": result["extra"]["extracted_json"],
        }
        res = cls.upsert(record)
        return res
