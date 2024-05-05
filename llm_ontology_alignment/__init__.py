
# load MIMIC 2 data from the dataset
# Path: llm_ontology_alignment/__init__.py
def load_dataset(filename):
    import pandas as pd
    data = pd.read_csv(filename)
    return data

def separate_dataset(data):
    from collections import defaultdict
    source_schema = defaultdict(dict)
    target_schema = defaultdict(dict)
    for index, row in data.iterrows():
        source_table, source_column = row['omop'].split('-')
        target_table, target_column = row['table'].split('-')
        source_table_description, source_column_description = row['d1'], row['d2']
        target_table_description, target_column_description = row['d3'], row['d4']
        source_schema[source_table][source_column] = source_column_description
        target_schema[target_column][target_column] = target_column_description

    return source_schema, target_schema


def main():
    import os
    current_dir = os.path.dirname(__file__)
    data = load_dataset(current_dir + '/../dataset/OMOP_Synthea_Data.csv')
    data

if __name__ == "__main__":
    main()