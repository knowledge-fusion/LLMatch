CREATE TABLE care_site (
    care_site_id INTEGER,
    care_site_name VARCHAR(255),
    care_site_source_value VARCHAR(50),
    location_id INTEGER,
    place_of_service_concept_id INTEGER,
    place_of_service_source_value VARCHAR(50)
);

COMMENT ON TABLE care_site IS '[SYSTEM] The CARE_SITE table contains a list of uniquely identified institutional (physical or organizational) units where healthcare delivery is practiced (offices, wards, hospitals, clinics, etc.).';';
COMMENT ON COLUMN care_site.care_site_id IS 'A unique identifier for each Care Site.';
COMMENT ON COLUMN care_site.care_site_name IS 'The verbatim description or name of the Care Site as in data source';
COMMENT ON COLUMN care_site.care_site_source_value IS 'The identifier for the Care Site in the source data, stored here for reference.';
COMMENT ON COLUMN care_site.location_id IS 'A foreign key to the geographic Location in the LOCATION table, where the detailed address information is stored.';
COMMENT ON COLUMN care_site.place_of_service_concept_id IS 'A foreign key that refers to a Place of Service Concept ID in the Standardized Vocabularies.';
COMMENT ON COLUMN care_site.place_of_service_source_value IS 'The source code for the Place of Service as it appears in the source data, stored here for reference.';

CREATE TABLE cdm_source (
    cdm_etl_reference VARCHAR(255),
    cdm_holder VARCHAR(255),
    cdm_release_date DATE,
    cdm_source_abbreviation VARCHAR(25),
    cdm_source_name VARCHAR(255),
    cdm_version VARCHAR(10),
    cdm_version_concept_id INTEGER,
    source_description TEXT,
    source_documentation_reference VARCHAR(255),
    source_release_date DATE,
    vocabulary_version VARCHAR(20)
);

COMMENT ON TABLE cdm_source IS 'The CDM_SOURCE table contains detail about the source database and the process used to transform the data into the OMOP Common Data Model.';';
COMMENT ON COLUMN cdm_source.cdm_etl_reference IS 'Version of the ETL script used. e.g. link to the Git release.';
COMMENT ON COLUMN cdm_source.cdm_holder IS 'The holder of the CDM instance.';
COMMENT ON COLUMN cdm_source.cdm_release_date IS 'The date the ETL script was completed. Typically this is after the source_release_date.';
COMMENT ON COLUMN cdm_source.cdm_source_abbreviation IS 'The abbreviation of the CDM instance.';
COMMENT ON COLUMN cdm_source.cdm_source_name IS 'The name of the CDM instance.';
COMMENT ON COLUMN cdm_source.cdm_version IS 'Version of the OMOP CDM used as string. e.g. v5.4.';
COMMENT ON COLUMN cdm_source.cdm_version_concept_id IS 'The Concept Id representing the version of the CDM. You can find all concepts that represent the CDM versions using the query: SELECT * FROM CONCEPT WHERE VOCABULARY_ID = "CDM" AND CONCEPT_CLASS = "CDM".';
COMMENT ON COLUMN cdm_source.source_description IS 'The description of the CDM instance.';
COMMENT ON COLUMN cdm_source.source_documentation_reference IS 'The reference documentation for the source database.';
COMMENT ON COLUMN cdm_source.source_release_date IS 'The date the data was extracted from the source system. In some systems that is the same as the date the ETL was run. Typically the latest even date in the source is on the source_release_date.';
COMMENT ON COLUMN cdm_source.vocabulary_version IS 'Version of the OMOP standardised vocabularies loaded. You can find the version of your Vocabulary using the query: SELECT vocabulary_version from vocabulary where vocabulary_id = "None".';

CREATE TABLE cohort (
    cohort_definition_id INTEGER,
    cohort_end_date DATE,
    cohort_start_date DATE,
    subject_id INTEGER
);

COMMENT ON TABLE cohort IS '[DERIVED] The COHORT table contains records of subjects that satisfy a given set of criteria for a duration of time. The definition of the cohort is contained within the COHORT_DEFINITION table. Cohorts can be constructed of patients (Persons), Providers or Visits.';';
COMMENT ON COLUMN cohort.cohort_definition_id IS 'A foreign key to a record in the COHORT_DEFINITION table containing relevant Cohort Definition information.';
COMMENT ON COLUMN cohort.cohort_end_date IS 'The date when the Cohort Definition criteria for the Person, Provider or Visit no longer match or the Cohort membership was terminated.';
COMMENT ON COLUMN cohort.cohort_start_date IS 'The date when the Cohort Definition criteria for the Person, Provider or Visit first match.';
COMMENT ON COLUMN cohort.subject_id IS 'A foreign key to the subject in the cohort. These could be referring to records in the PERSON, PROVIDER, VISIT_OCCURRENCE table.';

CREATE TABLE cohort_definition (
    cohort_definition_description TEXT,
    cohort_definition_id INTEGER,
    cohort_definition_name VARCHAR(255),
    cohort_definition_syntax TEXT,
    cohort_initiation_date DATE,
    definition_type_concept_id INTEGER,
    subject_concept_id INTEGER
);

COMMENT ON TABLE cohort_definition IS '[VOCABULARY] The COHORT_DEFINITION table contains records defining a Cohort derived from the data through the associated description and syntax and upon instantiation (execution of the algorithm) placed into the COHORT table. Cohorts are a set of subjects that satisfy a given combination of inclusion criteria for a duration of time. The COHORT_DEFINITION table provides a standardized structure for maintaining the rules governing the inclusion of a subject into a cohort, and can store operational programming code to instantiate the cohort within the OMOP Common Data Model.';';
COMMENT ON COLUMN cohort_definition.cohort_definition_description IS 'A complete description of the Cohort definition';
COMMENT ON COLUMN cohort_definition.cohort_definition_id IS 'A unique identifier for each Cohort.';
COMMENT ON COLUMN cohort_definition.cohort_definition_name IS 'A short description of the Cohort.';
COMMENT ON COLUMN cohort_definition.cohort_definition_syntax IS 'Syntax or code to operationalize the Cohort definition';
COMMENT ON COLUMN cohort_definition.cohort_initiation_date IS 'A date to indicate when the Cohort was initiated in the COHORT table';
COMMENT ON COLUMN cohort_definition.definition_type_concept_id IS 'Type defining what kind of Cohort Definition the record represents and how the syntax may be executed';
COMMENT ON COLUMN cohort_definition.subject_concept_id IS 'A foreign key to the Concept to which defines the domain of subjects that are members of the cohort (e.g., Person, Provider, Visit).';

CREATE TABLE concept (
    concept_class_id VARCHAR(20),
    concept_code VARCHAR(50),
    concept_id INTEGER,
    concept_name VARCHAR(255),
    domain_id VARCHAR(20),
    invalid_reason VARCHAR(1),
    standard_concept VARCHAR(1),
    valid_end_date DATE,
    valid_start_date DATE,
    vocabulary_id VARCHAR(20)
);

COMMENT ON TABLE concept IS '[VOCABULARY] The primary purpose of the CONCEPT table is to provide a standardized representation of medical Concepts, allowing for consistent querying and analysis across the healthcare databases. Users can join the CONCEPT table with other tables in the CDM to enrich clinical data with standardized Concept information or use the CONCEPT table as a reference for mapping clinical data from source terminologies to Standard Concepts.';';
COMMENT ON COLUMN concept.concept_class_id IS 'The attribute or concept class of the Concept. Examples are ';
COMMENT ON COLUMN concept.concept_code IS 'The concept code represents the identifier of the Concept in the source vocabulary, such as SNOMED-CT concept IDs, RxNorm RXCUIs etc. Note that concept codes are not unique across vocabularies.';
COMMENT ON COLUMN concept.concept_id IS 'A unique identifier for each Concept across all domains.';
COMMENT ON COLUMN concept.concept_name IS 'An unambiguous, meaningful and descriptive name for the Concept.';
COMMENT ON COLUMN concept.domain_id IS 'A foreign key to the [DOMAIN](https://github.com/OHDSI/CommonDataModel/wiki/DOMAIN) table the Concept belongs to.';
COMMENT ON COLUMN concept.invalid_reason IS 'Reason the Concept was invalidated. Possible values are D (deleted), U (replaced with an update) or NULL when valid_end_date has the default value.';
COMMENT ON COLUMN concept.standard_concept IS 'This flag determines where a Concept is a Standard Concept, i.e. is used in the data, a Classification Concept, or a non-standard Source Concept. The allowables values are ';
COMMENT ON COLUMN concept.valid_end_date IS 'The date when the Concept became invalid because it was deleted or superseded (updated) by a new concept. The default value is 31-Dec-2099, meaning, the Concept is valid until it becomes deprecated.';
COMMENT ON COLUMN concept.valid_start_date IS 'The date when the Concept was first recorded. The default value is 1-Jan-1970, meaning, the Concept has no (known) date of inception.';
COMMENT ON COLUMN concept.vocabulary_id IS 'A foreign key to the [VOCABULARY](https://github.com/OHDSI/CommonDataModel/wiki/VOCABULARY) table indicating from which source the Concept has been adapted.';

CREATE TABLE concept_ancestor (
    ancestor_concept_id INTEGER,
    descendant_concept_id INTEGER,
    max_levels_of_separation INTEGER,
    min_levels_of_separation INTEGER
);

COMMENT ON TABLE concept_ancestor IS '[VOCABULARY] The CONCEPT_ANCESTOR table is designed to simplify observational analysis by providing the complete hierarchical relationships between Concepts. Only direct parent-child relationships between Concepts are stored in the CONCEPT_RELATIONSHIP table. To determine higher level ancestry connections, all individual direct relationships would have to be navigated at analysis time. The CONCEPT_ANCESTOR table includes records for all parent-child relationships, as well as grandparent-grandchild relationships and those of any other level of lineage. Using the CONCEPT_ANCESTOR table allows for querying for all descendants of a hierarchical concept. For example, drug ingredients and drug products are all descendants of a drug class ancestor.';';
COMMENT ON COLUMN concept_ancestor.ancestor_concept_id IS 'A foreign key to the concept in the concept table for the higher-level concept that forms the ancestor in the relationship.';
COMMENT ON COLUMN concept_ancestor.descendant_concept_id IS 'A foreign key to the concept in the concept table for the lower-level concept that forms the descendant in the relationship.';
COMMENT ON COLUMN concept_ancestor.max_levels_of_separation IS 'The maximum separation in number of levels of hierarchy between ancestor and descendant concepts. This is an attribute that is used to simplify hierarchic analysis.';
COMMENT ON COLUMN concept_ancestor.min_levels_of_separation IS 'The minimum separation in number of levels of hierarchy between ancestor and descendant concepts. This is an attribute that is used to simplify hierarchic analysis.';

CREATE TABLE concept_class (
    concept_class_concept_id INTEGER,
    concept_class_id VARCHAR(20),
    concept_class_name VARCHAR(255)
);

COMMENT ON TABLE concept_class IS '[VOCABULARY] The CONCEPT_CLASS table is a reference table, which includes a list of the classifications used to differentiate Concepts within a given Vocabulary. This reference table is populated with a single record for each Concept Class:';';
COMMENT ON COLUMN concept_class.concept_class_concept_id IS 'A foreign key that refers to an identifier in the [CONCEPT](https://github.com/OHDSI/CommonDataModel/wiki/CONCEPT) table for the unique Concept Class the record belongs to.';
COMMENT ON COLUMN concept_class.concept_class_id IS 'A unique key for each class.';
COMMENT ON COLUMN concept_class.concept_class_name IS 'The name describing the Concept Class, e.g. "Clinical Finding", "Ingredient", etc.';

CREATE TABLE concept_relationship (
    concept_id_1 INTEGER,
    concept_id_2 INTEGER,
    invalid_reason VARCHAR(1),
    relationship_id VARCHAR(20),
    valid_end_date DATE,
    valid_start_date DATE
);

