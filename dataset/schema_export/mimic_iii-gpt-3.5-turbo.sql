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

CREATE TABLE carevue_fluid_input_data (
    administered_amount DOUBLE,
    administered_amount_unit VARCHAR(30),
    caregiver_identifier INT,
    event_time TIMESTAMP(0),
    hospital_admission_identifier INT,
    ICU_stay_identifier INT,
    charted_item_identifier INT,
    linked_order_identifier INT,
    new_bottle_status INT,
    grouped_item_identifier INT,
    original_charted_amount DOUBLE,
    original_charted_amount_unit VARCHAR(30),
    original_administration_rate DOUBLE,
    original_administration_rate_unit VARCHAR(30),
    originally_chosen_route VARCHAR(30),
    originally_chosen_site VARCHAR(30),
    administered_rate DOUBLE,
    administered_rate_unit VARCHAR(30),
    unique_row_identifier INT,
    stopped_status VARCHAR(30),
    recorded_time TIMESTAMP(0),
    patient_identifier INT
);

COMMENT ON TABLE carevue_fluid_input_data IS 'This table contains event details relating to fluid input for patients whose data was originally stored in the CareVue database.';
COMMENT ON COLUMN carevue_fluid_input_data.administered_amount IS 'Amount of the administered item. Type: Numeric';
COMMENT ON COLUMN carevue_fluid_input_data.administered_amount_unit IS 'Unit of measurement for the administered amount. Type: Text';
COMMENT ON COLUMN carevue_fluid_input_data.caregiver_identifier IS 'Foreign Key. Identifier of the caregiver. Type: Integer';
COMMENT ON COLUMN carevue_fluid_input_data.event_time IS 'Time that the input was started or received. Type: Datetime';
COMMENT ON COLUMN carevue_fluid_input_data.hospital_admission_identifier IS 'Foreign Key. Identifier of the hospital stay. Type: Integer';
COMMENT ON COLUMN carevue_fluid_input_data.ICU_stay_identifier IS 'Foreign Key. Identifier of the ICU stay. Type: Integer';
COMMENT ON COLUMN carevue_fluid_input_data.charted_item_identifier IS 'Foreign Key. Identifier of the charted item. Type: Integer';
COMMENT ON COLUMN carevue_fluid_input_data.linked_order_identifier IS 'Identifier linking orders across multiple administrations. Linked to the first occurring order identifier of the series. Type: Integer';
COMMENT ON COLUMN carevue_fluid_input_data.new_bottle_status IS 'Indicates when a new bottle of the solution was hung at the bedside. Type: Boolean';
COMMENT ON COLUMN carevue_fluid_input_data.grouped_item_identifier IS 'Identifier linking items which are grouped in a solution. Type: Integer';
COMMENT ON COLUMN carevue_fluid_input_data.original_charted_amount IS 'Amount of the item which is originally charted. Type: Numeric';
COMMENT ON COLUMN carevue_fluid_input_data.original_charted_amount_unit IS 'Unit of measurement for the original charted amount. Type: Text';
COMMENT ON COLUMN carevue_fluid_input_data.original_administration_rate IS 'Rate of administration originally chosen for the item. Type: Numeric';
COMMENT ON COLUMN carevue_fluid_input_data.original_administration_rate_unit IS 'Unit of measurement for the rate originally chosen. Type: Text';
COMMENT ON COLUMN carevue_fluid_input_data.originally_chosen_route IS 'Route of administration originally chosen for the item. Type: Text';
COMMENT ON COLUMN carevue_fluid_input_data.originally_chosen_site IS 'Anatomical site for the original administration of the item. Type: Text';
COMMENT ON COLUMN carevue_fluid_input_data.administered_rate IS 'Rate at which the item is being administered to the patient. Type: Numeric';
COMMENT ON COLUMN carevue_fluid_input_data.administered_rate_unit IS 'Unit of measurement for the administered rate. Type: Text';
COMMENT ON COLUMN carevue_fluid_input_data.unique_row_identifier IS 'Unique row identifier. Type: Integer';
COMMENT ON COLUMN carevue_fluid_input_data.stopped_status IS 'Event was explicitly marked as stopped. Infrequently used by caregivers. Type: Boolean';
COMMENT ON COLUMN carevue_fluid_input_data.recorded_time IS 'Time when the event was recorded in the system. Type: Datetime';
COMMENT ON COLUMN carevue_fluid_input_data.patient_identifier IS 'Foreign Key. Identifier of the patient. Type: Integer';

CREATE TABLE diagnosis_related_groups (
    drg_description VARCHAR(255),
    drg_identifier VARCHAR(20),
    drg_relative_mortality SMALLINT,
    drg_relative_severity SMALLINT,
    drg_classification VARCHAR(20),
    hospital_admission_id INT,
    unique_row_identifier INT,
    patient_identifier INT
);

