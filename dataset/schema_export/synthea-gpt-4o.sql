CREATE TABLE clinicians_information (
    street_address VARCHAR(255),
    address_city VARCHAR(255),
    provider_gender VARCHAR(255),
    provider_identifier VARCHAR(255),
    provider_name VARCHAR(255),
    employing_organization VARCHAR(255),
    provider_speciality VARCHAR(255),
    address_state VARCHAR(255),
    number_of_encounters VARCHAR(255),
    postal_code VARCHAR(255) 
);

COMMENT ON TABLE clinicians_information IS 'The clinicians information table contains details about clinicians who provide patient care.';
COMMENT ON COLUMN clinicians_information.street_address IS 'The provider's street address without commas or newlines.';
COMMENT ON COLUMN clinicians_information.address_city IS 'The city of the provider's street address.';
COMMENT ON COLUMN clinicians_information.provider_gender IS 'The gender of the provider. 'Male' for male, 'Female' for female.';
COMMENT ON COLUMN clinicians_information.provider_identifier IS 'A unique identifier for each provider or clinician.';
COMMENT ON COLUMN clinicians_information.provider_name IS 'The first and last name of the provider.';
COMMENT ON COLUMN clinicians_information.employing_organization IS 'A reference to the organization that employs this provider.';
COMMENT ON COLUMN clinicians_information.provider_speciality IS 'The speciality of the provider.';
COMMENT ON COLUMN clinicians_information.address_state IS 'The abbreviation of the state for the street address.';
COMMENT ON COLUMN clinicians_information.number_of_encounters IS 'The number of encounters performed by this provider.';
COMMENT ON COLUMN clinicians_information.postal_code IS 'The postal code or zip code for the street address.';

CREATE TABLE patient_allergy_information (
    allergy_code VARCHAR(255),
    allergy_description VARCHAR(255),
    diagnosis_encounter_identifier VARCHAR(255),
    patient_identifier VARCHAR(255),
    allergy_start_date VARCHAR(255),
    allergy_end_date VARCHAR(255) 
);

COMMENT ON TABLE patient_allergy_information IS 'The patient allergy information table contains data about patient allergies.';
COMMENT ON COLUMN patient_allergy_information.allergy_code IS 'The allergy code from the Systematized Nomenclature of Medicine Clinical Terms.';
COMMENT ON COLUMN patient_allergy_information.allergy_description IS 'A description of the allergy.';
COMMENT ON COLUMN patient_allergy_information.diagnosis_encounter_identifier IS 'The identifier linking to the encounter during which the allergy was diagnosed.';
COMMENT ON COLUMN patient_allergy_information.patient_identifier IS 'The identifier linking to the patient.';
COMMENT ON COLUMN patient_allergy_information.allergy_start_date IS 'The date the allergy was diagnosed.';
COMMENT ON COLUMN patient_allergy_information.allergy_end_date IS 'The date the allergy ended, if applicable.';

CREATE TABLE patient_care_plan_data (
    snomed_ct_code VARCHAR(255),
    care_plan_description VARCHAR(255),
    care_plan_encounter_identifier VARCHAR(255),
    care_plan_identifier VARCHAR(255),
    patient_identifier VARCHAR(255),
    care_plan_reason_code VARCHAR(255),
    reason_code_description VARCHAR(255),
    care_plan_start_date VARCHAR(255),
    care_plan_end_date VARCHAR(255) 
);

