def print_result(dataset):
    from llm_ontology_alignment.alignment_models.rematch import get_ground_truth
    ground_truths = get_ground_truth(dataset)
    duration, prompt_token, completion_token = 0, 0, 0
    from llm_ontology_alignment.data_models.experiment_models import OntologyAlignmentExperimentResult
    # for result in OntologyAlignmentExperimentResult.objects(
    #         run_id__startswith=run_id_prefix, dataset=dataset
    # ):