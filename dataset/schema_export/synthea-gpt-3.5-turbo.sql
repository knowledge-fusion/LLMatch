CREATE TABLE healthcare_providers (
    street_address VARCHAR(255),
    street_address_city VARCHAR(255),
    provider_id VARCHAR(255),
    provider_name VARCHAR(255),
    provider_phone_number VARCHAR(255),
    street_address_state VARCHAR(255),
    encounter_count VARCHAR(255),
    street_address_zip VARCHAR(255) 
);

COMMENT ON TABLE healthcare_providers IS 'The healthcare providers table includes information about hospitals and other medical facilities.';
COMMENT ON COLUMN healthcare_providers.street_address IS 'The street address of the healthcare provider. Commas and newlines are not included.';
COMMENT ON COLUMN healthcare_providers.street_address_city IS 'The city portion of the healthcare provider's street address.';
COMMENT ON COLUMN healthcare_providers.provider_id IS 'The unique identifier for the healthcare provider.';
COMMENT ON COLUMN healthcare_providers.provider_name IS 'The name of the healthcare provider.';
COMMENT ON COLUMN healthcare_providers.provider_phone_number IS 'The phone number of the healthcare provider.';
COMMENT ON COLUMN healthcare_providers.street_address_state IS 'The state abbreviation of the healthcare provider's street address.';
COMMENT ON COLUMN healthcare_providers.encounter_count IS 'The number of encounters (i.e. visits) performed by this healthcare provider.';
COMMENT ON COLUMN healthcare_providers.street_address_zip IS 'The zip or postal code of the healthcare provider's street address.';

CREATE TABLE patient_allergy_data (
    allergy_code VARCHAR(255),
    allergy_description VARCHAR(255),
    encounter_id VARCHAR(255),
    patient_id VARCHAR(255),
    allergy_start_date VARCHAR(255),
    allergy_end_date VARCHAR(255) 
);

COMMENT ON TABLE patient_allergy_data IS 'The table contains information about the allergies of patients.';
COMMENT ON COLUMN patient_allergy_data.allergy_code IS 'The allergy code from SNOMED-CT (Systematized Nomenclature of Medicine -- Clinical Terms).';
COMMENT ON COLUMN patient_allergy_data.allergy_description IS 'The description of the allergy.';
COMMENT ON COLUMN patient_allergy_data.encounter_id IS 'A unique identifier of the encounter when the allergy was diagnosed.';
COMMENT ON COLUMN patient_allergy_data.patient_id IS 'A unique identifier of the patient with the allergy.';
COMMENT ON COLUMN patient_allergy_data.allergy_start_date IS 'The date when the allergy was diagnosed.';
COMMENT ON COLUMN patient_allergy_data.allergy_end_date IS 'The date when the allergy ended (if applicable).';

CREATE TABLE patient_care_plans (
    snomed_ct_code VARCHAR(255),
    care_plan_description VARCHAR(255),
    encounter_key VARCHAR(255),
    care_plan_id VARCHAR(255),
    patient_key VARCHAR(255),
    diagnosis_snomed_ct_code VARCHAR(255),
    diagnosis_description VARCHAR(255),
    care_plan_start_date VARCHAR(255),
    care_plan_end_date VARCHAR(255) 
);

COMMENT ON TABLE patient_care_plans IS 'The patient care plan table contains data related to care plans, including goals.';
COMMENT ON COLUMN patient_care_plans.snomed_ct_code IS 'The SNOMED-CT code used in the care plan.';
COMMENT ON COLUMN patient_care_plans.care_plan_description IS 'The description of the care plan.';
COMMENT ON COLUMN patient_care_plans.encounter_key IS 'A foreign key linking to the encounter table when the care plan was initiated.';
COMMENT ON COLUMN patient_care_plans.care_plan_id IS 'A unique identifier for the care plan.';
COMMENT ON COLUMN patient_care_plans.patient_key IS 'A foreign key linking to the patient table.';
COMMENT ON COLUMN patient_care_plans.diagnosis_snomed_ct_code IS 'The SNOMED-CT code of the diagnosis for which the care plan is intended.';
COMMENT ON COLUMN patient_care_plans.diagnosis_description IS 'The description of the diagnosis.';
COMMENT ON COLUMN patient_care_plans.care_plan_start_date IS 'The date when the care plan was initiated.';
COMMENT ON COLUMN patient_care_plans.care_plan_end_date IS 'The date when the care plan ended.';