COMMENT ON TABLE patient_care_plan_data IS 'Patient care plan data, including goals.';
COMMENT ON COLUMN patient_care_plan_data.snomed_ct_code IS 'Code from Systematized Nomenclature of Medicine Clinical Terms.';
COMMENT ON COLUMN patient_care_plan_data.care_plan_description IS 'Description of the care plan.';
COMMENT ON COLUMN patient_care_plan_data.care_plan_encounter_identifier IS 'Foreign key to the encounter when the care plan was initiated.';
COMMENT ON COLUMN patient_care_plan_data.care_plan_identifier IS 'A primary key that uniquely identifies the care plan.';
COMMENT ON COLUMN patient_care_plan_data.patient_identifier IS 'Foreign key to the patient.';
COMMENT ON COLUMN patient_care_plan_data.care_plan_reason_code IS 'Diagnosis code from Systematized Nomenclature of Medicine Clinical Terms that this care plan addresses.';
COMMENT ON COLUMN patient_care_plan_data.reason_code_description IS 'Description of the reason code.';
COMMENT ON COLUMN patient_care_plan_data.care_plan_start_date IS 'The date the care plan was initiated.';
COMMENT ON COLUMN patient_care_plan_data.care_plan_end_date IS 'The date the care plan ended, if applicable.';

CREATE TABLE patient_demographics (
    street_address VARCHAR(255),
    birth_date VARCHAR(255),
    birth_town VARCHAR(255),
    city_name VARCHAR(255),
    death_date VARCHAR(255),
    driver's_license_number VARCHAR(255),
    ethnicity_description VARCHAR(255),
    first_name VARCHAR(255),
    gender_description VARCHAR(255),
    patient_identifier VARCHAR(255),
    last_name VARCHAR(255),
    maiden_name VARCHAR(255),
    marital_status VARCHAR(255),
    passport_number VARCHAR(255),
    name_prefix VARCHAR(255),
    race_description VARCHAR(255),
    social_security_number VARCHAR(255),
    state_name VARCHAR(255),
    name_suffix VARCHAR(255),
    zip_code VARCHAR(255) 
);

COMMENT ON TABLE patient_demographics IS 'The patient demographics table contains personal and demographic details about patients.';
COMMENT ON COLUMN patient_demographics.street_address IS 'The patient's street address without commas or newlines.';
COMMENT ON COLUMN patient_demographics.birth_date IS 'The patient's birth date.';
COMMENT ON COLUMN patient_demographics.birth_town IS 'The town where the patient was born.';
COMMENT ON COLUMN patient_demographics.city_name IS 'The city of the patient's address.';
COMMENT ON COLUMN patient_demographics.death_date IS 'The date of the patient's death.';
COMMENT ON COLUMN patient_demographics.driver's_license_number IS 'The patient's driver's license number.';
COMMENT ON COLUMN patient_demographics.ethnicity_description IS 'Description of the patient's primary ethnicity.';
COMMENT ON COLUMN patient_demographics.first_name IS 'The patient's first name.';
COMMENT ON COLUMN patient_demographics.gender_description IS 'The patient's gender. 'Male' for male, 'Female' for female.';
COMMENT ON COLUMN patient_demographics.patient_identifier IS 'A unique identifier for the patient.';
COMMENT ON COLUMN patient_demographics.last_name IS 'The patient's last or surname.';
COMMENT ON COLUMN patient_demographics.maiden_name IS 'The patient's maiden name.';
COMMENT ON COLUMN patient_demographics.marital_status IS 'The patient's marital status. 'Married' for married, 'Single' for single. Currently no support for divorce or widowing.';
COMMENT ON COLUMN patient_demographics.passport_number IS 'The patient's passport number.';
COMMENT ON COLUMN patient_demographics.name_prefix IS 'Prefix for the patient's name, such as Mr., Mrs., Dr., etc.';
COMMENT ON COLUMN patient_demographics.race_description IS 'Description of the patient's primary race.';
COMMENT ON COLUMN patient_demographics.social_security_number IS 'The patient's social security number.';
COMMENT ON COLUMN patient_demographics.state_name IS 'The state of the patient's address.';
COMMENT ON COLUMN patient_demographics.name_suffix IS 'Suffix for the patient's name, such as PhD, MD, JD, etc.';
COMMENT ON COLUMN patient_demographics.zip_code IS 'The patient's zip code.';

