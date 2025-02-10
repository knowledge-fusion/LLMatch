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


class Table(BaseModel):
    table_name: str = Field(..., description="The name of the merged table")
    table_description: str = Field(
        ..., description="The description of the merged table"
    )
    merged_columns: list[Column]


class MergeResult(BaseModel):
    merged_table: list[Table]
    unmerged_columns: list[Column]
    system_metadata_columns: list[Column]


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
    import os

    script_dir = os.path.dirname(os.path.abspath(__file__))

    file_path = os.path.join(script_dir, "simplify_schema_prompt.md")
    with open(file_path) as file:
        prompt_template = file.read()

    response = client.beta.chat.completions.parse(
        model="gpt-4o-mini",
        messages=[
            {
                "role": "system",
                "content": prompt_template
                + "\n\n"
                + json.dumps(schema_description, indent=2),
            },
        ],
        response_format=MergeResult,
    )
    merge_results = response.choices[0].message.parsed.model_dump()
    OntologySchemaMerge.objects(database=database).delete()
    OntologySchemaMerge(
        database=database,
        merge_result=merge_results,
    ).save()
    return merge_results


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
    merge_tables_task("omop")
    for database in DATABASES:
        get_merged_schema(database)
