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


class OntologyAlignmentExperimentResult(BaseDocument):
    dataset = StringField(required=True)
    run_id = StringField(required=True, unique=True)
    text_result = StringField()
    json_result = DictField()
    start = DateTimeField()
    end = DateTimeField()
    duration = FloatField()
    prompt_tokens = IntField()
    completion_tokens = IntField()
    total_tokens = IntField()

    @classmethod
    def get_filter(cls, record):
        flt = {
            cls.run_id.name: record.pop(cls.run_id.name),
        }
        return flt
