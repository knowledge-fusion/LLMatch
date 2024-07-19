CREATE TABLE biological_sample (
    anatomic_site_identifier INTEGER,
    anatomic_site_source VARCHAR(50),
    disease_status_identifier INTEGER,
    disease_status_source VARCHAR(50),
    person_identifier INTEGER,
    quantity NUMERIC,
    specimen_identifier INTEGER,
    specimen_collection_date DATE,
    specimen_collection_datetime TIMESTAMP,
    specimen_id INTEGER,
    specimen_source_identifier VARCHAR(50),
    specimen_source_value VARCHAR(50),
    specimen_type_identifier INTEGER,
    unit_concept_identifier INTEGER,
    unit_source_value VARCHAR(50)
);

COMMENT ON TABLE biological_sample IS 'This table contains information on biological samples collected from a person.';
COMMENT ON COLUMN biological_sample.anatomic_site_identifier IS 'Foreign Key. A reference to a Standard Concept identifier for the anatomic location of specimen collection.';
COMMENT ON COLUMN biological_sample.anatomic_site_source IS 'The anatomic site as detailed in the source data.';
COMMENT ON COLUMN biological_sample.disease_status_identifier IS 'Foreign Key. A reference to a Standard Concept identifier for the Disease Status of specimen collection.';
COMMENT ON COLUMN biological_sample.disease_status_source IS 'The disease status as detailed in the source data.';
COMMENT ON COLUMN biological_sample.person_identifier IS 'Foreign Key. An identifier for the person for whom the Specimen is recorded.';
COMMENT ON COLUMN biological_sample.quantity IS 'The amount of biological sample collected from the person during the sampling procedure.';
COMMENT ON COLUMN biological_sample.specimen_identifier IS 'Foreign Key. A reference to a Standard Concept identifier in the Standardized Vocabularies for the specimen.';
COMMENT ON COLUMN biological_sample.specimen_collection_date IS 'The date the biological sample was obtained from the person.';
COMMENT ON COLUMN biological_sample.specimen_collection_datetime IS 'The date and time when the biological sample was obtained from the person.';
COMMENT ON COLUMN biological_sample.specimen_id IS 'Primary Key. A unique identifier for each biological sample.';
COMMENT ON COLUMN biological_sample.specimen_source_identifier IS 'The biological sample identifier as it appears in the source data.';
COMMENT ON COLUMN biological_sample.specimen_source_value IS 'The biological sample value as it appears in the source data. This value is mapped to a Standard Concept in the Standardized Vocabularies and the original code is stored here for reference.';
COMMENT ON COLUMN biological_sample.specimen_type_identifier IS 'Foreign Key. A reference to the Concept identifier in the Standardized Vocabularies reflecting the system of record from which the Specimen was represented in the source data.';
COMMENT ON COLUMN biological_sample.unit_concept_identifier IS 'Foreign Key. A reference to a Standard Concept identifier for the Unit associated with the numeric quantity of the biological sample collection.';
COMMENT ON COLUMN biological_sample.unit_source_value IS 'The Unit as detailed in the source data.';

CREATE TABLE clinical_episode (
    episode_concept_identifier INTEGER,
    end_date DATE,
    end_datetime TIMESTAMP,
    episode_identifier INTEGER,
    episode_number INTEGER,
    object_concept_identifier INTEGER,
    parent_episode_identifier INTEGER,
    source_concept_identifier INTEGER,
    source_value VARCHAR(50),
    start_date DATE,
    start_datetime TIMESTAMP,
    type_concept_identifier INTEGER,
    person_identifier INTEGER
);

COMMENT ON TABLE clinical_episode IS 'This table represents clinically and analytically relevant disease phases, outcomes, and treatments by aggregating lower-level clinical events (VISIT_OCCURRENCE, DRUG_EXPOSURE, PROCEDURE_OCCURRENCE, DEVICE_EXPOSURE) into a higher-level abstraction.';
COMMENT ON COLUMN clinical_episode.episode_concept_identifier IS 'Concept ID to classify the episode. Type: Integer';
COMMENT ON COLUMN clinical_episode.end_date IS 'The end date of the episode. Type: Date';
COMMENT ON COLUMN clinical_episode.end_datetime IS 'The end datetime of the episode. Type: Timestamp';
COMMENT ON COLUMN clinical_episode.episode_identifier IS 'Primary Key. A unique identifier used to identify each episode in the table. Type: Integer';
COMMENT ON COLUMN clinical_episode.episode_number IS 'The number of the episode. Type: Integer';
COMMENT ON COLUMN clinical_episode.object_concept_identifier IS 'Concept ID for the object in the episode. Type: Integer';
COMMENT ON COLUMN clinical_episode.parent_episode_identifier IS 'The parent episode identifier for the episode. Type: Integer';
COMMENT ON COLUMN clinical_episode.source_concept_identifier IS 'Concept ID for the source of the episode. Type: Integer';
COMMENT ON COLUMN clinical_episode.source_value IS 'The source value of the episode. Type: String';
COMMENT ON COLUMN clinical_episode.start_date IS 'The start date of the episode. Type: Date';
COMMENT ON COLUMN clinical_episode.start_datetime IS 'The start datetime of the episode. Type: Timestamp';
COMMENT ON COLUMN clinical_episode.type_concept_identifier IS 'Concept ID for the episode type. Type: Integer';
COMMENT ON COLUMN clinical_episode.person_identifier IS 'Foreign Key. A reference to the person table. Type: Integer';

CREATE TABLE clinical_event_episode (
    episode_event_concept_identifier INTEGER,
    episode_identifier INTEGER,
    event_identifier INTEGER
);

COMMENT ON TABLE clinical_event_episode IS 'This table connects qualifying clinical events (visits, drug exposures, procedures, and device exposures) to appropriate higher-level abstraction representing clinically and analytically relevant disease phases, outcomes, and treatments. For example, this table can be used to store information about the cancer that includes its development over time, treatment, and final resolution.';
COMMENT ON COLUMN clinical_event_episode.episode_event_concept_identifier IS 'The concept identifier for the clinical event. Data Type: Integer';
COMMENT ON COLUMN clinical_event_episode.episode_identifier IS 'Foreign Key. A reference to the clinical_episode table. Data Type: Integer';
COMMENT ON COLUMN clinical_event_episode.event_identifier IS 'The identifier for the qualifying clinical event. Data Type: Integer';

CREATE TABLE clinical_note_nlp (
    term_offset VARCHAR(50),
    term_variant VARCHAR(250),
    nlp_date DATE,
    nlp_datetime TIMESTAMP,
    nlp_system VARCHAR(250),
    note_identifier INTEGER,
    note_nlp_concept_id INTEGER,
    note_nlp_identifier INTEGER,
    note_nlp_source_concept_id INTEGER,
    section_concept_id INTEGER,
    snippet VARCHAR(250),
    term_exists VARCHAR(1),
    term_modifiers VARCHAR(2000),
    term_temporal VARCHAR(50)
);

COMMENT ON TABLE clinical_note_nlp IS 'This table encodes all output of natural language processing (NLP) on clinical notes. Each row represents a single extracted term from a note.';
COMMENT ON COLUMN clinical_note_nlp.term_offset IS 'The character offset of the term in the note. Type: Text';
COMMENT ON COLUMN clinical_note_nlp.term_variant IS 'The lexical variant of the term. Type: Text';
COMMENT ON COLUMN clinical_note_nlp.nlp_date IS 'The date of the NLP extraction. Type: Date';
COMMENT ON COLUMN clinical_note_nlp.nlp_datetime IS 'The datetime of the NLP extraction. Type: Timestamp';
COMMENT ON COLUMN clinical_note_nlp.nlp_system IS 'The system used for NLP extraction. Type: Text';
COMMENT ON COLUMN clinical_note_nlp.note_identifier IS 'Foreign Key. A reference to the patient_notes table. Type: Integer';
COMMENT ON COLUMN clinical_note_nlp.note_nlp_concept_id IS 'The concept identifier of the term as defined in the note_nlp_concept table. Type: Integer';
COMMENT ON COLUMN clinical_note_nlp.note_nlp_identifier IS 'Primary Key. A unique identifier used to represent each extracted term in the table. Type: Integer';
COMMENT ON COLUMN clinical_note_nlp.note_nlp_source_concept_id IS 'The concept identifier of the term in the source vocabulary. Type: Integer';
COMMENT ON COLUMN clinical_note_nlp.section_concept_id IS 'The concept identifier of the section in which the term appears in the note. Type: Integer';
COMMENT ON COLUMN clinical_note_nlp.snippet IS 'A snippet of text surrounding the term in the note. Type: Text';
COMMENT ON COLUMN clinical_note_nlp.term_exists IS 'Whether the term appears in the note. Type: Text';
COMMENT ON COLUMN clinical_note_nlp.term_modifiers IS 'Modifiers associated with the term. Type: Text';
COMMENT ON COLUMN clinical_note_nlp.term_temporal IS 'Temporal information associated with the term. Type: Text';

CREATE TABLE clinical_observation (
    observation_event_field_concept_identifier INTEGER,
    observation_concept_identifier INTEGER,
    observation_date DATE,
    observation_datetime TIMESTAMP,
    observation_event_identifier INTEGER,
    observation_identifier INTEGER,
    observation_source_concept_identifier INTEGER,
    observation_source_value VARCHAR(50),
    observation_type_concept_identifier INTEGER,
    person_identifier INTEGER,
    provider_identifier INTEGER,
    qualifier_concept_identifier INTEGER,
    qualifier_source_value VARCHAR(50),
    unit_concept_identifier INTEGER,
    unit_source_value VARCHAR(50),
    measurement_value_as_concept_identifier INTEGER,
    measurement_value_as_number NUMERIC,
    measurement_value_as_string VARCHAR(60),
    measurement_value_source_value VARCHAR(50),
    visit_detail_identifier INTEGER,
    visit_occurrence_identifier INTEGER
);

COMMENT ON TABLE clinical_observation IS 'This table stores clinical facts about a Person obtained in the context of examination, questioning or a procedure. Any data that cannot be represented by any other domains, such as social and lifestyle facts, medical history, family history, etc. are recorded here.';
COMMENT ON COLUMN clinical_observation.observation_event_field_concept_identifier IS 'Data Type: Integer';
COMMENT ON COLUMN clinical_observation.observation_concept_identifier IS 'Data Type: Integer. A foreign key to the standard observation concept identifier in the Standardized Vocabularies.';
COMMENT ON COLUMN clinical_observation.observation_date IS 'Data Type: Date. The date of the observation.';
COMMENT ON COLUMN clinical_observation.observation_datetime IS 'Data Type: Timestamp. The date and time of the observation.';
COMMENT ON COLUMN clinical_observation.observation_event_identifier IS 'Data Type: Integer';
COMMENT ON COLUMN clinical_observation.observation_identifier IS 'Data Type: Integer. Primary Key. A unique identifier for each observation.';
COMMENT ON COLUMN clinical_observation.observation_source_concept_identifier IS 'Data Type: Integer. A foreign key to a Concept that refers to the code used in the source.';
COMMENT ON COLUMN clinical_observation.observation_source_value IS 'Data Type: Text. The observation code as it appears in the source data. This code is mapped to a Standard Concept in the Standardized Vocabularies and the original code is, stored here for reference.';
COMMENT ON COLUMN clinical_observation.observation_type_concept_identifier IS 'Data Type: Integer. A foreign key to the predefined concept identifier in the Standardized Vocabularies reflecting the type of the observation.';
COMMENT ON COLUMN clinical_observation.person_identifier IS 'Data Type: Integer. A foreign key identifier to the Person about whom the observation was recorded. The demographic details of that Person are stored in the PERSON table.';
COMMENT ON COLUMN clinical_observation.provider_identifier IS 'Data Type: Integer. A foreign key to the provider in the PROVIDER table who was responsible for making the observation.';
COMMENT ON COLUMN clinical_observation.qualifier_concept_identifier IS 'Data Type: Integer. A foreign key to a Standard Concept ID for a qualifier (e.g., severity of drug-drug interaction alert)';
COMMENT ON COLUMN clinical_observation.qualifier_source_value IS 'Data Type: Text. The source value associated with a qualifier to characterize the observation';
COMMENT ON COLUMN clinical_observation.unit_concept_identifier IS 'Data Type: Integer. A foreign key to a Standard Concept ID of measurement units in the Standardized Vocabularies.';
COMMENT ON COLUMN clinical_observation.unit_source_value IS 'Data Type: Text. The source code for the unit as it appears in the source data. This code is mapped to a standard unit concept in the Standardized Vocabularies and the original code is, stored here for reference.';
COMMENT ON COLUMN clinical_observation.measurement_value_as_concept_identifier IS 'Data Type: Integer. A foreign key to an observation result stored as a Concept ID. This is applicable to observations where the result can be expressed as a Standard Concept from the Standardized Vocabularies (e.g., positive/negative, present/absent, low/high, etc.).';
COMMENT ON COLUMN clinical_observation.measurement_value_as_number IS 'Data Type: Numeric. The observation result stored as a number. This is applicable to observations where the result is expressed as a numeric value.';
COMMENT ON COLUMN clinical_observation.measurement_value_as_string IS 'Data Type: Text. The observation result stored as a string. This is applicable to observations where the result is expressed as verbatim text.';
COMMENT ON COLUMN clinical_observation.measurement_value_source_value IS 'Data Type: Text.';
COMMENT ON COLUMN clinical_observation.visit_detail_identifier IS 'Data Type: Integer. A foreign key to the visit in the VISIT_DETAIL table during which the observation was recorded.';
COMMENT ON COLUMN clinical_observation.visit_occurrence_identifier IS 'Data Type: Integer. A foreign key to the visit in the VISIT_OCCURRENCE table during which the observation was recorded.';

