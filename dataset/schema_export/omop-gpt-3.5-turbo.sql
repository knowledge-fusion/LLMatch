CREATE TABLE biological_sample (
    anatomic_site_identifier VARCHAR(50),
    anatomic_site_source VARCHAR(50),
    disease_status_identifier VARCHAR(50),
    disease_status_source VARCHAR(50),
    person_identifier VARCHAR(50),
    quantity VARCHAR(50),
    specimen_identifier VARCHAR(50),
    specimen_collection_date VARCHAR(50),
    specimen_collection_datetime VARCHAR(50),
    specimen_source_identifier VARCHAR(50),
    specimen_source_value VARCHAR(50),
    specimen_type_identifier VARCHAR(50),
    unit_concept_identifier VARCHAR(50),
    unit_source_value VARCHAR(50)
);

CREATE TABLE clinical_episode (
    episode_concept_identifier VARCHAR(50),
    end_date VARCHAR(50),
    end_datetime VARCHAR(50),
    episode_identifier VARCHAR(50),
    episode_number VARCHAR(50),
    object_concept_identifier VARCHAR(50),
    parent_episode_identifier VARCHAR(50),
    source_concept_identifier VARCHAR(50),
    source_value VARCHAR(50),
    start_date VARCHAR(50),
    start_datetime VARCHAR(50),
    type_concept_identifier VARCHAR(50),
    person_identifier VARCHAR(50)
);

CREATE TABLE clinical_event_episode (
    episode_event_concept_identifier VARCHAR(50),
    episode_identifier VARCHAR(50),
    event_identifier VARCHAR(50)
);

CREATE TABLE clinical_note_nlp (
    term_offset VARCHAR(50),
    term_variant VARCHAR(50),
    nlp_date VARCHAR(50),
    nlp_datetime VARCHAR(50),
    nlp_system VARCHAR(50),
    note_identifier VARCHAR(50),
    note_nlp_concept_id VARCHAR(50),
    note_nlp_identifier VARCHAR(50),
    note_nlp_source_concept_id VARCHAR(50),
    section_concept_id VARCHAR(50),
    snippet VARCHAR(50),
    term_exists VARCHAR(50),
    term_modifiers VARCHAR(50),
    term_temporal VARCHAR(50)
);

CREATE TABLE clinical_observation (
    observation_event_field_concept_identifier VARCHAR(50),
    observation_concept_identifier VARCHAR(50),
    observation_date VARCHAR(50),
    observation_datetime VARCHAR(50),
    observation_event_identifier VARCHAR(50),
    observation_identifier VARCHAR(50),
    observation_source_concept_identifier VARCHAR(50),
    observation_source_value VARCHAR(50),
    observation_type_concept_identifier VARCHAR(50),
    person_identifier VARCHAR(50),
    provider_identifier VARCHAR(50),
    qualifier_concept_identifier VARCHAR(50),
    qualifier_source_value VARCHAR(50),
    unit_concept_identifier VARCHAR(50),
    unit_source_value VARCHAR(50),
    measurement_value_as_concept_identifier VARCHAR(50),
    measurement_value_as_number VARCHAR(50),
    measurement_value_as_string VARCHAR(50),
    measurement_value_source_value VARCHAR(50),
    visit_detail_identifier VARCHAR(50),
    visit_occurrence_identifier VARCHAR(50)
);

CREATE TABLE clinical_observation_period (
    end_date VARCHAR(50),
    observation_period_identifier VARCHAR(50),
    start_date VARCHAR(50),
    period_type_concept_identifier VARCHAR(50),
    person_identifier VARCHAR(50)
);

CREATE TABLE concept_association (
    source_concept_identifier VARCHAR(50),
    destination_concept_identifier VARCHAR(50),
    invalidation_reason VARCHAR(50),
    relationship_identifier VARCHAR(50),
    invalidation_date VARCHAR(50),
    validity_start_date VARCHAR(50),
    is_subset_of_hierarchy VARCHAR(50),
    is_hierarchical_relationship VARCHAR(50),
    relationship_concept_identifier VARCHAR(50),
    relationship_description VARCHAR(50),
    reverse_association_identifier VARCHAR(50)
);

CREATE TABLE concept_classification (
    classification_concept_identifier VARCHAR(50),
    classification_identifier VARCHAR(50),
    classification_name VARCHAR(50)
);