CREATE TABLE patient_demographic_data (
    street_address VARCHAR(255),
    birth_date VARCHAR(255),
    birth_town VARCHAR(255),
    address_city VARCHAR(255),
    death_date VARCHAR(255),
    drivers_license_number VARCHAR(255),
    primary_ethnicity VARCHAR(255),
    first_name VARCHAR(255),
    gender VARCHAR(255),
    patient_identifier VARCHAR(255),
    last_name VARCHAR(255),
    maiden_name VARCHAR(255),
    marital_status VARCHAR(255),
    passport_number VARCHAR(255),
    name_prefix VARCHAR(255),
    primary_race VARCHAR(255),
    social_security_number VARCHAR(255),
    address_state VARCHAR(255),
    name_suffix VARCHAR(255),
    zip_code VARCHAR(255) 
);

COMMENT ON TABLE patient_demographic_data IS 'The patient demographic data table contains information related to patient details.';
COMMENT ON COLUMN patient_demographic_data.street_address IS 'The street address of the patient without commas or newlines.';
COMMENT ON COLUMN patient_demographic_data.birth_date IS 'The date when the patient was born.';
COMMENT ON COLUMN patient_demographic_data.birth_town IS 'The town where the patient was born.';
COMMENT ON COLUMN patient_demographic_data.address_city IS 'The city of the patient's address.';
COMMENT ON COLUMN patient_demographic_data.death_date IS 'The date when the patient died.';
COMMENT ON COLUMN patient_demographic_data.drivers_license_number IS 'The drivers license number of the patient.';
COMMENT ON COLUMN patient_demographic_data.primary_ethnicity IS 'The primary ethnicity of the patient.';
COMMENT ON COLUMN patient_demographic_data.first_name IS 'The first name of the patient.';
COMMENT ON COLUMN patient_demographic_data.gender IS 'The gender of the patient. M stands for male and F stands for female.';
COMMENT ON COLUMN patient_demographic_data.patient_identifier IS 'A unique identifier used to uniquely identify each patient.';
COMMENT ON COLUMN patient_demographic_data.last_name IS 'The last name or surname of the patient.';
COMMENT ON COLUMN patient_demographic_data.maiden_name IS 'The maiden name of the patient.';
COMMENT ON COLUMN patient_demographic_data.marital_status IS 'The marital status of the patient. M stands for married and S stands for single.';
COMMENT ON COLUMN patient_demographic_data.passport_number IS 'The passport number of the patient.';
COMMENT ON COLUMN patient_demographic_data.name_prefix IS 'The prefix used in the patient's name.';
COMMENT ON COLUMN patient_demographic_data.primary_race IS 'The primary race of the patient.';
COMMENT ON COLUMN patient_demographic_data.social_security_number IS 'The social security number of the patient.';
COMMENT ON COLUMN patient_demographic_data.address_state IS 'The state of the patient's address.';
COMMENT ON COLUMN patient_demographic_data.name_suffix IS 'The suffix used in the patient's name.';
COMMENT ON COLUMN patient_demographic_data.zip_code IS 'The zip code of the patient.';

CREATE TABLE patient_diagnoses (
    diagnosis_code VARCHAR(255),
    diagnosis_description VARCHAR(255),
    encounter_id VARCHAR(255),
    patient_id VARCHAR(255),
    diagnosis_date VARCHAR(255),
    resolution_date VARCHAR(255) 
);