CREATE TABLE clinical_observation_period (
    end_date DATE,
    observation_period_identifier INTEGER,
    start_date DATE,
    period_type_concept_identifier INTEGER,
    person_identifier INTEGER
);

COMMENT ON TABLE clinical_observation_period IS 'This table contains the spans of time for which a Person is at-risk to have clinical events recorded within the source systems.';
COMMENT ON COLUMN clinical_observation_period.end_date IS 'The end date of the observation period for which data is available from the data source. Type: Date';
COMMENT ON COLUMN clinical_observation_period.observation_period_identifier IS 'Primary Key. A unique identifier for each observation period. Type: Integer';
COMMENT ON COLUMN clinical_observation_period.start_date IS 'The start date of the observation period for which data is available from the data source. Type: Date';
COMMENT ON COLUMN clinical_observation_period.period_type_concept_identifier IS 'Foreign Key. A reference to the predefined concept in the Standardized Vocabularies reflecting the source of the observation period information. Type: Integer';
COMMENT ON COLUMN clinical_observation_period.person_identifier IS 'Foreign Key. A reference to the person for whom the observation period is defined. The demographic details of that person are stored in the person table. Type: Integer';

CREATE TABLE concept_association (
    source_concept_identifier INTEGER,
    destination_concept_identifier INTEGER,
    invalidation_reason VARCHAR(1),
    relationship_identifier VARCHAR(20),
    invalidation_date DATE,
    validity_start_date DATE,
    is_subset_of_hierarchy VARCHAR(1),
    is_hierarchical_relationship VARCHAR(1),
    relationship_concept_identifier INTEGER,
    relationship_description VARCHAR(255),
    reverse_association_identifier VARCHAR(20)
);

COMMENT ON TABLE concept_association IS 'This table contains records that define direct relationships between any two Concepts and the nature or type of the relationship. Each type of a relationship is defined in the Relationship table.';
COMMENT ON COLUMN concept_association.source_concept_identifier IS 'Foreign Key. A reference to Concept table. Represents the source concept designation. Data Type: Integer';
COMMENT ON COLUMN concept_association.destination_concept_identifier IS 'Foreign Key. A reference to Concept table. Represents the destination concept designation. Data Type: Integer';
COMMENT ON COLUMN concept_association.invalidation_reason IS 'Reason the relationship was invalidated. Possible values are 'Deleted', 'Updated' or NULL when valid_end_date has the default value. Data Type: Text';
COMMENT ON COLUMN concept_association.relationship_identifier IS 'Primary Key. A unique identifier to the type or nature of the Relationship as defined in the Relationship table. Data Type: Text';
COMMENT ON COLUMN concept_association.invalidation_date IS 'The date when the Concept Relationship became invalid because it was deleted or superseded (updated) by a new relationship. Default value is 31-Dec-2099. Data Type: Date';
COMMENT ON COLUMN concept_association.validity_start_date IS 'The date when the instance of the Concept Relationship is first recorded. Data Type: Date';
COMMENT ON COLUMN concept_association.is_subset_of_hierarchy IS 'Defines whether a hierarchical relationship contributes to the concept_ancestor table. These are subsets of the hierarchical relationships. Valid values are 1 or 0.';
COMMENT ON COLUMN concept_association.is_hierarchical_relationship IS 'Defines whether a relationship defines concepts into classes or hierarchies. Values are 1 for hierarchical relationship or 0 if not.';
COMMENT ON COLUMN concept_association.relationship_concept_identifier IS 'Foreign key. Refers to an identifier in the CONCEPT table for the unique relationship concept.';
COMMENT ON COLUMN concept_association.relationship_description IS 'The text that describes the relationship type.';
COMMENT ON COLUMN concept_association.reverse_association_identifier IS 'The identifier for the relationship used to define the reverse relationship between two concepts.';

CREATE TABLE concept_classification (
    classification_concept_identifier INTEGER,
    classification_identifier VARCHAR(20),
    classification_name VARCHAR(255)
);

COMMENT ON TABLE concept_classification IS 'This table stores information about the different classes of concepts within standardized vocabularies.';
COMMENT ON COLUMN concept_classification.classification_concept_identifier IS 'Foreign Key. An identifier in the [CONCEPT](https://github.com/OHDSI/CommonDataModel/wiki/CONCEPT) table for the unique Concept Class the record belongs to. Type: Integer';
COMMENT ON COLUMN concept_classification.classification_identifier IS 'A unique identifier for each class. Type: Text';
COMMENT ON COLUMN concept_classification.classification_name IS 'The name describing the Concept Class, e.g. "Clinical Finding", "Ingredient", etc. Type: Text';

CREATE TABLE concept_relationship_hierarchy (
    higher_level_concept_id INTEGER,
    lower_level_concept_id INTEGER,
    maximum_hierarchy_level INTEGER,
    minimum_hierarchy_level INTEGER
);

COMMENT ON TABLE concept_relationship_hierarchy IS 'This table contains hierarchical relationships between concepts. It includes records for all parent-child relationships, as well as grandparent-grandchild relationships and those of any other level of lineage.';
COMMENT ON COLUMN concept_relationship_hierarchy.higher_level_concept_id IS 'Foreign Key. A reference to the concept in the concept table for the higher-level concept that forms the ancestor in the relationship. Type: Integer';
COMMENT ON COLUMN concept_relationship_hierarchy.lower_level_concept_id IS 'Foreign Key. A reference to the concept in the concept table for the lower-level concept that forms the descendant in the relationship. Type: Integer';
COMMENT ON COLUMN concept_relationship_hierarchy.maximum_hierarchy_level IS 'The maximum separation in number of levels of hierarchy between ancestor and descendant concepts. This is an attribute that is used to simplify hierarchic analysis. Type: Integer';
COMMENT ON COLUMN concept_relationship_hierarchy.minimum_hierarchy_level IS 'The minimum separation in number of levels of hierarchy between ancestor and descendant concepts. This is an attribute that is used to simplify hierarchic analysis. Type: Integer';

CREATE TABLE condition_period (
    condition_concept_identifier INTEGER,
    condition_period_end_date DATE,
    condition_period_identifier INTEGER,
    condition_period_start_date DATE,
    condition_occurrence_count INTEGER,
    person_identifier INTEGER
);

COMMENT ON TABLE condition_period IS 'This table contains periods of time during which a Person has a given condition.';
COMMENT ON COLUMN condition_period.condition_concept_identifier IS 'Foreign Key. Refers to a standard Condition Concept identifier in the Standardized Vocabularies. Type: Integer';
COMMENT ON COLUMN condition_period.condition_period_end_date IS 'The end date for the Condition Era constructed from the individual instances of Condition Occurrences. It is the end date of the final continuously recorded instance of the Condition. Type: Date';
COMMENT ON COLUMN condition_period.condition_period_identifier IS 'Primary Key. A unique identifier for each Condition Era. Type: Integer';
COMMENT ON COLUMN condition_period.condition_period_start_date IS 'The start date for the Condition Era constructed from the individual instances of Condition Occurrences. It is the start date of the very first chronologically recorded instance of the condition. Type: Date';
COMMENT ON COLUMN condition_period.condition_occurrence_count IS 'The number of individual Condition Occurrences used to construct the condition era. Type: Integer';
COMMENT ON COLUMN condition_period.person_identifier IS 'Foreign Key. A reference to the Person table containing demographic details of the person experiencing the Condition during the Condition Era. Type: Integer';

CREATE TABLE condition_record (
    condition_concept_identifier INTEGER,
    condition_end_date DATE,
    condition_end_datetime TIMESTAMP,
    condition_record_identifier INTEGER,
    condition_source_concept_identifier INTEGER,
    condition_source_value VARCHAR(50),
    condition_start_date DATE,
    condition_start_datetime TIMESTAMP,
    condition_status_concept_identifier INTEGER,
    condition_status_source_value VARCHAR(50),
    condition_type_concept_identifier INTEGER,
    person_identifier INTEGER,
    provider_identifier INTEGER,
    condition_stop_reason VARCHAR(20),
    visit_detail_identifier INTEGER,
    visit_occurrence_identifier INTEGER
);

COMMENT ON TABLE condition_record IS 'This table contains records of medical conditions stated as a diagnosis, a sign or a symptom, which is either observed by a provider or reported by the patient.';
COMMENT ON COLUMN condition_record.condition_concept_identifier IS 'Foreign Key. A unique identifier representing the medical condition. Type: Integer';
COMMENT ON COLUMN condition_record.condition_end_date IS 'The end date of the condition. Type: Date';
COMMENT ON COLUMN condition_record.condition_end_datetime IS 'The end datetime of the condition. Type: Timestamp';
COMMENT ON COLUMN condition_record.condition_record_identifier IS 'Primary Key. A unique identifier representing the condition record. Type: Integer';
COMMENT ON COLUMN condition_record.condition_source_concept_identifier IS 'Foreign Key. A unique identifier representing the medical condition in the source system. Type: Integer';
COMMENT ON COLUMN condition_record.condition_source_value IS 'The value of the medical condition in the source system. Type: Text';
COMMENT ON COLUMN condition_record.condition_start_date IS 'The start date of the condition. Type: Date';
COMMENT ON COLUMN condition_record.condition_start_datetime IS 'The start datetime of the condition. Type: Timestamp';
COMMENT ON COLUMN condition_record.condition_status_concept_identifier IS 'Foreign Key. A unique identifier representing the status of the medical condition. Type: Integer';
COMMENT ON COLUMN condition_record.condition_status_source_value IS 'The value of the status of the medical condition. Type: Text';
COMMENT ON COLUMN condition_record.condition_type_concept_identifier IS 'Foreign Key. A unique identifier representing the type of medical condition. Type: Integer';
COMMENT ON COLUMN condition_record.person_identifier IS 'Foreign Key. A unique identifier representing the person. Type: Integer';
COMMENT ON COLUMN condition_record.provider_identifier IS 'Foreign Key. A unique identifier representing the provider. Type: Integer';
COMMENT ON COLUMN condition_record.condition_stop_reason IS 'The reason for stopping the recording of the medical condition. Type: Text';
COMMENT ON COLUMN condition_record.visit_detail_identifier IS 'Foreign Key. A unique identifier representing the visit details. Type: Integer';
COMMENT ON COLUMN condition_record.visit_occurrence_identifier IS 'Foreign Key. A unique identifier representing the visit occurrence. Type: Integer';

CREATE TABLE constant_dose (
    end_date DATE,
    dose_era_identifier INTEGER,
    start_date DATE,
    dose_quantity NUMERIC,
    active_ingredient_concept_identifier INTEGER,
    person_identifier INTEGER,
    unit_concept_identifier INTEGER
);

COMMENT ON TABLE constant_dose IS 'This table contains information about continuous exposure to a specific active ingredient by a person for a period of time ('constant dose').';
COMMENT ON COLUMN constant_dose.end_date IS 'The end date of the final continuous instance of utilization of a drug for this era. Type: Date';
COMMENT ON COLUMN constant_dose.dose_era_identifier IS 'Primary Key. A unique identifier for each Dose Era in the table. Type: Integer';
COMMENT ON COLUMN constant_dose.start_date IS 'The start date of the first instance of utilization of a drug for this era. Type: Date';
COMMENT ON COLUMN constant_dose.dose_quantity IS 'The numeric value of the drug dose during this era. Type: Numeric';
COMMENT ON COLUMN constant_dose.active_ingredient_concept_identifier IS 'Foreign Key. A reference to the Standard Concept identifier in the Standardized Vocabularies for the active ingredient concept. Type: Integer';
COMMENT ON COLUMN constant_dose.person_identifier IS 'Foreign Key. A reference to the person table. Type: Integer';
COMMENT ON COLUMN constant_dose.unit_concept_identifier IS 'Foreign Key. A reference to the Standard Concept identifier in the Standardized Vocabularies for the unit concept. Type: Integer';

CREATE TABLE dataset_metadata (
    metadata_concept_identifier INTEGER,
    metadata_date DATE,
    metadata_datetime TIMESTAMP,
    metadata_identifier INTEGER,
    metadata_type_concept_identifier INTEGER,
    metadata_name VARCHAR(250),
    measurement_value_as_concept_identifier INTEGER,
    measurement_value_as_number NUMERIC,
    measurement_value_as_string VARCHAR(250)
);

COMMENT ON TABLE dataset_metadata IS 'This table contains metadata information about a dataset that has been transformed to the OMOP Common Data Model.';
COMMENT ON COLUMN dataset_metadata.metadata_concept_identifier IS 'Primary Key. Concept identifier of metadata. Type: Integer';
COMMENT ON COLUMN dataset_metadata.metadata_date IS 'The date of metadata. Type: Date';
COMMENT ON COLUMN dataset_metadata.metadata_datetime IS 'The date and time of metadata. Type: Timestamp';
COMMENT ON COLUMN dataset_metadata.metadata_identifier IS 'Unique identifier of metadata. Type: Integer';
COMMENT ON COLUMN dataset_metadata.metadata_type_concept_identifier IS 'Identifier of metadata type. Type: Integer';
COMMENT ON COLUMN dataset_metadata.metadata_name IS 'The name of metadata. Type: Text';
COMMENT ON COLUMN dataset_metadata.measurement_value_as_concept_identifier IS 'Concept identifier of the measurement value. Type: Integer';
COMMENT ON COLUMN dataset_metadata.measurement_value_as_number IS 'The measurement value in numeric format. Type: Float/Decimal';
COMMENT ON COLUMN dataset_metadata.measurement_value_as_string IS 'The measurement value in text format. Type: Text';

CREATE TABLE death_event (
    condition_concept_identifier INTEGER,
    condition_source_concept_identifier INTEGER,
    condition_source_code VARCHAR(50),
    death_date DATE,
    death_date_time TIMESTAMP,
    death_event_concept_identifier INTEGER,
    deceased_person_identifier INTEGER
);

COMMENT ON TABLE death_event IS 'This table contains clinical information for how and when a person dies.';
COMMENT ON COLUMN death_event.condition_concept_identifier IS 'Foreign Key. A reference to a standard concept identifier in the Standardized Vocabularies for conditions. Type: Integer';
COMMENT ON COLUMN death_event.condition_source_concept_identifier IS 'Foreign Key. A reference to the concept that refers to the code used in the source. Note: This variable name is abbreviated to ensure it will be allowable across database platforms. Type: Integer';
COMMENT ON COLUMN death_event.condition_source_code IS 'The source code for the cause of death as it appears in the source data. This code is mapped to a standard concept in the Standardized Vocabularies and the original code is stored here for reference. Type: Text';
COMMENT ON COLUMN death_event.death_date IS 'The date when the death occurred. Type: Date';
COMMENT ON COLUMN death_event.death_date_time IS 'The date and time when the death occurred. Type: Timestamp';
COMMENT ON COLUMN death_event.death_event_concept_identifier IS 'Foreign Key. A reference to the predefined concept identifier in the Standardized Vocabularies reflecting how the death was represented in the source data. Type: Integer';
COMMENT ON COLUMN death_event.deceased_person_identifier IS 'Foreign Key. A reference identifier to the deceased person. The demographic details of that person are stored in the person table. Type: Integer';

CREATE TABLE drug_ingredient_concentration (
    active_ingredient_unit_identifier INTEGER,
    active_ingredient_value NUMERIC,
    drug_box_size INTEGER,
    ingredient_concentration_denominator_unit_identifier INTEGER,
    ingredient_concentration_denominator_value NUMERIC,
    drug_identifier INTEGER,
    ingredient_identifier INTEGER,
    invalidation_reason VARCHAR(1),
    ingredient_concentration_numerator_unit_identifier INTEGER,
    ingredient_concentration_numerator_value NUMERIC,
    invalidation_date DATE,
    validity_start_date DATE
);

COMMENT ON TABLE drug_ingredient_concentration IS 'This table contains structured content about the amount or concentration and associated units of a specific ingredient contained within a particular drug product. This table is supplemental information to support standardized analysis of drug utilization.';
COMMENT ON COLUMN drug_ingredient_concentration.active_ingredient_unit_identifier IS 'Foreign Key. A reference to the Concept in the CONCEPT table representing the identifier for the Unit for the absolute amount of active ingredient.';
COMMENT ON COLUMN drug_ingredient_concentration.active_ingredient_value IS 'The numeric value associated with the amount of active ingredient contained within the product.';
COMMENT ON COLUMN drug_ingredient_concentration.drug_box_size IS 'The number of units of Clinical of Branded Drug, or Quantified Clinical or Branded Drug contained in a box as dispensed to the patient';
COMMENT ON COLUMN drug_ingredient_concentration.ingredient_concentration_denominator_unit_identifier IS 'Foreign Key. A reference to the Concept in the CONCEPT table representing the identifier for the denominator Unit for the concentration of active ingredient.';
COMMENT ON COLUMN drug_ingredient_concentration.ingredient_concentration_denominator_value IS 'The amount of total liquid (or other divisible product, such as ointment, gel, spray, etc.).';
COMMENT ON COLUMN drug_ingredient_concentration.drug_identifier IS 'Foreign Key. A reference to the Concept in the CONCEPT table representing the identifier for Branded Drug or Clinical Drug Concept.';
COMMENT ON COLUMN drug_ingredient_concentration.ingredient_identifier IS 'Foreign Key. A reference to the Concept in the CONCEPT table, representing the identifier for drug Ingredient Concept contained within the drug product.';
COMMENT ON COLUMN drug_ingredient_concentration.invalidation_reason IS 'Reason the concept was invalidated. Possible values are 'Deleted', 'Updated' or NULL when valid_end_date has the default value.';
COMMENT ON COLUMN drug_ingredient_concentration.ingredient_concentration_numerator_unit_identifier IS 'Foreign Key. A reference to the Concept in the CONCEPT table representing the identifier for the numerator Unit for the concentration of active ingredient.';
COMMENT ON COLUMN drug_ingredient_concentration.ingredient_concentration_numerator_value IS 'The numeric value associated with the concentration of the active ingredient contained in the product';
COMMENT ON COLUMN drug_ingredient_concentration.invalidation_date IS 'The date when the concept became invalid because it was deleted or superseded (updated) by a new Concept. The default value is 31-Dec-2099.';
COMMENT ON COLUMN drug_ingredient_concentration.validity_start_date IS 'The date when the Concept was first recorded. The default value is 1-Jan-1970.';

CREATE TABLE drug_period (
    active_ingredient_concept_identifier INTEGER,
    drug_period_end_date DATE,
    drug_period_identifier INTEGER,
    drug_period_start_date DATE,
    drug_exposure_occurrences INTEGER,
    uncovered_days INTEGER,
    person_identifier INTEGER
);

COMMENT ON TABLE drug_period IS 'This table contains drug era records for individuals, which are periods of assumed exposure to a particular active ingredient.';
COMMENT ON COLUMN drug_period.active_ingredient_concept_identifier IS 'Foreign Key. Refers to a Standard Concept identifier in the Standardized Vocabularies for the Ingredient Concept. Type: Integer';
COMMENT ON COLUMN drug_period.drug_period_end_date IS 'The end date for the drug period constructed from the individual instance of drug exposures. It is the end date of the final continuously recorded instance of utilization of a drug. Type: Date';
COMMENT ON COLUMN drug_period.drug_period_identifier IS 'Primary Key. A unique identifier for each drug period. Type: Integer';
COMMENT ON COLUMN drug_period.drug_period_start_date IS 'The start date for the drug period constructed from the individual instances of drug exposures. It is the start date of the very first chronologically recorded instance of conutilization of a drug. Type: Date';
COMMENT ON COLUMN drug_period.drug_exposure_occurrences IS 'The number of individual drug exposure occurrences used to construct the drug period. Type: Integer';
COMMENT ON COLUMN drug_period.uncovered_days IS 'The number of days that are not covered by drug exposure records that were used to make up the era record. Type: Integer';
COMMENT ON COLUMN drug_period.person_identifier IS 'Foreign Key. A reference to the person table, which contains demographic details of the person who is subjected to the drug during the drug period. Type: Integer';

CREATE TABLE drug_use (
    days_supply INTEGER,
    dose_unit VARCHAR(50),
    active_ingredient_concept_identifier INTEGER,
    end_date DATE,
    end_datetime TIMESTAMP,
    drug_use_identifier INTEGER,
    start_date DATE,
    start_datetime TIMESTAMP,
    source_concept_identifier INTEGER,
    source_code VARCHAR(50),
    record_type_concept_identifier INTEGER,
    batch_number VARCHAR(50),
    person_identifier INTEGER,
    provider_identifier INTEGER,
    quantity NUMERIC,
    refills INTEGER,
    route_concept_identifier INTEGER,
    route VARCHAR(50),
    prescription_directions TEXT,
    condition_stop_reason VARCHAR(20),
    known_end_date DATE,
    visit_detail_identifier INTEGER,
    visit_occurrence_identifier INTEGER
);

COMMENT ON TABLE drug_use IS 'This table stores records about the utilization of a Drug when ingested or otherwise introduced into the body. A Drug is a biochemical substance formulated in such a way that when administered to a person it will exert a certain physiological effect. Drugs include prescription and over-the-counter medicines, vaccines, and large-molecule biologic therapies. Radiological devices ingested or applied locally do not count as Drugs.';
COMMENT ON COLUMN drug_use.days_supply IS 'The number of days of supply of the medication as recorded in the original prescription or dispensing record. Type: Integer';
COMMENT ON COLUMN drug_use.dose_unit IS 'The information about the dose unit as detailed in the source. Type: Text';
COMMENT ON COLUMN drug_use.active_ingredient_concept_identifier IS 'Foreign Key. A reference to a Standard Concept identifier in the Standardized Vocabularies for the Drug concept. Type: Integer';
COMMENT ON COLUMN drug_use.end_date IS 'The end date for the current instance of Drug utilization. It is not available from all sources. Type: Date';
COMMENT ON COLUMN drug_use.end_datetime IS 'The end date and time for the current instance of Drug utilization. It is not available from all sources. Type: Timestamp';
COMMENT ON COLUMN drug_use.drug_use_identifier IS 'Primary Key. A system-generated unique identifier for each Drug utilization event. Type: Integer';
COMMENT ON COLUMN drug_use.start_date IS 'The start date for the current instance of Drug utilization. Valid entries include a start date of a prescription, the date a prescription was filled, or the date on which a Drug administration procedure was recorded. Type: Date';
COMMENT ON COLUMN drug_use.start_datetime IS 'The start date and time for the current instance of Drug utilization. Valid entries include a start date of a prescription, the date a prescription was filled, or the date on which a Drug administration procedure was recorded. Type: Timestamp';
COMMENT ON COLUMN drug_use.source_concept_identifier IS 'Foreign Key. A reference to a Drug Concept that refers to the code used in the source. Type: Integer';
COMMENT ON COLUMN drug_use.source_code IS 'The source code for the Drug as it appears in the source data. This code is mapped to a Standard Drug concept in the Standardized Vocabularies and the original code is, stored here for reference. Type: Text';
COMMENT ON COLUMN drug_use.record_type_concept_identifier IS 'Foreign Key. A reference to the predefined Concept identifier in the Standardized Vocabularies reflecting the type of Drug Exposure recorded. It indicates how the Drug Exposure was represented in the source data. Type: Integer';
COMMENT ON COLUMN drug_use.batch_number IS 'An identifier assigned to a particular quantity or lot of Drug product from the manufacturer. Type: Text';
COMMENT ON COLUMN drug_use.person_identifier IS 'Foreign Key. A reference to the person table. Type: Integer';
COMMENT ON COLUMN drug_use.provider_identifier IS 'Foreign Key. A reference to the provider table who initiated (prescribed or administered) the Drug Exposure. Type: Integer';
COMMENT ON COLUMN drug_use.quantity IS 'The quantity of the medication. Type: Numeric';
COMMENT ON COLUMN drug_use.refills IS 'The number of refills after the initial prescription. The initial prescription is not counted, values start with 0. Type: Integer';
COMMENT ON COLUMN drug_use.route_concept_identifier IS 'Foreign Key. A reference to a predefined concept in the Standardized Vocabularies reflecting the route of administration. Type: Integer';
COMMENT ON COLUMN drug_use.route IS 'The information about the route of administration as detailed in the source. Type: Text';
COMMENT ON COLUMN drug_use.prescription_directions IS 'The directions ("signetur") on the Drug prescription as recorded in the original prescription (and printed on the container) or dispensing record. Type: Text';
COMMENT ON COLUMN drug_use.condition_stop_reason IS 'The reason the Drug was stopped. Reasons include regimen completed, changed, removed, etc. Type: Text';
COMMENT ON COLUMN drug_use.known_end_date IS 'The known end date of a drug_use as provided by the source. Type: Date';
COMMENT ON COLUMN drug_use.visit_detail_identifier IS 'Foreign Key. A reference to the visit in the VISIT_DETAIL table during which the Drug Exposure was initiated. Type: Integer';
COMMENT ON COLUMN drug_use.visit_occurrence_identifier IS 'Foreign Key. A reference to the visit in the visit table during which the Drug Exposure was initiated. Type: Integer';

CREATE TABLE enrollment_period (
    family_code VARCHAR(50),
    payer_concept_identifier INTEGER,
    enrollment_period_end_date DATE,
    enrollment_period_identifier INTEGER,
    enrollment_period_start_date DATE,
    payer_source_concept_identifier INTEGER,
    payer_source_code VARCHAR(50),
    person_identifier INTEGER,
    plan_concept_identifier INTEGER,
    plan_source_concept_identifier INTEGER,
    plan_source_code VARCHAR(50),
    sponsor_concept_identifier INTEGER,
    sponsor_source_concept_identifier INTEGER,
    sponsor_source_code VARCHAR(50),
    stop_reason_concept_identifier INTEGER,
    stop_reason_source_concept_identifier INTEGER,
    stop_reason_source_code VARCHAR(50)
);

COMMENT ON TABLE enrollment_period IS 'This table captures details of the period of time that a Person is continuously enrolled under a specific health Plan benefit structure from a given Payer.';
COMMENT ON COLUMN enrollment_period.family_code IS 'The code for the Person's family as it appears in the source data. Type: Text';
COMMENT ON COLUMN enrollment_period.payer_concept_identifier IS 'The concept identifier for payer. Type: Integer';
COMMENT ON COLUMN enrollment_period.enrollment_period_end_date IS 'The end date of the enrollment period. Type: Date';
COMMENT ON COLUMN enrollment_period.enrollment_period_identifier IS 'Primary Key. An identifier for each unique combination of payer, plan, family code, and time span. Type: Integer';
COMMENT ON COLUMN enrollment_period.enrollment_period_start_date IS 'The start date of the enrollment period. Type: Date';
COMMENT ON COLUMN enrollment_period.payer_source_concept_identifier IS 'The source concept identifier for payer. Type: Integer';
COMMENT ON COLUMN enrollment_period.payer_source_code IS 'The source code for the payer as it appears in the source data. Type: Text';
COMMENT ON COLUMN enrollment_period.person_identifier IS 'Foreign Key. An identifier for the Person covered by the payer. The demographic details of that Person are stored in the PERSON table. Type: Integer';
COMMENT ON COLUMN enrollment_period.plan_concept_identifier IS 'The concept identifier for the health benefit plan. Type: Integer';
COMMENT ON COLUMN enrollment_period.plan_source_concept_identifier IS 'The source concept identifier for the health benefit plan. Type: Integer';
COMMENT ON COLUMN enrollment_period.plan_source_code IS 'The source code for the Person's health benefit plan as it appears in the source data. Type: Text';
COMMENT ON COLUMN enrollment_period.sponsor_concept_identifier IS 'The concept identifier for the sponsor. Type: Integer';
COMMENT ON COLUMN enrollment_period.sponsor_source_concept_identifier IS 'The source concept identifier for the sponsor. Type: Integer';
COMMENT ON COLUMN enrollment_period.sponsor_source_code IS 'The source code for the sponsor. Type: Text';
COMMENT ON COLUMN enrollment_period.stop_reason_concept_identifier IS 'The concept identifier for the stop reason. Type: Integer';
COMMENT ON COLUMN enrollment_period.stop_reason_source_concept_identifier IS 'The source concept identifier for the stop reason. Type: Integer';
COMMENT ON COLUMN enrollment_period.stop_reason_source_code IS 'The source code for the stop reason. Type: Text';

CREATE TABLE fact_association (
    fact_one_domain_concept_id INTEGER,
    fact_two_domain_concept_id INTEGER,
    fact_one_identifier INTEGER,
    fact_two_identifier INTEGER,
    relationship_concept_identifier INTEGER
);

COMMENT ON TABLE fact_association IS '[CLINICAL] This table contains records about the relationships between facts stored as records in any table of the CDM. Relationships can be defined between facts from the same domain (table), or different domains. Examples of Fact Relationships include: Person relationships (parent-child), care site relationships (hierarchical organizational structure of facilities within a health system), indication relationship (between drug exposures and associated conditions), usage relationships (of devices during the course of an associated procedure), or facts derived from one another (measurements derived from an associated specimen).';';
COMMENT ON COLUMN fact_association.fact_one_domain_concept_id IS 'Data Type: Integer. The concept representing the domain of fact one, from which the corresponding table can be inferred.';
COMMENT ON COLUMN fact_association.fact_two_domain_concept_id IS 'Data Type: Integer. The concept representing the domain of fact two, from which the corresponding table can be inferred.';
COMMENT ON COLUMN fact_association.fact_one_identifier IS 'Data Type: Integer. Primary Key. The unique identifier in the table corresponding to the domain of fact one.';
COMMENT ON COLUMN fact_association.fact_two_identifier IS 'Data Type: Integer. Primary Key. The unique identifier in the table corresponding to the domain of fact two.';
COMMENT ON COLUMN fact_association.relationship_concept_identifier IS 'Data Type: Integer. The unique identifier for the relationship concept.';

CREATE TABLE geographic_location (
    street_address VARCHAR(50),
    additional_address_details VARCHAR(50),
    city VARCHAR(50),
    country_concept_identifier INTEGER,
    country_source_value VARCHAR(80),
    county VARCHAR(20),
    latitude NUMERIC,
    geographic_location_identifier INTEGER,
    location_source_value VARCHAR(50),
    longitude NUMERIC,
    state_abbreviation VARCHAR(2),
    postal_code VARCHAR(9)
);

COMMENT ON TABLE geographic_location IS 'This table represents a generic way to capture physical location or address information of Persons and Care Sites.';
COMMENT ON COLUMN geographic_location.street_address IS 'The primary address line used for the street address. Type: Text';
COMMENT ON COLUMN geographic_location.additional_address_details IS 'Additional address details such as buildings, suites, or floors. Type: Text';
COMMENT ON COLUMN geographic_location.city IS 'The name of the city. Type: Text';
COMMENT ON COLUMN geographic_location.country_concept_identifier IS 'A foreign key reference to the concept table for the country. Type: Integer';
COMMENT ON COLUMN geographic_location.country_source_value IS 'The verbatim information for the country as it appears in the source data. Type: Text';
COMMENT ON COLUMN geographic_location.county IS 'The name of the county. Type: Text';
COMMENT ON COLUMN geographic_location.latitude IS 'The latitude of the geographic location. Type: Numeric';
COMMENT ON COLUMN geographic_location.geographic_location_identifier IS 'Primary Key. A unique identifier for each geographic location. Type: Integer';
COMMENT ON COLUMN geographic_location.location_source_value IS 'The verbatim information that is used to uniquely identify the location as it appears in the source data. Type: Text';
COMMENT ON COLUMN geographic_location.longitude IS 'The longitude of the geographic location. Type: Numeric';
COMMENT ON COLUMN geographic_location.state_abbreviation IS 'The abbreviation for the state as it appears in the source data. Type: Text';
COMMENT ON COLUMN geographic_location.postal_code IS 'The zip or postal code of the address. Type: Text';

CREATE TABLE healthcare_institution (
    healthcare_institution_identifier INTEGER,
    healthcare_institution_name VARCHAR(255),
    healthcare_institution_source_value VARCHAR(50),
    geographic_location_identifier INTEGER,
    place_of_service_concept_id INTEGER,
    place_of_service_source_value VARCHAR(50)
);

COMMENT ON TABLE healthcare_institution IS 'This table contains information on institutional units where healthcare delivery is practiced such as offices, wards, hospitals, clinics, etc.';
COMMENT ON COLUMN healthcare_institution.healthcare_institution_identifier IS 'Primary Key. A unique identifier for each healthcare institution. Type: Integer';
COMMENT ON COLUMN healthcare_institution.healthcare_institution_name IS 'The verbatim description or name of the healthcare institution as in data source. Type: Text';
COMMENT ON COLUMN healthcare_institution.healthcare_institution_source_value IS 'The identifier for the healthcare institution in the source data, stored here for reference. Type: Text';
COMMENT ON COLUMN healthcare_institution.geographic_location_identifier IS 'Foreign Key. A reference to the geographic Location in the LOCATION table, where the detailed address information is stored. Type: Integer';
COMMENT ON COLUMN healthcare_institution.place_of_service_concept_id IS 'Foreign Key. A reference to the Place of Service Concept ID in the Standardized Vocabularies. Type: Integer';
COMMENT ON COLUMN healthcare_institution.place_of_service_source_value IS 'The source code for the Place of Service as it appears in the source data, stored here for reference. Type: Text';

CREATE TABLE healthcare_provider (
    healthcare_institution_identifier INTEGER,
    drug_enforcement_administration_number VARCHAR(20),
    gender_concept_id INTEGER,
    gender_source_concept_id INTEGER,
    gender_source_value VARCHAR(50),
    national_provider_identifier VARCHAR(20),
    provider_identifier INTEGER,
    provider_description VARCHAR(255),
    provider_source_value VARCHAR(50),
    standard_specialty_concept_id INTEGER,
    specialty_source_concept_id INTEGER,
    specialty_source_value VARCHAR(50),
    year_of_birth INTEGER
);

