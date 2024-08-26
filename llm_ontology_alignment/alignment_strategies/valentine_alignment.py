import datetime
import json
from collections import defaultdict

import pandas as pd
import pprint


pp = pprint.PrettyPrinter(indent=4, sort_dicts=False)


def run_matching(run_specs, table_selections):
    # Load data using pandas
    from llm_ontology_alignment.data_models.experiment_models import (
        OntologyAlignmentExperimentResult,
    )
    from valentine import valentine_match

    assert run_specs["column_matching_strategy"] in [
        "similarity_flooding",
        "cupid",
        "coma",
    ]
    run_specs = {key: run_specs[key] for key in sorted(run_specs.keys())}
    run_id_prefix = json.dumps(run_specs)

    record = OntologyAlignmentExperimentResult.objects(run_id_prefix=run_id_prefix).first()
    print(run_id_prefix, record)
    if record and record.json_result and record.duration:
        return
    # Instantiate matcher and run
    from valentine.algorithms import SimilarityFlooding, Cupid, Coma

    if run_specs["column_matching_strategy"].find("coma") > -1:
        matcher = Coma(java_xmx="2056m")
    elif run_specs["column_matching_strategy"].find("similarity_flooding") > -1:
        matcher = SimilarityFlooding()
    elif run_specs["column_matching_strategy"].find("cupid") > -1:
        matcher = Cupid()
    else:
        raise ValueError(f"Invalid strategy {run_specs['strategy']}")

    if matcher:
        start = datetime.datetime.utcnow()
        mapping_result = defaultdict(list)

        for df1, df2 in get_matching_dfs(run_specs, table_selections):
            try:
                matches = valentine_match(df1, df2, matcher)
            except Exception as e:
                e
            one_to_one = matches.one_to_one()
            for (source, target), score in one_to_one.items():
                print(f"{source} -> {target} ({score})")
                mapping_result[source[1]].append(target[1])
        end = datetime.datetime.utcnow()
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


def get_matching_dfs(run_specs, table_selections):
    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite

    source_schema = OntologySchemaRewrite.get_database_description(run_specs["source_db"], run_specs["rewrite_llm"])
    target_shema = OntologySchemaRewrite.get_database_description(run_specs["target_db"], run_specs["rewrite_llm"])
    dfs = []
    if not table_selections:
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
        dfs = [(df1, df2)]
    else:
        for source_table, targets in table_selections.items():
            source_columns, target_columns = [], []
            if not targets:
                continue
            source_columns = [f"{source_table}.{column}" for column in source_schema[source_table]["columns"]]
            for target_table in targets:
                target_columns += [f"{target_table}.{column}" for column in target_shema[target_table]["columns"]]
            df1 = pd.DataFrame([], columns=source_columns)
            df2 = pd.DataFrame([], columns=target_columns)
            dfs.append((df1, df2))
    return dfs


def get_predictions(run_specs, G):
    from llm_ontology_alignment.data_models.experiment_models import OntologyAlignmentExperimentResult

    assert run_specs["column_matching_strategy"] in [
        "similarity_flooding",
        "cupid",
        "coma",
    ]

    run_specs = {key: run_specs[key] for key in sorted(run_specs.keys())}
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
    assert predictions, run_id_prefix + json.dumps(record.json_result)
    return predictions
