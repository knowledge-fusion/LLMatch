CREATE TABLE biological_sample (
    anatomic_site_concept_identifier INTEGER,
    anatomic_site_source_code VARCHAR(50),
    disease_status_concept_identifier INTEGER,
    disease_status_source_code VARCHAR(50),
    person_identifier INTEGER,
    device_quantity NUMERIC,
    specimen_concept_identifier INTEGER,
    specimen_collect_date DATE,
    specimen_collect_datetime TIMESTAMP,
    specimen_identifier INTEGER,
    specimen_source_identifier VARCHAR(50),
    specimen_source_code VARCHAR(50),
    specimen_type_concept_identifier INTEGER,
    unit_concept_identifier INTEGER,
    unit_source_code VARCHAR(50)
);

COMMENT ON TABLE biological_sample IS 'This table contains records identifying biological samples collected from a person, including details of the anatomic site, disease status, and specimen-related information.';
COMMENT ON COLUMN biological_sample.anatomic_site_concept_identifier IS 'Foreign Key. A reference to a Standard Concept identifier for the anatomic location of specimen collection. Type: Integer';
COMMENT ON COLUMN biological_sample.anatomic_site_source_code IS 'The information about the anatomic site as detailed in the source. Type: Text';
COMMENT ON COLUMN biological_sample.disease_status_concept_identifier IS 'Foreign Key. A reference to a Standard Concept identifier for the disease status of specimen collection. Type: Integer';
COMMENT ON COLUMN biological_sample.disease_status_source_code IS 'The information about the disease status as detailed in the source. Type: Text';
COMMENT ON COLUMN biological_sample.person_identifier IS 'Foreign Key. A reference to the person for whom the specimen is recorded. Type: Integer';
COMMENT ON COLUMN biological_sample.device_quantity IS 'The amount of specimen collected from the person during the sampling procedure. Type: Numeric';
COMMENT ON COLUMN biological_sample.specimen_concept_identifier IS 'Foreign Key. A reference to a Standard Concept identifier in the Standardized Vocabularies for the specimen. Type: Integer';
COMMENT ON COLUMN biological_sample.specimen_collect_date IS 'The date the specimen was obtained from the person. Type: Date';
COMMENT ON COLUMN biological_sample.specimen_collect_datetime IS 'The date and time when the specimen was obtained from the person. Type: Timestamp';
COMMENT ON COLUMN biological_sample.specimen_identifier IS 'Primary Key. A unique identifier for each specimen. Type: Integer';
COMMENT ON COLUMN biological_sample.specimen_source_identifier IS 'The specimen identifier as it appears in the source data. Type: Text';
COMMENT ON COLUMN biological_sample.specimen_source_code IS 'The specimen value as it appears in the source data. This value is mapped to a Standard Concept in the standardized vocabularies, and the original code is stored here for reference. Type: Text';
COMMENT ON COLUMN biological_sample.specimen_type_concept_identifier IS 'Foreign Key. A reference to the concept identifier in the standardized vocabularies representing the system of record for the specimen in the source data. Type: Integer';
COMMENT ON COLUMN biological_sample.unit_concept_identifier IS 'Foreign Key. A reference to a Standard Concept identifier for the unit associated with the numeric quantity of the specimen collection. Type: Integer';
COMMENT ON COLUMN biological_sample.unit_source_code IS 'The information about the unit as detailed in the source. Type: Text';

CREATE TABLE clinical_episode_summary (
    episode_abstraction_identifier INTEGER,
    episode_end_date DATE,
    episode_end_timestamp TIMESTAMP,
    episode_identifier INTEGER,
    episode_sequence_number INTEGER,
    episode_component_identifier INTEGER,
    parent_episode_identifier INTEGER,
    episode_source_concept_identifier INTEGER,
    episode_source_code VARCHAR(50),
    episode_start_date DATE,
    episode_start_timestamp TIMESTAMP,
    episode_origin_concept_identifier INTEGER,
    person_identifier INTEGER
);

COMMENT ON TABLE clinical_episode_summary IS 'This table aggregates lower-level clinical events (visit occurrences, drug exposures, procedure occurrences, device exposures) into a higher-level abstraction representing clinically and analytically relevant disease phases, outcomes, and treatments.';
COMMENT ON COLUMN clinical_episode_summary.episode_abstraction_identifier IS 'A concept representing the kind of abstraction related to the disease phase, outcome, or treatment. Type: Integer';
COMMENT ON COLUMN clinical_episode_summary.episode_end_date IS 'The date when the episode is considered to have ended. Type: Date';
COMMENT ON COLUMN clinical_episode_summary.episode_end_timestamp IS 'The date and time when the episode is considered to have ended. Type: Timestamp';
COMMENT ON COLUMN clinical_episode_summary.episode_identifier IS 'Primary Key. A unique identifier for each episode. Type: Integer';
COMMENT ON COLUMN clinical_episode_summary.episode_sequence_number IS 'Indicates the order of the episodes in a sequence, such as lines of treatment. Type: Integer';
COMMENT ON COLUMN clinical_episode_summary.episode_component_identifier IS 'A concept representing the specific disease phase, outcome, or treatment component of the episode. Type: Integer';
COMMENT ON COLUMN clinical_episode_summary.parent_episode_identifier IS 'References the episode that subsumes the given episode, used for nested episodes. Type: Integer';
COMMENT ON COLUMN clinical_episode_summary.episode_source_concept_identifier IS 'A foreign key to an episode concept used in the source data. Type: Integer';
COMMENT ON COLUMN clinical_episode_summary.episode_source_code IS 'The source code for the episode as it appears in the source data. Type: Text (50 characters max)';
COMMENT ON COLUMN clinical_episode_summary.episode_start_date IS 'The date when the episode begins. Type: Date';
COMMENT ON COLUMN clinical_episode_summary.episode_start_timestamp IS 'The date and time when the episode begins. Type: Timestamp';
COMMENT ON COLUMN clinical_episode_summary.episode_origin_concept_identifier IS 'Indicates the provenance of the episode, such as an EHR system, insurance claim, or registry. Type: Integer';
COMMENT ON COLUMN clinical_episode_summary.person_identifier IS 'Foreign Key. Identifies the person for whom the episode is recorded. Type: Integer';

CREATE TABLE clinical_event_to_episode_mapping (
    linked_record_source_identifier INTEGER,
    episode_identifier INTEGER,
    linked_record_identifier INTEGER
);

COMMENT ON TABLE clinical_event_to_episode_mapping IS 'This table connects qualifying clinical events such as condition occurrences, drug exposures, procedure occurrences, and measurements to the appropriate episode entry.';
COMMENT ON COLUMN clinical_event_to_episode_mapping.linked_record_source_identifier IS 'This field is the identifier that shows which table the primary key of the linked record came from. Type: Integer';
COMMENT ON COLUMN clinical_event_to_episode_mapping.episode_identifier IS 'Use this field to link the record to its episode. Type: Integer';
COMMENT ON COLUMN clinical_event_to_episode_mapping.linked_record_identifier IS 'This field is the primary key of the linked record in the database. For example, if the episode event is a condition occurrence, then the condition occurrence identifier of the linked record goes in this field. Type: Integer';

CREATE TABLE clinical_measurement (
    measurement_event_field_concept_identifier INTEGER,
    measurement_concept_identifier INTEGER,
    measurement_date DATE,
    measurement_date_time TIMESTAMP,
    measurement_event_identifier INTEGER,
    measurement_identifier INTEGER,
    measurement_source_concept_identifier INTEGER,
    measurement_source_code VARCHAR(50),
    measurement_time VARCHAR(10),
    measurement_type_concept_identifier INTEGER,
    operator_concept_identifier INTEGER,
    person_identifier INTEGER,
    provider_identifier INTEGER,
    range_upper_limit NUMERIC,
    range_lower_limit NUMERIC,
    unit_concept_identifier INTEGER,
    unit_source_concept_identifier INTEGER,
    unit_source_code VARCHAR(50),
    value_as_concept_identifier INTEGER,
    value_as_numeric NUMERIC,
    value_source_code VARCHAR(50),
    visit_detail_identifier INTEGER,
    visit_occurrence_identifier INTEGER
);

COMMENT ON TABLE clinical_measurement IS 'The clinical_measurement table contains records of measurements, including structured numerical or categorical values obtained through systematic and standardized examination or testing of a person or a person's sample. This includes both orders and results of measurements such as laboratory tests, vital signs, and quantitative findings from pathology reports.';
COMMENT ON COLUMN clinical_measurement.measurement_event_field_concept_identifier IS 'If the Measurement record is related to another record in the database, this field is the concept identifier that specifies which table the primary key of the linked record came from. Type: Integer';
COMMENT ON COLUMN clinical_measurement.measurement_concept_identifier IS 'Foreign Key. A reference to the standard measurement concept identifier in the standardized vocabularies. Type: Integer';
COMMENT ON COLUMN clinical_measurement.measurement_date IS 'The date the measurement was taken. Type: Date';
COMMENT ON COLUMN clinical_measurement.measurement_date_time IS 'The date and time the measurement was taken. Type: Timestamp';
COMMENT ON COLUMN clinical_measurement.measurement_event_identifier IS 'If the Measurement record is related to another record in the database, this field is the primary key of the linked record. Type: Integer';
COMMENT ON COLUMN clinical_measurement.measurement_identifier IS 'Primary Key. A unique identifier for each measurement. Type: Integer';
COMMENT ON COLUMN clinical_measurement.measurement_source_concept_identifier IS 'A foreign key to a concept in the standardized vocabularies that refers to the code used in the source. Type: Integer';
COMMENT ON COLUMN clinical_measurement.measurement_source_code IS 'The measurement name as it appears in the source data. This code is mapped to a standard concept in the standardized vocabularies, and the original code is stored here for reference. Type: Text (up to 50 characters)';
COMMENT ON COLUMN clinical_measurement.measurement_time IS 'This is present for backwards compatibility and will be deprecated in an upcoming version. Type: Text (up to 10 characters)';
COMMENT ON COLUMN clinical_measurement.measurement_type_concept_identifier IS 'A foreign key to the predefined concept in the standardized vocabularies reflecting the provenance from where the measurement record was recorded. Type: Integer';
COMMENT ON COLUMN clinical_measurement.operator_concept_identifier IS 'A foreign key identifier to the predefined concept in the standardized vocabularies reflecting the mathematical operator that is applied to the value_as_number. Operators are <, <=, =, >=, >. Type: Integer';
COMMENT ON COLUMN clinical_measurement.person_identifier IS 'Foreign Key. A reference to the person table. It identifies the person about whom the measurement was recorded. Type: Integer';
COMMENT ON COLUMN clinical_measurement.provider_identifier IS 'Foreign Key. A reference to the provider in the provider table responsible for initiating or obtaining the measurement. Type: Integer';
COMMENT ON COLUMN clinical_measurement.range_upper_limit IS 'The upper limit of the normal range of the measurement. Assumed to be of the same unit of measure as the measurement value. Type: Numeric';
COMMENT ON COLUMN clinical_measurement.range_lower_limit IS 'The lower limit of the normal range of the measurement result. Assumed to be of the same unit of measure as the measurement value. Type: Numeric';
COMMENT ON COLUMN clinical_measurement.unit_concept_identifier IS 'Foreign Key. A reference to the standard concept identifier of measurement units in the standardized vocabularies. Type: Integer';
COMMENT ON COLUMN clinical_measurement.unit_source_concept_identifier IS 'A reference to the concept representing the unit_source_code and may not necessarily be standard. Discouraged from use in analysis, consider using unit_concept_identifier instead. Type: Integer';
COMMENT ON COLUMN clinical_measurement.unit_source_code IS 'The source code for the unit as it appears in the source data. This code is mapped to a standard unit concept in the standardized vocabularies, and the original code is stored here for reference. Type: Text (up to 50 characters)';
COMMENT ON COLUMN clinical_measurement.value_as_concept_identifier IS 'Foreign Key. A measurement result represented as a concept from the standardized vocabularies (e.g., positive/negative, present/absent, low/high). Type: Integer';
COMMENT ON COLUMN clinical_measurement.value_as_numeric IS 'A measurement result where the result is expressed as a numeric value. Type: Numeric';
COMMENT ON COLUMN clinical_measurement.value_source_code IS 'The source value associated with the content of the value_as_numeric or value_as_concept_identifier as stored in the source data. Type: Text (up to 50 characters)';
COMMENT ON COLUMN clinical_measurement.visit_detail_identifier IS 'Foreign Key. A reference to the record in the visit_detail table during which the measurement was recorded. Type: Integer';
COMMENT ON COLUMN clinical_measurement.visit_occurrence_identifier IS 'Foreign Key. A reference to the record in the visit_occurrence table during which the measurement was recorded. Type: Integer';

