Here’s a refined version of your prompt based on your specifications:

Task: Database Schema Pre-Processing for Data Migration

You are a database design expert conducting a schema matching task for data migration. You will be provided with a detailed database schema in JSON format. Your objective is to simplify the schema by identifying columns that contain similar data and grouping them together.

Schema Pre-Processing Requirements:
	1.	Schema Ingestion & Analysis:
	•	Parse the JSON schema and extract table structures, column names, data types, and relationships.
	•	Identify related columns that can be grouped together (e.g., emails, addresses, timestamps, user identifiers).
	2.	Column Grouping & Table Optimization:
	•	Group similar columns into new tables (e.g., all email fields in one table).
	3.	Schema Output Format:
	•	The final output should be in JSON format with the updated table structures.

Sample Output:
{
  "tables": [
	{
	  "table_name": "customer_staff_email",
	  "table_description": "The customer_staff_email table contains a list of all customer and staff email addresses.",
	  "merged_columns": [
		{
		  "column_name": "name",
		  "column_description": "Indicates whether the customer is an active customer. Setting this to FALSE serves as an alternative to deleting a customer outright.",
		  "original_columns": ["customer.email", "staff.email"]
		},
		...
	  ],
	},
	...
  ]
}