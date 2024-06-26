import json

from llm_ontology_alignment.data_models.experiment_models import OntologySchemaRewrite

sample_table = {
    "table": "person",
    "table_description": "A table containing person data. person can be a student/teacher/non-teaching employee.",
    "columns": [
        {
            "column": "person_id",
            "description": "A unique identifier for each person.",
        },
        {
            "column": "name",
            "description": "The name of the person.",
        },
        {
            "column": "address_id",
            "description": "a reference of the address of the person.",
        },
        {"column": "category", "description": "The category of the person."},
    ],
}

sample_break_down = {
    "subtables": [
        sample_table,
        {
            "table_name": "student",
            "table_description": "A table containing student data.",
            "columns": [
                {
                    "column": "student_id",
                    "description": "A unique identifier for each student.",
                    "reference_table": "person",
                    "reference_column": "person_id",
                },
                {
                    "column": "student_name",
                    "description": "name of student",
                    "reference_table": "person",
                    "reference_column": "name",
                },
                {
                    "column": "student_address_id",
                    "description": "The reference of address of the student.",
                    "reference_table": "person",
                    "reference_column": "address_id",
                },
            ],
        },
        {
            "table_name": "teacher",
            "table_description": "A table containing teacher data.",
            "columns": [
                {
                    "column": "teacher_id",
                    "description": "A unique identifier for each teacher.",
                    "reference_table": "person",
                    "reference_column": "person_id",
                },
                {
                    "column": "teacher_name",
                    "description": "name of teacher",
                    "reference_table": "person",
                    "reference_column": "name",
                },
                {
                    "column": "teacher_address_id",
                    "description": "The address of the teacher.",
                    "reference_table": "person",
                    "reference_column": "address_id",
                },
            ],
        },
        {
            "table_name": "non_teaching_employee",
            "table_description": "A table containing non-teaching employee data.",
            "columns": [
                {
                    "column": "employee_id",
                    "description": "A unique identifier for each employee.",
                    "reference_table": "person",
                    "reference_column": "person_id",
                },
                {
                    "column": "employee_name",
                    "description": "name of employee",
                    "reference_table": "person",
                    "reference_column": "name",
                },
                {
                    "column": "employee_address_id",
                    "description": "The address of the employee.",
                    "reference_table": "person",
                    "reference_column": "address_id",
                },
            ],
        },
    ]
}


def decompose_table(database, table_name):
    """
    Decompose table into columns
    """

    # if OntologyAlignmentOriginalSchema.objects(is_primary_key=True, database=database, table=table_name).count() == 0:
    #     raise ValueError("Primary key not found in the table for decomposition.")

    records = OntologySchemaRewrite.objects(database=database, original_table=table_name, llm_model="gpt-4o")

    inputs = []
    table_description = ""
    for record in records:
        input = {
            "column": record.column,
            "description": record.column_description,
        }
        table_description = record.table_description
        inputs.append(input)
    prompt = "You are an expert in the database schema design. You are tasked to break down single table storing multiple types of data to multiple tables storing one type of data."
    prompt += "After the transformation, it should be intuitive to understand the data stored in each table simply by looking at the table and column names. "
    prompt += "Return a json list following the example given and no other texts. \n\n"
    prompt += " Return an empty list if the table is already decomposed. "
    prompt += (
        f"\n\nInput: {json.dumps(sample_table, indent=2)}\n\nOutput: {json.dumps(sample_break_down, indent=2)}\n\n"
    )
    prompt += f"\n\nInput: {json.dumps({'table': table_name, 'table_description': table_description, 'columns': inputs}, indent=2)}\n\nOutput: \n\n"
    from llm_ontology_alignment.services.language_models import complete

    response = complete(
        prompt=prompt,
        model="gpt-4o",
        run_specs={
            "operation": "decompose_table",
            "llm": "gpt-4o",
            "sub_run_id": f"{database}_{table_name}",
        },
    )

    result = response.json()

    json_result = result["extra"]["extracted_json"]
    if not json_result:
        text_result = result["choices"][0]["message"]["content"]
        print(text_result)
    return json_result
