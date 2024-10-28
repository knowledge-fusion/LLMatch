You are an expert in matching database schemas. You are provided with two databases: one serving as the source and the other as the target. Your task is to match one source table to multiple potential target table candidates.

**Objective**: Identify and list all potential target tables that can map to non foreign-key columns in the given source table.

**Source Table Details**:
{{source_table}}

**Target Tables Details**:
{{target_tables}}

**Matching Criteria**:
- Ignore all foreign keys on both source and target tables. Do not consider them for matching.
- Identify target tables may potentially have columns that can be matched to the source table.
- One source column might be matched to multiple target columns. Redundant matches are allowed.

**Expected Output**:
Provide the matches in the following JSON format:
```json
{"mappings":[
{
 "source_column": "column1",
  "table_candidates": [
    {
      "table_name": "target_table1",
    },
    {
      "table_name": "target_table2",
    }
  ],
  },
  {
 "source_column": "column2",
    "table_candidates": [
  ]
  ]
}
```
Return only the JSON object and no other text.