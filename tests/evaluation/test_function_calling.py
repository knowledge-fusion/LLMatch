import json

from schema_match.column_match.schema_understanding import (
    tools,
    ask_for_expert_match_result,
)
from schema_match.services.language_models import complete


def test_tools():
    prompt = "Map the columns from the source database to the target database. source_db: bank1, target_db: bank2"
    prompt += "\nsource_table1: account_name, column1\n"
    prompt += "\ntarget_table1: name, column_a\n"
    prompt += "return the mapping as a dictionary"
    prompt += "Some of the mappings do not have rich semantics. You can invoke function call to get expert advice. Invoke function call no more than once."
    messages = [{"role": "user", "content": prompt}]  # Single function call
    model = "gpt-4o-mini"
    response = complete(
        model=model,
        prompt=None,
        run_specs={},
        messages=messages,
        tools=tools,
        tool_choice="auto",
    )
    data = response.json()
    print(response)
    while data["choices"][0]["finish_reason"] == "tool_calls":
        messages.append(data["choices"][0]["message"])
        for tool_call in data["choices"][0]["message"]["tool_calls"]:
            function_name = tool_call["function"]["name"]
            arguments = json.loads(tool_call["function"]["arguments"])
            if function_name == "ask_for_expert_match_result":
                column_match_result = ask_for_expert_match_result(**arguments)
                messages.append(
                    {
                        "tool_call_id": tool_call["id"],
                        "role": "tool",
                        "name": function_name,
                        "content": column_match_result,
                    }
                )
        # messages.append(
        #     {
        #         "role": "user",
        #         "content": "I have received the expert advice. Please continue.",
        #     }
        # )
        final_response = complete(
            model=model,
            prompt=None,
            run_specs={},
            messages=messages,
            tools=tools,
            tool_choice="none",
        )
        data = final_response.json()
        print(data["choices"][0]["message"]["content"])
