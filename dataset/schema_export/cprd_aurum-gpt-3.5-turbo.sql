CREATE TABLE consultation_details (
    consultation_date DATE,
    consultation_identifier TEXT,
    consultation_source_code_identifier TEXT,
    emis_consultation_source_identifier TEXT,
    cprd_consultation_source_identifier INTEGER,
    entered_date DATE,
    patient_identifier TEXT,
    practice_identifier INTEGER,
    staff_identifier TEXT
);

COMMENT ON TABLE consultation_details IS 'This table contains details of different types of consultations received by patients recorded by GPs. Some consultations are linked to observations via the consultation identifier (consid).';
COMMENT ON COLUMN consultation_details.consultation_date IS 'Date associated with the consultation. Type: Date';
COMMENT ON COLUMN consultation_details.consultation_identifier IS 'Primary Key. A unique identifier given to the consultation. Type: Text (Up to 19 numeric characters).';
COMMENT ON COLUMN consultation_details.consultation_source_code_identifier IS 'Source of the consultation from EMIS® software. This is a medical code that can be used with the medical dictionary. It may contain information similar to the consultation source identifiers but is available for use now. Some of the codes may not be interpretable e.g. Awaiting clinical code migration to EMIS Web®. Type: Text (6-18 numeric characters). Mapping: Medical dictionary. Maps to medcodeid';
COMMENT ON COLUMN consultation_details.emis_consultation_source_identifier IS 'Identifier that allows retrieval of anonymised information on the source or location of the consultation as recorded in the EMIS® software. Only the most frequently occurring strings have been anonymised and are included in the lookup. All others have been withheld by CPRD, pending anonymisation where feasible. Type: Text (Up to 10 numeric characters). Mapping: Lookup: ConsSource.txt';
COMMENT ON COLUMN consultation_details.cprd_consultation_source_identifier IS 'Type of consultation: this will be generated by CPRD based on information recorded in the consmedcodeid and conssourceid variables. [Not currently populated]. Type: Integer (3). Mapping: Lookup: cprdconstype.txt [not included in initial release]';
COMMENT ON COLUMN consultation_details.entered_date IS 'Date the consultation was entered into the practice system. Type: Date';
COMMENT ON COLUMN consultation_details.patient_identifier IS 'Encrypted unique identifier given to a patient in CPRD Aurum. The patient identifier is unique to CPRD Aurum and may represent a different patient in the CPRD GOLD database. Type: Text (6-19 numeric characters). Mapping: Link Patient table';
COMMENT ON COLUMN consultation_details.practice_identifier IS 'Encrypted unique identifier given to a practice in CPRD Aurum. Type: Integer (5). Mapping: Link Practice table';
COMMENT ON COLUMN consultation_details.staff_identifier IS 'Encrypted unique identifier given to the practice staff member who took the consultation in CPRD Aurum. Type: Text (Up to 10 numeric characters). Mapping: Link Staff table';

CREATE TABLE medical_history (
    consultation_identifier TEXT,
    entered_date DATE,
    medical_code TEXT,
    numeric_range_high NUMERIC,
    numeric_range_low NUMERIC,
    numeric_unit_identifier INTEGER,
    event_date DATE,
    observation_identifier TEXT,
    observation_type_identifier INTEGER,
    parent_observation_identifier TEXT,
    patient_identifier TEXT,
    practice_identifier INTEGER,
    problem_observation_identifier TEXT,
    staff_identifier TEXT,
    measurement_value NUMERIC
);

