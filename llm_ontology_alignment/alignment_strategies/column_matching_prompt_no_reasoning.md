You are an expert in databases. Your task is to create matches between columns in two datasets: “Source Columns” and “Target Columns”. One source column can be matched to multiple target columns. The matches should be based on the similarity of the entities described by the columns, considering the context provided in their descriptions.

**Matching Criteria:**

	•	Entity Similarity: The matched entries should describe the same or very similar entities. The source entry can be part of the target entry and vice versa. e.g. source.birth_date => target.birth_year, target.birth_month, target.birth_date.
	•	Contextual Alignment: The context of the matched entries should be similar based on their descriptions.
	•	Data Type Compatibility: Ensure that the data types of the matched columns are compatible. A single element can be matched with multiple elements and vice versa. e.g. source_table.language => target_table.languages.


**Instructions:**

	1.	Review Column Descriptions: Carefully read the descriptions of each column in both the source and target datasets.
	2.	Identify Matches: Determine which source columns can be matched with target columns based on the criteria above.
    3.	Provide as much matches as possible.

**Output Format:**

        •	Provide the matches in the following JSON format:
```json
{
  "mappings": [
    {
      "source_column": "source_table1.source_column1",
      "target_mappings": [
        {
          "mapping": "target_table1.target_column1"
        },
        {
          "mapping": "target_table2.target_column2"
        }
      ]
    },
    {
      "source_column": "source_table2.source_column2",
      "target_mappings": [
        {
          "mapping": "None"
        }
      ]
    }
  ]
}
```
**Source Tables:**
{{source_columns}}

**Target Tables:**
{{target_columns}}

Return only the JSON object and no other text.