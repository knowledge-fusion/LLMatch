CREATE TABLE care_site (
    care_site_id VARCHAR(50),
    care_site_name VARCHAR(50),
    care_site_source_value VARCHAR(50),
    location_id VARCHAR(50),
    place_of_service_concept_id VARCHAR(50),
    place_of_service_source_value VARCHAR(50)
);

CREATE TABLE cdm_source (
    cdm_etl_reference VARCHAR(50),
    cdm_holder VARCHAR(50),
    cdm_release_date VARCHAR(50),
    cdm_source_abbreviation VARCHAR(50),
    cdm_source_name VARCHAR(50),
    cdm_version VARCHAR(50),
    cdm_version_concept_id VARCHAR(50),
    source_description VARCHAR(50),
    source_documentation_reference VARCHAR(50),
    source_release_date VARCHAR(50),
    vocabulary_version VARCHAR(50)
);

CREATE TABLE cohort (
    cohort_definition_id VARCHAR(50),
    cohort_end_date VARCHAR(50),
    cohort_start_date VARCHAR(50),
    subject_id VARCHAR(50)
);

CREATE TABLE cohort_definition (
    cohort_definition_description VARCHAR(50),
    cohort_definition_id VARCHAR(50),
    cohort_definition_name VARCHAR(50),
    cohort_definition_syntax VARCHAR(50),
    cohort_initiation_date VARCHAR(50),
    definition_type_concept_id VARCHAR(50),
    subject_concept_id VARCHAR(50)
);

CREATE TABLE concept (
    concept_class_id VARCHAR(50),
    concept_code VARCHAR(50),
    concept_id VARCHAR(50),
    concept_name VARCHAR(50),
    domain_id VARCHAR(50),
    invalid_reason VARCHAR(50),
    standard_concept VARCHAR(50),
    valid_end_date VARCHAR(50),
    valid_start_date VARCHAR(50),
    vocabulary_id VARCHAR(50)
);

CREATE TABLE concept_ancestor (
    ancestor_concept_id VARCHAR(50),
    descendant_concept_id VARCHAR(50),
    max_levels_of_separation VARCHAR(50),
    min_levels_of_separation VARCHAR(50)
);

CREATE TABLE concept_class (
    concept_class_concept_id VARCHAR(50),
    concept_class_id VARCHAR(50),
    concept_class_name VARCHAR(50)
);

CREATE TABLE concept_relationship (
    concept_id_1 VARCHAR(50),
    concept_id_2 VARCHAR(50),
    invalid_reason VARCHAR(50),
    relationship_id VARCHAR(50),
    valid_end_date VARCHAR(50),
    valid_start_date VARCHAR(50)
);

CREATE TABLE concept_synonym (
    concept_id VARCHAR(50),
    concept_synonym_name VARCHAR(50),
    language_concept_id VARCHAR(50)
);

CREATE TABLE condition_era (
    condition_concept_id VARCHAR(50),
    condition_era_end_date VARCHAR(50),
    condition_era_id VARCHAR(50),
    condition_era_start_date VARCHAR(50),
    condition_occurrence_count VARCHAR(50),
    person_id VARCHAR(50)
);

CREATE TABLE condition_occurrence (
    condition_concept_id VARCHAR(50),
    condition_end_date VARCHAR(50),
    condition_end_datetime VARCHAR(50),
    condition_occurrence_id VARCHAR(50),
    condition_source_concept_id VARCHAR(50),
    condition_source_value VARCHAR(50),
    condition_start_date VARCHAR(50),
    condition_start_datetime VARCHAR(50),
    condition_status_concept_id VARCHAR(50),
    condition_status_source_value VARCHAR(50),
    condition_type_concept_id VARCHAR(50),
    person_id VARCHAR(50),
    provider_id VARCHAR(50),
    stop_reason VARCHAR(50),
    visit_detail_id VARCHAR(50),
    visit_occurrence_id VARCHAR(50)
);

CREATE TABLE cost (
    amount_allowed VARCHAR(50),
    cost_domain_id VARCHAR(50),
    cost_event_id VARCHAR(50),
    cost_id VARCHAR(50),
    cost_type_concept_id VARCHAR(50),
    currency_concept_id VARCHAR(50),
    drg_concept_id VARCHAR(50),
    drg_source_value VARCHAR(50),
    paid_by_patient VARCHAR(50),
    paid_by_payer VARCHAR(50),
    paid_by_primary VARCHAR(50),
    paid_dispensing_fee VARCHAR(50),
    paid_ingredient_cost VARCHAR(50),
    paid_patient_coinsurance VARCHAR(50),
    paid_patient_copay VARCHAR(50),
    paid_patient_deductible VARCHAR(50),
    payer_plan_period_id VARCHAR(50),
    revenue_code_concept_id VARCHAR(50),
    revenue_code_source_value VARCHAR(50),
    total_charge VARCHAR(50),
    total_cost VARCHAR(50),
    total_paid VARCHAR(50)
);

CREATE TABLE death (
    cause_concept_id VARCHAR(50),
    cause_source_concept_id VARCHAR(50),
    cause_source_value VARCHAR(50),
    death_date VARCHAR(50),
    death_datetime VARCHAR(50),
    death_type_concept_id VARCHAR(50),
    person_id VARCHAR(50)
);

CREATE TABLE device_exposure (
    device_concept_id VARCHAR(50),
    device_exposure_end_date VARCHAR(50),
    device_exposure_end_datetime VARCHAR(50),
    device_exposure_id VARCHAR(50),
    device_exposure_start_date VARCHAR(50),
    device_exposure_start_datetime VARCHAR(50),
    device_source_concept_id VARCHAR(50),
    device_source_value VARCHAR(50),
    device_type_concept_id VARCHAR(50),
    person_id VARCHAR(50),
    production_id VARCHAR(50),
    provider_id VARCHAR(50),
    quantity VARCHAR(50),
    unique_device_id VARCHAR(50),
    unit_concept_id VARCHAR(50),
    unit_source_concept_id VARCHAR(50),
    unit_source_value VARCHAR(50),
    visit_detail_id VARCHAR(50),
    visit_occurrence_id VARCHAR(50)
);

CREATE TABLE domain (
    domain_concept_id VARCHAR(50),
    domain_id VARCHAR(50),
    domain_name VARCHAR(50)
);

CREATE TABLE dose_era (
    dose_era_end_date VARCHAR(50),
    dose_era_id VARCHAR(50),
    dose_era_start_date VARCHAR(50),
    dose_value VARCHAR(50),
    drug_concept_id VARCHAR(50),
    person_id VARCHAR(50),
    unit_concept_id VARCHAR(50)
);

CREATE TABLE drug_era (
    drug_concept_id VARCHAR(50),
    drug_era_end_date VARCHAR(50),
    drug_era_id VARCHAR(50),
    drug_era_start_date VARCHAR(50),
    drug_exposure_count VARCHAR(50),
    gap_days VARCHAR(50),
    person_id VARCHAR(50)
);

CREATE TABLE drug_exposure (
    days_supply VARCHAR(50),
    dose_unit_source_value VARCHAR(50),
    drug_concept_id VARCHAR(50),
    drug_exposure_end_date VARCHAR(50),
    drug_exposure_end_datetime VARCHAR(50),
    drug_exposure_id VARCHAR(50),
    drug_exposure_start_date VARCHAR(50),
    drug_exposure_start_datetime VARCHAR(50),
    drug_source_concept_id VARCHAR(50),
    drug_source_value VARCHAR(50),
    drug_type_concept_id VARCHAR(50),
    lot_number VARCHAR(50),
    person_id VARCHAR(50),
    provider_id VARCHAR(50),
    quantity VARCHAR(50),
    refills VARCHAR(50),
    route_concept_id VARCHAR(50),
    route_source_value VARCHAR(50),
    sig VARCHAR(50),
    stop_reason VARCHAR(50),
    verbatim_end_date VARCHAR(50),
    visit_detail_id VARCHAR(50),
    visit_occurrence_id VARCHAR(50)
);

CREATE TABLE drug_strength (
    amount_unit_concept_id VARCHAR(50),
    amount_value VARCHAR(50),
    box_size VARCHAR(50),
    denominator_unit_concept_id VARCHAR(50),
    denominator_value VARCHAR(50),
    drug_concept_id VARCHAR(50),
    ingredient_concept_id VARCHAR(50),
    invalid_reason VARCHAR(50),
    numerator_unit_concept_id VARCHAR(50),
    numerator_value VARCHAR(50),
    valid_end_date VARCHAR(50),
    valid_start_date VARCHAR(50)
);

CREATE TABLE episode (
    episode_concept_id VARCHAR(50),
    episode_end_date VARCHAR(50),
    episode_end_datetime VARCHAR(50),
    episode_id VARCHAR(50),
    episode_number VARCHAR(50),
    episode_object_concept_id VARCHAR(50),
    episode_parent_id VARCHAR(50),
    episode_source_concept_id VARCHAR(50),
    episode_source_value VARCHAR(50),
    episode_start_date VARCHAR(50),
    episode_start_datetime VARCHAR(50),
    episode_type_concept_id VARCHAR(50),
    person_id VARCHAR(50)
);

CREATE TABLE episode_event (
    episode_event_field_concept_id VARCHAR(50),
    episode_id VARCHAR(50),
    event_id VARCHAR(50)
);

CREATE TABLE fact_relationship (
    domain_concept_id_1 VARCHAR(50),
    domain_concept_id_2 VARCHAR(50),
    fact_id_1 VARCHAR(50),
    fact_id_2 VARCHAR(50),
    relationship_concept_id VARCHAR(50)
);

CREATE TABLE location (
    address_1 VARCHAR(50),
    address_2 VARCHAR(50),
    city VARCHAR(50),
    country_concept_id VARCHAR(50),
    country_source_value VARCHAR(50),
    county VARCHAR(50),
    latitude VARCHAR(50),
    location_id VARCHAR(50),
    location_source_value VARCHAR(50),
    longitude VARCHAR(50),
    state VARCHAR(50),
    zip VARCHAR(50)
);

CREATE TABLE measurement (
    meas_event_field_concept_id VARCHAR(50),
    measurement_concept_id VARCHAR(50),
    measurement_date VARCHAR(50),
    measurement_datetime VARCHAR(50),
    measurement_event_id VARCHAR(50),
    measurement_id VARCHAR(50),
    measurement_source_concept_id VARCHAR(50),
    measurement_source_value VARCHAR(50),
    measurement_time VARCHAR(50),
    measurement_type_concept_id VARCHAR(50),
    operator_concept_id VARCHAR(50),
    person_id VARCHAR(50),
    provider_id VARCHAR(50),
    range_high VARCHAR(50),
    range_low VARCHAR(50),
    unit_concept_id VARCHAR(50),
    unit_source_concept_id VARCHAR(50),
    unit_source_value VARCHAR(50),
    value_as_concept_id VARCHAR(50),
    value_as_number VARCHAR(50),
    value_source_value VARCHAR(50),
    visit_detail_id VARCHAR(50),
    visit_occurrence_id VARCHAR(50)
);

CREATE TABLE metadata (
    metadata_concept_id VARCHAR(50),
    metadata_date VARCHAR(50),
    metadata_datetime VARCHAR(50),
    metadata_id VARCHAR(50),
    metadata_type_concept_id VARCHAR(50),
    name VARCHAR(50),
    value_as_concept_id VARCHAR(50),
    value_as_number VARCHAR(50),
    value_as_string VARCHAR(50)
);

CREATE TABLE note (
    encoding_concept_id VARCHAR(50),
    language_concept_id VARCHAR(50),
    note_class_concept_id VARCHAR(50),
    note_date VARCHAR(50),
    note_datetime VARCHAR(50),
    note_event_field_concept_id VARCHAR(50),
    note_event_id VARCHAR(50),
    note_id VARCHAR(50),
    note_source_value VARCHAR(50),
    note_text VARCHAR(50),
    note_title VARCHAR(50),
    note_type_concept_id VARCHAR(50),
    person_id VARCHAR(50),
    provider_id VARCHAR(50),
    visit_detail_id VARCHAR(50),
    visit_occurrence_id VARCHAR(50)
);

