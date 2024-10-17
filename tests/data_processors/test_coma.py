def test_save_coma_alignment_result():
    from llm_ontology_alignment.alignment_strategies.coma_alignment import save_coma_alignment_result
    from llm_ontology_alignment.constants import EXPERIMENTS

    for experiment in EXPERIMENTS:
        for llm in ["original", "gpt-3.5-turbo", "gpt-4o"]:
            run_spect = {
                "source_db": experiment.split("-")[0],
                "target_db": experiment.split("-")[1],
                "rewrite_llm": llm,
                "table_selection_strategy": "None",
                "column_matching_strategy": "coma",
                "column_matching_llm": "None",
                "table_selection_llm": "None",
            }
            save_coma_alignment_result(run_spect)
