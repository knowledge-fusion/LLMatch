def test_dataset_statistics_rows():
    from llm_ontology_alignment.evaluations.extended_study_evaluation import dataset_statistics_rows

    rows = dataset_statistics_rows()
    print(rows)


def test_ground_truth_statistics():
    from llm_ontology_alignment.evaluations.extended_study_evaluation import ground_truth_statistics

    rows = ground_truth_statistics()
    print(rows)


def test_generate_human_experiment_result():
    from llm_ontology_alignment.evaluations.extended_study_evaluation import generate_human_experiment_result

    generate_human_experiment_result()