COMMENT ON TABLE diagnosis_related_groups IS 'This table contains diagnosis-related groups assigned to patients by the hospital for obtaining reimbursements. The codes correspond to the primary reason for a patient's hospital stay.';
COMMENT ON COLUMN diagnosis_related_groups.drg_description IS 'Description of the diagnosis-related group. Type: Text';
COMMENT ON COLUMN diagnosis_related_groups.drg_identifier IS 'Diagnosis-related group code. Type: Text';
COMMENT ON COLUMN diagnosis_related_groups.drg_relative_mortality IS 'Relative mortality, available for type APR only. Type: Small Integer';
COMMENT ON COLUMN diagnosis_related_groups.drg_relative_severity IS 'Relative severity, available for type APR only. Type: Small Integer';
COMMENT ON COLUMN diagnosis_related_groups.drg_classification IS 'Type of diagnosis-related group, for example APR is All Patient Refined. Type: Text';
COMMENT ON COLUMN diagnosis_related_groups.hospital_admission_id IS 'Foreign Key. A reference to the hospital admission table. Type: Integer';
COMMENT ON COLUMN diagnosis_related_groups.unique_row_identifier IS 'Unique row identifier. Type: Integer';
COMMENT ON COLUMN diagnosis_related_groups.patient_identifier IS 'Foreign Key. A reference to the patient table. Type: Integer';

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
    time_of_emergency_department_discharge TIMESTAMP(0),
    time_of_emergency_department_registration TIMESTAMP(0),
    ethnicity_type VARCHAR(200),
    hospital_admission_id INT,
    has_chart_events_data SMALLINT,
    hospital_expire_flag SMALLINT,
    insurance_type VARCHAR(255),
    language_type VARCHAR(10),
    marital_status_type VARCHAR(50),
    religion_type VARCHAR(50),
    unique_row_identifier INT,
    patient_identifier INT
);

COMMENT ON TABLE hospital_admissions IS 'This table contains information regarding a patient's admission to the hospital, including timing information for admission and discharge, demographic information, and the source of admission.';
COMMENT ON COLUMN hospital_admissions.location_of_admission IS 'The location where the patient was prior to arriving at the hospital.';
COMMENT ON COLUMN hospital_admissions.type_of_admission IS 'Describes the type of the admission: ELECTIVE, URGENT, NEWBORN, or EMERGENCY.';
COMMENT ON COLUMN hospital_admissions.time_of_admission IS 'Date and time the patient was admitted to the hospital.';
COMMENT ON COLUMN hospital_admissions.time_of_death IS 'Time of in-hospital death for the patient, if applicable. Usually the same as DISCHTIME, but discrepancies can occur due to typographical errors.';
COMMENT ON COLUMN hospital_admissions.diagnosis_description IS 'Preliminary, free text diagnosis for the patient on hospital admission. Assigned by the admitting clinician.';
COMMENT ON COLUMN hospital_admissions.location_of_discharge IS 'The location where the patient was discharged.';
COMMENT ON COLUMN hospital_admissions.time_of_discharge IS 'Date and time the patient was discharged from the hospital.';
COMMENT ON COLUMN hospital_admissions.time_of_emergency_department_discharge IS 'Time that the patient was discharged from the emergency department.';
COMMENT ON COLUMN hospital_admissions.time_of_emergency_department_registration IS 'Time that the patient was registered in the emergency department.';
COMMENT ON COLUMN hospital_admissions.ethnicity_type IS 'Ethnicity of the patient. Sourced from the admission, discharge, and transfers (ADT) data from the hospital database.';
COMMENT ON COLUMN hospital_admissions.hospital_admission_id IS 'Unique identifier for a single patient's admission to the hospital. Ranges from 1000000 - 1999999.';
COMMENT ON COLUMN hospital_admissions.has_chart_events_data IS 'Indicates whether chart events data is available for this admission.';
COMMENT ON COLUMN hospital_admissions.hospital_expire_flag IS 'Indicates whether the patient died within the given hospitalization. 1 indicates death in the hospital, 0 indicates survival to hospital discharge.';
COMMENT ON COLUMN hospital_admissions.insurance_type IS 'Describes the patient's insurance information. Sourced from the admission, discharge, and transfers (ADT) data from the hospital database.';
COMMENT ON COLUMN hospital_admissions.language_type IS 'Language spoken by the patient. Sourced from the admission, discharge, and transfers (ADT) data from the hospital database.';
COMMENT ON COLUMN hospital_admissions.marital_status_type IS 'Marital status of the patient. Sourced from the admission, discharge, and transfers (ADT) data from the hospital database.';
COMMENT ON COLUMN hospital_admissions.religion_type IS 'Religion of the patient. Sourced from the admission, discharge, and transfers (ADT) data from the hospital database.';
COMMENT ON COLUMN hospital_admissions.unique_row_identifier IS 'Unique identifier for the row.';
COMMENT ON COLUMN hospital_admissions.patient_identifier IS 'Unique identifier for the patient. Can be linked to the PATIENTS table using this identifier.';

CREATE TABLE hospital_note_records (
    note_category VARCHAR(50),
    caregiver_id INT,
    event_date TIMESTAMP(0),
    event_time TIMESTAMP(0),
    note_description VARCHAR(255),
    hospital_admission_id INT,
    error_flag CHAR(1),
    unique_row_identifier INT,
    recorded_time TIMESTAMP(0),
    patient_identifier INT,
    note_content TEXT
);

