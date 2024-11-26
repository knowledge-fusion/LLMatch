CREATE TABLE consultation_details (
    event_date DATE,
    consultation_identifier TEXT,
    consultation_source_code_identifier TEXT,
    consultation_source_identifier TEXT,
    consultation_type INTEGER,
    entered_date DATE,
    patient_identifier TEXT,
    practice_identifier INTEGER,
    staff_member_identifier TEXT
);

COMMENT ON TABLE consultation_details IS 'This table contains information about different types of consultations, including dates, identifiers, and sources linked to each consultation as entered by the General Practitioner (GP).';
COMMENT ON COLUMN consultation_details.event_date IS 'Date associated with the consultation event. Type: Date, Format: DD/MM/YYYY';
COMMENT ON COLUMN consultation_details.consultation_identifier IS 'Primary Key. Unique identifier given to the consultation. Type: Text, Format: Up to 19 numeric characters';
COMMENT ON COLUMN consultation_details.consultation_source_code_identifier IS 'Source of the consultation from EMIS software as a medical code for use with the medical dictionary. Type: Text, Format: 6-18 numeric characters';
COMMENT ON COLUMN consultation_details.consultation_source_identifier IS 'Identifier for retrieval of anonymised information on the consultation source or location from EMIS software. Type: Text, Format: Up to 10 numeric characters';
COMMENT ON COLUMN consultation_details.consultation_type IS 'Type of consultation, generated based on recorded information. Type: Integer, Format: 3';
COMMENT ON COLUMN consultation_details.entered_date IS 'Date when the event was entered into the practice system. Type: Date, Format: DD/MM/YYYY';
COMMENT ON COLUMN consultation_details.patient_identifier IS 'Encrypted unique identifier for a patient in CPRD Aurum. Type: Text, Format: 6-19 numeric characters';
COMMENT ON COLUMN consultation_details.practice_identifier IS 'Encrypted unique identifier for a practice in CPRD Aurum. Type: Integer, Format: 5';
COMMENT ON COLUMN consultation_details.staff_member_identifier IS 'Encrypted unique identifier for the practice staff member who conducted the consultation. Type: Text, Format: Up to 10 numeric characters';

CREATE TABLE medical_observation (
    consultation_identifier TEXT,
    entered_date DATE,
    medical_code_identifier TEXT,
    numeric_range_high NUMERIC,
    numeric_range_low NUMERIC,
    numeric_unit_identifier INTEGER,
    observation_date DATE,
    observation_identifier TEXT,
    observation_type_identifier INTEGER,
    parent_observation_identifier TEXT,
    patient_identifier TEXT,
    practice_identifier INTEGER,
    problem_observation_identifier TEXT,
    staff_member_identifier TEXT,
    measurement_value NUMERIC
);

COMMENT ON TABLE medical_observation IS 'This table contains medical history data such as symptoms, clinical measurements, laboratory test results, diagnoses, and demographic information recorded as clinical codes, including patient ethnicity. Observations can be linked to consultations and parent observations. The data is structured in long format with multiple rows per subject.';
COMMENT ON COLUMN medical_observation.consultation_identifier IS 'Foreign Key. Linked consultation identifier. In EMIS Web® it is not necessary to enter observations within a consultation, so this identifier may be missing. Type: Text, Format: Up to 19 numeric characters. Mapping: Link Consultation table.';
COMMENT ON COLUMN medical_observation.entered_date IS 'Date the event was entered into EMIS Web®. Type: Date, Format: DD/MM/YYYY. Mapping: None.';
COMMENT ON COLUMN medical_observation.medical_code_identifier IS 'CPRD unique code for the medical term selected by the General Practitioner. Type: Text, Format: 6-18 numeric characters. Mapping: Lookup: Medical dictionary.';
COMMENT ON COLUMN medical_observation.numeric_range_high IS 'Value representing the high boundary of the normal range for this measurement. Type: Numeric, Format: 19.3. Mapping: None.';
COMMENT ON COLUMN medical_observation.numeric_range_low IS 'Value representing the low boundary of the normal range for this measurement. Type: Numeric, Format: 19.3. Mapping: None.';
COMMENT ON COLUMN medical_observation.numeric_unit_identifier IS 'Unit of measurement. Type: Integer, Format: 10. Mapping: Lookup: NumUnit.txt.';
COMMENT ON COLUMN medical_observation.observation_date IS 'Date associated with the event. Type: Date, Format: DD/MM/YYYY. Mapping: None.';
COMMENT ON COLUMN medical_observation.observation_identifier IS 'Primary Key. Unique identifier given to the observation. Type: Text, Format: Up to 19 numeric characters. Mapping: None.';
COMMENT ON COLUMN medical_observation.observation_type_identifier IS 'Type of observation (e.g., allergy, family history, observation). Type: Integer, Format: 5. Mapping: Lookup: ObsType.txt.';
COMMENT ON COLUMN medical_observation.parent_observation_identifier IS 'Foreign Key. Observation identifier that is the parent to the current observation. This enables grouping of related observations (e.g., systolic and diastolic blood pressure, blood test results). Type: Text, Format: Up to 19 numeric characters. Mapping: Link Observation table.';
COMMENT ON COLUMN medical_observation.patient_identifier IS 'Encrypted unique identifier for a patient in CPRD Aurum. The patient identifier is unique to CPRD Aurum and may represent a different patient in the CPRD GOLD database. Type: Text, Format: 6-19 numeric characters. Mapping: Link Patient table.';
COMMENT ON COLUMN medical_observation.practice_identifier IS 'Encrypted unique identifier for a practice in CPRD Aurum. Type: Integer, Format: 5. Mapping: Link Practice table.';
COMMENT ON COLUMN medical_observation.problem_observation_identifier IS 'Foreign Key. Observation identifier of any problem that the current observation is associated with. An overarching condition (e.g., 'wheezing') linked to a problem observation identifier (e.g., 'asthma'). Type: Text, Format: Up to 19 numeric characters. Mapping: Link Observation table.';
COMMENT ON COLUMN medical_observation.staff_member_identifier IS 'Encrypted unique identifier for the practice staff member who took the consultation in CPRD Aurum. Type: Text, Format: Up to 10 numeric characters. Mapping: Link Staff table.';
COMMENT ON COLUMN medical_observation.measurement_value IS 'Measurement or test value. Type: Numeric, Format: 19.3. Mapping: None.';