COMMENT ON TABLE healthcare_provider IS 'This table contains information about healthcare providers such as physicians, nurses, midwives, and physical therapists.';
COMMENT ON COLUMN healthcare_provider.healthcare_institution_identifier IS 'Foreign Key. A reference to the main Care Site where the provider is practicing. Type: Integer';
COMMENT ON COLUMN healthcare_provider.drug_enforcement_administration_number IS 'The Drug Enforcement Administration (DEA) number of the provider. Type: Text';
COMMENT ON COLUMN healthcare_provider.gender_concept_id IS 'The gender of the Provider. Type: Integer';
COMMENT ON COLUMN healthcare_provider.gender_source_concept_id IS 'Foreign Key. A reference to a Concept that refers to the code used in the source. Type: Integer';
COMMENT ON COLUMN healthcare_provider.gender_source_value IS 'The gender code for the Provider as it appears in the source data, stored here for reference. Type: Text';
COMMENT ON COLUMN healthcare_provider.national_provider_identifier IS 'The National Provider Identifier (NPI) of the provider. Type: Text';
COMMENT ON COLUMN healthcare_provider.provider_identifier IS 'Primary Key. A unique identifier for each Provider. Type: Integer';
COMMENT ON COLUMN healthcare_provider.provider_description IS 'A description of the Provider. Type: Text';
COMMENT ON COLUMN healthcare_provider.provider_source_value IS 'The identifier used for the Provider in the source data, stored here for reference. Type: Text';
COMMENT ON COLUMN healthcare_provider.standard_specialty_concept_id IS 'Foreign Key. A reference to a Standard Specialty Concept ID in the Standardized Vocabularies. Type: Integer';
COMMENT ON COLUMN healthcare_provider.specialty_source_concept_id IS 'Foreign Key. A reference to a Concept that refers to the code used in the source. Type: Integer';
COMMENT ON COLUMN healthcare_provider.specialty_source_value IS 'The source code for the Provider specialty as it appears in the source data, stored here for reference. Type: Text';
COMMENT ON COLUMN healthcare_provider.year_of_birth IS 'The year of birth of the Provider. Type: Integer';

CREATE TABLE medical_entity_cost (
    contracted_amount NUMERIC,
    cost_domain_concept_id VARCHAR(20),
    event_identifier INTEGER,
    cost_identifier INTEGER,
    cost_type_concept_identifier INTEGER,
    currency_concept_identifier INTEGER,
    diagnosis_related_group_concept_identifier INTEGER,
    diagnosis_related_group_code VARCHAR(3),
    total_amount_paid_by_patient NUMERIC,
    total_amount_paid_by_payer NUMERIC,
    total_amount_paid_by_primary_payer NUMERIC,
    amount_paid_to_pharmacy_for_dispensing NUMERIC,
    amount_paid_to_pharmacy_for_drug NUMERIC,
    total_amount_paid_by_patient_for_coinsurance NUMERIC,
    total_amount_paid_by_patient_for_copay NUMERIC,
    total_amount_paid_by_patient_towards_deductible NUMERIC,
    payer_plan_period_identifier INTEGER,
    standard_concept_identifier_for_revenue_codes INTEGER,
    revenue_code_source_code VARCHAR(50),
    total_amount_charged NUMERIC,
    total_cost_incurred NUMERIC,
    total_amount_actually_paid NUMERIC
);

COMMENT ON TABLE medical_entity_cost IS 'This table captures the cost of any medical entity recorded in one of the DRUG_EXPOSURE, PROCEDURE_OCCURRENCE, VISIT_OCCURRENCE, DEVICE_OCCURRENCE, OBSERVATION or MEASUREMENT tables.';
COMMENT ON COLUMN medical_entity_cost.contracted_amount IS 'The contracted amount agreed between the payer and provider. Type: Numeric';
COMMENT ON COLUMN medical_entity_cost.cost_domain_concept_id IS 'The concept representing the domain of the cost event, from which the corresponding table can be inferred that contains the entity for which cost information is recorded. Type: Text';
COMMENT ON COLUMN medical_entity_cost.event_identifier IS 'Foreign Key. A reference to the event (e.g. Measurement, Procedure, Visit, Drug Exposure, etc) record for which cost data are recorded. Type: Integer';
COMMENT ON COLUMN medical_entity_cost.cost_identifier IS 'Primary Key. A unique identifier for each COST record. Type: Integer';
COMMENT ON COLUMN medical_entity_cost.cost_type_concept_identifier IS 'A foreign key identifier to a concept in the CONCEPT table for the provenance or the source of the COST data: Calculated from insurance claim information, provider revenue, calculated from cost-to-charge ratio, reported from accounting database, etc. Type: Integer';
COMMENT ON COLUMN medical_entity_cost.currency_concept_identifier IS 'A foreign key identifier to the concept representing the 3-letter code used to delineate international currencies, such as USD for US Dollar. Type: Integer';
COMMENT ON COLUMN medical_entity_cost.diagnosis_related_group_concept_identifier IS 'A foreign key to the predefined concept in the DRG Vocabulary reflecting the DRG for a visit. Type: Integer';
COMMENT ON COLUMN medical_entity_cost.diagnosis_related_group_code IS 'The 3-digit DRG source code as it appears in the source data. Type: Text';
COMMENT ON COLUMN medical_entity_cost.total_amount_paid_by_patient IS 'The total amount paid by the Person as a share of the expenses. Type: Numeric';
COMMENT ON COLUMN medical_entity_cost.total_amount_paid_by_payer IS 'The amount paid by the Payer for the goods or services. Type: Numeric';
COMMENT ON COLUMN medical_entity_cost.total_amount_paid_by_primary_payer IS 'The amount paid by a primary Payer through the coordination of benefits. Type: Numeric';
COMMENT ON COLUMN medical_entity_cost.amount_paid_to_pharmacy_for_dispensing IS 'The amount paid by the Payer to a pharmacy for dispensing a drug, excluding the amount paid for the drug ingredient. paid_dispensing_fee contributes to the paid_by_payer field if this field is populated with a nonzero value. Type: Numeric';
COMMENT ON COLUMN medical_entity_cost.amount_paid_to_pharmacy_for_drug IS 'The amount paid by the Payer to a pharmacy for the drug, excluding the amount paid for dispensing the drug.  paid_ingredient_cost contributes to the paid_by_payer field if this field is populated with a nonzero value. Type: Numeric';
COMMENT ON COLUMN medical_entity_cost.total_amount_paid_by_patient_for_coinsurance IS 'The amount paid by the Person as a joint assumption of risk. Typically, this is a percentage of the expenses defined by the Payer Plan after the Person''s deductible is exceeded. Type: Numeric';
COMMENT ON COLUMN medical_entity_cost.total_amount_paid_by_patient_for_copay IS 'The amount paid by the Person as a fixed contribution to the expenses. Type: Numeric';
COMMENT ON COLUMN medical_entity_cost.total_amount_paid_by_patient_towards_deductible IS 'The amount paid by the Person that is counted toward the deductible defined by the Payer Plan. paid_patient_deductible does contribute to the paid_by_patient variable. Type: Numeric';
COMMENT ON COLUMN medical_entity_cost.payer_plan_period_identifier IS 'Foreign Key. A reference to the PAYER_PLAN_PERIOD table, where the details of the Payer, Plan and Family are stored.  Record the payer_plan_id that relates to the payer who contributed to the paid_by_payer field. Type: Integer';
COMMENT ON COLUMN medical_entity_cost.standard_concept_identifier_for_revenue_codes IS 'A foreign key referring to a Standard Concept ID in the Standardized Vocabularies for Revenue codes. Type: Integer';
COMMENT ON COLUMN medical_entity_cost.revenue_code_source_code IS 'The source code for the Revenue code as it appears in the source data, stored here for reference. Type: Text';
COMMENT ON COLUMN medical_entity_cost.total_amount_charged IS 'The total amount charged by some provider of goods or services (e.g. hospital, physician pharmacy, dme provider) to payers (insurance companies, the patient). Type: Numeric';
COMMENT ON COLUMN medical_entity_cost.total_cost_incurred IS 'The cost incurred by the provider of goods or services. Type: Numeric';
COMMENT ON COLUMN medical_entity_cost.total_amount_actually_paid IS 'The total amount actually paid from all payers for goods or services of the provider. Type: Numeric';

CREATE TABLE medical_visit_record (
    admitting_source_concept_identifier INTEGER,
    admitting_source_source_value VARCHAR(50),
    healthcare_institution_identifier INTEGER,
    discharge_disposition_concept_identifier INTEGER,
    discharge_disposition_source_value VARCHAR(50),
    person_identifier INTEGER,
    preceding_visit_occurrence_identifier INTEGER,
    provider_identifier INTEGER,
    visit_concept_identifier INTEGER,
    visit_end_date DATE,
    visit_end_datetime TIMESTAMP,
    medical_visit_record_identifier INTEGER,
    visit_source_concept_identifier INTEGER,
    visit_source_source_value VARCHAR(50),
    visit_start_date DATE,
    visit_start_datetime TIMESTAMP,
    visit_type_concept_identifier INTEGER
);

COMMENT ON TABLE medical_visit_record IS 'This table stores information about the visits of a person to one or more healthcare providers in a given setting within the healthcare system. A visit can be classified into 4 different settings: outpatient care, inpatient confinement, emergency room, and long-term care.';
COMMENT ON COLUMN medical_visit_record.admitting_source_concept_identifier IS 'Foreign Key. A predefined concept identifier in the Place of Service Vocabulary used to reflect the admitting source for a visit. Type: Integer';
COMMENT ON COLUMN medical_visit_record.admitting_source_source_value IS 'The code for the admitting source as it appears in the source data. Type: Text';
COMMENT ON COLUMN medical_visit_record.healthcare_institution_identifier IS 'Foreign Key. An identifier to the care site in the care site table that was visited. Type: Integer';
COMMENT ON COLUMN medical_visit_record.discharge_disposition_concept_identifier IS 'Foreign Key. A predefined concept identifier in the Place of Service Vocabulary that reflects the discharge disposition for a visit. Type: Integer';
COMMENT ON COLUMN medical_visit_record.discharge_disposition_source_value IS 'The source code for the discharge disposition as it appears in the source data. Type: Text';
COMMENT ON COLUMN medical_visit_record.person_identifier IS 'Foreign Key. An identifier for the person for whom the visit is recorded. The demographic details of that person are stored in the PERSON table. Type: Integer';
COMMENT ON COLUMN medical_visit_record.preceding_visit_occurrence_identifier IS 'Foreign Key. A reference to the preceding visit occurrence identifier. Type: Integer';
COMMENT ON COLUMN medical_visit_record.provider_identifier IS 'Foreign Key. An identifier to the provider in the provider table who was associated with the visit. Type: Integer';
COMMENT ON COLUMN medical_visit_record.visit_concept_identifier IS 'Foreign Key. Refers to a visit Concept identifier in the Standardized Vocabularies. Type: Integer';
COMMENT ON COLUMN medical_visit_record.visit_end_date IS 'The end date of the visit. If this is a one-day visit the end date should match the start date. Type: Date';
COMMENT ON COLUMN medical_visit_record.visit_end_datetime IS 'The date and time of the visit end. Type: DateTime';
COMMENT ON COLUMN medical_visit_record.medical_visit_record_identifier IS 'Primary Key. A unique identifier for each person's visit or encounter at a healthcare provider. Type: Integer';
COMMENT ON COLUMN medical_visit_record.visit_source_concept_identifier IS 'Foreign Key. Refers to the code used in the source to identify the concept. Type: Integer';
COMMENT ON COLUMN medical_visit_record.visit_source_source_value IS 'The source code for the visit as it appears in the source data. Type: Text';
COMMENT ON COLUMN medical_visit_record.visit_start_date IS 'The start date of the visit. Type: Date';
COMMENT ON COLUMN medical_visit_record.visit_start_datetime IS 'The date and time of the visit start. Type: DateTime';
COMMENT ON COLUMN medical_visit_record.visit_type_concept_identifier IS 'Foreign Key. A predefined concept identifier in the Standardized Vocabularies reflecting the type of source data from which the visit record is derived. Type: Integer';

CREATE TABLE omop_domain (
    domain_concept_identifier INTEGER,
    domain_identifier VARCHAR(20),
    domain_category VARCHAR(255)
);