COMMENT ON TABLE concept_relationship IS '[VOCABULARY] The CONCEPT_RELATIONSHIP table contains records that define direct relationships between any two Concepts and the nature or type of the relationship. Each type of a relationship is defined in the [RELATIONSHIP](https://github.com/OHDSI/CommonDataModel/wiki/RELATIONSHIP) table.';';
COMMENT ON COLUMN concept_relationship.concept_id_1 IS 'A foreign key to a Concept in the [CONCEPT](https://github.com/OHDSI/CommonDataModel/wiki/CONCEPT) table associated with the relationship. Relationships are directional, and this field represents the source concept designation.';
COMMENT ON COLUMN concept_relationship.concept_id_2 IS 'A foreign key to a Concept in the [CONCEPT](https://github.com/OHDSI/CommonDataModel/wiki/CONCEPT) table associated with the relationship. Relationships are directional, and this field represents the destination concept designation.';
COMMENT ON COLUMN concept_relationship.invalid_reason IS 'Reason the relationship was invalidated. Possible values are ';
COMMENT ON COLUMN concept_relationship.relationship_id IS 'A unique identifier to the type or nature of the Relationship as defined in the [RELATIONSHIP](https://github.com/OHDSI/CommonDataModel/wiki/RELATIONSHIP) table.';
COMMENT ON COLUMN concept_relationship.valid_end_date IS 'The date when the Concept Relationship became invalid because it was deleted or superseded (updated) by a new relationship. Default value is 31-Dec-2099.';
COMMENT ON COLUMN concept_relationship.valid_start_date IS 'The date when the instance of the Concept Relationship is first recorded.';

CREATE TABLE concept_synonym (
    concept_id INTEGER,
    concept_synonym_name VARCHAR(1000),
    language_concept_id INTEGER
);

COMMENT ON TABLE concept_synonym IS '[VOCABULARY] The CONCEPT_SYNONYM table is used to store alternate names and descriptions for Concepts.';';
COMMENT ON COLUMN concept_synonym.concept_id IS 'A foreign key to the Concept in the CONCEPT table.';
COMMENT ON COLUMN concept_synonym.concept_synonym_name IS 'The alternative name for the Concept.';
COMMENT ON COLUMN concept_synonym.language_concept_id IS 'A foreign key to a Concept representing the language.';

CREATE TABLE condition_era (
    condition_concept_id INTEGER,
    condition_era_end_date DATE,
    condition_era_id INTEGER,
    condition_era_start_date DATE,
    condition_occurrence_count INTEGER,
    person_id INTEGER
);

COMMENT ON TABLE condition_era IS '[DERIVED] A Condition Era is defined as a span of time when the Person is assumed to have a given condition.';';
COMMENT ON COLUMN condition_era.condition_concept_id IS 'A foreign key that refers to a standard Condition Concept identifier in the Standardized Vocabularies.';
COMMENT ON COLUMN condition_era.condition_era_end_date IS 'The end date for the Condition Era constructed from the individual instances of Condition Occurrences. It is the end date of the final continuously recorded instance of the Condition.';
COMMENT ON COLUMN condition_era.condition_era_id IS 'A unique identifier for each Condition Era.';
COMMENT ON COLUMN condition_era.condition_era_start_date IS 'The start date for the Condition Era constructed from the individual instances of Condition Occurrences. It is the start date of the very first chronologically recorded instance of the condition.';
COMMENT ON COLUMN condition_era.condition_occurrence_count IS 'The number of individual Condition Occurrences used to construct the condition era.';
COMMENT ON COLUMN condition_era.person_id IS 'A foreign key identifier to the Person who is experiencing the Condition during the Condition Era. The demographic details of that Person are stored in the PERSON table.';

CREATE TABLE condition_occurrence (
    condition_concept_id INTEGER,
    condition_end_date DATE,
    condition_end_datetime TIMESTAMP,
    condition_occurrence_id INTEGER,
    condition_source_concept_id INTEGER,
    condition_source_value VARCHAR(50),
    condition_start_date DATE,
    condition_start_datetime TIMESTAMP,
    condition_status_concept_id INTEGER,
    condition_status_source_value VARCHAR(50),
    condition_type_concept_id INTEGER,
    person_id INTEGER,
    provider_id INTEGER,
    stop_reason VARCHAR(20),
    visit_detail_id INTEGER,
    visit_occurrence_id INTEGER
);

COMMENT ON TABLE condition_occurrence IS '[CLINICAL] Conditions are records of a Person suggesting the presence of a disease or medical condition stated as a diagnosis, a sign or a symptom, which is either observed by a Provider or reported by the patient. Conditions are recorded in different sources and levels of standardization, for example:';';
COMMENT ON COLUMN condition_occurrence.condition_concept_id IS 'A foreign key that refers to a Standard Condition Concept identifier in the Standardized Vocabularies.';
COMMENT ON COLUMN condition_occurrence.condition_end_date IS 'The date when the instance of the Condition is considered to have ended.';
COMMENT ON COLUMN condition_occurrence.condition_end_datetime IS 'The date when the instance of the Condition is considered to have ended.';
COMMENT ON COLUMN condition_occurrence.condition_occurrence_id IS 'A unique identifier for each Condition Occurrence event.';
COMMENT ON COLUMN condition_occurrence.condition_source_concept_id IS 'A foreign key to a Condition Concept that refers to the code used in the source.';
COMMENT ON COLUMN condition_occurrence.condition_source_value IS 'The source code for the condition as it appears in the source data. This code is mapped to a standard condition concept in the Standardized Vocabularies and the original code is stored here for reference.';
COMMENT ON COLUMN condition_occurrence.condition_start_date IS 'The date when the instance of the Condition is recorded.';
COMMENT ON COLUMN condition_occurrence.condition_start_datetime IS 'The date and time when the instance of the Condition is recorded.';
COMMENT ON COLUMN condition_occurrence.condition_status_concept_id IS 'A foreign key to the predefined concept in the standard vocabulary reflecting the condition status';
COMMENT ON COLUMN condition_occurrence.condition_status_source_value IS 'The source code for the condition status as it appears in the source data.';
COMMENT ON COLUMN condition_occurrence.condition_type_concept_id IS 'A foreign key to the predefined Concept identifier in the Standardized Vocabularies reflecting the source data from which the condition was recorded, the level of standardization, and the type of occurrence.';
COMMENT ON COLUMN condition_occurrence.person_id IS 'A foreign key identifier to the Person who is experiencing the condition. The demographic details of that Person are stored in the PERSON table.';
COMMENT ON COLUMN condition_occurrence.provider_id IS 'A foreign key to the Provider in the PROVIDER table who was responsible for capturing (diagnosing) the Condition.';
COMMENT ON COLUMN condition_occurrence.stop_reason IS 'The reason that the condition was no longer present, as indicated in the source data.';
COMMENT ON COLUMN condition_occurrence.visit_detail_id IS 'A foreign key to the visit in the VISIT_DETAIL table during which the Condition was determined (diagnosed).';
COMMENT ON COLUMN condition_occurrence.visit_occurrence_id IS 'A foreign key to the visit in the VISIT_OCCURRENCE table during which the Condition was determined (diagnosed).';

CREATE TABLE cost (
    amount_allowed NUMERIC,
    cost_domain_id VARCHAR(20),
    cost_event_id INTEGER,
    cost_id INTEGER,
    cost_type_concept_id INTEGER,
    currency_concept_id INTEGER,
    drg_concept_id INTEGER,
    drg_source_value VARCHAR(3),
    paid_by_patient NUMERIC,
    paid_by_payer NUMERIC,
    paid_by_primary NUMERIC,
    paid_dispensing_fee NUMERIC,
    paid_ingredient_cost NUMERIC,
    paid_patient_coinsurance NUMERIC,
    paid_patient_copay NUMERIC,
    paid_patient_deductible NUMERIC,
    payer_plan_period_id INTEGER,
    revenue_code_concept_id INTEGER,
    revenue_code_source_value VARCHAR(50),
    total_charge NUMERIC,
    total_cost NUMERIC,
    total_paid NUMERIC
);

COMMENT ON TABLE cost IS '[ECONOMIC] The COST table captures records containing the cost of any medical entity recorded in one of the DRUG_EXPOSURE, PROCEDURE_OCCURRENCE, VISIT_OCCURRENCE or DEVICE_OCCURRENCE tables. It replaces the corresponding DRUG_COST, PROCEDURE_COST, VISIT_COST or DEVICE_COST tables that were initially defined for the OMOP CDM V5. However, it also allows to capture cost information for records of the OBSERVATION and MEASUREMENT tables.';';
COMMENT ON COLUMN cost.amount_allowed IS 'The contracted amount agreed between the payer and provider.';
COMMENT ON COLUMN cost.cost_domain_id IS 'The concept representing the domain of the cost event, from which the corresponding table can be inferred that contains the entity for which cost information is recorded.';
COMMENT ON COLUMN cost.cost_event_id IS 'A foreign key identifier to the event (e.g. Measurement, Procedure, Visit, Drug Exposure, etc) record for which cost data are recorded.';
COMMENT ON COLUMN cost.cost_id IS 'A unique identifier for each COST record.';
COMMENT ON COLUMN cost.cost_type_concept_id IS 'A foreign key identifier to a concept in the CONCEPT table for the provenance or the source of the COST data: Calculated from insurance claim information, provider revenue, calculated from cost-to-charge ratio, reported from accounting database, etc.';
COMMENT ON COLUMN cost.currency_concept_id IS 'A foreign key identifier to the concept representing the 3-letter code used to delineate international currencies, such as USD for US Dollar.';
COMMENT ON COLUMN cost.drg_concept_id IS 'A foreign key to the predefined concept in the DRG Vocabulary reflecting the DRG for a visit.';
COMMENT ON COLUMN cost.drg_source_value IS 'The 3-digit DRG source code as it appears in the source data.';
COMMENT ON COLUMN cost.paid_by_patient IS 'The total amount paid by the Person as a share of the expenses.';
COMMENT ON COLUMN cost.paid_by_payer IS 'The amount paid by the Payer for the goods or services.';
COMMENT ON COLUMN cost.paid_by_primary IS 'The amount paid by a primary Payer through the coordination of benefits.';
COMMENT ON COLUMN cost.paid_dispensing_fee IS 'The amount paid by the Payer to a pharmacy for dispensing a drug, excluding the amount paid for the drug ingredient. paid_dispensing_fee contributes to the paid_by_payer field if this field is populated with a nonzero value.';
COMMENT ON COLUMN cost.paid_ingredient_cost IS 'The amount paid by the Payer to a pharmacy for the drug, excluding the amount paid for dispensing the drug. paid_ingredient_cost contributes to the paid_by_payer field if this field is populated with a nonzero value.';
COMMENT ON COLUMN cost.paid_patient_coinsurance IS 'The amount paid by the Person as a joint assumption of risk. Typically, this is a percentage of the expenses defined by the Payer Plan after the Person';
COMMENT ON COLUMN cost.paid_patient_copay IS 'The amount paid by the Person as a fixed contribution to the expenses.';
COMMENT ON COLUMN cost.paid_patient_deductible IS 'The amount paid by the Person that is counted toward the deductible defined by the Payer Plan. paid_patient_deductible does contribute to the paid_by_patient variable.';
COMMENT ON COLUMN cost.payer_plan_period_id IS 'A foreign key to the PAYER_PLAN_PERIOD table, where the details of the Payer, Plan and Family are stored. Record the payer_plan_id that relates to the payer who contributed to the paid_by_payer field.';
COMMENT ON COLUMN cost.revenue_code_concept_id IS 'A foreign key referring to a Standard Concept ID in the Standardized Vocabularies for Revenue codes.';
COMMENT ON COLUMN cost.revenue_code_source_value IS 'The source code for the Revenue code as it appears in the source data, stored here for reference.';
COMMENT ON COLUMN cost.total_charge IS 'The total amount charged by some provider of goods or services (e.g. hospital, physician pharmacy, dme provider) to payers (insurance companies, the patient).';
COMMENT ON COLUMN cost.total_cost IS 'The cost incurred by the provider of goods or services.';
COMMENT ON COLUMN cost.total_paid IS 'The total amount actually paid from all payers for goods or services of the provider.';

CREATE TABLE death (
    cause_concept_id INTEGER,
    cause_source_concept_id INTEGER,
    cause_source_value VARCHAR(50),
    death_date DATE,
    death_datetime TIMESTAMP,
    death_type_concept_id INTEGER,
    person_id INTEGER
);