CREATE TABLE patient_demographics_and_registration (
    quality_standard_flag INTEGER,
    estimated_death_date DATE,
    recorded_death_date_software DATE,
    patient_gender INTEGER,
    month_of_birth INTEGER,
    patient_identifier TEXT,
    patient_category_identifier INTEGER,
    practice_identifier INTEGER,
    registration_end_date DATE,
    registration_start_date DATE,
    assigned_general_practitioner_identifier TEXT,
    year_of_birth INTEGER
);

COMMENT ON TABLE patient_demographics_and_registration IS 'This table contains basic patient demographics and registration details for the patients.';
COMMENT ON COLUMN patient_demographics_and_registration.quality_standard_flag IS 'Flag to indicate whether the patient has met certain quality standards: 1 = acceptable, 0 = unacceptable. Type: Integer';
COMMENT ON COLUMN patient_demographics_and_registration.estimated_death_date IS 'Estimated date of death of patient – derived using an algorithm. Type: Date, Format: DD/MM/YYYY';
COMMENT ON COLUMN patient_demographics_and_registration.recorded_death_date_software IS 'Date of death as recorded in the software. Researchers are advised to treat this with caution and consider using the estimated_death_date. Type: Date, Format: DD/MM/YYYY';
COMMENT ON COLUMN patient_demographics_and_registration.patient_gender IS 'Patient’s gender. Type: Integer, Lookup: Gender.txt';
COMMENT ON COLUMN patient_demographics_and_registration.month_of_birth IS 'Patient’s month of birth (for those aged under 16). Type: Integer';
COMMENT ON COLUMN patient_demographics_and_registration.patient_identifier IS 'Primary Key. Encrypted unique identifier given to a patient. Unique to the database. Type: Text';
COMMENT ON COLUMN patient_demographics_and_registration.patient_category_identifier IS 'The category that the patient has been assigned to, e.g., private, regular, temporary. Type: Integer, Lookup: PatientType.txt';
COMMENT ON COLUMN patient_demographics_and_registration.practice_identifier IS 'Encrypted unique identifier given to a practice. Type: Integer, Link: Practice table';
COMMENT ON COLUMN patient_demographics_and_registration.registration_end_date IS 'Date the patient's registration at the practice ended. Could represent a transfer-out date or death date. Type: Date, Format: DD/MM/YYYY';
COMMENT ON COLUMN patient_demographics_and_registration.registration_start_date IS 'The date that the patient registered with the practice. Most recent date the patient is recorded as having registered. Type: Date, Format: DD/MM/YYYY';
COMMENT ON COLUMN patient_demographics_and_registration.assigned_general_practitioner_identifier IS 'The General Practitioner that the patient is nominally registered with. Use with the Staff table for reference. Type: Text';
COMMENT ON COLUMN patient_demographics_and_registration.year_of_birth IS 'Patient’s year of birth. This is the actual year of birth, e.g., 1984. Type: Integer';

