You are an expert data scientist. You will be given a table named {{ table_name }} from the IMDb database. The table has the following schema:

{{ table_schema }}

Your task is to generate **5 rows of sample data** for this table. The data should be realistic and adhere to the schema provided. The output should be in JSON format, with each row represented as a dictionary. Ensure that the data aligns with the column descriptions and constraints (e.g., `nconst` is unique and alphanumeric, `primaryprofession` is an array of up to 3 strings, etc.).

If you need clarification on any aspect of the schema or data generation, feel free to ask.

---

**Example Output:**

```json
{
  "generated_data": [
    [
      {
        "column": "nconst",
        "data": "nm0000001"
      },
      {
        "column": "primaryname",
        "data": "Tom Hanks"
      },
      {
        "column": "birthyear",
        "data": 1956
      },
      {
        "column": "deathyear",
        "data": null
      },
      {
        "column": "primaryprofession",
        "data": ["actor", "producer", "director"]
      },
      {
        "column": "knownfortitles",
        "data": ["tt0109830", "tt0110357", "tt0120338"]
      }
    ],
    [
      {
        "column": "nconst",
        "data": "nm0000002"
      },
      {
        "column": "primaryname",
        "data": "Meryl Streep"
      },
      {
        "column": "birthyear",
        "data": 1949
      },
      {
        "column": "deathyear",
        "data": null
      },
      {
        "column": "primaryprofession",
        "data": ["actress", "singer"]
      },
      {
        "column": "knownfortitles",
        "data": ["tt0070511", "tt0112573", "tt0116282"]
      }
    ]
  ],
  ...
}
```

Only output the json data.