COMMENT ON TABLE omop_domain IS 'This table lists the OMOP-defined domains to which concepts of the standardized vocabularies can belong to. A domain defines the set of allowable concepts for the standardized fields in the CDM tables, e.g. the Condition domain contains concepts that describe a patient's condition stored in condition_concept_id field of the CONDITION_OCCURRENCE and CONDITION_ERA tables. This reference table is populated with a single record for each domain and includes a descriptive name for the domain.';
COMMENT ON COLUMN omop_domain.domain_concept_identifier IS 'Foreign Key. An integer that refers to an identifier in the CONCEPT table for the unique domain concept the domain record belongs to. Type: Integer';
COMMENT ON COLUMN omop_domain.domain_identifier IS 'Primary Key. A unique key for each domain. Type: Text';
COMMENT ON COLUMN omop_domain.domain_category IS 'The category name describing the domain, e.g. "Condition", "Procedure", "Measurement" etc. Type: Text';

CREATE TABLE patient_notes (
    encoding_type INTEGER,
    language_identifier INTEGER,
    note_class_type INTEGER,
    note_date DATE,
    note_datetime TIMESTAMP,
    note_event_field_type INTEGER,
    note_event_identifier INTEGER,
    note_identifier INTEGER,
    note_source_value VARCHAR(50),
    note_content TEXT,
    note_title VARCHAR(250),
    note_type INTEGER,
    person_identifier INTEGER,
    provider_identifier INTEGER,
    visit_detail_identifier INTEGER,
    visit_occurrence_identifier INTEGER
);

COMMENT ON TABLE patient_notes IS 'This table captures unstructured information that was recorded by a provider about a patient in free text notes on a given date.';
COMMENT ON COLUMN patient_notes.encoding_type IS 'Data Type: Integer';
COMMENT ON COLUMN patient_notes.language_identifier IS 'Data Type: Integer';
COMMENT ON COLUMN patient_notes.note_class_type IS 'Data Type: Integer. A foreign key to the predefined Concept in the Standardized Vocabularies reflecting the HL7 LOINC Document Type Vocabulary classification of the note.';
COMMENT ON COLUMN patient_notes.note_date IS 'Data Type: Date';
COMMENT ON COLUMN patient_notes.note_datetime IS 'Data Type: Timestamp. The date and time the note was recorded.';
COMMENT ON COLUMN patient_notes.note_event_field_type IS 'Data Type: Integer';
COMMENT ON COLUMN patient_notes.note_event_identifier IS 'Data Type: Integer';
COMMENT ON COLUMN patient_notes.note_identifier IS 'Primary Key. Data Type: Integer. A unique identifier for each note.';
COMMENT ON COLUMN patient_notes.note_source_value IS 'Data Type: Text. The source value associated with the origin of the note';
COMMENT ON COLUMN patient_notes.note_content IS 'Data Type: Text. The content of the Note.';
COMMENT ON COLUMN patient_notes.note_title IS 'Data Type: Text';
COMMENT ON COLUMN patient_notes.note_type IS 'Data Type: Integer. A foreign key to the predefined Concept in the Standardized Vocabularies reflecting the type, origin or provenance of the Note.';
COMMENT ON COLUMN patient_notes.person_identifier IS 'Data Type: Integer. A foreign key identifier to the Person about whom the Note was recorded. The demographic details of that Person are stored in the PERSON table.';
COMMENT ON COLUMN patient_notes.provider_identifier IS 'Data Type: Integer. A foreign key to the Provider in the PROVIDER table who took the Note.';
COMMENT ON COLUMN patient_notes.visit_detail_identifier IS 'Data Type: Integer';
COMMENT ON COLUMN patient_notes.visit_occurrence_identifier IS 'Data Type: Integer. Foreign key to the Visit in the VISIT_OCCURRENCE table when the Note was taken.';

CREATE TABLE person_information (
    date_of_birth TIMESTAMP,
    healthcare_institution_identifier INTEGER,
    day_of_birth INTEGER,
    ethnicity_concept_id INTEGER,
    ethnicity_source_concept_id INTEGER,
    ethnicity_source_value VARCHAR(50),
    gender_concept_id INTEGER,
    gender_source_concept_id INTEGER,
    gender_source_value VARCHAR(50),
    geographic_location_identifier INTEGER,
    month_of_birth INTEGER,
    person_identifier INTEGER,
    person_source_value VARCHAR(50),
    provider_identifier INTEGER,
    race_concept_id INTEGER,
    race_source_concept_id INTEGER,
    race_source_value VARCHAR(50),
    year_of_birth INTEGER
);

COMMENT ON TABLE person_information IS 'This table contains personal information for each patient in the source data who is time at-risk to have clinical observations recorded within the source systems.';
COMMENT ON COLUMN person_information.date_of_birth IS 'The date and time of birth of the person. Data Type: Timestamp';
COMMENT ON COLUMN person_information.healthcare_institution_identifier IS 'Foreign Key. A reference to the site of primary care in the healthcare_institution table, where the details of the healthcare institution are stored. Data Type: Integer';
COMMENT ON COLUMN person_information.day_of_birth IS 'The day of the month of birth of the person. For data sources that provide the precise date of birth, the day is extracted and stored in this field. Data Type: Integer';
COMMENT ON COLUMN person_information.ethnicity_concept_id IS 'Foreign Key. A reference to the standard concept identifier in the Standardized Vocabularies for the ethnicity of the person. Data Type: Integer';
COMMENT ON COLUMN person_information.ethnicity_source_concept_id IS 'Foreign Key. A reference to the ethnicity concept that refers to the code used in the source. Data Type: Integer';
COMMENT ON COLUMN person_information.ethnicity_source_value IS 'The source code for the ethnicity of the person as it appears in the source data. The person ethnicity is mapped to a standard ethnicity concept in the Standardized Vocabularies and the original code is, stored here for reference. Data Type: Text';
COMMENT ON COLUMN person_information.gender_concept_id IS 'Foreign Key. A reference to an identifier in the CONCEPT table for the unique gender of the person. Data Type: Integer';
COMMENT ON COLUMN person_information.gender_source_concept_id IS 'Foreign Key. A reference to the gender concept that refers to the code used in the source. Data Type: Integer';
COMMENT ON COLUMN person_information.gender_source_value IS 'The source code for the gender of the person as it appears in the source data. The person’s gender is mapped to a standard gender concept in the Standardized Vocabularies; the original value is stored here for reference. Data Type: Text';
COMMENT ON COLUMN person_information.geographic_location_identifier IS 'Foreign Key. A reference to the place of residency for the person in the geographic_location table, where the detailed address information is stored. Data Type: Integer';
COMMENT ON COLUMN person_information.month_of_birth IS 'The month of birth of the person. For data sources that provide the precise date of birth, the month is extracted and stored in this field. Data Type: Integer';
COMMENT ON COLUMN person_information.person_identifier IS 'Primary Key. A unique identifier for each person. Data Type: Integer';
COMMENT ON COLUMN person_information.person_source_value IS 'An (encrypted) key derived from the person identifier in the source data. This is necessary when a use case requires a link back to the person data at the source dataset. Data Type: Text';
COMMENT ON COLUMN person_information.provider_identifier IS 'Foreign Key. A reference to the primary care provider the person is seeing in the provider table. Data Type: Integer';
COMMENT ON COLUMN person_information.race_concept_id IS 'Foreign Key. A reference to an identifier in the CONCEPT table for the unique race of the person. Data Type: Integer';
COMMENT ON COLUMN person_information.race_source_concept_id IS 'Foreign Key. A reference to the race concept that refers to the code used in the source. Data Type: Integer';
COMMENT ON COLUMN person_information.race_source_value IS 'The source code for the race of the person as it appears in the source data. The person race is mapped to a standard race concept in the Standardized Vocabularies and the original value is stored here for reference. Data Type: Text';
COMMENT ON COLUMN person_information.year_of_birth IS 'The year of birth of the person. Data Type: Integer';

CREATE TABLE physical_devices (
    device_concept_identifier INTEGER,
    device_exposure_end_date DATE,
    device_exposure_end_datetime TIMESTAMP,
    device_exposure_identifier INTEGER,
    device_exposure_start_date DATE,
    device_exposure_start_datetime TIMESTAMP,
    device_source_concept_identifier INTEGER,
    device_source_value VARCHAR(50),
    device_type_concept_identifier INTEGER,
    person_identifier INTEGER,
    production_identifier VARCHAR(255),
    provider_identifier INTEGER,
    quantity INTEGER,
    unique_device_identifier VARCHAR(255),
    unit_concept_identifier INTEGER,
    unit_source_concept_identifier INTEGER,
    unit_source_value VARCHAR(50),
    visit_detail_identifier INTEGER,
    visit_occurrence_identifier INTEGER
);

COMMENT ON TABLE physical_devices IS 'This table contains details of a person's exposure to physical devices used for diagnostic or therapeutic purposes.';
COMMENT ON COLUMN physical_devices.device_concept_identifier IS 'Foreign Key. A reference to the standardized concept identifier in the standardized vocabulary for the device concept. Type: Integer';
COMMENT ON COLUMN physical_devices.device_exposure_end_date IS 'The date the physical device was removed from use. Type: Date';
COMMENT ON COLUMN physical_devices.device_exposure_end_datetime IS 'The date and time the physical device was removed from use. Type: Timestamp';
COMMENT ON COLUMN physical_devices.device_exposure_identifier IS 'Primary Key. A system-generated unique identifier for each physical device exposure. Type: Integer';
COMMENT ON COLUMN physical_devices.device_exposure_start_date IS 'The date the physical device was applied or used. Type: Date';
COMMENT ON COLUMN physical_devices.device_exposure_start_datetime IS 'The date and time the physical device was applied or used. Type: Timestamp';
COMMENT ON COLUMN physical_devices.device_source_concept_identifier IS 'Foreign Key. A reference to the device concept that refers to the code used in the source. Type: Integer';
COMMENT ON COLUMN physical_devices.device_source_value IS 'The source code for the device as it appears in the source data. This code is mapped to a standard device concept in the standardized vocabularies and the original code is stored here for reference. Type: Text';
COMMENT ON COLUMN physical_devices.device_type_concept_identifier IS 'Foreign Key. A reference to the standardized concept identifier in the standardized vocabularies reflecting the type of device exposure recorded. It indicates how the device exposure was represented in the source data. Type: Integer';
COMMENT ON COLUMN physical_devices.person_identifier IS 'Foreign Key. A reference to the person table. Type: Integer';
COMMENT ON COLUMN physical_devices.production_identifier IS 'Production identifier. Type: Text';
COMMENT ON COLUMN physical_devices.provider_identifier IS 'Foreign Key. A reference to the provider in the provider table who initiated or administered the device. Type: Integer';
COMMENT ON COLUMN physical_devices.quantity IS 'The number of individual physical devices used for the exposure. Type: Integer';
COMMENT ON COLUMN physical_devices.unique_device_identifier IS 'Unique device identifier. Type: Text';
COMMENT ON COLUMN physical_devices.unit_concept_identifier IS 'Foreign Key. A reference to the predefined concept identifier in the standardized vocabularies reflecting the unit of the physical device exposure. Type: Integer';
COMMENT ON COLUMN physical_devices.unit_source_concept_identifier IS 'Foreign Key. A reference to the unit concept that refers to the code used in the source. Type: Integer';
COMMENT ON COLUMN physical_devices.unit_source_value IS 'The source value for the unit as it appears in the source data. Type: Text';
COMMENT ON COLUMN physical_devices.visit_detail_identifier IS 'Foreign Key. A reference to the visit in the visit-detail table during which the physical device exposure was initiated. Type: Integer';
COMMENT ON COLUMN physical_devices.visit_occurrence_identifier IS 'Foreign Key. A reference to the visit in the visit table during which the physical device was used. Type: Integer';

CREATE TABLE procedure_record (
    modifier INTEGER,
    modifier_source VARCHAR(50),
    person_identifier INTEGER,
    procedure_concept INTEGER,
    procedure_date DATE,
    procedure_datetime TIMESTAMP,
    procedure_end_date DATE,
    procedure_end_datetime TIMESTAMP,
    procedure_occurrence_identifier INTEGER,
    procedure_source_concept INTEGER,
    procedure_source VARCHAR(50),
    procedure_type_concept INTEGER,
    provider_identifier INTEGER,
    quantity INTEGER,
    visit_detail_identifier INTEGER,
    visit_occurrence_identifier INTEGER
);

