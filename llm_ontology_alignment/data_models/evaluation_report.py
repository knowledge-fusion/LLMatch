from mongoengine import StringField, IntField, FloatField, DictField

from llm_ontology_alignment.constants import TABLE_SELECTION_STRATEGIES, COLUMN_MAPPING_STRATEGIES
from llm_ontology_alignment.data_models.experiment_models import BaseDocument


class OntologyMatchingEvaluationReport(BaseDocument):
    meta = {
        "indexes": [
            "version",
            {
                "fields": [
                    "source_database",
                    "target_database",
                    "table_selection_strategy",
                    "column_matching_strategy",
                    "table_selection_llm",
                    "column_matching_llm",
                    "matching_llm",
                    "rewrite_llm",
                ],
                "unique": True,  # unique index
            },
        ]
    }
    source_database = StringField(required=True)
    target_database = StringField(required=True)
    table_selection_strategy = StringField(
        choices=TABLE_SELECTION_STRATEGIES,
    )
    column_matching_strategy = StringField(
        choices=COLUMN_MAPPING_STRATEGIES,
    )
    strategy = StringField(
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
    )
    table_selection_llm = StringField()
    column_matching_llm = StringField()
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
    details = DictField()
    total_model_cost = FloatField()
    version = IntField()

    @classmethod
    def get_filter(cls, record):
        flt = {
            cls.source_database.name: record.pop(cls.source_database.name),
            cls.target_database.name: record.pop(cls.target_database.name),
            cls.table_selection_strategy.name: record.pop(cls.table_selection_strategy.name),
            cls.column_matching_strategy.name: record.pop(cls.column_matching_strategy.name),
            cls.table_selection_llm.name: record.pop(cls.table_selection_llm.name),
            cls.column_matching_llm.name: record.pop(cls.column_matching_llm.name),
            cls.rewrite_llm.name: record.pop(cls.rewrite_llm.name),
        }
        return flt
