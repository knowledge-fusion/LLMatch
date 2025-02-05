from dotenv import load_dotenv
from pydantic import BaseModel, Field


class CompanySummaryResponseFormat(BaseModel):
    business_scope: str = Field(
        ...,
        description="Business scope of the company",
    )

    product: str = Field(
        ...,
        description="Product description of the company",
    )
    supply_chain: str = Field(
        ...,
        description="Supply chain information of the company",
    )
    customer_segment: str = Field(
        ...,
        description="Customer segment of the company",
    )


def test_company_summary_response_format():
    from openai import OpenAI
    import os

    load_dotenv()
    client = OpenAI(
        # This is the default and can be omitted
        api_key=os.environ.get("OPENAI_API_KEY", "-")
    )
    schema = CompanySummaryResponseFormat.model_json_schema()
    response_format = {
        "type": "json_schema",
        "json_schema": {
            "name": "generated_data_result",
            "schema": schema,
            "strict": True,
        },
    }
    response_summary = client.beta.chat.completions.parse(
        model="gpt-4o-mini",
        messages=[
            {
                "role": "system",
                "content": "You are an expert business analyst. You are asked to summarize the following company information.",
            },
            {"role": "user", "content": "Apple Inc"},
        ],
        response_format=response_format,
    )
    response_summary
