import json


def label_schema_primary_foreign_keys():
    from mongoengine import Q

    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite

    rewrite_model = "gpt-4o"

    databases = OntologySchemaRewrite.objects(llm_model=rewrite_model).distinct("database")
    # databases = ["imdb", "saki"]
    # OntologySchemaRewrite.objects(llm_model=rewrite_model).update(unset__is_primary_key=True, unset__is_foreign_key=True)
    for database in databases:
        selection_options = {}
        for table in OntologySchemaRewrite.objects(database=database, llm_model=rewrite_model).distinct("table"):
            queryset = OntologySchemaRewrite.objects(database=database, table=table, llm_model=rewrite_model)
            selection_options[table] = {
                "descriptions": queryset.first().table_description,
                "columns": queryset.distinct("column"),
            }

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
    databases = ["imdb", "saki"]
    # OntologySchemaRewrite.objects(database__in=databases).update(unset__linked_table=True, unset__linked_column=True)
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
                    database=database, table=table, llm_model=llm_model, is_foreign_key=True, linked_table__ne=None
                ).count()
                + OntologySchemaRewrite.objects(
                    database=database, table=table, llm_model=llm_model, is_primary_key=True, linked_table__ne=None
                ).count()
                > 0
            ):
                continue
            table_description = OntologySchemaRewrite.get_table_columns_description(
                database, table, llm_model=llm_model
            )
            try:
                prompt = "You are an expert database schema designer. You are tasked to map the primary/foreign keys in the given table: "
                prompt += f"\n\n{json.dumps(table_description, indent=2)}"
                prompt += f"\nLink Target Options: \n{json.dumps(selection_options, indent=2)}"
                prompt += "\nIf no matching found, leave the primary/foreign key empty."
                prompt += "\n only output a json object of the format and no other text {'column_name1': 'selected_table1_name.selected_column1', 'column_name2': 'selected_table2_name.select_column2', ...}"
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
                data
                for column, linked_table in data.items():
                    if linked_table:
                        linked_table, linked_column = linked_table.split(".")
                        res = OntologySchemaRewrite.objects(
                            database=database, table=table, column=column, llm_model=llm_model
                        ).update(set__linked_table=linked_table, set__linked_column=linked_column)
                        assert res
            except Exception as exp:
                print(exp)
