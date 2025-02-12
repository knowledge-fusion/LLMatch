Task: Rename Ambiguous Columns in a Database Schema

Context & Objective

You have been given a database schema in JSON format (see “Input Schema”). Your goal is to find columns with ambiguous names—names that could be interpreted in multiple ways or do not convey their meaning clearly—and rename them to something more descriptive. For example, a column named rating might be changed to parental_rating or review_rating, depending on its purpose.

Instructions
	1.	Read the Input JSON Schema
	•	Parse each table and its columns.
	•	For each column, check if its name is ambiguous. Ambiguity can arise if a name could mean more than one thing (e.g., active could be a status or a time range; rating could be user feedback or a parental guideline).
	2.	Identify Ambiguous Columns
	•	If a column name is ambiguous, decide on a more precise name that captures the column’s meaning.
	•	Use the column’s description (if available) to deduce the intended meaning.
	•	If no description is available, infer from the table or column context.
	3.	Propose a Renaming
	•	For each ambiguous column:
	1.	table_name: Which table it belongs to.
	2.	old_column_name: The current (ambiguous) name.
	3.	new_column_name: Your proposed, clearer name.
	4.	reason_for_renaming: A brief explanation of why the old name was ambiguous and how the new name helps.
	4.	Output Format
	•	Return the result as valid JSON under the key "renamed_columns".
	•	List only the columns you actually renamed.
	•	Example structure:

{
  "renamed_columns": [
    {
      "table_name": "sample_table",
      "old_column_name": "old_name",
      "new_column_name": "new_name",
      "reason_for_renaming": "Explanation."
    }
  ]
}

Example

Below is a simple example illustrating how you might rename ambiguous columns within a sample schema:

Sample Input:

{
  "film": {
    "table": "film",
    "columns": {
      "film_id": {
        "name": "film_id",
        "description": "A surrogate primary key for the film."
      },
      "title": {
        "name": "title",
        "description": "The title of the film."
      },
      "rating": {
        "name": "rating",
        "description": "Possible film rating: G, PG, PG-13, R, NC-17."
      }
    },
    "table_description": "Contains metadata about each film."
  }
}

Sample Output:

{
  "renamed_columns": [
    {
      "table_name": "film",
      "old_column_name": "rating",
      "new_column_name": "parental_rating",
      "reason_for_renaming": "The term 'rating' is ambiguous—could mean user reviews or parental rating. 'parental_rating' clarifies it as G, PG, R, etc."
    }
  ]
}

Input Schema:
