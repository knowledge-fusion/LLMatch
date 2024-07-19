CREATE TABLE current_procedural_terminology_dictionary (
    code_category SMALLINT,
    current_procedural_terminology_text_element VARCHAR(5),
    maximum_code_in_subsection INT,
    minimum_code_in_subsection INT,
    unique_row_identifier INT,
    section_header VARCHAR(50),
    section_code_range VARCHAR(100),
    subsection_header VARCHAR(255),
    subsection_code_range VARCHAR(100)
);

COMMENT ON TABLE current_procedural_terminology_dictionary IS 'This table is a high-level dictionary of the Current Procedural Terminology.';
COMMENT ON COLUMN current_procedural_terminology_dictionary.code_category IS 'The category of the code.';
COMMENT ON COLUMN current_procedural_terminology_dictionary.current_procedural_terminology_text_element IS 'This is the text element of the Current Procedural Terminology, if it exists.';
COMMENT ON COLUMN current_procedural_terminology_dictionary.maximum_code_in_subsection IS 'This is the largest code within the subsection.';
COMMENT ON COLUMN current_procedural_terminology_dictionary.minimum_code_in_subsection IS 'This is the smallest code within the subsection.';
COMMENT ON COLUMN current_procedural_terminology_dictionary.unique_row_identifier IS 'This is a unique identifier for each row.';
COMMENT ON COLUMN current_procedural_terminology_dictionary.section_header IS 'This is the header of the section.';
COMMENT ON COLUMN current_procedural_terminology_dictionary.section_code_range IS 'This shows the range of codes within the high-level section.';
COMMENT ON COLUMN current_procedural_terminology_dictionary.subsection_header IS 'This is the header of the subsection.';
COMMENT ON COLUMN current_procedural_terminology_dictionary.subsection_code_range IS 'This shows the range of codes within the subsection.';

CREATE TABLE current_procedural_terminology_events (
    event_date TIMESTAMP(0),
    recording_center VARCHAR(10),
    current_procedural_terminology_code VARCHAR(10),
    current_procedural_terminology_code_number INT,
    current_procedural_terminology_code_suffix VARCHAR(5),
    current_procedural_terminology_code_description VARCHAR(200),
    hospital_stay_identifier INT,
    unique_row_identifier INT,
    primary_section_current_procedural_terminology_code VARCHAR(50),
    patient_identifier INT,
    subsection_current_procedural_terminology_code VARCHAR(255),
    event_sequence_number INT
);

COMMENT ON TABLE current_procedural_terminology_events IS 'Table records events specified in Current Procedural Terminology.';
COMMENT ON COLUMN current_procedural_terminology_events.event_date IS 'The date when the event took place, if available.';
COMMENT ON COLUMN current_procedural_terminology_events.recording_center IS 'Identifies the department responsible for recording the code, such as the Intensive Care Unit or the Respiratory Unit.';
COMMENT ON COLUMN current_procedural_terminology_events.current_procedural_terminology_code IS 'Specifies the Current Procedural Terminology code.';
COMMENT ON COLUMN current_procedural_terminology_events.current_procedural_terminology_code_number IS 'Numerical component of the Current Procedural Terminology code.';
COMMENT ON COLUMN current_procedural_terminology_events.current_procedural_terminology_code_suffix IS 'Text component of the Current Procedural Terminology code, if it exists. It indicates the category of the code.';
COMMENT ON COLUMN current_procedural_terminology_events.current_procedural_terminology_code_description IS 'Details about the Current Procedural Terminology code, if given.';
COMMENT ON COLUMN current_procedural_terminology_events.hospital_stay_identifier IS 'This foreign key identifies the particular hospital stay associated with the event.';
COMMENT ON COLUMN current_procedural_terminology_events.unique_row_identifier IS 'Unique identifier for each row in the table.';
COMMENT ON COLUMN current_procedural_terminology_events.primary_section_current_procedural_terminology_code IS 'Indicates the high-level section of the Current Procedural Terminology code.';
COMMENT ON COLUMN current_procedural_terminology_events.patient_identifier IS 'This foreign key identifies the patient associated with each event.';
COMMENT ON COLUMN current_procedural_terminology_events.subsection_current_procedural_terminology_code IS 'Indicates the specific subsection of the Current Procedural Terminology code.';
COMMENT ON COLUMN current_procedural_terminology_events.event_sequence_number IS 'Sequence number of the event, derived from the ticket ID.';

CREATE TABLE datetime_related_events (
    caregiver_identifier INT,
    event_time TIMESTAMP(0),
    error_flag SMALLINT,
    hospital_admission_identifier INT,
    intensive_care_unit_stay_identifier INT,
    charted_item_identifier INT,
    result_status VARCHAR(50),
    row_identifier INT,
    explicitly_stopped VARCHAR(50),
    recorded_time TIMESTAMP(0),
    patient_identifier INT,
    event_value TIMESTAMP(0),
    value_unit_of_measurement VARCHAR(50),
    warning_flag SMALLINT
);

COMMENT ON TABLE datetime_related_events IS 'This table contains events related to specific date and time.';
COMMENT ON COLUMN datetime_related_events.caregiver_identifier IS 'A foreign key that identifies the caregiver.';
COMMENT ON COLUMN datetime_related_events.event_time IS 'The time when the event occurred.';
COMMENT ON COLUMN datetime_related_events.error_flag IS 'A flag to highlight an error with the event.';
COMMENT ON COLUMN datetime_related_events.hospital_admission_identifier IS 'A foreign key that identifies the hospital stay.';
COMMENT ON COLUMN datetime_related_events.intensive_care_unit_stay_identifier IS 'A foreign key that identifies the Intensive Care Unit stay.';
COMMENT ON COLUMN datetime_related_events.charted_item_identifier IS 'A foreign key that identifies the charted item.';
COMMENT ON COLUMN datetime_related_events.result_status IS 'The result status of lab data.';
COMMENT ON COLUMN datetime_related_events.row_identifier IS 'A unique row identifier.';
COMMENT ON COLUMN datetime_related_events.explicitly_stopped IS 'Indicates whether the event was explicitly marked as stopped, infrequently used by caregivers.';
COMMENT ON COLUMN datetime_related_events.recorded_time IS 'The time when the event was recorded in the system.';
COMMENT ON COLUMN datetime_related_events.patient_identifier IS 'A foreign key that identifies the patient.';
COMMENT ON COLUMN datetime_related_events.event_value IS 'The value of the event as a text string.';
COMMENT ON COLUMN datetime_related_events.value_unit_of_measurement IS 'The unit of measurement for the event value.';
COMMENT ON COLUMN datetime_related_events.warning_flag IS 'A flag to highlight that the value has triggered a warning.';