COMMENT ON TABLE medical_history IS 'This table contains medical history data entered on the GP system including symptoms, clinical measurements, laboratory test results, diagnoses, and demographic information recorded as a clinical code (e.g. patient ethnicity). CPRD Aurum data are structured in a long format (multiple rows per subject), and observations can be linked to a parent observation.';
COMMENT ON COLUMN medical_history.consultation_identifier IS 'Linked consultation identifier. In EMIS Web it is not necessary to enter observations within a consultation, so this identifier may be missing. Type: Text';
COMMENT ON COLUMN medical_history.entered_date IS 'Date the event was entered into EMIS Web. Type: Date';
COMMENT ON COLUMN medical_history.medical_code IS 'CPRD unique code for the medical term selected by the GP. Type: Text';
COMMENT ON COLUMN medical_history.numeric_range_high IS 'Value representing the high boundary of the normal range for this measurement. Type: Numeric';
COMMENT ON COLUMN medical_history.numeric_range_low IS 'Value representing the low boundary of the normal range for this measurement. Type: Numeric';
COMMENT ON COLUMN medical_history.numeric_unit_identifier IS 'Unit of measurement. Type: Integer';
COMMENT ON COLUMN medical_history.event_date IS 'Date associated with the event. Type: Date';
COMMENT ON COLUMN medical_history.observation_identifier IS 'Primary Key. Unique identifier given to the observation. Type: Text';
COMMENT ON COLUMN medical_history.observation_type_identifier IS 'Type of observation (allergy, family history, observation). Type: Integer';
COMMENT ON COLUMN medical_history.parent_observation_identifier IS 'Observation identifier (obsid) that is the parent to the observation. This enables grouping of multiple observations, such as systolic and diastolic blood pressure, or blood test results. Type: Text';
COMMENT ON COLUMN medical_history.patient_identifier IS 'Encrypted unique identifier given to a patient in CPRD Aurum. Type: Text';
COMMENT ON COLUMN medical_history.practice_identifier IS 'Encrypted unique identifier given to a practice in CPRD Aurum. Type: Integer';
COMMENT ON COLUMN medical_history.problem_observation_identifier IS 'Observation identifier (obsid) of any problem that an observation is associated with. An example of this might be an overarching condition that the current observation is associated with such as 'wheezing' with the problem observation identifier that links to an observation of 'asthma', that in turn contains information in the problem table. Type: Text';
COMMENT ON COLUMN medical_history.staff_identifier IS 'Encrypted unique identifier given to the practice staff member who took the consultation in CPRD Aurum. Type: Text';
COMMENT ON COLUMN medical_history.measurement_value IS 'Measurement or test value. Type: Numeric';

CREATE TABLE patient_problems (
    expected_duration INTEGER,
    last_review_date DATE,
    last_review_staff_identifier TEXT,
    observation_identifier TEXT,
    parent_problem_observation_identifier TEXT,
    parent_problem_relationship_identifier INTEGER,
    patient_identifier TEXT,
    practice_identifier INTEGER,
    problem_end_date DATE,
    problem_status_identifier INTEGER,
    problem_significance_identifier INTEGER
);

COMMENT ON TABLE patient_problems IS 'This table contains the patient's medical history that have been defined by the GP as a ‘problem’. Data in the table are linked to the observation file and contain ‘add-on’ data for problem-type observations. Information on identifying associated problems, the significance of the problem, and its expected duration can be found in this table. GPs may use ‘problems’ to manage chronic conditions as it would allow them to group clinical events (including drug prescriptions, measurements, symptom recording) by problem rather than chronologically. To obtain the full problem record (including the clinical code for the problem), problems should be linked to the Observation file using the observation identifier (observation_identifier).';
COMMENT ON COLUMN patient_problems.expected_duration IS 'Expected duration of the problem in days. Type: Integer';
COMMENT ON COLUMN patient_problems.last_review_date IS 'Date the problem was last reviewed. Type: Date';
COMMENT ON COLUMN patient_problems.last_review_staff_identifier IS 'Staff member who last reviewed the problem. Type: Text. Mapping: Link Staff table';
COMMENT ON COLUMN patient_problems.observation_identifier IS 'Primary Key. Unique identifier given to the observation. Type: Text. Mapping: Link Observation table';
COMMENT ON COLUMN patient_problems.parent_problem_observation_identifier IS 'Observation identifier for the parent observation of the problem. This can be used to group problems via the Observation table. Type: Text. Mapping: Link Observation table';
COMMENT ON COLUMN patient_problems.parent_problem_relationship_identifier IS 'Description of the relationship of the problem to another problem e.g. the problem may have evolved or been merged with another problem as the problem, or the GP’s understanding of the problem, changes. Type: Integer. Mapping: Lookup ParentProbRel.txt';
COMMENT ON COLUMN patient_problems.patient_identifier IS 'Encrypted unique identifier given to a patient in CPRD Aurum. The patient identifier is unique to CPRD Aurum and may represent a different patient in the CPRD GOLD database. Type: Text. Mapping: Link Patient table';
COMMENT ON COLUMN patient_problems.practice_identifier IS 'Encrypted unique identifier given to a practice in CPRD Aurum. Type: Integer. Mapping: Link Practice table';
COMMENT ON COLUMN patient_problems.problem_end_date IS 'Date the problem ended. Type: Date';
COMMENT ON COLUMN patient_problems.problem_status_identifier IS 'Status of the problem (active, past). Type: Integer. Mapping: Lookup: ProbStatus.txt';
COMMENT ON COLUMN patient_problems.problem_significance_identifier IS 'Significance of the problem (minor, significant). Type: Integer. Mapping: Lookup: Sign.txt';

