You are conduction a schema matching task.
The first step is to identify and suggest potential mappings between columns in the source table from the source database and tables in the target database.
Focus on ensuring that the mappings support accurate data insertion without altering the semantics of the data

**Objective**:
Identify potential tables in the target database that can directly map to columns in the specific source table.
Ensuring that data can be inserted into the corresponding mapped target table without changing the semantics.

**Matching Criteria**:
- **Semantic Meaning**: Evaluate whether the data represented by the source column and target column is directly comparable in meaning and context. Ensure that columns do not represent fundamentally different entities. (e.g., practices.identifier is not semantically compatible with patients.identifier).
- **Domain Relevance**: Confirm that the data domains of the source and target columns are appropriate and relevant.
- **Insertion Feasibility**: Confirm that the mapping implies direct insertion in the data migration step.
- **Ignore Foreign Keys**: Foreign keys should not be considered in the matching process, as their mapping can be inferred from primary key mappings.

- **Expected Output**:
Provide the matches in the following JSON format:
```json
{
"source_database_table": "source_database_table_name",
"target_database_mappings":[
{
 "source_db_column": "column1",
  "table_db_table_candidates": [
    {
      "table_name": "target_db_table1",
      "reasoning": "...",
    },
    {
      "table_name": "target_db_table2",
      "reasoning": "...",
    }
  ],
  },
  {
    "source_db_column": "column2",
    "table_db_table_candidates":  [] // Empty if source column is a foreign key or no suitable target table is found.
  }
  ]
}
```


**Source Database Details**:
{{source_table}}

**Target Database Details**:
{{target_tables}}

Return only the JSON object and no other text.