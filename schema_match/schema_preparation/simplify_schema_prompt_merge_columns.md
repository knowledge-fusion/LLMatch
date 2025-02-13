Task: Database Schema Pre-Processing for Data Migration

Objective:
You will be provided with a database schema in JSON format. Your goal is to identify columns within the same table that hold related or similar data (e.g., first_name and last_name belong together). Then, merge these related columns into a single column in your output.

Steps:
	1.	Read the Input JSON Schema
	•	Understand the structure of each table.
	•	Look for columns in the same table that are similar or can be combined logically.
	2.	Identify Mergable Columns
	•	If two or more columns represent “parts of a whole” (like first and last name, or address1 and address2), these can be merged.
	•	If the columns are not logically related, do not merge them.
    •	If two columns represent the same data but are named differently, they can be merged. e.g. table.address, table.address_id
	3.	Create a Merged Output
	•	For each table with identified merges, create an entry in a JSON array named "merged_columns".
	•	Inside each entry, show:
	•	table_name: The name of the table.
	•	merged_columns: An array of merged column definitions, each of which must include:
	1.	column_name: The new merged name.
	2.	column_description: A short explanation of why or how these columns are merged.
	3.	original_columns: A list of the fully qualified column references (e.g., "customer.first_name", "customer.last_name").
	4.	Output Format
	•	Your final output must be valid JSON.
	•	Use the following structure (with any necessary merges included):

{
  "merged_columns": [
    {
      "table_name": "<TABLE_NAME>",
      "merged_columns": [
        {
          "column_name": "<MERGED_COLUMN_NAME>",
          "column_description": "<WHY_MERGED>",
          "original_columns": [
            "<table.columnA>",
            "<table.columnB>"
          ]
        }
      ]
    }
  ]
}



Important:
	•	Only list tables that actually have merged columns.
	•	If a table has no columns that need merging, skip it.
	•	Do not delete or rename any columns unless they are part of a merged set.

Sample Input

(The JSON schema from your database might be large, so here is a short version showing two tables as an example.)

{
  "actor": {
    "table": "actor",
    "columns": {
      "actor_id": {
        "name": "actor_id",
        "description": "Primary key"
      },
      "first_name": {
        "name": "first_name",
        "description": "Actor first name"
      },
      "last_name": {
        "name": "last_name",
        "description": "Actor last name"
      }
    }
  },
  "customer": {
    "table": "customer",
    "columns": {
      "customer_id": {
        "name": "customer_id",
        "description": "Primary key"
      },
      "first_name": {
        "name": "first_name",
        "description": "Customer first name"
      },
      "last_name": {
        "name": "last_name",
        "description": "Customer last name"
      }
    }
  }
}

Sample Output

Here is the kind of JSON output we expect after identifying mergable columns. Notice how first_name and last_name have been combined into one column called name. Adjust the language/description to fit your needs:

{
  "tables": [
    {
      "table_name": "actor",
      "merged_columns": [
        {
          "column_name": "name",
          "column_description": "Actor's full name (merged from first_name and last_name)",
          "original_columns": [
            "actor.first_name",
            "actor.last_name"
          ]
        }
      ]
    },
    {
      "table_name": "customer",
      "merged_columns": [
        {
          "column_name": "name",
          "column_description": "Customer's full name (merged from first_name and last_name)",
          "original_columns": [
            "customer.first_name",
            "customer.last_name"
          ]
        }
      ]
    }
  ]
}

Input: