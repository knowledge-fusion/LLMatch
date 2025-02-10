import json
import os

from dotenv import load_dotenv
from openai import OpenAI
from pydantic import BaseModel, Field

from schema_match.constants import DATABASES
from schema_match.data_models.experiment_models import (
    OntologySchemaRewrite,
    OntologySchemaMerge,
)


class Column(BaseModel):
    column_name: str = Field(..., description="The name of the column")
    column_description: str = Field(..., description="The description of the column")
    original_columns: list[str] = Field(
        ..., description="The original table_name, column_name"
    )


class MergedTable(BaseModel):
    table_name: str = Field(..., description="The name of the merged table")
    table_description: str = Field(
        ..., description="The description of the merged table"
    )
    merged_tables: list[str] = Field(
        ..., description="The original table_names that are merged"
    )
    merged_columns: list[Column]


class MergeResult(BaseModel):
    merged_tables: list[MergedTable]
    unmerged_columns: list[Column]
    system_metadata_columns: list[Column]


class MergeCandidate(BaseModel):
    merge_candidates: list[str]


class MergeOpportunities(BaseModel):
    opportunities: list[MergeCandidate]


load_dotenv()

# Initialize the OpenAI client
client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))


script_dir = os.path.dirname(os.path.abspath(__file__))

file_path = os.path.join(script_dir, "simplify_schema_prompt_step1.md")
with open(file_path) as file:
    step1_prompt_template = file.read()

file_path = os.path.join(script_dir, "simplify_schema_prompt_step2.md")
with open(file_path) as file:
    step2_prompt_template = file.read()


# @cache.memoize(timeout=3600)
def merge_tables(schema_description, table_candidates):
    descriptions = {table: schema_description[table] for table in table_candidates}
    response = client.beta.chat.completions.parse(
        model="gpt-4o-mini",
        messages=[
            {
                "role": "system",
                "content": step2_prompt_template,
            },
            {"role": "user", "content": json.dumps(descriptions, indent=2)},
            {"role": "system", "content": "Identify columns can be merged."},
        ],
        response_format=MergeResult,
    )
    merged_table = response.choices[0].message.parsed
    merged_table_dump = merged_table.model_dump()
    return merged_table_dump


def identify_mergable_table(database, schema_description):
    response = client.beta.chat.completions.parse(
        model="gpt-4o-mini",
        messages=[
            {
                "role": "system",
                "content": step1_prompt_template
                + "\n\n"
                + json.dumps(schema_description, indent=2),
            },
        ],
        response_format=MergeOpportunities,
    )
    data = response.choices[0].message.parsed.model_dump()
    merge_results = []
    for opportunity in data["opportunities"]:
        tables = opportunity["merge_candidates"]
        tables.sort()
        key = ",".join(tables)
        res = merge_tables(schema_description, opportunity["merge_candidates"])

        merge_results[key] = res

    return merge_results


def merge_tables_task(database):
    schema_description = OntologySchemaRewrite.get_database_description(
        database, llm_model="original", include_foreign_keys=True
    )
    record = OntologySchemaMerge.objects(database=database).first()
    if not record:
        result = identify_mergable_table(database, schema_description)
        record = OntologySchemaMerge(database=database, merge_result=result).save()
    return record


def get_merged_schema(database, with_orginal_columns=True):
    database = database.split("-merged")[0]
    schema_description = OntologySchemaRewrite.get_database_description(
        database, llm_model="original", include_foreign_keys=True
    )
    merged_schema = {}
    merged_columns = []
    for merge_result in OntologySchemaMerge.objects(database=database):
        for column in merge_result.merge_result["columns"]:
            merged_columns += column["original_columns"]
        table_result = merge_result.merge_result
        merged_schema[table_result["table_name"]] = table_result
    assert merged_columns
    assert merged_schema
    for table in schema_description:
        for column, column_data in schema_description[table]["columns"].items():
            if f"{table}.{column}" in merged_columns:
                continue
            if table not in merged_schema:
                merged_schema[table] = {
                    "table_name": table,
                    "table_description": schema_description[table]["table_description"],
                    "columns": {},
                }
            merged_schema[table]["columns"][column_data["name"]] = {
                "column_name": f"{column_data['name']}",
                "column_description": column_data["description"],
                "original_columns": [f"{table}.{column_data['name']}"],
            }

    merged_schema = json.loads(json.dumps(merged_schema))
    for table in merged_schema:
        assert table.find(".") == -1
        if isinstance(merged_schema[table]["columns"], list):
            columns_dict = {}
            for column_data in merged_schema[table]["columns"]:
                columns_dict[column_data["column_name"]] = column_data
            merged_schema[table]["columns"] = columns_dict
        for key, val in merged_schema[table]["columns"].items():
            assert key.find(".") == -1
            assert val["column_name"].find(".") == -1
    if not with_orginal_columns:
        for table in merged_schema:
            for column in merged_schema[table]["columns"]:
                merged_schema[table]["columns"][column].pop("original_columns")
    return merged_schema


if __name__ == "__main__":
    for database in DATABASES:
        merge_tables_task(database)
    # for database in DATABASES:
    #     get_merged_schema(database)