CREATE TABLE diagnoses_international_classification_of_diseases (
    hospital_admission_identifier INT,
    international_classification_of_diseases_9_code VARCHAR(10),
    row_identifier INT,
    sequence_number INT,
    patient_identifier INT
);

COMMENT ON TABLE diagnoses_international_classification_of_diseases IS 'Diagnoses relating to a hospital admission coded using the International Classification of Diseases, Ninth Revision (ICD9) system.';
COMMENT ON COLUMN diagnoses_international_classification_of_diseases.hospital_admission_identifier IS 'A foreign key that identifies the hospital stay.';
COMMENT ON COLUMN diagnoses_international_classification_of_diseases.international_classification_of_diseases_9_code IS 'The International Classification of Diseases, Ninth Revision (ICD9) code for the diagnosis.';
COMMENT ON COLUMN diagnoses_international_classification_of_diseases.row_identifier IS 'A unique identifier for each row.';
COMMENT ON COLUMN diagnoses_international_classification_of_diseases.sequence_number IS 'The priority of the code. Sequence number 1 is the primary code.';
COMMENT ON COLUMN diagnoses_international_classification_of_diseases.patient_identifier IS 'A foreign key that identifies the patient.';

CREATE TABLE diagnosis_related_group_codes (
    diagnosis_related_group_description VARCHAR(255),
    diagnosis_related_group_code VARCHAR(20),
    diagnosis_related_group_mortality SMALLINT,
    diagnosis_related_group_severity SMALLINT,
    diagnosis_related_group_type VARCHAR(20),
    hospital_admission_identifier INT,
    row_identifier INT,
    patient_identifier INT
);

COMMENT ON TABLE diagnosis_related_group_codes IS 'This table contains information about hospital stays classified using the Diagnosis-Related Group system.';
COMMENT ON COLUMN diagnosis_related_group_codes.diagnosis_related_group_description IS 'Description of the Diagnosis-Related Group.';
COMMENT ON COLUMN diagnosis_related_group_codes.diagnosis_related_group_code IS 'The code for the Diagnosis-Related Group.';
COMMENT ON COLUMN diagnosis_related_group_codes.diagnosis_related_group_mortality IS 'Relative mortality, available only for All Patient Refined type.';
COMMENT ON COLUMN diagnosis_related_group_codes.diagnosis_related_group_severity IS 'Relative severity, available only for All Patient Refined type.';
COMMENT ON COLUMN diagnosis_related_group_codes.diagnosis_related_group_type IS 'Type of Diagnosis-Related Group, such as All Patient Refined (APR).';
COMMENT ON COLUMN diagnosis_related_group_codes.hospital_admission_identifier IS 'A foreign key that identifies the hospital stay.';
COMMENT ON COLUMN diagnosis_related_group_codes.row_identifier IS 'A unique identifier for each row.';
COMMENT ON COLUMN diagnosis_related_group_codes.patient_identifier IS 'A foreign key that identifies the patient.';

CREATE TABLE discharge_log (
    response_status VARCHAR(20),
    response_time TIMESTAMP(0),
    discharge_outcome VARCHAR(20),
    discharge_service VARCHAR(10),
    discharge_status VARCHAR(20),
    destination_ward_id INT,
    creation_time TIMESTAMP(0),
    current_care_unit VARCHAR(15),
    current_ward_id INT,
    latest_reservation_time TIMESTAMP(0),
    discharge_ward_id INT,
    initial_reservation_time TIMESTAMP(0),
    hospital_stay_id INT,
    outcome_time TIMESTAMP(0),
    special_precautions_cdifficile SMALLINT,
    special_precautions_mrsa SMALLINT,
    special_precautions_respiratory SMALLINT,
    special_precautions_telemetry SMALLINT,
    special_precautions_vre SMALLINT,
    row_identifier INT,
    patient_id INT,
    submitted_from_care_unit VARCHAR(15),
    submitted_from_ward_id INT,
    last_update_time TIMESTAMP(0)
);

COMMENT ON TABLE discharge_log IS 'Record of when patients were ready for discharge, and the actual time of their discharge or other outcomes.';
COMMENT ON COLUMN discharge_log.response_status IS 'The status of the response to the discharge request.';
COMMENT ON COLUMN discharge_log.response_time IS 'Time at which the discharge request was acknowledged.';
COMMENT ON COLUMN discharge_log.discharge_outcome IS 'The result of the discharge request.';
COMMENT ON COLUMN discharge_log.discharge_service IS 'Identifies the service that the patient is discharged to.';
COMMENT ON COLUMN discharge_log.discharge_status IS 'Current status of the discharge request.';
COMMENT ON COLUMN discharge_log.destination_ward_id IS 'Identifies the ward where the patient is to be discharged. A value of 1 indicates the first available ward. A value of 0 indicates home.';
COMMENT ON COLUMN discharge_log.creation_time IS 'Time at which the discharge request was created.';
COMMENT ON COLUMN discharge_log.current_care_unit IS 'If the ward where the patient is currently residing is an Intensive Care Unit, the type is listed here.';
COMMENT ON COLUMN discharge_log.current_ward_id IS 'Identifies the ward where the patient is currently residing.';
COMMENT ON COLUMN discharge_log.latest_reservation_time IS 'Latest time at which a ward was reserved for the discharge request.';
COMMENT ON COLUMN discharge_log.discharge_ward_id IS 'The ward to which the patient was discharged.';
COMMENT ON COLUMN discharge_log.initial_reservation_time IS 'First time at which a ward was reserved for the discharge request.';
COMMENT ON COLUMN discharge_log.hospital_stay_id IS 'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN discharge_log.outcome_time IS 'Time at which the outcome (cancelled or discharged) occurred.';
COMMENT ON COLUMN discharge_log.special_precautions_cdifficile IS 'Indicates if special precautions are required for Clostridium difficile.';
COMMENT ON COLUMN discharge_log.special_precautions_mrsa IS 'Indicates if special precautions are required for Methicillin-resistant Staphylococcus aureus.';
COMMENT ON COLUMN discharge_log.special_precautions_respiratory IS 'Indicates if special precautions are required for respiratory issues.';
COMMENT ON COLUMN discharge_log.special_precautions_telemetry IS 'Indicates if special precautions are required for telemetry.';
COMMENT ON COLUMN discharge_log.special_precautions_vre IS 'Indicates if special precautions are required for Vancomycin-resistant Enterococci.';
COMMENT ON COLUMN discharge_log.row_identifier IS 'Unique row identifier.';
COMMENT ON COLUMN discharge_log.patient_id IS 'Foreign key. Identifies the patient.';
COMMENT ON COLUMN discharge_log.submitted_from_care_unit IS 'If the ward where the request was submitted is an Intensive Care Unit, the type is listed here.';
COMMENT ON COLUMN discharge_log.submitted_from_ward_id IS 'Identifies the ward where the discharge request was submitted.';
COMMENT ON COLUMN discharge_log.last_update_time IS 'Last time at which the discharge request was updated.';

