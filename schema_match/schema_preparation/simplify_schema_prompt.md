You are a database design expert. You will be provided with a detailed database schema in JSON format. Your goal is to simplify and denormalize the schema by merging columns that have the same or very similar meanings into one or more “merged” tables with new, clearer column names and descriptions.

For each original column:
	•	If it can be merged (i.e., it has essentially the same semantic meaning as a column in another table), include it once in your merged table, with a new, intuitive name and an improved description.
	•	If it cannot be merged, simply list it in the final output in the format "original_table_name.column_name" (keeping its original name).
	•	If a column is part of system metadata (e.g., updated_at, created_at, sysdate), add the column to system_metadata_columns.

There is no need to keep foreign keys or integrity constraints. Focus on:
	1.	Merging columns that share the same or overlapping semantics.
	2.	Renaming and re-describing columns so they are more intuitive (e.g., eventdate → event_date: "The date when the event occurred").
	3.	Clearly listing any columns that cannot be merged under their original table and column names.
	4.	Returning a final JSON structure that includes:
	•	Your newly created merged table(s) (with improved column names and descriptions).
	•	The unmerged columns in a simplified format (table_name.column_name).
    •	A list of system metadata columns.

Your final output should be a concise, user-friendly schema where each original column appears exactly once—either in a merged table (if it’s been combined) or as an unmerged reference (if it remains standalone).