COMMENT ON TABLE patient_diagnoses IS 'The patient diagnoses table stores all patient diagnoses or conditions.';
COMMENT ON COLUMN patient_diagnoses.diagnosis_code IS 'The diagnosis code from Systematized Nomenclature of Medicine Clinical Terms.';
COMMENT ON COLUMN patient_diagnoses.diagnosis_description IS 'The detailed description of the patient diagnosis.';
COMMENT ON COLUMN patient_diagnoses.encounter_id IS 'Foreign key to the encounter table when the condition was diagnosed.';
COMMENT ON COLUMN patient_diagnoses.patient_id IS 'Foreign key to the patient table.';
COMMENT ON COLUMN patient_diagnoses.diagnosis_date IS 'The date the condition was diagnosed.';
COMMENT ON COLUMN patient_diagnoses.resolution_date IS 'The date the condition resolved, if applicable.';

CREATE TABLE patient_encounter_data (
    encounter_code VARCHAR(255),
    encounter_base_cost VARCHAR(255),
    encounter_description VARCHAR(255),
    encounter_class VARCHAR(255),
    encounter_identifier VARCHAR(255),
    patient_foreign_key VARCHAR(255),
    organization_foreign_key VARCHAR(255),
    diagnosis_code VARCHAR(255),
    diagnosis_description VARCHAR(255),
    encounter_start_date_time VARCHAR(255),
    encounter_end_date_time VARCHAR(255) 
);

COMMENT ON TABLE patient_encounter_data IS 'The patient encounter data table stores details about patient encounters.';
COMMENT ON COLUMN patient_encounter_data.encounter_code IS 'The encounter code from Systematized Nomenclature of Medicine Clinical Terms (SNOMED-CT).';
COMMENT ON COLUMN patient_encounter_data.encounter_base_cost IS 'The base cost of the patient encounter, not including any line item costs related to medications, immunizations, procedures, or other services.';
COMMENT ON COLUMN patient_encounter_data.encounter_description IS 'Description of the type of patient encounter.';
COMMENT ON COLUMN patient_encounter_data.encounter_class IS 'The class of the patient encounter, such as ambulatory, emergency, inpatient, wellness, or urgent care.';
COMMENT ON COLUMN patient_encounter_data.encounter_identifier IS 'A unique identifier of the patient encounter.';
COMMENT ON COLUMN patient_encounter_data.patient_foreign_key IS 'A foreign key reference to the patient table.';
COMMENT ON COLUMN patient_encounter_data.organization_foreign_key IS 'A foreign key reference to the organization the patient encountered.';
COMMENT ON COLUMN patient_encounter_data.diagnosis_code IS 'The diagnosis code from Systematized Nomenclature of Medicine Clinical Terms (SNOMED-CT) if this encounter targeted a specific condition.';
COMMENT ON COLUMN patient_encounter_data.diagnosis_description IS 'Description of the reason code.';
COMMENT ON COLUMN patient_encounter_data.encounter_start_date_time IS 'The date and time the patient encounter started.';
COMMENT ON COLUMN patient_encounter_data.encounter_end_date_time IS 'The date and time the patient encounter concluded.';

CREATE TABLE patient_imaging_metadata (
    body_site_code VARCHAR(255),
    body_site_description VARCHAR(255),
    study_date VARCHAR(255),
    encounter_id VARCHAR(255),
    imaging_study_id VARCHAR(255),
    modality_code VARCHAR(255),
    modality_description VARCHAR(255),
    patient_id VARCHAR(255),
    sop_code VARCHAR(255),
    sop_description VARCHAR(255) 
);

