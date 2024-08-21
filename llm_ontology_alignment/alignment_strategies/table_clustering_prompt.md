You are an expert in database schema design. You are provided with one database with multiple tables. Your task is to cluster the tables into different groups such table tables within each cluster contains similar content. Make sure all tables exist in clusters and no table is left out.

**Database Details**:
{{database_description}}

**Expected Output**:
Provide the matches in the following JSON format:
```json
{
  "cluster1": [
    "table1",
    "table2",
    "table6"
  ],
    "cluster2": [
        "table3",
        "table5"
      ]
}
```
Return only the JSON object and no other text.