COMMENT ON TABLE death IS '[CLINICAL] The death domain contains the clinical event for how and when a Person dies. A person can have up to one record if the source system contains evidence about the Death, such as:';';
COMMENT ON COLUMN death.cause_concept_id IS 'A foreign key referring to a standard concept identifier in the Standardized Vocabularies for conditions.';
COMMENT ON COLUMN death.cause_source_concept_id IS 'A foreign key to the concept that refers to the code used in the source. Note, this variable name is abbreviated to ensure it will be allowable across database platforms.';
COMMENT ON COLUMN death.cause_source_value IS 'The source code for the cause of death as it appears in the source data. This code is mapped to a standard concept in the Standardized Vocabularies and the original code is, stored here for reference.';
COMMENT ON COLUMN death.death_date IS 'The date the person was deceased. If the precise date including day or month is not known or not allowed, December is used as the default month, and the last day of the month the default day.';
COMMENT ON COLUMN death.death_datetime IS 'The date and time the person was deceased. If the precise date including day or month is not known or not allowed, December is used as the default month, and the last day of the month the default day.';
COMMENT ON COLUMN death.death_type_concept_id IS 'A foreign key referring to the predefined concept identifier in the Standardized Vocabularies reflecting how the death was represented in the source data.';
COMMENT ON COLUMN death.person_id IS 'A foreign key identifier to the deceased person. The demographic details of that person are stored in the person table.';

CREATE TABLE device_exposure (
    device_concept_id INTEGER,
    device_exposure_end_date DATE,
    device_exposure_end_datetime TIMESTAMP,
    device_exposure_id INTEGER,
    device_exposure_start_date DATE,
    device_exposure_start_datetime TIMESTAMP,
    device_source_concept_id INTEGER,
    device_source_value VARCHAR(50),
    device_type_concept_id INTEGER,
    person_id INTEGER,
    production_id VARCHAR(255),
    provider_id INTEGER,
    quantity INTEGER,
    unique_device_id VARCHAR(255),
    unit_concept_id INTEGER,
    unit_source_concept_id INTEGER,
    unit_source_value VARCHAR(50),
    visit_detail_id INTEGER,
    visit_occurrence_id INTEGER
);

COMMENT ON TABLE device_exposure IS '[CLINICAL] The device exposure domain captures information about a person''s exposure to a foreign physical object or instrument that which is used for diagnostic or therapeutic purposes through a mechanism beyond chemical action. Devices include implantable objects (e.g. pacemakers, stents, artificial joints), medical equipment and supplies (e.g. bandages, crutches, syringes), other instruments used in medical procedures (e.g. sutures, defibrillators) and material used in clinical care (e.g. adhesives, body material, dental material, surgical material).';';
COMMENT ON COLUMN device_exposure.device_concept_id IS 'A foreign key that refers to a Standard Concept identifier in the Standardized Vocabularies for the Device concept.';
COMMENT ON COLUMN device_exposure.device_exposure_end_date IS 'The date the Device or supply was removed from use.';
COMMENT ON COLUMN device_exposure.device_exposure_end_datetime IS 'The date and time the Device or supply was removed from use.';
COMMENT ON COLUMN device_exposure.device_exposure_id IS 'A system-generated unique identifier for each Device Exposure.';
COMMENT ON COLUMN device_exposure.device_exposure_start_date IS 'The date the Device or supply was applied or used.';
COMMENT ON COLUMN device_exposure.device_exposure_start_datetime IS 'The date and time the Device or supply was applied or used.';
COMMENT ON COLUMN device_exposure.device_source_concept_id IS 'A foreign key to a Device Concept that refers to the code used in the source.';
COMMENT ON COLUMN device_exposure.device_source_value IS 'The source code for the Device as it appears in the source data. This code is mapped to a standard Device Concept in the Standardized Vocabularies and the original code is stored here for reference.';
COMMENT ON COLUMN device_exposure.device_type_concept_id IS 'A foreign key to the predefined Concept identifier in the Standardized Vocabularies reflecting the type of Device Exposure recorded. It indicates how the Device Exposure was represented in the source data.';
COMMENT ON COLUMN device_exposure.person_id IS 'A foreign key identifier to the Person who is subjected to the Device. The demographic details of that person are stored in the Person table.';
COMMENT ON COLUMN device_exposure.production_id IS 'This is the Production Identifier (UDI-PI) portion of the Unique Device Identification.';
COMMENT ON COLUMN device_exposure.provider_id IS 'A foreign key to the provider in the PROVIDER table who initiated of administered the Device.';
COMMENT ON COLUMN device_exposure.quantity IS 'The number of individual Devices used for the exposure.';
COMMENT ON COLUMN device_exposure.unique_device_id IS 'A UDI or equivalent identifying the instance of the Device used in the Person.';
COMMENT ON COLUMN device_exposure.unit_concept_id IS 'UNIT_SOURCE_VALUES should be mapped to a Standard Concept in the Unit domain that best represents the unit as given in the source data.';
COMMENT ON COLUMN device_exposure.unit_source_concept_id IS 'This is the concept representing the UNIT_SOURCE_VALUE and may not necessarily be standard. This field is discouraged from use in analysis because it is not required to contain Standard Concepts that are used across the OHDSI community, and should only be used when Standard Concepts do not adequately represent the source detail for the Unit necessary for a given analytic use case. Consider using UNIT_CONCEPT_ID instead to enable standardized analytics that can be consistent across the network.';
COMMENT ON COLUMN device_exposure.unit_source_value IS 'This field houses the verbatim value from the source data representing the unit of the Device. For example, blood transfusions are considered devices and can be given in mL quantities.';
COMMENT ON COLUMN device_exposure.visit_detail_id IS 'A foreign key to the visit in the visit-detail table during which the Drug Exposure was initiated.';
COMMENT ON COLUMN device_exposure.visit_occurrence_id IS 'A foreign key to the visit in the VISIT table during which the device was used.';

CREATE TABLE domain (
    domain_concept_id INTEGER,
    domain_id VARCHAR(20),
    domain_name VARCHAR(255)
);

COMMENT ON TABLE domain IS '[VOCABULARY] The DOMAIN table includes a list of OMOP-defined Domains the Concepts of the Standardized Vocabularies can belong to. A Domain defines the set of allowable Concepts for the standardized fields in the CDM tables. For example, the "Condition" Domain contains Concepts that describe a condition of a patient, and these Concepts can only be stored in the condition_concept_id field of the [CONDITION_OCCURRENCE](https://github.com/OHDSI/CommonDataModel/wiki/CONDITION_OCCURRENCE) and [CONDITION_ERA](https://github.com/OHDSI/CommonDataModel/wiki/CONDITION_ERA) tables. This reference table is populated with a single record for each Domain and includes a descriptive name for the Domain.';';
COMMENT ON COLUMN domain.domain_concept_id IS 'A foreign key that refers to an identifier in the [CONCEPT](https://github.com/OHDSI/CommonDataModel/wiki/CONCEPT) table for the unique Domain Concept the Domain record belongs to.';
COMMENT ON COLUMN domain.domain_id IS 'A unique key for each domain.';
COMMENT ON COLUMN domain.domain_name IS 'The name describing the Domain, e.g. "Condition", "Procedure", "Measurement" etc.';

CREATE TABLE dose_era (
    dose_era_end_date DATE,
    dose_era_id INTEGER,
    dose_era_start_date DATE,
    dose_value NUMERIC,
    drug_concept_id INTEGER,
    person_id INTEGER,
    unit_concept_id INTEGER
);

COMMENT ON TABLE dose_era IS '[DERIVED] A Dose Era is defined as a span of time when the Person is assumed to be exposed to a constant dose of a specific active ingredient. Dose Eras will be derived from records in the DRUG_EXPOSURE table and the Dose information from the DRUG_STRENGTH table using a standardized algorithm. Dose Form information is not taken into account. So, if the patient changes between different formulations, or different manufacturers with the same formulation, the Dose Era is still spanning the entire time of exposure to the Ingredient.';';
COMMENT ON COLUMN dose_era.dose_era_end_date IS 'The end date for the drug era constructed from the individual instance of drug exposures. It is the end date of the final continuously recorded instance of utilization of a drug.';
COMMENT ON COLUMN dose_era.dose_era_id IS 'A unique identifier for each Dose Era.';
COMMENT ON COLUMN dose_era.dose_era_start_date IS 'The start date for the drug era constructed from the individual instances of drug exposures. It is the start date of the very first chronologically recorded instance of utilization of a drug.';
COMMENT ON COLUMN dose_era.dose_value IS 'The numeric value of the dose.';
COMMENT ON COLUMN dose_era.drug_concept_id IS 'A foreign key that refers to a Standard Concept identifier in the Standardized Vocabularies for the active Ingredient Concept.';
COMMENT ON COLUMN dose_era.person_id IS 'A foreign key identifier to the Person who is subjected to the drug during the drug era. The demographic details of that Person are stored in the PERSON table.';
COMMENT ON COLUMN dose_era.unit_concept_id IS 'A foreign key that refers to a Standard Concept identifier in the Standardized Vocabularies for the unit concept.';

CREATE TABLE drug_era (
    drug_concept_id INTEGER,
    drug_era_end_date DATE,
    drug_era_id INTEGER,
    drug_era_start_date DATE,
    drug_exposure_count INTEGER,
    gap_days INTEGER,
    person_id INTEGER
);

COMMENT ON TABLE drug_era IS '[DERIVED] A Drug Era is defined as a span of time when the Person is assumed to be exposed to a particular active ingredient. A Drug Era is not the same as a Drug Exposure: Exposures are individual records corresponding to the source when Drug was delivered to the Person, while successive periods of Drug Exposures are combined under certain rules to produce continuous Drug Eras.';';
COMMENT ON COLUMN drug_era.drug_concept_id IS 'A foreign key that refers to a Standard Concept identifier in the Standardized Vocabularies for the Ingredient Concept.';
COMMENT ON COLUMN drug_era.drug_era_end_date IS 'The end date for the drug era constructed from the individual instance of drug exposures. It is the end date of the final continuously recorded instance of utilization of a drug.';
COMMENT ON COLUMN drug_era.drug_era_id IS 'A unique identifier for each Drug Era.';
COMMENT ON COLUMN drug_era.drug_era_start_date IS 'The start date for the Drug Era constructed from the individual instances of Drug Exposures. It is the start date of the very first chronologically recorded instance of conutilization of a Drug.';
COMMENT ON COLUMN drug_era.drug_exposure_count IS 'The number of individual Drug Exposure occurrences used to construct the Drug Era.';
COMMENT ON COLUMN drug_era.gap_days IS 'The number of days that are not covered by DRUG_EXPOSURE records that were used to make up the era record.';
COMMENT ON COLUMN drug_era.person_id IS 'A foreign key identifier to the Person who is subjected to the Drug during the fDrug Era. The demographic details of that Person are stored in the PERSON table.';

CREATE TABLE drug_exposure (
    days_supply INTEGER,
    dose_unit_source_value VARCHAR(50),
    drug_concept_id INTEGER,
    drug_exposure_end_date DATE,
    drug_exposure_end_datetime TIMESTAMP,
    drug_exposure_id INTEGER,
    drug_exposure_start_date DATE,
    drug_exposure_start_datetime TIMESTAMP,
    drug_source_concept_id INTEGER,
    drug_source_value VARCHAR(50),
    drug_type_concept_id INTEGER,
    lot_number VARCHAR(50),
    person_id INTEGER,
    provider_id INTEGER,
    quantity NUMERIC,
    refills INTEGER,
    route_concept_id INTEGER,
    route_source_value VARCHAR(50),
    sig TEXT,
    stop_reason VARCHAR(20),
    verbatim_end_date DATE,
    visit_detail_id INTEGER,
    visit_occurrence_id INTEGER
);

