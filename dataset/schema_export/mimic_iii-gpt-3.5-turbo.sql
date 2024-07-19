CREATE TABLE ICU_stays (
    item_source_database VARCHAR(20),
    first_care_unit VARCHAR(20),
    first_ward_identifier SMALLINT,
    hospital_admission_id INT,
    ICU_stay_id INT,
    admission_time_ICU TIMESTAMP(0),
    last_care_unit VARCHAR(20),
    last_ward_identifier SMALLINT,
    ICU_stay_length DOUBLE,
    discharge_time_ICU TIMESTAMP(0),
    unique_row_identifier INT,
    patient_identifier INT
);

COMMENT ON TABLE ICU_stays IS 'This table lists all ICU admissions.';
COMMENT ON COLUMN ICU_stays.item_source_database IS 'Source database of the item.';
COMMENT ON COLUMN ICU_stays.first_care_unit IS 'First care unit associated with the ICU stay.';
COMMENT ON COLUMN ICU_stays.first_ward_identifier IS 'Identifier for the first ward the patient was located in.';
COMMENT ON COLUMN ICU_stays.hospital_admission_id IS 'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN ICU_stays.ICU_stay_id IS 'Primary Key. Identifies the ICU stay.';
COMMENT ON COLUMN ICU_stays.admission_time_ICU IS 'Time of admission to the ICU.';
COMMENT ON COLUMN ICU_stays.last_care_unit IS 'Last care unit associated with the ICU stay.';
COMMENT ON COLUMN ICU_stays.last_ward_identifier IS 'Identifier for the last ward the patient is located in.';
COMMENT ON COLUMN ICU_stays.ICU_stay_length IS 'Length of stay in the ICU in minutes.';
COMMENT ON COLUMN ICU_stays.discharge_time_ICU IS 'Time of discharge from the ICU.';
COMMENT ON COLUMN ICU_stays.unique_row_identifier IS 'Unique row identifier.';
COMMENT ON COLUMN ICU_stays.patient_identifier IS 'Foreign key. Identifies the patient.';

CREATE TABLE caregivers_list (
    caregiver_id INT,
    caregiver_description VARCHAR(30),
    caregiver_title VARCHAR(15),
    unique_row_identifier INT
);

COMMENT ON TABLE caregivers_list IS 'This table contains a list of caregivers associated with an ICU stay.';
COMMENT ON COLUMN caregivers_list.caregiver_id IS 'Primary Key. A unique identifier for each caregiver.';
COMMENT ON COLUMN caregivers_list.caregiver_description IS 'More detailed description of the caregiver if available.';
COMMENT ON COLUMN caregivers_list.caregiver_title IS 'Title of the caregiver, for example Medical Doctor or Registered Nurse.';
COMMENT ON COLUMN caregivers_list.unique_row_identifier IS 'Unique row identifier.';

CREATE TABLE current_procedural_terminology_dictionary (
    code_category SMALLINT,
    terminology_text_element VARCHAR(5),
    maximum_code_within_subsection INT,
    minimum_code_within_subsection INT,
    unique_row_identifier INT,
    high_level_section_header VARCHAR(50),
    range_of_codes_within_high_level_section VARCHAR(100),
    subsection_header VARCHAR(255),
    range_of_codes_within_subsection VARCHAR(100)
);

COMMENT ON TABLE current_procedural_terminology_dictionary IS 'This table contains a high-level dictionary of Current Procedural Terminology.';
COMMENT ON COLUMN current_procedural_terminology_dictionary.code_category IS 'Code category.';
COMMENT ON COLUMN current_procedural_terminology_dictionary.terminology_text_element IS 'Text element of Current Procedural Terminology, if any.';
COMMENT ON COLUMN current_procedural_terminology_dictionary.maximum_code_within_subsection IS 'Maximum code within the subsection.';
COMMENT ON COLUMN current_procedural_terminology_dictionary.minimum_code_within_subsection IS 'Minimum code within the subsection.';
COMMENT ON COLUMN current_procedural_terminology_dictionary.unique_row_identifier IS 'Unique row identifier.';
COMMENT ON COLUMN current_procedural_terminology_dictionary.high_level_section_header IS 'High-level section header.';
COMMENT ON COLUMN current_procedural_terminology_dictionary.range_of_codes_within_high_level_section IS 'Range of codes within the high-level section.';
COMMENT ON COLUMN current_procedural_terminology_dictionary.subsection_header IS 'Subsection header.';
COMMENT ON COLUMN current_procedural_terminology_dictionary.range_of_codes_within_subsection IS 'Range of codes within the subsection.';

