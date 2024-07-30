def export_unicorn_test_data():
    database = "unicorn"
    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite

    template = "[ATT] {{att}} [VAL] {{val}} "
    OntologySchemaRewrite.objects(database=database).distinct("llm_model")
    for llm_model in ["original", "gpt-4o", "gpt-3.5-turbo"]:
        statements = []
        for table in OntologySchemaRewrite.objects(database=database, llm_model=llm_model).distinct("table"):
            columns = OntologySchemaRewrite.objects(database=database, llm_model=llm_model, table=table)
            table_description = columns[0].table_description
            try:
                columns = [
                    {
                        "name": column.column,
                        "type": column.column_type.upper() if column.column_type else "VARCHAR(255)",
                        "comment": column.column_description.replace("'", "'"),
                    }
                    for column in columns
                ]
            except Exception as e:
                raise e
            create_table_statement = generate_create_table_statement(table, table_description, columns)
            statements.append(create_table_statement)

        file_path = os.path.join(script_dir, "..", "..", "dataset/schema_export", f"{database}-{llm_model}.sql")
        with open(file_path, "w") as f:
            f.write("\n\n".join(statements))


if __name__ == "__main__":
    export_unicorn_test_data()