CREATE TABLE clinical_note (
    encoding_concept_identifier INTEGER,
    language_concept_identifier INTEGER,
    note_class_concept_identifier INTEGER,
    note_date DATE,
    note_datetime TIMESTAMP,
    note_event_field_concept_identifier INTEGER,
    note_event_identifier INTEGER,
    note_identifier INTEGER,
    note_source_value VARCHAR(50),
    note_text TEXT,
    note_title VARCHAR(250),
    note_type_concept_identifier INTEGER,
    person_identifier INTEGER,
    provider_identifier INTEGER,
    visit_detail_identifier INTEGER,
    visit_occurrence_identifier INTEGER
);

COMMENT ON TABLE clinical_note IS 'This table captures unstructured information that was recorded by a provider about a patient in free text notes on a given date.';
COMMENT ON COLUMN clinical_note.encoding_concept_identifier IS 'Foreign Key. A reference to the predefined concept reflecting the note character encoding type. Type: Integer';
COMMENT ON COLUMN clinical_note.language_concept_identifier IS 'Foreign Key. A reference to the predefined concept reflecting the language of the note. Type: Integer';
COMMENT ON COLUMN clinical_note.note_class_concept_identifier IS 'Foreign Key. A reference to the predefined concept reflecting the HL7 LOINC Document Type Vocabulary classification of the note. Type: Integer';
COMMENT ON COLUMN clinical_note.note_date IS 'The date the note was recorded. Type: Date';
COMMENT ON COLUMN clinical_note.note_datetime IS 'The date and time the note was recorded. Type: Timestamp';
COMMENT ON COLUMN clinical_note.note_event_field_concept_identifier IS 'Foreign Key. A reference to the concept that identifies which table the primary key of the linked record came from if the note record is related to another record in the database. Type: Integer';
COMMENT ON COLUMN clinical_note.note_event_identifier IS 'Foreign Key. The primary key of the linked record if the note record is related to another record in the database. Type: Integer';
COMMENT ON COLUMN clinical_note.note_identifier IS 'Primary Key. A unique identifier for each note. Type: Integer';
COMMENT ON COLUMN clinical_note.note_source_value IS 'The source value associated with the origin of the note. Type: Text';
COMMENT ON COLUMN clinical_note.note_text IS 'The content of the note. Type: Text';
COMMENT ON COLUMN clinical_note.note_title IS 'The title of the note as it appears in the source. Type: Text';
COMMENT ON COLUMN clinical_note.note_type_concept_identifier IS 'Foreign Key. A reference to the predefined concept reflecting the type, origin, or provenance of the note. Type: Integer';
COMMENT ON COLUMN clinical_note.person_identifier IS 'Foreign Key. A reference to the person about whom the note was recorded. The demographic details of that person are stored in the person table. Type: Integer';
COMMENT ON COLUMN clinical_note.provider_identifier IS 'Foreign Key. A reference to the provider who took the note. Type: Integer';
COMMENT ON COLUMN clinical_note.visit_detail_identifier IS 'Foreign Key. A reference to the visit in the visit_detail table when the note was taken. Type: Integer';
COMMENT ON COLUMN clinical_note.visit_occurrence_identifier IS 'Foreign Key. A reference to the visit in the visit_occurrence table when the note was taken. Type: Integer';

CREATE TABLE clinical_observation_time_span (
    observation_end_date DATE,
    observation_identifier INTEGER,
    observation_start_date DATE,
    period_type_identifier INTEGER,
    person_identifier INTEGER
);

COMMENT ON TABLE clinical_observation_time_span IS 'This table contains records that define the time spans during which a person is at risk of having clinical events recorded within the source systems, even if no events are actually recorded.';
COMMENT ON COLUMN clinical_observation_time_span.observation_end_date IS 'The end date of the observation time span for which data are available from the source system. Type: Date';
COMMENT ON COLUMN clinical_observation_time_span.observation_identifier IS 'A unique identifier for each observation time span. Type: Integer';
COMMENT ON COLUMN clinical_observation_time_span.observation_start_date IS 'The start date of the observation time span for which data are available from the source system. Type: Date';
COMMENT ON COLUMN clinical_observation_time_span.period_type_identifier IS 'Foreign Key. A reference to a predefined concept in the standardized vocabularies reflecting the source of the observation period information. Type: Integer';
COMMENT ON COLUMN clinical_observation_time_span.person_identifier IS 'Foreign Key. A reference to the person for whom the observation period is defined. Demographic details of that person are stored in the person table. Type: Integer';

CREATE TABLE concept_alternative_names (
    concept_unique_identifier INTEGER,
    concept_alternative_name VARCHAR(1000),
    language_concept_unique_identifier INTEGER
);

COMMENT ON TABLE concept_alternative_names IS 'This table stores alternate names and descriptions for concepts.';
COMMENT ON COLUMN concept_alternative_names.concept_unique_identifier IS 'Foreign Key. A unique identifier linking to the concept in the concept table. Type: Integer';
COMMENT ON COLUMN concept_alternative_names.concept_alternative_name IS 'The alternative name for the concept. Type: Text';
COMMENT ON COLUMN concept_alternative_names.language_concept_unique_identifier IS 'Foreign Key. A unique identifier representing the language. Type: Integer';

CREATE TABLE concept_classification (
    concept_classification_concept_identifier INTEGER,
    concept_classification_identifier VARCHAR(20),
    concept_classification_name VARCHAR(255)
);

COMMENT ON TABLE concept_classification IS 'This table is a reference table that includes a list of classifications used to differentiate concepts within a given vocabulary. It contains one record for each concept classification.';
COMMENT ON COLUMN concept_classification.concept_classification_concept_identifier IS 'Foreign Key. A reference to the unique concept identifier in the concept table. Type: Integer';
COMMENT ON COLUMN concept_classification.concept_classification_identifier IS 'Primary Key. A unique identifier for each concept classification. Type: Text (20 characters)';
COMMENT ON COLUMN concept_classification.concept_classification_name IS 'The name describing the concept classification, e.g., 'Clinical Finding', 'Ingredient', etc. Type: Text (255 characters)';

CREATE TABLE concept_relationship (
    defines_hierarchical_ancestry VARCHAR(1),
    is_hierarchical_relationship VARCHAR(1),
    relationship_concept_identifier INTEGER,
    relationship_identifier VARCHAR(20),
    relationship_name VARCHAR(255),
    reverse_relationship_identifier VARCHAR(20)
);

COMMENT ON TABLE concept_relationship IS 'This table provides a reference list of all types of relationships that can be used to associate any two concepts in the concept relationship table.';
COMMENT ON COLUMN concept_relationship.defines_hierarchical_ancestry IS 'Indicates if a hierarchical relationship contributes to the concept ancestor table. Valid values are 1 or 0. Type: Text';
COMMENT ON COLUMN concept_relationship.is_hierarchical_relationship IS 'Indicates if a relationship defines concepts into classes or hierarchies. Values are 1 for hierarchical relationship or 0 if not. Type: Text';
COMMENT ON COLUMN concept_relationship.relationship_concept_identifier IS 'Foreign Key. A reference to the unique relationship identifier in the concept table. Type: Integer';
COMMENT ON COLUMN concept_relationship.relationship_identifier IS 'The type of relationship captured by the relationship record. Type: Text';
COMMENT ON COLUMN concept_relationship.relationship_name IS 'The text that describes the relationship type. Type: Text';
COMMENT ON COLUMN concept_relationship.reverse_relationship_identifier IS 'The identifier for the relationship used to define the reverse relationship between two concepts. Type: Text';

CREATE TABLE concept_relationship_information (
    source_concept_identifier INTEGER,
    destination_concept_identifier INTEGER,
    concept_invalid_reason VARCHAR(1),
    relationship_identifier VARCHAR(20),
    concept_valid_end_date DATE,
    concept_valid_start_date DATE
);

COMMENT ON TABLE concept_relationship_information IS 'This table contains records that define direct relationships between any two concepts and the nature or type of the relationship. Each type of a relationship is defined in the Relationship table.';
COMMENT ON COLUMN concept_relationship_information.source_concept_identifier IS 'Foreign Key. A reference to a source concept in the Concept table associated with the relationship. Relationships are directional, and this field represents the source concept designation. Type: Integer';
COMMENT ON COLUMN concept_relationship_information.destination_concept_identifier IS 'Foreign Key. A reference to a destination concept in the Concept table associated with the relationship. Relationships are directional, and this field represents the destination concept designation. Type: Integer';
COMMENT ON COLUMN concept_relationship_information.concept_invalid_reason IS 'Reason the relationship was invalidated. Type: Text';
COMMENT ON COLUMN concept_relationship_information.relationship_identifier IS 'A unique identifier for the type or nature of the relationship as defined in the Relationship table. Type: Text';
COMMENT ON COLUMN concept_relationship_information.concept_valid_end_date IS 'The date when the concept relationship became invalid because it was deleted or superseded (updated) by a new relationship. Default value is 31-Dec-2099. Type: Date';
COMMENT ON COLUMN concept_relationship_information.concept_valid_start_date IS 'The date when the instance of the concept relationship is first recorded. Type: Date';

CREATE TABLE condition_duration (
    condition_concept_identifier INTEGER,
    condition_end_date DATE,
    condition_duration_identifier INTEGER,
    condition_start_date DATE,
    condition_instance_count INTEGER,
    person_identifier INTEGER
);

COMMENT ON TABLE condition_duration IS 'This table defines a span of time when a person is assumed to have a given condition.';
COMMENT ON COLUMN condition_duration.condition_concept_identifier IS 'Foreign Key. A reference to a standard Condition Concept identifier in the Standardized Vocabularies. Type: Integer';
COMMENT ON COLUMN condition_duration.condition_end_date IS 'The end date for the condition duration constructed from individual instances of Condition Occurrences. It is the end date of the final continuously recorded instance of the Condition. Type: Date';
COMMENT ON COLUMN condition_duration.condition_duration_identifier IS 'Primary Key. A unique identifier for each condition duration. Type: Integer';
COMMENT ON COLUMN condition_duration.condition_start_date IS 'The start date for the condition duration constructed from individual instances of Condition Occurrences. It is the start date of the very first chronologically recorded instance of the Condition. Type: Date';
COMMENT ON COLUMN condition_duration.condition_instance_count IS 'The number of individual Condition Occurrences used to construct the condition duration. Type: Integer';
COMMENT ON COLUMN condition_duration.person_identifier IS 'Foreign Key. A reference identifier to the person experiencing the condition during the condition duration. The demographic details of that person are stored in the person table. Type: Integer';

CREATE TABLE condition_record (
    condition_concept_identifier INTEGER,
    condition_end_date DATE,
    condition_end_timestamp TIMESTAMP,
    condition_record_identifier INTEGER,
    condition_source_concept_identifier INTEGER,
    condition_source_code VARCHAR(50),
    condition_start_date DATE,
    condition_start_timestamp TIMESTAMP,
    condition_status_identifier INTEGER,
    condition_status_code VARCHAR(50),
    condition_type_identifier INTEGER,
    person_identifier INTEGER,
    provider_identifier INTEGER,
    condition_stop_reason VARCHAR(20),
    visit_detail_identifier INTEGER,
    visit_occurrence_identifier INTEGER
);

