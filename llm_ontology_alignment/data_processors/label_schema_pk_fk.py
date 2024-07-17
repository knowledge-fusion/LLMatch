import json
from collections import defaultdict

from llm_ontology_alignment.utils import get_embeddings, cosine_distance

labelled_database = ["imdb", "saki", "cms", "mimic", "mimic_old_dataset"]


def label_schema_primary_foreign_keys():
    from mongoengine import Q

    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite

    rewrite_model = "gpt-4o"

    databases = OntologySchemaRewrite.objects(llm_model=rewrite_model, database__nin=labelled_database).distinct(
        "database"
    )

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
            prompt += f"Database name: {database}"
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
            data
            res1 = OntologySchemaRewrite.objects(
                database=database, table=table, llm_model=rewrite_model, column__in=data["primary_keys"]
            ).update(set__is_primary_key=True)
            res2 = OntologySchemaRewrite.objects(
                database=database, table=table, llm_model=rewrite_model, column__in=data["foreign_keys"]
            ).update(set__is_foreign_key=True)
            print(res1, res2)


def link_foreign_key():
    from mongoengine import Q
    from llm_ontology_alignment.services.language_models import complete
    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite

    llm_model = "gpt-4o"
    databases = OntologySchemaRewrite.objects(
        llm_model=llm_model, is_primary_key=True, database__nin=labelled_database
    ).distinct("database")
    # OntologySchemaRewrite.objects(database__in='omop').update(
    #     unset__linked_table=True, unset__linked_column=True
    # )
    for database in databases:
        table_scores = OntologySchemaRewrite.objects(database=database, llm_model=llm_model).distinct("table")
        # assert each table has one and only one primary key
        selection_options = {}
        table_embeddings = {}
        for table in table_scores:
            if table in ["source_database_metadata"]:
                continue
            queryset = OntologySchemaRewrite.objects(database=database, table=table, llm_model=llm_model)
            if queryset.filter(Q(is_primary_key=True) | Q(is_foreign_key=True)).count() == 0:
                raise ValueError(f"Table {table} in {database} has no primary/foreign keys")
            record = queryset.first()
            selection_options[table] = OntologySchemaRewrite.get_table_columns_description(
                database, table, llm_model=llm_model
            )
            table_embeddings[table] = get_embeddings(record.table + " " + record.table_description)
        for table in table_scores:
            if (
                OntologySchemaRewrite.objects(
                    database=database, table=table, llm_model=llm_model, is_foreign_key=True, linked_table=None
                ).count()
                == 0
                and OntologySchemaRewrite.objects(
                    database=database, table=table, llm_model=llm_model, is_primary_key=True, linked_table=None
                ).count()
                <= 1
            ):
                continue

            column_embeddings = {
                column["name"]: get_embeddings(column["name"] + " " + column["description"])
                for column in selection_options[table]["columns"].values()
                if column.get("is_primary_key") or column.get("is_foreign_key")
            }
            cosine_similarities = defaultdict(dict)
            for column, column_embedding in column_embeddings.items():
                for table_name, table_embedding in table_embeddings.items():
                    if table_name == table:
                        continue
                    cosine_similarities[column][table_name] = cosine_distance(table_embedding, column_embedding)
            prompt_table_options = {}
            linking_candidates = {}
            for column, table_scores in list(cosine_similarities.items()):
                cosine_similarities[column] = dict(sorted(table_scores.items(), key=lambda x: x[1], reverse=True))
                linking_candidates[column] = [
                    table
                    for idx, (table, score) in enumerate(cosine_similarities[column].items())
                    if idx < 3 or score > 0.5 or set(column.split("_")).intersection(set(table.split("_")))
                ]
                for table_candidate in linking_candidates[column]:
                    prompt_table_options[table_candidate] = {
                        "columns": list(selection_options[table_candidate]["columns"].keys()),
                        "primary_keys": [
                            item["name"]
                            for item in selection_options[table_candidate]["columns"].values()
                            if item.get("is_primary_key")
                        ],
                        "table_description": selection_options[table_candidate]["table_description"],
                        "table_name": table_candidate,
                    }
            try:
                prompt = "You are an expert database schema designer. You are tasked to map the primary/foreign keys in the given table: "
                prompt += f"\n\n{json.dumps(selection_options[table], indent=2)}"
                prompt += f"\nLink Target Options: \n{json.dumps(prompt_table_options, indent=2)}"
                prompt += "\nIf no matching found, leave the primary/foreign key empty."
                prompt += "\n only output a json object of the format and no other text {'column_name1': 'selected_table1_name.selected_column1', 'column_name2': 'selected_table2_name.select_column2', ...}"
                data = complete(
                    prompt,
                    "gpt-4o",
                    {
                        "database": database,
                        "table": table,
                        "task": "link_foreign_key",
                    },
                ).json()["extra"]["extracted_json"]
                data
                for column, linked_table in data.items():
                    if linked_table and column in selection_options[table]["columns"]:
                        linked_table, linked_column = linked_table.split(".")
                        if table == linked_table:
                            continue
                        res = OntologySchemaRewrite.objects(
                            database=database, table=table, column=column, llm_model=llm_model
                        ).update(set__linked_table=linked_table, set__linked_column=linked_column)
                        assert res
            except Exception as exp:
                raise exp


