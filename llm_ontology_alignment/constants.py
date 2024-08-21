COLUMN_MAPPING_STRATEGIES = [
    "coma",
    "llm-rematch",
    "unicorn",
    "similarity_flooding",
    "cupid",
    "llm",
    "llm-no_foreign_keys",
    "llm-no_description",
    "llm-reasoning",
]


TABLE_SELECTION_STRATEGIES = [
    "None",
    "llm",
    "llm-reasoning",
    "column_to_table_vector_similarity",
    "table_to_table_vector_similarity",
    "nested_join",
    "block_nested_join_2",
]
EXPERIMENTS = ["imdb-sakila", "cms-omop", "cprd_aurum-omop", "cprd_gold-omop", "mimic_iii-omop"]

DATABASES = ["sakila", "imdb", "mimic_iii", "cprd_aurum", "cprd_gold", "cms", "omop"]
