CREATE TABLE consultation_information (
    event_date VARCHAR(50),
    consultation_identifier VARCHAR(50),
    consultation_source_code_identifier VARCHAR(50),
    emis_consultation_source_identifier VARCHAR(50),
    cprd_consultation_source_identifier VARCHAR(50),
    entered_date VARCHAR(50),
    patient_identifier VARCHAR(50),
    practice_identifier VARCHAR(50),
    staff_identifier VARCHAR(50)
);

CREATE TABLE medical_history (
    consultation_identifier VARCHAR(50),
    entered_date VARCHAR(50),
    medical_code VARCHAR(50),
    numeric_range_high VARCHAR(50),
    numeric_range_low VARCHAR(50),
    numeric_unit_identifier VARCHAR(50),
    event_date VARCHAR(50),
    observation_identifier VARCHAR(50),
    observation_type_identifier VARCHAR(50),
    parent_observation_identifier VARCHAR(50),
    patient_identifier VARCHAR(50),
    practice_identifier VARCHAR(50),
    problem_observation_identifier VARCHAR(50),
    staff_identifier VARCHAR(50),
    measurement_value VARCHAR(50),
    expected_duration VARCHAR(50),
    last_review_date VARCHAR(50),
    last_review_staff_identifier VARCHAR(50),
    parent_problem_observation_identifier VARCHAR(50),
    parent_problem_relationship_identifier VARCHAR(50),
    problem_end_date VARCHAR(50),
    problem_status_identifier VARCHAR(50),
    problem_significance VARCHAR(50)
);

CREATE TABLE patient_referral (
    observation_identifier VARCHAR(50),
    patient_identifier VARCHAR(50),
    practice_identifier VARCHAR(50),
    referral_mode_identifier VARCHAR(50),
    referral_service_type_identifier VARCHAR(50),
    referral_source_organization_identifier VARCHAR(50),
    referral_target_organization_identifier VARCHAR(50),
    referral_urgency_identifier VARCHAR(50)
);

CREATE TABLE patient_registration_details (
    quality_flag VARCHAR(50),
    cprd_death_date VARCHAR(50),
    emis_death_date VARCHAR(50),
    gender_code VARCHAR(50),
    month_of_birth VARCHAR(50),
    patient_identifier VARCHAR(50),
    patient_category VARCHAR(50),
    practice_identifier VARCHAR(50),
    registration_end_date VARCHAR(50),
    registration_start_date VARCHAR(50),
    usual_gp VARCHAR(50),
    year_of_birth VARCHAR(50)
);

CREATE TABLE practice_details (
    last_collection_date VARCHAR(50),
    practice_identifier VARCHAR(50),
    practice_region VARCHAR(50),
    up_to_standard_date VARCHAR(50)
);

CREATE TABLE practice_staff (
    job_category_id VARCHAR(50),
    practice_identifier VARCHAR(50),
    staff_identifier VARCHAR(50)
);

CREATE TABLE prescriptions (
    dosage_identifier VARCHAR(50),
    drug_record_identifier VARCHAR(50),
    course_duration VARCHAR(50),
    entered_date VARCHAR(50),
    estimated_nhs_cost VARCHAR(50),
    event_date VARCHAR(50),
    issue_identifier VARCHAR(50),
    patient_identifier VARCHAR(50),
    practice_identifier VARCHAR(50),
    problem_observation_identifier VARCHAR(50),
    product_code_identifier VARCHAR(50),
    quantity VARCHAR(50),
    quantity_unit_identifier VARCHAR(50),
    staff_identifier VARCHAR(50)
);