COMMENT ON TABLE hospital_note_records IS 'This table contains notes associated with hospital stays.';
COMMENT ON COLUMN hospital_note_records.note_category IS 'Category of the note, such as discharge summary.';
COMMENT ON COLUMN hospital_note_records.caregiver_id IS 'Foreign Key. Identifies the caregiver who made the note.';
COMMENT ON COLUMN hospital_note_records.event_date IS 'Date when the note was created.';
COMMENT ON COLUMN hospital_note_records.event_time IS 'Date and time when the note was created. Note that some notes (e.g. discharge summaries) do not have a time associated with them: these notes have NULL in this column.';
COMMENT ON COLUMN hospital_note_records.note_description IS 'A more detailed categorization for the note, sometimes entered by free-text.';
COMMENT ON COLUMN hospital_note_records.hospital_admission_id IS 'Foreign Key. Identifies the hospital stay related to the note.';
COMMENT ON COLUMN hospital_note_records.error_flag IS 'Flag to highlight an error with the note.';
COMMENT ON COLUMN hospital_note_records.unique_row_identifier IS 'Unique row identifier.';
COMMENT ON COLUMN hospital_note_records.recorded_time IS 'STORETIME records the date and time at which a note was saved into the system. Notes with a CATEGORY value of ‘Discharge Summary’, ‘ECG’, ‘Radiology’, and ‘Echo’ never have a STORETIME. All other notes have a STORETIME.';
COMMENT ON COLUMN hospital_note_records.patient_identifier IS 'Foreign Key. Identifies the patient related to the note.';
COMMENT ON COLUMN hospital_note_records.note_content IS 'Content of the note.';

CREATE TABLE hospital_services (
    current_service_type VARCHAR(20),
    hospital_admission_id INT,
    previous_service_type VARCHAR(20),
    unique_row_identifier INT,
    patient_identifier INT,
    transfer_time TIMESTAMP(0)
);

COMMENT ON TABLE hospital_services IS 'This table contains details of hospital services that patients were under during their hospital stay.';
COMMENT ON COLUMN hospital_services.current_service_type IS 'The type of current service. Type: Text';
COMMENT ON COLUMN hospital_services.hospital_admission_id IS 'Foreign Key. Identifies the hospital stay. Type: Integer';
COMMENT ON COLUMN hospital_services.previous_service_type IS 'The type of previous service. Type: Text';
COMMENT ON COLUMN hospital_services.unique_row_identifier IS 'Primary Key. A unique identifier used to identify each row in the table. Type: Integer';
COMMENT ON COLUMN hospital_services.patient_identifier IS 'Foreign Key. Identifies the patient. Type: Integer';
COMMENT ON COLUMN hospital_services.transfer_time IS 'The time when the transfer occurred. Type: Time';

CREATE TABLE icd9_procedures (
    icd_code VARCHAR(10),
    full_title VARCHAR(255),
    unique_row_identifier INT,
    abbreviated_title VARCHAR(50)
);

COMMENT ON TABLE icd9_procedures IS 'This table contains International Classification of Diseases Version 9 (ICD-9) codes for procedures assigned at the end of a patient's stay to bill for care provided and identify if certain procedures have been performed (e.g. surgery).';
COMMENT ON COLUMN icd9_procedures.icd_code IS 'Fixed length character field used to uniquely identify ICD-9 codes. Type: varchar(10)';
COMMENT ON COLUMN icd9_procedures.full_title IS 'Long title associated with the code. Type: varchar(255)';
COMMENT ON COLUMN icd9_procedures.unique_row_identifier IS 'Primary Key. Unique row identifier. Type: int';
COMMENT ON COLUMN icd9_procedures.abbreviated_title IS 'Short title associated with the code. Type: varchar(50)';

CREATE TABLE icd_procedures (
    hospital_admission_id INT,
    icd_code VARCHAR(10),
    unique_row_identifier INT,
    code_priority INT,
    patient_identifier INT
);

COMMENT ON TABLE icd_procedures IS 'This table contains procedures relating to a hospital admission coded using the International Classification of Diseases 9th Revision (ICD-9) system.';
COMMENT ON COLUMN icd_procedures.hospital_admission_id IS 'Foreign Key. A reference to hospital admission table. Type: Integer';
COMMENT ON COLUMN icd_procedures.icd_code IS 'The ICD-9 code associated with the procedure. Type: Text';
COMMENT ON COLUMN icd_procedures.unique_row_identifier IS 'Primary Key. A unique identifier used to uniquely identify each procedure in the table. Type: Integer';
COMMENT ON COLUMN icd_procedures.code_priority IS 'The priority of the procedure. Lower numbers indicate earlier occurrence. Type: Integer';
COMMENT ON COLUMN icd_procedures.patient_identifier IS 'Foreign Key. Identifies the patient. Type: Integer';

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

CREATE TABLE laboratory_tests (
    event_time TIMESTAMP(0),
    abnormal_flag VARCHAR(20),
    hospital_admission_id INT,
    charted_item_id INT,
    unique_row_identifier INT,
    patient_identifier INT,
    event_value VARCHAR(200),
    event_value_number DOUBLE,
    measurement_unit VARCHAR(20)
);