COMMENT ON TABLE drug_exposure IS '[CLINICAL] The drug exposure domain captures records about the utilization of a Drug when ingested or otherwise introduced into the body. A Drug is a biochemical substance formulated in such a way that when administered to a Person it will exert a certain physiological effect. Drugs include prescription and over-the-counter medicines, vaccines, and large-molecule biologic therapies. Radiological devices ingested or applied locally do not count as Drugs.';';
COMMENT ON COLUMN drug_exposure.days_supply IS 'The number of days of supply of the medication as recorded in the original prescription or dispensing record.';
COMMENT ON COLUMN drug_exposure.dose_unit_source_value IS 'The information about the dose unit as detailed in the source.';
COMMENT ON COLUMN drug_exposure.drug_concept_id IS 'A foreign key that refers to a Standard Concept identifier in the Standardized Vocabularies for the Drug concept.';
COMMENT ON COLUMN drug_exposure.drug_exposure_end_date IS 'The end date for the current instance of Drug utilization. It is not available from all sources.';
COMMENT ON COLUMN drug_exposure.drug_exposure_end_datetime IS 'The end date and time for the current instance of Drug utilization. It is not available from all sources.';
COMMENT ON COLUMN drug_exposure.drug_exposure_id IS 'A system-generated unique identifier for each Drug utilization event.';
COMMENT ON COLUMN drug_exposure.drug_exposure_start_date IS 'The start date for the current instance of Drug utilization. Valid entries include a start date of a prescription, the date a prescription was filled, or the date on which a Drug administration procedure was recorded.';
COMMENT ON COLUMN drug_exposure.drug_exposure_start_datetime IS 'The start date and time for the current instance of Drug utilization. Valid entries include a start date of a prescription, the date a prescription was filled, or the date on which a Drug administration procedure was recorded.';
COMMENT ON COLUMN drug_exposure.drug_source_concept_id IS 'A foreign key to a Drug Concept that refers to the code used in the source.';
COMMENT ON COLUMN drug_exposure.drug_source_value IS 'The source code for the Drug as it appears in the source data. This code is mapped to a Standard Drug concept in the Standardized Vocabularies and the original code is, stored here for reference.';
COMMENT ON COLUMN drug_exposure.drug_type_concept_id IS 'A foreign key to the predefined Concept identifier in the Standardized Vocabularies reflecting the type of Drug Exposure recorded. It indicates how the Drug Exposure was represented in the source data.';
COMMENT ON COLUMN drug_exposure.lot_number IS 'An identifier assigned to a particular quantity or lot of Drug product from the manufacturer.';
COMMENT ON COLUMN drug_exposure.person_id IS 'A foreign key identifier to the person who is subjected to the Drug. The demographic details of that person are stored in the person table.';
COMMENT ON COLUMN drug_exposure.provider_id IS 'A foreign key to the provider in the provider table who initiated (prescribed or administered) the Drug Exposure.';
COMMENT ON COLUMN drug_exposure.quantity IS 'The quantity of drug as recorded in the original prescription or dispensing record.';
COMMENT ON COLUMN drug_exposure.refills IS 'The number of refills after the initial prescription. The initial prescription is not counted, values start with 0.';
COMMENT ON COLUMN drug_exposure.route_concept_id IS 'A foreign key to a predefined concept in the Standardized Vocabularies reflecting the route of administration.';
COMMENT ON COLUMN drug_exposure.route_source_value IS 'The information about the route of administration as detailed in the source.';
COMMENT ON COLUMN drug_exposure.sig IS 'The directions ("signetur") on the Drug prescription as recorded in the original prescription (and printed on the container) or dispensing record.';
COMMENT ON COLUMN drug_exposure.stop_reason IS 'The reason the Drug was stopped. Reasons include regimen completed, changed, removed, etc.';
COMMENT ON COLUMN drug_exposure.verbatim_end_date IS 'The known end date of a drug_exposure as provided by the source';
COMMENT ON COLUMN drug_exposure.visit_detail_id IS 'A foreign key to the visit in the VISIT_DETAIL table during which the Drug Exposure was initiated.';
COMMENT ON COLUMN drug_exposure.visit_occurrence_id IS 'A foreign key to the visit in the visit table during which the Drug Exposure was initiated.';

CREATE TABLE drug_strength (
    amount_unit_concept_id INTEGER,
    amount_value NUMERIC,
    box_size INTEGER,
    denominator_unit_concept_id INTEGER,
    denominator_value NUMERIC,
    drug_concept_id INTEGER,
    ingredient_concept_id INTEGER,
    invalid_reason VARCHAR(1),
    numerator_unit_concept_id INTEGER,
    numerator_value NUMERIC,
    valid_end_date DATE,
    valid_start_date DATE
);

COMMENT ON TABLE drug_strength IS '[VOCABULARY] The DRUG_STRENGTH table contains structured content about the amount or concentration and associated units of a specific ingredient contained within a particular drug product. This table is supplemental information to support standardized analysis of drug utilization.';';
COMMENT ON COLUMN drug_strength.amount_unit_concept_id IS 'A foreign key to the Concept in the CONCEPT table representing the identifier for the Unit for the absolute amount of active ingredient.';
COMMENT ON COLUMN drug_strength.amount_value IS 'The numeric value associated with the amount of active ingredient contained within the product.';
COMMENT ON COLUMN drug_strength.box_size IS 'The number of units of Clinical of Branded Drug, or Quantified Clinical or Branded Drug contained in a box as dispensed to the patient';
COMMENT ON COLUMN drug_strength.denominator_unit_concept_id IS 'A foreign key to the Concept in the CONCEPT table representing the identifier for the denominator Unit for the concentration of active ingredient.';
COMMENT ON COLUMN drug_strength.denominator_value IS 'The amount of total liquid (or other divisible product, such as ointment, gel, spray, etc.).';
COMMENT ON COLUMN drug_strength.drug_concept_id IS 'A foreign key to the Concept in the CONCEPT table representing the identifier for Branded Drug or Clinical Drug Concept.';
COMMENT ON COLUMN drug_strength.ingredient_concept_id IS 'A foreign key to the Concept in the CONCEPT table, representing the identifier for drug Ingredient Concept contained within the drug product.';
COMMENT ON COLUMN drug_strength.invalid_reason IS 'Reason the concept was invalidated. Possible values are ';
COMMENT ON COLUMN drug_strength.numerator_unit_concept_id IS 'A foreign key to the Concept in the CONCEPT table representing the identifier for the numerator Unit for the concentration of active ingredient.';
COMMENT ON COLUMN drug_strength.numerator_value IS 'The numeric value associated with the concentration of the active ingredient contained in the product';
COMMENT ON COLUMN drug_strength.valid_end_date IS 'The date when the concept became invalid because it was deleted or superseded (updated) by a new Concept. The default value is 31-Dec-2099.';
COMMENT ON COLUMN drug_strength.valid_start_date IS 'The date when the Concept was first recorded. The default value is 1-Jan-1970.';

CREATE TABLE episode (
    episode_concept_id INTEGER,
    episode_end_date DATE,
    episode_end_datetime TIMESTAMP,
    episode_id INTEGER,
    episode_number INTEGER,
    episode_object_concept_id INTEGER,
    episode_parent_id INTEGER,
    episode_source_concept_id INTEGER,
    episode_source_value VARCHAR(50),
    episode_start_date DATE,
    episode_start_datetime TIMESTAMP,
    episode_type_concept_id INTEGER,
    person_id INTEGER
);

COMMENT ON TABLE episode IS 'The EPISODE table aggregates lower-level clinical events (VISIT_OCCURRENCE, DRUG_EXPOSURE, PROCEDURE_OCCURRENCE, DEVICE_EXPOSURE) into a higher-level abstraction representing clinically and analytically relevant disease phases,outcomes and treatments. The EPISODE_EVENT table connects qualifying clinical events (VISIT_OCCURRENCE, DRUG_EXPOSURE, PROCEDURE_OCCURRENCE, DEVICE_EXPOSURE) to the appropriate EPISODE entry. For example cancers including their development over time, their treatment, and final resolution.';';
COMMENT ON COLUMN episode.episode_concept_id IS 'The EPISODE_CONCEPT_ID represents the kind of abstraction related to the disease phase, outcome, or treatment. Choose a concept in the Episode domain that best represents the ongoing disease phase, outcome, or treatment.';
COMMENT ON COLUMN episode.episode_end_date IS 'The date when the instance of the Episode is considered to have ended. Please see [article] for how to define an Episode end date.';
COMMENT ON COLUMN episode.episode_end_datetime IS 'The date and time when the instance of the Episode is considered to have ended.';
COMMENT ON COLUMN episode.episode_id IS 'A unique identifier for each Episode.';
COMMENT ON COLUMN episode.episode_number IS 'For sequences of episodes, this is used to indicate the order the episodes occurred. For example, lines of treatment could be indicated here. Please see [article] for the details of how to count episodes.';
COMMENT ON COLUMN episode.episode_object_concept_id IS 'A Standard Concept representing the disease phase, outcome, or other abstraction of which the episode consists. For example, if the EPISODE_CONCEPT_ID is treatment regimen then the EPISODE_OBJECT_CONCEPT_ID should contain the chemotherapy regimen concept, like Afatinib monotherapy.';
COMMENT ON COLUMN episode.episode_parent_id IS 'Use this field to find the Episode that subsumes the given Episode record. This is used in the case that Episodes are nested into each other.';
COMMENT ON COLUMN episode.episode_source_concept_id IS 'A foreign key to an Episode Concept that refers to the code used in the source. Given that the Episodes are user-defined it is unlikely that there will be a Source Concept available. If that is the case then set this field to zero.';
COMMENT ON COLUMN episode.episode_source_value IS 'The source code for the Episode as it appears in the source data. This code is mapped to a Standard Condition Concept in the Standardized Vocabularies and the original code is stored here for reference.';
COMMENT ON COLUMN episode.episode_start_date IS 'The date when the Episode begins. Please see [article] for how to define an Episode start date.';
COMMENT ON COLUMN episode.episode_start_datetime IS 'The date and time when the Episode begins.';
COMMENT ON COLUMN episode.episode_type_concept_id IS 'This field can be used to determine the provenance of the Episode record, as in whether the episode was from an EHR system, insurance claim, registry, or other sources. Choose the EPISODE_TYPE_CONCEPT_ID that best represents the provenance of the record.';
COMMENT ON COLUMN episode.person_id IS 'The PERSON_ID of the PERSON for whom the episode is recorded.';

CREATE TABLE episode_event (
    episode_event_field_concept_id INTEGER,
    episode_id INTEGER,
    event_id INTEGER
);

COMMENT ON TABLE episode_event IS 'The EPISODE_EVENT table connects qualifying clinical events (such as CONDITION_OCCURRENCE, DRUG_EXPOSURE, PROCEDURE_OCCURRENCE, MEASUREMENT) to the appropriate EPISODE entry. For example, linking the precise location of the metastasis (cancer modifier in MEASUREMENT) to the disease episode. This connecting table is used instead of the FACT_RELATIONSHIP table for linking low-level events to abstracted Episodes. Some episodes may not have links to any underlying clinical events. For such episodes, the EPISODE_EVENT table is not populated.';';
COMMENT ON COLUMN episode_event.episode_event_field_concept_id IS 'This field is the CONCEPT_ID that identifies which table the primary key of the linked record came from. Put the CONCEPT_ID that identifies which table and field the EVENT_ID came from. Accepted Concepts.';
COMMENT ON COLUMN episode_event.episode_id IS 'Use this field to link the EPISODE_EVENT record to its EPISODE. Put the EPISODE_ID that subsumes the EPISODE_EVENT record here.';
COMMENT ON COLUMN episode_event.event_id IS 'This field is the primary key of the linked record in the database. For example, if the Episode Event is a Condition Occurrence, then the CONDITION_OCCURRENCE_ID of the linked record goes in this field. Put the primary key of the linked record here.';

CREATE TABLE fact_relationship (
    domain_concept_id_1 INTEGER,
    domain_concept_id_2 INTEGER,
    fact_id_1 INTEGER,
    fact_id_2 INTEGER,
    relationship_concept_id INTEGER
);

COMMENT ON TABLE fact_relationship IS '[CLINICAL] The FACT_RELATIONSHIP table contains records about the relationships between facts stored as records in any table of the CDM. Relationships can be defined between facts from the same domain (table), or different domains. Examples of Fact Relationships include: Person relationships (parent-child), care site relationships (hierarchical organizational structure of facilities within a health system), indication relationship (between drug exposures and associated conditions), usage relationships (of devices during the course of an associated procedure), or facts derived from one another (measurements derived from an associated specimen).';';
COMMENT ON COLUMN fact_relationship.domain_concept_id_1 IS 'The concept representing the domain of fact one, from which the corresponding table can be inferred.';
COMMENT ON COLUMN fact_relationship.domain_concept_id_2 IS 'The concept representing the domain of fact two, from which the corresponding table can be inferred.';
COMMENT ON COLUMN fact_relationship.fact_id_1 IS 'The unique identifier in the table corresponding to the domain of fact one.';
COMMENT ON COLUMN fact_relationship.fact_id_2 IS 'The unique identifier in the table corresponding to the domain of fact two.';
COMMENT ON COLUMN fact_relationship.relationship_concept_id IS 'A foreign key to a Standard Concept ID of relationship in the Standardized Vocabularies.';