CREATE TABLE hospital_admissions (
    admission_location VARCHAR(50),
    admission_type VARCHAR(50),
    admission_time TIMESTAMP(0),
    time_of_death TIMESTAMP(0),
    diagnosis VARCHAR(255),
    discharge_location VARCHAR(50),
    discharge_time TIMESTAMP(0),
    ethnicity VARCHAR(200),
    hospital_admission_id INT,
    has_chart_events SMALLINT,
    insurance_type VARCHAR(255),
    language VARCHAR(10),
    marital_status VARCHAR(50),
    religion VARCHAR(50),
    row_identifier INT,
    patient_id INT
);

COMMENT ON TABLE hospital_admissions IS 'This table contains hospital admissions linked to an Intensive Care Unit stay.';
COMMENT ON COLUMN hospital_admissions.admission_location IS 'Location from where the patient was admitted.';
COMMENT ON COLUMN hospital_admissions.admission_type IS 'Type of admission, such as emergency or elective.';
COMMENT ON COLUMN hospital_admissions.admission_time IS 'Time when the patient was admitted to the hospital.';
COMMENT ON COLUMN hospital_admissions.time_of_death IS 'Time when the patient passed away.';
COMMENT ON COLUMN hospital_admissions.diagnosis IS 'Medical diagnosis of the patient.';
COMMENT ON COLUMN hospital_admissions.discharge_location IS 'Location where the patient was discharged to.';
COMMENT ON COLUMN hospital_admissions.discharge_time IS 'Time when the patient was discharged from the hospital.';
COMMENT ON COLUMN hospital_admissions.ethnicity IS 'Ethnic background of the patient.';
COMMENT ON COLUMN hospital_admissions.hospital_admission_id IS 'Primary key. A unique identifier for the hospital stay.';
COMMENT ON COLUMN hospital_admissions.has_chart_events IS 'Indicates if the hospital admission has at least one observation in the Chart Events table.';
COMMENT ON COLUMN hospital_admissions.insurance_type IS 'Type of insurance coverage.';
COMMENT ON COLUMN hospital_admissions.language IS 'Language spoken by the patient.';
COMMENT ON COLUMN hospital_admissions.marital_status IS 'Marital status of the patient.';
COMMENT ON COLUMN hospital_admissions.religion IS 'Religious affiliation of the patient.';
COMMENT ON COLUMN hospital_admissions.row_identifier IS 'Unique identifier for each row.';
COMMENT ON COLUMN hospital_admissions.patient_id IS 'Foreign key. A unique identifier for the patient.';

CREATE TABLE hospital_patient_services (
    current_service_type VARCHAR(20),
    hospital_admission_identifier INT,
    previous_service_type VARCHAR(20),
    row_identifier INT,
    patient_identifier INT,
    transfer_time TIMESTAMP(0)
);

COMMENT ON TABLE hospital_patient_services IS 'This table contains information about the hospital services that patients were under during their hospital stay.';
COMMENT ON COLUMN hospital_patient_services.current_service_type IS 'Type of the current service.';
COMMENT ON COLUMN hospital_patient_services.hospital_admission_identifier IS 'Foreign key that identifies the hospital stay.';
COMMENT ON COLUMN hospital_patient_services.previous_service_type IS 'Type of the previous service.';
COMMENT ON COLUMN hospital_patient_services.row_identifier IS 'A unique identifier for each row.';
COMMENT ON COLUMN hospital_patient_services.patient_identifier IS 'Foreign key that identifies the patient.';
COMMENT ON COLUMN hospital_patient_services.transfer_time IS 'The time when the transfer occurred.';

CREATE TABLE hospital_procedures_coded_by_ICD9 (
    hospital_stay_identifier INT,
    procedure_ICD9_code VARCHAR(10),
    unique_row_identifier INT,
    procedure_order INT,
    patient_identifier INT
);

COMMENT ON TABLE hospital_procedures_coded_by_ICD9 IS 'This table contains procedures related to a hospital admission, coded using the International Classification of Diseases, 9th Revision (ICD9) system.';
COMMENT ON COLUMN hospital_procedures_coded_by_ICD9.hospital_stay_identifier IS 'This is a foreign key that identifies the hospital stay.';
COMMENT ON COLUMN hospital_procedures_coded_by_ICD9.procedure_ICD9_code IS 'The International Classification of Diseases, 9th Revision code associated with the procedure.';
COMMENT ON COLUMN hospital_procedures_coded_by_ICD9.unique_row_identifier IS 'A unique identifier for each row in the table.';
COMMENT ON COLUMN hospital_procedures_coded_by_ICD9.procedure_order IS 'The order of procedures. Lower procedure numbers indicate an earlier occurrence.';
COMMENT ON COLUMN hospital_procedures_coded_by_ICD9.patient_identifier IS 'This is a foreign key that identifies the patient.';

CREATE TABLE hospital_stay_notes (
    note_category VARCHAR(50),
    caregiver_identifier INT,
    note_chart_date TIMESTAMP(0),
    note_chart_datetime TIMESTAMP(0),
    note_detailed_category VARCHAR(255),
    hospital_admission_identifier INT,
    error_flag CHAR(1),
    row_identifier INT,
    patient_identifier INT,
    note_content TEXT
);

COMMENT ON TABLE hospital_stay_notes IS 'This table contains notes associated with hospital stays.';
COMMENT ON COLUMN hospital_stay_notes.note_category IS 'Category of the note, such as Discharge summary.';
COMMENT ON COLUMN hospital_stay_notes.caregiver_identifier IS 'Foreign key. Identifies the caregiver.';
COMMENT ON COLUMN hospital_stay_notes.note_chart_date IS 'Date when the note was charted.';
COMMENT ON COLUMN hospital_stay_notes.note_chart_datetime IS 'Date and time when the note was charted. Some notes, such as discharge summaries, do not have a time associated with them and have NULL in this column.';
COMMENT ON COLUMN hospital_stay_notes.note_detailed_category IS 'A more detailed categorization for the note, sometimes entered as free-text.';
COMMENT ON COLUMN hospital_stay_notes.hospital_admission_identifier IS 'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN hospital_stay_notes.error_flag IS 'Flag to highlight an error with the note.';
COMMENT ON COLUMN hospital_stay_notes.row_identifier IS 'Unique identifier for each row.';
COMMENT ON COLUMN hospital_stay_notes.patient_identifier IS 'Foreign key. Identifies the patient.';
COMMENT ON COLUMN hospital_stay_notes.note_content IS 'Content of the note.';

CREATE TABLE icu_patient_records (
    date_of_birth TIMESTAMP(0),
    date_of_death TIMESTAMP(0),
    date_of_death_hospital TIMESTAMP(0),
    date_of_death_social_security TIMESTAMP(0),
    death_indicator INT,
    gender VARCHAR(5),
    unique_row_identifier INT,
    patient_id INT
);

COMMENT ON TABLE icu_patient_records IS 'This table contains the data of patients who were admitted to the Intensive Care Unit.';
COMMENT ON COLUMN icu_patient_records.date_of_birth IS 'This is the birth date of the patient.';
COMMENT ON COLUMN icu_patient_records.date_of_death IS 'This indicates the date of patient's death. If the value is null, it indicates that the patient was alive at least 90 days post hospital discharge.';
COMMENT ON COLUMN icu_patient_records.date_of_death_hospital IS 'The date of patient's death recorded in the hospital records.';
COMMENT ON COLUMN icu_patient_records.date_of_death_social_security IS 'The date of patient's death recorded in the social security records.';
COMMENT ON COLUMN icu_patient_records.death_indicator IS 'A flag that indicates whether the patient has died or not.';
COMMENT ON COLUMN icu_patient_records.gender IS 'The gender of the patient.';
COMMENT ON COLUMN icu_patient_records.unique_row_identifier IS 'A unique identifier for each row in the table.';
COMMENT ON COLUMN icu_patient_records.patient_id IS 'Primary key. This identifier uniquely identifies the patient.';

CREATE TABLE intensive_care_unit_admissions (
    database_source VARCHAR(20),
    initial_care_unit VARCHAR(20),
    first_ward_identifier SMALLINT,
    hospital_admission_identifier INT,
    intensive_care_unit_stay_identifier INT,
    admission_time TIMESTAMP(0),
    final_care_unit VARCHAR(20),
    last_ward_identifier SMALLINT,
    length_of_stay DOUBLE,
    discharge_time TIMESTAMP(0),
    row_identifier INT,
    patient_identifier INT
);

COMMENT ON TABLE intensive_care_unit_admissions IS 'This table lists admissions to the Intensive Care Unit.';
COMMENT ON COLUMN intensive_care_unit_admissions.database_source IS 'The source database of the item.';
COMMENT ON COLUMN intensive_care_unit_admissions.initial_care_unit IS 'The first care unit associated with the ICU stay.';
COMMENT ON COLUMN intensive_care_unit_admissions.first_ward_identifier IS 'The identifier for the first ward the patient was located in.';
COMMENT ON COLUMN intensive_care_unit_admissions.hospital_admission_identifier IS 'A foreign key that identifies the hospital stay.';
COMMENT ON COLUMN intensive_care_unit_admissions.intensive_care_unit_stay_identifier IS 'The primary key that identifies the ICU stay.';
COMMENT ON COLUMN intensive_care_unit_admissions.admission_time IS 'The time of admission to the ICU.';
COMMENT ON COLUMN intensive_care_unit_admissions.final_care_unit IS 'The last care unit associated with the ICU stay.';
COMMENT ON COLUMN intensive_care_unit_admissions.last_ward_identifier IS 'The identifier for the last ward where the patient is located.';
COMMENT ON COLUMN intensive_care_unit_admissions.length_of_stay IS 'The length of stay in the ICU in minutes.';
COMMENT ON COLUMN intensive_care_unit_admissions.discharge_time IS 'The time of discharge from the ICU.';
COMMENT ON COLUMN intensive_care_unit_admissions.row_identifier IS 'A unique row identifier.';
COMMENT ON COLUMN intensive_care_unit_admissions.patient_identifier IS 'A foreign key that identifies the patient.';

CREATE TABLE intensive_care_unit_caregivers (
    caregiver_identifier INT,
    caregiver_details VARCHAR(30),
    caregiver_title VARCHAR(15),
    row_identifier INT
);

COMMENT ON TABLE intensive_care_unit_caregivers IS 'This table contains a list of caregivers associated with an Intensive Care Unit stay.';
COMMENT ON COLUMN intensive_care_unit_caregivers.caregiver_identifier IS 'A unique identifier assigned to each caregiver.';
COMMENT ON COLUMN intensive_care_unit_caregivers.caregiver_details IS 'More detailed information about the caregiver, if available.';
COMMENT ON COLUMN intensive_care_unit_caregivers.caregiver_title IS 'Title of the caregiver such as Medical Doctor or Registered Nurse.';
COMMENT ON COLUMN intensive_care_unit_caregivers.row_identifier IS 'Unique identifier assigned to each row.';

CREATE TABLE international_classification_of_diseases_ninth_revision_diagnoses (
    international_classification_of_diseases_ninth_revision_code VARCHAR(10),
    detailed_description VARCHAR(255),
    row_identifier INT,
    short_description VARCHAR(50)
);

COMMENT ON TABLE international_classification_of_diseases_ninth_revision_diagnoses IS 'This table is a dictionary of the International Classification of Diseases, 9th Revision (Diagnoses).';
COMMENT ON COLUMN international_classification_of_diseases_ninth_revision_diagnoses.international_classification_of_diseases_ninth_revision_code IS 'A code from the International Classification of Diseases, 9th Revision. Note that this is a fixed length character field, as whitespaces are important in uniquely identifying these codes.';
COMMENT ON COLUMN international_classification_of_diseases_ninth_revision_diagnoses.detailed_description IS 'A detailed description associated with the code.';
COMMENT ON COLUMN international_classification_of_diseases_ninth_revision_diagnoses.row_identifier IS 'A unique identifier for each row.';
COMMENT ON COLUMN international_classification_of_diseases_ninth_revision_diagnoses.short_description IS 'A short description associated with the code.';

CREATE TABLE international_classification_of_diseases_procedures_ninth_revision (
    international_classification_of_diseases_ninth_revision_code VARCHAR(10),
    long_title_associated_with_code VARCHAR(255),
    row_identifier INT,
    short_title_associated_with_code VARCHAR(50)
);

