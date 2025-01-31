# load MIMIC 2 data from the dataset
# Path: schema_match/__init__.py
import logging
from dotenv import load_dotenv
import sentry_sdk
from sentry_sdk.integrations.logging import LoggingIntegration
import os


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
    from schema_match.evaluations.ontology_matching_evaluation import (
        table_selection_strategies,
    )

    res = table_selection_strategies()
    print(res)
    return


if __name__ == "__main__":
    main()
