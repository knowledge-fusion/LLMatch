# load MIMIC 2 data from the dataset
# Path: schema_match/__init__.py
import logging
from dotenv import load_dotenv
import sentry_sdk
from sentry_sdk.integrations.logging import LoggingIntegration
import os

from schema_match.constants import EXPERIMENTS

logger = logging.getLogger(__name__)


load_dotenv()

sentry_logging = LoggingIntegration(
    level=logging.INFO,  # Capture info and above as breadcrumbs
    event_level=logging.ERROR,  # Send errors as events
)
# formatter = SlackFormatter.default(
#     config=FormatConfig(service="news_crawler", environment="dev")
# )  # plain message, no decorations
# handler = SlackHandler.from_webhook(os.environ["SLACK_NOTIFICATION_URL"])
# handler.setFormatter(formatter)
# handler.setLevel(logging.WARN)
# logger.addHandler(handler)

sentry_sdk.init(
    dsn=os.getenv("SENTRY_DSN"),
    integrations=[
        sentry_logging,
    ],
)


def load_sql_schema_example():
    from schema_match.schema_preparation.load_data import load_sql_schema
    from schema_match.schema_preparation.load_data import load_schema_constraint_sql
    from schema_match.schema_preparation.load_data import export_sql_statements

    for database in ["bank1", "bank2"]:
        load_sql_schema(database)
        load_schema_constraint_sql(database)
        export_sql_statements(database)


def main():
    llm = "gpt-4o-mini"
    for experiment in EXPERIMENTS[0:1]:
        source_db, target_db = experiment.split("-")
        run_specs = {
            "source_db": source_db,
            "target_db": target_db,
            "rewrite_llm": "original",
            "table_selection_strategy": "llm",
            "table_selection_llm": llm,
            "column_matching_strategy": "llm-human_in_the_loop",
            "column_matching_llm": llm,
            # "context_size": context_size,
        }
        from schema_match.evaluations.calculate_result import table_selection_func_map

        table_selections = table_selection_func_map[
            run_specs["table_selection_strategy"]
        ](run_specs)
        from schema_match.evaluations.calculate_result import (
            run_schema_matching_evaluation,
        )

        run_schema_matching_evaluation(run_specs, refresh_existing_result=False)

        # table_selection_result = print_table_mapping_result(run_specs)
        print(f" {run_specs=} {run_specs['source_db']}-{run_specs['target_db']}")
    return


if __name__ == "__main__":
    main()