def resolve_primary_key():
    from mongoengine import Q
    from llm_ontology_alignment.services.language_models import complete
    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite
    import networkx as nx

    llm_model = "gpt-4o"
    databases = OntologySchemaRewrite.objects(
        llm_model=llm_model, is_primary_key=True, database__nin=labelled_database
    ).distinct("database")
    for database in databases:
        G = nx.MultiDiGraph()
        table_descriptions = {}
        tables = OntologySchemaRewrite.objects(database=database, llm_model=llm_model).distinct("table")
        for table in tables:
            item = OntologySchemaRewrite.objects(database=database, table=table, llm_model=llm_model).first()
            table_descriptions[table] = item.table_description

        for item in OntologySchemaRewrite.objects(database=database, linked_table__ne=None, llm_model=llm_model):
            from_node, to_node = f"{item.table}.{item.column}", f"{item.linked_table}.{item.linked_column}"
            if item.is_primary_key and (not item.is_foreign_key):
                from_node, to_node = to_node, from_node

            G.add_edge(from_node, to_node)

        for connected_component in nx.weakly_connected_components(G):
            tables = [node.split(".")[0] for node in connected_component]
            queries = []
            for node in connected_component:
                queries.append(
                    Q(
                        database=database, table=node.split(".")[0], column=node.split(".")[1], llm_model=llm_model
                    ).to_query(OntologySchemaRewrite)
                )
            queryset = OntologySchemaRewrite.objects(__raw__={"$or": queries})
            if queryset.filter(Q(is_primary_key=True)).count() == 1:
                subgraph = G.subgraph(connected_component)
                out_degrees = subgraph.out_degree()
                root_candidates = [node for node, degree in out_degrees if degree == 0]
                primary_key = root_candidates[0]
                for node in connected_component:
                    if node != primary_key:
                        res = OntologySchemaRewrite.objects(
                            database=database, table=node.split(".")[0], column=node.split(".")[1], llm_model=llm_model
                        ).update(
                            set__is_primary_key=False,
                            set__is_foreign_key=True,
                            set__linked_table=primary_key.split(".")[0],
                            set__linked_column=primary_key.split(".")[1],
                        )
                        assert res
                OntologySchemaRewrite.objects(
                    database=database,
                    llm_model=llm_model,
                    table=primary_key.split(".")[0],
                    column=primary_key.split(".")[1],
                ).update(
                    set__is_primary_key=True,
                    unset__is_foreign_key=True,
                    unset__linked_table=True,
                    unset__linked_column=True,
                )
                continue
            column_descriptions = {f"{item.table}.{item.column}": item.column_description for item in queryset}

            selected_table_description = {table: table_descriptions[table] for table in tables}
            prompt = "You are an expert database schema designer. You are tasked to resolve the primary key/foreign key relationships in the following linked columns."
            prompt += f"\n\nTable Descriptions: {json.dumps(selected_table_description, indent=2)}"
            prompt += f"\n\n Linked Columns: {json.dumps(column_descriptions, indent=2)}"
            prompt += "\n\nPlease provide a json object with the following format."
            prompt += """
            {
                    'primary_key': ''
            }
            """
            prompt += "\n\nReturn only a json object with the mappings with no other text. There should be only one primary key in the connected component."
            response = complete(
                prompt,
                "gpt-4o",
                {
                    "database": database + ",".join(list(connected_component)),
                    "task": "resolve_primary_key",
                },
            )
            data = response.json()["extra"]["extracted_json"]
            primary_key = data.get("primary_key")
            if primary_key:
                for node in connected_component:
                    if node != primary_key:
                        res = OntologySchemaRewrite.objects(
                            database=database, table=node.split(".")[0], column=node.split(".")[1], llm_model=llm_model
                        ).update(
                            set__is_primary_key=False,
                            set__is_foreign_key=True,
                            set__linked_table=primary_key.split(".")[0],
                            set__linked_column=primary_key.split(".")[1],
                        )
                        assert res
                OntologySchemaRewrite.objects(
                    database=database,
                    llm_model=llm_model,
                    table=primary_key.split(".")[0],
                    column=primary_key.split(".")[1],
                ).update(
                    set__is_primary_key=True,
                    unset__is_foreign_key=True,
                    unset__linked_table=True,
                    unset__linked_column=True,
                )


