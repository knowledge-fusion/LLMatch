import json
import os
from collections import defaultdict

from dotenv import load_dotenv
from openai.lib._parsing import type_to_response_format_param
from pydantic import BaseModel

from schema_match.constants import DATABASES
from schema_match.data_models.experiment_models import (
    OntologySchemaRewrite,
    OntologySchemaMerge,
    OntologySchemaTableMerge,
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
        new_table_description: str
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
    data = model.model_dump()
    merged_tables = []
    for table in data["merged_tables"]:
        original_columns = []
        for column in table["new_table_columns"]:
            for original_column in column["original_columns"]:
                original_table, original_column_name = original_column.split(".")
                assert schema_description[original_table]["columns"][
                    original_column_name
                ]
                original_columns.append(original_column)
        for table_name in table["tables_merged"]:
            assert table_name not in merged_tables
            merged_tables.append(table_name)
            for column, column_data in schema_description[table_name][
                "columns"
            ].items():
                if f"{table_name}.{column}" not in original_columns:
                    table["new_table_columns"].append(
                        {
                            "column_name": column,
                            "column_description": column_data["description"],
                            "original_columns": [f"{table_name}.{column}"],
                        }
                    )
    return data


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
    for table in data["tables"]:
        for column in table["merged_columns"]:
            for original_column in column["original_columns"]:
                original_table, original_column_name = original_column.split(".")
                assert schema_description[original_table]["columns"][
                    original_column_name
                ]
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
    for item in data["renamed_columns"]:
        assert schema_description[item["table_name"]]["columns"][
            item["old_column_name"]
        ]
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


def get_column_rename_mapping(database):
    table_merge_result = (
        OntologySchemaTableMerge.objects(database=database)
        .first()
        .merge_result["merged_tables"]
    )
    original_schema_description = OntologySchemaRewrite.get_database_description(
        database, llm_model="original", include_foreign_keys=True
    )
    column_merge_mapping = defaultdict(set)
    rename_mapping = {}
    for record in OntologySchemaMerge.objects(database=database):
        for table in record.merge_result.get("tables", []):
            for column in table["merged_columns"]:
                column_merge_mapping[f"{record.table}.{column['column_name']}"] = set(
                    column["original_columns"]
                )
        for table in record.rename_result.get("renamed_columns", []):
            rename_mapping[f"{record.table}.{table['new_column_name']}"] = (
                f"{record.table}.{table['old_column_name']}"
            )

    original_columns_mapping = defaultdict(set)
    for table_data in table_merge_result:
        new_table_name = table_data["new_table_name"]
        for column_data in table_data["new_table_columns"]:
            for merged_column in column_data["original_columns"]:
                if merged_column in column_merge_mapping:
                    for unmerged_column in column_merge_mapping[merged_column]:
                        original_columns_mapping[
                            f"{new_table_name}.{column_data['column_name']}"
                        ].add(unmerged_column)
                else:
                    original_columns_mapping[
                        f"{new_table_name}.{column_data['column_name']}"
                    ].add(merged_column)

    result = defaultdict(dict)
    for key, column_names in original_columns_mapping.items():
        for column_name in column_names:
            original_table, original_column_name = rename_mapping.get(
                column_name, column_name
            ).split(".")
            data = original_schema_description[original_table]["columns"][
                original_column_name
            ]
            data["table_name"] = original_table
            data["table_description"] = original_schema_description[original_table][
                "table_description"
            ]
            result[key][column_name] = data

    schema_detail = get_merged_schema(database, with_orginal_columns=True)
    for table in schema_detail:
        for column in schema_detail[table]["columns"]:
            if f"{table}.{column}" not in result:
                data = schema_detail[table]["columns"][column]
                data["table_name"] = table
                data["table_description"] = schema_detail[table]["table_description"]
                result[f"{table}.{column}"] = {f"{table}.{column}": data}
    return result


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


def update_merge_tables(schema_description, merge_result):
    for merge_table in merge_result["merged_tables"]:
        new_table_name = merge_table["new_table_name"]
        new_table_columns = merge_table["new_table_columns"]
        for table in merge_table["tables_merged"]:
            schema_description.pop(table, None)
        schema_description[new_table_name] = {
            "table_name": new_table_name,
            "table_description": merge_table["new_table_description"],
            "columns": {
                column["column_name"]: {
                    "column_name": column["column_name"],
                    "column_description": column["column_description"],
                    "original_columns": column["original_columns"],
                }
                for column in new_table_columns
            },
        }
    return schema_description


def preprocess_schema_task(database):
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
    merge_table_record = OntologySchemaTableMerge.objects(database=database).first()
    if not merge_table_record:
        merge_tables_result = merge_tables(schema_description)
        merge_table_record = OntologySchemaTableMerge(
            database=database, merge_result=merge_tables_result
        )
        merge_table_record.save()
    schema_description = update_merge_tables(
        schema_description, merge_table_record.merge_result
    )
    return schema_description


def get_merged_schema(database, with_orginal_columns=True):
    database = database.split("-merged")[0]
    schema_description = preprocess_schema_task(database)
    if not with_orginal_columns:
        for table in schema_description:
            for column in schema_description[table]["columns"]:
                schema_description[table]["columns"][column].pop(
                    "original_columns", None
                )
    return schema_description


if __name__ == "__main__":
    for database in DATABASES[0:2]:
        print("\n")
        print(database)

        preprocess_schema_task(database)
        get_column_rename_mapping(database)

        get_merged_schema(database)
