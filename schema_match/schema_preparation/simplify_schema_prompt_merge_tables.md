Task: Merge Candidate Tables in a Database Schema

Objective

You have been given a database schema (in JSON format). Some of the tables may contain overlapping or nearly identical data or serve essentially the same purpose. Your task is to propose which tables could be merged to reduce the total number of tables, along with reasons why merging makes sense.

Instructions
	1.	Read the Input JSON Schema
	•	The schema will show multiple tables, each containing columns and descriptions.
	2.	Look for Merge Candidates
	•	Identify tables that contain similar columns or a table that stores partial or duplicated columns (like film and film_text, visit and visit_details).
	•	Each table can be merged at most once. Do not create new columns. There should be no loss of data. There should be at least two overlapping columns that are not foreign keys/primary keys.
	3.	For Each Identified Merge
	•	Create a JSON object with the following structure:

{
  "new_table_name": "<NAME_OF_NEW_MERGED_TABLE>",
  "new_table_description": "<DESCRIPTION_OF_NEW_MERGED_TABLE>",
  "tables_merged": [ "tableA", "tableB" ],
  "reason_for_merging": "<WHY_WE_MERGE_THESE_TABLES>"
   "overlapping_columns": [ "<columnA>", "<columnB>" ]
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

