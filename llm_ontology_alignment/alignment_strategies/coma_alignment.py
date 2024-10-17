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
        f"{run_specs['source_db']}-{run_specs['target_db']}-{run_specs['rewrite_llm'].replace('-', '_')}.txt",
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


def get_predictions(run_specs):
    from llm_ontology_alignment.data_models.experiment_models import OntologyAlignmentExperimentResult

    assert run_specs["column_matching_strategy"] in ["coma"]
    run_specs = {key: run_specs[key] for key in sorted(run_specs.keys())}
    run_id_prefix = json.dumps(run_specs)
    record = OntologyAlignmentExperimentResult.objects(
        run_id_prefix=run_id_prefix,
        sub_run_id="",
        dataset=f"{run_specs['source_db']}-{run_specs['target_db']}",
    ).first()
    assert record, run_id_prefix
    predictions = defaultdict(list)
    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite

    queryset = OntologySchemaRewrite.objects(
        database__in=[run_specs["source_db"], run_specs["target_db"]], llm_model=run_specs["rewrite_llm"]
    )
    for source, targets in record.json_result.items():
        if source.find(".") == -1:
            continue
        source_entry = queryset.filter(
            table__in=[source.split(".")[0], source.split(".")[0].lower()],
            column__in=[source.split(".")[1], source.split(".")[1].lower()],
        ).first()
        if source_entry.linked_table:
            source_entry = queryset.filter(
                table__in=[source_entry.linked_table, source_entry.linked_table.lower()],
                column__in=[source_entry.linked_column, source_entry.linked_column.lower()],
            ).first()
        assert source_entry
        for target in targets:
            if target.find(".") == -1:
                continue
            target_table, target_column = target.split(".")
            target_entry = queryset.filter(
                table__in=[target_table, target_table.lower()],
                column__in=[target_column, target_column.lower()],
            ).first()
            if target_entry.linked_table:
                target_entry = queryset.filter(
                    table__in=[target_entry.linked_table, target_entry.linked_table.lower()],
                    column__in=[target_entry.linked_column, target_entry.linked_column.lower()],
                ).first()
            assert target_entry
            predictions[f"{source_entry.table}.{source_entry.column}"].append(
                f"{target_entry.table}.{target_entry.column}"
            )
    assert predictions
    return predictions