COMMENT ON TABLE international_classification_of_diseases_procedures_ninth_revision IS 'Dictionary of the International Classification of Diseases, 9th Revision (Procedures).';
COMMENT ON COLUMN international_classification_of_diseases_procedures_ninth_revision.international_classification_of_diseases_ninth_revision_code IS 'ICD-9 code - note that this is a fixed length character field, as whitespaces are important in uniquely identifying ICD-9 codes.';
COMMENT ON COLUMN international_classification_of_diseases_procedures_ninth_revision.long_title_associated_with_code IS 'Long title associated with the code.';
COMMENT ON COLUMN international_classification_of_diseases_procedures_ninth_revision.row_identifier IS 'Unique row identifier.';
COMMENT ON COLUMN international_classification_of_diseases_procedures_ninth_revision.short_title_associated_with_code IS 'Short title associated with the code.';

CREATE TABLE laboratory_items_dictionary (
    item_category VARCHAR(100),
    associated_fluid VARCHAR(100),
    item_identifier INT,
    item_label VARCHAR(100),
    logical_observation_identifiers_names_and_codes VARCHAR(100),
    row_identifier INT
);

COMMENT ON TABLE laboratory_items_dictionary IS 'This table contains a dictionary of laboratory-related items.';
COMMENT ON COLUMN laboratory_items_dictionary.item_category IS 'The category of the item, for example, chemistry or hematology.';
COMMENT ON COLUMN laboratory_items_dictionary.associated_fluid IS 'The fluid associated with the item, for example, blood or urine.';
COMMENT ON COLUMN laboratory_items_dictionary.item_identifier IS 'A foreign key that identifies the charted item.';
COMMENT ON COLUMN laboratory_items_dictionary.item_label IS 'A label identifying the item.';
COMMENT ON COLUMN laboratory_items_dictionary.logical_observation_identifiers_names_and_codes IS 'Logical Observation Identifiers Names and Codes mapped to the item, if available.';
COMMENT ON COLUMN laboratory_items_dictionary.row_identifier IS 'A unique identifier for each row.';

CREATE TABLE laboratory_test_events (
    event_time TIMESTAMP(0),
    abnormal_flag VARCHAR(20),
    hospital_admission_identifier INT,
    charted_item_identifier INT,
    row_identifier INT,
    patient_identifier INT,
    event_value_text VARCHAR(200),
    event_value_number DOUBLE,
    value_unit_of_measurement VARCHAR(20)
);

COMMENT ON TABLE laboratory_test_events IS 'This table contains events relating to laboratory tests.';
COMMENT ON COLUMN laboratory_test_events.event_time IS 'The time when the event occurred.';
COMMENT ON COLUMN laboratory_test_events.abnormal_flag IS 'A flag indicating whether the lab test value is considered abnormal (null if the test was normal).';
COMMENT ON COLUMN laboratory_test_events.hospital_admission_identifier IS 'A foreign key that identifies the hospital stay.';
COMMENT ON COLUMN laboratory_test_events.charted_item_identifier IS 'A foreign key that identifies the charted item.';
COMMENT ON COLUMN laboratory_test_events.row_identifier IS 'A unique row identifier.';
COMMENT ON COLUMN laboratory_test_events.patient_identifier IS 'A foreign key that identifies the patient.';
COMMENT ON COLUMN laboratory_test_events.event_value_text IS 'The value of the event as a text string.';
COMMENT ON COLUMN laboratory_test_events.event_value_number IS 'The value of the event as a number.';
COMMENT ON COLUMN laboratory_test_events.value_unit_of_measurement IS 'The unit of measurement for the value.';

CREATE TABLE medicines_prescribed_information (
    dose_unit VARCHAR(120),
    prescribed_dose_value VARCHAR(120),
    drug_name VARCHAR(100),
    generic_drug_name VARCHAR(100),
    provider_order_entry_drug_name VARCHAR(100),
    drug_category VARCHAR(100),
    prescription_end_date TIMESTAMP(0),
    dispensed_formulation_unit VARCHAR(120),
    dispensed_formulation_value VARCHAR(120),
    formulary_drug_code VARCHAR(120),
    generic_sequence_number VARCHAR(200),
    hospital_admission_identifier INT,
    intensive_care_unit_stay_identifier INT,
    national_drug_code VARCHAR(120),
    product_strength VARCHAR(120),
    administration_route VARCHAR(120),
    row_identifier INT,
    prescription_start_date TIMESTAMP(0),
    patient_identifier INT
);

COMMENT ON TABLE medicines_prescribed_information IS 'This table contains details about medicines prescribed to patients.';
COMMENT ON COLUMN medicines_prescribed_information.dose_unit IS 'Unit of measurement associated with the dose.';
COMMENT ON COLUMN medicines_prescribed_information.prescribed_dose_value IS 'Dose of the drug prescribed.';
COMMENT ON COLUMN medicines_prescribed_information.drug_name IS 'Name of the drug.';
COMMENT ON COLUMN medicines_prescribed_information.generic_drug_name IS 'Generic name of the drug.';
COMMENT ON COLUMN medicines_prescribed_information.provider_order_entry_drug_name IS 'Name of the drug on the Provider Order Entry interface.';
COMMENT ON COLUMN medicines_prescribed_information.drug_category IS 'Type of drug.';
COMMENT ON COLUMN medicines_prescribed_information.prescription_end_date IS 'Date when the prescription ended.';
COMMENT ON COLUMN medicines_prescribed_information.dispensed_formulation_unit IS 'Unit of measurement associated with the dispensed formulation.';
COMMENT ON COLUMN medicines_prescribed_information.dispensed_formulation_value IS 'Amount of the formulation dispensed.';
COMMENT ON COLUMN medicines_prescribed_information.formulary_drug_code IS 'Formulary drug code.';
COMMENT ON COLUMN medicines_prescribed_information.generic_sequence_number IS 'Generic Sequence Number.';
COMMENT ON COLUMN medicines_prescribed_information.hospital_admission_identifier IS 'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN medicines_prescribed_information.intensive_care_unit_stay_identifier IS 'Foreign key. Identifies the Intensive Care Unit stay.';
COMMENT ON COLUMN medicines_prescribed_information.national_drug_code IS 'National Drug Code.';
COMMENT ON COLUMN medicines_prescribed_information.product_strength IS 'Strength of the drug product.';
COMMENT ON COLUMN medicines_prescribed_information.administration_route IS 'Route of administration, for example, intravenous or oral.';
COMMENT ON COLUMN medicines_prescribed_information.row_identifier IS 'Unique identifier for each row.';
COMMENT ON COLUMN medicines_prescribed_information.prescription_start_date IS 'Date when the prescription started.';
COMMENT ON COLUMN medicines_prescribed_information.patient_identifier IS 'Foreign key. Identifies the patient.';