COMMENT ON TABLE laboratory_tests IS 'This table contains events relating to laboratory tests.';
COMMENT ON COLUMN laboratory_tests.event_time IS 'Time when the laboratory test event occured.';
COMMENT ON COLUMN laboratory_tests.abnormal_flag IS 'Flag indicating whether the laboratory test value is considered abnormal. Null if the test was normal.';
COMMENT ON COLUMN laboratory_tests.hospital_admission_id IS 'Foreign Key. Identifies the hospital stay.';
COMMENT ON COLUMN laboratory_tests.charted_item_id IS 'Foreign Key. Identifies the charted laboratory test item.';
COMMENT ON COLUMN laboratory_tests.unique_row_identifier IS 'A unique identifier for each row in the table.';
COMMENT ON COLUMN laboratory_tests.patient_identifier IS 'Foreign Key. Identifies the patient.';
COMMENT ON COLUMN laboratory_tests.event_value IS 'Value of the laboratory test event as a text string.';
COMMENT ON COLUMN laboratory_tests.event_value_number IS 'Value of the laboratory test event as a number.';
COMMENT ON COLUMN laboratory_tests.measurement_unit IS 'Unit of measurement for the laboratory test.';

CREATE TABLE medication_prescriptions (
    dose_unit VARCHAR(120),
    dose_value VARCHAR(120),
    drug_name_brand VARCHAR(100),
    drug_name_generic VARCHAR(100),
    drug_name_provider_order_entry VARCHAR(100),
    drug_type VARCHAR(100),
    end_date TIMESTAMP(0),
    formulation_unit VARCHAR(120),
    formulation_amount VARCHAR(120),
    formulary_drug_code VARCHAR(120),
    generic_sequence_number VARCHAR(200),
    hospital_admission_id INT,
    ICU_stay_id INT,
    national_drug_code VARCHAR(120),
    drug_strength VARCHAR(120),
    administration_route VARCHAR(120),
    unique_row_identifier INT,
    start_date TIMESTAMP(0),
    patient_identifier INT
);

COMMENT ON TABLE medication_prescriptions IS 'This table contains details of medicines prescribed to patients during their hospitalization.';
COMMENT ON COLUMN medication_prescriptions.dose_unit IS 'Unit of measurement associated with the dose. Type: Text';
COMMENT ON COLUMN medication_prescriptions.dose_value IS 'Dose of the drug prescribed. Type: Float';
COMMENT ON COLUMN medication_prescriptions.drug_name_brand IS 'Brand name of the drug. Type: Text';
COMMENT ON COLUMN medication_prescriptions.drug_name_generic IS 'Generic drug name. Type: Text';
COMMENT ON COLUMN medication_prescriptions.drug_name_provider_order_entry IS 'Name of the drug on the Provider Order Entry interface. Type: Text';
COMMENT ON COLUMN medication_prescriptions.drug_type IS 'Type of drug. Type: Text';
COMMENT ON COLUMN medication_prescriptions.end_date IS 'Date when the prescription ended. Type: Date';
COMMENT ON COLUMN medication_prescriptions.formulation_unit IS 'Unit of measurement associated with the formulation. Type: Text';
COMMENT ON COLUMN medication_prescriptions.formulation_amount IS 'Amount of the formulation dispensed. Type: Float';
COMMENT ON COLUMN medication_prescriptions.formulary_drug_code IS 'Formulary drug code. Type: Text';
COMMENT ON COLUMN medication_prescriptions.generic_sequence_number IS 'Generic Sequence Number. Type: Text';
COMMENT ON COLUMN medication_prescriptions.hospital_admission_id IS 'Foreign key. Identifies the hospital stay. Type: Integer';
COMMENT ON COLUMN medication_prescriptions.ICU_stay_id IS 'Foreign key. Identifies the ICU stay. Type: Integer';
COMMENT ON COLUMN medication_prescriptions.national_drug_code IS 'National Drug Code. Type: Text';
COMMENT ON COLUMN medication_prescriptions.drug_strength IS 'Strength of the drug (product). Type: Text';
COMMENT ON COLUMN medication_prescriptions.administration_route IS 'Route of drug administration, for example intravenous or oral. Type: Text';
COMMENT ON COLUMN medication_prescriptions.unique_row_identifier IS 'Unique row identifier. Type: Integer';
COMMENT ON COLUMN medication_prescriptions.start_date IS 'Date when the prescription started. Type: Date';
COMMENT ON COLUMN medication_prescriptions.patient_identifier IS 'Foreign key. Identifies the patient. Type: Integer';

CREATE TABLE metavision_fluid_input_data (
    administered_amount DOUBLE,
    administered_amount_unit VARCHAR(30),
    cancellation_reason SMALLINT,
    caregiver_id INT,
    caregiver_who_canceled_order VARCHAR(40),
    caregiver_edit_time TIMESTAMP(0),
    caregiver_who_edited_order VARCHAR(30),
    continue_in_next_department SMALLINT,
    event_end_time TIMESTAMP(0),
    hospital_admission_id INT,
    ICU_stay_id INT,
    open_bag_indicator SMALLINT,
    charted_item_id INT,
    linked_order_identifier INT,
    administered_item_type_description VARCHAR(50),
    administered_item_group VARCHAR(100),
    administered_item_role_description VARCHAR(200),
    grouped_item_identifier INT,
    original_charted_amount DOUBLE,
    original_administration_rate DOUBLE,
    weight_for_dose_calculation DOUBLE,
    administered_rate DOUBLE,
    administered_rate_unit VARCHAR(30),
    unique_row_identifier INT,
    secondary_administered_item_group VARCHAR(100),
    event_start_time TIMESTAMP(0),
    order_status_description VARCHAR(30),
    recorded_time TIMESTAMP(0),
    patient_identifier INT,
    solution_total_amount DOUBLE,
    solution_total_amount_unit VARCHAR(50)
);