CREATE TABLE concept_relationship_hierarchy (
    higher_level_concept_id VARCHAR(50),
    lower_level_concept_id VARCHAR(50),
    maximum_hierarchy_level VARCHAR(50),
    minimum_hierarchy_level VARCHAR(50)
);

CREATE TABLE condition_period (
    condition_concept_identifier VARCHAR(50),
    condition_period_end_date VARCHAR(50),
    condition_period_identifier VARCHAR(50),
    condition_period_start_date VARCHAR(50),
    condition_occurrence_count VARCHAR(50),
    person_identifier VARCHAR(50)
);

CREATE TABLE condition_record (
    condition_concept_identifier VARCHAR(50),
    condition_end_date VARCHAR(50),
    condition_end_datetime VARCHAR(50),
    condition_record_identifier VARCHAR(50),
    condition_source_concept_identifier VARCHAR(50),
    condition_source_value VARCHAR(50),
    condition_start_date VARCHAR(50),
    condition_start_datetime VARCHAR(50),
    condition_status_concept_identifier VARCHAR(50),
    condition_status_source_value VARCHAR(50),
    condition_type_concept_identifier VARCHAR(50),
    person_identifier VARCHAR(50),
    provider_identifier VARCHAR(50),
    condition_stop_reason VARCHAR(50),
    visit_detail_identifier VARCHAR(50),
    visit_occurrence_identifier VARCHAR(50)
);

CREATE TABLE constant_dose (
    end_date VARCHAR(50),
    dose_era_identifier VARCHAR(50),
    start_date VARCHAR(50),
    dose_quantity VARCHAR(50),
    active_ingredient_concept_identifier VARCHAR(50),
    person_identifier VARCHAR(50),
    unit_concept_identifier VARCHAR(50)
);

CREATE TABLE dataset_metadata (
    metadata_concept_identifier VARCHAR(50),
    metadata_date VARCHAR(50),
    metadata_datetime VARCHAR(50),
    metadata_identifier VARCHAR(50),
    metadata_type_concept_identifier VARCHAR(50),
    metadata_name VARCHAR(50),
    measurement_value_as_concept_identifier VARCHAR(50),
    measurement_value_as_number VARCHAR(50),
    measurement_value_as_string VARCHAR(50)
);

CREATE TABLE death_event (
    condition_concept_identifier VARCHAR(50),
    condition_source_concept_identifier VARCHAR(50),
    condition_source_code VARCHAR(50),
    death_date VARCHAR(50),
    death_date_time VARCHAR(50),
    death_event_concept_identifier VARCHAR(50),
    deceased_person_identifier VARCHAR(50)
);

CREATE TABLE drug_ingredient_concentration (
    active_ingredient_unit_identifier VARCHAR(50),
    active_ingredient_value VARCHAR(50),
    drug_box_size VARCHAR(50),
    ingredient_concentration_denominator_unit_identifier VARCHAR(50),
    ingredient_concentration_denominator_value VARCHAR(50),
    drug_identifier VARCHAR(50),
    ingredient_identifier VARCHAR(50),
    invalidation_reason VARCHAR(50),
    ingredient_concentration_numerator_unit_identifier VARCHAR(50),
    ingredient_concentration_numerator_value VARCHAR(50),
    invalidation_date VARCHAR(50),
    validity_start_date VARCHAR(50)
);

CREATE TABLE drug_period (
    active_ingredient_concept_identifier VARCHAR(50),
    drug_period_end_date VARCHAR(50),
    drug_period_identifier VARCHAR(50),
    drug_period_start_date VARCHAR(50),
    drug_exposure_occurrences VARCHAR(50),
    uncovered_days VARCHAR(50),
    person_identifier VARCHAR(50)
);

CREATE TABLE drug_use (
    days_supply VARCHAR(50),
    dose_unit VARCHAR(50),
    active_ingredient_concept_identifier VARCHAR(50),
    end_date VARCHAR(50),
    end_datetime VARCHAR(50),
    drug_use_identifier VARCHAR(50),
    start_date VARCHAR(50),
    start_datetime VARCHAR(50),
    source_concept_identifier VARCHAR(50),
    source_code VARCHAR(50),
    record_type_concept_identifier VARCHAR(50),
    batch_number VARCHAR(50),
    person_identifier VARCHAR(50),
    provider_identifier VARCHAR(50),
    quantity VARCHAR(50),
    refills VARCHAR(50),
    route_concept_identifier VARCHAR(50),
    route VARCHAR(50),
    prescription_directions VARCHAR(50),
    condition_stop_reason VARCHAR(50),
    known_end_date VARCHAR(50),
    visit_detail_identifier VARCHAR(50),
    visit_occurrence_identifier VARCHAR(50)
);