CREATE TABLE microbiology_test_events (
    antibody_identifier INT,
    antibody_name VARCHAR(30),
    event_date TIMESTAMP(0),
    event_time TIMESTAMP(0),
    dilution_comparison_operator VARCHAR(20),
    dilution_description VARCHAR(10),
    dilution_value_float DOUBLE,
    hospital_admission_identifier INT,
    test_interpretation VARCHAR(5),
    isolate_number SMALLINT,
    organism_identifier INT,
    organism_name VARCHAR(100),
    row_identifier INT,
    specimen_identifier INT,
    specimen_description VARCHAR(100),
    patient_identifier INT
);

COMMENT ON TABLE microbiology_test_events IS 'This table contains events related to microbiology tests.';
COMMENT ON COLUMN microbiology_test_events.antibody_identifier IS 'Foreign key. Identifies the antibody.';
COMMENT ON COLUMN microbiology_test_events.antibody_name IS 'Name of the antibody used.';
COMMENT ON COLUMN microbiology_test_events.event_date IS 'Date when the event occurred.';
COMMENT ON COLUMN microbiology_test_events.event_time IS 'Time when the event occurred, if available.';
COMMENT ON COLUMN microbiology_test_events.dilution_comparison_operator IS 'The comparison component of the dilution description: either <= (less than or equal), = (equal), or >= (greater than or equal), or null when not available.';
COMMENT ON COLUMN microbiology_test_events.dilution_description IS 'The dilution amount tested for and the comparison which was made against it (e.g. <=4).';
COMMENT ON COLUMN microbiology_test_events.dilution_value_float IS 'The value component of the dilution description: must be a floating point number.';
COMMENT ON COLUMN microbiology_test_events.hospital_admission_identifier IS 'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN microbiology_test_events.test_interpretation IS 'Interpretation of the test.';
COMMENT ON COLUMN microbiology_test_events.isolate_number IS 'Isolate number associated with the test.';
COMMENT ON COLUMN microbiology_test_events.organism_identifier IS 'Foreign key. Identifies the organism.';
COMMENT ON COLUMN microbiology_test_events.organism_name IS 'Name of the organism.';
COMMENT ON COLUMN microbiology_test_events.row_identifier IS 'Unique row identifier.';
COMMENT ON COLUMN microbiology_test_events.specimen_identifier IS 'Foreign key. Identifies the specimen.';
COMMENT ON COLUMN microbiology_test_events.specimen_description IS 'Description of the specimen.';
COMMENT ON COLUMN microbiology_test_events.patient_identifier IS 'Foreign key. Identifies the patient.';

CREATE TABLE non_laboratory_charted_items_dictionary (
    item_abbreviation VARCHAR(100),
    item_category VARCHAR(100),
    harmonized_concept_identifier INT,
    item_source_database VARCHAR(20),
    charted_item_identifier INT,
    item_label VARCHAR(200),
    linked_table VARCHAR(50),
    item_type VARCHAR(30),
    unique_row_identifier INT,
    item_unit_name VARCHAR(100)
);

COMMENT ON TABLE non_laboratory_charted_items_dictionary IS 'This table is a dictionary of non-laboratory-related charted items.';
COMMENT ON COLUMN non_laboratory_charted_items_dictionary.item_abbreviation IS 'Abbreviation associated with the item.';
COMMENT ON COLUMN non_laboratory_charted_items_dictionary.item_category IS 'Category of data under which the concept falls.';
COMMENT ON COLUMN non_laboratory_charted_items_dictionary.harmonized_concept_identifier IS 'Identifier used for harmonizing concepts identified by multiple item identifiers. It is planned but not yet implemented (all values are currently NULL).';
COMMENT ON COLUMN non_laboratory_charted_items_dictionary.item_source_database IS 'Source database of the item.';
COMMENT ON COLUMN non_laboratory_charted_items_dictionary.charted_item_identifier IS 'Primary key identifier for the charted item.';
COMMENT ON COLUMN non_laboratory_charted_items_dictionary.item_label IS 'Label identifying the item.';
COMMENT ON COLUMN non_laboratory_charted_items_dictionary.linked_table IS 'Name of the table which contains data for the given item identifier.';
COMMENT ON COLUMN non_laboratory_charted_items_dictionary.item_type IS 'Type of item, for example, solution or ingredient.';
COMMENT ON COLUMN non_laboratory_charted_items_dictionary.unique_row_identifier IS 'Unique identifier for each row.';
COMMENT ON COLUMN non_laboratory_charted_items_dictionary.item_unit_name IS 'Unit associated with the item.';

CREATE TABLE patient_chart_events (
    caregiver_identifier INT,
    event_occurrance_time TIMESTAMP(0),
    error_flag INT,
    hospital_stay_identifier INT,
    intensive_care_unit_stay_identifier INT,
    charted_item_identifier INT,
    lab_result_status VARCHAR(50),
    unique_row_identifier INT,
    event_stopped_status VARCHAR(50),
    event_recording_time TIMESTAMP(0),
    patient_identifier INT,
    event_value_text VARCHAR(255),
    event_value_number DOUBLE,
    unit_of_measurement VARCHAR(50),
    warning_flag INT
);

COMMENT ON TABLE patient_chart_events IS 'This table records events occurring on a patient's chart.';
COMMENT ON COLUMN patient_chart_events.caregiver_identifier IS 'Foreign key that identifies the caregiver.';
COMMENT ON COLUMN patient_chart_events.event_occurrance_time IS 'The time when the event occurred.';
COMMENT ON COLUMN patient_chart_events.error_flag IS 'A flag that highlights if there has been an error with the event.';
COMMENT ON COLUMN patient_chart_events.hospital_stay_identifier IS 'Foreign key that identifies the patient's hospital stay.';
COMMENT ON COLUMN patient_chart_events.intensive_care_unit_stay_identifier IS 'Foreign key that identifies the patient's stay in Intensive Care Unit.';
COMMENT ON COLUMN patient_chart_events.charted_item_identifier IS 'Foreign key that identifies the charted item.';
COMMENT ON COLUMN patient_chart_events.lab_result_status IS 'The result status of the lab data.';
COMMENT ON COLUMN patient_chart_events.unique_row_identifier IS 'Unique identifier for each record row.';
COMMENT ON COLUMN patient_chart_events.event_stopped_status IS 'A text string that indicates the stopped status of an event (for example, stopped or not stopped).';
COMMENT ON COLUMN patient_chart_events.event_recording_time IS 'The time when the event was recorded in the system.';
COMMENT ON COLUMN patient_chart_events.patient_identifier IS 'Foreign key that identifies the patient.';
COMMENT ON COLUMN patient_chart_events.event_value_text IS 'The value of the event as a text string.';
COMMENT ON COLUMN patient_chart_events.event_value_number IS 'The value of the event as a number.';
COMMENT ON COLUMN patient_chart_events.unit_of_measurement IS 'The unit of measurement for the event value.';
COMMENT ON COLUMN patient_chart_events.warning_flag IS 'A flag that highlights if the value has triggered a warning.';