CREATE TABLE location (
    address_1 VARCHAR(50),
    address_2 VARCHAR(50),
    city VARCHAR(50),
    country_concept_id INTEGER,
    country_source_value VARCHAR(80),
    county VARCHAR(20),
    latitude NUMERIC,
    location_id INTEGER,
    location_source_value VARCHAR(50),
    longitude NUMERIC,
    state VARCHAR(2),
    zip VARCHAR(9)
);

COMMENT ON TABLE location IS '[SYSTEM] The LOCATION table represents a generic way to capture physical location or address information of Persons and Care Sites.';';
COMMENT ON COLUMN location.address_1 IS 'The address field 1, typically used for the street address, as it appears in the source data.';
COMMENT ON COLUMN location.address_2 IS 'The address field 2, typically used for additional detail such as buildings, suites, floors, as it appears in the source data.';
COMMENT ON COLUMN location.city IS 'The city field as it appears in the source data.';
COMMENT ON COLUMN location.country_concept_id IS 'The Concept Id representing the country. Values should conform to the Geography domain.';
COMMENT ON COLUMN location.country_source_value IS 'The name of the country.';
COMMENT ON COLUMN location.county IS 'The county.';
COMMENT ON COLUMN location.latitude IS 'Must be between -90 and 90.';
COMMENT ON COLUMN location.location_id IS 'A unique identifier for each geographic location.';
COMMENT ON COLUMN location.location_source_value IS 'The verbatim information that is used to uniquely identify the location as it appears in the source data.';
COMMENT ON COLUMN location.longitude IS 'Must be between -180 and 180.';
COMMENT ON COLUMN location.state IS 'The state field as it appears in the source data.';
COMMENT ON COLUMN location.zip IS 'The zip or postal code.';

CREATE TABLE measurement (
    meas_event_field_concept_id INTEGER,
    measurement_concept_id INTEGER,
    measurement_date DATE,
    measurement_datetime TIMESTAMP,
    measurement_event_id INTEGER,
    measurement_id INTEGER,
    measurement_source_concept_id INTEGER,
    measurement_source_value VARCHAR(50),
    measurement_time VARCHAR(10),
    measurement_type_concept_id INTEGER,
    operator_concept_id INTEGER,
    person_id INTEGER,
    provider_id INTEGER,
    range_high NUMERIC,
    range_low NUMERIC,
    unit_concept_id INTEGER,
    unit_source_concept_id INTEGER,
    unit_source_value VARCHAR(50),
    value_as_concept_id INTEGER,
    value_as_number NUMERIC,
    value_source_value VARCHAR(50),
    visit_detail_id INTEGER,
    visit_occurrence_id INTEGER
);

COMMENT ON TABLE measurement IS '[CLINICAL] The MEASUREMENT table contains records of Measurement, i.e. structured values (numerical or categorical) obtained through systematic and standardized examination or testing of a Person or Person''s sample. The MEASUREMENT table contains both orders and results of such Measurements as laboratory tests, vital signs, quantitative findings from pathology reports, etc.';';
COMMENT ON COLUMN measurement.meas_event_field_concept_id IS 'If the Measurement record is related to another record in the database, this field is the CONCEPT_ID that identifies which table the primary key of the linked record came from.';
COMMENT ON COLUMN measurement.measurement_concept_id IS 'A foreign key to the standard measurement concept identifier in the Standardized Vocabularies.';
COMMENT ON COLUMN measurement.measurement_date IS 'The date of the Measurement.';
COMMENT ON COLUMN measurement.measurement_datetime IS 'The date and time of the Measurement. Some database systems don';
COMMENT ON COLUMN measurement.measurement_event_id IS 'If the Measurement record is related to another record in the database, this field is the primary key of the linked record.';
COMMENT ON COLUMN measurement.measurement_id IS 'A unique identifier for each Measurement.';
COMMENT ON COLUMN measurement.measurement_source_concept_id IS 'A foreign key to a Concept in the Standard Vocabularies that refers to the code used in the source.';
COMMENT ON COLUMN measurement.measurement_source_value IS 'The Measurement name as it appears in the source data. This code is mapped to a Standard Concept in the Standardized Vocabularies and the original code is stored here for reference.';
COMMENT ON COLUMN measurement.measurement_time IS 'This is present for backwards compatibility and will be deprecated in an upcoming version.';
COMMENT ON COLUMN measurement.measurement_type_concept_id IS 'A foreign key to the predefined Concept in the Standardized Vocabularies reflecting the provenance from where the Measurement record was recorded.';
COMMENT ON COLUMN measurement.operator_concept_id IS 'A foreign key identifier to the predefined Concept in the Standardized Vocabularies reflecting the mathematical operator that is applied to the value_as_number. Operators are <, <=, =, >=, >.';
COMMENT ON COLUMN measurement.person_id IS 'A foreign key identifier to the Person about whom the measurement was recorded. The demographic details of that Person are stored in the PERSON table.';
COMMENT ON COLUMN measurement.provider_id IS 'A foreign key to the provider in the PROVIDER table who was responsible for initiating or obtaining the measurement.';
COMMENT ON COLUMN measurement.range_high IS 'The upper limit of the normal range of the Measurement. The upper range is assumed to be of the same unit of measure as the Measurement value.';
COMMENT ON COLUMN measurement.range_low IS 'The lower limit of the normal range of the Measurement result. The lower range is assumed to be of the same unit of measure as the Measurement value.';
COMMENT ON COLUMN measurement.unit_concept_id IS 'A foreign key to a Standard Concept ID of Measurement Units in the Standardized Vocabularies.';
COMMENT ON COLUMN measurement.unit_source_concept_id IS 'This is the concept representing the UNIT_SOURCE_VALUE and may not necessarily be standard. This field is discouraged from use in analysis because it is not required to contain Standard Concepts that are used across the OHDSI community, and should only be used when Standard Concepts do not adequately represent the source detail for the Measurement necessary for a given analytic use case. Consider using UNIT_CONCEPT_ID instead to enable standardized analytics that can be consistent across the network.';
COMMENT ON COLUMN measurement.unit_source_value IS 'The source code for the unit as it appears in the source data. This code is mapped to a standard unit concept in the Standardized Vocabularies and the original code is stored here for reference.';
COMMENT ON COLUMN measurement.value_as_concept_id IS 'A foreign key to a Measurement result represented as a Concept from the Standardized Vocabularies (e.g., positive/negative, present/absent, low/high, etc.).';
COMMENT ON COLUMN measurement.value_as_number IS 'A Measurement result where the result is expressed as a numeric value.';
COMMENT ON COLUMN measurement.value_source_value IS 'The source value associated with the content of the value_as_number or value_as_concept_id as stored in the source data.';
COMMENT ON COLUMN measurement.visit_detail_id IS 'A foreign key to the Visit in the VISIT_DETAIL table during which the Measurement was recorded.';
COMMENT ON COLUMN measurement.visit_occurrence_id IS 'A foreign key to the Visit in the VISIT_OCCURRENCE table during which the Measurement was recorded.';

CREATE TABLE metadata (
    metadata_concept_id INTEGER,
    metadata_date DATE,
    metadata_datetime TIMESTAMP,
    metadata_id INTEGER,
    metadata_type_concept_id INTEGER,
    name VARCHAR(250),
    value_as_concept_id INTEGER,
    value_as_number NUMERIC,
    value_as_string VARCHAR(250)
);

COMMENT ON TABLE metadata IS 'The METADATA table contains metadata information about a dataset that has been transformed to the OMOP Common Data Model.';';
COMMENT ON COLUMN metadata.metadata_concept_id IS 'The CONCEPT_ID that provides the metadata concept.';
COMMENT ON COLUMN metadata.metadata_date IS 'The date of the metadata attribute.';
COMMENT ON COLUMN metadata.metadata_datetime IS 'The datetime of the metadata attribute.';
COMMENT ON COLUMN metadata.metadata_id IS 'The unique key given to a Metadata record. Attribute value is auto-generated.';
COMMENT ON COLUMN metadata.metadata_type_concept_id IS 'The CONCEPT_ID that provides the type of metadata.';
COMMENT ON COLUMN metadata.name IS 'The name of the metadata attribute.';
COMMENT ON COLUMN metadata.value_as_concept_id IS 'The CONCEPT_ID that represents the value of the metadata attribute.';
COMMENT ON COLUMN metadata.value_as_number IS 'This is the numerical value of the result of the Metadata, if applicable and available. It is not expected that all Metadata will have numeric results, rather, this field is here to house values should they exist.';
COMMENT ON COLUMN metadata.value_as_string IS 'The string value of the metadata attribute.';

CREATE TABLE note (
    encoding_concept_id INTEGER,
    language_concept_id INTEGER,
    note_class_concept_id INTEGER,
    note_date DATE,
    note_datetime TIMESTAMP,
    note_event_field_concept_id INTEGER,
    note_event_id INTEGER,
    note_id INTEGER,
    note_source_value VARCHAR(50),
    note_text TEXT,
    note_title VARCHAR(250),
    note_type_concept_id INTEGER,
    person_id INTEGER,
    provider_id INTEGER,
    visit_detail_id INTEGER,
    visit_occurrence_id INTEGER
);

COMMENT ON TABLE note IS '[CLINICAL] The NOTE table captures unstructured information that was recorded by a provider about a patient in free text notes on a given date.';';
COMMENT ON COLUMN note.encoding_concept_id IS 'A foreign key to the predefined Concept in the Standardized Vocabularies reflecting the note character encoding type';
COMMENT ON COLUMN note.language_concept_id IS 'A foreign key to the predefined Concept in the Standardized Vocabularies reflecting the language of the note';
COMMENT ON COLUMN note.note_class_concept_id IS 'A foreign key to the predefined Concept in the Standardized Vocabularies reflecting the HL7 LOINC Document Type Vocabulary classification of the note.';
COMMENT ON COLUMN note.note_date IS 'The date the note was recorded.';
COMMENT ON COLUMN note.note_datetime IS 'The date and time the note was recorded.';
COMMENT ON COLUMN note.note_event_field_concept_id IS 'If the Note record is related to another record in the database, this field is the CONCEPT_ID that identifies which table the primary key of the linked record came from.';
COMMENT ON COLUMN note.note_event_id IS 'If the Note record is related to another record in the database, this field is the primary key of the linked record.';
COMMENT ON COLUMN note.note_id IS 'A unique identifier for each note.';
COMMENT ON COLUMN note.note_source_value IS 'The source value associated with the origin of the note';
COMMENT ON COLUMN note.note_text IS 'The content of the Note.';
COMMENT ON COLUMN note.note_title IS 'The title of the Note as it appears in the source.';
COMMENT ON COLUMN note.note_type_concept_id IS 'A foreign key to the predefined Concept in the Standardized Vocabularies reflecting the type, origin or provenance of the Note.';
COMMENT ON COLUMN note.person_id IS 'A foreign key identifier to the Person about whom the Note was recorded. The demographic details of that Person are stored in the PERSON table.';
COMMENT ON COLUMN note.provider_id IS 'A foreign key to the Provider in the PROVIDER table who took the Note.';
COMMENT ON COLUMN note.visit_detail_id IS 'Foreign key to the Visit in the VISIT_DETAIL table when the Note was taken.';
COMMENT ON COLUMN note.visit_occurrence_id IS 'Foreign key to the Visit in the VISIT_OCCURRENCE table when the Note was taken.';

CREATE TABLE note_nlp (
    lexical_variant VARCHAR(250),
    nlp_date DATE,
    nlp_datetime TIMESTAMP,
    nlp_system VARCHAR(250),
    note_id INTEGER,
    note_nlp_concept_id INTEGER,
    note_nlp_id INTEGER,
    note_nlp_source_concept_id INTEGER,
    offset VARCHAR(50),
    section_concept_id INTEGER,
    snippet VARCHAR(250),
    term_exists VARCHAR(1),
    term_modifiers VARCHAR(2000),
    term_temporal VARCHAR(50)
);

