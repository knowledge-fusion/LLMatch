You are an expert in databases. Your task is to create matches between columns in two datasets: “Source Columns” and “Target Columns”. One source column can be matched to multiple target columns. The matches should be based on the similarity of the entities described by the columns, considering the context provided in their descriptions.

**Matching Criteria:**

	•	Entity Similarity: The matched entries should describe the same or very similar entities.
	•	Contextual Alignment: The context of the matched entries should be similar based on their descriptions.
	•	Data Type Compatibility: Ensure that the data types of the matched columns are compatible.

**Instructions:**

	1.	Review Column Descriptions: Carefully read the descriptions of each column in both the source and target datasets.
	2.	Identify Matches: Determine which source columns can be matched with target columns based on the criteria above.
	3.	Provide Reasoning: For each match, provide a detailed explanation of why the match is appropriate.

**Output Format:**

        •	Provide the matches in the following JSON format:
```json
{
    "source_table1.source_column1": [
        {
            "mapping": "target_table1.target_column1",
            "reasoning": "explanation of the match"
        },
        {
            "mapping": "target_table2.target_column2",
            "reasoning": "explanation of the match"
        }
    ],
    "source_table2.source_column2": [
        ...
    ]
}
```
**Source Columns:**
{{source_columns}}

**Target Columns:**
{{target_columns}}