CREATE TABLE enrollment_period (
    family_code VARCHAR(50),
    payer_concept_identifier VARCHAR(50),
    enrollment_period_end_date VARCHAR(50),
    enrollment_period_identifier VARCHAR(50),
    enrollment_period_start_date VARCHAR(50),
    payer_source_concept_identifier VARCHAR(50),
    payer_source_code VARCHAR(50),
    person_identifier VARCHAR(50),
    plan_concept_identifier VARCHAR(50),
    plan_source_concept_identifier VARCHAR(50),
    plan_source_code VARCHAR(50),
    sponsor_concept_identifier VARCHAR(50),
    sponsor_source_concept_identifier VARCHAR(50),
    sponsor_source_code VARCHAR(50),
    stop_reason_concept_identifier VARCHAR(50),
    stop_reason_source_concept_identifier VARCHAR(50),
    stop_reason_source_code VARCHAR(50)
);

CREATE TABLE fact_association (
    fact_one_domain_concept_id VARCHAR(50),
    fact_two_domain_concept_id VARCHAR(50),
    fact_one_identifier VARCHAR(50),
    fact_two_identifier VARCHAR(50),
    relationship_concept_identifier VARCHAR(50)
);

CREATE TABLE geographic_location (
    street_address VARCHAR(50),
    additional_address_details VARCHAR(50),
    city VARCHAR(50),
    country_concept_identifier VARCHAR(50),
    country_source_value VARCHAR(50),
    county VARCHAR(50),
    latitude VARCHAR(50),
    geographic_location_identifier VARCHAR(50),
    location_source_value VARCHAR(50),
    longitude VARCHAR(50),
    state_abbreviation VARCHAR(50),
    postal_code VARCHAR(50)
);

CREATE TABLE healthcare_institution (
    healthcare_institution_identifier VARCHAR(50),
    healthcare_institution_name VARCHAR(50),
    healthcare_institution_source_value VARCHAR(50),
    geographic_location_identifier VARCHAR(50),
    place_of_service_concept_id VARCHAR(50),
    place_of_service_source_value VARCHAR(50)
);

CREATE TABLE healthcare_provider (
    healthcare_institution_identifier VARCHAR(50),
    drug_enforcement_administration_number VARCHAR(50),
    gender_concept_id VARCHAR(50),
    gender_source_concept_id VARCHAR(50),
    gender_source_value VARCHAR(50),
    national_provider_identifier VARCHAR(50),
    provider_identifier VARCHAR(50),
    provider_description VARCHAR(50),
    provider_source_value VARCHAR(50),
    standard_specialty_concept_id VARCHAR(50),
    specialty_source_concept_id VARCHAR(50),
    specialty_source_value VARCHAR(50),
    year_of_birth VARCHAR(50)
);

CREATE TABLE medical_entity_cost (
    contracted_amount VARCHAR(50),
    cost_domain_concept_id VARCHAR(50),
    event_identifier VARCHAR(50),
    cost_identifier VARCHAR(50),
    cost_type_concept_identifier VARCHAR(50),
    currency_concept_identifier VARCHAR(50),
    diagnosis_related_group_concept_identifier VARCHAR(50),
    diagnosis_related_group_code VARCHAR(50),
    total_amount_paid_by_patient VARCHAR(50),
    total_amount_paid_by_payer VARCHAR(50),
    total_amount_paid_by_primary_payer VARCHAR(50),
    amount_paid_to_pharmacy_for_dispensing VARCHAR(50),
    amount_paid_to_pharmacy_for_drug VARCHAR(50),
    total_amount_paid_by_patient_for_coinsurance VARCHAR(50),
    total_amount_paid_by_patient_for_copay VARCHAR(50),
    total_amount_paid_by_patient_towards_deductible VARCHAR(50),
    payer_plan_period_identifier VARCHAR(50),
    standard_concept_identifier_for_revenue_codes VARCHAR(50),
    revenue_code_source_code VARCHAR(50),
    total_amount_charged VARCHAR(50),
    total_cost_incurred VARCHAR(50),
    total_amount_actually_paid VARCHAR(50)
);