CREATE TABLE diagnosis_related_group (
    drg_description VARCHAR(255),
    drg_code VARCHAR(20),
    relative_mortality SMALLINT,
    relative_severity SMALLINT,
    drg_group_type VARCHAR(20),
    hospital_admission_id INT,
    unique_row_identifier INT,
    patient_identifier INT
);

COMMENT ON TABLE diagnosis_related_group IS 'This table contains diagnoses related to the hospital stays of patients.';
COMMENT ON COLUMN diagnosis_related_group.drg_description IS 'Description of the related group of diagnoses. ';
COMMENT ON COLUMN diagnosis_related_group.drg_code IS 'Code for the Diagnosis-Related Group.';
COMMENT ON COLUMN diagnosis_related_group.relative_mortality IS 'Relative mortality rate, available for type All Patient Refined(APR) only.';
COMMENT ON COLUMN diagnosis_related_group.relative_severity IS 'Relative severity rate, available for type APR only.';
COMMENT ON COLUMN diagnosis_related_group.drg_group_type IS 'Type of Diagnosis-Related Group. For example, APR is All Patient Refined.';
COMMENT ON COLUMN diagnosis_related_group.hospital_admission_id IS 'Foreign Key. Identifies the hospital stay of related group of diagnoses.';
COMMENT ON COLUMN diagnosis_related_group.unique_row_identifier IS 'Unique row identifier for diagnosis related group.';
COMMENT ON COLUMN diagnosis_related_group.patient_identifier IS 'Foreign Key. Identifies the patient for diagnosis related group.';

CREATE TABLE discharge_status (
    acknowledge_status VARCHAR(20),
    acknowledgetime TIMESTAMP(0),
    outcome VARCHAR(20),
    service_id VARCHAR(10),
    status VARCHAR(20),
    ward_id INT,
    createtime TIMESTAMP(0),
    current_icu VARCHAR(15),
    current_ward_id INT,
    latest_reservation_time TIMESTAMP(0),
    ward_id_discharge INT,
    first_reservation_time TIMESTAMP(0),
    hospital_admission_id INT,
    outcome_time TIMESTAMP(0),
    is_cdiff_requested SMALLINT,
    is_mrsa_requested SMALLINT,
    is_resp_requested SMALLINT,
    is_tele_requested SMALLINT,
    is_vre_requested SMALLINT,
    unique_row_identifier INT,
    patient_identifier INT,
    submit_icu VARCHAR(15),
    submit_ward_id INT,
    last_update_time TIMESTAMP(0)
);

COMMENT ON TABLE discharge_status IS 'Records the discharge status (called out) of the patient.';
COMMENT ON COLUMN discharge_status.acknowledge_status IS 'Status of the response to the call out request.';
COMMENT ON COLUMN discharge_status.acknowledgetime IS 'Time at which call out request was acknowledged.';
COMMENT ON COLUMN discharge_status.outcome IS 'Result of the call out request.';
COMMENT ON COLUMN discharge_status.service_id IS 'Identifies the service to which the patient is called out to.';
COMMENT ON COLUMN discharge_status.status IS 'Current status of the call out request.';
COMMENT ON COLUMN discharge_status.ward_id IS 'Identifies the ward where the patient is to be discharged to. A value of 1 indicates first available ward. A value of 0 indicates home.';
COMMENT ON COLUMN discharge_status.createtime IS 'Time at which the call out request was created.';
COMMENT ON COLUMN discharge_status.current_icu IS 'If the ward where the patient is currently residing is an ICU, the ICU type is listed here.';
COMMENT ON COLUMN discharge_status.current_ward_id IS 'Identifies the ward where the patient is currently residing.';
COMMENT ON COLUMN discharge_status.latest_reservation_time IS 'Latest time at which a ward was reserved for the call out request.';
COMMENT ON COLUMN discharge_status.ward_id_discharge IS 'The ward to which the patient was discharged.';
COMMENT ON COLUMN discharge_status.first_reservation_time IS 'First time at which a ward was reserved for the call out request.';
COMMENT ON COLUMN discharge_status.hospital_admission_id IS 'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN discharge_status.outcome_time IS 'Time at which the outcome (cancelled or discharged) occurred.';
COMMENT ON COLUMN discharge_status.is_cdiff_requested IS 'Indicates if special precautions are required.';
COMMENT ON COLUMN discharge_status.is_mrsa_requested IS 'Indicates if special precautions are required.';
COMMENT ON COLUMN discharge_status.is_resp_requested IS 'Indicates if special precautions are required.';
COMMENT ON COLUMN discharge_status.is_tele_requested IS 'Indicates if special precautions are required.';
COMMENT ON COLUMN discharge_status.is_vre_requested IS 'Indicates if special precautions are required.';
COMMENT ON COLUMN discharge_status.unique_row_identifier IS 'Unique row identifier.';
COMMENT ON COLUMN discharge_status.patient_identifier IS 'Foreign key. Identifies the patient.';
COMMENT ON COLUMN discharge_status.submit_icu IS 'If the ward where the call was submitted was an ICU, the ICU type is listed here.';
COMMENT ON COLUMN discharge_status.submit_ward_id IS 'Identifies the ward where the call out request was submitted.';
COMMENT ON COLUMN discharge_status.last_update_time IS 'Last time at which the call out request was updated.';

CREATE TABLE hospital_admissions (
    location_of_admission VARCHAR(50),
    type_of_admission VARCHAR(50),
    time_of_admission TIMESTAMP(0),
    time_of_death TIMESTAMP(0),
    diagnosis_description VARCHAR(255),
    location_of_discharge VARCHAR(50),
    time_of_discharge TIMESTAMP(0),
    ethnicity_type VARCHAR(200),
    hospital_admission_id INT,
    has_chart_events_data SMALLINT,
    insurance_type VARCHAR(255),
    language_type VARCHAR(10),
    marital_status_type VARCHAR(50),
    religion_type VARCHAR(50),
    unique_row_identifier INT,
    patient_identifier INT
);

COMMENT ON TABLE hospital_admissions IS 'This table contains information regarding hospital admissions associated with an ICU stay.';
COMMENT ON COLUMN hospital_admissions.location_of_admission IS 'Location of admission.';
COMMENT ON COLUMN hospital_admissions.type_of_admission IS 'Type of admission, for example emergency or elective.';
COMMENT ON COLUMN hospital_admissions.time_of_admission IS 'Time of admission to the hospital.';
COMMENT ON COLUMN hospital_admissions.time_of_death IS 'Time of death.';
COMMENT ON COLUMN hospital_admissions.diagnosis_description IS 'Description of diagnosis.';
COMMENT ON COLUMN hospital_admissions.location_of_discharge IS 'Location of discharge.';
COMMENT ON COLUMN hospital_admissions.time_of_discharge IS 'Time of discharge from the hospital.';
COMMENT ON COLUMN hospital_admissions.ethnicity_type IS 'Type of ethnicity.';
COMMENT ON COLUMN hospital_admissions.hospital_admission_id IS 'Primary Key. Identifies the hospital stay.';
COMMENT ON COLUMN hospital_admissions.has_chart_events_data IS 'Boolean value determining if the hospital admission has at least one observation in the CHARTEVENTS table.';
COMMENT ON COLUMN hospital_admissions.insurance_type IS 'Type of insurance.';
COMMENT ON COLUMN hospital_admissions.language_type IS 'Type of language.';
COMMENT ON COLUMN hospital_admissions.marital_status_type IS 'Type of marital status.';
COMMENT ON COLUMN hospital_admissions.religion_type IS 'Type of religion.';
COMMENT ON COLUMN hospital_admissions.unique_row_identifier IS 'Unique row identifier.';
COMMENT ON COLUMN hospital_admissions.patient_identifier IS 'Foreign key. Identifies the patient.';

CREATE TABLE icd_diagnoses (
    hospital_admission_id INT,
    icd_code VARCHAR(10),
    unique_row_identifier INT,
    code_priority INT,
    patient_identifier INT
);

COMMENT ON TABLE icd_diagnoses IS 'Table containing hospital admission diagnoses coded using the International Classification of Diseases 9th Revision (ICD9) system.';
COMMENT ON COLUMN icd_diagnoses.hospital_admission_id IS 'Foreign Key. Identifies the hospital stay.';
COMMENT ON COLUMN icd_diagnoses.icd_code IS 'ICD9 code for the diagnosis.';
COMMENT ON COLUMN icd_diagnoses.unique_row_identifier IS 'Unique row identifier.';
COMMENT ON COLUMN icd_diagnoses.code_priority IS 'Priority of the code. Sequence 1 is the primary code.';
COMMENT ON COLUMN icd_diagnoses.patient_identifier IS 'Foreign Key. Identifies the patient.';

CREATE TABLE international_classification_of_diseases_9th_revision_diagnoses (
    icd_code VARCHAR(10),
    full_title VARCHAR(255),
    unique_row_identifier INT,
    abbreviated_title VARCHAR(50)
);

COMMENT ON TABLE international_classification_of_diseases_9th_revision_diagnoses IS 'This table contains the dictionary of the International Classification of Diseases, 9th Revision (Diagnoses).';
COMMENT ON COLUMN international_classification_of_diseases_9th_revision_diagnoses.icd_code IS 'ICD-9 code. This is a fixed length character field, as whitespaces are important in uniquely identifying ICD-9 codes. Primary Key.';
COMMENT ON COLUMN international_classification_of_diseases_9th_revision_diagnoses.full_title IS 'The full title associated with the ICD code.';
COMMENT ON COLUMN international_classification_of_diseases_9th_revision_diagnoses.unique_row_identifier IS 'Unique identifier for each row in the table.';
COMMENT ON COLUMN international_classification_of_diseases_9th_revision_diagnoses.abbreviated_title IS 'The abbreviated title associated with the ICD code.';

CREATE TABLE international_classification_of_diseases_9th_revision_procedures (
    icd_code VARCHAR(10),
    full_title VARCHAR(255),
    unique_row_identifier INT,
    abbreviated_title VARCHAR(50)
);

COMMENT ON TABLE international_classification_of_diseases_9th_revision_procedures IS 'This table contains a dictionary for the International Classification of Diseases, 9th Revision (Procedures).';
COMMENT ON COLUMN international_classification_of_diseases_9th_revision_procedures.icd_code IS 'ICD Code - note that this is a fixed length character field, as whitespaces are important in uniquely identifying ICD codes.';
COMMENT ON COLUMN international_classification_of_diseases_9th_revision_procedures.full_title IS 'Full title associated with the code.';
COMMENT ON COLUMN international_classification_of_diseases_9th_revision_procedures.unique_row_identifier IS 'Primary Key. Unique row identifier.';
COMMENT ON COLUMN international_classification_of_diseases_9th_revision_procedures.abbreviated_title IS 'Abbreviated title associated with the code.';

CREATE TABLE laboratory_items_dictionary (
    item_category VARCHAR(100),
    associated_fluid VARCHAR(100),
    charted_item_id INT,
    item_label VARCHAR(100),
    loinc_identifiers VARCHAR(100),
    unique_row_identifier INT
);

COMMENT ON TABLE laboratory_items_dictionary IS 'This table contains laboratory related items and their details.';
COMMENT ON COLUMN laboratory_items_dictionary.item_category IS 'Category of the laboratory item, for example chemistry or hematology.';
COMMENT ON COLUMN laboratory_items_dictionary.associated_fluid IS 'Fluid associated with the laboratory item, for example blood or urine.';
COMMENT ON COLUMN laboratory_items_dictionary.charted_item_id IS 'Foreign Key. Identifies the laboratory item.';
COMMENT ON COLUMN laboratory_items_dictionary.item_label IS 'Label identifying the laboratory item.';
COMMENT ON COLUMN laboratory_items_dictionary.loinc_identifiers IS 'Logical Observation Identifiers Names and Codes (LOINC) mapped to the laboratory item, if available.';
COMMENT ON COLUMN laboratory_items_dictionary.unique_row_identifier IS 'Unique row identifier for the laboratory item in the table.';

CREATE TABLE non_laboratory_charted_items_dictionary (
    item_abbreviation VARCHAR(100),
    item_category VARCHAR(100),
    concept_identifier INT,
    item_source_database VARCHAR(20),
    charted_item_id INT,
    item_label VARCHAR(200),
    corresponding_table VARCHAR(50),
    item_type VARCHAR(30),
    unique_row_identifier INT,
    item_unit VARCHAR(100)
);

COMMENT ON TABLE non_laboratory_charted_items_dictionary IS 'This table contains dictionary of non-laboratory related charted items. Such items are necessary for patient care and facilitates the smooth operation of an organization.';
COMMENT ON COLUMN non_laboratory_charted_items_dictionary.item_abbreviation IS 'Abbreviation associated with the item.';
COMMENT ON COLUMN non_laboratory_charted_items_dictionary.item_category IS 'Category of data which the concept falls under.';
COMMENT ON COLUMN non_laboratory_charted_items_dictionary.concept_identifier IS 'Identifier used to harmonize concepts identified by multiple ITEMIDs. CONCEPTIDs are planned but not yet implemented (all values are NULL).';
COMMENT ON COLUMN non_laboratory_charted_items_dictionary.item_source_database IS 'Source database of the item.';
COMMENT ON COLUMN non_laboratory_charted_items_dictionary.charted_item_id IS 'Primary key. Identifies the charted item.';
COMMENT ON COLUMN non_laboratory_charted_items_dictionary.item_label IS 'Label identifying the item.';
COMMENT ON COLUMN non_laboratory_charted_items_dictionary.corresponding_table IS 'Table which contains data for the given ITEMID.';
COMMENT ON COLUMN non_laboratory_charted_items_dictionary.item_type IS 'Type of item, for example solution or ingredient.';
COMMENT ON COLUMN non_laboratory_charted_items_dictionary.unique_row_identifier IS 'Unique row identifier. Primary Key.';
COMMENT ON COLUMN non_laboratory_charted_items_dictionary.item_unit IS 'Unit associated with the item.';

CREATE TABLE patient_chart_events (
    caregiver_id INT,
    event_time TIMESTAMP(0),
    error_flag INT,
    hospital_admission_id INT,
    ICU_stay_id INT,
    charted_item_id INT,
    lab_result_status VARCHAR(50),
    unique_row_identifier INT,
    stopped_status VARCHAR(50),
    recorded_time TIMESTAMP(0),
    patient_identifier INT,
    event_value VARCHAR(255),
    event_value_number DOUBLE,
    measurement_unit VARCHAR(50),
    warning_flag INT
);

COMMENT ON TABLE patient_chart_events IS 'This table contains events that occur on a patient's chart.';
COMMENT ON COLUMN patient_chart_events.caregiver_id IS 'Foreign Key. Identifies the caregiver responsible for the event.';
COMMENT ON COLUMN patient_chart_events.event_time IS 'The time when the event occurred.';
COMMENT ON COLUMN patient_chart_events.error_flag IS 'A flag indicating whether an error exists with the event.';
COMMENT ON COLUMN patient_chart_events.hospital_admission_id IS 'Foreign Key. Identifies the hospital stay associated with the event.';
COMMENT ON COLUMN patient_chart_events.ICU_stay_id IS 'Foreign Key. Identifies the ICU stay associated with the event.';
COMMENT ON COLUMN patient_chart_events.charted_item_id IS 'Foreign Key. Identifies the charted item associated with the event.';
COMMENT ON COLUMN patient_chart_events.lab_result_status IS 'The status of the result of the lab data.';
COMMENT ON COLUMN patient_chart_events.unique_row_identifier IS 'Unique identifier used to identify each row in the table.';
COMMENT ON COLUMN patient_chart_events.stopped_status IS 'A text string indicating the stopped status of an event (i.e. stopped, not stopped).';
COMMENT ON COLUMN patient_chart_events.recorded_time IS 'The time when the event was recorded in the system.';
COMMENT ON COLUMN patient_chart_events.patient_identifier IS 'Foreign Key. Identifies the patient associated with the event.';
COMMENT ON COLUMN patient_chart_events.event_value IS 'The value of the event as a text string.';
COMMENT ON COLUMN patient_chart_events.event_value_number IS 'The value of the event as a number.';
COMMENT ON COLUMN patient_chart_events.measurement_unit IS 'The unit of measurement used for the event value.';
COMMENT ON COLUMN patient_chart_events.warning_flag IS 'A flag indicating whether the event has triggered a warning.';

CREATE TABLE procedure_events (
    event_date TIMESTAMP(0),
    recording_center VARCHAR(10),
    cpt_code VARCHAR(10),
    cpt_code_number INT,
    cpt_code_suffix VARCHAR(5),
    cpt_description VARCHAR(200),
    hospital_admission_id INT,
    unique_row_identifier INT,
    cpt_section VARCHAR(50),
    patient_identifier INT,
    cpt_subsection VARCHAR(255),
    event_sequence_number INT
);

COMMENT ON TABLE procedure_events IS 'This table contains information about Current Procedural Terminology (CPT) codes for medical procedures.';
COMMENT ON COLUMN procedure_events.event_date IS 'Date when the event occurred, if available.';
COMMENT ON COLUMN procedure_events.recording_center IS 'Center recording the code, for example the ICU or the respiratory unit.';
COMMENT ON COLUMN procedure_events.cpt_code IS 'Current Procedural Terminology code.';
COMMENT ON COLUMN procedure_events.cpt_code_number IS 'Numerical element of the Current Procedural Terminology code.';
COMMENT ON COLUMN procedure_events.cpt_code_suffix IS 'Text element indicating code category the Current Procedural Terminology, if any.';
COMMENT ON COLUMN procedure_events.cpt_description IS 'Description of the Current Procedural Terminology, if available.';
COMMENT ON COLUMN procedure_events.hospital_admission_id IS 'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN procedure_events.unique_row_identifier IS 'Unique row identifier, used as primary key.';
COMMENT ON COLUMN procedure_events.cpt_section IS 'High-level section of the Current Procedural Terminology code.';
COMMENT ON COLUMN procedure_events.patient_identifier IS 'Foreign key. Identifies the patient.';
COMMENT ON COLUMN procedure_events.cpt_subsection IS 'Subsection of the Current Procedural Terminology code.';
COMMENT ON COLUMN procedure_events.event_sequence_number IS 'Sequence number of the event, derived from the ticket ID.';

CREATE TABLE time_related_events (
    caregiver_id INT,
    event_time TIMESTAMP(0),
    error_flag SMALLINT,
    hospital_admission_id INT,
    ICU_stay_id INT,
    charted_item_id INT,
    lab_result_status VARCHAR(50),
    unique_row_identifier INT,
    stopped_status VARCHAR(50),
    recorded_time TIMESTAMP(0),
    patient_identifier INT,
    event_value TIMESTAMP(0),
    measurement_unit VARCHAR(50),
    warning_flag SMALLINT
);

COMMENT ON TABLE time_related_events IS 'This table contains events that are related to time across hospital stays and ICU stays.';
COMMENT ON COLUMN time_related_events.caregiver_id IS 'Foreign Key. Identifies the caregiver who recorded the event.';
COMMENT ON COLUMN time_related_events.event_time IS 'The time at which the event occurred.';
COMMENT ON COLUMN time_related_events.error_flag IS 'A flag to indicate if there was an error with the event.';
COMMENT ON COLUMN time_related_events.hospital_admission_id IS 'Foreign Key. Identifies the hospital admission of the patient.';
COMMENT ON COLUMN time_related_events.ICU_stay_id IS 'Foreign Key. Identifies the ICU stay of the patient.';
COMMENT ON COLUMN time_related_events.charted_item_id IS 'Foreign Key. Identifies the charted item related to the event.';
COMMENT ON COLUMN time_related_events.lab_result_status IS 'Result status of laboratory data associated with event.';
COMMENT ON COLUMN time_related_events.unique_row_identifier IS 'Unique identifier for each row in the table.';
COMMENT ON COLUMN time_related_events.stopped_status IS 'A flag to indicate if the event was explicitly stopped by the caregiver. This is infrequently used.';
COMMENT ON COLUMN time_related_events.recorded_time IS 'The time at which the event was recorded into the system.';
COMMENT ON COLUMN time_related_events.patient_identifier IS 'Foreign Key. Identifies the patient associated with the event.';
COMMENT ON COLUMN time_related_events.event_value IS 'The value associated with the event as a text string.';
COMMENT ON COLUMN time_related_events.measurement_unit IS 'The unit of measurement.';
COMMENT ON COLUMN time_related_events.warning_flag IS 'A flag to indicate if the value of the event has triggered a warning.';