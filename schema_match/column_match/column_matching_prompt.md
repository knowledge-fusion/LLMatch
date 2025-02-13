You are an expert in databases. Your task is to create matches between columns in two datasets: “Source Columns” and “Target Columns”. One source column can be matched to multiple target columns. The matches should be based on the semantic similarity of the entities described by the columns, considering the context provided in their descriptions.

**Matching Criteria:**

	•	Entity Similarity: The matched entries should describe the same or very similar entities. The source entry can be part of the target entry and vice versa. e.g. full_name => first_name, last_name. registration_date => registration_date, registration_time
	•	Contextual Alignment: each column represent different types of entities. make sure that the matched columns are of the same type. Negative examples: bank.name != bank_branch.name, customer.name != staff.name
	•	Data Type Compatibility: Ensure that the data types of the matched columns are compatible. A single element can be matched with multiple elements and vice versa. e.g. source_table.language => target_table.languages.

**Instructions:**

	1.	Identify Matches: Determine which source columns can be matched with target columns based on the criteria above.
	2.	Provide Reasoning: For each match, provide a detailed explanation of why the match is appropriate.
    3.  Review Matches: Ensure data belongs to the same domain and is semantically similar.

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
        {
            "mapping": "None",
            "reasoning": "..."
        }
    ]
}
```
**Source Tables:**
{{source_columns}}

**Target Tables:**
{{target_columns}}

Return only the JSON object and no other text.