COMMENT ON TABLE metavision_fluid_input_data IS 'This table contains events relating to fluid input for patients whose data was originally stored in the MetaVision database.';
COMMENT ON COLUMN metavision_fluid_input_data.administered_amount IS 'Amount of the item administered to the patient.';
COMMENT ON COLUMN metavision_fluid_input_data.administered_amount_unit IS 'Unit of measurement for the amount.';
COMMENT ON COLUMN metavision_fluid_input_data.cancellation_reason IS 'Reason for cancellation, if cancelled.';
COMMENT ON COLUMN metavision_fluid_input_data.caregiver_id IS 'Foreign key. Identifies the caregiver.';
COMMENT ON COLUMN metavision_fluid_input_data.caregiver_who_canceled_order IS 'The title of the caregiver who canceled the order.';
COMMENT ON COLUMN metavision_fluid_input_data.caregiver_edit_time IS 'Time at which the caregiver edited or cancelled the order.';
COMMENT ON COLUMN metavision_fluid_input_data.caregiver_who_edited_order IS 'The title of the caregiver who edited the order.';
COMMENT ON COLUMN metavision_fluid_input_data.continue_in_next_department IS 'Indicates whether the item will be continued in the next department where the patient is transferred to.';
COMMENT ON COLUMN metavision_fluid_input_data.event_end_time IS 'Time when the event ended.';
COMMENT ON COLUMN metavision_fluid_input_data.hospital_admission_id IS 'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN metavision_fluid_input_data.ICU_stay_id IS 'Foreign key. Identifies the ICU stay.';
COMMENT ON COLUMN metavision_fluid_input_data.open_bag_indicator IS 'Indicates whether the bag containing the solution is open.';
COMMENT ON COLUMN metavision_fluid_input_data.charted_item_id IS 'Foreign key. Identifies the charted item.';
COMMENT ON COLUMN metavision_fluid_input_data.linked_order_identifier IS 'Identifier linking orders across multiple administrations. LINKORDERID is always equal to the first occuring ORDERID of the series.';
COMMENT ON COLUMN metavision_fluid_input_data.administered_item_type_description IS 'The type of item administered.';
COMMENT ON COLUMN metavision_fluid_input_data.administered_item_group IS 'A group which the item corresponds to.';
COMMENT ON COLUMN metavision_fluid_input_data.administered_item_role_description IS 'The role of the item administered in the order.';
COMMENT ON COLUMN metavision_fluid_input_data.grouped_item_identifier IS 'Identifier linking items which are grouped in a solution.';
COMMENT ON COLUMN metavision_fluid_input_data.original_charted_amount IS 'Amount of the item which was originally charted.';
COMMENT ON COLUMN metavision_fluid_input_data.original_administration_rate IS 'Rate of administration originally chosen for the item.';
COMMENT ON COLUMN metavision_fluid_input_data.weight_for_dose_calculation IS 'For drugs dosed by weight, the value of the weight used in the calculation.';
COMMENT ON COLUMN metavision_fluid_input_data.administered_rate IS 'Rate at which the item is being administered to the patient.';
COMMENT ON COLUMN metavision_fluid_input_data.administered_rate_unit IS 'Unit of measurement for the rate.';
COMMENT ON COLUMN metavision_fluid_input_data.unique_row_identifier IS 'Unique row identifier.';
COMMENT ON COLUMN metavision_fluid_input_data.secondary_administered_item_group IS 'A secondary group for those items with more than one grouping possible.';
COMMENT ON COLUMN metavision_fluid_input_data.event_start_time IS 'Time when the event started.';
COMMENT ON COLUMN metavision_fluid_input_data.order_status_description IS 'The current status of the order: stopped, rewritten, running or cancelled.';
COMMENT ON COLUMN metavision_fluid_input_data.recorded_time IS 'Time when the event was recorded in the system.';
COMMENT ON COLUMN metavision_fluid_input_data.patient_identifier IS 'Foreign key. Identifies the patient.';
COMMENT ON COLUMN metavision_fluid_input_data.solution_total_amount IS 'The total amount in the solution for the given item.';
COMMENT ON COLUMN metavision_fluid_input_data.solution_total_amount_unit IS 'Unit of measurement for the total amount in the solution.';

CREATE TABLE metavision_procedure_events (
    cancellation_reason SMALLINT,
    caregiver_id INT,
    caregiver_who_canceled_order VARCHAR(30),
    caregiver_edit_time TIMESTAMP(0),
    caregiver_who_edited_order VARCHAR(30),
    continue_in_next_department SMALLINT,
    event_end_time TIMESTAMP(0),
    hospital_admission_id INT,
    ICU_stay_id INT,
    open_bag_indicator SMALLINT,
    charted_item_id INT,
    linked_order_identifier INT,
    procedure_location VARCHAR(30),
    procedure_location_category VARCHAR(30),
    administered_item_type_description VARCHAR(50),
    administered_item_group VARCHAR(100),
    grouped_item_identifier INT,
    unique_row_identifier INT,
    secondary_administered_item_group VARCHAR(100),
    event_start_time TIMESTAMP(0),
    order_status_description VARCHAR(30),
    recorded_time TIMESTAMP(0),
    patient_identifier INT,
    event_value DOUBLE,
    measurement_unit VARCHAR(30)
);

