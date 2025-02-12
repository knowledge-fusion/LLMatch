Task: Merge Candidate Tables in a Database Schema

Objective

You have been given a database schema (in JSON format). Some of the tables may contain overlapping or nearly identical data or serve essentially the same purpose. Your task is to propose which tables could be merged to reduce the total number of tables, along with reasons why merging makes sense.

Instructions
	1.	Read the Input JSON Schema
	•	The schema will show multiple tables, each containing columns and descriptions.
	2.	Look for Merge Candidates
	•	Identify tables that contain redundant data or are closely linked (for example, tables that have nearly identical columns or share a 1:1 relationship).
	•	Typical candidates might include:
	•	A table that holds an “extension” of data for another table.
	•	A table that stores partial or duplicated columns (like film and film_text).
	•	Lookup tables (like city and country) that might sometimes be combined into a single table (e.g., location), if the system doesn’t require strict normalization.
	3.	For Each Identified Merge
	•	Create a JSON object with the following structure:

{
  "new_table_name": "<NAME_OF_NEW_MERGED_TABLE>",
  "tables_merged": [ "tableA", "tableB" ],
  "reason_for_merging": "<WHY_WE_MERGE_THESE_TABLES>"
   "new_table_columns": [
	{
	  "column_name": "<COLUMN_NAME>",
	  "column_description": "<COLUMN_DESCRIPTION>"
      "original_columns": [ "<tableA.columnA>", "<tableB.columnB>" ]
	}
}


	•	If multiple merges are found, only choose the most significant ones. Ensure all columns are migrated to the new table.

	4.	Output Format
	•	Return your findings in valid JSON.

