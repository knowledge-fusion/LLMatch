import json


def rename_db_column(
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
    As an intermediate step, you are tasked to rewrite the column names for the columns in the table to make it more human understandable.
    Read the table and column descriptions of two schemas and develop a COMMON vocabulary to describe the columns.
    You can assume the semantics and data for two schemas are highly similar.
    The new column names should following the same naming convention.
    The new column names shouldn't contain any acronyms. Replace acronyms with full form.
    Return a dictionary with the old column names as key and the new names as value.\n\n
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


def update_column_name(run_specs):
    import json
    from llm_ontology_alignment.utils import get_embeddings
    from llm_ontology_alignment.data_models.experiment_models import (
        OntologyAlignmentData,
    )

    source_schema_description, target_schema_description = [], []
    source_column_description, target_column_description = [], []
    version = 4
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
            dataset=run_specs["dataset"], table_name=table_name, llm_column_name=None
        ):
            column = column_item.extra_data
            if not table_description:
                table_description = column.pop("table_description", None)
            records.append(column)
        if records:
            result = rename_db_column(
                "gpt-4o",
                source_schema=source_schema_description,
                target_schema=target_schema_description,
                source_column_description=source_column_description[0:4],
                target_column_description=target_column_description[0:4],
                table_description=table_description,
                table=records,
            )
            text = result.choices[0]["model_extra"]["message"]["content"]
            json_result = json.loads(text)
            updates = []
            for column_name, llm_column_name in json_result.items():
                updates.append(
                    {
                        "dataset": run_specs["dataset"],
                        "table_name": table_name,
                        "column_name": column_name,
                        "llm_column_name": llm_column_name,
                        "version": version,
                    }
                )
            res = OntologyAlignmentData.upsert_many(updates)
            print(res)
