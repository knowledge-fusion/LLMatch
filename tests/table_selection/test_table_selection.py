def test_effect_of_context_size_in_table_selection():
    from schema_match.evaluations.ontology_matching_evaluation import (
        effect_of_context_size_in_table_selection,
    )

    effect_of_context_size_in_table_selection("gpt-3.5-turbo")
