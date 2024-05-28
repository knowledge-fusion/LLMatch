import json


def describe_db_column(
    llm,
    source_schema,
    target_schema,
    source_column_description,
    target_column_description,
    table_description,
    table,
):
    assert table_description, "Table description is required"
    prompt = f"""
    You are given two sets of database schema and and a table as a json list of columns.
    The final goal is to map the columns of source schema to the columns of target schema.
    As an intermediate step, you are tasked to rewrite the column descriptions for the columns in the table.
    Read the table and column descriptions of two schemas and develop a COMMON vocabulary to describe the columns.
    You can assume the semantics and data for two schemas are highly similar.
    The new column descriptions should group similar columns together.
    The description should inform the matcher about the table information in which the column belongs to, foreign/primary key, data type, etc.
    The description shouldn't contain acronyms if explanation is provided in table description. Replace acronyms with full form.
    Return a dictionary with the column names as key and one line summary as value.\n\n
    Source Tables: {json.dumps(source_schema, indent=2)}\n
    Target Tables: {json.dumps(target_schema, indent=2)}\n
    Sample Source Columns: {json.dumps(source_column_description, indent=2)}\n
    Sample Target Columns: {json.dumps(target_column_description, indent=2)}\n
    Table description: {table_description}\n
    Columns to annotate: {json.dumps(table, indent=2)}
"""

    from litellm import completion

    messages = [{"content": prompt, "role": "user"}]

    response = completion(
        model=llm,
        seed=42,
        temperature=0.5,
        top_p=0.9,
        max_tokens=4096,
        frequency_penalty=0,
        presence_penalty=0,
        messages=messages,
        response_format={"type": "json_object"},
    )

    return response


def load_and_save_schema(run_specs):
    import json
    import os
    from llm_ontology_alignment.data_models.experiment_models import (
        OntologyAlignmentData,
    )

    # Get the directory of the current script
    script_dir = os.path.dirname(os.path.abspath(__file__))
    records = []
    for filespec in run_specs["schemas"]:
        # Define the relative path to the CSV file

        file_path = os.path.join(
            script_dir, "..", "..", "dataset", filespec["filename"]
        )
        matching_role = filespec["matching_role"]
        # Open the CSV file and read its contents
        with open(file_path, mode="r", newline="") as file:
            data = json.load(file)

        for table_name, columns in data.items():
            for column_name, column in columns.items():
                if column_name in ["NaN", "nan"]:
                    continue
                column.pop("id", None)
                embedding = column.pop("embedding", None)
                column["matching_role"] = matching_role
                column["matching_index"] = len(records)
                records.append(
                    {
                        "dataset": run_specs["dataset"],
                        "table_name": column["table"],
                        "column_name": column["column"],
                        "default_embedding": embedding,
                        "extra_data": column,
                        "version": 0,
                    }
                )
    res = OntologyAlignmentData.upsert_many(records)
    print(res)


def update_schema(run_specs):
    import json
    from llm_ontology_alignment.utils import get_embeddings
    from llm_ontology_alignment.data_models.experiment_models import (
        OntologyAlignmentData,
    )

    source_schema_description, target_schema_description = [], []
    source_column_description, target_column_description = [], []
    version = 3
    for table in OntologyAlignmentData.objects(dataset=run_specs["dataset"]).distinct(
        "table_name"
    ):
        record = OntologyAlignmentData.objects(
            dataset=run_specs["dataset"], table_name=table
        ).first()
        description = f"Table: {table}, Description: {record.extra_data.pop('table_description')}. "
        # description += f"Columns: {OntologyAlignmentData.objects(dataset=run_specs['dataset'], table_name=table).distinct('column_name')}"
        record.extra_data.pop("matching_index", None)
        matching_role = record.extra_data.pop("matching_role")
        column_description = record.extra_data
        if matching_role == "source":
            source_schema_description.append(description)
            source_column_description.append(column_description)
        else:
            target_schema_description.append(description)
            target_column_description.append(column_description)

    for table_name in OntologyAlignmentData.objects(
        dataset=run_specs["dataset"]
    ).distinct("table_name"):
        if (
            OntologyAlignmentData.objects(
                dataset=run_specs["dataset"], table_name=table_name, version=version
            ).count()
            > 0
        ):
            continue
        records = []
        table_description = ""
        for column_item in OntologyAlignmentData.objects(
            dataset=run_specs["dataset"],
            table_name=table_name,
        ):
            column = column_item.extra_data
            if not table_description:
                table_description = column.pop("table_description", None)
            records.append(column)
        if records:
            result = describe_db_column(
                "gpt-4o",
                source_schema=source_schema_description,
                target_schema=target_schema_description,
                source_column_description=source_column_description[0:5],
                target_column_description=target_column_description[0:5],
                table_description=table_description,
                table=records,
            )
            text = result.choices[0]["model_extra"]["message"]["content"]
            json_result = json.loads(text)
            updates = []
            for column_name, llm_description in json_result.items():
                updates.append(
                    {
                        "dataset": run_specs["dataset"],
                        "table_name": table_name,
                        "column_name": column_name,
                        "llm_description": llm_description,
                        "llm_summary_embedding": get_embeddings(
                            table_name + " " + column_name + " " + llm_description
                        ),
                        "version": version,
                    }
                )
            res = OntologyAlignmentData.upsert_many(updates)
            print(res)