CREATE TABLE patient_referral (
    observation_identifier TEXT,
    patient_identifier TEXT,
    practice_identifier INTEGER,
    referral_mode_identifier INTEGER,
    referral_service_type_identifier INTEGER,
    referral_source_organization_identifier INTEGER,
    referral_target_organization_identifier INTEGER,
    referral_urgency_identifier INTEGER
);

COMMENT ON TABLE patient_referral IS 'This table contains referral details involving inbound and outbound patient referrals to or from external care centers such as hospitals for inpatient or outpatient care. Referral-type observations are linked to this table via observation identifier (obsid).';
COMMENT ON COLUMN patient_referral.observation_identifier IS 'Primary Key. A unique identifier given to the observation. Used to link referral-type observations to this table. Type: Text, Format: Up to 19 numeric characters';
COMMENT ON COLUMN patient_referral.patient_identifier IS 'Foreign Key. Encrypted identifier given to a patient in CPRD Aurum. Unique to CPRD Aurum but may represent a different patient in the CPRD GOLD database. Type: Text, Format: 6-19 numeric characters';
COMMENT ON COLUMN patient_referral.practice_identifier IS 'Foreign Key. Encrypted unique identifier given to a practice in CPRD Aurum. Used to link practices to this table. Type: Integer, Format: 5';
COMMENT ON COLUMN patient_referral.referral_mode_identifier IS 'Lookup. Mode by which the referral was made, e.g., telephone, written. Type: Integer, Format: 1';
COMMENT ON COLUMN patient_referral.referral_service_type_identifier IS 'Lookup. Type of service the referral relates to, e.g., assessment, management, investigation. Type: Integer, Format: 2';
COMMENT ON COLUMN patient_referral.referral_source_organization_identifier IS 'Foreign Key. Source organization of the referral. Identifies organizations by an ID number and each organization has a type, e.g., hospital inpatient department, community clinic. Both the organization table and the OrgType lookup are required. The lookups are undergoing anonymization work. [Not currently populated]. Type: Integer, Format: 10';
COMMENT ON COLUMN patient_referral.referral_target_organization_identifier IS 'Foreign Key. Target organization of the referral. Identifies organizations by an ID number and each organization has a type, e.g., hospital inpatient department, community clinic. Both the organization table and the OrgType lookup are required. The lookups are undergoing anonymization work. [Not currently populated]. Type: Integer, Format: 10';
COMMENT ON COLUMN patient_referral.referral_urgency_identifier IS 'Lookup. Urgency of the referral, e.g., routine, urgent, dated. Type: Integer, Format: 1';

CREATE TABLE patient_registration_details (
    quality_flag INTEGER,
    cprd_death_date DATE,
    emis_death_date DATE,
    gender_code INTEGER,
    month_of_birth INTEGER,
    patient_identifier TEXT,
    patient_category INTEGER,
    practice_identifier INTEGER,
    registration_end_date DATE,
    registration_start_date DATE,
    usual_gp TEXT,
    year_of_birth INTEGER
);

