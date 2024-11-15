from llm_ontology_alignment.constants import TABLE_SELECTION_STRATEGIES
from llm_ontology_alignment.data_models.experiment_models import BaseDocument

from mongoengine import StringField, DictField, IntField


class OntologyTableSelectionResult(BaseDocument):
    table_selection_llm = StringField()
    table_selection_strategy = StringField(
        required=True,
        choices=TABLE_SELECTION_STRATEGIES,
    )
    source_database = StringField(required=True)
    target_database = StringField(required=True)
    rewrite_llm = StringField(
        required=True,
        unique_with=["source_database", "target_database", "table_selection_llm", "table_selection_strategy"],
    )
    context_size = IntField()
    data = DictField(required=True)
    total_tokens = IntField()

    @classmethod
    def get_filter(cls, record):
        flt = {
            cls.source_database.name: record.pop(cls.source_database.name),
            cls.target_database.name: record.pop(cls.target_database.name),
            cls.rewrite_llm.name: record.pop(cls.rewrite_llm.name),
            cls.table_selection_llm.name: record.pop(cls.table_selection_llm.name),
            cls.table_selection_strategy.name: record.pop(cls.table_selection_strategy.name),
        }
        return flt
