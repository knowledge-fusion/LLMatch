# Schema Matching Program - README

## What is this repository for?

This repository provides a schema matching solution for data integration tasks. It includes components for schema preparation, table selection, and column matching. Users can configure and plug in different tools for each component.

- **Version**: 1.0.0
- **Documentation**: Follow this README to set up and run the program.

---

## How do I get set up?

### Prerequisites

Ensure the following dependencies are installed on your system:
- **Python**: 3.8 or higher
- **pipenv**: Latest version
- **MongoDB**: For storing schema and matching results

Install required Python libraries:
```bash
git clone <repository_url>
cd <repository_directory>
pipenv install --dev
```
### Configuration

Copy `.env.example` to `.env`. Update the .env file with:
- Database URI
- Embedding Service URL
- Chat Service URL

### Running the program
####	Schema Preparation:
Ensure the source and target schemas are uploaded as `database.sql`, `database-comment.sql`, `database-constrainsts.sql` files in the data/original_schema_files folder.

Running the function to load the schema:

```python
def load_sql_schema_example():
    from schema_match.schema_preparation.load_data import load_sql_schema
    from schema_match.schema_preparation.load_data import load_schema_constraint_sql
    from schema_match.schema_preparation.load_data import export_sql_statements

    for database in ["bank1", "bank2"]:
        load_sql_schema(database)
        load_schema_constraint_sql(database)
        export_sql_statements(database)
```

#### Table Selection:

Once source and target schema are loaded. Run following function to select tables:
```python
# file in schema_match/table_selection/llm_selection.py
    table_selection_strategy = "llm"
    for experiment in EXPERIMENTS:
        source, target = experiment.split("-")
        run_specs = {
            "column_matching_llm": "gpt-4o-mini",
            "column_matching_strategy": "llm",
            "rewrite_llm": "original",
            "source_db": source,
            "table_selection_llm": "gpt-4o-mini",
            "table_selection_strategy": table_selection_strategy,
            "target_db": target,
        }
        res, tokens = get_llm_table_selection_result(run_specs, refresh_existing_result=False)
        print(res, tokens)
```


#### Column Matching:
```python
    run_specs = {
        "source_db": "cprd_aurum",
        "target_db": "omop",
        "matching_llm": "gpt-3.5-turbo",
        "rewrite_llm": "original",
        "strategy": "schema_understanding",
    }

    run_specs = {key: run_specs[key] for key in sorted(run_specs.keys())}
    from schema_match.column_match.schema_understanding import run_matching

    run_matching(run_specs)
```

#### End-to-End Pipeline:

```python
    run_specs = {
        "source_db": "imdb",
        "target_db": "sakila",
        "rewrite_llm": "original",
        "table_selection_strategy": "llm",
        "table_selection_llm": "gpt-4o-mini",
        "column_matching_strategy": "llm",
        "column_matching_llm": "gpt-4o-mini",
    }

    res = run_schema_matching_evaluation(run_specs)
    print(res.f1_score)
```


#### Contribution Guidelines

1. **Writing Tests**:
   - Add unit tests for every new module in the `tests/` directory.
   - Follow the pytest style.

2. **Code Review**:
   - Open a pull request for every feature or bug fix.
   - Ensure code is reviewed by at least one other contributor.

3. **Other Guidelines**:
   - Follow the PEP 8 style guide for Python code.
   - Document every function with docstrings.
