import json
from collections import defaultdict


def save_coma_alignment_result(run_specs):
    import os

    script_dir = os.path.dirname(os.path.abspath(__file__))

    file_path = os.path.join(
        script_dir,
        "..",
        "..",
        "dataset/match_result/coma",
        f"{run_specs['source_db']}-{run_specs['target_db']}-{run_specs['llm_model'].replace('-', '_')}.txt",
    )
    mapping = {}
    with open(file_path, mode="r", newline="", encoding="utf-8-sig") as file:
        for row in file:
            row = row.strip()
            if not row.startswith("- "):
                continue
            tokens = row.split(" ")
            assert len(tokens) == 5
            source = tokens[1]
            target = tokens[3].replace(":", "")
            mapping[source] = [target]
            from llm_ontology_alignment.data_models.experiment_models import OntologyAlignmentExperimentResult

            run_specs = {key: run_specs[key] for key in sorted(run_specs.keys())}
            run_id_prefix = json.dumps(run_specs)
            OntologyAlignmentExperimentResult.objects(run_id_prefix=run_id_prefix).delete()
            res = OntologyAlignmentExperimentResult(
                run_id_prefix=run_id_prefix,
                sub_run_id="",
                dataset=f"{run_specs['source_db']}-{run_specs['target_db']}",
                json_result=mapping,
            ).save()
            assert res


def get_predictions(run_specs, G):
    from llm_ontology_alignment.data_models.experiment_models import OntologyAlignmentExperimentResult

    assert run_specs["strategy"] == "coma"
    run_specs = {key: run_specs[key] for key in sorted(run_specs.keys())}
    run_id_prefix = json.dumps(run_specs)
    record = OntologyAlignmentExperimentResult.objects(
        run_id_prefix=run_id_prefix,
        sub_run_id="",
        dataset=f"{run_specs['source_db']}-{run_specs['target_db']}",
    ).first()
    assert record
    predictions = defaultdict(dict)
    for source, targets in record.json_result.items():
        if source.find(".") == -1:
            continue
        source_table, source_column = source.split(".")
        predictions[source_table][source_column] = targets
    assert predictions
    return predictions
