from llm_ontology_alignment.evaluations.ontology_matching_evaluation import get_full_results
from llm_ontology_alignment.evaluations.latex_report.full_experiment_f1_score import experiments


def dataset_statistics_rows():
    rows = []
    for dataset in ["sakila", "imdb", "mimic_iii", "cprd_aurum", "cprd_gold", "cms", "omop"]:
        from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite

        schema_descriptions = OntologySchemaRewrite.get_database_description(dataset, "original")
        number_of_table = len(schema_descriptions)
        number_of_columns = sum([len(schema["columns"]) for schema in schema_descriptions.values()])
        number_of_foreign_keys = 0
        number_of_primary_keys = 0
        for schema in schema_descriptions.values():
            for field in schema["columns"].values():
                if field.get("is_foreign_key"):
                    number_of_foreign_keys += 1
                if field.get("is_primary_key"):
                    number_of_primary_keys += 1

        rows.append(
            [
                dataset,
                number_of_table,
                number_of_columns,
                number_of_foreign_keys,
                number_of_primary_keys,
            ]
        )
    return rows


def export_scalability_study_data():
    result = get_full_results()
    dataset_statistics = dataset_statistics_rows()
    strategy_mappings = [
        ("coma Rewrite: original", "Coma"),
        ("similarity_flooding Rewrite: original", "Similarity Flooding"),
        ("cupid Rewrite: original", "Cupid"),
        ("unicorn Rewrite: original", "Unicorn"),
        ("rematch Rewrite: original Matching: gpt-4o", "Rematch (gpt-4o)"),
        # (
        # '{"strategy": "schema_understanding_no_reasoning", "rewrite_llm": "gpt-3.5-turbo", "matching_llm": "gpt-3.5-turbo"}',
        # "Schema Understanding (rewrite:gpt-4o/matching:gpt-3.5)"),
        # ('{"strategy": "schema_understanding_no_reasoning", "rewrite_llm": "gpt-3.5-turbo", "matching_llm": "gpt-4o"}',
        #  "Schema Understanding (rewrite:gpt-3.5/matching:gpt-4o)"),
        (
            "schema_understanding_no_reasoning Rewrite: gpt-4o Matching: gpt-4o",
            "Schema Understanding (gpt-4o)",
        ),
        # (
        #     "schema_understanding_no_reasoning Rewrite: gpt-3.5-turbo Matching: gpt-4o",
        #     "Schema Understanding (rewrite:gpt-3.5/matching:gpt-4o)",
        # ),
    ]
    rows = []
    for config, strategy in strategy_mappings:
        row = [strategy]
        for dataset in experiments:
            try:
                row.append(result[config][dataset].total_duration)
            except Exception as e:
                row.append(0)

                # raise e
        rows.append(row)
    return rows


if __name__ == "__main__":
    export_scalability_study_data()
    print("Done")
