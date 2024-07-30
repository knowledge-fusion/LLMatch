import datetime
import json
from collections import defaultdict

import pandas as pd
from valentine import valentine_match
import pprint

pp = pprint.PrettyPrinter(indent=4, sort_dicts=False)


def run_valentine(run_specs):
    # Load data using pandas
    from llm_ontology_alignment.data_models.experiment_models import (
        OntologySchemaRewrite,
        OntologyAlignmentExperimentResult,
    )

    source_schema = OntologySchemaRewrite.get_database_description(run_specs["source_db"], run_specs["rewrite_llm"])
    target_shema = OntologySchemaRewrite.get_database_description(run_specs["target_db"], run_specs["rewrite_llm"])

    source_columns = []
    for table, column_data in source_schema.items():
        for column in column_data["columns"]:
            source_columns.append(f"{table}.{column}")

    omop_columns = []
    for table, column_data in target_shema.items():
        for column in column_data["columns"]:
            omop_columns.append(f"{table}.{column}")
    df1 = pd.DataFrame([], columns=source_columns)
    df2 = pd.DataFrame([], columns=omop_columns)
    # Instantiate matcher and run
    from valentine.algorithms import SimilarityFlooding, Cupid

    for algorithm_cls in [SimilarityFlooding, Cupid]:
        start = datetime.datetime.utcnow()
        run_specs["strategy"] = algorithm_cls.__name__
        run_specs = {key: run_specs[key] for key in sorted(run_specs.keys())}
        run_id_prefix = json.dumps(run_specs)
        record = OntologyAlignmentExperimentResult.objects(run_id_prefix=run_id_prefix).first()
        print(run_id_prefix, record)
        if record:
            continue
        matcher = algorithm_cls()
        matches = valentine_match(df1, df2, matcher)
        print(f"Found the following {len(matches)} matches using {algorithm_cls.__name__}:")

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
