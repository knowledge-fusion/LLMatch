import json


def save_coma_alignment_result():
    import os

    script_dir = os.path.dirname(os.path.abspath(__file__))

    source_dbs = ["cprd_gold", "cprd_aurum", "mimic_iii"]
    target_db = "omop"
    for source_db in source_dbs:
        for llm_model in ["gpt-3.5-turbo", "original"]:
            run_specs = {
                "source_db": source_db,
                "target_db": target_db,
                "strategy": "coma",
                "rewrite_llm": llm_model,
            }
            file_path = os.path.join(
                script_dir,
                "..",
                "..",
                "dataset/match_result/coma",
                f"{source_db}-{target_db}-{llm_model.replace('-', '_')}.txt",
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
                dataset=f"{source_db}-{target_db}",
                json_result=mapping,
            ).save()
            assert res
