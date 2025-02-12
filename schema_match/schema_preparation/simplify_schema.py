import json
import os

from dotenv import load_dotenv
from openai.lib._parsing import type_to_response_format_param
from pydantic import BaseModel, Field

from schema_match.constants import DATABASES
from schema_match.data_models.experiment_models import (
    OntologySchemaRewrite,
    OntologySchemaMerge,
)
from schema_match.services.language_models import complete


class Column(BaseModel):
    column_name: str = Field(..., description="The name of the column")
    column_description: str = Field(..., description="The description of the column")
    original_columns: list[str] = Field(
        ..., description="The original table_name.column_name"
    )


class GroupedTable(BaseModel):
    table_name: str = Field(..., description="The name of the merged table")
    table_description: str = Field(
        ..., description="The description of the merged table"
    )
    merged_tables: list[str] = Field(
        ..., description="The original table_names that are merged"
    )
    merged_columns: list[Column]
    unmerged_columns: list[str]
    system_metadata_columns: list[str]


class GroupResult(BaseModel):
    tables: list[GroupedTable]


class GroupCandidate(BaseModel):
    group_candidates: list[str]


class GroupOpportunities(BaseModel):
    opportunities: list[GroupCandidate]


load_dotenv()


script_dir = os.path.dirname(os.path.abspath(__file__))

file_path = os.path.join(script_dir, "simplify_schema_prompt_merge_columns.md")
with open(file_path) as file:
    merge_column_prompt = file.read()

file_path = os.path.join(script_dir, "simplify_schema_prompt_rename_columns.md")
with open(file_path) as file:
    rename_column_prompt = file.read()

file_path = os.path.join(script_dir, "simplify_schema_prompt_step2.md")
with open(file_path) as file:
    step2_prompt_template = file.read()


# @cache.memoize(timeout=3600)
def merge_tables(schema_description, candidates):
    table_candidates = [item.split(".")[0] for item in candidates]
    descriptions = {table: schema_description[table] for table in table_candidates}
    response = complete(
        run_specs={},
        model="gpt-4o-mini",
        prompt=step2_prompt_template + "\n\n" + json.dumps(descriptions, indent=2),
        response_format=type_to_response_format_param(GroupResult),
    )
    result = response.json()
    text = result["choices"][0]["message"]["content"]
    model = GroupResult.model_validate_json(text)
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


def merge_tables_task(database):
    schema_description = OntologySchemaRewrite.get_database_description(
        database, llm_model="original", include_foreign_keys=False
    )
    for table, table_data in schema_description.items():
        record = OntologySchemaMerge.objects(database=database, table=table).first()
        if not record:
            rename_result = rename_columns(database, {table: table_data})
            original_column_mapping = {}
            for item in rename_result["renamed_columns"]:
                table_data["columns"][item["new_column_name"]] = table_data[
                    "columns"
                ].pop(item["old_column_name"])
                original_column_mapping[item["new_column_name"]] = item[
                    "old_column_name"
                ]
            merge_result = merge_columns(database, {table: table_data})
            print(json.dumps(rename_result, indent=2))
            print(json.dumps(merge_result, indent=2))
            record = OntologySchemaMerge(
                database=database,
                table=table,
                merge_result=merge_result,
                rename_result=rename_result,
            ).save()
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
                merged_schema[table]["columns"][column].pop("original_columns")
    return merged_schema


if __name__ == "__main__":
    for database in DATABASES[0:2]:
        print("\n")
        print(database)

        merge_tables_task(database)
        get_merged_schema(database)