COMMENT ON TABLE condition_record IS 'This table contains records of medical conditions, including details such as diagnosis, symptoms, dates, and related persons and providers.';
COMMENT ON COLUMN condition_record.condition_concept_identifier IS 'Foreign Key. Refers to a Standard Condition Concept identifier in the Standardized Vocabularies. Type: Integer';
COMMENT ON COLUMN condition_record.condition_end_date IS 'The date when the medical condition is considered to have ended. Type: Date';
COMMENT ON COLUMN condition_record.condition_end_timestamp IS 'The date and time when the medical condition is considered to have ended. Type: Timestamp';
COMMENT ON COLUMN condition_record.condition_record_identifier IS 'Primary Key. A unique identifier for each medical condition record. Type: Integer';
COMMENT ON COLUMN condition_record.condition_source_concept_identifier IS 'Foreign Key. Refers to the code used in the source for the medical condition. Type: Integer';
COMMENT ON COLUMN condition_record.condition_source_code IS 'The original source code for the medical condition as it appears in the source data. Type: Text';
COMMENT ON COLUMN condition_record.condition_start_date IS 'The date when the medical condition is recorded. Type: Date';
COMMENT ON COLUMN condition_record.condition_start_timestamp IS 'The date and time when the medical condition is recorded. Type: Timestamp';
COMMENT ON COLUMN condition_record.condition_status_identifier IS 'Foreign Key. Refers to the predefined concept in the standard vocabulary reflecting the condition status. Type: Integer';
COMMENT ON COLUMN condition_record.condition_status_code IS 'The source code for the condition status as it appears in the source data. Type: Text';
COMMENT ON COLUMN condition_record.condition_type_identifier IS 'Foreign Key. Refers to the predefined Concept identifier in the Standardized Vocabularies reflecting the source data, level of standardization, and type of occurrence. Type: Integer';
COMMENT ON COLUMN condition_record.person_identifier IS 'Foreign Key. Refers to the Person who is experiencing the medical condition. Type: Integer';
COMMENT ON COLUMN condition_record.provider_identifier IS 'Foreign Key. Refers to the Provider responsible for diagnosing the medical condition. Type: Integer';
COMMENT ON COLUMN condition_record.condition_stop_reason IS 'The reason that the medical condition was no longer present, as indicated in the source data. Type: Text';
COMMENT ON COLUMN condition_record.visit_detail_identifier IS 'Foreign Key. Refers to the visit during which the medical condition was diagnosed. Type: Integer';
COMMENT ON COLUMN condition_record.visit_occurrence_identifier IS 'Foreign Key. Refers to the visit during which the medical condition was diagnosed. Type: Integer';

CREATE TABLE data_source_information (
    etl_script_version_reference VARCHAR(255),
    data_model_holder VARCHAR(255),
    etl_script_completion_date DATE,
    data_model_source_abbreviation VARCHAR(25),
    data_model_source_name VARCHAR(255),
    data_model_version VARCHAR(10),
    data_model_version_concept_identifier INTEGER,
    data_source_description TEXT,
    source_database_documentation_reference VARCHAR(255),
    source_data_extraction_date DATE,
    standardized_vocabularies_version VARCHAR(20)
);

COMMENT ON TABLE data_source_information IS 'This table contains details about the source database and the process used to transform the data into the Observational Medical Outcomes Partnership Common Data Model.';
COMMENT ON COLUMN data_source_information.etl_script_version_reference IS 'Version of the Extract, Transform, Load script used. For example, link to the Git release. Type: Text';
COMMENT ON COLUMN data_source_information.data_model_holder IS 'The holder of the Common Data Model instance. Type: Text';
COMMENT ON COLUMN data_source_information.etl_script_completion_date IS 'The date the Extract, Transform, Load script was completed. Typically, this is after the source data release date. Type: Date';
COMMENT ON COLUMN data_source_information.data_model_source_abbreviation IS 'The abbreviation of the Common Data Model instance. Type: Text';
COMMENT ON COLUMN data_source_information.data_model_source_name IS 'The name of the Common Data Model instance. Type: Text';
COMMENT ON COLUMN data_source_information.data_model_version IS 'Version of the Observational Medical Outcomes Partnership Common Data Model used. For example, v5.4. Type: Text';
COMMENT ON COLUMN data_source_information.data_model_version_concept_identifier IS 'The concept identifier representing the version of the Common Data Model. You can find all concepts that represent the Common Data Model versions using the query: SELECT * FROM CONCEPT WHERE VOCABULARY_ID = "CDM" AND CONCEPT_CLASS = "CDM". Type: Integer';
COMMENT ON COLUMN data_source_information.data_source_description IS 'The description of the Common Data Model instance. Type: Text';
COMMENT ON COLUMN data_source_information.source_database_documentation_reference IS 'The reference documentation for the source database. Type: Text';
COMMENT ON COLUMN data_source_information.source_data_extraction_date IS 'The date the data was extracted from the source system. In some systems, this is the same as the date the Extract, Transform, Load was run. Typically, the latest event date in the source is on the source data extraction date. Type: Date';
COMMENT ON COLUMN data_source_information.standardized_vocabularies_version IS 'Version of the Observational Medical Outcomes Partnership standardized vocabularies loaded. You can find the version of your vocabulary using the query: SELECT vocabulary_version from vocabulary where vocabulary_id = "None". Type: Text';

CREATE TABLE death_event (
    cause_condition_identifier INTEGER,
    cause_source_identifier INTEGER,
    cause_source_code VARCHAR(50),
    death_date DATE,
    death_date_time TIMESTAMP,
    death_representation_identifier INTEGER,
    person_identifier INTEGER
);

COMMENT ON TABLE death_event IS 'This table contains details on the clinical event of a person's death, including cause and date.';
COMMENT ON COLUMN death_event.cause_condition_identifier IS 'Foreign Key. A reference to a standard concept identifier in the Standardized Vocabularies for conditions. Type: Integer';
COMMENT ON COLUMN death_event.cause_source_identifier IS 'Foreign Key. A reference to the concept that refers to the source code used. Type: Integer';
COMMENT ON COLUMN death_event.cause_source_code IS 'The source code for the cause of death as it appears in the source data. This code is mapped to a standard concept in the Standardized Vocabularies and the original code is stored here for reference. Type: Text';
COMMENT ON COLUMN death_event.death_date IS 'The date the person was deceased. If the precise date including day or month is not known or not allowed, December is used as the default month, and the last day of the month the default day. Type: Date';
COMMENT ON COLUMN death_event.death_date_time IS 'The date and time the person was deceased. If the precise date including day or month is not known or not allowed, December is used as the default month, and the last day of the month the default day. Type: Timestamp';
COMMENT ON COLUMN death_event.death_representation_identifier IS 'Foreign Key. A reference to the predefined concept identifier in the Standardized Vocabularies reflecting how the death was represented in the source data. Type: Integer';
COMMENT ON COLUMN death_event.person_identifier IS 'Foreign Key. An identifier to the deceased person. The demographic details of that person are stored in the person table. Type: Integer';

CREATE TABLE device_usage_information (
    device_concept_identifier INTEGER,
    device_usage_end_date DATE,
    device_usage_end_timestamp TIMESTAMP,
    device_usage_identifier INTEGER,
    device_usage_start_date DATE,
    device_usage_start_timestamp TIMESTAMP,
    device_source_concept_identifier INTEGER,
    device_source_code VARCHAR(50),
    device_type_concept_identifier INTEGER,
    person_identifier INTEGER,
    production_identifier VARCHAR(255),
    provider_identifier INTEGER,
    device_quantity INTEGER,
    unique_device_identifier VARCHAR(255),
    unit_concept_identifier INTEGER,
    unit_source_concept_identifier INTEGER,
    unit_source_code VARCHAR(50),
    visit_detail_identifier INTEGER,
    visit_occurrence_identifier INTEGER
);

COMMENT ON TABLE device_usage_information IS 'This table captures information about a person's exposure to a foreign physical object or instrument used for diagnostic or therapeutic purposes. Devices include implantable objects, medical equipment and supplies, instruments used in medical procedures, and materials used in clinical care.';
COMMENT ON COLUMN device_usage_information.device_concept_identifier IS 'Foreign Key. A standard concept identifier in the standardized vocabularies for the device concept. Type: Integer';
COMMENT ON COLUMN device_usage_information.device_usage_end_date IS 'The date the device or supply was removed from use. Type: Date';
COMMENT ON COLUMN device_usage_information.device_usage_end_timestamp IS 'The date and time the device or supply was removed from use. Type: Timestamp';
COMMENT ON COLUMN device_usage_information.device_usage_identifier IS 'Primary Key. A unique identifier for each device exposure. Type: Integer';
COMMENT ON COLUMN device_usage_information.device_usage_start_date IS 'The date the device or supply was applied or used. Type: Date';
COMMENT ON COLUMN device_usage_information.device_usage_start_timestamp IS 'The date and time the device or supply was applied or used. Type: Timestamp';
COMMENT ON COLUMN device_usage_information.device_source_concept_identifier IS 'Foreign Key. A device concept identifier that refers to the code used in the source. Type: Integer';
COMMENT ON COLUMN device_usage_information.device_source_code IS 'The source code for the device as it appears in the source data, mapped to a standard device concept and stored for reference. Type: Text';
COMMENT ON COLUMN device_usage_information.device_type_concept_identifier IS 'Foreign Key. A predefined concept identifier in the standardized vocabularies reflecting the type of device exposure recorded. Type: Integer';
COMMENT ON COLUMN device_usage_information.person_identifier IS 'Foreign Key. An identifier for the person subjected to the device. The demographic details of that person are stored in the Person table. Type: Integer';
COMMENT ON COLUMN device_usage_information.production_identifier IS 'The production identifier portion (UDI-PI) of the unique device identification. Type: Text';
COMMENT ON COLUMN device_usage_information.provider_identifier IS 'Foreign Key. An identifier for the provider in the Provider table who initiated or administered the device. Type: Integer';
COMMENT ON COLUMN device_usage_information.device_quantity IS 'The number of individual devices used for the exposure. Type: Integer';
COMMENT ON COLUMN device_usage_information.unique_device_identifier IS 'A unique device identifier or equivalent identifying the instance of the device used in the person. Type: Text';
COMMENT ON COLUMN device_usage_information.unit_concept_identifier IS 'Concept identifier in the unit domain representing the unit as given in the source data. Type: Integer';
COMMENT ON COLUMN device_usage_information.unit_source_concept_identifier IS 'Concept identifier representing the unit source value, not necessarily standard. Should be used when standard concepts do not adequately represent the source detail for a given analytic use case. Type: Integer';
COMMENT ON COLUMN device_usage_information.unit_source_code IS 'The verbatim value from the source data representing the unit of the device. Type: Text';
COMMENT ON COLUMN device_usage_information.visit_detail_identifier IS 'Foreign Key. An identifier for the visit in the visit-detail table during which the device exposure was initiated. Type: Integer';
COMMENT ON COLUMN device_usage_information.visit_occurrence_identifier IS 'Foreign Key. An identifier for the visit in the Visit table during which the device was used. Type: Integer';

CREATE TABLE domain_information (
    domain_concept_identifier INTEGER,
    domain_identifier VARCHAR(20),
    domain_name VARCHAR(255)
);

COMMENT ON TABLE domain_information IS 'This table includes a list of OMOP-defined Domains that Concepts in the Standardized Vocabularies can belong to. A Domain defines the set of allowable Concepts for the standardized fields in the CDM tables.';
COMMENT ON COLUMN domain_information.domain_concept_identifier IS 'Foreign Key. An identifier that refers to the unique Domain Concept in the CONCEPT table.';
COMMENT ON COLUMN domain_information.domain_identifier IS 'Primary Key. A unique identifier for each domain.';
COMMENT ON COLUMN domain_information.domain_name IS 'The name describing the Domain, e.g. 'Condition', 'Procedure', 'Measurement', etc.';

CREATE TABLE drug_dose_period (
    dose_period_end_date DATE,
    dose_period_identifier INTEGER,
    dose_period_start_date DATE,
    dose_quantity NUMERIC,
    drug_concept_identifier INTEGER,
    person_identifier INTEGER,
    unit_concept_identifier INTEGER
);

COMMENT ON TABLE drug_dose_period IS 'This table contains information about spans of time when a person is exposed to a constant dose of a specific active ingredient, derived from drug exposure and drug strength records.';
COMMENT ON COLUMN drug_dose_period.dose_period_end_date IS 'The end date for the drug dose period, marking the end of the last recorded use of a drug. Type: Date';
COMMENT ON COLUMN drug_dose_period.dose_period_identifier IS 'Primary Key. A unique identifier for each drug dose period. Type: Integer';
COMMENT ON COLUMN drug_dose_period.dose_period_start_date IS 'The start date for the drug dose period, marking the beginning of the first recorded use of a drug. Type: Date';
COMMENT ON COLUMN drug_dose_period.dose_quantity IS 'The numeric value of the dose. Type: Numeric';
COMMENT ON COLUMN drug_dose_period.drug_concept_identifier IS 'Foreign Key. A reference to the standard concept identifier for the active ingredient concept in the standardized vocabularies. Type: Integer';
COMMENT ON COLUMN drug_dose_period.person_identifier IS 'Foreign Key. A reference to the identifier of the person who is subjected to the drug during the dose period. The demographic details are stored in the person table. Type: Integer';
COMMENT ON COLUMN drug_dose_period.unit_concept_identifier IS 'Foreign Key. A reference to the standard concept identifier for the unit concept in the standardized vocabularies. Type: Integer';

CREATE TABLE drug_exposure_information (
    days_of_supply INTEGER,
    dose_unit_value VARCHAR(50),
    drug_concept_identifier INTEGER,
    drug_exposure_end_date DATE,
    drug_exposure_end_timestamp TIMESTAMP,
    drug_exposure_identifier INTEGER,
    drug_exposure_start_date DATE,
    drug_exposure_start_timestamp TIMESTAMP,
    drug_source_concept_identifier INTEGER,
    drug_source_code VARCHAR(50),
    drug_type_concept_identifier INTEGER,
    drug_lot_number VARCHAR(50),
    person_identifier INTEGER,
    provider_identifier INTEGER,
    drug_quantity NUMERIC,
    refill_count INTEGER,
    route_concept_identifier INTEGER,
    route_source_code VARCHAR(50),
    prescription_instructions TEXT,
    condition_stop_reason VARCHAR(20),
    recorded_end_date DATE,
    visit_detail_identifier INTEGER,
    visit_occurrence_identifier INTEGER
);

COMMENT ON TABLE drug_exposure_information IS 'This table captures records about the utilization of a Drug when ingested or otherwise introduced into the body. This includes details such as the duration of drug use, dosage, and the person who used the drug. It covers prescription and over-the-counter medicines, vaccines, and biologic therapies.';
COMMENT ON COLUMN drug_exposure_information.days_of_supply IS 'The number of days the medication was supplied as recorded in the original prescription or dispensing record. Type: Integer';
COMMENT ON COLUMN drug_exposure_information.dose_unit_value IS 'Details about the dose unit as specified in the source. Type: Text';
COMMENT ON COLUMN drug_exposure_information.drug_concept_identifier IS 'Foreign Key. A reference to the Standard Concept identifier in the standardized vocabularies for the Drug concept. Type: Integer';
COMMENT ON COLUMN drug_exposure_information.drug_exposure_end_date IS 'The end date for the current instance of Drug use. May not be available from all sources. Type: Date';
COMMENT ON COLUMN drug_exposure_information.drug_exposure_end_timestamp IS 'The end date and time for the current instance of Drug use. May not be available from all sources. Type: Timestamp';
COMMENT ON COLUMN drug_exposure_information.drug_exposure_identifier IS 'Primary Key. A unique identifier for each Drug use event. Type: Integer';
COMMENT ON COLUMN drug_exposure_information.drug_exposure_start_date IS 'The start date for the current instance of Drug use. This could be the prescription start date, fill date, or the date a Drug administration procedure was recorded. Type: Date';
COMMENT ON COLUMN drug_exposure_information.drug_exposure_start_timestamp IS 'The start date and time for the current instance of Drug use. This could be the prescription start date, fill date, or the date a Drug administration procedure was recorded. Type: Timestamp';
COMMENT ON COLUMN drug_exposure_information.drug_source_concept_identifier IS 'Foreign Key. A reference to a Drug Concept code used in the source. Type: Integer';
COMMENT ON COLUMN drug_exposure_information.drug_source_code IS 'The source code for the Drug as it appears in the source data. This code is mapped to a Standard Drug concept and stored here for reference. Type: Text';
COMMENT ON COLUMN drug_exposure_information.drug_type_concept_identifier IS 'Foreign Key. A reference to a predefined Concept identifier in the standardized vocabularies reflecting the type of Drug Exposure recorded. Type: Integer';
COMMENT ON COLUMN drug_exposure_information.drug_lot_number IS 'An identifier assigned to a particular quantity or lot of Drug product from the manufacturer. Type: Text';
COMMENT ON COLUMN drug_exposure_information.person_identifier IS 'Foreign Key. A reference to the person who used the Drug. The demographic details of that person are stored in the person table. Type: Integer';
COMMENT ON COLUMN drug_exposure_information.provider_identifier IS 'Foreign Key. A reference to the provider in the provider table who initiated (prescribed or administered) the Drug Exposure. Type: Integer';
COMMENT ON COLUMN drug_exposure_information.drug_quantity IS 'The quantity of drug as recorded in the prescription or dispensing record. Type: Numeric';
COMMENT ON COLUMN drug_exposure_information.refill_count IS 'The number of refills after the initial prescription. The initial prescription is not counted; values start with 0. Type: Integer';
COMMENT ON COLUMN drug_exposure_information.route_concept_identifier IS 'Foreign Key. A reference to a predefined concept in the standardized vocabularies reflecting the route of administration. Type: Integer';
COMMENT ON COLUMN drug_exposure_information.route_source_code IS 'Details about the route of administration as specified in the source. Type: Text';
COMMENT ON COLUMN drug_exposure_information.prescription_instructions IS 'The directions on the Drug prescription as recorded in the prescription (and printed on the container) or dispensing record. Type: Text';
COMMENT ON COLUMN drug_exposure_information.condition_stop_reason IS 'The reason the Drug was stopped. Could include reasons like regimen completed, changed, or removed. Type: Text';
COMMENT ON COLUMN drug_exposure_information.recorded_end_date IS 'The known end date of a drug exposure as provided by the source. Type: Date';
COMMENT ON COLUMN drug_exposure_information.visit_detail_identifier IS 'Foreign Key. A reference to the visit in the VISIT_DETAIL table during which the Drug Exposure was initiated. Type: Integer';
COMMENT ON COLUMN drug_exposure_information.visit_occurrence_identifier IS 'Foreign Key. A reference to the visit in the visit table during which the Drug Exposure was initiated. Type: Integer';

CREATE TABLE drug_exposure_period (
    drug_concept_identifier INTEGER,
    drug_period_end_date DATE,
    drug_period_identifier INTEGER,
    drug_period_start_date DATE,
    drug_exposure_instance_count INTEGER,
    uncovered_days INTEGER,
    person_identifier INTEGER
);

COMMENT ON TABLE drug_exposure_period IS 'This table contains periods of time when a person is assumed to be exposed to a particular active ingredient, derived from individual drug exposures.';
COMMENT ON COLUMN drug_exposure_period.drug_concept_identifier IS 'Foreign Key. Refers to a Standard Concept identifier in the Standardized Vocabularies for the Ingredient Concept. Type: Integer';
COMMENT ON COLUMN drug_exposure_period.drug_period_end_date IS 'The end date for the drug exposure period constructed from individual instances of drug exposures. Type: Date';
COMMENT ON COLUMN drug_exposure_period.drug_period_identifier IS 'Primary Key. A unique identifier for each drug exposure period. Type: Integer';
COMMENT ON COLUMN drug_exposure_period.drug_period_start_date IS 'The start date for the drug exposure period constructed from individual instances of drug exposures. Type: Date';
COMMENT ON COLUMN drug_exposure_period.drug_exposure_instance_count IS 'The number of individual drug exposure occurrences used to construct the drug exposure period. Type: Integer';
COMMENT ON COLUMN drug_exposure_period.uncovered_days IS 'The number of days not covered by drug exposure records used to make up the period record. Type: Integer';
COMMENT ON COLUMN drug_exposure_period.person_identifier IS 'Foreign Key. An identifier for the person who is subjected to the drug during the exposure period. The demographic details are stored in the person table. Type: Integer';

CREATE TABLE drug_strength_information (
    amount_unit_identifier INTEGER,
    amount_value NUMERIC,
    box_size INTEGER,
    denominator_unit_identifier INTEGER,
    denominator_value NUMERIC,
    drug_concept_identifier INTEGER,
    ingredient_identifier INTEGER,
    concept_invalid_reason VARCHAR(1),
    numerator_unit_identifier INTEGER,
    numerator_value NUMERIC,
    concept_valid_end_date DATE,
    concept_valid_start_date DATE
);

COMMENT ON TABLE drug_strength_information IS 'This table contains structured details about the amount or concentration and associated units of a specific ingredient contained within a particular drug product. It supports standardized analysis of drug utilization.';
COMMENT ON COLUMN drug_strength_information.amount_unit_identifier IS 'Foreign Key. A reference to the concept table representing the unit identifier for the absolute amount of an active ingredient. Type: Integer';
COMMENT ON COLUMN drug_strength_information.amount_value IS 'The numeric value associated with the amount of active ingredient contained within the product. Type: Numeric';
COMMENT ON COLUMN drug_strength_information.box_size IS 'The number of units of clinical or branded drug contained in a box as dispensed to the patient. Type: Integer';
COMMENT ON COLUMN drug_strength_information.denominator_unit_identifier IS 'Foreign Key. A reference to the concept table representing the unit identifier for the denominator of the concentration of active ingredient. Type: Integer';
COMMENT ON COLUMN drug_strength_information.denominator_value IS 'The amount of total liquid or other divisible product such as ointment or gel. Type: Numeric';
COMMENT ON COLUMN drug_strength_information.drug_concept_identifier IS 'Foreign Key. A reference to the concept table representing the identifier for branded or clinical drug concept. Type: Integer';
COMMENT ON COLUMN drug_strength_information.ingredient_identifier IS 'Foreign Key. A reference to the concept table representing the identifier for the drug ingredient concept contained within the drug product. Type: Integer';
COMMENT ON COLUMN drug_strength_information.concept_invalid_reason IS 'The reason why the concept was invalidated. Type: Small Text';
COMMENT ON COLUMN drug_strength_information.numerator_unit_identifier IS 'Foreign Key. A reference to the concept table representing the unit identifier for the numerator of the concentration of active ingredient. Type: Integer';
COMMENT ON COLUMN drug_strength_information.numerator_value IS 'The numeric value associated with the concentration of the active ingredient contained in the product. Type: Numeric';
COMMENT ON COLUMN drug_strength_information.concept_valid_end_date IS 'The date when the concept became invalid, either due to deletion or being superseded by a new concept. Default value is 31-Dec-2099. Type: Date';
COMMENT ON COLUMN drug_strength_information.concept_valid_start_date IS 'The date when the concept was first recorded. Default value is 1-Jan-1970. Type: Date';

CREATE TABLE fact_relationships (
    fact_one_domain_identifier INTEGER,
    fact_two_domain_identifier INTEGER,
    fact_one_identifier INTEGER,
    fact_two_identifier INTEGER,
    relationship_identifier INTEGER
);

COMMENT ON TABLE fact_relationships IS 'This table contains records about relationships between facts stored in any table of the Common Data Model. These relationships can be defined within the same domain or across different domains.';
COMMENT ON COLUMN fact_relationships.fact_one_domain_identifier IS 'The concept representing the domain of the first fact, from which the corresponding table can be inferred. Type: Integer';
COMMENT ON COLUMN fact_relationships.fact_two_domain_identifier IS 'The concept representing the domain of the second fact, from which the corresponding table can be inferred. Type: Integer';
COMMENT ON COLUMN fact_relationships.fact_one_identifier IS 'The unique identifier in the table corresponding to the domain of the first fact. Type: Integer';
COMMENT ON COLUMN fact_relationships.fact_two_identifier IS 'The unique identifier in the table corresponding to the domain of the second fact. Type: Integer';
COMMENT ON COLUMN fact_relationships.relationship_identifier IS 'Foreign Key. A reference to the Standard Concept Identifier for the relationship in the Standardized Vocabularies. Type: Integer';

CREATE TABLE geographic_location_information (
    street_address VARCHAR(50),
    additional_address_details VARCHAR(50),
    city VARCHAR(50),
    country_concept_identifier INTEGER,
    country_name VARCHAR(80),
    county_name VARCHAR(20),
    latitude_coordinate NUMERIC,
    location_identifier INTEGER,
    location_source_identifier VARCHAR(50),
    longitude_coordinate NUMERIC,
    state_abbreviation VARCHAR(2),
    postal_code VARCHAR(9)
);

