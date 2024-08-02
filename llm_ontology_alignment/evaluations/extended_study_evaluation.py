def export_dataset_statistics_latex_table():
    rows = []

    for dataset in ["cms", "omop", "mimic_iii", "cprd_aurum", "cprd_gold", "sakila", "imdb"]:
        from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite

        schema_descriptions = OntologySchemaRewrite.get_database_description(dataset, "original")
        number_of_table = len(schema_descriptions)
        number_of_columns = sum([len(schema["columns"]) for schema in schema_descriptions])
        number_of_foreign_keys = sum([len(schema["foreign_keys"]) for schema in schema_descriptions])
        number_of_primary_keys = sum([len(schema["primary_keys"]) for schema in schema_descriptions])
        rows.append([dataset, number_of_table, number_of_columns, number_of_foreign_keys, number_of_primary_keys])