COMMENT ON TABLE note_nlp IS '[CLINICAL] The NOTE_NLP table will encode all output of NLP on clinical notes. Each row represents a single extracted term from a note.';';
COMMENT ON COLUMN note_nlp.lexical_variant IS 'Raw text extracted from the NLP tool.';
COMMENT ON COLUMN note_nlp.nlp_date IS 'The date of the note processing.Useful for data provenance.';
COMMENT ON COLUMN note_nlp.nlp_datetime IS 'The date and time of the note processing. Useful for data provenance.';
COMMENT ON COLUMN note_nlp.nlp_system IS 'Name and version of the NLP system that extracted the term.Useful for data provenance.';
COMMENT ON COLUMN note_nlp.note_id IS 'A foreign key to the Note table note the term was extracted from.';
COMMENT ON COLUMN note_nlp.note_nlp_concept_id IS 'A foreign key to the predefined Concept in the Standardized Vocabularies reflecting the normalized concept for the extracted term. Domain of the term is represented as part of the Concept table.';
COMMENT ON COLUMN note_nlp.note_nlp_id IS 'A unique identifier for each term extracted from a note.';
COMMENT ON COLUMN note_nlp.note_nlp_source_concept_id IS 'A foreign key to a Concept that refers to the code in the source vocabulary used by the NLP system';
COMMENT ON COLUMN note_nlp.offset IS 'Character offset of the extracted term in the input note.';
COMMENT ON COLUMN note_nlp.section_concept_id IS 'A foreign key to the predefined Concept in the Standardized Vocabularies representing the section of the extracted term.';
COMMENT ON COLUMN note_nlp.snippet IS 'A small window of text surrounding the term.';
COMMENT ON COLUMN note_nlp.term_exists IS 'A summary modifier that signifies presence or absence of the term for a given patient. Useful for quick querying. *';
COMMENT ON COLUMN note_nlp.term_modifiers IS 'For the modifiers that are there, they would have to have these values: - Negation = false - Subject = patient - Conditional = false - Rule_out = false - Uncertain = true or high or moderate or even low (could argue about low). Term_modifiers will concatenate all modifiers for different types of entities (conditions, drugs, labs etc) into one string. Lab values will be saved as one of the modifiers';
COMMENT ON COLUMN note_nlp.term_temporal IS 'Term_temporal is to indicate if a condition is present or just in the past. The following would be past:History = true - Concept_date = anything before the time of the report';

CREATE TABLE observation (
    obs_event_field_concept_id INTEGER,
    observation_concept_id INTEGER,
    observation_date DATE,
    observation_datetime TIMESTAMP,
    observation_event_id INTEGER,
    observation_id INTEGER,
    observation_source_concept_id INTEGER,
    observation_source_value VARCHAR(50),
    observation_type_concept_id INTEGER,
    person_id INTEGER,
    provider_id INTEGER,
    qualifier_concept_id INTEGER,
    qualifier_source_value VARCHAR(50),
    unit_concept_id INTEGER,
    unit_source_value VARCHAR(50),
    value_as_concept_id INTEGER,
    value_as_number NUMERIC,
    value_as_string VARCHAR(60),
    value_source_value VARCHAR(50),
    visit_detail_id INTEGER,
    visit_occurrence_id INTEGER
);

COMMENT ON TABLE observation IS '[CLINICAL] The OBSERVATION table captures clinical facts about a Person obtained in the context of examination, questioning or a procedure. Any data that cannot be represented by any other domains, such as social and lifestyle facts, medical history, family history, etc. are recorded here.';';
COMMENT ON COLUMN observation.obs_event_field_concept_id IS 'If the Observation record is related to another record in the database, this field is the CONCEPT_ID that identifies which table the primary key of the linked record came from.';
COMMENT ON COLUMN observation.observation_concept_id IS 'A foreign key to the standard observation concept identifier in the Standardized Vocabularies.';
COMMENT ON COLUMN observation.observation_date IS 'The date of the observation.';
COMMENT ON COLUMN observation.observation_datetime IS 'The date and time of the observation.';
COMMENT ON COLUMN observation.observation_event_id IS 'If the Observation record is related to another record in the database, this field is the primary key of the linked record.';
COMMENT ON COLUMN observation.observation_id IS 'A unique identifier for each observation.';
COMMENT ON COLUMN observation.observation_source_concept_id IS 'A foreign key to a Concept that refers to the code used in the source.';
COMMENT ON COLUMN observation.observation_source_value IS 'The observation code as it appears in the source data. This code is mapped to a Standard Concept in the Standardized Vocabularies and the original code is, stored here for reference.';
COMMENT ON COLUMN observation.observation_type_concept_id IS 'A foreign key to the predefined concept identifier in the Standardized Vocabularies reflecting the type of the observation.';
COMMENT ON COLUMN observation.person_id IS 'A foreign key identifier to the Person about whom the observation was recorded. The demographic details of that Person are stored in the PERSON table.';
COMMENT ON COLUMN observation.provider_id IS 'A foreign key to the provider in the PROVIDER table who was responsible for making the observation.';
COMMENT ON COLUMN observation.qualifier_concept_id IS 'A foreign key to a Standard Concept ID for a qualifier (e.g., severity of drug-drug interaction alert)';
COMMENT ON COLUMN observation.qualifier_source_value IS 'The source value associated with a qualifier to characterize the observation';
COMMENT ON COLUMN observation.unit_concept_id IS 'A foreign key to a Standard Concept ID of measurement units in the Standardized Vocabularies.';
COMMENT ON COLUMN observation.unit_source_value IS 'The source code for the unit as it appears in the source data. This code is mapped to a standard unit concept in the Standardized Vocabularies and the original code is, stored here for reference.';
COMMENT ON COLUMN observation.value_as_concept_id IS 'A foreign key to an observation result stored as a Concept ID. This is applicable to observations where the result can be expressed as a Standard Concept from the Standardized Vocabularies (e.g., positive/negative, present/absent, low/high, etc.).';
COMMENT ON COLUMN observation.value_as_number IS 'The observation result stored as a number. This is applicable to observations where the result is expressed as a numeric value.';
COMMENT ON COLUMN observation.value_as_string IS 'The observation result stored as a string. This is applicable to observations where the result is expressed as verbatim text.';
COMMENT ON COLUMN observation.value_source_value IS 'This field houses the verbatim result value of the Observation from the source data. Do not get confused with the Observation_source_value which captures source value of the observation mapped to observation_concept_id. This field is the observation result value from the source.';
COMMENT ON COLUMN observation.visit_detail_id IS 'A foreign key to the visit in the VISIT_DETAIL table during which the observation was recorded.';
COMMENT ON COLUMN observation.visit_occurrence_id IS 'A foreign key to the visit in the VISIT_OCCURRENCE table during which the observation was recorded.';

CREATE TABLE observation_period (
    observation_period_end_date DATE,
    observation_period_id INTEGER,
    observation_period_start_date DATE,
    period_type_concept_id INTEGER,
    person_id INTEGER
);

COMMENT ON TABLE observation_period IS '[CLINICAL] The OBSERVATION_PERIOD table contains records which uniquely define the spans of time for which a Person is at-risk to have clinical events recorded within the source systems, even if no events in fact are recorded (healthy patient with no healthcare interactions).';';
COMMENT ON COLUMN observation_period.observation_period_end_date IS 'The end date of the observation period for which data are available from the data source.';
COMMENT ON COLUMN observation_period.observation_period_id IS 'A unique identifier for each observation period.';
COMMENT ON COLUMN observation_period.observation_period_start_date IS 'The start date of the observation period for which data are available from the data source.';
COMMENT ON COLUMN observation_period.period_type_concept_id IS 'A foreign key identifier to the predefined concept in the Standardized Vocabularies reflecting the source of the observation period information';
COMMENT ON COLUMN observation_period.person_id IS 'A foreign key identifier to the person for whom the observation period is defined. The demographic details of that person are stored in the person table.';

CREATE TABLE payer_plan_period (
    family_source_value VARCHAR(50),
    payer_concept_id INTEGER,
    payer_plan_period_end_date DATE,
    payer_plan_period_id INTEGER,
    payer_plan_period_start_date DATE,
    payer_source_concept_id INTEGER,
    payer_source_value VARCHAR(50),
    person_id INTEGER,
    plan_concept_id INTEGER,
    plan_source_concept_id INTEGER,
    plan_source_value VARCHAR(50),
    sponsor_concept_id INTEGER,
    sponsor_source_concept_id INTEGER,
    sponsor_source_value VARCHAR(50),
    stop_reason_concept_id INTEGER,
    stop_reason_source_concept_id INTEGER,
    stop_reason_source_value VARCHAR(50)
);

COMMENT ON TABLE payer_plan_period IS 'The PAYER_PLAN_PERIOD table captures details of the period of time that a Person is continuously enrolled under a specific health Plan benefit structure from a given Payer. Each Person receiving healthcare is typically covered by a health benefit plan, which pays for (fully or partially), or directly provides, the care. These benefit plans are provided by payers, such as health insurances or state or government agencies. In each plan the details of the health benefits are defined for the Person or her family, and the health benefit Plan might change over time typically with increasing utilization (reaching certain cost thresholds such as deductibles), plan availability and purchasing choices of the Person. The unique combinations of Payer organizations, health benefit Plans and time periods in which they are valid for a Person are recorded in this table.';';
COMMENT ON COLUMN payer_plan_period.family_source_value IS 'The common identifier for all people (often a family) that covered by the same policy. Often these are the common digits of the enrollment id of the policy members.';
COMMENT ON COLUMN payer_plan_period.payer_concept_id IS 'This field represents the organization who reimburses the provider which administers care to the Person. Map the payer directly to a standard CONCEPT_ID with the domain_id of ‘Payer’ (Accepted Concepts). This vocabulary is not exhaustive so if there is a value missing, please see the custom concepts page.';
COMMENT ON COLUMN payer_plan_period.payer_plan_period_end_date IS 'End date of Plan coverage.';
COMMENT ON COLUMN payer_plan_period.payer_plan_period_id IS 'A unique identifier for each unique combination of a Person, Payer, Plan, and Period of time.';
COMMENT ON COLUMN payer_plan_period.payer_plan_period_start_date IS 'Start date of Plan coverage.';
COMMENT ON COLUMN payer_plan_period.payer_source_concept_id IS 'If the source data codes the Payer in an OMOP supported vocabulary store the concept_id here.';
COMMENT ON COLUMN payer_plan_period.payer_source_value IS 'This is the Payer as it appears in the source data.';
COMMENT ON COLUMN payer_plan_period.person_id IS 'The Person covered by the Plan. A single Person can have multiple, overlapping, PAYER_PLAN_PERIOD records.';
COMMENT ON COLUMN payer_plan_period.plan_concept_id IS 'This field represents the specific health benefit Plan the Person is enrolled in. Map the Plan directly to a standard CONCEPT_ID in the ‘Plan’ vocabulary (Accepted Concepts). This vocabulary is not exhaustive so if there is a value missing, please see the custom concepts page.';
COMMENT ON COLUMN payer_plan_period.plan_source_concept_id IS 'If the source data codes the Plan in an OMOP supported vocabulary store the concept_id here.';
COMMENT ON COLUMN payer_plan_period.plan_source_value IS 'This is the health benefit Plan of the Person as it appears in the source data.';
COMMENT ON COLUMN payer_plan_period.sponsor_concept_id IS 'This field represents the sponsor of the Plan who finances the Plan. This includes self-insured, small group health plan and large group health plan. Map the sponsor directly to a standard CONCEPT_ID with the domain_id of ‘Sponsor’ (Accepted Concepts). This vocabulary is not exhaustive so if there is a value missing, please see the custom concepts page.';
COMMENT ON COLUMN payer_plan_period.sponsor_source_concept_id IS 'If the source data codes the sponsor in an OMOP supported vocabulary store the concept_id here.';
COMMENT ON COLUMN payer_plan_period.sponsor_source_value IS 'The Plan sponsor as it appears in the source data.';
COMMENT ON COLUMN payer_plan_period.stop_reason_concept_id IS 'This field represents the reason the Person left the Plan, if known. Map the stop reason directly to a standard CONCEPT_ID with a domain of ‘Plan Stop Reason’ (Accepted Concepts). If one does not exist visit the Custom Concepts pate for more information.';
COMMENT ON COLUMN payer_plan_period.stop_reason_source_concept_id IS 'If the source data codes the stop reason in an OMOP supported vocabulary store the concept_id here.';
COMMENT ON COLUMN payer_plan_period.stop_reason_source_value IS 'The Plan stop reason as it appears in the source data.';