COMMENT ON TABLE patient_imaging_metadata IS 'Table containing metadata for patient imaging studies.';
COMMENT ON COLUMN patient_imaging_metadata.body_site_code IS 'Snomed body structures code describing the specific body part imaged.';
COMMENT ON COLUMN patient_imaging_metadata.body_site_description IS 'Description of the body site imaged.';
COMMENT ON COLUMN patient_imaging_metadata.study_date IS 'Date the imaging study was conducted.';
COMMENT ON COLUMN patient_imaging_metadata.encounter_id IS 'Foreign key to the encounter where the imaging study was conducted.';
COMMENT ON COLUMN patient_imaging_metadata.imaging_study_id IS 'Unique identifier of the imaging study.';
COMMENT ON COLUMN patient_imaging_metadata.modality_code IS 'Dicom-dcm code describing the imaging method used.';
COMMENT ON COLUMN patient_imaging_metadata.modality_description IS 'Description of the imaging modality used.';
COMMENT ON COLUMN patient_imaging_metadata.patient_id IS 'Foreign key to the patient.';
COMMENT ON COLUMN patient_imaging_metadata.sop_code IS 'Dicom-sop code describing the subject-object pair (sop) constituting the image.';
COMMENT ON COLUMN patient_imaging_metadata.sop_description IS 'Description of the sop code.';

CREATE TABLE patient_immunization_data (
    immunization_code VARCHAR(255),
    item_cost VARCHAR(255),
    administered_date VARCHAR(255),
    immunization_description VARCHAR(255),
    encounter_id VARCHAR(255),
    patient_id VARCHAR(255) 
);

COMMENT ON TABLE patient_immunization_data IS 'The table containing patient immunization data.';
COMMENT ON COLUMN patient_immunization_data.immunization_code IS 'The immunization code from CVX.';
COMMENT ON COLUMN patient_immunization_data.item_cost IS 'The cost of the immunization as a line item.';
COMMENT ON COLUMN patient_immunization_data.administered_date IS 'The date when the immunization was administered.';
COMMENT ON COLUMN patient_immunization_data.immunization_description IS 'The description of the immunization.';
COMMENT ON COLUMN patient_immunization_data.encounter_id IS 'The unique identifier of the encounter where the immunization was administered.';
COMMENT ON COLUMN patient_immunization_data.patient_id IS 'The unique identifier of the patient.';

CREATE TABLE patient_medication_data (
    medication_code VARCHAR(255),
    medication_cost VARCHAR(255),
    medication_description VARCHAR(255),
    encounter_id VARCHAR(255),
    patient_id VARCHAR(255),
    prescription_reason_code VARCHAR(255),
    prescription_reason_description VARCHAR(255),
    prescription_start_date VARCHAR(255),
    prescription_end_date VARCHAR(255) 
);

COMMENT ON TABLE patient_medication_data IS 'Patient medication data.';
COMMENT ON COLUMN patient_medication_data.medication_code IS 'Medication code from RxNorm.';
COMMENT ON COLUMN patient_medication_data.medication_cost IS 'The line item cost of the medication.';
COMMENT ON COLUMN patient_medication_data.medication_description IS 'Description of the medication.';
COMMENT ON COLUMN patient_medication_data.encounter_id IS 'Foreign key to the encounter where the medication was prescribed.';
COMMENT ON COLUMN patient_medication_data.patient_id IS 'Foreign key to the patient.';
COMMENT ON COLUMN patient_medication_data.prescription_reason_code IS 'Diagnosis code from SNOMED-CT specifying why this medication was prescribed.';
COMMENT ON COLUMN patient_medication_data.prescription_reason_description IS 'Description of the reason code.';
COMMENT ON COLUMN patient_medication_data.prescription_start_date IS 'The date the medication was prescribed.';
COMMENT ON COLUMN patient_medication_data.prescription_end_date IS 'The date the prescription ended, if applicable.';

CREATE TABLE patient_observation_data (
    observation_code VARCHAR(255),
    observation_date VARCHAR(255),
    observation_description VARCHAR(255),
    encounter_id VARCHAR(255),
    patient_id VARCHAR(255),
    observation_data_type VARCHAR(255),
    observation_units VARCHAR(255),
    observation_value VARCHAR(255) 
);