COMMENT ON TABLE patient_registration_details IS 'This table contains basic registration and demographic details for patients.';
COMMENT ON COLUMN patient_registration_details.quality_flag IS 'Flag to indicate whether the patient has met certain quality standards: 1 = acceptable, 0 = unacceptable. Type: Integer';
COMMENT ON COLUMN patient_registration_details.cprd_death_date IS 'Estimated date of death of patient - derived using a CPRD algorithm. Type: Date';
COMMENT ON COLUMN patient_registration_details.emis_death_date IS 'Date of death as recorded in the EMIS® software. Researchers are advised to treat the emis_death_date with caution and consider using the cprd_death_date variable below. Type: Date';
COMMENT ON COLUMN patient_registration_details.gender_code IS 'Patient’s gender. Type: Integer';
COMMENT ON COLUMN patient_registration_details.month_of_birth IS 'Patient’s month of birth (for those aged under 16). Type: Integer';
COMMENT ON COLUMN patient_registration_details.patient_identifier IS 'Primary Key. Encrypted unique identifier given to a patient in CPRD Aurum. The patient identifier is unique to CPRD Aurum and may represent a different patient in the CPRD GOLD database. The last 5 characters will be same as the CPRD practice identifier. Type: Text';
COMMENT ON COLUMN patient_registration_details.patient_category IS 'The category that the patient has been assigned to e.g. private, regular, temporary. Type: Integer';
COMMENT ON COLUMN patient_registration_details.practice_identifier IS 'Foreign Key. Encrypted unique identifier given to a practice in CPRD Aurum. Type: Integer. Linked to Practice table.';
COMMENT ON COLUMN patient_registration_details.registration_end_date IS 'Date the patient's registration at the practice ended. This may represent a transfer-out date or death date. Type: Date';
COMMENT ON COLUMN patient_registration_details.registration_start_date IS 'The date that the patient registered with the CPRD contributing practice. Most recent date the patient is recorded as having registered at the practice. If a patient deregistered for a period of time and returned, the return date would be recorded. Type: Date';
COMMENT ON COLUMN patient_registration_details.usual_gp IS 'The GP that the patient is nominally registered with. To be used with the Staff table for reference. Type: Text. Linked to Staff table.';
COMMENT ON COLUMN patient_registration_details.year_of_birth IS 'Patient’s year of birth. This is actual year of birth e.g. 1984. Type: Integer';

CREATE TABLE practice_details (
    last_collection_date DATE,
    practice_identifier INTEGER,
    practice_region INTEGER,
    up_to_standard_date DATE
);

COMMENT ON TABLE practice_details IS 'This table contains details of each practice, including the practice identifier, region, and last collection date.';
COMMENT ON COLUMN practice_details.last_collection_date IS 'Date of the most recent CPRD data collection for the practice. Type: Date (format: DD/MM/YYYY). This is not a primary key. ';
COMMENT ON COLUMN practice_details.practice_identifier IS 'Primary Key. Encrypted unique identifier given to a practice in CPRD Aurum. Type: Integer (format: 5).';
COMMENT ON COLUMN practice_details.practice_region IS 'Value to indicate where in the UK the practice is based. The region denotes the Strategic Health Authority (for builds to Dec 2021) or ONS region (for builds from Jan 2022) for English practices. Type: Integer (format: 5).';
COMMENT ON COLUMN practice_details.up_to_standard_date IS 'The date at which the practice data is deemed to be of research quality, based on CPRD algorithm. Type: Date (format: DD/MM/YYYY). This is not a primary key.';

CREATE TABLE practice_staff (
    job_category_id INTEGER,
    practice_identifier INTEGER,
    staff_identifier TEXT
);

COMMENT ON TABLE practice_staff IS 'This table contains details of staff members working in a practice including their job categories.';
COMMENT ON COLUMN practice_staff.job_category_id IS 'Foreign Key. A reference to the Job Category table. Type: Integer';
COMMENT ON COLUMN practice_staff.practice_identifier IS 'Foreign Key. A reference to the Practice table. Type: Integer';
COMMENT ON COLUMN practice_staff.staff_identifier IS 'Primary Key. A unique encrypted identifier given to the practice staff member in CPRD Aurum. Type: Text';