COMMENT ON TABLE procedure_record IS 'This table contains records of activities or processes ordered by, or carried out by, a healthcare provider on the patient to have a diagnostic or therapeutic purpose.';
COMMENT ON COLUMN procedure_record.modifier IS 'Foreign Key. A reference to a Standard Concept identifier for a modifier to the Procedure (e.g. bilateral). Type: Integer';
COMMENT ON COLUMN procedure_record.modifier_source IS 'The source code for the qualifier as it appears in the source data. Type: Text';
COMMENT ON COLUMN procedure_record.person_identifier IS 'Foreign Key. A reference to the Person who is subjected to the Procedure. Type: Integer';
COMMENT ON COLUMN procedure_record.procedure_concept IS 'Foreign Key. A reference to a standard procedure Concept identifier in the Standardized Vocabularies. Type: Integer';
COMMENT ON COLUMN procedure_record.procedure_date IS 'The date on which the Procedure was performed. Type: Date';
COMMENT ON COLUMN procedure_record.procedure_datetime IS 'The date and time on which the Procedure was performed. Type: Timestamp';
COMMENT ON COLUMN procedure_record.procedure_end_date IS 'The date on which the Procedure ended. Type: Date';
COMMENT ON COLUMN procedure_record.procedure_end_datetime IS 'The date and time on which the Procedure ended. Type: Timestamp';
COMMENT ON COLUMN procedure_record.procedure_occurrence_identifier IS 'Primary Key. A system-generated unique identifier for each Procedure Occurrence. Type: Integer';
COMMENT ON COLUMN procedure_record.procedure_source_concept IS 'Foreign Key. A reference to a Procedure Concept that refers to the code used in the source. Type: Integer';
COMMENT ON COLUMN procedure_record.procedure_source IS 'The source code for the Procedure as it appears in the source data. This code is mapped to a standard procedure Concept in the Standardized Vocabularies and the original code is, stored here for reference. Procedure source codes are typically ICD-9-Proc, CPT-4, HCPCS or OPCS-4 codes. Type: Text';
COMMENT ON COLUMN procedure_record.procedure_type_concept IS 'Foreign Key. A reference to a predefined Concept identifier in the Standardized Vocabularies reflecting the type of source data from which the procedure record is derived. Type: Integer';
COMMENT ON COLUMN procedure_record.provider_identifier IS 'Foreign Key. A reference to the provider in the provider table who was responsible for carrying out the procedure. Type: Integer';
COMMENT ON COLUMN procedure_record.quantity IS 'The quantity of procedures ordered or administered. Type: Integer';
COMMENT ON COLUMN procedure_record.visit_detail_identifier IS 'Foreign Key. A reference to the visit in the visit table during which the Procedure was carried out. Type: Integer';
COMMENT ON COLUMN procedure_record.visit_occurrence_identifier IS 'Foreign Key. A reference to the visit in the visit table during which the Procedure was carried out. Type: Integer';

CREATE TABLE source_code_mapping (
    invalidation_reason VARCHAR(1),
    source_code VARCHAR(50),
    source_code_description VARCHAR(255),
    source_concept_identifier INTEGER,
    source_vocabulary_identifier VARCHAR(20),
    target_concept_identifier INTEGER,
    target_vocabulary_identifier VARCHAR(20),
    invalidation_date DATE,
    validity_start_date DATE
);

COMMENT ON TABLE source_code_mapping IS 'This table contains mappings of source codes to standardized concepts in the OMOP Common Data Model. Recommended for use in ETL processes to maintain local source codes which are not available as Concepts in the Standardized Vocabularies, and to establish mappings for each source code into a Standard Concept. The SOURCE_TO_CONCEPT_MAP table is no longer populated with content within the Standardized Vocabularies published to the OMOP community.';';
COMMENT ON COLUMN source_code_mapping.invalidation_reason IS 'Reason the mapping instance was invalidated. Possible values are Deleted (D), Replaced with an update (U) or NULL when validity_end_date has the default value. Data Type: Text';
COMMENT ON COLUMN source_code_mapping.source_code IS 'The source code being translated into a Standard Concept. Data Type: Text';
COMMENT ON COLUMN source_code_mapping.source_code_description IS 'An optional description for the source code. This is included as a convenience to compare the description of the source code to the name of the concept. Data Type: Text';
COMMENT ON COLUMN source_code_mapping.source_concept_identifier IS 'Foreign Key. A reference to the Source Concept that is being translated into a Standard Concept. Data Type: Integer';
COMMENT ON COLUMN source_code_mapping.source_vocabulary_identifier IS 'Foreign Key. A reference to the VOCABULARY table defining the vocabulary of the source code that is being translated to a Standard Concept. Data Type: Text';
COMMENT ON COLUMN source_code_mapping.target_concept_identifier IS 'Foreign Key. A reference to the target Concept to which the source code is being mapped. Data Type: Integer';
COMMENT ON COLUMN source_code_mapping.target_vocabulary_identifier IS 'Foreign Key. A reference to the VOCABULARY table defining the vocabulary of the target Concept. Data Type: Text';
COMMENT ON COLUMN source_code_mapping.invalidation_date IS 'The date when the mapping instance became invalid because it was deleted or superseded (updated) by a new relationship. Default value is 31-Dec-2099. Data Type: Date';
COMMENT ON COLUMN source_code_mapping.validity_start_date IS 'The date when the mapping instance was first recorded. Data Type: Date';

CREATE TABLE source_info (
    etl_reference VARCHAR(255),
    organization_name VARCHAR(255),
    instance_release_date DATE,
    source_abbreviation VARCHAR(25),
    source_name VARCHAR(255),
    cdm_version VARCHAR(10),
    cdm_version_concept_id INTEGER,
    source_data_description TEXT,
    source_documentation_reference VARCHAR(255),
    source_release_date DATE,
    vocabulary_version VARCHAR(20)
);

COMMENT ON TABLE source_info IS 'This table contains details about the data source and the process used to transform the data into the OMOP Common Data Model.';
COMMENT ON COLUMN source_info.etl_reference IS 'URL or external reference to the location of ETL specification documentation and ETL source code. Type: Text';
COMMENT ON COLUMN source_info.organization_name IS 'The name of the organization responsible for the development of the CDM instance. Type: Text';
COMMENT ON COLUMN source_info.instance_release_date IS 'The date when the CDM was instantiated. Type: Date';
COMMENT ON COLUMN source_info.source_abbreviation IS 'An abbreviation of the data source name. Type: Text';
COMMENT ON COLUMN source_info.source_name IS 'The full name of the data source. Type: Text';
COMMENT ON COLUMN source_info.cdm_version IS 'The version of the Common Data Model used. Type: Text';
COMMENT ON COLUMN source_info.cdm_version_concept_id IS 'Concept ID for Common Data Model version. Type: Integer';
COMMENT ON COLUMN source_info.source_data_description IS 'A description of the source data origin and purpose for collection. Type: Text';
COMMENT ON COLUMN source_info.source_documentation_reference IS 'URL or external reference to the location of source documentation. Type: Text';
COMMENT ON COLUMN source_info.source_release_date IS 'The date for which the source data are most current, such as the last day of data capture. Type: Date';
COMMENT ON COLUMN source_info.vocabulary_version IS 'The version of the vocabulary used. Type: Text';

CREATE TABLE source_vocabulary (
    standard_concept_identifier INTEGER,
    vocabulary_identifier VARCHAR(20),
    vocabulary_description VARCHAR(255),
    vocabulary_documentation VARCHAR(255),
    vocabulary_version VARCHAR(255)
);

COMMENT ON TABLE source_vocabulary IS 'This reference table contains information about the vocabularies collected from various sources or created de novo by the OMOP community.';
COMMENT ON COLUMN source_vocabulary.standard_concept_identifier IS 'Foreign Key. A reference to a standard concept identifier in the CONCEPT table for the Vocabulary the record belongs to. Type: Integer';
COMMENT ON COLUMN source_vocabulary.vocabulary_identifier IS 'Unique identifier for each Vocabulary, such as International Classification of Diseases, Ninth Revision, Clinical Modification, Volume 1 and 2 (NCHS), SNOMED, Visit. Type: Text';
COMMENT ON COLUMN source_vocabulary.vocabulary_description IS 'The name describing the vocabulary. Type: Text';
COMMENT ON COLUMN source_vocabulary.vocabulary_documentation IS 'External reference to documentation or available download of the about the vocabulary. Type: Text';
COMMENT ON COLUMN source_vocabulary.vocabulary_version IS 'Version of the Vocabulary as indicated in the source. Type: Text';

CREATE TABLE standardized_vocabularies (
    classification_id VARCHAR(20),
    vocabulary_code VARCHAR(50),
    concept_identifier INTEGER,
    concept_description VARCHAR(255),
    domain_identifier VARCHAR(20),
    invalidation_reason VARCHAR(1),
    is_standard_concept VARCHAR(1),
    invalidation_date DATE,
    validity_start_date DATE,
    vocabulary_identifier VARCHAR(20)
);

COMMENT ON TABLE standardized_vocabularies IS 'This table contains standardized vocabularies, which represent clinical information across various domains, through the use of codes and associated descriptions. It contains standard and non-standard concepts and their details across all domains.';
COMMENT ON COLUMN standardized_vocabularies.classification_id IS 'The attribute or concept class of the Concept. Examples are 'Clinical Drug', 'Ingredient', 'Clinical Finding', etc. Type: Text';
COMMENT ON COLUMN standardized_vocabularies.vocabulary_code IS 'The vocabulary code represents the identifier of the Concept in the source vocabulary, such as SNOMED-CT concept IDs, RxNorm RXCUIs, etc. Note that vocabulary codes are not unique across vocabularies. Type: Text';
COMMENT ON COLUMN standardized_vocabularies.concept_identifier IS 'Primary Key. A unique identifier for each Concept across all domains. Type: Integer';
COMMENT ON COLUMN standardized_vocabularies.concept_description IS 'An unambiguous, meaningful and descriptive name for the Concept. Type: Text';
COMMENT ON COLUMN standardized_vocabularies.domain_identifier IS 'Foreign Key. A reference to the DOMAIN table the Concept belongs to. Type: Text';
COMMENT ON COLUMN standardized_vocabularies.invalidation_reason IS 'Reason the Concept was invalidated. Possible values are 'Deleted', 'Replaced with an update' or NULL when valid_end_date has the default value. Type: Text';
COMMENT ON COLUMN standardized_vocabularies.is_standard_concept IS 'This flag determines whether a Concept is a Standard Concept, i.e. is used in the data, a Classification Concept, or a non-standard Source Concept. The allowable values are 'Standard Concept' and 'Classification Concept', otherwise the content is NULL. Type: Text';
COMMENT ON COLUMN standardized_vocabularies.invalidation_date IS 'The date when the Concept became invalid because it was deleted or superseded (updated) by a new concept. The default value is 31-Dec-2099, meaning, the Concept is valid until it becomes deprecated. Type: Date';
COMMENT ON COLUMN standardized_vocabularies.validity_start_date IS 'The date when the Concept was first recorded. The default value is 1-Jan-1970, meaning, the Concept has no (known) date of inception. Type: Date';
COMMENT ON COLUMN standardized_vocabularies.vocabulary_identifier IS 'Foreign Key. A reference to the VOCABULARY table indicating from which source the Concept has been adapted. Type: Text';