COMMENT ON TABLE geographic_location_information IS 'This table contains detailed address and physical location information for Persons and Care Sites.';
COMMENT ON COLUMN geographic_location_information.street_address IS 'The first line of the address, typically the street address, from the source data. Type: Text';
COMMENT ON COLUMN geographic_location_information.additional_address_details IS 'The second line of the address, typically used for additional details like buildings, suites, or floors, from the source data. Type: Text';
COMMENT ON COLUMN geographic_location_information.city IS 'The name of the city as it appears in the source data. Type: Text';
COMMENT ON COLUMN geographic_location_information.country_concept_identifier IS 'Foreign Key. A unique identifier representing the country conforming to the Geography domain. Type: Integer';
COMMENT ON COLUMN geographic_location_information.country_name IS 'The name of the country as it appears in the source data. Type: Text';
COMMENT ON COLUMN geographic_location_information.county_name IS 'The name of the county. Type: Text';
COMMENT ON COLUMN geographic_location_information.latitude_coordinate IS 'The latitude coordinate, must be between -90 and 90. Type: Numeric';
COMMENT ON COLUMN geographic_location_information.location_identifier IS 'Primary Key. A unique identifier for each geographic location. Type: Integer';
COMMENT ON COLUMN geographic_location_information.location_source_identifier IS 'The verbatim information used to uniquely identify the location from the source data. Type: Text';
COMMENT ON COLUMN geographic_location_information.longitude_coordinate IS 'The longitude coordinate, must be between -180 and 180. Type: Numeric';
COMMENT ON COLUMN geographic_location_information.state_abbreviation IS 'The state abbreviation as it appears in the source data. Type: Text';
COMMENT ON COLUMN geographic_location_information.postal_code IS 'The zip or postal code. Type: Text';

CREATE TABLE group_definition_information (
    group_definition_description TEXT,
    group_definition_identifier INTEGER,
    group_definition_name VARCHAR(255),
    group_definition_syntax TEXT,
    group_initiation_date DATE,
    definition_type_identifier INTEGER,
    subject_identifier INTEGER
);

COMMENT ON TABLE group_definition_information IS 'This table contains records defining a group (cohort) derived from the data through the associated description and syntax. It includes the rules governing the inclusion of a subject into a group and stores the programming code to instantiate the group within the data model.';
COMMENT ON COLUMN group_definition_information.group_definition_description IS 'A complete description of the group definition. Type: Text';
COMMENT ON COLUMN group_definition_information.group_definition_identifier IS 'Primary Key. A unique identifier for each group. Type: Integer';
COMMENT ON COLUMN group_definition_information.group_definition_name IS 'A short description of the group. Type: Text';
COMMENT ON COLUMN group_definition_information.group_definition_syntax IS 'Syntax or code to operationalize the group definition. Type: Text';
COMMENT ON COLUMN group_definition_information.group_initiation_date IS 'A date indicating when the group was initiated. Type: Date';
COMMENT ON COLUMN group_definition_information.definition_type_identifier IS 'A type defining what kind of group definition the record represents and how the syntax may be executed. Type: Integer';
COMMENT ON COLUMN group_definition_information.subject_identifier IS 'Foreign Key. A reference to the concept which defines the domain of subjects that are members of the group (e.g., Person, Provider, Visit). Type: Integer';

CREATE TABLE group_information (
    group_definition_identifier INTEGER,
    group_end_date DATE,
    group_start_date DATE,
    subject_identifier INTEGER
);

COMMENT ON TABLE group_information IS 'This table contains records of subjects that satisfy a given set of criteria for a duration of time. The definition of the group is contained within the group_definition table. Groups can be constructed of patients (Persons), Providers, or Visits.';
COMMENT ON COLUMN group_information.group_definition_identifier IS 'Foreign Key. A reference to a record in the group_definition table containing relevant group definition information. Type: Integer';
COMMENT ON COLUMN group_information.group_end_date IS 'The date when the group definition criteria for the person, provider, or visit no longer match, or the group membership was terminated. Type: Date';
COMMENT ON COLUMN group_information.group_start_date IS 'The date when the group definition criteria for the person, provider, or visit first match. Type: Date';
COMMENT ON COLUMN group_information.subject_identifier IS 'Foreign Key. A reference to the subject in the group, which could be records in the person, provider, or visit_occurrence table. Type: Integer';

CREATE TABLE health_plan_enrollment_period (
    family_identifier VARCHAR(50),
    payer_identifier INTEGER,
    enrollment_end_date DATE,
    health_plan_period_identifier INTEGER,
    enrollment_start_date DATE,
    payer_source_identifier INTEGER,
    payer_source_text VARCHAR(50),
    person_identifier INTEGER,
    health_plan_identifier INTEGER,
    health_plan_source_identifier INTEGER,
    health_plan_source_text VARCHAR(50),
    plan_sponsor_identifier INTEGER,
    plan_sponsor_source_identifier INTEGER,
    plan_sponsor_source_text VARCHAR(50),
    stop_reason_identifier INTEGER,
    stop_reason_source_identifier INTEGER,
    stop_reason_source_text VARCHAR(50)
);

COMMENT ON TABLE health_plan_enrollment_period IS 'This table captures details of the period of time that a person is continuously enrolled under a specific health plan benefit structure from a given payer.';
COMMENT ON COLUMN health_plan_enrollment_period.family_identifier IS 'A common identifier for all individuals covered by the same policy. Type: Text';
COMMENT ON COLUMN health_plan_enrollment_period.payer_identifier IS 'Identifier for the organization reimbursing the healthcare provider. Type: Integer';
COMMENT ON COLUMN health_plan_enrollment_period.enrollment_end_date IS 'End date of the plan coverage. Type: Date';
COMMENT ON COLUMN health_plan_enrollment_period.health_plan_period_identifier IS 'Primary Key. A unique identifier for each combination of person, payer, plan, and period of time. Type: Integer';
COMMENT ON COLUMN health_plan_enrollment_period.enrollment_start_date IS 'Start date of the plan coverage. Type: Date';
COMMENT ON COLUMN health_plan_enrollment_period.payer_source_identifier IS 'Identifier for the payer in the source data if it uses a supported vocabulary. Type: Integer';
COMMENT ON COLUMN health_plan_enrollment_period.payer_source_text IS 'The payer as it appears in the source data. Type: Text';
COMMENT ON COLUMN health_plan_enrollment_period.person_identifier IS 'Foreign Key. The person covered by the plan. Type: Integer';
COMMENT ON COLUMN health_plan_enrollment_period.health_plan_identifier IS 'Identifier for the specific health benefit plan the person is enrolled in. Type: Integer';
COMMENT ON COLUMN health_plan_enrollment_period.health_plan_source_identifier IS 'Identifier for the plan in the source data if it uses a supported vocabulary. Type: Integer';
COMMENT ON COLUMN health_plan_enrollment_period.health_plan_source_text IS 'The health benefit plan of the person as it appears in the source data. Type: Text';
COMMENT ON COLUMN health_plan_enrollment_period.plan_sponsor_identifier IS 'Identifier for the sponsor financing the plan. Type: Integer';
COMMENT ON COLUMN health_plan_enrollment_period.plan_sponsor_source_identifier IS 'Identifier for the sponsor in the source data if it uses a supported vocabulary. Type: Integer';
COMMENT ON COLUMN health_plan_enrollment_period.plan_sponsor_source_text IS 'The plan sponsor as it appears in the source data. Type: Text';
COMMENT ON COLUMN health_plan_enrollment_period.stop_reason_identifier IS 'Identifier for the reason the person left the plan, if known. Type: Integer';
COMMENT ON COLUMN health_plan_enrollment_period.stop_reason_source_identifier IS 'Identifier for the stop reason in the source data if it uses a supported vocabulary. Type: Integer';
COMMENT ON COLUMN health_plan_enrollment_period.stop_reason_source_text IS 'The plan stop reason as it appears in the source data. Type: Text';

CREATE TABLE healthcare_delivery_unit (
    unit_identifier INTEGER,
    unit_name VARCHAR(255),
    unit_source_identifier VARCHAR(50),
    location_identifier INTEGER,
    service_concept_identifier INTEGER,
    service_source_value VARCHAR(50)
);

COMMENT ON TABLE healthcare_delivery_unit IS 'This table contains a list of uniquely identified institutional (physical or organizational) units where healthcare delivery is practiced (offices, wards, hospitals, clinics, etc.).';
COMMENT ON COLUMN healthcare_delivery_unit.unit_identifier IS 'Primary Key. A unique identifier for each healthcare delivery unit. Type: Integer';
COMMENT ON COLUMN healthcare_delivery_unit.unit_name IS 'The name or description of the healthcare delivery unit as in source data. Type: Text';
COMMENT ON COLUMN healthcare_delivery_unit.unit_source_identifier IS 'The identifier for the healthcare delivery unit in the source data, stored here for reference. Type: Text';
COMMENT ON COLUMN healthcare_delivery_unit.location_identifier IS 'Foreign Key. A reference to the geographic location in the location table, where the detailed address information is stored. Type: Integer';
COMMENT ON COLUMN healthcare_delivery_unit.service_concept_identifier IS 'Foreign Key. A reference to a place of service concept identifier in the standardized vocabularies. Type: Integer';
COMMENT ON COLUMN healthcare_delivery_unit.service_source_value IS 'The source code for the place of service as it appears in the source data, stored here for reference. Type: Text';

CREATE TABLE healthcare_provider (
    unit_identifier INTEGER,
    drug_enforcement_administration_number VARCHAR(20),
    gender_standard_concept_identifier INTEGER,
    gender_source_concept_identifier INTEGER,
    gender_source_code VARCHAR(50),
    national_provider_identifier VARCHAR(20),
    provider_identifier INTEGER,
    provider_name VARCHAR(255),
    provider_source_identifier VARCHAR(50),
    specialty_standard_concept_identifier INTEGER,
    specialty_source_concept_identifier INTEGER,
    specialty_source_code VARCHAR(50),
    birth_year INTEGER
);

COMMENT ON TABLE healthcare_provider IS 'This table contains a list of uniquely identified healthcare providers, including details such as their practice sites, identifiers, and specialty information.';
COMMENT ON COLUMN healthcare_provider.unit_identifier IS 'Foreign Key. A reference to the main care site where the provider is practicing. Type: Integer';
COMMENT ON COLUMN healthcare_provider.drug_enforcement_administration_number IS 'The Drug Enforcement Administration (DEA) number of the provider. Type: Text';
COMMENT ON COLUMN healthcare_provider.gender_standard_concept_identifier IS 'The gender of the provider. Type: Integer';
COMMENT ON COLUMN healthcare_provider.gender_source_concept_identifier IS 'Foreign Key. A reference to the code used in the source for the provider's gender. Type: Integer';
COMMENT ON COLUMN healthcare_provider.gender_source_code IS 'The gender code for the provider as it appears in the source data, stored here for reference. Type: Text';
COMMENT ON COLUMN healthcare_provider.national_provider_identifier IS 'The National Provider Identifier (NPI) of the provider. Type: Text';
COMMENT ON COLUMN healthcare_provider.provider_identifier IS 'Primary Key. A unique identifier for each provider. Type: Integer';
COMMENT ON COLUMN healthcare_provider.provider_name IS 'A description of the provider. Type: Text';
COMMENT ON COLUMN healthcare_provider.provider_source_identifier IS 'The identifier used for the provider in the source data, stored here for reference. Type: Text';
COMMENT ON COLUMN healthcare_provider.specialty_standard_concept_identifier IS 'Foreign Key. A reference to a standard specialty concept identifier in the standardized vocabularies. Type: Integer';
COMMENT ON COLUMN healthcare_provider.specialty_source_concept_identifier IS 'Foreign Key. A reference to the code used in the source for the provider's specialty. Type: Integer';
COMMENT ON COLUMN healthcare_provider.specialty_source_code IS 'The source code for the provider's specialty as it appears in the source data, stored here for reference. Type: Text';
COMMENT ON COLUMN healthcare_provider.birth_year IS 'The year of birth of the provider. Type: Integer';

CREATE TABLE hierarchical_relationship (
    higher_level_concept_id INTEGER,
    lower_level_concept_id INTEGER,
    maximum_hierarchy_levels INTEGER,
    minimum_hierarchy_levels INTEGER
);

