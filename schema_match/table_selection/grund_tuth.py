from collections import defaultdict

from schema_match.constants import EXPERIMENTS
from schema_match.data_models.experiment_models import (
    OntologyAlignmentGroundTruth,
    OntologySchemaRewrite,
)


def generate_table_selection_ground_truth_result():
    from schema_match.data_models.experiment_models import OntologySchemaRewrite
    from schema_match.constants import EXPERIMENTS
    from schema_match.data_models.table_selection import OntologyTableSelectionResult

    for experiment in EXPERIMENTS:
        for rewrite_llm in ["gpt-3.5-turbo", "gpt-4o", "original"]:
            source_db, target_db = experiment.split("-")
            res = OntologyTableSelectionResult.objects(
                **{
                    "source_database": source_db,
                    "target_database": target_db,
                    "table_selection_llm": "None",
                    "table_selection_strategy": "ground_truth",
                    "rewrite_llm": rewrite_llm,
                }
            ).first()
            if res:
                continue

            record = OntologyAlignmentGroundTruth.objects(dataset=experiment).first()

            source_query = OntologySchemaRewrite.objects(
                database=source_db, llm_model=rewrite_llm
            )
            target_query = OntologySchemaRewrite.objects(
                database=target_db, llm_model=rewrite_llm
            )
            table_mapping = defaultdict(list)
            for source_table in source_query.distinct("table"):
                table_mapping[source_table] = []
            for source, targets in record.data.items():
                source_table, source_column = source.split(".")
                source_entry = source_query.filter(original_table=source_table).first()
                assert source_entry
                target_tables = target_query.filter(
                    original_table__in=[target.split(".")[0] for target in targets]
                ).distinct("table")
                table_mapping[source_entry.table] += target_tables
            for key, values in list(table_mapping.items()):
                table_mapping[key] = list(set(values))
            res = OntologyTableSelectionResult.upsert(
                {
                    "source_database": source_db,
                    "target_database": target_db,
                    "table_selection_llm": "None",
                    "table_selection_strategy": "ground_truth",
                    "rewrite_llm": rewrite_llm,
                    "data": table_mapping,
                }
            )
            print(table_mapping)
            print(res)


def get_ground_truth_table_selection_result(run_specs):
    from schema_match.data_models.table_selection import OntologyTableSelectionResult

    source_database, target_database = run_specs["source_db"], run_specs["target_db"]
    assert run_specs["table_selection_strategy"] == "ground_truth"
    res = OntologyTableSelectionResult.objects(
        **{
            "table_selection_llm": "None",
            "table_selection_strategy": run_specs["table_selection_strategy"],
            "source_database": source_database,
            "target_database": target_database,
            "rewrite_llm": run_specs["rewrite_llm"],
        }
    ).first()
    assert res
    return res.data, 0


def get_all_to_all_table_selection_result(run_specs, refresh_existing_result=False):
    source_tables = OntologySchemaRewrite.objects(
        database=run_specs["source_db"], llm_model=run_specs["rewrite_llm"]
    ).distinct("table")
    target_tables = OntologySchemaRewrite.objects(
        database=run_specs["target_db"], llm_model=run_specs["rewrite_llm"]
    ).distinct("table")
    return {source_table: list(target_tables) for source_table in source_tables}, 0


if __name__ == "__main__":
    generate_table_selection_ground_truth_result()
    for dataset in EXPERIMENTS:
        source_db, target_db = dataset.split("-")
        run_specs = {
            "source_db": source_db,
            "target_db": target_db,
            "table_selection_strategy": "ground_truth",
            "rewrite_llm": "gpt-3.5-turbo",
        }
        res = get_ground_truth_table_selection_result(run_specs)
        print(res)
