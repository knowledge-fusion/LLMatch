import datetime
from collections import defaultdict

import pandas as pd
import pprint

from schema_match.data_models.experiment_models import OntologySchemaRewrite

pp = pprint.PrettyPrinter(indent=4, sort_dicts=False)


def run_matching(run_specs, table_selections):
    # Load data using pandas
    from schema_match.data_models.experiment_models import (
        OntologyAlignmentExperimentResult,
    )
    from valentine import valentine_match
    from valentine.algorithms import SimilarityFlooding, Cupid, Coma

    print("valentine", run_specs)
    assert run_specs["column_matching_strategy"] in [
        "similarity_flooding",
        "cupid",
        "coma",
    ]

    # Instantiate matcher and run
    assert table_selections, table_selections
    if run_specs["column_matching_strategy"].find("coma") > -1:
        matcher = Coma(java_xmx="2056m")
    elif run_specs["column_matching_strategy"].find("similarity_flooding") > -1:
        matcher = SimilarityFlooding()
    elif run_specs["column_matching_strategy"].find("cupid") > -1:
        matcher = Cupid()
    else:
        raise ValueError(f"Invalid strategy {run_specs['strategy']}")

    if matcher:
        start = datetime.datetime.utcnow()
        mapping_result = defaultdict(list)

        for df1, df2 in get_matching_dfs(
            run_specs, table_selections, single_target_table=False
        ):
            source_table = list({col.split(".")[0] for col in df1.columns})
            target_tables = list({col.split(".")[0] for col in df2.columns})
            print(df1.columns, df2.columns)
            # assert len(source_table) == 1, f"Multiple source tables found {source_table}, {table_selections}"
            operation_specs = {
                "operation": "column_matching",
                "source_table": source_table[0],
                "target_tables": target_tables,
                "column_matching_strategy": run_specs["column_matching_strategy"],
                "source_db": run_specs["source_db"],
                "target_db": run_specs["target_db"],
                "rewrite_llm": run_specs["rewrite_llm"],
            }
            print(f"{df1.columns.size=},{df2.columns.size=}")
            assert df1.columns.size > 0
            assert df2.columns.size > 0
            matches = valentine_match(df1, df2, matcher)
            one_to_one = matches.one_to_one()
            for (source, target), score in one_to_one.items():
                print(f"{source} -> {target} ({score})")
                mapping_result[source[1]].append(target[1])
        end = datetime.datetime.utcnow()
        res = OntologyAlignmentExperimentResult.upsert(
            {
                "operation_specs": operation_specs,
                "dataset": f"{run_specs['source_db']}-{run_specs['target_db']}",
                "json_result": mapping_result,
                "duration": (end - start).total_seconds(),
            }
        )
        assert res


def get_matching_dfs(run_specs, table_selections, single_target_table=False):
    from schema_match.data_models.experiment_models import OntologySchemaRewrite

    source_schema = OntologySchemaRewrite.get_database_description(
        run_specs["source_db"], run_specs["rewrite_llm"]
    )
    target_schema = OntologySchemaRewrite.get_database_description(
        run_specs["target_db"], run_specs["rewrite_llm"]
    )

    dfs = []
    table_selections = None
    if not table_selections:
        source_columns = []
        for table, column_data in source_schema.items():
            for column in column_data["columns"]:
                source_columns.append(f"{table}.{column}")
        target_columns = []
        for table, column_data in target_schema.items():
            for column in column_data["columns"]:
                target_columns.append(f"{table}.{column}")
        df1 = pd.DataFrame([], columns=source_columns)
        df2 = pd.DataFrame([], columns=target_columns)
        dfs = [(df1, df2)]
    else:
        for source_table, targets in table_selections:
            source_columns, target_columns = [], []
            if not targets:
                continue
            source_columns = [
                f"{source_table}.{column}"
                for column in source_schema[source_table]["columns"]
            ]
            for target_table in targets:
                target_columns += [
                    f"{target_table}.{column}"
                    for column in target_schema[target_table]["columns"]
                ]
                if single_target_table:
                    dfs.append(
                        (
                            pd.DataFrame([], columns=source_columns),
                            pd.DataFrame([], columns=target_columns),
                        )
                    )
            if not single_target_table:
                df1 = pd.DataFrame([], columns=source_columns)
                df2 = pd.DataFrame([], columns=target_columns)
                dfs.append((df1, df2))
    return dfs


def get_predictions(run_specs, table_selections):
    from schema_match.data_models.experiment_models import (
        OntologyAlignmentExperimentResult,
    )

    assert run_specs["column_matching_strategy"] in [
        "similarity_flooding",
        "cupid",
        "coma",
    ]

    record = OntologyAlignmentExperimentResult.objects(
        operation_specs__operation="column_matching",
        operation_specs__column_matching_strategy=run_specs["column_matching_strategy"],
        operation_specs__source_db=run_specs["source_db"],
        operation_specs__target_db=run_specs["target_db"],
        operation_specs__rewrite_llm=run_specs["rewrite_llm"],
        dataset=f"{run_specs['source_db']}-{run_specs['target_db']}",
    ).first()
    queryset = OntologySchemaRewrite.objects(
        database__in=[run_specs["source_db"], run_specs["target_db"]],
        llm_model=run_specs["rewrite_llm"],
    )
    assert record
    predictions = defaultdict(list)
    for source, targets in record.json_result.items():
        if source.find(".") == -1:
            continue
        source_entry = queryset.filter(
            table__in=[source.split(".")[0], source.split(".")[0].lower()],
            column__in=[source.split(".")[1], source.split(".")[1].lower()],
        ).first()
        if source_entry.linked_table:
            source_entry = queryset.filter(
                table__in=[
                    source_entry.linked_table,
                    source_entry.linked_table.lower(),
                ],
                column__in=[
                    source_entry.linked_column,
                    source_entry.linked_column.lower(),
                ],
            ).first()
        assert source_entry
        for target in targets:
            if target.find(".") == -1:
                continue
            target_table, target_column = target.split(".")
            target_entry = queryset.filter(
                table__in=[target_table, target_table.lower()],
                column__in=[target_column, target_column.lower()],
            ).first()
            if target_entry.linked_table:
                target_entry = queryset.filter(
                    table__in=[
                        target_entry.linked_table,
                        target_entry.linked_table.lower(),
                    ],
                    column__in=[
                        target_entry.linked_column,
                        target_entry.linked_column.lower(),
                    ],
                ).first()
            assert target_entry
            predictions[f"{source_entry.table}.{source_entry.column}"].append(
                f"{target_entry.table}.{target_entry.column}"
            )
    return predictions, 0