CREATE TABLE patient_encounter_data (
    encounter_code_snomed_ct VARCHAR(255),
    base_cost_of_encounter VARCHAR(255),
    encounter_type_description VARCHAR(255),
    encounter_category VARCHAR(255),
    unique_encounter_identifier VARCHAR(255),
    patient_reference VARCHAR(255),
    providing_organization_reference VARCHAR(255),
    diagnosis_code_snomed_ct VARCHAR(255),
    reason_code_description VARCHAR(255),
    start_date_and_time VARCHAR(255),
    end_date_and_time VARCHAR(255) 
);

COMMENT ON TABLE patient_encounter_data IS 'The patient encounter data table stores information about each patient's encounter.';
COMMENT ON COLUMN patient_encounter_data.encounter_code_snomed_ct IS 'Encounter code derived from Snomed Clinical Terms.';
COMMENT ON COLUMN patient_encounter_data.base_cost_of_encounter IS 'The base cost of the encounter, not including any extra costs related to medications, immunizations, procedures, or other services.';
COMMENT ON COLUMN patient_encounter_data.encounter_type_description IS 'Description of the type of patient encounter.';
COMMENT ON COLUMN patient_encounter_data.encounter_category IS 'The category of the encounter, such as ambulatory, emergency, inpatient, wellness, or urgent care.';
COMMENT ON COLUMN patient_encounter_data.unique_encounter_identifier IS 'Primary key. Unique identifier of each patient encounter.';
COMMENT ON COLUMN patient_encounter_data.patient_reference IS 'Foreign key referring to the respective patient.';
COMMENT ON COLUMN patient_encounter_data.providing_organization_reference IS 'Foreign key referring to the providing organization.';
COMMENT ON COLUMN patient_encounter_data.diagnosis_code_snomed_ct IS 'Diagnosis code derived from Snomed Clinical Terms, present only if this encounter targeted a specific condition.';
COMMENT ON COLUMN patient_encounter_data.reason_code_description IS 'Description of the reason code.';
COMMENT ON COLUMN patient_encounter_data.start_date_and_time IS 'The date and time each patient encounter began.';
COMMENT ON COLUMN patient_encounter_data.end_date_and_time IS 'The date and time each patient encounter concluded.';

CREATE TABLE patient_health_condition (
    diagnosis_snomed-ct_code VARCHAR(255),
    condition_description VARCHAR(255),
    diagnosis_encounter_reference VARCHAR(255),
    patient_reference VARCHAR(255),
    diagnosis_start_date VARCHAR(255),
    condition_resolution_date VARCHAR(255) 
);

COMMENT ON TABLE patient_health_condition IS 'The patient health condition table records details of patient's diagnoses or conditions.';
COMMENT ON COLUMN patient_health_condition.diagnosis_snomed-ct_code IS 'The diagnosis code as per Snomed-Clinical Terms.';
COMMENT ON COLUMN patient_health_condition.condition_description IS 'Description of the patient's health condition.';
COMMENT ON COLUMN patient_health_condition.diagnosis_encounter_reference IS 'A reference key linking to the details when the condition was diagnosed.';
COMMENT ON COLUMN patient_health_condition.patient_reference IS 'A reference key linking to the patient's record.';
COMMENT ON COLUMN patient_health_condition.diagnosis_start_date IS 'The date the health condition was diagnosed.';
COMMENT ON COLUMN patient_health_condition.condition_resolution_date IS 'The date the health condition was resolved, if applicable.';

CREATE TABLE patient_imaging_metadata (
    body_structure_code VARCHAR(255),
    body_structure_description VARCHAR(255),
    study_date VARCHAR(255),
    encounter_reference VARCHAR(255),
    imaging_study_identifier VARCHAR(255),
    imaging_method_code VARCHAR(255),
    imaging_method_description VARCHAR(255),
    patient_reference VARCHAR(255),
    image_subject_object_pair_code VARCHAR(255),
    subject_object_pair_description VARCHAR(255) 
);

