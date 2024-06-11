import json

def rewrite_db_schema(
    llm,
    source_schema,
    target_schema,
    source_column_description,
    target_column_description,
    table_name,
    table_description,
    columns,
    runspecs
):
    assert table_name, "Table name is required"
    assert table_description, "Table description is required"
    output_format = {
        "table": {
            "old_name": "old_table_name",
            "new_name": "new_table_name",
            "new_description": "new_table_description",
        },
        "columns": {
            "old_column_name": {
                "new_name": "new_column_name",
                "new_description": "new_column_description",
            }
        }
    }
    prompt = f"""
    You are given two sets of database schema and a table as a json list of columns.
    The final goal is to map the columns of source schema to the columns of target schema.
    As an intermediate step, you are tasked to rewrite the table name, column name, table description, column description to make it more human understandable and easier to match with another schema.
    Read the table and column descriptions of two schemas and develop a COMMON vocabulary to describe the schemas.
    You can assume the semantics and data for two schemas are highly similar.
    The new names should following the a common naming convention.
    The new names shouldn't contain any acronyms. Replace acronyms with full form.
    Return a json dictionary with following format {output_format}.\n\n
    All Source Tables: {json.dumps(source_schema, indent=2)}\n
    All Target Tables: {json.dumps(target_schema, indent=2)}\n
    Sample Source Columns: {json.dumps(source_column_description, indent=2)}\n
    Sample Target Columns: {json.dumps(target_column_description, indent=2)}\n
    Old Table name to rewrite: {table_name}\n
    Old Table description to rewrite: {table_description}\n
    Columns to rewrite: {json.dumps(columns, indent=2)}
"""

    from llm_ontology_alignment.services.language_models import complete
    response = complete(
        prompt=prompt,
        model=llm,
        run_specs={"operation": "rewrite_db_schema", "dataset": runspecs["dataset"], "llm": llm, "sub_run_id": f"{table_name}-{len(columns)}-columns"},
    )
    result = response.json()
    response_text = result["choices"][0]["message"]["content"].strip()

    return response


def update_schema(run_specs):
    import json
    from llm_ontology_alignment.data_models.experiment_models import (
        OntologyAlignmentData, SchemaRewrite
    )

    source_schema_description, target_schema_description = [], []
    source_column_description, target_column_description = [], []
    version = 5
    for table in OntologyAlignmentData.objects(dataset=run_specs["dataset"]).distinct(
        "table_name"
    ):
        record = OntologyAlignmentData.objects(
            dataset=run_specs["dataset"], table_name=table
        ).first()
        description = f"Table: {table}, Description: {record.extra_data.pop('table_description')}. "
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
            SchemaRewrite.objects(
                dataset=run_specs["dataset"], original_table=table_name,  version=version
            ).count()
            > 0
        ):
            continue
        records = []
        old_table_name, old_table_description = "", ""
        for column_item in OntologyAlignmentData.objects(
            dataset=run_specs["dataset"], table_name=table_name
        ):
            column = column_item.extra_data
            if not old_table_description:
                old_table_description = column.pop("table_description", None)
            if not old_table_name:
                old_table_name = column["table"]
            column.pop("matching_role", None)
            column.pop("matching_index", None)
            records.append(column)
        if records:
            result = rewrite_db_schema(
                llm=run_specs["rewrite_llm"],
                source_schema=source_schema_description,
                target_schema=target_schema_description,
                source_column_description=source_column_description[0:4],
                target_column_description=target_column_description[0:4],
                table_name=old_table_name,
                table_description=old_table_description,
                columns=records,
                runspecs=run_specs
            )
            text = result.choices[0]["model_extra"]["message"]["content"]
            json_result = json.loads(text)
            updates = []
            new_table_name = json_result.get(old_table_name, json_result.get('old_table_name'))["new_name"]
            new_table_description = json_result.get(old_table_name, json_result.get("old_table_name"))["new_description"]
            for old_column_name, new_column_data in json_result["columns"].items():
                updates.append(
                    {
                        "dataset": run_specs["dataset"],
                        "original_table": old_table_name,
                        "original_column": old_column_name,
                        "rewritten_table": new_table_name,
                        "rewritten_table_description": new_table_description,
                        "rewritten_column": new_column_data["new_name"],
                        "rewritten_column_description": new_column_data["new_description"],
                        "version": version,
                        "llm_model": run_specs["rewrite_llm"]
                    }
                )
            OntologyAlignmentData.objects.update(unset__table_name_rewritten=1, unset__table_description_rewritten=1, unset__column_name_rewritten=1, unset__column_description_rewritten=1)
            res = SchemaRewrite.upsert_many(updates)
            print(res)