CREATE TABLE patient_referral_information (
    observation_identifier TEXT,
    patient_identifier TEXT,
    practice_identifier INTEGER,
    referral_mode_identifier INTEGER,
    referral_service_type_identifier INTEGER,
    referral_source_organization_identifier INTEGER,
    referral_target_organization_identifier INTEGER,
    referral_urgency_identifier INTEGER
);

COMMENT ON TABLE patient_referral_information IS 'This table contains details of patient referrals recorded on the General Practitioner system, including inbound and outbound referrals to or from external care centers.';
COMMENT ON COLUMN patient_referral_information.observation_identifier IS 'Primary Key. Unique identifier for the observation. Used to link with the Observation table. Type: Text, up to 19 numeric characters.';
COMMENT ON COLUMN patient_referral_information.patient_identifier IS 'Unique encrypted identifier for a patient in CPRD Aurum. Type: Text, 6-19 numeric characters.';
COMMENT ON COLUMN patient_referral_information.practice_identifier IS 'Unique encrypted identifier for a practice in CPRD Aurum. Type: Integer, 5 characters.';
COMMENT ON COLUMN patient_referral_information.referral_mode_identifier IS 'Mode by which the referral was made, e.g., telephone, written. Type: Integer, 1 character.';
COMMENT ON COLUMN patient_referral_information.referral_service_type_identifier IS 'Type of service the referral relates to, e.g., assessment, management, investigation. Type: Integer, 2 characters.';
COMMENT ON COLUMN patient_referral_information.referral_source_organization_identifier IS 'Source organization of the referral, identified by an ID number. Requires organization and organization type lookups. Type: Integer, 10 characters.';
COMMENT ON COLUMN patient_referral_information.referral_target_organization_identifier IS 'Target organization of the referral, identified by an ID number. Requires organization and organization type lookups. Type: Integer, 10 characters.';
COMMENT ON COLUMN patient_referral_information.referral_urgency_identifier IS 'Urgency of the referral, e.g., routine, urgent, dated. Type: Integer, 1 character.';

CREATE TABLE practice_information (
    last_collection_date DATE,
    practice_identifier INTEGER,
    practice_region INTEGER,
    up_to_standard_date DATE
);

COMMENT ON TABLE practice_information IS 'This table contains details of each practice, including the practice identifier, practice region, and the most recent data collection date.';
COMMENT ON COLUMN practice_information.last_collection_date IS 'Date of the most recent data collection for the practice. Type: Date, Format: DD/MM/YYYY. Mapping: None';
COMMENT ON COLUMN practice_information.practice_identifier IS 'Primary Key. A unique identifier given to a practice. Type: Integer, Format: 5. Mapping: None';
COMMENT ON COLUMN practice_information.practice_region IS 'Indicates where in the United Kingdom the practice is based. Denotes the Strategic Health Authority or ONS region for English practices. Type: Integer, Format: 5. Mapping: Lookup: Region.txt';
COMMENT ON COLUMN practice_information.up_to_standard_date IS 'The date at which the practice data is deemed to be of research quality based on an algorithm. [Not currently populated]. Type: Date, Format: DD/MM/YYYY. Mapping: None';

CREATE TABLE practice_staff_details (
    job_category_identifier INTEGER,
    practice_identifier INTEGER,
    staff_member_identifier TEXT
);

COMMENT ON TABLE practice_staff_details IS 'This table contains details of practice staff members, including their job categories.';
COMMENT ON COLUMN practice_staff_details.job_category_identifier IS 'Foreign Key. The job category identifier of the staff member who created the event. Maps to the Job Category table. Type: Integer';
COMMENT ON COLUMN practice_staff_details.practice_identifier IS 'Foreign Key. A unique identifier assigned to a practice. Maps to the Practice table. Type: Integer';
COMMENT ON COLUMN practice_staff_details.staff_member_identifier IS 'Primary Key. A unique identifier assigned to a practice staff member. Type: Text';

CREATE TABLE prescription_details (
    dosage_identifier TEXT,
    drug_record_identifier TEXT,
    treatment_duration_days INTEGER,
    entered_date DATE,
    estimated_national_health_service_cost DECIMAL,
    event_date DATE,
    issue_record_identifier TEXT,
    patient_identifier TEXT,
    practice_identifier INTEGER,
    problem_observation_identifier TEXT,
    drug_code_identifier TEXT,
    prescribed_quantity DECIMAL,
    quantity_unit_identifier INTEGER,
    staff_member_identifier TEXT
);

