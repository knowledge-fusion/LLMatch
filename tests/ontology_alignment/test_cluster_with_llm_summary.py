def test_cluster_with_llm_summary():
    from llm_ontology_alignment.alignment_strategies.column_cluster_with_llm_summary import (
        run_cluster_with_llm_summary,
    )

    run_cluster_with_llm_summary(dataset="OMOP_Synthea")