COMMENT ON TABLE metavision_procedure_events IS 'This table contains information about procedures performed on patients.';
COMMENT ON COLUMN metavision_procedure_events.cancellation_reason IS 'Reason for canceling the procedure.';
COMMENT ON COLUMN metavision_procedure_events.caregiver_id IS 'Identifier for each caregiver. The identification number of the provider associated with the procedure record, for example, the provider who performed the procedure.';
COMMENT ON COLUMN metavision_procedure_events.caregiver_who_canceled_order IS 'Identifier of the person who canceled the comments.';
COMMENT ON COLUMN metavision_procedure_events.caregiver_edit_time IS 'Date when the comments were made.';
COMMENT ON COLUMN metavision_procedure_events.caregiver_who_edited_order IS 'Identifier of the person who edited the comments.';
COMMENT ON COLUMN metavision_procedure_events.continue_in_next_department IS 'Indicates if the procedure will continue in the next department.';
COMMENT ON COLUMN metavision_procedure_events.event_end_time IS 'The time the procedure ended.';
COMMENT ON COLUMN metavision_procedure_events.hospital_admission_id IS 'Identifier for each hospital admission. The unique identifier for the visit during which the procedure took place.';
COMMENT ON COLUMN metavision_procedure_events.ICU_stay_id IS 'Identifier for each intensive care unit stay. The identifier for the detailed visit record during which the Procedure took place, such as the Intensive Care Unit stay during the hospital visit.';
COMMENT ON COLUMN metavision_procedure_events.open_bag_indicator IS 'Indicates whether the bag is open.';
COMMENT ON COLUMN metavision_procedure_events.charted_item_id IS 'Identifier for each item in the procedure. This field houses the unique concept identifier for the procedure. This is used primarily for analyses and network studies.';
COMMENT ON COLUMN metavision_procedure_events.linked_order_identifier IS 'Identifier for the linked order associated with the procedure.';
COMMENT ON COLUMN metavision_procedure_events.procedure_location IS 'Location where the procedure was performed.';
COMMENT ON COLUMN metavision_procedure_events.procedure_location_category IS 'Category of the location where the procedure was performed.';
COMMENT ON COLUMN metavision_procedure_events.administered_item_type_description IS 'Description of the order category.';
COMMENT ON COLUMN metavision_procedure_events.administered_item_group IS 'The name of the order category.';
COMMENT ON COLUMN metavision_procedure_events.grouped_item_identifier IS 'Identifier for the order associated with the procedure.';
COMMENT ON COLUMN metavision_procedure_events.unique_row_identifier IS 'Unique identifier for the row.';
COMMENT ON COLUMN metavision_procedure_events.secondary_administered_item_group IS 'The name of the secondary order category.';
COMMENT ON COLUMN metavision_procedure_events.event_start_time IS 'The time the procedure started. The exact time when the procedure happened.';
COMMENT ON COLUMN metavision_procedure_events.order_status_description IS 'Description of the status of the procedure.';
COMMENT ON COLUMN metavision_procedure_events.recorded_time IS 'Records the time at which an observation was manually input or manually validated by a member of the clinical staff.';
COMMENT ON COLUMN metavision_procedure_events.patient_identifier IS 'Identifier for each patient. The unique identifier of the patient for whom the procedure is recorded. This may be a system generated code.';
COMMENT ON COLUMN metavision_procedure_events.event_value IS 'Value of the item in the procedure. The original value from the source data that represents the actual procedure performed.';
COMMENT ON COLUMN metavision_procedure_events.measurement_unit IS 'Unit of measure for the value of the item in the procedure.';

CREATE TABLE microbiology_test_results (
    antibody_identifier INT,
    antibody_name VARCHAR(30),
    event_date TIMESTAMP(0),
    event_time TIMESTAMP(0),
    dilution_comparison VARCHAR(20),
    dilution_amount VARCHAR(10),
    dilution_value DOUBLE,
    hospital_admission_id INT,
    test_interpretation VARCHAR(5),
    isolate_number SMALLINT,
    organism_identifier INT,
    organism_name VARCHAR(100),
    unique_row_identifier INT,
    specimen_identifier INT,
    specimen_description VARCHAR(100),
    patient_identifier INT
);