COMMENT ON TABLE patient_imaging_metadata IS 'This table contains metadata related to patient imaging studies.';
COMMENT ON COLUMN patient_imaging_metadata.body_structure_code IS 'A code from the Systematized Nomenclature of Medicine, describing the part of the body imaged.';
COMMENT ON COLUMN patient_imaging_metadata.body_structure_description IS 'Description related to the body structure code.';
COMMENT ON COLUMN patient_imaging_metadata.study_date IS 'The date when the imaging study was conducted.';
COMMENT ON COLUMN patient_imaging_metadata.encounter_reference IS 'Reference to the encounter during which the imaging study took place.';
COMMENT ON COLUMN patient_imaging_metadata.imaging_study_identifier IS 'Unique identifier of the imaging study, acting as the primary key.';
COMMENT ON COLUMN patient_imaging_metadata.imaging_method_code IS 'A Digital Imaging and Communications in Medicine code describing the imaging method used.';
COMMENT ON COLUMN patient_imaging_metadata.imaging_method_description IS 'Description related to the imaging method code.';
COMMENT ON COLUMN patient_imaging_metadata.patient_reference IS 'Reference to the patient related to the imaging study.';
COMMENT ON COLUMN patient_imaging_metadata.image_subject_object_pair_code IS 'A Digital Imaging and Communications in Medicine Subject-Object Pair code describing image content.';
COMMENT ON COLUMN patient_imaging_metadata.subject_object_pair_description IS 'Description related to the Subject-Object Pair code.';

CREATE TABLE patient_immunization_records (
    immunization_code VARCHAR(255),
    immunization_cost VARCHAR(255),
    immunization_date VARCHAR(255),
    immunization_description VARCHAR(255),
    immunization_encounter_reference VARCHAR(255),
    patient_reference VARCHAR(255) 
);

COMMENT ON TABLE patient_immunization_records IS 'The patient immunization records table contains data about patient's immunizations.';
COMMENT ON COLUMN patient_immunization_records.immunization_code IS 'The code of the immunization derived from the Clinical Virology Laboratory reference list.';
COMMENT ON COLUMN patient_immunization_records.immunization_cost IS 'The cost of the immunization.';
COMMENT ON COLUMN patient_immunization_records.immunization_date IS 'The date when the immunization was given.';
COMMENT ON COLUMN patient_immunization_records.immunization_description IS 'The description of the immunization.';
COMMENT ON COLUMN patient_immunization_records.immunization_encounter_reference IS 'The reference data linking to the encounter when the immunization was given.';
COMMENT ON COLUMN patient_immunization_records.patient_reference IS 'The reference data linking to the patient who received the immunization.';

CREATE TABLE patient_medication_data (
    medication_code VARCHAR(255),
    medication_cost VARCHAR(255),
    medication_description VARCHAR(255),
    encounter_identifier VARCHAR(255),
    patient_identifier VARCHAR(255),
    diagnosis_code VARCHAR(255),
    diagnosis_description VARCHAR(255),
    prescription_start_date VARCHAR(255),
    prescription_end_date VARCHAR(255) 
);

COMMENT ON TABLE patient_medication_data IS 'The patient medication data table contains information on medications prescribed to patients.';
COMMENT ON COLUMN patient_medication_data.medication_code IS 'Medication code from RxNorm.';
COMMENT ON COLUMN patient_medication_data.medication_cost IS 'The line item cost of the medication.';
COMMENT ON COLUMN patient_medication_data.medication_description IS 'Description of the medication.';
COMMENT ON COLUMN patient_medication_data.encounter_identifier IS 'Foreign key to the encounter where the medication was prescribed.';
COMMENT ON COLUMN patient_medication_data.patient_identifier IS 'Foreign key to the patient.';
COMMENT ON COLUMN patient_medication_data.diagnosis_code IS 'Diagnosis code from Systematized Nomenclature of Medicine Clinical Terms specifying why this medication was prescribed.';
COMMENT ON COLUMN patient_medication_data.diagnosis_description IS 'Description of the diagnosis code.';
COMMENT ON COLUMN patient_medication_data.prescription_start_date IS 'The date the medication was prescribed.';
COMMENT ON COLUMN patient_medication_data.prescription_end_date IS 'The date the prescription ended, if applicable.';

