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


load_dotenv()

# Initialize the OpenAI client
client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))


def identify_mergable_table(schema_description):
    response = client.beta.chat.completions.parse(
        model="gpt-4o-mini",
        messages=[
            {
                "role": "system",
                "content": "You are a database design expert. You will be given a database schema and you need to identify the tables that can be merged. Try to de-normalize the schema as much as possible.",
            },
            {"role": "user", "content": json.dumps(schema_description, indent=2)},
        ],
        response_format=MergeOpportunities,
    )
    return response.choices[0].message.parsed


def merge_tables(database):
    schema_description = OntologySchemaRewrite.get_database_description(
        database, llm_model="original", include_foreign_keys=True
    )
    table_names = identify_mergable_table(schema_description)
    return table_names


if __name__ == "__main__":
    for database in DATABASES:
        merge_tables(database)
