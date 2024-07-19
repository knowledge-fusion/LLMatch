import os
import pandas as pd
from valentine import valentine_match
import pprint

pp = pprint.PrettyPrinter(indent=4, sort_dicts=False)


def run_valentine():
    # Load data using pandas
    script_dir = os.path.dirname(os.path.abspath(__file__))
    llm_model = "gpt-3.5-turbo"
    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite

    cprd_gold_original = OntologySchemaRewrite.get_database_description("cprd_aurum", llm_model)
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

    one_to_one = matches.one_to_one()

    print(f"\nGetting the {len(one_to_one)} one-to-one matches:")
    pp.pprint(one_to_one)


if __name__ == "__main__":
    run_valentine()
