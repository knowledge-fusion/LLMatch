import json
from collections import defaultdict

from schema_match.constants import EXPERIMENTS


def generate_table_data(run_specs, database, table_name, tables_description):
    table_description = tables_description[table_name]

    import os

    script_dir = os.path.dirname(os.path.abspath(__file__))

    file_path = os.path.join(script_dir, "generate_sample_data_prompt.md")
    with open(file_path) as file:
        prompt_template = file.read()

    with open(
        os.path.join(script_dir, "generate_sample_data_output_format.json")
    ) as file:
        response_format = json.loads(file.read())

    prompt = prompt_template.replace("{{ table_name }}", table_name).replace(
        "{{ table_schema }}", json.dumps(table_description, indent=2)
    )

    from schema_match.services.language_models import complete

    response = complete(
        prompt=prompt,
        model="gpt-4o-mini-openai",
        run_specs=run_specs,
        response_format=response_format,
    )
    result = response.json()
    data = result["extra"]["extracted_json"]
    return data


def generate_db_data(run_specs):
    from schema_match.data_models.experiment_models import (
        OntologySchemaRewrite,
    )

    databases = [run_specs["source_db"], run_specs["target_db"]]
    for database in databases:
        table_descriptions = OntologySchemaRewrite.get_database_description(
            database, llm_model=run_specs["rewrite_llm"], include_foreign_keys=True
        )

        for table_name in table_descriptions:
            queryset = OntologySchemaRewrite.objects(
                original_table=table_name, database=database, sample_data__exists=False
            )
            if queryset:
                try:
                    res = generate_table_data(
                        run_specs, database, table_name, table_descriptions
                    )
                    print(table_name, res)
                    sample_data = defaultdict(list)
                    for row in res["generated_data"]:
                        for entry in row:
                            column = entry["column"]
                            value = entry["data"]
                            sample_data[column].append(value)
                    for column, values in sample_data.items():
                        record = queryset.filter(original_column=column).first()
                        if record:
                            record.sample_data = values
                            record.save()

                except Exception as e:
                    raise e


if __name__ == "__main__":
    for experiment in EXPERIMENTS:
        source_db, target_db = experiment.split("-")
        run_specs = {
            "source_db": source_db,
            "target_db": target_db,
            "rewrite_llm": "original",
        }
        generate_db_data(run_specs)