CREATE TABLE prescriptions (
    dosage_identifier TEXT,
    drug_record_identifier TEXT,
    course_duration INTEGER,
    entered_date DATE,
    estimated_nhs_cost DECIMAL,
    event_date DATE,
    issue_identifier TEXT,
    patient_identifier TEXT,
    practice_identifier INTEGER,
    problem_observation_identifier TEXT,
    product_code_identifier TEXT,
    quantity DECIMAL,
    quantity_unit_identifier INTEGER,
    staff_identifier TEXT
);

COMMENT ON TABLE prescriptions IS 'This table contains details of all drug and appliance prescriptions issued by the GP system. Some prescriptions are linked to observations via the Observation table by the observation identifier (obsid).';
COMMENT ON COLUMN prescriptions.dosage_identifier IS 'A unique identifier that allows dosage information on the event to be retrieved. Type: Text. Format: 64 characters. Field Name: Dosage identifier. Mapping: Lookup: common_dosages.txt';
COMMENT ON COLUMN prescriptions.drug_record_identifier IS 'A unique identifier to a drug template record which is not currently for release. At present, this may be used to group repeat prescriptions from the same template. Type: Text. Format: Up to 19 numeric characters. Field Name: Drug record identifier. Mapping: None';
COMMENT ON COLUMN prescriptions.course_duration IS 'Duration of the treatment in days. Type: Integer. Format: 10. Field Name: Course duration in days. Mapping: None';
COMMENT ON COLUMN prescriptions.entered_date IS 'Date the event was entered into EMIS Web. Type: Date. Format: DD/MM/YYYY. Field Name: Entered date. Mapping: None';
COMMENT ON COLUMN prescriptions.estimated_nhs_cost IS 'Estimated cost of the treatment to the NHS. Type: Decimal. Format: 10.4. Field Name: Estimated NHS cost. Mapping: None';
COMMENT ON COLUMN prescriptions.event_date IS 'Date associated with the event. Type: Date. Format: DD/MM/YYYY. Field Name: Event date. Mapping: None';
COMMENT ON COLUMN prescriptions.issue_identifier IS 'Primary Key. A unique identifier given to the issue record. Type: Text. Format: Up to 19 numeric characters. Field Name: Issue record identifier. Mapping: None';
COMMENT ON COLUMN prescriptions.patient_identifier IS 'Encrypted unique identifier given to a patient in CPRD Aurum. The patient identifier is unique to CPRD Aurum and may represent a different patient in the CPRD GOLD database. Type: Text. Format: 6-19 numeric characters. Field Name: Patient identifier. Mapping: Link Patient table';
COMMENT ON COLUMN prescriptions.practice_identifier IS 'Encrypted unique identifier given to a practice in CPRD Aurum. Type: Integer. Format: 5. Field Name: Practice identifier. Mapping: Link Practice table';
COMMENT ON COLUMN prescriptions.problem_observation_identifier IS 'Unique identifier for the observation that links to a problem under which this prescription was issued. This refers to an 'obsid' in the Observation table which, in turn, can be linked to a record in the Problem table using 'obsid'. Type: Text. Format: Up to 19 numeric characters. Field Name: Problem observation identifier. Mapping: Link Observation and Problem tables';
COMMENT ON COLUMN prescriptions.product_code_identifier IS 'Unique CPRD code for the treatment selected by the GP. Type: Text. Format: 6-18 numeric characters. Field Name: Product code identifier. Mapping: Lookup: Product dictionary';
COMMENT ON COLUMN prescriptions.quantity IS 'Total quantity entered by the GP for the prescribed treatment. Type: Decimal. Format: 9.31. Field Name: Quantity. Mapping: None';
COMMENT ON COLUMN prescriptions.quantity_unit_identifier IS 'Unit of the treatment (capsule, tablet). Type: Integer. Format: 2. Field Name: Quantity unit identifier. Mapping: Lookup: QuantUnit.txt';
COMMENT ON COLUMN prescriptions.staff_identifier IS 'Encrypted unique identifier given to the practice staff member issued the treatment in CPRD Aurum. Type: Text. Format: Up to 10 numeric characters. Field Name: Staff identifier. Mapping: Link Staff table';