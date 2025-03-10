You are an expert in matching database schemas. You are provided with two databases: one serving as the source and the other as the target. Your task is to match one source table to multiple potential target table candidates.

**Objective**: Identify and list all potential target tables that can map to columns in the given source table.

**Source Table Details**:
{{source_table}}

**Target Tables Details**:
{{target_tables}}

**Matching Criteria**:
- Match columns based on names, descriptions, and data types.
- Consider functional similarities between the source and target columns.
- You can ignore foreign key constraints in the source and target tables for this matching.

**Expected Output**:
Provide the matches in the following JSON format:
```json
{
  "source_table1": [
    {
      "target_table": "target_table1"
    },
    {
      "target_table": "target_table2"
    }
  ]
}
```
Return only the JSON object and no other text.