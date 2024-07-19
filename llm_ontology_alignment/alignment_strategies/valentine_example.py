import os
import pandas as pd
from valentine.metrics import F1Score, PrecisionTopNPercent
from valentine import valentine_match
import pprint

pp = pprint.PrettyPrinter(indent=4, sort_dicts=False)


def run_valentine():
    # Load data using pandas
    script_dir = os.path.dirname(os.path.abspath(__file__))
    llm_model = "gpt-3.5-turbo"
    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite

    cprd_gold_original = OntologySchemaRewrite.get_database_description("cprd_gold", llm_model)
    omop_original = OntologySchemaRewrite.get_database_description("omop", llm_model)

    cprd_columns = []
    for table, column_data in cprd_gold_original.items():
        for column in column_data["columns"]:
            cprd_columns.append(f"{table}.{column}")

    omop_columns = []
    for table, column_data in omop_original.items():
        for column in column_data["columns"]:
            omop_columns.append(f"{table}.{column}")
    df1 = pd.DataFrame([], columns=cprd_columns)
    df2 = pd.DataFrame([], columns=omop_columns)
    # Instantiate matcher and run
    from valentine.algorithms import Coma

    matcher = Coma()
    matches = valentine_match(df1, df2, matcher)

    # MatcherResults is a wrapper object that has several useful
    # utility/transformation functions
    print(f"Found the following {len(matches)} matches:")
    pp.pprint(matches)

    print("\nGetting the one-to-one matches:")
    pp.pprint(matches.one_to_one())

    # If ground truth available valentine could calculate the metrics
    ground_truth = [("Cited by", "Cited by"), ("Authors", "Authors"), ("EID", "EID")]

    metrics = matches.get_metrics(ground_truth)

    print("\nAccording to the ground truth:")
    pp.pprint(ground_truth)

    print("\nThese are the scores of the default metrics for the matcher:")
    pp.pprint(metrics)

    print("\nYou can also get specific metric scores:")
    pp.pprint(matches.get_metrics(ground_truth, metrics={PrecisionTopNPercent(n=80), F1Score()}))

    print("\nThe MatcherResults object is a dict and can be treated such:")
    for match in matches:
        print(f"{str(match): <60} {matches[match]}")


if __name__ == "__main__":
    run_valentine()