COMMENT ON TABLE microbiology_test_results IS 'This table contains information on events related to microbiology tests performed during hospital stay.';
COMMENT ON COLUMN microbiology_test_results.antibody_identifier IS 'Foreign Key. Identifies the antibody used in the test.';
COMMENT ON COLUMN microbiology_test_results.antibody_name IS 'Name of the antibody used in the test.';
COMMENT ON COLUMN microbiology_test_results.event_date IS 'The date when the test event occurred.';
COMMENT ON COLUMN microbiology_test_results.event_time IS 'The time when the test event occurred, if available.';
COMMENT ON COLUMN microbiology_test_results.dilution_comparison IS 'The comparison component of Dilution Text: either <= (less than or equal), = (equal), or >= (greater than or equal), or null when not available.';
COMMENT ON COLUMN microbiology_test_results.dilution_amount IS 'The dilution amount tested for and the comparison which was made against it (e.g. <=4).';
COMMENT ON COLUMN microbiology_test_results.dilution_value IS 'The value component of Dilution Text: must be a floating point number.';
COMMENT ON COLUMN microbiology_test_results.hospital_admission_id IS 'Foreign Key. Identifies the hospital stay of the patient.';
COMMENT ON COLUMN microbiology_test_results.test_interpretation IS 'Interpretation of the microbiology test.';
COMMENT ON COLUMN microbiology_test_results.isolate_number IS 'Isolate number associated with the microbiology test.';
COMMENT ON COLUMN microbiology_test_results.organism_identifier IS 'Foreign Key. Identifies the organism found in the test.';
COMMENT ON COLUMN microbiology_test_results.organism_name IS 'Name of the organism found in the test.';
COMMENT ON COLUMN microbiology_test_results.unique_row_identifier IS 'Unique identifier for the row in the table.';
COMMENT ON COLUMN microbiology_test_results.specimen_identifier IS 'Foreign Key. Identifies the specimen used in the microbiology test.';
COMMENT ON COLUMN microbiology_test_results.specimen_description IS 'Description of the specimen used in the microbiology test.';
COMMENT ON COLUMN microbiology_test_results.patient_identifier IS 'Foreign Key. Identifies the patient associated with the test.';

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

CREATE TABLE patient_admission_records (
    date_of_birth TIMESTAMP(0),
    date_of_death TIMESTAMP(0),
    hospital_death_date TIMESTAMP(0),
    ssn_death_date TIMESTAMP(0),
    flag_deceased INT,
    gender VARCHAR(5),
    unique_row_identifier INT,
    patient_identifier INT
);

COMMENT ON TABLE patient_admission_records IS 'This table contains records of patients admitted to the ICU.';
COMMENT ON COLUMN patient_admission_records.date_of_birth IS 'Date of birth of the patient. Type: Date';
COMMENT ON COLUMN patient_admission_records.date_of_death IS 'Date of death of the patient. Null if patient was alive at least 90 days post hospital discharge. Type: Date';
COMMENT ON COLUMN patient_admission_records.hospital_death_date IS 'Date of death recorded in hospital records. Type: Date';
COMMENT ON COLUMN patient_admission_records.ssn_death_date IS 'Date of death recorded in social security records. Type: Date';
COMMENT ON COLUMN patient_admission_records.flag_deceased IS 'Flag indicating if patient is deceased. Type: Boolean';
COMMENT ON COLUMN patient_admission_records.gender IS 'Gender of the patient. Type: Text';
COMMENT ON COLUMN patient_admission_records.unique_row_identifier IS 'Unique identifier for each row in the table. Type: Integer';
COMMENT ON COLUMN patient_admission_records.patient_identifier IS 'Primary Key. Identifier for each patient. Type: Integer';

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

CREATE TABLE patient_diagnoses (
    hospital_admission_id INT,
    icd_code VARCHAR(10),
    unique_row_identifier INT,
    code_priority INT,
    patient_identifier INT
);

COMMENT ON TABLE patient_diagnoses IS 'This table contains a record of all diagnoses a patient was billed for during their hospital stay using the International Classification of Diseases (ICD). Diagnoses are determined by trained persons who read signed clinical notes on hospital discharge.';
COMMENT ON COLUMN patient_diagnoses.hospital_admission_id IS 'Foreign Key. Identifies the hospital stay. Type: Integer';
COMMENT ON COLUMN patient_diagnoses.icd_code IS 'ICD-9 code for the diagnosis. Type: Text';
COMMENT ON COLUMN patient_diagnoses.unique_row_identifier IS 'Primary Key. A unique identifier used to identify each record in the table. Type: Integer';
COMMENT ON COLUMN patient_diagnoses.code_priority IS 'The priority assigned to the diagnoses. The priority can be interpreted as a ranking of which diagnoses are “important”. For example, patients who are diagnosed with sepsis must have sepsis as their 2nd billed condition. Type: Integer';
COMMENT ON COLUMN patient_diagnoses.patient_identifier IS 'Foreign Key. Identifies the patient. Type: Integer';

CREATE TABLE patient_location_history (
    current_icu VARCHAR(20),
    current_ward_id SMALLINT,
    item_source_database VARCHAR(20),
    event_type VARCHAR(20),
    hospital_admission_id INT,
    ICU_stay_id INT,
    admission_time_ICU TIMESTAMP(0),
    ICU_stay_length DOUBLE,
    discharge_time_ICU TIMESTAMP(0),
    previous_icu VARCHAR(20),
    previous_ward_id SMALLINT,
    unique_row_identifier INT,
    patient_identifier INT
);

