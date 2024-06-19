
sample_table = {
        "table": "person",
        "table_description": "A table containing person data. person can be a student/teacher/non-teaching employee etc.",
        "columns": [
            {
                "column": "person_id",
                "description": "A unique identifier for each person.",
                "is_primary_key": True,
            },
            {
                "column": "name",
                "description": "The name of the person.",
            },
            {
                "column": "gender",
                "description": "The gender of the person.",
            },
            {
                "column": "category",
                "description": "The category of the person."
            }
        ]
    }

sample_break_down = [
        {
            "table_name": "person",
            "table_description": "A table containing person data. person can be a student/teacher/non-teaching employee etc.",
            "columns": [
                {
                    "column": "person_id",
                    "description": "A unique identifier for each person.",
                    "is_primary_key": True,
                },
                {
                    "column": "name",
                    "description": "The name of the person.",
                },
                {
                    "column": "gender",
                    "description": "The gender of the person.",
                }]
        }, {
            "table_name": "student",
            "table_description": "A table containing student data.",
            "columns": [
                {
                    "column": "student_id",
                    "description": "A unique identifier for each student.",
                    "is_foreign_key": True,
                    "reference_table": "person",
                    "reference_column": "person_id",
                },
                {
                    "column": "name",
                    "description": "name of student",
                },
                {
                    "column": "gender",
                    "description": "The gender of the student.",
                }
            ]
        },
        {
            "table_name": "teacher",
            "table_description": "A table containing teacher data.",
            "columns": [
                {
                    "column": "teacher_id",
                    "description": "A unique identifier for each teacher.",
                    "is_foreign_key": True,
                    "reference_table": "person",
                    "reference_column": "person_id",
                },
                {
                    "column": "name",
                    "description": "name of teacher",
                },
                {
                    "column": "gender",
                    "description": "The gender of the teacher.",
                }]
            }, {
            "table_name": "non_teaching_employee",
            "table_description": "A table containing non-teaching employee data.",
            "columns": [
                {
                    "column": "employee_id",
                    "description": "A unique identifier for each employee.",
                    "is_foreign_key": True,
                    "reference_table": "person",
                    "reference_column": "person_id",
                },
                {
                    "column": "name",
                    "description": "name of employee",
                },
                {
                    "column": "gender",
                    "description": "The gender of the employee.",
                }
            ]
        }
    ]

def decompose_table(database, table_name):
    """
    Decompose table into columns
    """

    from llm_ontology_alignment.data_models.experiment_models import (
        OntologySchemaRewrite,
    )

    records = OntologySchemaRewrite.objects(
        database=database, original_table=table_name, llm_model="gpt-4o"
    )
    prompt = "You are an expert in the database schema design. You are tasked to break down single table storing multiple types of data to multiple tables storing one type of data."
    prompt += f"After the transformation, it should be intuitive to understand the data stored in each table simply by looking at the table and column names. "
    prompt += "Return a json list following the example given and no other texts. \n\n"
    prompt +=" Return an empty list if the table is already decomposed. \n\n"

