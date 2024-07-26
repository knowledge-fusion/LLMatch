import json


def print_result():
    run_specs = {
        "source_db": "cprd_aurum",
        "target_db": "omop",
        "matching_llm": "gpt-4o",
        "rewrite_llm": "gpt-3.5-turbo",
        "strategy": "coma",
        "template": "top2-no-na",
        "use_translation": False,
    }
    from llm_ontology_alignment.alignment_strategies.evaluation import (
        print_result_one_to_many,
    )

    print_result_one_to_many(run_specs)


def test_print_result():
    from llm_ontology_alignment.alignment_strategies.evaluation import print_table_mapping_result

    run_specs = {
        "source_db": "imdb",
        "target_db": "sakila",
        "matching_llm": "gpt-4o",
        "rewrite_llm": "gpt-4o",
        "strategy": "rematch",
        "template": "top2-no-na",
    }
    run_specs = {key: run_specs[key] for key in sorted(run_specs.keys())}
    from llm_ontology_alignment.data_processors.load_data import import_ground_truth

    import_ground_truth(run_specs["source_db"], run_specs["target_db"])

    rewrite = False
    if rewrite:
        from llm_ontology_alignment.data_processors.rewrite_db_schema import rewrite_db_columns

        rewrite_db_columns(run_specs)
        from llm_ontology_alignment.data_processors.load_data import update_rewrite_schema_constraints

        update_rewrite_schema_constraints(run_specs["source_db"])
        update_rewrite_schema_constraints(run_specs["target_db"])

    # from llm_ontology_alignment.data_models.experiment_models import OntologyAlignmentExperimentResult
    # OntologyAlignmentExperimentResult.objects(run_id_prefix=json.dumps(run_specs)).delete()
    run_id_prefix = json.dumps(run_specs)
    print("\n", run_id_prefix)
    print_table_mapping_result(run_specs)

    from llm_ontology_alignment.alignment_strategies.rematch import run_matching

    run_matching(run_specs)
    from llm_ontology_alignment.alignment_strategies.evaluation import print_result_one_to_many

    print_result_one_to_many(run_specs)