CREATE TABLE patient_observations (
    observation_code VARCHAR(255),
    observation_date VARCHAR(255),
    observation_description VARCHAR(255),
    encounter_identifier VARCHAR(255),
    patient_identifier VARCHAR(255),
    data_type VARCHAR(255),
    measurement_units VARCHAR(255),
    recorded_value VARCHAR(255) 
);

COMMENT ON TABLE patient_observations IS 'The patient observations table includes details of vital signs and laboratory reports.';
COMMENT ON COLUMN patient_observations.observation_code IS 'Observation or laboratory code from Logical Observation Identifiers Names and Codes (LOINC).';
COMMENT ON COLUMN patient_observations.observation_date IS 'The date the observation was performed.';
COMMENT ON COLUMN patient_observations.observation_description IS 'Description of the observation or laboratory.';
COMMENT ON COLUMN patient_observations.encounter_identifier IS 'A unique identifier that references the encounter where the observation was performed.';
COMMENT ON COLUMN patient_observations.patient_identifier IS 'A unique identifier that references the patient.';
COMMENT ON COLUMN patient_observations.data_type IS 'The datatype of the recorded value, such as text or numeric.';
COMMENT ON COLUMN patient_observations.measurement_units IS 'The units of measure for the recorded value.';
COMMENT ON COLUMN patient_observations.recorded_value IS 'The recorded value of the observation.';

CREATE TABLE patient_procedure_data (
    procedure_code VARCHAR(255),
    procedure_cost VARCHAR(255),
    procedure_date VARCHAR(255),
    procedure_description VARCHAR(255),
    encounter_reference VARCHAR(255),
    patient_reference VARCHAR(255),
    diagnosis_code VARCHAR(255),
    diagnosis_description VARCHAR(255) 
);

COMMENT ON TABLE patient_procedure_data IS 'The patient procedure data table includes information about surgeries performed on patients.';
COMMENT ON COLUMN patient_procedure_data.procedure_code IS 'The procedure code from Systematized Nomenclature of Medicine Clinical Terms.';
COMMENT ON COLUMN patient_procedure_data.procedure_cost IS 'The cost of the procedure.';
COMMENT ON COLUMN patient_procedure_data.procedure_date IS 'The date when the procedure was performed.';
COMMENT ON COLUMN patient_procedure_data.procedure_description IS 'The description of the procedure.';
COMMENT ON COLUMN patient_procedure_data.encounter_reference IS 'The reference to the encounter in which the procedure was performed.';
COMMENT ON COLUMN patient_procedure_data.patient_reference IS 'The reference to the specific patient.';
COMMENT ON COLUMN patient_procedure_data.diagnosis_code IS 'The diagnosis code from Systematized Nomenclature of Medicine Clinical Terms that specifies the reason for the procedure.';
COMMENT ON COLUMN patient_procedure_data.diagnosis_description IS 'The description of the diagnosis code.';

CREATE TABLE provider_organizations (
    street_address VARCHAR(255),
    address_city VARCHAR(255),
    organization_identifier VARCHAR(255),
    organization_name VARCHAR(255),
    phone_number VARCHAR(255),
    address_state VARCHAR(255),
    encounter_count VARCHAR(255),
    postal_code VARCHAR(255) 
);

COMMENT ON TABLE provider_organizations IS 'The provider organizations table contains information about provider organizations including hospitals.';
COMMENT ON COLUMN provider_organizations.street_address IS 'Organization's street address without commas or newlines.';
COMMENT ON COLUMN provider_organizations.address_city IS 'City of the street address.';
COMMENT ON COLUMN provider_organizations.organization_identifier IS 'Primary key of the organization.';
COMMENT ON COLUMN provider_organizations.organization_name IS 'Name of the organization.';
COMMENT ON COLUMN provider_organizations.phone_number IS 'Organization's phone number.';
COMMENT ON COLUMN provider_organizations.address_state IS 'State abbreviation of the street address.';
COMMENT ON COLUMN provider_organizations.encounter_count IS 'The number of encounters performed by this organization.';
COMMENT ON COLUMN provider_organizations.postal_code IS 'Postal code or zip code of the street address.';