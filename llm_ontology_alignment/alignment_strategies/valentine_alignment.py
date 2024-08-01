import datetime
import json
from collections import defaultdict

import pandas as pd
import pprint

pp = pprint.PrettyPrinter(indent=4, sort_dicts=False)


def run_match(run_specs):
    # Load data using pandas
    from llm_ontology_alignment.data_models.experiment_models import (
        OntologySchemaRewrite,
        OntologyAlignmentExperimentResult,
    )
    from valentine import valentine_match

    assert run_specs["strategy"] in ["similarity_flooding", "cupid", "coma"]
    run_id_prefix = json.dumps(run_specs)
    record = OntologyAlignmentExperimentResult.objects(run_id_prefix=run_id_prefix).first()
    print(run_id_prefix, record)
    if record:
        return
    source_schema = OntologySchemaRewrite.get_database_description(run_specs["source_db"], run_specs["rewrite_llm"])
    target_shema = OntologySchemaRewrite.get_database_description(run_specs["target_db"], run_specs["rewrite_llm"])

    source_columns = []
    for table, column_data in source_schema.items():
        for column in column_data["columns"]:
            source_columns.append(f"{table}.{column}")

    target_columns = []
    for table, column_data in target_shema.items():
        for column in column_data["columns"]:
            target_columns.append(f"{table}.{column}")
    df1 = pd.DataFrame([], columns=source_columns)
    df2 = pd.DataFrame([], columns=target_columns)
    # Instantiate matcher and run
    from valentine.algorithms import SimilarityFlooding, Cupid, Coma

    if run_specs["strategy"] == "coma":
        matcher = Coma()
    elif run_specs["strategy"] == "similarity_flooding":
        matcher = SimilarityFlooding()
    elif run_specs["strategy"] == "cupid":
        matcher = Cupid()
    else:
        raise ValueError(f"Invalid strategy {run_specs['strategy']}")
    if matcher:
        start = datetime.datetime.utcnow()

        matches = valentine_match(df1, df2, matcher)

        one_to_one = matches.one_to_one()
        end = datetime.datetime.utcnow()
        mapping_result = defaultdict(list)
        for (source, target), score in one_to_one.items():
            print(f"{source} -> {target} ({score})")
            mapping_result[source[1]].append(target[1])

        res = OntologyAlignmentExperimentResult.upsert(
            {
                "run_id_prefix": run_id_prefix,
                "dataset": f"{run_specs['source_db']}-{run_specs['target_db']}",
                "sub_run_id": "",
                "json_result": mapping_result,
                "duration": (end - start).total_seconds(),
            }
        )
        assert res
        pp.pprint(one_to_one)


def get_predictions(run_specs, G):
    from llm_ontology_alignment.data_models.experiment_models import OntologyAlignmentExperimentResult

    assert run_specs["strategy"] in ["similarity_flooding", "cupid"]
    run_specs = {key: run_specs[key] for key in sorted(run_specs.keys())}
    run_specs["strategy"] = "SimilarityFlooding" if run_specs["strategy"] == "similarity_flooding" else "Cupid"
    run_id_prefix = json.dumps(run_specs)
    record = OntologyAlignmentExperimentResult.objects(
        run_id_prefix=run_id_prefix,
        sub_run_id="",
        dataset=f"{run_specs['source_db']}-{run_specs['target_db']}",
    ).first()
    assert record
    predictions = defaultdict(lambda: defaultdict(list))
    for source, targets in record.json_result.items():
        if source.find(".") == -1:
            continue
        for target in targets:
            if target.find(".") == -1:
                continue
            target_table, target_column = target.split(".")
            predictions[target_table][target_column].append(source)
    assert predictions
    return predictions


if __name__ == "__main__":
    for dataset in ["imdb-sakila", "omop-cms", "mimic_iii-omop", "cprd_aurum-omop", "cprd_gold-omop"]:
        for llm in ["gpt-4o", "gpt-3.5-turbo", "original"]:
            source_db, target_db = dataset.split("-")
            run_specs = {
                "source_db": source_db,
                "target_db": target_db,
                "rewrite_llm": llm,
            }
            run_valentine(run_specs)