COMMENT ON TABLE hierarchical_relationship IS 'This table contains hierarchical relationships between concepts, including direct and indirect ancestor-descendant connections, to simplify observational analysis and querying of all descendants of a hierarchical concept.';
COMMENT ON COLUMN hierarchical_relationship.higher_level_concept_id IS 'Foreign Key. A reference to the concept in the concept table for the higher-level (ancestor) concept. Type: Integer';
COMMENT ON COLUMN hierarchical_relationship.lower_level_concept_id IS 'Foreign Key. A reference to the concept in the concept table for the lower-level (descendant) concept. Type: Integer';
COMMENT ON COLUMN hierarchical_relationship.maximum_hierarchy_levels IS 'The maximum separation in terms of number of hierarchy levels between ancestor and descendant concepts. Used to simplify hierarchical analysis. Type: Integer';
COMMENT ON COLUMN hierarchical_relationship.minimum_hierarchy_levels IS 'The minimum separation in terms of number of hierarchy levels between ancestor and descendant concepts. Used to simplify hierarchical analysis. Type: Integer';

CREATE TABLE medical_concept_information (
    concept_classification_identifier VARCHAR(20),
    concept_source_code VARCHAR(50),
    concept_unique_identifier INTEGER,
    concept_name VARCHAR(255),
    domain_identifier VARCHAR(20),
    concept_invalid_reason VARCHAR(1),
    standard_concept_flag VARCHAR(1),
    concept_valid_end_date DATE,
    concept_valid_start_date DATE,
    vocabulary_source_identifier VARCHAR(20)
);

COMMENT ON TABLE medical_concept_information IS 'This table provides a standardized representation of medical concepts for consistent querying and analysis across healthcare databases. It is used to enrich clinical data with standardized concept information or map clinical data from source terminologies to standard concepts.';
COMMENT ON COLUMN medical_concept_information.concept_classification_identifier IS 'The attribute or classification of the concept. Type: Text';
COMMENT ON COLUMN medical_concept_information.concept_source_code IS 'The identifier of the concept in the source vocabulary, such as SNOMED-CT concept IDs or RxNorm RXCUIs. Note that concept codes are not unique across vocabularies. Type: Text';
COMMENT ON COLUMN medical_concept_information.concept_unique_identifier IS 'Primary Key. A unique identifier for each concept across all domains. Type: Integer';
COMMENT ON COLUMN medical_concept_information.concept_name IS 'An unambiguous, meaningful, and descriptive name for the concept. Type: Text';
COMMENT ON COLUMN medical_concept_information.domain_identifier IS 'Foreign Key. A reference to the domain table the concept belongs to. Type: Text';
COMMENT ON COLUMN medical_concept_information.concept_invalid_reason IS 'The reason why the concept was invalidated. Possible values are D (deleted), U (replaced with an update), or NULL when valid_end_date has the default value. Type: Text';
COMMENT ON COLUMN medical_concept_information.standard_concept_flag IS 'Indicates whether a concept is a standard concept, a classification concept, or a non-standard source concept. Type: Text';
COMMENT ON COLUMN medical_concept_information.concept_valid_end_date IS 'The date when the concept became invalid because it was deleted or updated. The default value is 31-Dec-2099, meaning the concept is valid until it becomes deprecated. Type: Date';
COMMENT ON COLUMN medical_concept_information.concept_valid_start_date IS 'The date when the concept was first recorded. The default value is 1-Jan-1970, meaning the concept has no known date of inception. Type: Date';
COMMENT ON COLUMN medical_concept_information.vocabulary_source_identifier IS 'Foreign Key. A reference to the vocabulary table indicating from which source the concept has been adapted. Type: Text';

CREATE TABLE medical_expense_record (
    contracted_amount_agreed NUMERIC,
    cost_event_domain VARCHAR(20),
    associated_event_identifier INTEGER,
    cost_record_identifier INTEGER,
    cost_source_concept_identifier INTEGER,
    currency_code_identifier INTEGER,
    diagnosis_related_group_identifier INTEGER,
    diagnosis_related_group_source_code VARCHAR(3),
    patient_paid_amount NUMERIC,
    payer_paid_amount NUMERIC,
    primary_payer_paid_amount NUMERIC,
    dispensing_fee_paid NUMERIC,
    ingredient_cost_paid NUMERIC,
    patient_coinsurance_paid NUMERIC,
    patient_copay_amount NUMERIC,
    patient_deductible_amount NUMERIC,
    payer_plan_period_identifier INTEGER,
    revenue_code_concept_identifier INTEGER,
    revenue_code_source VARCHAR(50),
    total_amount_charged NUMERIC,
    total_cost_incurred NUMERIC,
    total_amount_paid NUMERIC
);

COMMENT ON TABLE medical_expense_record IS 'This table captures records related to the cost of medical entities recorded in various tables like drug exposure, procedure occurrence, visit occurrence, or device occurrence. It also includes cost information for observation and measurement records.';
COMMENT ON COLUMN medical_expense_record.contracted_amount_agreed IS 'The contracted amount agreed between the payer and provider. Type: Numeric';
COMMENT ON COLUMN medical_expense_record.cost_event_domain IS 'The identifier for the domain of the cost event which indicates the related table that contains the entity for which cost information is recorded. Type: Text';
COMMENT ON COLUMN medical_expense_record.associated_event_identifier IS 'Foreign Key. The identifier for the event (e.g., Measurement, Procedure, Visit, Drug Exposure) for which cost data is recorded. Type: Integer';
COMMENT ON COLUMN medical_expense_record.cost_record_identifier IS 'Primary Key. A unique identifier for each cost record. Type: Integer';
COMMENT ON COLUMN medical_expense_record.cost_source_concept_identifier IS 'Foreign Key. The concept identifier pointing to the source of the cost data from the concept table, such as an insurance claim, provider revenue, etc. Type: Integer';
COMMENT ON COLUMN medical_expense_record.currency_code_identifier IS 'Foreign Key. The identifier for the concept representing the 3-letter code used for international currencies (e.g., USD). Type: Integer';
COMMENT ON COLUMN medical_expense_record.diagnosis_related_group_identifier IS 'Foreign Key. The identifier pointing to the predefined concept in the DRG Vocabulary related to a visit. Type: Integer';
COMMENT ON COLUMN medical_expense_record.diagnosis_related_group_source_code IS 'The 3-digit DRG source code as it appears in the source data. Type: Text';
COMMENT ON COLUMN medical_expense_record.patient_paid_amount IS 'The total amount paid by the patient as a share of the expenses. Type: Numeric';
COMMENT ON COLUMN medical_expense_record.payer_paid_amount IS 'The amount paid by the payer for the goods or services. Type: Numeric';
COMMENT ON COLUMN medical_expense_record.primary_payer_paid_amount IS 'The amount paid by a primary payer through coordination of benefits. Type: Numeric';
COMMENT ON COLUMN medical_expense_record.dispensing_fee_paid IS 'The amount paid by the payer to a pharmacy for dispensing a drug, excluding the amount paid for the drug ingredient. This fee contributes to the payer_paid_amount field. Type: Numeric';
COMMENT ON COLUMN medical_expense_record.ingredient_cost_paid IS 'The amount paid by the payer to a pharmacy for the drug, excluding the amount paid for dispensing the drug. This cost contributes to the payer_paid_amount field. Type: Numeric';
COMMENT ON COLUMN medical_expense_record.patient_coinsurance_paid IS 'The amount paid by the patient as a joint assumption of risk, typically a percentage of the expenses defined by the payer plan. Type: Numeric';
COMMENT ON COLUMN medical_expense_record.patient_copay_amount IS 'The amount paid by the patient as a fixed contribution to the expenses. Type: Numeric';
COMMENT ON COLUMN medical_expense_record.patient_deductible_amount IS 'The amount paid by the patient that contributes toward the deductible defined by the payer plan. This amount contributes to the patient_paid_amount field. Type: Numeric';
COMMENT ON COLUMN medical_expense_record.payer_plan_period_identifier IS 'Foreign Key. The identifier referring to the payer plan period table where details of the payer, plan, and family are stored. Type: Integer';
COMMENT ON COLUMN medical_expense_record.revenue_code_concept_identifier IS 'Foreign Key. The identifier referring to a standard concept ID for revenue codes from standardized vocabularies. Type: Integer';
COMMENT ON COLUMN medical_expense_record.revenue_code_source IS 'The source code for the revenue code as it appears in the source data, stored for reference. Type: Text';
COMMENT ON COLUMN medical_expense_record.total_amount_charged IS 'The total amount charged by a provider (e.g., hospital, physician, pharmacy) to payers (insurance companies, the patient). Type: Numeric';
COMMENT ON COLUMN medical_expense_record.total_cost_incurred IS 'The cost incurred by the provider of goods or services. Type: Numeric';
COMMENT ON COLUMN medical_expense_record.total_amount_paid IS 'The total amount actually paid by all payers for goods or services provided. Type: Numeric';

CREATE TABLE metadata_information (
    metadata_concept_identifier INTEGER,
    metadata_date DATE,
    metadata_datetime TIMESTAMP,
    metadata_identifier INTEGER,
    metadata_type_concept_identifier INTEGER,
    metadata_name VARCHAR(250),
    value_as_concept_identifier INTEGER,
    value_as_numeric NUMERIC,
    value_as_text VARCHAR(250)
);

COMMENT ON TABLE metadata_information IS 'This table contains metadata information about a dataset that has been transformed to the Observational Medical Outcomes Partnership (OMOP) Common Data Model.';
COMMENT ON COLUMN metadata_information.metadata_concept_identifier IS 'A unique identifier that provides the metadata concept. Type: Integer';
COMMENT ON COLUMN metadata_information.metadata_date IS 'The date associated with the metadata attribute. Type: Date';
COMMENT ON COLUMN metadata_information.metadata_datetime IS 'The datetime associated with the metadata attribute. Type: Timestamp';
COMMENT ON COLUMN metadata_information.metadata_identifier IS 'Primary Key. A unique key assigned to a metadata record, auto-generated by the system. Type: Integer';
COMMENT ON COLUMN metadata_information.metadata_type_concept_identifier IS 'A unique identifier that provides the type of metadata. Type: Integer';
COMMENT ON COLUMN metadata_information.metadata_name IS 'The name of the metadata attribute. Type: Text (250 characters)';
COMMENT ON COLUMN metadata_information.value_as_concept_identifier IS 'A unique identifier that represents the value of the metadata attribute. Type: Integer';
COMMENT ON COLUMN metadata_information.value_as_numeric IS 'The numeric value of the metadata attribute, if applicable and available. Not all metadata will have numeric values. Type: Numeric';
COMMENT ON COLUMN metadata_information.value_as_text IS 'The text value of the metadata attribute. Type: Text (250 characters)';

CREATE TABLE note_natural_language_processing (
    raw_extracted_text VARCHAR(250),
    processing_date DATE,
    processing_datetime TIMESTAMP,
    processing_system VARCHAR(250),
    note_identifier INTEGER,
    extracted_term_concept_identifier INTEGER,
    extracted_term_identifier INTEGER,
    source_code_concept_identifier INTEGER,
    character_offset VARCHAR(50),
    section_concept_identifier INTEGER,
    text_snippet VARCHAR(250),
    term_presence VARCHAR(1),
    term_modifiers VARCHAR(2000),
    temporal_status VARCHAR(50)
);

