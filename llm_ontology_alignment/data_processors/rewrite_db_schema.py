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
    sample_input = {
        "table": {
            "old_name": "basic_information",
            "old_description": "the address contains basic information for customers, staff, and stores.",
        },
        "columns": [
            {
                "old_name": "address_id",
                "old_description": "a surrogate primary key used to uniquely identify each address in the table. Type: int(11)",
            },
            {
                "old_name": "address",
                "old_description": "the details of an address. Type: varchar(255)",
            },
            {
                "old_name": "owner_id",
                "old_description": "an mapping to person table. Type: int(11)",
            },
        ],
    }
    sample_output = {
        "table": {
            "old_name": "address",
            "new_name": "address_information",
            "new_description": "This table contains address details for customers, staff, and stores.",
        },
        "columns": [
            {
                "old_name": "address_id",
                "new_name": "address_identifier",
                "new_description": "Primary Key. A unique identifier used to uniquely identify each address in the table. Type: Integer",
            },
            {
                "old_name": "address",
                "new_name": "address",
                "new_description": "The details of an address. Type: Text",
            },
            {
                "old_name": "owner_id",
                "new_name": "owner_identifier",
                "new_description": "Foreign Key. A reference to the person table. Type: Integer",
            },
        ],
    }

    task_json = {
        "table": {
            "old_name": table_name,
            "old_description": table_description,
        },
        "columns": columns,
    }

    prompt = f"""
    You are given a table from the database: {database} as a json list of columns.
    You are tasked to rewrite the table name, column name, table description, column description to make it easier to understand the content stored in the table.
    The new names shouldn't contain any acronyms. Replace acronyms with full form. It should be easy to understand for a non-domain expert.
    Descriptions should be clear and concise. Table descriptions should contain information on data stored in columns.
    Original names can be kept if they are already clear and precise.
    Retain Primary Key/Foreign Key/Table Mapping/Type information if exists.
    New column names should be unique within the table.
    Existing table name rewrites: \n{json.dumps(existing_table_rewrites, indent=2)}
    Existing column name rewrites: \n{json.dumps(existing_column_rewrites, indent=2)}
    Try to keep the new name consistent with the existing rewrites.
    Try to reuse old vocabulary if possible.
    Do not reuse table names.
    Follow the example to complete the output. Only return one json output without any explanation.\n\n
    Input: \n{json.dumps(sample_input, indent=2)}\n
    Output: \n{json.dumps(sample_output, indent=2)}\n
    Input: \n{json.dumps(task_json, indent=2)}\n
    Output: \n
"""

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
        and OntologySchemaRewrite.objects(
            database=database,
            original_table=table_name,
            llm_model=run_specs["rewrite_llm"],
        )
        .order_by("-updated_at")
        .first()
        .updated_at
        > queryset.order_by("-updated_at").first().updated_at
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
            updates = []
            if not new_table_name:
                new_table_name = json_result.get("table", {}).get("new_name")
            if not new_table_description:
                new_table_description = json_result.get("table", {}).get("new_description")
            assert old_table_name in [
                json_result.get("table", {}).get("old_name"),
                json_result.get("table", {}).get("old_name").replace("_", ""),
            ]
            for column_item in json_result["columns"]:
                if column_item["old_name"] in records:
                    updates.append(
                        {
                            "database": database,
                            "original_table": old_table_name,
                            "original_column": column_item["old_name"],
                            "column_type": records[column_item["old_name"]]["column_type"],
                            "table": new_table_name.replace(" ", "_"),
                            "table_description": new_table_description,
                            "column": column_item["new_name"].replace(" ", "_"),
                            "column_description": column_item["new_description"],
                            "version": version,
                            "llm_model": run_specs["rewrite_llm"],
                        }
                    )
                else:
                    column_item
            if len(updates) != len(chunks):
                updates
            assert len(updates) == len(chunks)
            res = OntologySchemaRewrite.upsert_many(updates)
            if res["errors"]:
                res
            assert not res["errors"]
            return res


def rewrite_db_columns(run_specs):
    from llm_ontology_alignment.data_models.experiment_models import (
        OntologySchemaRewrite,
    )

    databases = OntologySchemaRewrite.objects.distinct("database")
    databases = ["omop", "cprd_gold", "cprd_aurum", "mimic_iii"]
    for database in databases:
        tables = OntologySchemaRewrite.objects(database=database, llm_model="original").distinct("original_table")
        for table_name in tables:
            res = rewrite_table_schema(run_specs, database, table_name)
            print(table_name, res)
