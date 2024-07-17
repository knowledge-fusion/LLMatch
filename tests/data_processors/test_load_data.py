def test_sanitize_schema():
    from llm_ontology_alignment.data_processors.load_data import sanitize_schema

    sanitize_schema()


def test_load_sql_file():
    from llm_ontology_alignment.data_processors.load_data import load_sql_file

    load_sql_file()


def test_load_and_save_table():
    from llm_ontology_alignment.data_processors.load_data import load_and_save_table

    load_and_save_table()


def test_print_schema():
    from llm_ontology_alignment.data_processors.load_data import print_schema

    print_schema("cms")


def test_label_primary_key():
    from llm_ontology_alignment.data_processors.load_data import label_primary_key

    label_primary_key()


def test_migrate_scheam_rewrite():
    from llm_ontology_alignment.data_processors.load_data import migrate_schema_rewrite

    migrate_schema_rewrite()


def test_migrate_schema_rewrite_embedding():
    from llm_ontology_alignment.data_processors.load_data import migrate_schema_rewrite_embedding

    migrate_schema_rewrite_embedding()


def test_load_schema_constrain():
    from llm_ontology_alignment.data_processors.load_data import load_schema_constrain

    load_schema_constrain()


def test_load_cprd_schema():
    from llm_ontology_alignment.data_processors.load_data import load_cprd_schema

    load_cprd_schema()


def test_add_table_description():
    table_description = {
        "Patient": "The Patient file (Patient_NNN.txt) contains basic patient demographics and patient registration details for the patients.",
        "Practice": "The Practice file (Practice_NNN.txt) contains details of each practice, including the practice identifier, practice region, and the last collection date.",
        "Staff": "The Staff file (Staff_NNN.txt) contains practice staff details for each staff member, including job category.",
        "Consultation": "The Consultation file (Consultation_NNN.txt) contains information relating to the type of consultation as entered by the GP (e.g. telephone, home visit, practice visit). Some consultations are linked to observations that occur during the consultation via the consultation identifier (consid).",
        "Observation": "The Observation file (Observation_NNN.txt) contains medical history data entered on the GP system, including symptoms, clinical measurements, laboratory test results, diagnoses, and demographic information recorded as a clinical code (e.g. patient ethnicity). Observations that occur during a consultation can be linked via the consultation identifier. CPRD Aurum data are structured in a long format (multiple rows per subject), and observations can be linked to a parent observation.",
        "Referral": "a. The Referral file (Referral_NNN.txt) contains referral details recorded on the GP system. Data in the referral file are linked to the observation file and contain ‘add-on’ data for referral-type observations. These files contain information involving both inbound and outbound patient referrals to or from external care centres (normally to secondary care locations such as hospitals for inpatient or outpatient care). To obtain the full referral record (including reason for the referral and date), referrals should be linked to the Observation file using the observation identifier (obsid).",
        "Problem": "b. The Problem file (Problem_NNN.txt) contains details of the patient’s medical history that have been defined by the GP as a ‘problem’. Data in the problem file are linked to the observation file and contain ‘add-on’ data for problem-type observations. Information on identifying associated problems, the significance of the problem, and its expected duration can be found in this table. GPs may use ‘problems’ to manage chronic conditions as it would allow them to group clinical events (including drug prescriptions, measurements, symptom recording) by problem rather than chronologically. To obtain the full problem record (including the clinical code for the problem), problems should be linked to the Observation file using the observation identifier (obsid).",
        "DrugIssue": "The Drug issue file (DrugIssue_NNN.txt) contains details of all prescriptions on the GP system. This file contains data relating to all prescriptions (for drugs and appliances) issued by the GP. Some prescriptions are linked to problem-type observations via the Observation file, using the observation identifier (obsid).",
    }

    for table_name, table_description in table_description.items():
        from llm_ontology_alignment.data_processors.load_data import add_table_description

        add_table_description(table_name, table_description)
