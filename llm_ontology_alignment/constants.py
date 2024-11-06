COLUMN_MAPPING_STRATEGIES = [
    "coma",
    "llm-rematch",
    "unicorn",
    "similarity_flooding",
    "cupid",
    "llm",
    "llm-no_foreign_keys",
    "llm-no_description",
    "llm-no_description_no_foreign_keys",
    "llm-reasoning",
    "llm-limit_context",
]


TABLE_SELECTION_STRATEGIES = [
    "None",
    "ground_truth",
    "llm",
    "llm-no_foreign_keys",
    "llm-no_description",
    "llm-no_description_no_foreign_keys",
    "llm-reasoning",
    "llm-limit_context",
    "column_to_table_vector_similarity",
    "table_to_table_vector_similarity",
    "table_to_table_top_10_vector_similarity",
    "table_to_table_top_15_vector_similarity",
    "nested_join",
    "block_nested_join_2",
]
EXPERIMENTS = [
    "imdb-sakila",
    "cms-omop",
    "cprd_aurum-omop",
    "cprd_gold-omop",
    "mimic_iii-omop",
    "synthea-omop",
    "bank1-bank2",
]

DATABASES = ["sakila", "imdb", "mimic_iii", "cprd_aurum", "cprd_gold", "cms", "omop", "synthea", "bank1", "bank2"]

SINGLE_TABLE_EXPERIMENTS = [
    "Musicians_joinable_source-Musicians_joinable_target",
    "Musicians_semjoinable_source-Musicians_semjoinable_target",
    "Musicians_unionable_source-Musicians_unionable_target",
    "Musicians_viewunion_source-Musicians_viewunion_target",
]