COMMENT ON TABLE patient_location_history IS 'This table contains information about the location of the patient during their hospital stay.';
COMMENT ON COLUMN patient_location_history.current_icu IS 'Identifier for the current ICU the patient is located in.';
COMMENT ON COLUMN patient_location_history.current_ward_id IS 'Identifier for the current ward the patient is located in.';
COMMENT ON COLUMN patient_location_history.item_source_database IS 'Source database of the item.';
COMMENT ON COLUMN patient_location_history.event_type IS 'Type of event, for example admission or transfer.';
COMMENT ON COLUMN patient_location_history.hospital_admission_id IS 'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN patient_location_history.ICU_stay_id IS 'Foreign key. Identifies the ICU stay.';
COMMENT ON COLUMN patient_location_history.admission_time_ICU IS 'Time when the patient was transferred into the ICU.';
COMMENT ON COLUMN patient_location_history.ICU_stay_length IS 'Length of stay in the ICU in minutes.';
COMMENT ON COLUMN patient_location_history.discharge_time_ICU IS 'Time when the patient was transferred out of the ICU.';
COMMENT ON COLUMN patient_location_history.previous_icu IS 'Identifier for the previous ICU the patient was located in.';
COMMENT ON COLUMN patient_location_history.previous_ward_id IS 'Identifier for the previous ward the patient was located in.';
COMMENT ON COLUMN patient_location_history.unique_row_identifier IS 'Unique row identifier.';
COMMENT ON COLUMN patient_location_history.patient_identifier IS 'Foreign key. Identifies the patient.';

CREATE TABLE patient_output (
    caregiver_id INT,
    event_time TIMESTAMP(0),
    hospital_admission_id INT,
    ICU_stay_id INT,
    error_flag INT,
    charted_item_id INT,
    new_bottle_status CHAR(1),
    unique_row_identifier INT,
    stopped_status VARCHAR(30),
    recorded_time TIMESTAMP(0),
    patient_identifier INT,
    event_value DOUBLE,
    measurement_unit VARCHAR(30)
);

COMMENT ON TABLE patient_output IS 'This table contains output data for patients during their hospital or ICU stay.';
COMMENT ON COLUMN patient_output.caregiver_id IS 'Identifier for the caregiver who validated the given measurement. Type: Integer';
COMMENT ON COLUMN patient_output.event_time IS 'The time of an output event. Type: Datetime';
COMMENT ON COLUMN patient_output.hospital_admission_id IS 'Identifier which is unique to a patient hospital stay. Type: Integer';
COMMENT ON COLUMN patient_output.ICU_stay_id IS 'Identifier which is unique to a patient ICU stay. Type: Integer';
COMMENT ON COLUMN patient_output.error_flag IS 'A checkbox where a caregiver can specify that an observation is an error. No other details are provided. Type: Boolean';
COMMENT ON COLUMN patient_output.charted_item_id IS 'Identifier for a single measurement type in the database. Each row associated with one item ID (e.g. 212) corresponds to an instantiation of the same measurement (e.g. heart rate). A subset of commonly used medications have item ID values between 30000-39999. The remaining input/output item ID values are between 40000-49999. Type: Integer';
COMMENT ON COLUMN patient_output.new_bottle_status IS 'Indicates that a new bag of solution was hung at the given event time. Type: Boolean';
COMMENT ON COLUMN patient_output.unique_row_identifier IS 'Primary key. Type: Integer';
COMMENT ON COLUMN patient_output.stopped_status IS 'Indicates if the order was disconnected at the given event time. Type: Boolean';
COMMENT ON COLUMN patient_output.recorded_time IS 'Records the time at which an observation was manually input or manually validated by a member of the clinical staff. Type: Datetime';
COMMENT ON COLUMN patient_output.patient_identifier IS 'Identifier which is unique to a patient. Type: Integer';
COMMENT ON COLUMN patient_output.event_value IS 'Lists the amount of a substance at the event time (when the exact start time is unknown, but usually up to an hour before). Type: Float';
COMMENT ON COLUMN patient_output.measurement_unit IS 'Lists the unit of measure for the event value at the event time (when the exact start time is unknown, but usually up to an hour before). Type: Text';

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

CREATE TABLE procedure_terminology (
    item_category SMALLINT,
    terminology_text VARCHAR(5),
    max_code_subsection INT,
    min_code_subsection INT,
    unique_row_identifier INT,
    cpt_section VARCHAR(50),
    section_code_range VARCHAR(100),
    cpt_subsection VARCHAR(255),
    subsection_code_range VARCHAR(100)
);

COMMENT ON TABLE procedure_terminology IS 'This table contains the high-level dictionary of the Current Procedural Terminology. Each row of this table can map to a range of CPT_CODEs in CPTEVENTS.';
COMMENT ON COLUMN procedure_terminology.item_category IS 'Code category. Type: Small Integer';
COMMENT ON COLUMN procedure_terminology.terminology_text IS 'Text element of the Current Procedural Terminology, if any. Type: Varchar(5)';
COMMENT ON COLUMN procedure_terminology.max_code_subsection IS 'Maximum code within the subsection. Type: Integer';
COMMENT ON COLUMN procedure_terminology.min_code_subsection IS 'Minimum code within the subsection. Type: Integer';
COMMENT ON COLUMN procedure_terminology.unique_row_identifier IS 'Primary Key. A unique identifier used to uniquely identify each row in the table. Type: Integer';
COMMENT ON COLUMN procedure_terminology.cpt_section IS 'Section header. Type: Varchar(50)';
COMMENT ON COLUMN procedure_terminology.section_code_range IS 'Range of codes within the high-level section. Type: Varchar(100)';
COMMENT ON COLUMN procedure_terminology.cpt_subsection IS 'Subsection header. Type: Varchar(255)';
COMMENT ON COLUMN procedure_terminology.subsection_code_range IS 'Range of codes within the subsection. Type: Varchar(100)';

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