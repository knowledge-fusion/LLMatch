import json

from llm_ontology_alignment.utils import split_list_into_chunks


def update_db_table_rewrites(runspecs, database, original_table_name):
    old_table_name = None
    old_columns = dict()
    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite

    for item in OntologySchemaRewrite.objects(
        database=database, original_table=original_table_name, llm_model=runspecs["rewrite_llm"]
    ):
        if not old_table_name:
            old_table_name = item.table
        old_columns[item.column] = item.original_column

    OntologySchemaRewrite.objects(
        database=database,
        original_table=original_table_name,
        llm_model=runspecs["rewrite_llm"],
    ).delete()
    rewrite_table_schema(runspecs, database, original_table_name)

    new_table_name = None
    new_columns = dict()
    for item in OntologySchemaRewrite.objects(
        database=database, original_table=original_table_name, llm_model=runspecs["rewrite_llm"]
    ):
        if not new_table_name:
            new_table_name = item.table
        new_columns[item.original_column] = item.column

    assert old_table_name, "Original table name not found"
    # update linked table mappings
    for item in OntologySchemaRewrite.objects(
        database=database, llm_model=runspecs["rewrite_llm"], linked_table=old_table_name
    ):
        item.linked_table = new_table_name
        new_column = new_columns.get(old_columns.get(item.linked_column))
        if not new_column:
            new_column
        item.linked_column = new_column
        item.save()


def rewrite_db_schema(
    llm, database, table_name, table_description, columns, existing_table_rewrites, existing_column_rewrites, sub_run_id
):
    assert table_name, "Table name is required"
    if not table_description:
        table_name
    assert table_description, "Table description is required"
    assert database, "Database name is required"
    import os

    script_dir = os.path.dirname(os.path.abspath(__file__))

    file_path = os.path.join(script_dir, "rewrite_db_schema_prompt.md")
    with open(file_path, "r") as file:
        prompt_template = file.read()

    input_data = {
        "table": {
            "old_name": table_name,
            "old_description": table_description,
        },
        "columns": columns,
    }

    prompt = prompt_template.replace("{{input_data}}", json.dumps(input_data, indent=2))
    prompt = prompt.replace("{{existing_column_rewrites}}", json.dumps(existing_column_rewrites, indent=2))
    from llm_ontology_alignment.services.language_models import complete

    response = complete(
        prompt=prompt,
        model=llm,
        run_specs={
            "operation": "rewrite_db_schema",
            "llm": llm,
            "sub_run_id": sub_run_id,
        },
    )
    result = response.json()

    json_result = result["extra"]["extracted_json"]
    if not json_result:
        text_result = result["choices"][0]["message"]["content"]
        print(text_result)

    return json_result


def rewrite_table_schema(run_specs, database, table_name):
    version = 0
    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite

    queryset = OntologySchemaRewrite.objects(database=database, table=table_name, llm_model="original")
    if (
        OntologySchemaRewrite.objects(
            database=database,
            original_table=table_name,
            llm_model=run_specs["rewrite_llm"],
        ).count()
        == queryset.count()
        # and OntologySchemaRewrite.objects(
        #     database=database,
        #     original_table=table_name,
        #     llm_model=run_specs["rewrite_llm"],
        # )
        # .order_by("-updated_at")
        # .first()
        # .updated_at
        # > queryset.order_by("-updated_at").first().updated_at
    ):
        return {}

    OntologySchemaRewrite.objects(
        database=database,
        original_table=table_name,
        llm_model=run_specs["rewrite_llm"],
    ).delete()
    # existing rewrites
    table_name_rewrite = {}
    for original_table in OntologySchemaRewrite.objects(database=database, llm_model=run_specs["rewrite_llm"]).distinct(
        "original_table"
    ):
        if set(original_table.split("_")).isdisjoint(set(table_name.split("_"))):
            continue
        table_name_rewrite[original_table] = (
            OntologySchemaRewrite.objects(
                database=database, llm_model=run_specs["rewrite_llm"], original_table=original_table
            )
            .first()
            .table
        )
    column_name_rewrite = {}
    for original_column in OntologySchemaRewrite.objects(
        database=database, llm_model=run_specs["rewrite_llm"], original_column__in=queryset.values_list("column")
    ).distinct("original_column"):
        column_name_rewrite[original_column] = (
            OntologySchemaRewrite.objects(
                database=database, llm_model=run_specs["rewrite_llm"], original_column=original_column
            )
            .first()
            .column
        )
    records = {}
    old_table_name, old_table_description = "", ""
    for column_item in queryset:
        if not old_table_description:
            old_table_description = column_item.table_description
        if not old_table_name:
            old_table_name = column_item.table

        records[column_item.column] = {
            "old_name": column_item.column,
            "old_description": column_item.column_description,
            "column_type": column_item.column_type,
        }
    if records:
        updates = dict()
        columns = list(records.values())
        new_table_name, new_table_description = "", ""
        batches = [columns]
        if len(columns) > 5 and run_specs["rewrite_llm"].find("gpt") == -1:
            batches = split_list_into_chunks(columns, chunk_size=5)
        for idx, chunks in enumerate(batches):
            json_result = rewrite_db_schema(
                llm=run_specs["rewrite_llm"],
                database=database,
                table_name=old_table_name,
                table_description=old_table_description,
                columns=chunks,
                existing_table_rewrites=table_name_rewrite,
                existing_column_rewrites=column_name_rewrite,
                sub_run_id=f"{table_name}-{len(columns)}-columns-{idx}",
            )
            if column_name_rewrite:
                json_result
            if not new_table_name:
                new_table_name = json_result.get("table", {}).get("new_name")
            if not new_table_description:
                new_table_description = json_result.get("table", {}).get("new_description")

            for column_item in json_result["columns"]:
                if column_item["old_name"] not in records:
                    column_item
                if column_item["old_name"] in records:
                    assert column_item["new_name"] not in updates, column_item
                    updates[column_item["new_name"]] = {
                        "database": database,
                        "original_table": old_table_name,
                        "original_column": column_item["old_name"],
                        "column_type": records[column_item["old_name"]]["column_type"],
                        "table": new_table_name.replace(" ", "_"),
                        "table_description": new_table_description,
                        "column": column_item["new_name"].replace(" ", "_"),
                        "column_description": str(column_item["new_description"]),
                        "version": version,
                        "llm_model": run_specs["rewrite_llm"],
                    }

        assert len(updates) == len(records)
        res = OntologySchemaRewrite.upsert_many(list(updates.values()))
        if res["errors"]:
            res
        assert not res["errors"], res["errors"]
        return res


def rewrite_db_columns(run_specs):
    from llm_ontology_alignment.data_models.experiment_models import (
        OntologySchemaRewrite,
    )
    from llm_ontology_alignment.data_processors.load_data import update_rewrite_schema_constraints

    databases = [run_specs["source_db"], run_specs["target_db"]]
    for database in databases:
        tables = OntologySchemaRewrite.objects(database=database, llm_model="original").distinct("original_table")
        for table_name in tables:
            res = rewrite_table_schema(run_specs, database, table_name)
            print(table_name, res)
        update_rewrite_schema_constraints(database.upper())
