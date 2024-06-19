import json

from llm_ontology_alignment.utils import get_embeddings, split_list_into_chunks


def rewrite_db_schema(llm, table_name, table_description, columns, runspecs, sub_run_id):
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
    Descriptions should be clear and concise, no more than two sentences.
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
            "llm": llm,
            "sub_run_id": sub_run_id,
        },
    )
    result = response.json()

    json_result = result["extra"]["extracted_json"]
    if not json_result:
        text_result = result["choices"][0]["message"]["content"]
        print(text_result)
    return json_result


def rewrite_db_columns(run_specs):
    from llm_ontology_alignment.data_models.experiment_models import (
        OntologyAlignmentOriginalSchema,
        OntologySchemaRewrite,
    )

    version = 0

    for database in OntologyAlignmentOriginalSchema.objects.distinct("database"):
        tables = OntologyAlignmentOriginalSchema.objects(database=database).distinct("table")
        for table_name in tables:
            queryset = OntologyAlignmentOriginalSchema.objects(database=database, table=table_name)
            if (
                OntologySchemaRewrite.objects(
                    database=database,
                    original_table=table_name,
                    version=version,
                    llm_model=run_specs["rewrite_llm"],
                ).count()
                == queryset.count()
            ):
                continue
            records = {}
            old_table_name, old_table_description = "", ""
            for column_item in queryset:
                column = column_item.extra_data
                if not old_table_description:
                    old_table_description = column.pop("table_description", None)
                if not old_table_name:
                    old_table_name = column_item.table

                records[column_item.column] = {
                    "old_name": column_item.column,
                    "old_description": str(column["description"]),
                }
            if records:
                columns = list(records.values())
                new_table_name, new_table_description = "", ""
                batches = [columns]
                if len(columns) > 5 and run_specs["rewrite_llm"].find("gpt") == -1:
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
                        new_table_description = json_result.get("table", {}).get("new_description")
                    assert old_table_name in [
                        json_result.get("table", {}).get("old_name"),
                        json_result.get("table", {}).get("old_name").replace("_", ""),
                    ]
                    for column_item in json_result["columns"]:
                        if column_item["old_name"] in records:
                            updates.append(
                                {
                                    "database": database,
                                    "original_table": old_table_name,
                                    "original_column": column_item["old_name"],
                                    "rewritten_table": new_table_name,
                                    "rewritten_table_description": new_table_description,
                                    "rewritten_column": column_item["new_name"],
                                    "rewritten_column_description": column_item["new_description"],
                                    "version": version,
                                    "llm_model": run_specs["rewrite_llm"],
                                }
                            )
                    res = OntologySchemaRewrite.upsert_many(updates)
                    print(res)


def calculate_alternative_embeddings():
    # copy original names
    from llm_ontology_alignment.data_models.experiment_models import (
        SchemaRewrite,
        SchemaEmbedding,
    )

    # updates = []
    # for item in OntologyAlignmentData.objects():
    #     updates.append({
    #         "dataset": item.dataset,
    #         "llm_model": "original",
    #         "original_table": item.table_name,
    #         "original_column": item.column_name,
    #         "matching_role": item.extra_data["matching_role"],
    #         "rewritten_table": item.table_name,
    #         "rewritten_table_description": item.extra_data.get("table_description", ""),
    #         "rewritten_column": item.column_name,
    #         "rewritten_column_description": item.extra_data.get("column_description", ""),
    #     })
    # res = SchemaRewrite.upsert_many(updates)
    embedding_strategies = [
        ["rewritten_column"],
        ["rewritten_column_description"],
        ["rewritten_table"],
        ["rewritten_table_description"],
        ["rewritten_column", "rewritten_column_description"],
        ["rewritten_table", "rewritten_table_description"],
        ["rewritten_table", "rewritten_column"],
        ["rewritten_table_description", "rewritten_column_description"],
        ["rewritten_column", "rewritten_column_description", "rewritten_table"],
        ["rewritten_column", "rewritten_column_description", "rewritten_table_description"],
        ["rewritten_column", "rewritten_column_description", "rewritten_table", "rewritten_table_description"],
    ]
    version = 7
    for item in list(SchemaRewrite.objects(version__ne=version)):
        print(item)
        embedding_count = SchemaEmbedding.objects(
            dataset=item.dataset, llm_model=item.llm_model, table=item.original_table, column=item.original_column
        ).count()
        if embedding_count == len(embedding_strategies):
            if item.version != version:
                item.version = version
                item.save()
            continue
        updates = []
        for columns in embedding_strategies:
            columns.sort()
            embedding_text = " | ".join([str(item[column]) for column in columns])
            updates.append(
                {
                    "dataset": item.dataset,
                    "llm_model": item.llm_model,
                    "table": item.original_table,
                    "column": item.original_column,
                    "embedding_text": embedding_text,
                    "embedding": get_embeddings(embedding_text),
                    "matching_role": item.matching_role,
                    "embedding_strategy": ",".join(columns),
                    "version": 1,
                }
            )
        res = SchemaEmbedding.upsert_many(updates)
        item.version = version
        item.save()
        print(res)