COMMENT ON TABLE prescription_details IS 'This table contains details of all prescriptions (for drugs and appliances) issued by general practitioners. Some prescriptions are linked to problem-type observations via the observation identifier.';
COMMENT ON COLUMN prescription_details.dosage_identifier IS 'An identifier that allows dosage information on the event to be retrieved. Type: Text, Format: 64 characters, Mapping: common_dosages.txt';
COMMENT ON COLUMN prescription_details.drug_record_identifier IS 'A unique identifier to a drug template record, used to group repeat prescriptions from the same template. Type: Text, Format: Up to 19 numeric characters';
COMMENT ON COLUMN prescription_details.treatment_duration_days IS 'Duration of the treatment in days. Type: Integer';
COMMENT ON COLUMN prescription_details.entered_date IS 'Date the event was entered into the system. Type: Date, Format: DD/MM/YYYY';
COMMENT ON COLUMN prescription_details.estimated_national_health_service_cost IS 'Estimated cost of the treatment to the National Health Service. Type: Decimal, Format: 10.4';
COMMENT ON COLUMN prescription_details.event_date IS 'Date associated with the event. Type: Date, Format: DD/MM/YYYY';
COMMENT ON COLUMN prescription_details.issue_record_identifier IS 'Primary Key. A unique identifier given to the issue record. Type: Text, Format: Up to 19 numeric characters';
COMMENT ON COLUMN prescription_details.patient_identifier IS 'An encrypted unique identifier given to a patient in the database. Type: Text, Format: 6-19 numeric characters, Mapping: Link Patient table';
COMMENT ON COLUMN prescription_details.practice_identifier IS 'An encrypted unique identifier given to a practice in the database. Type: Integer, Format: 5, Mapping: Link Practice table';
COMMENT ON COLUMN prescription_details.problem_observation_identifier IS 'A unique identifier for the observation that links to a problem under which this prescription was issued. Type: Text, Format: Up to 19 numeric characters, Mapping: Link Observation and Problem tables';
COMMENT ON COLUMN prescription_details.drug_code_identifier IS 'A unique code for the treatment selected by the general practitioner. Type: Text, Format: 6-18 numeric characters, Mapping: Product dictionary';
COMMENT ON COLUMN prescription_details.prescribed_quantity IS 'Total quantity entered by the general practitioner for the prescribed treatment. Type: Decimal, Format: 9.31';
COMMENT ON COLUMN prescription_details.quantity_unit_identifier IS 'Unit of the treatment (e.g., capsule, tablet). Type: Integer, Format: 2, Mapping: QuantUnit.txt';
COMMENT ON COLUMN prescription_details.staff_member_identifier IS 'An encrypted unique identifier given to the practice staff member who issued the treatment. Type: Text, Format: Up to 10 numeric characters, Mapping: Link Staff table';

CREATE TABLE problem_history (
    expected_duration_days INTEGER,
    last_review_date DATE,
    last_review_staff_identifier TEXT,
    observation_identifier TEXT,
    parent_problem_observation_identifier TEXT,
    parent_problem_relationship_identifier INTEGER,
    patient_identifier TEXT,
    practice_identifier INTEGER,
    problem_end_date DATE,
    problem_status_identifier INTEGER,
    significance_identifier INTEGER
);

COMMENT ON TABLE problem_history IS 'This table contains details of the patient's medical history, identified as a 'problem' by the General Practitioner. Data includes expected duration, review details, and relationships between problems. Problems should be linked to the Observation table for complete records.';
COMMENT ON COLUMN problem_history.expected_duration_days IS 'Expected duration of the problem in days. Type: Integer';
COMMENT ON COLUMN problem_history.last_review_date IS 'Date the problem was last reviewed. Type: Date, Format: DD/MM/YYYY';
COMMENT ON COLUMN problem_history.last_review_staff_identifier IS 'Identifier of the staff member who last reviewed the problem. Type: Text, Format: Up to 10 numeric characters';
COMMENT ON COLUMN problem_history.observation_identifier IS 'Primary Key. Unique identifier given to the observation. Type: Text, Format: Up to 19 numeric characters';
COMMENT ON COLUMN problem_history.parent_problem_observation_identifier IS 'Observation identifier for the parent observation of the problem, used to group problems via the Observation table. Type: Text, Format: Up to 19 numeric characters';
COMMENT ON COLUMN problem_history.parent_problem_relationship_identifier IS 'Identifier describing the relationship of the problem to another problem. Type: Integer';
COMMENT ON COLUMN problem_history.patient_identifier IS 'Encrypted unique identifier given to a patient in CPRD Aurum. Type: Text, Format: 6-19 numeric characters';
COMMENT ON COLUMN problem_history.practice_identifier IS 'Encrypted unique identifier given to a practice in CPRD Aurum. Type: Integer';
COMMENT ON COLUMN problem_history.problem_end_date IS 'Date the problem ended. Type: Date, Format: DD/MM/YYYY';
COMMENT ON COLUMN problem_history.problem_status_identifier IS 'Identifier of the problem's status (active, past). Type: Integer';
COMMENT ON COLUMN problem_history.significance_identifier IS 'Identifier of the problem's significance (minor, significant). Type: Integer';