CREATE TABLE person (
    birth_datetime TIMESTAMP,
    care_site_id INTEGER,
    day_of_birth INTEGER,
    ethnicity_concept_id INTEGER,
    ethnicity_source_concept_id INTEGER,
    ethnicity_source_value VARCHAR(50),
    gender_concept_id INTEGER,
    gender_source_concept_id INTEGER,
    gender_source_value VARCHAR(50),
    location_id INTEGER,
    month_of_birth INTEGER,
    person_id INTEGER,
    person_source_value VARCHAR(50),
    provider_id INTEGER,
    race_concept_id INTEGER,
    race_source_concept_id INTEGER,
    race_source_value VARCHAR(50),
    year_of_birth INTEGER
);

COMMENT ON TABLE person IS '[CLINICAL] The Person Domain contains records that uniquely identify each patient in the source data who is time at-risk to have clinical observations recorded within the source systems.';';
COMMENT ON COLUMN person.birth_datetime IS 'The date and time of birth of the person.';
COMMENT ON COLUMN person.care_site_id IS 'A foreign key to the site of primary care in the care_site table, where the details of the care site are stored.';
COMMENT ON COLUMN person.day_of_birth IS 'The day of the month of birth of the person. For data sources that provide the precise date of birth, the day is extracted and stored in this field.';
COMMENT ON COLUMN person.ethnicity_concept_id IS 'A foreign key that refers to the standard concept identifier in the Standardized Vocabularies for the ethnicity of the person.';
COMMENT ON COLUMN person.ethnicity_source_concept_id IS 'A foreign key to the ethnicity concept that refers to the code used in the source.';
COMMENT ON COLUMN person.ethnicity_source_value IS 'The source code for the ethnicity of the person as it appears in the source data. The person ethnicity is mapped to a standard ethnicity concept in the Standardized Vocabularies and the original code is, stored here for reference.';
COMMENT ON COLUMN person.gender_concept_id IS 'A foreign key that refers to an identifier in the CONCEPT table for the unique gender of the person.';
COMMENT ON COLUMN person.gender_source_concept_id IS 'A foreign key to the gender concept that refers to the code used in the source.';
COMMENT ON COLUMN person.gender_source_value IS 'The source code for the gender of the person as it appears in the source data. The person’s gender is mapped to a standard gender concept in the Standardized Vocabularies. the original value is stored here for reference.';
COMMENT ON COLUMN person.location_id IS 'A foreign key to the place of residency for the person in the location table, where the detailed address information is stored.';
COMMENT ON COLUMN person.month_of_birth IS 'The month of birth of the person. For data sources that provide the precise date of birth, the month is extracted and stored in this field.';
COMMENT ON COLUMN person.person_id IS 'A unique identifier for each person.';
COMMENT ON COLUMN person.person_source_value IS 'An (encrypted) key derived from the person identifier in the source data. This is necessary when a use case requires a link back to the person data at the source dataset.';
COMMENT ON COLUMN person.provider_id IS 'A foreign key to the primary care provider the person is seeing in the provider table.';
COMMENT ON COLUMN person.race_concept_id IS 'A foreign key that refers to an identifier in the CONCEPT table for the unique race of the person.';
COMMENT ON COLUMN person.race_source_concept_id IS 'A foreign key to the race concept that refers to the code used in the source.';
COMMENT ON COLUMN person.race_source_value IS 'The source code for the race of the person as it appears in the source data. The person race is mapped to a standard race concept in the Standardized Vocabularies and the original value is stored here for reference.';
COMMENT ON COLUMN person.year_of_birth IS 'The year of birth of the person. For data sources with date of birth, the year is extracted. For data sources where the year of birth is not available, the approximate year of birth is derived based on any age group categorization available.';

CREATE TABLE procedure_occurrence (
    modifier_concept_id INTEGER,
    modifier_source_value VARCHAR(50),
    person_id INTEGER,
    procedure_concept_id INTEGER,
    procedure_date DATE,
    procedure_datetime TIMESTAMP,
    procedure_end_date DATE,
    procedure_end_datetime TIMESTAMP,
    procedure_occurrence_id INTEGER,
    procedure_source_concept_id INTEGER,
    procedure_source_value VARCHAR(50),
    procedure_type_concept_id INTEGER,
    provider_id INTEGER,
    quantity INTEGER,
    visit_detail_id INTEGER,
    visit_occurrence_id INTEGER
);

COMMENT ON TABLE procedure_occurrence IS '[CLINICAL] The PROCEDURE_OCCURRENCE table contains records of activities or processes ordered by, or carried out by, a healthcare provider on the patient to have a diagnostic or therapeutic purpose. Procedures are present in various data sources in different forms with varying levels of standardization. For example:';';
COMMENT ON COLUMN procedure_occurrence.modifier_concept_id IS 'A foreign key to a Standard Concept identifier for a modifier to the Procedure (e.g. bilateral)';
COMMENT ON COLUMN procedure_occurrence.modifier_source_value IS 'The source code for the qualifier as it appears in the source data.';
COMMENT ON COLUMN procedure_occurrence.person_id IS 'A foreign key identifier to the Person who is subjected to the Procedure. The demographic details of that Person are stored in the PERSON table.';
COMMENT ON COLUMN procedure_occurrence.procedure_concept_id IS 'A foreign key that refers to a standard procedure Concept identifier in the Standardized Vocabularies.';
COMMENT ON COLUMN procedure_occurrence.procedure_date IS 'The date on which the Procedure was performed.';
COMMENT ON COLUMN procedure_occurrence.procedure_datetime IS 'The date and time on which the Procedure was performed.';
COMMENT ON COLUMN procedure_occurrence.procedure_end_date IS 'The date on which the Procedure finished.';
COMMENT ON COLUMN procedure_occurrence.procedure_end_datetime IS 'The date and time on which the Procedure finished.';
COMMENT ON COLUMN procedure_occurrence.procedure_occurrence_id IS 'A system-generated unique identifier for each Procedure Occurrence.';
COMMENT ON COLUMN procedure_occurrence.procedure_source_concept_id IS 'A foreign key to a Procedure Concept that refers to the code used in the source.';
COMMENT ON COLUMN procedure_occurrence.procedure_source_value IS 'The source code for the Procedure as it appears in the source data. This code is mapped to a standard procedure Concept in the Standardized Vocabularies and the original code is, stored here for reference. Procedure source codes are typically ICD-9-Proc, CPT-4, HCPCS or OPCS-4 codes.';
COMMENT ON COLUMN procedure_occurrence.procedure_type_concept_id IS 'A foreign key to the predefined Concept identifier in the Standardized Vocabularies reflecting the type of source data from which the procedure record is derived.';
COMMENT ON COLUMN procedure_occurrence.provider_id IS 'A foreign key to the provider in the provider table who was responsible for carrying out the procedure.';
COMMENT ON COLUMN procedure_occurrence.quantity IS 'The quantity of procedures ordered or administered.';
COMMENT ON COLUMN procedure_occurrence.visit_detail_id IS 'A foreign key to the visit in the visit table during which the Procedure was carried out.';
COMMENT ON COLUMN procedure_occurrence.visit_occurrence_id IS 'A foreign key to the visit in the visit table during which the Procedure was carried out.';

CREATE TABLE provider (
    care_site_id INTEGER,
    dea VARCHAR(20),
    gender_concept_id INTEGER,
    gender_source_concept_id INTEGER,
    gender_source_value VARCHAR(50),
    npi VARCHAR(20),
    provider_id INTEGER,
    provider_name VARCHAR(255),
    provider_source_value VARCHAR(50),
    specialty_concept_id INTEGER,
    specialty_source_concept_id INTEGER,
    specialty_source_value VARCHAR(50),
    year_of_birth INTEGER
);

COMMENT ON TABLE provider IS '[SYSTEM] The PROVIDER table contains a list of uniquely identified healthcare providers. These are individuals providing hands-on healthcare to patients, such as physicians, nurses, midwives, physical therapists etc.';';
COMMENT ON COLUMN provider.care_site_id IS 'A foreign key to the main Care Site where the provider is practicing.';
COMMENT ON COLUMN provider.dea IS 'The Drug Enforcement Administration (DEA) number of the provider.';
COMMENT ON COLUMN provider.gender_concept_id IS 'The gender of the Provider.';
COMMENT ON COLUMN provider.gender_source_concept_id IS 'A foreign key to a Concept that refers to the code used in the source.';
COMMENT ON COLUMN provider.gender_source_value IS 'The gender code for the Provider as it appears in the source data, stored here for reference.';
COMMENT ON COLUMN provider.npi IS 'The National Provider Identifier (NPI) of the provider.';
COMMENT ON COLUMN provider.provider_id IS 'A unique identifier for each Provider.';
COMMENT ON COLUMN provider.provider_name IS 'A description of the Provider.';
COMMENT ON COLUMN provider.provider_source_value IS 'The identifier used for the Provider in the source data, stored here for reference.';
COMMENT ON COLUMN provider.specialty_concept_id IS 'A foreign key to a Standard Specialty Concept ID in the Standardized Vocabularies.';
COMMENT ON COLUMN provider.specialty_source_concept_id IS 'A foreign key to a Concept that refers to the code used in the source.';
COMMENT ON COLUMN provider.specialty_source_value IS 'The source code for the Provider specialty as it appears in the source data, stored here for reference.';
COMMENT ON COLUMN provider.year_of_birth IS 'The year of birth of the Provider.';

CREATE TABLE relationship (
    defines_ancestry VARCHAR(1),
    is_hierarchical VARCHAR(1),
    relationship_concept_id INTEGER,
    relationship_id VARCHAR(20),
    relationship_name VARCHAR(255),
    reverse_relationship_id VARCHAR(20)
);

COMMENT ON TABLE relationship IS '[VOCABULARY] The RELATIONSHIP table provides a reference list of all types of relationships that can be used to associate any two concepts in the CONCEPT_RELATIONSHP table.';';
COMMENT ON COLUMN relationship.defines_ancestry IS 'Defines whether a hierarchical relationship contributes to the concept_ancestor table. These are subsets of the hierarchical relationships. Valid values are 1 or 0.';
COMMENT ON COLUMN relationship.is_hierarchical IS 'Defines whether a relationship defines concepts into classes or hierarchies. Values are 1 for hierarchical relationship or 0 if not.';
COMMENT ON COLUMN relationship.relationship_concept_id IS 'A foreign key that refers to an identifier in the CONCEPT table for the unique relationship concept.';
COMMENT ON COLUMN relationship.relationship_id IS 'The type of relationship captured by the relationship record.';
COMMENT ON COLUMN relationship.relationship_name IS 'The text that describes the relationship type.';
COMMENT ON COLUMN relationship.reverse_relationship_id IS 'The identifier for the relationship used to define the reverse relationship between two concepts.';

CREATE TABLE source_to_concept_map (
    invalid_reason VARCHAR(1),
    source_code VARCHAR(50),
    source_code_description VARCHAR(255),
    source_concept_id INTEGER,
    source_vocabulary_id VARCHAR(20),
    target_concept_id INTEGER,
    target_vocabulary_id VARCHAR(20),
    valid_end_date DATE,
    valid_start_date DATE
);

COMMENT ON TABLE source_to_concept_map IS '[VOCABULARY] The source to concept map table is a legacy data structure within the OMOP Common Data Model, recommended for use in ETL processes to maintain local source codes which are not available as Concepts in the Standardized Vocabularies, and to establish mappings for each source code into a Standard Concept as target_concept_ids that can be used to populate the Common Data Model tables. The SOURCE_TO_CONCEPT_MAP table is no longer populated with content within the Standardized Vocabularies published to the OMOP community.';';
COMMENT ON COLUMN source_to_concept_map.invalid_reason IS 'Reason the mapping instance was invalidated. Possible values are D (deleted), U (replaced with an update) or NULL when valid_end_date has the default value.';
COMMENT ON COLUMN source_to_concept_map.source_code IS 'The source code being translated into a Standard Concept.';
COMMENT ON COLUMN source_to_concept_map.source_code_description IS 'An optional description for the source code. This is included as a convenience to compare the description of the source code to the name of the concept.';
COMMENT ON COLUMN source_to_concept_map.source_concept_id IS 'A foreign key to the Source Concept that is being translated into a Standard Concept.';
COMMENT ON COLUMN source_to_concept_map.source_vocabulary_id IS 'A foreign key to the VOCABULARY table defining the vocabulary of the source code that is being translated to a Standard Concept.';
COMMENT ON COLUMN source_to_concept_map.target_concept_id IS 'A foreign key to the target Concept to which the source code is being mapped.';
COMMENT ON COLUMN source_to_concept_map.target_vocabulary_id IS 'A foreign key to the VOCABULARY table defining the vocabulary of the target Concept.';
COMMENT ON COLUMN source_to_concept_map.valid_end_date IS 'The date when the mapping instance became invalid because it was deleted or superseded (updated) by a new relationship. Default value is 31-Dec-2099.';
COMMENT ON COLUMN source_to_concept_map.valid_start_date IS 'The date when the mapping instance was first recorded.';

