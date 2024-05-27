def describe_db_column(llm, table):
    prompt = f"""{table}\n\n
    You are given a table as a json list for schema mapping task, give a one line description for each
    column in the table to assist you with the matching task later.
    Return a dictionary with the column names as key and one line summary as value."""

    from litellm import completion

    messages = [{"content": prompt, "role": "user"}]

    response = completion(
        model=llm,
        seed=42,
        temperature=0.5,
        top_p=0.9,
        max_tokens=4096,
        frequency_penalty=0,
        presence_penalty=0,
        messages=messages,
        response_format={"type": "json_object"},
    )

    return response


def load_and_save_schema(dataset, filename, matching_role):
    import json
    import os
    from llm_ontology_alignment.services.vector_db import get_embeddings
    from llm_ontology_alignment.data_models.experiment_models import (
        OntologyAlignmentData,
    )

    # Get the directory of the current script
    script_dir = os.path.dirname(os.path.abspath(__file__))

    # Define the relative path to the CSV file
    file_path = os.path.join(script_dir, "..", "..", "dataset", filename)

    # Open the CSV file and read its contents
    with open(file_path, mode="r", newline="") as file:
        data = json.load(file)

    for table_name, columns in data.items():
        records = []
        for column_name, column in columns.items():
            if (
                OntologyAlignmentData.objects(
                    dataset=dataset,
                    table_name=column["table"],
                    column_name=column["column"],
                ).count()
                > 0
            ):
                continue
            records.append(
                {
                    "table": column["table"],
                    "column": column["column"],
                    "table_description": column["table_description"],
                    "column_description": column["column_description"],
                }
            )
        if records:
            result = describe_db_column("gpt-4o", records)
            text = result.choices[0]["model_extra"]["message"]["content"]
            try:
                json_result = json.loads(text)
                for column_name, llm_description in json_result.items():
                    column = columns[column_name]
                    columns[column_name]["llm_description"] = llm_description

                    column["matching_role"] = matching_role
                    column.pop("id")
                    res = OntologyAlignmentData.upsert(
                        {
                            "dataset": dataset,
                            "table_name": column["table"],
                            "column_name": column["column"],
                            "extra_data": column,
                            "default_embedding": column.pop("embedding"),
                            "llm_summary_embedding": get_embeddings(llm_description),
                        }
                    )
                    res
                    print(res)

            except Exception:
                pass

    # with open(file_path, "w") as file:
    #     file.write(json.dumps(data, indent=2))

    return data