CREATE TABLE patient_fluid_input_events (
    administered_amount DOUBLE,
    amount_unit_of_measurement VARCHAR(30),
    caregiver_identifier INT,
    input_start_time TIMESTAMP(0),
    hospital_admission_identifier INT,
    intensive_care_unit_stay_identifier INT,
    charted_item_identifier INT,
    linked_order_identifier INT,
    new_bottle_indicator INT,
    order_identifier INT,
    original_administered_amount DOUBLE,
    original_amount_unit_of_measurement VARCHAR(30),
    original_administration_rate DOUBLE,
    original_rate_unit_of_measurement VARCHAR(30),
    original_administration_route VARCHAR(30),
    original_administration_site VARCHAR(30),
    administration_rate DOUBLE,
    rate_unit_of_measurement VARCHAR(30),
    row_identifier INT,
    event_stopped_indicator VARCHAR(30),
    event_recorded_time TIMESTAMP(0),
    patient_identifier INT
);

COMMENT ON TABLE patient_fluid_input_events IS 'This table contains events related to fluid input for patients whose data was originally stored in the CareVue database.';
COMMENT ON COLUMN patient_fluid_input_events.administered_amount IS 'Amount of the item administered to the patient.';
COMMENT ON COLUMN patient_fluid_input_events.amount_unit_of_measurement IS 'Unit of measurement for the amount.';
COMMENT ON COLUMN patient_fluid_input_events.caregiver_identifier IS 'Foreign key. Identifies the caregiver.';
COMMENT ON COLUMN patient_fluid_input_events.input_start_time IS 'Time when the fluid input was started or received.';
COMMENT ON COLUMN patient_fluid_input_events.hospital_admission_identifier IS 'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN patient_fluid_input_events.intensive_care_unit_stay_identifier IS 'Foreign key. Identifies the Intensive Care Unit stay.';
COMMENT ON COLUMN patient_fluid_input_events.charted_item_identifier IS 'Foreign key. Identifies the charted item.';
COMMENT ON COLUMN patient_fluid_input_events.linked_order_identifier IS 'Identifier linking orders across multiple administrations. This identifier is always equal to the first occurring order identifier of the series.';
COMMENT ON COLUMN patient_fluid_input_events.new_bottle_indicator IS 'Indicates when a new bottle of the solution was hung at the bedside.';
COMMENT ON COLUMN patient_fluid_input_events.order_identifier IS 'Identifier linking items which are grouped in a solution.';
COMMENT ON COLUMN patient_fluid_input_events.original_administered_amount IS 'Amount of the item which was originally charted.';
COMMENT ON COLUMN patient_fluid_input_events.original_amount_unit_of_measurement IS 'Unit of measurement for the original amount.';
COMMENT ON COLUMN patient_fluid_input_events.original_administration_rate IS 'Rate of administration originally chosen for the item.';
COMMENT ON COLUMN patient_fluid_input_events.original_rate_unit_of_measurement IS 'Unit of measurement for the rate originally chosen.';
COMMENT ON COLUMN patient_fluid_input_events.original_administration_route IS 'Route of administration originally chosen for the item.';
COMMENT ON COLUMN patient_fluid_input_events.original_administration_site IS 'Anatomical site for the original administration of the item.';
COMMENT ON COLUMN patient_fluid_input_events.administration_rate IS 'Rate at which the item is being administered to the patient.';
COMMENT ON COLUMN patient_fluid_input_events.rate_unit_of_measurement IS 'Unit of measurement for the rate.';
COMMENT ON COLUMN patient_fluid_input_events.row_identifier IS 'Unique row identifier.';
COMMENT ON COLUMN patient_fluid_input_events.event_stopped_indicator IS 'Indicator showing that the event was explicitly marked as stopped. Infrequently used by caregivers.';
COMMENT ON COLUMN patient_fluid_input_events.event_recorded_time IS 'Time when the event was recorded in the system.';
COMMENT ON COLUMN patient_fluid_input_events.patient_identifier IS 'Foreign key. Identifies the patient.';

CREATE TABLE patient_fluid_input_metaVision (
    administered_item_amount DOUBLE,
    administered_item_amount_unit_of_measurement VARCHAR(30),
    cancellation_reason SMALLINT,
    caregiver_identifier INT,
    order_canceled_by VARCHAR(40),
    order_edit_or_cancel_date TIMESTAMP(0),
    order_edited_by VARCHAR(30),
    is_item_continued_in_next_department SMALLINT,
    event_end_time TIMESTAMP(0),
    hospital_stay_identifier INT,
    intensive_care_unit_stay_identifier INT,
    is_solution_bag_open SMALLINT,
    charted_item_identifier INT,
    linked_orders_identifier INT,
    administered_item_type VARCHAR(50),
    administered_item_group VARCHAR(100),
    administered_item_role VARCHAR(200),
    grouped_items_identifier INT,
    original_charted_item_amount DOUBLE,
    original_item_administration_rate DOUBLE,
    patient_weight_for_dosed_drugs DOUBLE,
    administered_item_rate DOUBLE,
    administered_item_rate_unit_of_measurement VARCHAR(30),
    row_identifier INT,
    administered_item_secondary_group VARCHAR(100),
    event_start_time TIMESTAMP(0),
    current_order_status VARCHAR(30),
    event_recording_time TIMESTAMP(0),
    patient_identifier INT,
    total_item_amount_in_solution DOUBLE,
    total_item_amount_in_solution_unit_of_measurement VARCHAR(50)
);

