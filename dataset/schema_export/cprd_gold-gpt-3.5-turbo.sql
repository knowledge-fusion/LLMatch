CREATE TABLE gp_test_record (
    consultation_identifier VARCHAR(50),
    consultation_type VARCHAR(50),
    entity_type VARCHAR(50),
    event_date VARCHAR(50),
    medical_code VARCHAR(50),
    patient_identifier VARCHAR(50),
    snomed_description_id VARCHAR(50),
    snomed_expression VARCHAR(50),
    snomed_ct_concept_id VARCHAR(50),
    snomed_is_assured VARCHAR(50),
    snomed_is_indicative VARCHAR(50),
    snomed_mapping_type VARCHAR(50),
    snomed_mapping_version VARCHAR(50),
    staff_identifier VARCHAR(50),
    system_date VARCHAR(50)
);

CREATE TABLE immunisation_records (
    batch_number VARCHAR(50),
    immunisation_compound VARCHAR(50),
    consultation_identifier VARCHAR(50),
    event_category_code VARCHAR(50),
    event_date VARCHAR(50),
    immunisation_type VARCHAR(50),
    medical_code VARCHAR(50),
    administration_route VARCHAR(50),
    patient_identifier VARCHAR(50),
    administered_reason_code VARCHAR(50),
    snomed_description_id VARCHAR(50),
    snomed_expression VARCHAR(50),
    snomed_ct_concept_id VARCHAR(50),
    snomed_is_assured VARCHAR(50),
    snomed_is_indicative VARCHAR(50),
    snomed_mapping_type VARCHAR(50),
    snomed_mapping_version VARCHAR(50),
    immunisation_source VARCHAR(50),
    staff_identifier VARCHAR(50),
    immunisation_stage VARCHAR(50),
    immunisation_status VARCHAR(50),
    system_date VARCHAR(50)
);

CREATE TABLE medical_consultation (
    consultation_identifier VARCHAR(50),
    consultation_type VARCHAR(50),
    consultation_duration VARCHAR(50),
    event_date VARCHAR(50),
    patient_identifier VARCHAR(50),
    staff_identifier VARCHAR(50),
    system_date VARCHAR(50)
);

CREATE TABLE medical_history (
    additional_details_identifier VARCHAR(50),
    consultation_identifier VARCHAR(50),
    consultation_type VARCHAR(50),
    entity_type VARCHAR(50),
    episode_type VARCHAR(50),
    event_date VARCHAR(50),
    medical_code VARCHAR(50),
    patient_identifier VARCHAR(50),
    snomed_description_id VARCHAR(50),
    snomed_expression VARCHAR(50),
    snomed_ct_concept_id VARCHAR(50),
    snomed_is_assured VARCHAR(50),
    snomed_is_indicative VARCHAR(50),
    snomed_mapping_type VARCHAR(50),
    snomed_mapping_version VARCHAR(50),
    staff_identifier VARCHAR(50),
    system_date VARCHAR(50)
);

CREATE TABLE patient_information (
    acceptable_patient_flag VARCHAR(50),
    capitation_supplement_level VARCHAR(50),
    child_health_surveillance_registration_date VARCHAR(50),
    child_health_surveillance_registered_flag VARCHAR(50),
    current_registration_date VARCHAR(50),
    death_date VARCHAR(50),
    family_number VARCHAR(50),
    first_registration_date VARCHAR(50),
    patient_gender VARCHAR(50),
    internal_transfer_out_periods_number VARCHAR(50),
    patient_marital_status VARCHAR(50),
    birth_month VARCHAR(50),
    patient_identifier VARCHAR(50),
    prescription_exemption_type VARCHAR(50),
    registration_gaps_days VARCHAR(50),
    registration_status VARCHAR(50),
    transfer_out_date VARCHAR(50),
    transfer_out_reason VARCHAR(50),
    vamp_identifier VARCHAR(50),
    birth_year VARCHAR(50)
);

CREATE TABLE patient_referral (
    referral_attendance_type VARCHAR(50),
    consultation_identifier VARCHAR(50),
    consultation_type VARCHAR(50),
    referral_event_date VARCHAR(50),
    fhsa_speciality VARCHAR(50),
    referral_type VARCHAR(50),
    medical_code VARCHAR(50),
    nhs_speciality VARCHAR(50),
    patient_identifier VARCHAR(50),
    snomed_description_id VARCHAR(50),
    snomed_expression VARCHAR(50),
    snomed_ct_concept_id VARCHAR(50),
    snomed_is_assured VARCHAR(50),
    snomed_is_indicative VARCHAR(50),
    snomed_mapping_type VARCHAR(50),
    snomed_mapping_version VARCHAR(50),
    immunisation_source VARCHAR(50),
    staff_identifier VARCHAR(50),
    system_date VARCHAR(50),
    referral_urgency VARCHAR(50)
);

CREATE TABLE practice_details (
    last_collection_date VARCHAR(50),
    practice_identifier VARCHAR(50),
    location_region VARCHAR(50),
    up_to_standard_date VARCHAR(50)
);

CREATE TABLE prescription_details (
    bnf_code VARCHAR(50),
    consultation_identifier VARCHAR(50),
    dosage_identifier VARCHAR(50),
    drug_mapped_dmd_code VARCHAR(50),
    event_date VARCHAR(50),
    issue_sequence_number VARCHAR(50),
    number_of_days VARCHAR(50),
    number_of_packs VARCHAR(50),
    pack_type VARCHAR(50),
    patient_identifier VARCHAR(50),
    prescribed_as_required VARCHAR(50),
    product_code VARCHAR(50),
    total_quantity VARCHAR(50),
    staff_identifier VARCHAR(50),
    system_date VARCHAR(50)
);

CREATE TABLE staff_information (
    staff_gender VARCHAR(50),
    staff_role VARCHAR(50),
    staff_identifier VARCHAR(50)
);