CREATE TABLE note_nlp (
    "offset" VARCHAR(50),
    lexical_variant VARCHAR(50),
    nlp_date VARCHAR(50),
    nlp_datetime VARCHAR(50),
    nlp_system VARCHAR(50),
    note_id VARCHAR(50),
    note_nlp_concept_id VARCHAR(50),
    note_nlp_id VARCHAR(50),
    note_nlp_source_concept_id VARCHAR(50),
    section_concept_id VARCHAR(50),
    snippet VARCHAR(50),
    term_exists VARCHAR(50),
    term_modifiers VARCHAR(50),
    term_temporal VARCHAR(50)
);

CREATE TABLE observation (
    obs_event_field_concept_id VARCHAR(50),
    observation_concept_id VARCHAR(50),
    observation_date VARCHAR(50),
    observation_datetime VARCHAR(50),
    observation_event_id VARCHAR(50),
    observation_id VARCHAR(50),
    observation_source_concept_id VARCHAR(50),
    observation_source_value VARCHAR(50),
    observation_type_concept_id VARCHAR(50),
    person_id VARCHAR(50),
    provider_id VARCHAR(50),
    qualifier_concept_id VARCHAR(50),
    qualifier_source_value VARCHAR(50),
    unit_concept_id VARCHAR(50),
    unit_source_value VARCHAR(50),
    value_as_concept_id VARCHAR(50),
    value_as_number VARCHAR(50),
    value_as_string VARCHAR(50),
    value_source_value VARCHAR(50),
    visit_detail_id VARCHAR(50),
    visit_occurrence_id VARCHAR(50)
);

CREATE TABLE observation_period (
    observation_period_end_date VARCHAR(50),
    observation_period_id VARCHAR(50),
    observation_period_start_date VARCHAR(50),
    period_type_concept_id VARCHAR(50),
    person_id VARCHAR(50)
);

CREATE TABLE payer_plan_period (
    family_source_value VARCHAR(50),
    payer_concept_id VARCHAR(50),
    payer_plan_period_end_date VARCHAR(50),
    payer_plan_period_id VARCHAR(50),
    payer_plan_period_start_date VARCHAR(50),
    payer_source_concept_id VARCHAR(50),
    payer_source_value VARCHAR(50),
    person_id VARCHAR(50),
    plan_concept_id VARCHAR(50),
    plan_source_concept_id VARCHAR(50),
    plan_source_value VARCHAR(50),
    sponsor_concept_id VARCHAR(50),
    sponsor_source_concept_id VARCHAR(50),
    sponsor_source_value VARCHAR(50),
    stop_reason_concept_id VARCHAR(50),
    stop_reason_source_concept_id VARCHAR(50),
    stop_reason_source_value VARCHAR(50)
);

CREATE TABLE person (
    birth_datetime VARCHAR(50),
    care_site_id VARCHAR(50),
    day_of_birth VARCHAR(50),
    ethnicity_concept_id VARCHAR(50),
    ethnicity_source_concept_id VARCHAR(50),
    ethnicity_source_value VARCHAR(50),
    gender_concept_id VARCHAR(50),
    gender_source_concept_id VARCHAR(50),
    gender_source_value VARCHAR(50),
    location_id VARCHAR(50),
    month_of_birth VARCHAR(50),
    person_id VARCHAR(50),
    person_source_value VARCHAR(50),
    provider_id VARCHAR(50),
    race_concept_id VARCHAR(50),
    race_source_concept_id VARCHAR(50),
    race_source_value VARCHAR(50),
    year_of_birth VARCHAR(50)
);

CREATE TABLE procedure_occurrence (
    modifier_concept_id VARCHAR(50),
    modifier_source_value VARCHAR(50),
    person_id VARCHAR(50),
    procedure_concept_id VARCHAR(50),
    procedure_date VARCHAR(50),
    procedure_datetime VARCHAR(50),
    procedure_end_date VARCHAR(50),
    procedure_end_datetime VARCHAR(50),
    procedure_occurrence_id VARCHAR(50),
    procedure_source_concept_id VARCHAR(50),
    procedure_source_value VARCHAR(50),
    procedure_type_concept_id VARCHAR(50),
    provider_id VARCHAR(50),
    quantity VARCHAR(50),
    visit_detail_id VARCHAR(50),
    visit_occurrence_id VARCHAR(50)
);