CREATE TABLE medical_visit_record (
    admitting_source_concept_identifier VARCHAR(50),
    admitting_source_source_value VARCHAR(50),
    healthcare_institution_identifier VARCHAR(50),
    discharge_disposition_concept_identifier VARCHAR(50),
    discharge_disposition_source_value VARCHAR(50),
    person_identifier VARCHAR(50),
    preceding_visit_occurrence_identifier VARCHAR(50),
    provider_identifier VARCHAR(50),
    visit_concept_identifier VARCHAR(50),
    visit_end_date VARCHAR(50),
    visit_end_datetime VARCHAR(50),
    medical_visit_record_identifier VARCHAR(50),
    visit_source_concept_identifier VARCHAR(50),
    visit_source_source_value VARCHAR(50),
    visit_start_date VARCHAR(50),
    visit_start_datetime VARCHAR(50),
    visit_type_concept_identifier VARCHAR(50)
);

CREATE TABLE omop_domain (
    domain_concept_identifier VARCHAR(50),
    domain_identifier VARCHAR(50),
    domain_category VARCHAR(50)
);

CREATE TABLE patient_notes (
    encoding_type VARCHAR(50),
    language_identifier VARCHAR(50),
    note_class_type VARCHAR(50),
    note_date VARCHAR(50),
    note_datetime VARCHAR(50),
    note_event_field_type VARCHAR(50),
    note_event_identifier VARCHAR(50),
    note_identifier VARCHAR(50),
    note_source_value VARCHAR(50),
    note_content VARCHAR(50),
    note_title VARCHAR(50),
    note_type VARCHAR(50),
    person_identifier VARCHAR(50),
    provider_identifier VARCHAR(50),
    visit_detail_identifier VARCHAR(50),
    visit_occurrence_identifier VARCHAR(50)
);

CREATE TABLE person_information (
    date_of_birth VARCHAR(50),
    healthcare_institution_identifier VARCHAR(50),
    day_of_birth VARCHAR(50),
    ethnicity_concept_id VARCHAR(50),
    ethnicity_source_concept_id VARCHAR(50),
    ethnicity_source_value VARCHAR(50),
    gender_concept_id VARCHAR(50),
    gender_source_concept_id VARCHAR(50),
    gender_source_value VARCHAR(50),
    geographic_location_identifier VARCHAR(50),
    month_of_birth VARCHAR(50),
    person_identifier VARCHAR(50),
    person_source_value VARCHAR(50),
    provider_identifier VARCHAR(50),
    race_concept_id VARCHAR(50),
    race_source_concept_id VARCHAR(50),
    race_source_value VARCHAR(50),
    year_of_birth VARCHAR(50)
);

CREATE TABLE physical_devices (
    device_concept_identifier VARCHAR(50),
    device_exposure_end_date VARCHAR(50),
    device_exposure_end_datetime VARCHAR(50),
    device_exposure_identifier VARCHAR(50),
    device_exposure_start_date VARCHAR(50),
    device_exposure_start_datetime VARCHAR(50),
    device_source_concept_identifier VARCHAR(50),
    device_source_value VARCHAR(50),
    device_type_concept_identifier VARCHAR(50),
    person_identifier VARCHAR(50),
    production_identifier VARCHAR(50),
    provider_identifier VARCHAR(50),
    quantity VARCHAR(50),
    unique_device_identifier VARCHAR(50),
    unit_concept_identifier VARCHAR(50),
    unit_source_concept_identifier VARCHAR(50),
    unit_source_value VARCHAR(50),
    visit_detail_identifier VARCHAR(50),
    visit_occurrence_identifier VARCHAR(50)
);

CREATE TABLE procedure_record (
    modifier VARCHAR(50),
    modifier_source VARCHAR(50),
    person_identifier VARCHAR(50),
    procedure_concept VARCHAR(50),
    procedure_date VARCHAR(50),
    procedure_datetime VARCHAR(50),
    procedure_end_date VARCHAR(50),
    procedure_end_datetime VARCHAR(50),
    procedure_occurrence_identifier VARCHAR(50),
    procedure_source_concept VARCHAR(50),
    procedure_source VARCHAR(50),
    procedure_type_concept VARCHAR(50),
    provider_identifier VARCHAR(50),
    quantity VARCHAR(50),
    visit_detail_identifier VARCHAR(50),
    visit_occurrence_identifier VARCHAR(50)
);

CREATE TABLE source_code_mapping (
    invalidation_reason VARCHAR(50),
    source_code VARCHAR(50),
    source_code_description VARCHAR(50),
    source_concept_identifier VARCHAR(50),
    source_vocabulary_identifier VARCHAR(50),
    target_concept_identifier VARCHAR(50),
    target_vocabulary_identifier VARCHAR(50),
    invalidation_date VARCHAR(50),
    validity_start_date VARCHAR(50)
);