CREATE TABLE specimen (
    anatomic_site_concept_id INTEGER,
    anatomic_site_source_value VARCHAR(50),
    disease_status_concept_id INTEGER,
    disease_status_source_value VARCHAR(50),
    person_id INTEGER,
    quantity NUMERIC,
    specimen_concept_id INTEGER,
    specimen_date DATE,
    specimen_datetime TIMESTAMP,
    specimen_id INTEGER,
    specimen_source_id VARCHAR(50),
    specimen_source_value VARCHAR(50),
    specimen_type_concept_id INTEGER,
    unit_concept_id INTEGER,
    unit_source_value VARCHAR(50)
);

COMMENT ON TABLE specimen IS '[CLINICAL] The specimen domain contains the records identifying biological samples from a person.';';
COMMENT ON COLUMN specimen.anatomic_site_concept_id IS 'A foreign key to a Standard Concept identifier for the anatomic location of specimen collection.';
COMMENT ON COLUMN specimen.anatomic_site_source_value IS 'The information about the anatomic site as detailed in the source.';
COMMENT ON COLUMN specimen.disease_status_concept_id IS 'A foreign key to a Standard Concept identifier for the Disease Status of specimen collection.';
COMMENT ON COLUMN specimen.disease_status_source_value IS 'The information about the disease status as detailed in the source.';
COMMENT ON COLUMN specimen.person_id IS 'A foreign key identifier to the Person for whom the Specimen is recorded.';
COMMENT ON COLUMN specimen.quantity IS 'The amount of specimen collection from the person during the sampling procedure.';
COMMENT ON COLUMN specimen.specimen_concept_id IS 'A foreign key referring to a Standard Concept identifier in the Standardized Vocabularies for the Specimen.';
COMMENT ON COLUMN specimen.specimen_date IS 'The date the specimen was obtained from the Person.';
COMMENT ON COLUMN specimen.specimen_datetime IS 'The date and time on the date when the Specimen was obtained from the person.';
COMMENT ON COLUMN specimen.specimen_id IS 'A unique identifier for each specimen.';
COMMENT ON COLUMN specimen.specimen_source_id IS 'The Specimen identifier as it appears in the source data.';
COMMENT ON COLUMN specimen.specimen_source_value IS 'The Specimen value as it appears in the source data. This value is mapped to a Standard Concept in the Standardized Vocabularies and the original code is, stored here for reference.';
COMMENT ON COLUMN specimen.specimen_type_concept_id IS 'A foreign key referring to the Concept identifier in the Standardized Vocabularies reflecting the system of record from which the Specimen was represented in the source data.';
COMMENT ON COLUMN specimen.unit_concept_id IS 'A foreign key to a Standard Concept identifier for the Unit associated with the numeric quantity of the Specimen collection.';
COMMENT ON COLUMN specimen.unit_source_value IS 'The information about the Unit as detailed in the source.';

CREATE TABLE visit_detail (
    admitted_from_concept_id INTEGER,
    admitted_from_source_value VARCHAR(50),
    care_site_id INTEGER,
    discharged_to_concept_id INTEGER,
    discharged_to_source_value VARCHAR(50),
    person_id INTEGER,
    preceding_visit_detail_id INTEGER,
    provider_id INTEGER,
    visit_detail_concept_id INTEGER,
    visit_detail_end_date DATE,
    visit_detail_end_datetime TIMESTAMP,
    visit_detail_id INTEGER,
    visit_detail_parent_id INTEGER,
    visit_detail_source_concept_id INTEGER,
    visit_detail_source_value VARCHAR(50),
    visit_detail_start_date DATE,
    visit_detail_start_datetime TIMESTAMP,
    visit_detail_type_concept_id INTEGER,
    visit_occurrence_id INTEGER
);

COMMENT ON TABLE visit_detail IS '[CLINICAL] The VISIT_DETAIL table is an optional table used to represents details of each record in the parent visit_occurrence table. For every record in visit_occurrence table there may be 0 or more records in the visit_detail table with a 1:n relationship where n may be 0. The visit_detail table is structurally very similar to visit_occurrence table and belongs to the similar domain as the visit.';';
COMMENT ON COLUMN visit_detail.admitted_from_concept_id IS 'A foreign key to the predefined concept in the Place of Service Vocabulary reflecting the admitting source for a visit.';
COMMENT ON COLUMN visit_detail.admitted_from_source_value IS 'The source code for the admitting source as it appears in the source data.';
COMMENT ON COLUMN visit_detail.care_site_id IS 'A foreign key to the care site in the care site table that was visited.';
COMMENT ON COLUMN visit_detail.discharged_to_concept_id IS 'A foreign key to the predefined concept in the Place of Service Vocabulary reflecting the discharge disposition for a visit.';
COMMENT ON COLUMN visit_detail.discharged_to_source_value IS 'The source code for the discharge disposition as it appears in the source data.';
COMMENT ON COLUMN visit_detail.person_id IS 'A foreign key identifier to the Person for whom the visit is recorded. The demographic details of that Person are stored in the PERSON table.';
COMMENT ON COLUMN visit_detail.preceding_visit_detail_id IS 'A foreign key to the VISIT_DETAIL table of the visit immediately preceding this visit';
COMMENT ON COLUMN visit_detail.provider_id IS 'A foreign key to the provider in the provider table who was associated with the visit.';
COMMENT ON COLUMN visit_detail.visit_detail_concept_id IS 'A foreign key that refers to a visit Concept identifier in the Standardized Vocabularies.';
COMMENT ON COLUMN visit_detail.visit_detail_end_date IS 'The end date of the visit. If this is a one-day visit the end date should match the start date.';
COMMENT ON COLUMN visit_detail.visit_detail_end_datetime IS 'The date and time of the visit end.';
COMMENT ON COLUMN visit_detail.visit_detail_id IS 'A unique identifier for each Person';
COMMENT ON COLUMN visit_detail.visit_detail_parent_id IS 'A foreign key to the VISIT_DETAIL table record to represent the immediate parent visit-detail record.';
COMMENT ON COLUMN visit_detail.visit_detail_source_concept_id IS 'A foreign key to a Concept that refers to the code used in the source.';
COMMENT ON COLUMN visit_detail.visit_detail_source_value IS 'The source code for the visit as it appears in the source data.';
COMMENT ON COLUMN visit_detail.visit_detail_start_date IS 'The start date of the visit.';
COMMENT ON COLUMN visit_detail.visit_detail_start_datetime IS 'The date and time of the visit started.';
COMMENT ON COLUMN visit_detail.visit_detail_type_concept_id IS 'A foreign key to the predefined Concept identifier in the Standardized Vocabularies reflecting the type of source data from which the visit record is derived.';
COMMENT ON COLUMN visit_detail.visit_occurrence_id IS 'A foreign key that refers to the record in the VISIT_OCCURRENCE table. This is a required field, because for every visit_detail is a child of visit_occurrence and cannot exist without a corresponding parent record in visit_occurrence.';

CREATE TABLE visit_occurrence (
    admitted_from_concept_id INTEGER,
    admitted_from_source_value VARCHAR(50),
    care_site_id INTEGER,
    discharged_to_concept_id INTEGER,
    discharged_to_source_value VARCHAR(50),
    person_id INTEGER,
    preceding_visit_occurrence_id INTEGER,
    provider_id INTEGER,
    visit_concept_id INTEGER,
    visit_end_date DATE,
    visit_end_datetime TIMESTAMP,
    visit_occurrence_id INTEGER,
    visit_source_concept_id INTEGER,
    visit_source_value VARCHAR(50),
    visit_start_date DATE,
    visit_start_datetime TIMESTAMP,
    visit_type_concept_id INTEGER
);

COMMENT ON TABLE visit_occurrence IS '[CLINICAL] The VISIT_OCCURRENCE table contains the spans of time a Person continuously receives medical services from one or more providers at a Care Site in a given setting within the health care system. Visits are classified into 4 settings: outpatient care, inpatient confinement, emergency room, and long-term care. Persons may transition between these settings over the course of an episode of care (for example, treatment of a disease onset).';';
COMMENT ON COLUMN visit_occurrence.admitted_from_concept_id IS 'A foreign key to the predefined concept in the Place of Service Vocabulary reflecting the admitting source for a visit.';
COMMENT ON COLUMN visit_occurrence.admitted_from_source_value IS 'The source code for the admitting source as it appears in the source data.';
COMMENT ON COLUMN visit_occurrence.care_site_id IS 'A foreign key to the care site in the care site table that was visited.';
COMMENT ON COLUMN visit_occurrence.discharged_to_concept_id IS 'A foreign key to the predefined concept in the Place of Service Vocabulary reflecting the discharge disposition for a visit.';
COMMENT ON COLUMN visit_occurrence.discharged_to_source_value IS 'The source code for the discharge disposition as it appears in the source data.';
COMMENT ON COLUMN visit_occurrence.person_id IS 'A foreign key identifier to the Person for whom the visit is recorded. The demographic details of that Person are stored in the PERSON table.';
COMMENT ON COLUMN visit_occurrence.preceding_visit_occurrence_id IS 'A foreign key to the VISIT_OCCURRENCE table of the visit immediately preceding this visit';
COMMENT ON COLUMN visit_occurrence.provider_id IS 'A foreign key to the provider in the provider table who was associated with the visit.';
COMMENT ON COLUMN visit_occurrence.visit_concept_id IS 'A foreign key that refers to a visit Concept identifier in the Standardized Vocabularies.';
COMMENT ON COLUMN visit_occurrence.visit_end_date IS 'The end date of the visit. If this is a one-day visit the end date should match the start date.';
COMMENT ON COLUMN visit_occurrence.visit_end_datetime IS 'The date and time of the visit end.';
COMMENT ON COLUMN visit_occurrence.visit_occurrence_id IS 'A unique identifier for each Person';
COMMENT ON COLUMN visit_occurrence.visit_source_concept_id IS 'A foreign key to a Concept that refers to the code used in the source.';
COMMENT ON COLUMN visit_occurrence.visit_source_value IS 'The source code for the visit as it appears in the source data.';
COMMENT ON COLUMN visit_occurrence.visit_start_date IS 'The start date of the visit.';
COMMENT ON COLUMN visit_occurrence.visit_start_datetime IS 'The date and time of the visit started.';
COMMENT ON COLUMN visit_occurrence.visit_type_concept_id IS 'A foreign key to the predefined Concept identifier in the Standardized Vocabularies reflecting the type of source data from which the visit record is derived.';

CREATE TABLE vocabulary (
    vocabulary_concept_id INTEGER,
    vocabulary_id VARCHAR(20),
    vocabulary_name VARCHAR(255),
    vocabulary_reference VARCHAR(255),
    vocabulary_version VARCHAR(255)
);

COMMENT ON TABLE vocabulary IS '[VOCABULARY] The VOCABULARY table includes a list of the Vocabularies collected from various sources or created de novo by the OMOP community. This reference table is populated with a single record for each Vocabulary source and includes a descriptive name and other associated attributes for the Vocabulary.';';
COMMENT ON COLUMN vocabulary.vocabulary_concept_id IS 'A foreign key that refers to a standard concept identifier in the CONCEPT table for the Vocabulary the VOCABULARY record belongs to.';
COMMENT ON COLUMN vocabulary.vocabulary_id IS 'A unique identifier for each Vocabulary, such as ICD9CM, SNOMED, Visit.';
COMMENT ON COLUMN vocabulary.vocabulary_name IS 'The name describing the vocabulary, for example "International Classification of Diseases, Ninth Revision, Clinical Modification, Volume 1 and 2 (NCHS)" etc.';
COMMENT ON COLUMN vocabulary.vocabulary_reference IS 'External reference to documentation or available download of the about the vocabulary.';
COMMENT ON COLUMN vocabulary.vocabulary_version IS 'Version of the Vocabulary as indicated in the source.';