CREATE TABLE provider (
    care_site_id VARCHAR(50),
    dea VARCHAR(50),
    gender_concept_id VARCHAR(50),
    gender_source_concept_id VARCHAR(50),
    gender_source_value VARCHAR(50),
    npi VARCHAR(50),
    provider_id VARCHAR(50),
    provider_name VARCHAR(50),
    provider_source_value VARCHAR(50),
    specialty_concept_id VARCHAR(50),
    specialty_source_concept_id VARCHAR(50),
    specialty_source_value VARCHAR(50),
    year_of_birth VARCHAR(50)
);

CREATE TABLE relationship (
    defines_ancestry VARCHAR(50),
    is_hierarchical VARCHAR(50),
    relationship_concept_id VARCHAR(50),
    relationship_id VARCHAR(50),
    relationship_name VARCHAR(50),
    reverse_relationship_id VARCHAR(50)
);

CREATE TABLE source_to_concept_map (
    invalid_reason VARCHAR(50),
    source_code VARCHAR(50),
    source_code_description VARCHAR(50),
    source_concept_id VARCHAR(50),
    source_vocabulary_id VARCHAR(50),
    target_concept_id VARCHAR(50),
    target_vocabulary_id VARCHAR(50),
    valid_end_date VARCHAR(50),
    valid_start_date VARCHAR(50)
);

CREATE TABLE specimen (
    anatomic_site_concept_id VARCHAR(50),
    anatomic_site_source_value VARCHAR(50),
    disease_status_concept_id VARCHAR(50),
    disease_status_source_value VARCHAR(50),
    person_id VARCHAR(50),
    quantity VARCHAR(50),
    specimen_concept_id VARCHAR(50),
    specimen_date VARCHAR(50),
    specimen_datetime VARCHAR(50),
    specimen_id VARCHAR(50),
    specimen_source_id VARCHAR(50),
    specimen_source_value VARCHAR(50),
    specimen_type_concept_id VARCHAR(50),
    unit_concept_id VARCHAR(50),
    unit_source_value VARCHAR(50)
);

CREATE TABLE visit_detail (
    admitted_from_concept_id VARCHAR(50),
    admitted_from_source_value VARCHAR(50),
    care_site_id VARCHAR(50),
    discharged_to_concept_id VARCHAR(50),
    discharged_to_source_value VARCHAR(50),
    parent_visit_detail_id VARCHAR(50),
    person_id VARCHAR(50),
    preceding_visit_detail_id VARCHAR(50),
    provider_id VARCHAR(50),
    visit_detail_concept_id VARCHAR(50),
    visit_detail_end_date VARCHAR(50),
    visit_detail_end_datetime VARCHAR(50),
    visit_detail_id VARCHAR(50),
    visit_detail_source_concept_id VARCHAR(50),
    visit_detail_source_value VARCHAR(50),
    visit_detail_start_date VARCHAR(50),
    visit_detail_start_datetime VARCHAR(50),
    visit_detail_type_concept_id VARCHAR(50),
    visit_occurrence_id VARCHAR(50)
);

CREATE TABLE visit_occurrence (
    admitted_from_concept_id VARCHAR(50),
    admitted_from_source_value VARCHAR(50),
    care_site_id VARCHAR(50),
    discharged_to_concept_id VARCHAR(50),
    discharged_to_source_value VARCHAR(50),
    person_id VARCHAR(50),
    preceding_visit_occurrence_id VARCHAR(50),
    provider_id VARCHAR(50),
    visit_concept_id VARCHAR(50),
    visit_end_date VARCHAR(50),
    visit_end_datetime VARCHAR(50),
    visit_occurrence_id VARCHAR(50),
    visit_source_concept_id VARCHAR(50),
    visit_source_value VARCHAR(50),
    visit_start_date VARCHAR(50),
    visit_start_datetime VARCHAR(50),
    visit_type_concept_id VARCHAR(50)
);

CREATE TABLE vocabulary (
    vocabulary_concept_id VARCHAR(50),
    vocabulary_id VARCHAR(50),
    vocabulary_name VARCHAR(50),
    vocabulary_reference VARCHAR(50),
    vocabulary_version VARCHAR(50)
);