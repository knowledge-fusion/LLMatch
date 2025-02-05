import json
import os

from dotenv import load_dotenv
from openai import OpenAI
from pydantic import BaseModel, Field

from schema_match.constants import DATABASES
from schema_match.data_models.experiment_models import OntologySchemaRewrite


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


def merge_tables(schema_description, merge_opportunity):
    tables = [merge_opportunity.primary_table] + merge_opportunity.merge_candidates
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
    return merged_table


def identify_mergable_table(schema_description):
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
    for opportunity in opportunities.opportunities:
        merge_tables(schema_description, opportunity)


def merge_tables_task(database):
    schema_description = OntologySchemaRewrite.get_database_description(
        database, llm_model="original", include_foreign_keys=True
    )
    table_names = identify_mergable_table(schema_description)
    return table_names


if __name__ == "__main__":
    for database in DATABASES:
        merge_tables_task(database)
