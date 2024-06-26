import json


def label_schema_primary_foreign_keys():
    from mongoengine import Q

    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite

    rewrite_model = "gpt-4o"

    databases = OntologySchemaRewrite.objects(llm_model=rewrite_model).distinct("database")
    for database in databases:
        for table in OntologySchemaRewrite.objects(database=database, llm_model=rewrite_model).distinct("table"):
            if (
                OntologySchemaRewrite.objects(
                    Q(database=database)
                    & Q(table=table)
                    & Q(llm_model=rewrite_model)
                    & (Q(is_primary_key=True) | Q(is_foreign_key=True))
                ).count()
                > 0
            ):
                continue
            table_description = OntologySchemaRewrite.get_table_columns_description(
                database=database, table=table, llm_model=rewrite_model
            )

            prompt = "You are an expert database schema designer."
            prompt += "You are given a database schema with the following table and column descriptions."
            prompt += f"Databse name: {database}"
            prompt += f"\n\n{json.dumps(table_description, indent=2)}"
            prompt += "\n\nYou are asked to label the primary and foreign keys in the schema."
            prompt += "A primary key is a column that uniquely identifies each row in a table."
            prompt += "Normally, a table has only one primary key."
            prompt += "A foreign key is a column that references a primary key in another table."
            prompt += "\n\nPlease provide a json object with the following format."
            prompt += """
            {
                    'primary_keys': ['column1', 'column2', ...],
                    'foreign_keys': ['column3', 'column4', ...],
            }
            """
            prompt += "\n\nReturn only a json object with the mappings with no other text."
            from llm_ontology_alignment.services.language_models import complete

            response = complete(
                prompt,
                "gpt-4o",
                run_specs={"operation": "label_schema_primary_foreign_keys", "database": database, "table": table},
            )
            response = response.json()
            data = response["extra"]["extracted_json"]
            if data.get("primary_keys"):
                res1 = OntologySchemaRewrite.objects(
                    database=database, table=table, llm_model=rewrite_model, column__in=data["primary_keys"]
                ).update(set__is_primary_key=True)
            if data.get("foreign_keys"):
                res2 = OntologySchemaRewrite.objects(
                    database=database, table=table, llm_model=rewrite_model, column__in=data["foreign_keys"]
                ).update(set__is_foreign_key=True)


def link_foreign_key():
    from mongoengine import Q
    from llm_ontology_alignment.services.language_models import complete
    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite

    llm_model = "gpt-4o"
    databases = OntologySchemaRewrite.objects(llm_model=llm_model, is_primary_key=True).distinct("database")
    for database in databases:
        table_names = OntologySchemaRewrite.objects(database=database, llm_model=llm_model).distinct("table")
        # assert each table has one and only one primary key
        selection_options = {}
        for table in table_names:
            queryset = OntologySchemaRewrite.objects(database=database, table=table, llm_model=llm_model)
            if queryset.filter(Q(is_primary_key=True) | Q(is_foreign_key=True)).count() == 0:
                raise ValueError(f"Table {table} in {database} has no primary/foreign keys")

            selection_options[table] = {
                "descriptions": queryset.first().table_description,
                "columns": queryset.distinct("column"),
            }
        for table in table_names:
            if (
                OntologySchemaRewrite.objects(
                    database=database, table=table, llm_model=llm_model, is_foreign_key=True, linked_table=None
                ).count()
                == 0
            ):
                continue
            table_description = OntologySchemaRewrite.get_table_columns_description(
                database, table, llm_model=llm_model
            )
            try:
                prompt = "You are an expert database schema designer. You arer tasked to select the table that the foreign key references"
                prompt += f"\n\nTable to link: \n\n{json.dumps(table_description, indent=2)}"
                prompt += f"\nForeign Key Link Options: \n{json.dumps(selection_options, indent=2)}"
                prompt += "\n If no matching found, leave the foreign key empty."
                prompt += "\n only output a json object of the format and no other text {'foreign_key_column_name1': 'selected_table1_name', 'foreign_key_column_name2': 'selected_table2_name', ...}"
                response = complete(
                    prompt,
                    "gpt-4o",
                    {
                        "database": database,
                        "table": table,
                        "task": "link_foreign_key",
                    },
                )
                data = response.json()["extra"]["extracted_json"]
                for column, linked_table in data.items():
                    if linked_table:
                        res = OntologySchemaRewrite.objects(database=database, table=table, column=column).update(
                            set__linked_table=linked_table
                        )
                        assert res
            except Exception as exp:
                print(exp)