COMMENT ON TABLE note_natural_language_processing IS 'This table encodes all output of natural language processing on clinical notes. Each row represents a single extracted term from a note.';
COMMENT ON COLUMN note_natural_language_processing.raw_extracted_text IS 'Raw text extracted from the natural language processing tool. Type: Text';
COMMENT ON COLUMN note_natural_language_processing.processing_date IS 'The date of the note processing. Useful for data provenance. Type: Date';
COMMENT ON COLUMN note_natural_language_processing.processing_datetime IS 'The date and time of the note processing. Useful for data provenance. Type: Timestamp';
COMMENT ON COLUMN note_natural_language_processing.processing_system IS 'Name and version of the natural language processing system that extracted the term. Useful for data provenance. Type: Text';
COMMENT ON COLUMN note_natural_language_processing.note_identifier IS 'Foreign Key. A reference to the Note table where the term was extracted from. Type: Integer';
COMMENT ON COLUMN note_natural_language_processing.extracted_term_concept_identifier IS 'Foreign Key. A reference to the predefined Concept in the Standardized Vocabularies reflecting the normalized concept for the extracted term. Type: Integer';
COMMENT ON COLUMN note_natural_language_processing.extracted_term_identifier IS 'Primary Key. A unique identifier for each term extracted from a note. Type: Integer';
COMMENT ON COLUMN note_natural_language_processing.source_code_concept_identifier IS 'Foreign Key. A reference to a Concept that refers to the code in the source vocabulary used by the natural language processing system. Type: Integer';
COMMENT ON COLUMN note_natural_language_processing.character_offset IS 'Character offset of the extracted term in the input note. Type: Text';
COMMENT ON COLUMN note_natural_language_processing.section_concept_identifier IS 'Foreign Key. A reference to the predefined Concept in the Standardized Vocabularies representing the section of the extracted term. Type: Integer';
COMMENT ON COLUMN note_natural_language_processing.text_snippet IS 'A small window of text surrounding the term. Type: Text';
COMMENT ON COLUMN note_natural_language_processing.term_presence IS 'A summary modifier that signifies presence or absence of the term for a given patient. Useful for quick querying. Type: Character (1)';
COMMENT ON COLUMN note_natural_language_processing.term_modifiers IS 'Concatenated string of various term modifiers including negation, subject, conditional, rule_out, and uncertainty values for different entities such as conditions, drugs, and labs. Type: Text';
COMMENT ON COLUMN note_natural_language_processing.temporal_status IS 'Indicates if a condition is present or occurred in the past. Type: Text';

CREATE TABLE observation_records (
    observation_event_table_identifier INTEGER,
    observation_concept_identifier INTEGER,
    observation_date DATE,
    observation_datetime TIMESTAMP,
    observation_event_identifier INTEGER,
    observation_identifier INTEGER,
    observation_source_concept_identifier INTEGER,
    observation_source_code VARCHAR(50),
    observation_type_concept_identifier INTEGER,
    person_identifier INTEGER,
    provider_identifier INTEGER,
    qualifier_concept_identifier INTEGER,
    qualifier_source_code VARCHAR(50),
    unit_concept_identifier INTEGER,
    unit_source_code VARCHAR(50),
    value_as_concept_identifier INTEGER,
    value_as_numeric NUMERIC,
    value_as_text VARCHAR(60),
    value_source_code VARCHAR(50),
    visit_detail_identifier INTEGER,
    visit_occurrence_identifier INTEGER
);

COMMENT ON TABLE observation_records IS 'This table captures clinical facts about a person obtained during an examination, questioning, or procedure. It includes data that cannot be represented by other domains such as social and lifestyle details, medical history, and family history.';
COMMENT ON COLUMN observation_records.observation_event_table_identifier IS 'Foreign Key. Identifies which table the primary key of the related record came from, represented by a concept identifier. Type: Integer';
COMMENT ON COLUMN observation_records.observation_concept_identifier IS 'Foreign Key. Refers to the standard observation concept identifier in the standardized vocabularies. Type: Integer';
COMMENT ON COLUMN observation_records.observation_date IS 'The date of the observation. Type: Date';
COMMENT ON COLUMN observation_records.observation_datetime IS 'The date and time of the observation. Type: Timestamp';
COMMENT ON COLUMN observation_records.observation_event_identifier IS 'If the observation record is related to another record, this is the primary key of the linked record. Type: Integer';
COMMENT ON COLUMN observation_records.observation_identifier IS 'Primary Key. A unique identifier for each observation. Type: Integer';
COMMENT ON COLUMN observation_records.observation_source_concept_identifier IS 'Foreign Key. Refers to the concept that represents the code used in the source data. Type: Integer';
COMMENT ON COLUMN observation_records.observation_source_code IS 'The observation code as it appears in the source data, mapped to a standard concept and stored for reference. Type: Text';
COMMENT ON COLUMN observation_records.observation_type_concept_identifier IS 'Foreign Key. Refers to the predefined concept identifier in the standardized vocabularies reflecting the type of the observation. Type: Integer';
COMMENT ON COLUMN observation_records.person_identifier IS 'Foreign Key. Identifies the person about whom the observation was recorded. Demographic details are stored in the person table. Type: Integer';
COMMENT ON COLUMN observation_records.provider_identifier IS 'Foreign Key. Identifies the provider in the provider table who made the observation. Type: Integer';
COMMENT ON COLUMN observation_records.qualifier_concept_identifier IS 'Foreign Key. Refers to a standard concept identifier for a qualifier, such as the severity of an alert. Type: Integer';
COMMENT ON COLUMN observation_records.qualifier_source_code IS 'The source value associated with a qualifier providing additional characterization of the observation. Type: Text';
COMMENT ON COLUMN observation_records.unit_concept_identifier IS 'Foreign Key. Refers to the standard concept identifier of measurement units in the standardized vocabularies. Type: Integer';
COMMENT ON COLUMN observation_records.unit_source_code IS 'The source code for the unit as it appears in the source data, mapped to a standard unit concept and stored for reference. Type: Text';
COMMENT ON COLUMN observation_records.value_as_concept_identifier IS 'Foreign Key. Refers to an observation result stored as a concept identifier, applicable to results expressed as standard concepts (e.g., positive/negative). Type: Integer';
COMMENT ON COLUMN observation_records.value_as_numeric IS 'The observation result stored as a numeric value. Applicable where the result is expressed numerically. Type: Numeric';
COMMENT ON COLUMN observation_records.value_as_text IS 'The observation result stored as text. Applicable where the result is expressed as verbatim text. Type: Text';
COMMENT ON COLUMN observation_records.value_source_code IS 'Verbatim result value of the observation from the source data. Different from observation_source_code which captures the source observation code. Type: Text';
COMMENT ON COLUMN observation_records.visit_detail_identifier IS 'Foreign Key. Identifies the visit in the visit_detail table during which the observation was recorded. Type: Integer';
COMMENT ON COLUMN observation_records.visit_occurrence_identifier IS 'Foreign Key. Identifies the visit in the visit_occurrence table during which the observation was recorded. Type: Integer';

CREATE TABLE patient_information (
    birth_date_time TIMESTAMP,
    primary_care_site_identifier INTEGER,
    birth_day INTEGER,
    ethnicity_standard_concept_identifier INTEGER,
    ethnicity_source_concept_identifier INTEGER,
    ethnicity_source_code VARCHAR(50),
    gender_standard_concept_identifier INTEGER,
    gender_source_concept_identifier INTEGER,
    gender_source_code VARCHAR(50),
    residency_location_identifier INTEGER,
    birth_month INTEGER,
    person_identifier INTEGER,
    person_source_key VARCHAR(50),
    primary_provider_identifier INTEGER,
    race_standard_concept_identifier INTEGER,
    race_source_concept_identifier INTEGER,
    race_source_code VARCHAR(50),
    birth_year INTEGER
);

COMMENT ON TABLE patient_information IS 'This table contains records that uniquely identify each patient at risk of having clinical observations recorded within the source systems.';
COMMENT ON COLUMN patient_information.birth_date_time IS 'The date and time of birth of the person. Type: Timestamp';
COMMENT ON COLUMN patient_information.primary_care_site_identifier IS 'Foreign Key. A reference to the site of primary care in the care_site table, where the details of the care site are stored. Type: Integer';
COMMENT ON COLUMN patient_information.birth_day IS 'The day of the month of birth of the person. Type: Integer';
COMMENT ON COLUMN patient_information.ethnicity_standard_concept_identifier IS 'Foreign Key. A reference to the standard concept identifier in the Standardized Vocabularies for the ethnicity of the person. Type: Integer';
COMMENT ON COLUMN patient_information.ethnicity_source_concept_identifier IS 'Foreign Key. A reference to the ethnicity concept that refers to the code used in the source. Type: Integer';
COMMENT ON COLUMN patient_information.ethnicity_source_code IS 'The source code for the ethnicity of the person as it appears in the source data. Type: Text';
COMMENT ON COLUMN patient_information.gender_standard_concept_identifier IS 'Foreign Key. A reference to an identifier in the concept table for the gender of the person. Type: Integer';
COMMENT ON COLUMN patient_information.gender_source_concept_identifier IS 'Foreign Key. A reference to the gender concept that refers to the code used in the source. Type: Integer';
COMMENT ON COLUMN patient_information.gender_source_code IS 'The source code for the gender of the person as it appears in the source data. Type: Text';
COMMENT ON COLUMN patient_information.residency_location_identifier IS 'Foreign Key. A reference to the place of residency for the person in the location table. Type: Integer';
COMMENT ON COLUMN patient_information.birth_month IS 'The month of birth of the person. Type: Integer';
COMMENT ON COLUMN patient_information.person_identifier IS 'Primary Key. A unique identifier for each person. Type: Integer';
COMMENT ON COLUMN patient_information.person_source_key IS 'An encrypted key derived from the person identifier in the source data. Type: Text';
COMMENT ON COLUMN patient_information.primary_provider_identifier IS 'Foreign Key. A reference to the primary care provider the person is seeing in the provider table. Type: Integer';
COMMENT ON COLUMN patient_information.race_standard_concept_identifier IS 'Foreign Key. A reference to an identifier in the concept table for the race of the person. Type: Integer';
COMMENT ON COLUMN patient_information.race_source_concept_identifier IS 'Foreign Key. A reference to the race concept that refers to the code used in the source. Type: Integer';
COMMENT ON COLUMN patient_information.race_source_code IS 'The source code for the race of the person as it appears in the source data. Type: Text';
COMMENT ON COLUMN patient_information.birth_year IS 'The year of birth of the person. Type: Integer';

CREATE TABLE procedure_record (
    procedure_modifier_identifier INTEGER,
    procedure_modifier_source_code VARCHAR(50),
    person_identifier INTEGER,
    procedure_identifier INTEGER,
    procedure_date DATE,
    procedure_datetime TIMESTAMP,
    procedure_end_date DATE,
    procedure_end_datetime TIMESTAMP,
    procedure_record_identifier INTEGER,
    procedure_source_identifier INTEGER,
    procedure_source_code VARCHAR(50),
    procedure_type_identifier INTEGER,
    provider_identifier INTEGER,
    procedure_quantity INTEGER,
    visit_detail_identifier INTEGER,
    visit_occurrence_identifier INTEGER
);

COMMENT ON TABLE procedure_record IS 'This table contains records of medical procedures performed on patients by healthcare providers. Procedures may be diagnostic or therapeutic.';
COMMENT ON COLUMN procedure_record.procedure_modifier_identifier IS 'Foreign Key. A unique identifier for a modifier to the procedure (e.g., bilateral). Type: Integer';
COMMENT ON COLUMN procedure_record.procedure_modifier_source_code IS 'The source code for the modifier as it appears in the source data. Type: Text';
COMMENT ON COLUMN procedure_record.person_identifier IS 'Foreign Key. A unique identifier for the person subjected to the procedure. The demographic details of that person are stored in the person table. Type: Integer';
COMMENT ON COLUMN procedure_record.procedure_identifier IS 'Foreign Key. A unique identifier referring to a standard procedure concept in the standardized vocabularies. Type: Integer';
COMMENT ON COLUMN procedure_record.procedure_date IS 'The date on which the procedure was performed. Type: Date';
COMMENT ON COLUMN procedure_record.procedure_datetime IS 'The date and time on which the procedure was performed. Type: Timestamp';
COMMENT ON COLUMN procedure_record.procedure_end_date IS 'The date on which the procedure finished. Type: Date';
COMMENT ON COLUMN procedure_record.procedure_end_datetime IS 'The date and time on which the procedure finished. Type: Timestamp';
COMMENT ON COLUMN procedure_record.procedure_record_identifier IS 'Primary Key. A unique identifier for each procedure record. Type: Integer';
COMMENT ON COLUMN procedure_record.procedure_source_identifier IS 'Foreign Key. A unique identifier for a procedure concept that refers to the code used in the source. Type: Integer';
COMMENT ON COLUMN procedure_record.procedure_source_code IS 'The source code for the procedure as it appears in the source data. This code is mapped to a standard procedure concept in the standardized vocabularies and the original code is stored here for reference. Type: Text';
COMMENT ON COLUMN procedure_record.procedure_type_identifier IS 'Foreign Key. A unique identifier reflecting the type of source data from which the procedure record is derived in the standardized vocabularies. Type: Integer';
COMMENT ON COLUMN procedure_record.provider_identifier IS 'Foreign Key. A unique identifier for the provider responsible for carrying out the procedure. Type: Integer';
COMMENT ON COLUMN procedure_record.procedure_quantity IS 'The quantity of procedures ordered or administered. Type: Integer';
COMMENT ON COLUMN procedure_record.visit_detail_identifier IS 'Foreign Key. A unique identifier for the visit during which the procedure was carried out. Type: Integer';
COMMENT ON COLUMN procedure_record.visit_occurrence_identifier IS 'Foreign Key. A unique identifier for the visit during which the procedure was carried out. Type: Integer';