COMMENT ON TABLE patient_observation_data IS 'The patient observation data table includes vital signs and lab reports for patients.';
COMMENT ON COLUMN patient_observation_data.observation_code IS 'Observation or lab code from LOINC.';
COMMENT ON COLUMN patient_observation_data.observation_date IS 'The date on which the observation was performed.';
COMMENT ON COLUMN patient_observation_data.observation_description IS 'Description of the observation or lab.';
COMMENT ON COLUMN patient_observation_data.encounter_id IS 'A unique encounter identifier.';
COMMENT ON COLUMN patient_observation_data.patient_id IS 'A unique patient identifier.';
COMMENT ON COLUMN patient_observation_data.observation_data_type IS 'The data type of the observation: text or numeric.';
COMMENT ON COLUMN patient_observation_data.observation_units IS 'The units of measure for the value.';
COMMENT ON COLUMN patient_observation_data.observation_value IS 'The recorded value of the observation.';

CREATE TABLE patient_procedure_data (
    procedure_code VARCHAR(255),
    procedure_cost VARCHAR(255),
    procedure_date VARCHAR(255),
    procedure_description VARCHAR(255),
    encounter_key VARCHAR(255),
    patient_key VARCHAR(255),
    reason_code VARCHAR(255),
    reason_description VARCHAR(255) 
);

COMMENT ON TABLE patient_procedure_data IS 'The patient procedure data table includes information on surgeries and other procedures performed.';
COMMENT ON COLUMN patient_procedure_data.procedure_code IS 'Code representing the procedure from SNOMED-CT.';
COMMENT ON COLUMN patient_procedure_data.procedure_cost IS 'The cost of the procedure.';
COMMENT ON COLUMN patient_procedure_data.procedure_date IS 'The date the procedure was performed.';
COMMENT ON COLUMN patient_procedure_data.procedure_description IS 'Description of the procedure.';
COMMENT ON COLUMN patient_procedure_data.encounter_key IS 'Key linking to the encounter where the procedure took place.';
COMMENT ON COLUMN patient_procedure_data.patient_key IS 'Key linking to the patient involved in the procedure.';
COMMENT ON COLUMN patient_procedure_data.reason_code IS 'Diagnosis code from SNOMED-CT explaining why the procedure was performed.';
COMMENT ON COLUMN patient_procedure_data.reason_description IS 'Description of the reason code.';

CREATE TABLE providers_information (
    street_address VARCHAR(255),
    street_address_city VARCHAR(255),
    gender VARCHAR(255),
    provider_id VARCHAR(255),
    provider_name VARCHAR(255),
    organization_id VARCHAR(255),
    provider_specialty VARCHAR(255),
    street_address_state VARCHAR(255),
    encounter_count VARCHAR(255),
    street_address_zip VARCHAR(255) 
);

COMMENT ON TABLE providers_information IS 'This table contains information about the healthcare providers that provide patient care.';
COMMENT ON COLUMN providers_information.street_address IS 'The street address of the provider. Type: Text';
COMMENT ON COLUMN providers_information.street_address_city IS 'The city of the provider's street address. Type: Text';
COMMENT ON COLUMN providers_information.gender IS 'The gender of the provider. Type: Text';
COMMENT ON COLUMN providers_information.provider_id IS 'Primary Key. The unique identifier of the provider. Type: Text';
COMMENT ON COLUMN providers_information.provider_name IS 'The full name of the provider. Type: Text';
COMMENT ON COLUMN providers_information.organization_id IS 'Foreign Key. The unique identifier of the organization the provider belongs to. Type: Text';
COMMENT ON COLUMN providers_information.provider_specialty IS 'The area of specialty of the provider. Type: Text';
COMMENT ON COLUMN providers_information.street_address_state IS 'The state of the provider's street address. Type: Text';
COMMENT ON COLUMN providers_information.encounter_count IS 'The number of encounters performed by this provider. Type: Text';
COMMENT ON COLUMN providers_information.street_address_zip IS 'The zip or postal code of the provider's street address. Type: Text';