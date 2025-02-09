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


# step 1: given a database schema, identify mergeable tables
class MergableTable(BaseModel):
    primary_table: str = Field(..., description="The primary table to merge")
    merge_candidates: list[str] = Field(
        ..., description="The tables that can be merged with the primary table"
    )


class MergeOpportunities(BaseModel):
    opportunities: list[MergableTable]


class Column(BaseModel):
    column_name: str = Field(..., description="The name of the column")
    column_description: str = Field(..., description="The description of the column")
    original_columns: list[str] = Field(
        ..., description="The original table_name, column_name"
    )


class Table(BaseModel):
    table_name: str = Field(..., description="The name of the merged table")
    table_description: str = Field(
        ..., description="The description of the merged table"
    )
    columns: list[Column]


load_dotenv()

# Initialize the OpenAI client
client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))


# @cache.memoize(timeout=3600)
def merge_tables(database, schema_description, merge_opportunity):
    tables = [merge_opportunity.primary_table] + merge_opportunity.merge_candidates
    tables.sort()
    key = json.dumps(tables)
    result = OntologySchemaMerge.objects(
        database=database,
        merge_candidates=key,
    ).first()
    if result:
        return result.merge_result
    descriptions = {table: schema_description[table] for table in tables}
    response = client.beta.chat.completions.parse(
        model="gpt-4o-mini",
        messages=[
            {
                "role": "system",
                "content": "You are a database design expert. You will be given a few related tables and you need to merge the columns with similar semantics. keep an reference to original columns. For columns not able to merge, copy them to the new table.",
            },
            {"role": "user", "content": json.dumps(descriptions, indent=2)},
            {"role": "system", "content": "Identify columns can be merged."},
        ],
        response_format=Table,
    )
    merged_table = response.choices[0].message.parsed
    merged_table_dump = merged_table.model_dump()
    try:
        OntologySchemaMerge(
            database=database,
            merge_candidates=key,
            merge_result=merged_table_dump,
        ).save()
    except Exception as e:
        raise e
    return merged_table_dump


def identify_mergable_table(database, schema_description):
    response = client.beta.chat.completions.parse(
        model="gpt-4o-mini",
        messages=[
            {
                "role": "system",
                "content": "You are a database design expert. You will be given a database schema and you need to identify the columns with similar semantics that can be merged. Try to de-normalize the schema as much as possible.",
            },
            {"role": "user", "content": json.dumps(schema_description, indent=2)},
        ],
        response_format=MergeOpportunities,
    )
    opportunities = response.choices[0].message.parsed
    result = []
    for opportunity in opportunities.opportunities:
        if len(opportunity.merge_candidates) == 0:
            continue
        res = merge_tables(database, schema_description, opportunity)
        result.append(res)
    return result


def merge_tables_task(database):
    schema_description = OntologySchemaRewrite.get_database_description(
        database, llm_model="original", include_foreign_keys=True
    )
    column_maps = {}
    for table_name, table_description in schema_description.items():
        for column_name, column_description in table_description.items():
            column_maps[f"{table_name}.{column_name}"] = f"{table_name}.{column_name}"
    table_names = identify_mergable_table(database, schema_description)
    return table_names


def get_merged_schema(database, with_orginal_columns=True):
    database = database.split("-merged")[0]
    schema_description = OntologySchemaRewrite.get_database_description(
        database, llm_model="original", include_foreign_keys=True
    )
    merged_schema = {}
    merged_tables = []
    for merge_result in OntologySchemaMerge.objects(database=database):
        original_tables = json.loads(merge_result.merge_candidates)
        merged_tables += original_tables
        original_columns = []
        for table in original_tables:
            for column in schema_description[table]["columns"]:
                original_columns.append(f"{table}.{column}")
        merged_columns = []
        for column in merge_result.merge_result["columns"]:
            for original_column in column["original_columns"]:
                merged_columns.append(original_column)
        table_result = merge_result.merge_result
        for diff in set(original_columns) - set(merged_columns):
            table, column = diff.split(".")
            column_details = schema_description[table]["columns"][column]
            record = {
                "column_name": diff,
                "column_description": column_details["description"],
                "original_columns": [diff],
            }
            table_result["columns"].append(record)
        merged_schema[table_result["table_name"]] = table_result
    for table in set(schema_description.keys()) - set(merged_tables):
        merged_schema[table] = schema_description[table]
    merged_schema = json.loads(json.dumps(merged_schema))
    if not with_orginal_columns:
        for table in merged_schema:
            for column in merged_schema[table]["columns"]:
                column.pop("original_columns")
    return merged_schema


if __name__ == "__main__":
    for database in DATABASES:
        get_merged_schema(database)
