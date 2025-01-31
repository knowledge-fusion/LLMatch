

You are an expert in matching database schemas. You are given a table  as a JSON list of columns. Your task is to generate 5 rows of sample data given the schema.

1. **Table Name**: The new table name should clearly indicate the data stored in the table.
2. **Column Names**: The new column names should be unique within the table and clearly describe the data stored in each column. Avoid using acronyms; replace them with their full forms. Try to use widely accepted vocabulary.
3. **Descriptions**:
    - **Table Description**: Should be clear, concise, and include information on the data stored in the table columns.
    - **Column Descriptions**: Should be clear, concise, and include the data type and any key information (Primary Key, Foreign Key, etc.).

Reuse existing vocabulary where possible and maintain consistency with the provided rewrites.

Here are some existing column name rewrites:
{{existing_column_rewrites}}

**Input Example**:

```json
{
  "table": {
    "old_name": "basic_information",
    "old_description": "the address contains basic information for customers, staff, and stores."
  },
  "columns": [
    {
      "old_name": "address_id",
      "old_description": "a surrogate primary key used to uniquely identify each address in the table. Type: int(11)"
    },
    {
      "old_name": "address",
      "old_description": "the details of an address. Type: varchar(255)"
    },
    {
      "old_name": "owner_id",
      "old_description": "an mapping to person table. Type: int(11)"
    }
  ]
}
```

**Output Example**:

```json
{
  "table": {
    "old_name": "address",
    "new_name": "address_information",
    "new_description": "This table contains address details for customers, staff, and stores."
  },
  "columns": [
    {
      "old_name": "address_id",
      "new_name": "address_identifier",
      "new_description": "Primary Key. A unique identifier used to uniquely identify each address in the table. Type: Integer"
    },
    {
      "old_name": "address",
      "new_name": "full_address",
      "new_description": "The details of an address. Type: Text"
    },
    {
      "old_name": "owner_id",
      "new_name": "owner_identifier",
      "new_description": "Foreign Key. A reference to the person table. Type: Integer"
    }
  ]
}
```

**Input for you to process**:

{{input_data}}

Return only the JSON object and no other text.