def print_database_constrain_accuracy():
    from mongoengine import Q
    from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite

    databases = OntologySchemaRewrite.objects(llm_model="original", linked_table__ne=None).distinct("database")
    for database in databases:
        print(database)
        for original_primary_key in OntologySchemaRewrite.objects(
            llm_model="original", database=database, is_primary_key=True
        ):
            foreign_keys = OntologySchemaRewrite.objects(
                llm_model="original",
                database=database,
                linked_table=original_primary_key.table,
                linked_column=original_primary_key.column,
            )
            rewritten_primary_key = OntologySchemaRewrite.objects(
                llm_model="gpt-4o",
                database=database,
                original_table=original_primary_key.table,
                original_column=original_primary_key.column,
            ).first()
            queries = []
            for foreign_key in foreign_keys:
                queries.append(
                    (Q(original_table=foreign_key.table) & Q(original_column=foreign_key.column)).to_query(
                        OntologySchemaRewrite
                    )
                )

            ground_truth_foreign_keys = OntologySchemaRewrite.objects(__raw__={"$or": queries}).filter(
                database=database, llm_model="gpt-4o"
            )
            labelled_foreign_keys = OntologySchemaRewrite.objects(
                database=database,
                llm_model="gpt-4o",
                linked_table=rewritten_primary_key.table,
                linked_column=rewritten_primary_key.column,
            )
            ground_truth_foreign_keys = set(f"{item.table}.{item.column}" for item in ground_truth_foreign_keys)
            labelled_foreign_keys = set(f"{item.table}.{item.column}" for item in labelled_foreign_keys)
            print(f"Primary Key: {rewritten_primary_key.table}.{rewritten_primary_key.column}")
            print(f"Ground Truth Foreign Keys: {ground_truth_foreign_keys}")
            print(f"Labelled Foreign Keys: {labelled_foreign_keys}")
            print(
                f"Accuracy: {len(ground_truth_foreign_keys.intersection(labelled_foreign_keys)) / len(ground_truth_foreign_keys)}"
            )
