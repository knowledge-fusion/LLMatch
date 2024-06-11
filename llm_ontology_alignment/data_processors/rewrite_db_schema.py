import json

from llm_ontology_alignment.utils import get_embeddings, split_list_into_chunks


def rewrite_db_schema(
    llm, table_name, table_description, columns, runspecs, sub_run_id
):
    assert table_name, "Table name is required"
    assert table_description, "Table description is required"
    sample_input = {
        "table": {
            "old_name": "address",
            "old_description": "the address table contains address information for customers, staff, and stores.",
        },
        "columns": [
            {
                "old_name": "address_id",
                "old_description": "a surrogate primary key used to uniquely identify each address in the table.",
            },
            {
                "old_name": "address",
                "old_description": "the first line of an address",
            },
            {
                "old_name": "address2",
                "old_description": "an optional second line of an address.",
            },
        ],
    }
    sample_output = {
        "table": {
            "old_name": "address",
            "new_name": "customer_address_information",
            "new_description": "The customer address information table contains address details for customers, staff, and stores.",
        },
        "columns": [
            {
                "old_name": "address_id",
                "new_name": "address_identifier",
                "new_description": "A unique identifier used to uniquely identify each address in the table.",
            },
            {
                "old_name": "address",
                "new_name": "address_line_one",
                "new_description": "The first line of an address.",
            },
            {
                "old_name": "address2",
                "new_name": "address_line_two",
                "new_description": "An optional second line of an address.",
            },
        ],
    }

    task_json = {
        "table": {
            "old_name": table_name,
            "old_description": table_description,
        },
        "columns": columns,
    }

    prompt = f"""
    You are given a table as a json list of columns.
    You are tasked to rewrite the table name, column name, table description, column description to make it easier to understand the content stored in the table.
    The new names shouldn't contain any acronyms. Replace acronyms with full form.
    Follow the example to complete the output. Only return one json output without any explaination.\n\n
    Input: \n{json.dumps(sample_input, indent=2)}\n
    Output: \n{json.dumps(sample_output, indent=2)}\n
    Input: \n{json.dumps(task_json, indent=2)}\n
    Output: \n
"""

    from llm_ontology_alignment.services.language_models import complete

    response = complete(
        prompt=prompt,
        model=llm,
        run_specs={
            "operation": "rewrite_db_schema",
            "dataset": runspecs["dataset"],
            "llm": llm,
            "sub_run_id": sub_run_id,
        },
    )
    result = response.json()
    text_result = result["choices"][0]["message"]["content"]
    json_result = result["extra"]["extracted_json"]
    if not json_result:
        print(json_result)
    return json_result


def update_schema(run_specs):
    from llm_ontology_alignment.data_models.experiment_models import (
        OntologyAlignmentData,
        SchemaRewrite,
    )

    source_schema_description, target_schema_description = [], []
    source_column_description, target_column_description = [], []
    version = 6
    for table in OntologyAlignmentData.objects(dataset=run_specs["dataset"]).distinct(
        "table_name"
    ):
        record = OntologyAlignmentData.objects(
            dataset=run_specs["dataset"], table_name=table
        ).first()
        description = f"Table: {table}, Description: {record.extra_data.pop('table_description')}. "
        record.extra_data.pop("matching_index", None)
        matching_role = record.extra_data.pop("matching_role")
        column_description = record.extra_data
        if matching_role == "source":
            source_schema_description.append(description)
            source_column_description.append(column_description)
        else:
            target_schema_description.append(description)
            target_column_description.append(column_description)

    for table_name in OntologyAlignmentData.objects(
        dataset=run_specs["dataset"]
    ).distinct("table_name"):
        if (
            SchemaRewrite.objects(
                dataset=run_specs["dataset"],
                original_table=table_name,
                version=version,
                llm_model=run_specs["rewrite_llm"],
            ).count()
            > 0
        ):
            continue
        records = {}
        old_table_name, old_table_description = "", ""
        for column_item in OntologyAlignmentData.objects(
            dataset=run_specs["dataset"], table_name=table_name
        ):
            column = column_item.extra_data
            if not old_table_description:
                old_table_description = column.pop("table_description", None).replace(
                    "\u00a0", " "
                )
            if not old_table_name:
                old_table_name = column["table"]

            records[column["column"]] = {
                "old_name": column["column"],
                "old_description": column["column_description"].replace("\u00a0", " "),
            }
        if records:
            columns = list(records.values())
            new_table_name, new_table_description, table_embedding = "", "", None
            batches = [columns]
            if len(columns) > 5:
                batches = split_list_into_chunks(columns, chunk_size=5)
            for idx, chunks in enumerate(batches):
                json_result = rewrite_db_schema(
                    llm=run_specs["rewrite_llm"],
                    table_name=old_table_name,
                    table_description=old_table_description,
                    columns=chunks,
                    runspecs=run_specs,
                    sub_run_id=f"{table_name}-{len(columns)}-columns-{idx}",
                )
                updates = []
                if not new_table_name:
                    new_table_name = json_result.get("table", {}).get("new_name")
                if not new_table_description:
                    new_table_description = json_result.get("table", {}).get(
                        "new_description"
                    )
                    table_embedding = get_embeddings(new_table_description)
                assert old_table_name == json_result.get("table", {}).get("old_name")
                for column_item in json_result["columns"]:
                    if column_item["old_name"] in records:
                        updates.append(
                            {
                                "dataset": run_specs["dataset"],
                                "original_table": old_table_name,
                                "original_column": column_item["old_name"],
                                "rewritten_table": new_table_name,
                                "rewritten_table_description": new_table_description,
                                "rewritten_column": column_item["new_name"],
                                "rewritten_column_description": column_item[
                                    "new_description"
                                ],
                                "column_embedding": get_embeddings(
                                    column_item["new_description"]
                                ),
                                "table_embedding": table_embedding,
                                "version": version,
                                "llm_model": run_specs["rewrite_llm"],
                            }
                        )
                res = SchemaRewrite.upsert_many(updates)
                print(res)