CREATE TABLE source_to_standard_mapping (
    concept_invalid_reason VARCHAR(1),
    local_source_code VARCHAR(50),
    local_source_code_description VARCHAR(255),
    local_source_concept_identifier INTEGER,
    local_source_vocabulary_identifier VARCHAR(20),
    standard_concept_identifier INTEGER,
    standard_vocabulary_identifier VARCHAR(20),
    concept_valid_end_date DATE,
    concept_valid_start_date DATE
);

COMMENT ON TABLE source_to_standard_mapping IS 'This table is used in Extract, Transform, and Load (ETL) processes to maintain local source codes not available as standardized vocabulary concepts and to map each source code to a standard concept. The table is no longer populated with new content.';
COMMENT ON COLUMN source_to_standard_mapping.concept_invalid_reason IS 'Reason the mapping instance was invalidated. Possible values are D (deleted), U (replaced with an update), or NULL when the default end date is used.';
COMMENT ON COLUMN source_to_standard_mapping.local_source_code IS 'The local source code being translated into a standard concept.';
COMMENT ON COLUMN source_to_standard_mapping.local_source_code_description IS 'An optional description for the local source code included to compare the description of the source code to the name of the concept.';
COMMENT ON COLUMN source_to_standard_mapping.local_source_concept_identifier IS 'Foreign Key. A reference to the source concept being translated into a standard concept.';
COMMENT ON COLUMN source_to_standard_mapping.local_source_vocabulary_identifier IS 'Foreign Key. A reference to the vocabulary table defining the vocabulary of the local source code being translated to a standard concept.';
COMMENT ON COLUMN source_to_standard_mapping.standard_concept_identifier IS 'Foreign Key. A reference to the target concept to which the local source code is being mapped.';
COMMENT ON COLUMN source_to_standard_mapping.standard_vocabulary_identifier IS 'Foreign Key. A reference to the vocabulary table defining the vocabulary of the target concept.';
COMMENT ON COLUMN source_to_standard_mapping.concept_valid_end_date IS 'The date when the mapping instance became invalid due to deletion or being superseded by an update. Default value is 31-Dec-2099.';
COMMENT ON COLUMN source_to_standard_mapping.concept_valid_start_date IS 'The date when the mapping instance was first recorded.';

CREATE TABLE visit_information_detail (
    admission_source_concept_identifier INTEGER,
    admission_source_code VARCHAR(50),
    unit_identifier INTEGER,
    discharge_location_concept_identifier INTEGER,
    discharge_location_code VARCHAR(50),
    person_identifier INTEGER,
    previous_visit_detail_identifier INTEGER,
    provider_identifier INTEGER,
    visit_concept_identifier INTEGER,
    visit_end_date DATE,
    visit_end_timestamp TIMESTAMP,
    visit_detail_identifier INTEGER,
    parent_visit_detail_identifier INTEGER,
    source_concept_identifier INTEGER,
    visit_source_code VARCHAR(50),
    visit_start_date DATE,
    visit_start_timestamp TIMESTAMP,
    visit_type_concept_identifier INTEGER,
    visit_occurrence_identifier INTEGER
);

COMMENT ON TABLE visit_information_detail IS 'This table contains detailed information for each visit record in the parent visit_occurrence table. Each visit occurrence may have zero or more detailed records in this table.';
COMMENT ON COLUMN visit_information_detail.admission_source_concept_identifier IS 'Foreign Key. A reference to the predefined concept in the Place of Service Vocabulary reflecting the source of admission for a visit. Type: Integer';
COMMENT ON COLUMN visit_information_detail.admission_source_code IS 'The source code for the admission source as it appears in the source data. Type: Text';
COMMENT ON COLUMN visit_information_detail.unit_identifier IS 'Foreign Key. A reference to the care site in the care site table that was visited. Type: Integer';
COMMENT ON COLUMN visit_information_detail.discharge_location_concept_identifier IS 'Foreign Key. A reference to the predefined concept in the Place of Service Vocabulary reflecting the discharge disposition for a visit. Type: Integer';
COMMENT ON COLUMN visit_information_detail.discharge_location_code IS 'The source code for the discharge disposition as it appears in the source data. Type: Text';
COMMENT ON COLUMN visit_information_detail.person_identifier IS 'Foreign Key. A reference to the Person for whom the visit is recorded. The demographic details of that Person are stored in the PERSON table. Type: Integer';
COMMENT ON COLUMN visit_information_detail.previous_visit_detail_identifier IS 'Foreign Key. A reference to the VISIT_DETAIL table record of the visit immediately preceding this visit. Type: Integer';
COMMENT ON COLUMN visit_information_detail.provider_identifier IS 'Foreign Key. A reference to the provider in the provider table who was associated with the visit. Type: Integer';
COMMENT ON COLUMN visit_information_detail.visit_concept_identifier IS 'Foreign Key. A reference to a visit Concept identifier in the Standardized Vocabularies. Type: Integer';
COMMENT ON COLUMN visit_information_detail.visit_end_date IS 'The end date of the visit. If this is a one-day visit the end date should match the start date. Type: Date';
COMMENT ON COLUMN visit_information_detail.visit_end_timestamp IS 'The date and time of the visit end. Type: Timestamp';
COMMENT ON COLUMN visit_information_detail.visit_detail_identifier IS 'Primary Key. A unique identifier for each visit detail record. Type: Integer';
COMMENT ON COLUMN visit_information_detail.parent_visit_detail_identifier IS 'Foreign Key. A reference to the VISIT_DETAIL table record to represent the immediate parent visit-detail record. Type: Integer';
COMMENT ON COLUMN visit_information_detail.source_concept_identifier IS 'Foreign Key. A reference to a Concept that refers to the code used in the source. Type: Integer';
COMMENT ON COLUMN visit_information_detail.visit_source_code IS 'The source code for the visit as it appears in the source data. Type: Text';
COMMENT ON COLUMN visit_information_detail.visit_start_date IS 'The start date of the visit. Type: Date';
COMMENT ON COLUMN visit_information_detail.visit_start_timestamp IS 'The date and time when the visit started. Type: Timestamp';
COMMENT ON COLUMN visit_information_detail.visit_type_concept_identifier IS 'Foreign Key. A reference to the predefined Concept identifier in the Standardized Vocabularies reflecting the type of source data from which the visit record is derived. Type: Integer';
COMMENT ON COLUMN visit_information_detail.visit_occurrence_identifier IS 'Foreign Key. A reference to the record in the VISIT_OCCURRENCE table. This is a required field, as each visit_detail is a child of visit_occurrence and cannot exist without a corresponding parent record in visit_occurrence. Type: Integer';

CREATE TABLE visit_record (
    admission_source_concept_identifier INTEGER,
    admission_source_code VARCHAR(50),
    unit_identifier INTEGER,
    discharge_location_concept_identifier INTEGER,
    discharge_location_code VARCHAR(50),
    person_identifier INTEGER,
    preceding_visit_identifier INTEGER,
    provider_identifier INTEGER,
    visit_concept_identifier INTEGER,
    visit_end_date DATE,
    visit_end_date_time TIMESTAMP,
    visit_occurrence_identifier INTEGER,
    visit_source_concept_identifier INTEGER,
    visit_source_code VARCHAR(50),
    visit_start_date DATE,
    visit_start_date_time TIMESTAMP,
    visit_type_concept_identifier INTEGER
);

COMMENT ON TABLE visit_record IS 'This table contains details of the time spans a person receives medical services in different settings. Visits are classified into outpatient care, inpatient confinement, emergency room, and long-term care.';
COMMENT ON COLUMN visit_record.admission_source_concept_identifier IS 'A foreign key to the predefined concept reflecting the admitting source for a visit. Type: Integer';
COMMENT ON COLUMN visit_record.admission_source_code IS 'The source code for the admitting source as it appears in the source data. Type: Text';
COMMENT ON COLUMN visit_record.unit_identifier IS 'A foreign key to the care site in the care site table that was visited. Type: Integer';
COMMENT ON COLUMN visit_record.discharge_location_concept_identifier IS 'A foreign key to the predefined concept reflecting the discharge disposition for a visit. Type: Integer';
COMMENT ON COLUMN visit_record.discharge_location_code IS 'The source code for the discharge disposition as it appears in the source data. Type: Text';
COMMENT ON COLUMN visit_record.person_identifier IS 'A foreign key identifier to the Person for whom the visit is recorded. The demographic details of that person are stored in the person table. Type: Integer';
COMMENT ON COLUMN visit_record.preceding_visit_identifier IS 'A foreign key to the visit record table of the visit immediately preceding this visit. Type: Integer';
COMMENT ON COLUMN visit_record.provider_identifier IS 'A foreign key to the provider in the provider table who was associated with the visit. Type: Integer';
COMMENT ON COLUMN visit_record.visit_concept_identifier IS 'A foreign key that refers to a visit concept identifier in the standardized vocabularies. Type: Integer';
COMMENT ON COLUMN visit_record.visit_end_date IS 'The end date of the visit. If this is a one-day visit, the end date should match the start date. Type: Date';
COMMENT ON COLUMN visit_record.visit_end_date_time IS 'The date and time of the visit end. Type: Timestamp';
COMMENT ON COLUMN visit_record.visit_occurrence_identifier IS 'Primary Key. A unique identifier for each visit occurrence. Type: Integer';
COMMENT ON COLUMN visit_record.visit_source_concept_identifier IS 'A foreign key to a concept that refers to the code used in the source. Type: Integer';
COMMENT ON COLUMN visit_record.visit_source_code IS 'The source code for the visit as it appears in the source data. Type: Text';
COMMENT ON COLUMN visit_record.visit_start_date IS 'The start date of the visit. Type: Date';
COMMENT ON COLUMN visit_record.visit_start_date_time IS 'The date and time the visit started. Type: Timestamp';
COMMENT ON COLUMN visit_record.visit_type_concept_identifier IS 'A foreign key to the predefined concept identifier reflecting the type of source data from which the visit record is derived. Type: Integer';

CREATE TABLE vocabulary_source_information (
    vocabulary_concept_identifier INTEGER,
    vocabulary_source_identifier VARCHAR(20),
    vocabulary_name VARCHAR(255),
    vocabulary_external_reference VARCHAR(255),
    standardized_vocabularies_version VARCHAR(255)
);

COMMENT ON TABLE vocabulary_source_information IS 'This table includes a list of vocabularies collected from various sources or created de novo by the OMOP community. Each record includes a descriptive name and other attributes for the vocabulary.';
COMMENT ON COLUMN vocabulary_source_information.vocabulary_concept_identifier IS 'Foreign Key. A reference to a standard concept identifier in the concept table for the vocabulary this record belongs to.';
COMMENT ON COLUMN vocabulary_source_information.vocabulary_source_identifier IS 'Unique identifier for each vocabulary source, such as International Classification of Diseases, Ninth Revision, Clinical Modification (ICD9CM), Systematized Nomenclature of Medicine (SNOMED), Visit.';
COMMENT ON COLUMN vocabulary_source_information.vocabulary_name IS 'The name describing the vocabulary, for example, 'International Classification of Diseases, Ninth Revision, Clinical Modification, Volume 1 and 2 (NCHS)'.';
COMMENT ON COLUMN vocabulary_source_information.vocabulary_external_reference IS 'External reference to documentation or available download for the vocabulary.';
COMMENT ON COLUMN vocabulary_source_information.standardized_vocabularies_version IS 'Version of the vocabulary as indicated in the source.';