CREATE TABLE structured_measurement (
    measurement_event_field_concept_identifier INTEGER,
    measurement_concept_identifier INTEGER,
    measurement_date DATE,
    measurement_datetime TIMESTAMP,
    measurement_event_identifier INTEGER,
    measurement_identifier INTEGER,
    measurement_source_concept_identifier INTEGER,
    measurement_source_value VARCHAR(50),
    measurement_time VARCHAR(10),
    measurement_type_concept_identifier INTEGER,
    operator_concept_identifier INTEGER,
    person_identifier INTEGER,
    provider_identifier INTEGER,
    measurement_normal_range_upper NUMERIC,
    measurement_normal_range_lower NUMERIC,
    measurement_unit_concept_identifier INTEGER,
    unit_source_concept_identifier INTEGER,
    unit_source_value VARCHAR(50),
    measurement_value_as_concept_identifier INTEGER,
    measurement_value_as_number NUMERIC,
    measurement_value_source_value VARCHAR(50),
    visit_detail_identifier INTEGER,
    visit_occurrence_identifier INTEGER
);

COMMENT ON TABLE structured_measurement IS 'This table contains structured values obtained through systematic and standardized examination or testing of a Person or Person''s sample. It contains both orders and results of such Measurements as laboratory tests, vital signs, quantitative findings from pathology reports, etc.';
COMMENT ON COLUMN structured_measurement.measurement_event_field_concept_identifier IS 'A foreign key to the Concept identifier in the Standardized Vocabularies.';
COMMENT ON COLUMN structured_measurement.measurement_concept_identifier IS 'Foreign Key. A foreign key to the Standard measurement concept identifier in the Standardized Vocabularies.';
COMMENT ON COLUMN structured_measurement.measurement_date IS 'The date of the Measurement.';
COMMENT ON COLUMN structured_measurement.measurement_datetime IS 'The date and time of the Measurement. Some database systems don''t have a datatype of time. To accomodate all temporal analyses, datatype datetime can be used.';
COMMENT ON COLUMN structured_measurement.measurement_event_identifier IS 'A foreign key to the event identifier for each Measurement.';
COMMENT ON COLUMN structured_measurement.measurement_identifier IS 'Primary Key. A unique identifier for each Measurement.';
COMMENT ON COLUMN structured_measurement.measurement_source_concept_identifier IS 'A foreign key to a Concept in the Standard Vocabularies that refers to the code used in the source.';
COMMENT ON COLUMN structured_measurement.measurement_source_value IS 'The Measurement name as it appears in the source data. This code is mapped to a Standard Concept in the Standardized Vocabularies and the original code is stored here for reference.';
COMMENT ON COLUMN structured_measurement.measurement_time IS 'the time of the Measurement. ';
COMMENT ON COLUMN structured_measurement.measurement_type_concept_identifier IS 'A foreign key to the predefined Concept in the Standardized Vocabularies reflecting the provenance from where the Measurement record was recorded.';
COMMENT ON COLUMN structured_measurement.operator_concept_identifier IS 'A foreign key identifier to the predefined Concept in the Standardized Vocabularies reflecting the mathematical operator that is applied to the value_as_number.';
COMMENT ON COLUMN structured_measurement.person_identifier IS 'A foreign key identifier to the Person about whom the structured measurement was recorded. The demographic details of that Person are stored in the PERSON table.';
COMMENT ON COLUMN structured_measurement.provider_identifier IS 'A foreign key to the provider in the PROVIDER table who was responsible for initiating or obtaining the structured measurement.';
COMMENT ON COLUMN structured_measurement.measurement_normal_range_upper IS 'The upper limit of the normal range of the Measurement. The upper range is assumed to be of the same unit of measure as the Measurement value.';
COMMENT ON COLUMN structured_measurement.measurement_normal_range_lower IS 'The lower limit of the normal range of the Measurement result. The lower range is assumed to be of the same unit of measure as the Measurement value.';
COMMENT ON COLUMN structured_measurement.measurement_unit_concept_identifier IS 'A foreign key to a Standard Concept ID of Measurement Units in the Standardized Vocabularies.';
COMMENT ON COLUMN structured_measurement.unit_source_concept_identifier IS 'A foreign key to the source Concept ID of Measurement Units in the Standard Vocabularies.';
COMMENT ON COLUMN structured_measurement.unit_source_value IS 'The source code for the unit as it appears in the source data. This code is mapped to a standard unit concept in the Standardized Vocabularies and the original code is stored here for reference.';
COMMENT ON COLUMN structured_measurement.measurement_value_as_concept_identifier IS 'A foreign key to a Measurement result represented as a Concept from the Standardized Vocabularies (e.g., positive/negative, present/absent, low/high, etc.).';
COMMENT ON COLUMN structured_measurement.measurement_value_as_number IS 'A Measurement result where the result is expressed as a numeric value.';
COMMENT ON COLUMN structured_measurement.measurement_value_source_value IS 'The source value associated with the content of the value_as_number or value_as_concept_id as stored in the source data.';
COMMENT ON COLUMN structured_measurement.visit_detail_identifier IS 'A foreign key to the Visit in the VISIT_DETAIL table during which the Measurement was recorded.';
COMMENT ON COLUMN structured_measurement.visit_occurrence_identifier IS 'A foreign key to the Visit in the VISIT_OCCURRENCE table during which the Measurement was recorded.';

CREATE TABLE subject_cohort (
    cohort_definition_identifier INTEGER,
    cohort_end_date DATE,
    cohort_start_date DATE,
    subject_identifier INTEGER
);

COMMENT ON TABLE subject_cohort IS 'This table contains records of subjects that satisfy a given set of criteria for a duration of time. The definition of the cohort is contained within the cohort definition table. Cohorts can be constructed of persons, providers or visit occurrences.';
COMMENT ON COLUMN subject_cohort.cohort_definition_identifier IS 'Foreign Key. A reference to a record in the cohort definition table containing relevant cohort definition information. Type: Integer';
COMMENT ON COLUMN subject_cohort.cohort_end_date IS 'The date when the cohort definition criteria for the person, provider or visit no longer match or the cohort membership was terminated. Type: Date';
COMMENT ON COLUMN subject_cohort.cohort_start_date IS 'The date when the cohort definition criteria for the person, provider or visit first match. Type: Date';
COMMENT ON COLUMN subject_cohort.subject_identifier IS 'Foreign Key. A reference to the subject in the cohort. These could be referring to records in the person, provider, or visit occurrence table. Type: Integer';

CREATE TABLE subject_cohort_definition (
    cohort_description TEXT,
    cohort_definition_identifier INTEGER,
    cohort_short_description VARCHAR(255),
    cohort_definition_syntax TEXT,
    cohort_initiation_date DATE,
    cohort_definition_type_concept_id INTEGER,
    subject_concept_identifier INTEGER
);

COMMENT ON TABLE subject_cohort_definition IS 'This table contains records defining a Cohort and provides a standardized structure for maintaining the rules governing the inclusion of a subject into a cohort.';
COMMENT ON COLUMN subject_cohort_definition.cohort_description IS 'A complete description of the Cohort definition. Type: Text';
COMMENT ON COLUMN subject_cohort_definition.cohort_definition_identifier IS 'Primary Key. A unique identifier for each Cohort. Type: Integer';
COMMENT ON COLUMN subject_cohort_definition.cohort_short_description IS 'A short description of the Cohort. Type: Text';
COMMENT ON COLUMN subject_cohort_definition.cohort_definition_syntax IS 'Syntax or code to operationalize the Cohort definition. Type: Text';
COMMENT ON COLUMN subject_cohort_definition.cohort_initiation_date IS 'A date to indicate when the Cohort was initiated in the COHORT table. Type: Date';
COMMENT ON COLUMN subject_cohort_definition.cohort_definition_type_concept_id IS 'Type defining what kind of Cohort Definition the record represents and how the syntax may be executed. Type: Integer';
COMMENT ON COLUMN subject_cohort_definition.subject_concept_identifier IS 'Foreign Key. A reference to the Concept table representing the domain of subjects that are members of the cohort (e.g., Person, Provider, Visit). Type: Integer';

CREATE TABLE visit_detail_information (
    admitted_from_concept_identifier INTEGER,
    admitted_from_source_value VARCHAR(50),
    healthcare_institution_identifier INTEGER,
    discharge_disposition_concept_identifier INTEGER,
    discharge_disposition_source_value VARCHAR(50),
    parent_visit_detail_identifier INTEGER,
    person_identifier INTEGER,
    preceding_visit_detail_identifier INTEGER,
    provider_identifier INTEGER,
    visit_concept_identifier INTEGER,
    visit_end_date DATE,
    visit_end_datetime TIMESTAMP,
    visit_detail_identifier INTEGER,
    visit_source_concept_identifier INTEGER,
    visit_source_value VARCHAR(50),
    visit_start_date DATE,
    visit_start_datetime TIMESTAMP,
    visit_type_concept_identifier INTEGER,
    visit_occurrence_identifier INTEGER
);

COMMENT ON TABLE visit_detail_information IS 'This table contains details of each visit record in the parent visit_occurrence table.';
COMMENT ON COLUMN visit_detail_information.admitted_from_concept_identifier IS 'Type: Integer';
COMMENT ON COLUMN visit_detail_information.admitted_from_source_value IS 'Type: Text';
COMMENT ON COLUMN visit_detail_information.healthcare_institution_identifier IS 'Foreign Key. A reference to the care site table that was visited. Type: Integer';
COMMENT ON COLUMN visit_detail_information.discharge_disposition_concept_identifier IS 'Foreign Key. A reference to the Place of Service Vocabulary reflecting the discharge disposition for a visit. Type: Integer';
COMMENT ON COLUMN visit_detail_information.discharge_disposition_source_value IS 'The source code for the discharge disposition as it appears in the source data. Type: Text';
COMMENT ON COLUMN visit_detail_information.parent_visit_detail_identifier IS 'Type: Integer';
COMMENT ON COLUMN visit_detail_information.person_identifier IS 'Foreign Key. A reference to the person table. Type: Integer';
COMMENT ON COLUMN visit_detail_information.preceding_visit_detail_identifier IS 'Type: Integer';
COMMENT ON COLUMN visit_detail_information.provider_identifier IS 'Foreign Key. A reference to the provider table who was associated with the visit. Type: Integer';
COMMENT ON COLUMN visit_detail_information.visit_concept_identifier IS 'Foreign Key. A reference to a visit Concept identifier in the Standardized Vocabularies. Type: Integer';
COMMENT ON COLUMN visit_detail_information.visit_end_date IS 'The end date of the visit. If this is a one-day visit the end date should match the start date. Type: Date';
COMMENT ON COLUMN visit_detail_information.visit_end_datetime IS 'The date and time of the visit end. Type: Timestamp';
COMMENT ON COLUMN visit_detail_information.visit_detail_identifier IS 'Primary Key. A unique identifier for each Person''s visit or encounter at a healthcare provider. Type: Integer';
COMMENT ON COLUMN visit_detail_information.visit_source_concept_identifier IS 'Foreign Key. A reference to a Concept that refers to the code used in the source. Type: Integer';
COMMENT ON COLUMN visit_detail_information.visit_source_value IS 'The source code for the visit as it appears in the source data. Type: Text';
COMMENT ON COLUMN visit_detail_information.visit_start_date IS 'The start date of the visit. Type: Date';
COMMENT ON COLUMN visit_detail_information.visit_start_datetime IS 'The date and time of the visit started. Type: Timestamp';
COMMENT ON COLUMN visit_detail_information.visit_type_concept_identifier IS 'Foreign Key. A reference to the predefined Concept identifier in the Standardized Vocabularies reflecting the type of source data from which the visit record is derived. Type: Integer';
COMMENT ON COLUMN visit_detail_information.visit_occurrence_identifier IS 'Foreign Key. A reference to the parent visit_occurrence table. Type: Integer';

CREATE TABLE vocabulary_synonym (
    concept_identifier INTEGER,
    synonym VARCHAR(1000),
    language_identifier INTEGER
);

COMMENT ON TABLE vocabulary_synonym IS 'This table stores alternative names and descriptions for concepts in different vocabularies.';
COMMENT ON COLUMN vocabulary_synonym.concept_identifier IS 'Foreign Key. A reference to the concept table. Data Type: Integer.';
COMMENT ON COLUMN vocabulary_synonym.synonym IS 'The alternative name for the concept. Data Type: Text';
COMMENT ON COLUMN vocabulary_synonym.language_identifier IS 'Foreign Key. A reference to the concept representing the language used in the synonym. Data Type: Integer.';