COMMENT ON TABLE patient_fluid_input_metaVision IS 'This table records events related to fluid input for patients whose data was initially gathered in the MetaVision database.';
COMMENT ON COLUMN patient_fluid_input_metaVision.administered_item_amount IS 'The quantity of the item administered to the patient.';
COMMENT ON COLUMN patient_fluid_input_metaVision.administered_item_amount_unit_of_measurement IS 'The unit of measurement for the quantity of the item administered.';
COMMENT ON COLUMN patient_fluid_input_metaVision.cancellation_reason IS 'The reason for cancellation, if an order was cancelled.';
COMMENT ON COLUMN patient_fluid_input_metaVision.caregiver_identifier IS 'Identifier references the caregiver.';
COMMENT ON COLUMN patient_fluid_input_metaVision.order_canceled_by IS 'The title of the caregiver who canceled the order.';
COMMENT ON COLUMN patient_fluid_input_metaVision.order_edit_or_cancel_date IS 'The time at which the caregiver edited or cancelled the order.';
COMMENT ON COLUMN patient_fluid_input_metaVision.order_edited_by IS 'The title of the caregiver who edited the order.';
COMMENT ON COLUMN patient_fluid_input_metaVision.is_item_continued_in_next_department IS 'Indicator of whether the item will be continued in the department where the patient is transferred to next.';
COMMENT ON COLUMN patient_fluid_input_metaVision.event_end_time IS 'The time when the event ended.';
COMMENT ON COLUMN patient_fluid_input_metaVision.hospital_stay_identifier IS 'Identifier references the hospital stay.';
COMMENT ON COLUMN patient_fluid_input_metaVision.intensive_care_unit_stay_identifier IS 'Identifier references the Intensive Care Unit stay.';
COMMENT ON COLUMN patient_fluid_input_metaVision.is_solution_bag_open IS 'Indicator of whether the bag containing the solution is open.';
COMMENT ON COLUMN patient_fluid_input_metaVision.charted_item_identifier IS 'Identifier references the charted item.';
COMMENT ON COLUMN patient_fluid_input_metaVision.linked_orders_identifier IS 'Identifier linking orders across multiple administrations. Linked Orders Identifier is always equal to the first occuring Grouped Items Identifier of the series.';
COMMENT ON COLUMN patient_fluid_input_metaVision.administered_item_type IS 'The type of item administered.';
COMMENT ON COLUMN patient_fluid_input_metaVision.administered_item_group IS 'The group to which the administered item corresponds.';
COMMENT ON COLUMN patient_fluid_input_metaVision.administered_item_role IS 'The role of the item administered in the order.';
COMMENT ON COLUMN patient_fluid_input_metaVision.grouped_items_identifier IS 'Identifier linking items which are grouped in a solution.';
COMMENT ON COLUMN patient_fluid_input_metaVision.original_charted_item_amount IS 'The quantity of the item which was originally charted.';
COMMENT ON COLUMN patient_fluid_input_metaVision.original_item_administration_rate IS 'The rate of administration originally chosen for the item.';
COMMENT ON COLUMN patient_fluid_input_metaVision.patient_weight_for_dosed_drugs IS 'For drugs dosed by weight, the value of the weight used in the dosage calculation.';
COMMENT ON COLUMN patient_fluid_input_metaVision.administered_item_rate IS 'The rate at which the item is being administered to the patient.';
COMMENT ON COLUMN patient_fluid_input_metaVision.administered_item_rate_unit_of_measurement IS 'The unit of measurement for the rate of item administration.';
COMMENT ON COLUMN patient_fluid_input_metaVision.row_identifier IS 'A unique identifier for each row.';
COMMENT ON COLUMN patient_fluid_input_metaVision.administered_item_secondary_group IS 'A secondary group for those administered items with more than one grouping potential.';
COMMENT ON COLUMN patient_fluid_input_metaVision.event_start_time IS 'The time when the event started.';
COMMENT ON COLUMN patient_fluid_input_metaVision.current_order_status IS 'The current status of the order: stopped, rewritten, running or cancelled.';
COMMENT ON COLUMN patient_fluid_input_metaVision.event_recording_time IS 'The time when the event was recorded in the system.';
COMMENT ON COLUMN patient_fluid_input_metaVision.patient_identifier IS 'Identifier references the patient.';
COMMENT ON COLUMN patient_fluid_input_metaVision.total_item_amount_in_solution IS 'The total amount in the solution for the given item.';
COMMENT ON COLUMN patient_fluid_input_metaVision.total_item_amount_in_solution_unit_of_measurement IS 'The unit of measurement for the total item amount in the solution.';

CREATE TABLE patient_hospital_stay_locational_history (
    current_care_unit VARCHAR(20),
    current_ward_identifier SMALLINT,
    database_source VARCHAR(20),
    event_type VARCHAR(20),
    hospital_stay_identifier INT,
    intensive_care_unit_stay_identifier INT,
    entry_time TIMESTAMP(0),
    length_of_stay DOUBLE,
    exit_time TIMESTAMP(0),
    previous_care_unit VARCHAR(20),
    previous_ward_identifier SMALLINT,
    row_identifier INT,
    patient_identifier INT
);

COMMENT ON TABLE patient_hospital_stay_locational_history IS 'This table records the locational history of patients during their hospital stay.';
COMMENT ON COLUMN patient_hospital_stay_locational_history.current_care_unit IS 'The current care unit where the patient is located.';
COMMENT ON COLUMN patient_hospital_stay_locational_history.current_ward_identifier IS 'The identifier for the current ward the patient is located in.';
COMMENT ON COLUMN patient_hospital_stay_locational_history.database_source IS 'The source database of the item.';
COMMENT ON COLUMN patient_hospital_stay_locational_history.event_type IS 'The type of event, for example, admission or transfer.';
COMMENT ON COLUMN patient_hospital_stay_locational_history.hospital_stay_identifier IS 'Foreign key. It identifies the hospital stay.';
COMMENT ON COLUMN patient_hospital_stay_locational_history.intensive_care_unit_stay_identifier IS 'Foreign key. It identifies the Intensive Care Unit stay.';
COMMENT ON COLUMN patient_hospital_stay_locational_history.entry_time IS 'The time when the patient was transferred into the unit.';
COMMENT ON COLUMN patient_hospital_stay_locational_history.length_of_stay IS 'The length of stay in the unit in minutes.';
COMMENT ON COLUMN patient_hospital_stay_locational_history.exit_time IS 'The time when the patient was transferred out of the unit.';
COMMENT ON COLUMN patient_hospital_stay_locational_history.previous_care_unit IS 'The previous care unit where the patient was located.';
COMMENT ON COLUMN patient_hospital_stay_locational_history.previous_ward_identifier IS 'The identifier for the previous ward the patient was located in.';
COMMENT ON COLUMN patient_hospital_stay_locational_history.row_identifier IS 'A unique identifier for each row.';
COMMENT ON COLUMN patient_hospital_stay_locational_history.patient_identifier IS 'Foreign key. It identifies the patient.';