CREATE TABLE source_info (
    etl_reference VARCHAR(50),
    organization_name VARCHAR(50),
    instance_release_date VARCHAR(50),
    source_abbreviation VARCHAR(50),
    source_name VARCHAR(50),
    cdm_version VARCHAR(50),
    cdm_version_concept_id VARCHAR(50),
    source_data_description VARCHAR(50),
    source_documentation_reference VARCHAR(50),
    source_release_date VARCHAR(50),
    vocabulary_version VARCHAR(50)
);

CREATE TABLE source_vocabulary (
    standard_concept_identifier VARCHAR(50),
    vocabulary_identifier VARCHAR(50),
    vocabulary_description VARCHAR(50),
    vocabulary_documentation VARCHAR(50),
    vocabulary_version VARCHAR(50)
);

CREATE TABLE standardized_vocabularies (
    classification_id VARCHAR(50),
    vocabulary_code VARCHAR(50),
    concept_identifier VARCHAR(50),
    concept_description VARCHAR(50),
    domain_identifier VARCHAR(50),
    invalidation_reason VARCHAR(50),
    is_standard_concept VARCHAR(50),
    invalidation_date VARCHAR(50),
    validity_start_date VARCHAR(50),
    vocabulary_identifier VARCHAR(50)
);

CREATE TABLE structured_measurement (
    measurement_event_field_concept_identifier VARCHAR(50),
    measurement_concept_identifier VARCHAR(50),
    measurement_date VARCHAR(50),
    measurement_datetime VARCHAR(50),
    measurement_event_identifier VARCHAR(50),
    measurement_identifier VARCHAR(50),
    measurement_source_concept_identifier VARCHAR(50),
    measurement_source_value VARCHAR(50),
    measurement_time VARCHAR(50),
    measurement_type_concept_identifier VARCHAR(50),
    operator_concept_identifier VARCHAR(50),
    person_identifier VARCHAR(50),
    provider_identifier VARCHAR(50),
    measurement_normal_range_upper VARCHAR(50),
    measurement_normal_range_lower VARCHAR(50),
    measurement_unit_concept_identifier VARCHAR(50),
    unit_source_concept_identifier VARCHAR(50),
    unit_source_value VARCHAR(50),
    measurement_value_as_concept_identifier VARCHAR(50),
    measurement_value_as_number VARCHAR(50),
    measurement_value_source_value VARCHAR(50),
    visit_detail_identifier VARCHAR(50),
    visit_occurrence_identifier VARCHAR(50)
);

CREATE TABLE subject_cohort (
    cohort_definition_identifier VARCHAR(50),
    cohort_end_date VARCHAR(50),
    cohort_start_date VARCHAR(50),
    subject_identifier VARCHAR(50)
);

CREATE TABLE subject_cohort_definition (
    cohort_description VARCHAR(50),
    cohort_definition_identifier VARCHAR(50),
    cohort_short_description VARCHAR(50),
    cohort_definition_syntax VARCHAR(50),
    cohort_initiation_date VARCHAR(50),
    cohort_definition_type_concept_id VARCHAR(50),
    subject_concept_identifier VARCHAR(50)
);

CREATE TABLE visit_detail_information (
    admitted_from_concept_identifier VARCHAR(50),
    admitted_from_source_value VARCHAR(50),
    healthcare_institution_identifier VARCHAR(50),
    discharge_disposition_concept_identifier VARCHAR(50),
    discharge_disposition_source_value VARCHAR(50),
    parent_visit_detail_identifier VARCHAR(50),
    person_identifier VARCHAR(50),
    preceding_visit_detail_identifier VARCHAR(50),
    provider_identifier VARCHAR(50),
    visit_concept_identifier VARCHAR(50),
    visit_end_date VARCHAR(50),
    visit_end_datetime VARCHAR(50),
    visit_detail_identifier VARCHAR(50),
    visit_source_concept_identifier VARCHAR(50),
    visit_source_value VARCHAR(50),
    visit_start_date VARCHAR(50),
    visit_start_datetime VARCHAR(50),
    visit_type_concept_identifier VARCHAR(50),
    visit_occurrence_identifier VARCHAR(50)
);

CREATE TABLE vocabulary_synonym (
    concept_identifier VARCHAR(50),
    synonym VARCHAR(50),
    language_identifier VARCHAR(50)
);