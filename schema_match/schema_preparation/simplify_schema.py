import json
import os

from dotenv import load_dotenv
from openai.lib._parsing import type_to_response_format_param
from pydantic import BaseModel

from schema_match.constants import DATABASES
from schema_match.data_models.experiment_models import (
    OntologySchemaRewrite,
    OntologySchemaMerge,
)
from schema_match.services.language_models import complete

load_dotenv()


script_dir = os.path.dirname(os.path.abspath(__file__))


# @cache.memoize(timeout=3600)
def merge_tables(schema_description):
    class MergedColumn(BaseModel):
        column_name: str
        column_description: str
        original_columns: list[str]

    class MergedTable(BaseModel):
        new_table_name: str
        tables_merged: list[str]
        reason_for_merging: str
        new_table_columns: list[MergedColumn]

    class MergedTablesResponse(BaseModel):
        merged_tables: list[MergedTable]

    file_path = os.path.join(script_dir, "simplify_schema_prompt_merge_tables.md")
    with open(file_path) as file:
        merge_table_prompt = file.read()
    prompt = (
        merge_table_prompt + "\n\n Input: " + json.dumps(schema_description, indent=2)
    )
    response = complete(
        run_specs={},
        prompt=prompt,
        model="gpt-4o-mini",
        response_format=type_to_response_format_param(MergedTablesResponse),
    )
    result = response.json()
    text = result["choices"][0]["message"]["content"]
    model = MergedTablesResponse.model_validate_json(text)
    return model


def merge_columns(database, schema_description):
    class MergedColumn(BaseModel):
        column_name: str
        column_description: str
        original_columns: list[str]

    class TableSchema(BaseModel):
        table_name: str
        merged_columns: list[MergedColumn]

    class MergeSameTableColumnResponse(BaseModel):
        tables: list[TableSchema]

    file_path = os.path.join(script_dir, "simplify_schema_prompt_merge_columns.md")
    with open(file_path) as file:
        merge_column_prompt = file.read()
    prompt = (
        merge_column_prompt + "\n\n Input: " + json.dumps(schema_description, indent=2)
    )
    response = complete(
        run_specs={},
        prompt=prompt,
        model="gpt-4o-mini",
        response_format=type_to_response_format_param(MergeSameTableColumnResponse),
    )
    result = response.json()
    text = result["choices"][0]["message"]["content"]
    model = MergeSameTableColumnResponse.model_validate_json(text)
    data = model.model_dump()
    return data


def rename_columns(database, schema_description):
    class RenamedColumn(BaseModel):
        table_name: str
        old_column_name: str
        new_column_name: str
        reason_for_renaming: str

    class RenamedColumnsResponse(BaseModel):
        renamed_columns: list[RenamedColumn]

    file_path = os.path.join(script_dir, "simplify_schema_prompt_rename_columns.md")
    with open(file_path) as file:
        rename_column_prompt = file.read()
    prompt = (
        rename_column_prompt + "\n\n Input: " + json.dumps(schema_description, indent=2)
    )
    response = complete(
        run_specs={},
        prompt=prompt,
        model="gpt-4o-mini",
        response_format=type_to_response_format_param(RenamedColumnsResponse),
    )
    result = response.json()
    text = result["choices"][0]["message"]["content"]
    model = RenamedColumnsResponse.model_validate_json(text)
    data = model.model_dump()
    return data


def update_rename_columns(schema_description, column_rename_result):
    for table, table_data in schema_description.items():
        for rename_result in column_rename_result["renamed_columns"]:
            old_column_data = table_data["columns"].pop(
                rename_result["old_column_name"], None
            )
            table_data["columns"][rename_result["new_column_name"]] = {
                "name": rename_result["new_column_name"],
                "description": old_column_data["description"],
            }

    return schema_description


def update_merge_columns(schema_description, column_merge_result):
    for table, table_data in schema_description.items():
        for column in table_data["columns"]:
            for merge_table in column_merge_result["tables"]:
                for merge_item in merge_table["merged_columns"]:
                    if merge_item["column_name"] == column:
                        table_data["columns"][column] = {
                            "column_name": column,
                            "column_description": merge_item["column_description"],
                            "original_columns": merge_item["original_columns"],
                        }
                        for original_column in merge_item["original_columns"]:
                            original_table, original_column_name = (
                                original_column.split(".")
                            )
                            schema_description[original_table]["columns"].pop(
                                original_column_name, None
                            )
    return schema_description


def merge_tables_task(database):
    schema_description = OntologySchemaRewrite.get_database_description(
        database, llm_model="original", include_foreign_keys=False
    )
    for table, table_data in schema_description.items():
        table_schema = {table: table_data}
        record = OntologySchemaMerge.objects(database=database, table=table).first()
        if not record:
            record = OntologySchemaMerge(database=database, table=table)
        if not record.rename_result:
            record.rename_result = rename_columns(database, table_schema)
        table_schema = update_rename_columns(table_schema, record.rename_result)
        if not record.merge_result:
            record.merge_result = merge_columns(database, table_schema)
        table_schema = update_merge_columns(table_schema, record.merge_result)
        schema_description[table] = table_schema[table]
        record.save()
    merge_tables_result = merge_tables(schema_description)
    return record


def get_merged_schema(database, with_orginal_columns=True):
    database = database.split("-merged")[0]
    schema_description = OntologySchemaRewrite.get_database_description(
        database, llm_model="original", include_foreign_keys=True
    )
    merged_schema = {}
    merged_columns = []
    system_metadata_columns = []
    for item in OntologySchemaMerge.objects(database=database):
        table_name = item.table
        table_data = schema_description[table_name]
        original_column_mapping = {}
        for rename_result in item.rename_result["renamed_columns"]:
            table_data["columns"][rename_result["new_column_name"]] = table_data[
                "columns"
            ].pop(rename_result["old_column_name"])
            original_column_mapping[rename_result["new_column_name"]] = rename_result[
                "old_column_name"
            ]
        for merge_table in item.merge_result["tables"]:
            for merge_item in merge_table["merged_columns"]:
                column_description = merge_item["column_description"]
                column_name = merge_item["column_name"]
                original_columns = merge_item["original_columns"]
                schema_description[table_name]["columns"][column_name] = {
                    "column_name": column_name,
                    "column_description": column_description,
                    "original_columns": original_columns,
                }
                for original_column in original_columns:
                    original_table, original_column_name = original_column.split(".")
                    schema_description[original_table]["columns"].pop(
                        original_column_name, None
                    )

    if not with_orginal_columns:
        for table in merged_schema:
            for column in merged_schema[table]["columns"]:
                schema_description[table]["columns"][column].pop(
                    "original_columns", None
                )
    return schema_description


if __name__ == "__main__":
    for database in DATABASES[0:2]:
        print("\n")
        print(database)

        merge_tables_task(database)
        get_merged_schema(database)
