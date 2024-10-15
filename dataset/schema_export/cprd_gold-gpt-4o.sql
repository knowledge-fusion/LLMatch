CREATE TABLE consultation_details (
    consultation_identifier INTEGER,
    consultation_type_code INTEGER,
    consultation_duration INTEGER,
    event_date DATE,
    patient_identifier TEXT,
    staff_identifier INTEGER,
    system_entry_date DATE 
);

COMMENT ON TABLE consultation_details IS 'This table contains information related to the type of consultation entered by the General Practitioner, linked to events via the consultation identifier.';
COMMENT ON COLUMN consultation_details.consultation_identifier IS 'Primary Key. The consultation identifier linking events at the same consultation when used in combination with practice identifier. Type: Integer';
COMMENT ON COLUMN consultation_details.consultation_type_code IS 'Type of consultation (e.g., Surgery Consultation, Night Visit, Emergency, etc.). Type: Integer';
COMMENT ON COLUMN consultation_details.consultation_duration IS 'The length of time (minutes) between the opening and closing of the consultation record. Type: Integer';
COMMENT ON COLUMN consultation_details.event_date IS 'Date associated with the event, as entered by the General Practitioner. Type: Date';
COMMENT ON COLUMN consultation_details.patient_identifier IS 'Encrypted unique identifier given to a patient in CPRD GOLD. Type: Text';
COMMENT ON COLUMN consultation_details.staff_identifier IS 'The identifier of the practice staff member entering the data. A value of 0 indicates that the staff identifier is unknown. Type: Integer';
COMMENT ON COLUMN consultation_details.system_entry_date IS 'Date the event was entered into the system. Type: Date';

CREATE TABLE general_practice_test_records (
    consultation_identifier INTEGER,
    consultation_type_code INTEGER,
    entity_type_identifier INTEGER,
    event_date DATE,
    medical_code INTEGER,
    patient_identifier TEXT,
    snomed_description_identifier TEXT,
    snomed_postcoordinated_expression TEXT,
    snomed_concept_identifier TEXT,
    snomed_mapping_assurance BOOLEAN,
    snomed_mapping_indicative BOOLEAN,
    snomed_mapping_type INTEGER,
    snomed_mapping_version INTEGER,
    staff_identifier INTEGER,
    system_entry_date DATE 
);

COMMENT ON TABLE general_practice_test_records IS 'This table contains records of test data entered into the General Practice (GP) system, coded using medical terminology. Test types are identified by different entity types, each with varying data fields.';
COMMENT ON COLUMN general_practice_test_records.consultation_identifier IS 'Primary Key. Identifier that connects consultation information. Type: INTEGER';
COMMENT ON COLUMN general_practice_test_records.consultation_type_code IS 'Code representing the category of event recorded within the GP system. Type: INTEGER';
COMMENT ON COLUMN general_practice_test_records.entity_type_identifier IS 'Identifier representing the structured data area in the GP system where the data was entered. Type: INTEGER';
COMMENT ON COLUMN general_practice_test_records.event_date IS 'The date associated with the event as entered by the GP. Type: DATE';
COMMENT ON COLUMN general_practice_test_records.medical_code IS 'Unique code for the medical term selected by the GP. Type: INTEGER';
COMMENT ON COLUMN general_practice_test_records.patient_identifier IS 'Encrypted unique identifier assigned to a patient. Type: TEXT';
COMMENT ON COLUMN general_practice_test_records.snomed_description_identifier IS 'Identifier for the selected SNOMED CT term description. This will be NULL when the mapping type is set to 4. Type: TEXT';
COMMENT ON COLUMN general_practice_test_records.snomed_postcoordinated_expression IS 'A placeholder for SNOMED CT post-coordinated expressions. Not supported in early phases of SNOMED implementation. Type: TEXT';
COMMENT ON COLUMN general_practice_test_records.snomed_concept_identifier IS 'Identifier for the mapped SNOMED CT Concept. Mapping is conducted before data transfer. Type: TEXT';
COMMENT ON COLUMN general_practice_test_records.snomed_mapping_assurance IS 'Indicates verification by a panel of physicians for the Read to SNOMED mapping. Type: BOOLEAN';
COMMENT ON COLUMN general_practice_test_records.snomed_mapping_indicative IS 'Indicates the reliability of the reverse SNOMED CT-Read map. Use specific codes when no direct mapping exists to READ. Type: BOOLEAN';
COMMENT ON COLUMN general_practice_test_records.snomed_mapping_type IS 'Indicates native encoding of the record in the GP system (e.g., Read dictionary or SNOMED CT). Type: INTEGER';
COMMENT ON COLUMN general_practice_test_records.snomed_mapping_version IS 'Version of the READ-SNOMED CT mapping table applied. Type: INTEGER';
COMMENT ON COLUMN general_practice_test_records.staff_identifier IS 'Identifier of the practice staff member entering the data. A value of 0 indicates unknown staff ID. Type: INTEGER';
COMMENT ON COLUMN general_practice_test_records.system_entry_date IS 'The date the event was entered into the GP system. Type: DATE';

CREATE TABLE immunisation_records (
    immunisation_batch_number INTEGER,
    immunisation_compound INTEGER,
    consultation_identifier INTEGER,
    consultation_type_code INTEGER,
    event_date DATE,
    immunisation_component_type INTEGER,
    medical_code INTEGER,
    administration_method INTEGER,
    patient_identifier TEXT,
    immunisation_reason INTEGER,
    snomed_description_identifier TEXT,
    snomed_postcoordinated_expression TEXT,
    snomed_concept_identifier TEXT,
    snomed_mapping_assurance BOOLEAN,
    snomed_mapping_indicative BOOLEAN,
    snomed_mapping_type INTEGER,
    snomed_mapping_version INTEGER,
    immunisation_location INTEGER,
    staff_identifier INTEGER,
    immunisation_stage INTEGER,
    immunisation_status INTEGER,
    system_entry_date DATE 
);

COMMENT ON TABLE immunisation_records IS 'This table contains detailed records of immunisations from the GP system, including batch numbers, types, methods, and SNOMED codes.';
COMMENT ON COLUMN immunisation_records.immunisation_batch_number IS 'Immunisation batch number. Type: Integer';
COMMENT ON COLUMN immunisation_records.immunisation_compound IS 'Immunisation compound administered, which may be a single or multicomponent preparation (e.g., MMR). Type: Integer';
COMMENT ON COLUMN immunisation_records.consultation_identifier IS 'Foreign Key. Identifier allowing retrieval of consultation information when combined with practice identifier. Type: Integer';
COMMENT ON COLUMN immunisation_records.consultation_type_code IS 'Code representing the category of event recorded within the GP system (e.g., intervention). Type: Integer';
COMMENT ON COLUMN immunisation_records.event_date IS 'Date associated with the event, as entered by the GP. Type: Date';
COMMENT ON COLUMN immunisation_records.immunisation_component_type IS 'Individual components of an immunisation (e.g., Mumps, Rubella, Measles). Type: Integer';
COMMENT ON COLUMN immunisation_records.medical_code IS 'CPRD unique code for the medical term selected by the GP. Type: Integer';
COMMENT ON COLUMN immunisation_records.administration_method IS 'Route of administration for the immunisation (e.g., Oral, Intramuscular). Type: Integer';
COMMENT ON COLUMN immunisation_records.patient_identifier IS 'Encrypted unique identifier assigned to a patient in CPRD GOLD. Type: Text';
COMMENT ON COLUMN immunisation_records.immunisation_reason IS 'Reason for administering the immunisation (e.g., Routine measure). Type: Integer';
COMMENT ON COLUMN immunisation_records.snomed_description_identifier IS 'SNOMED CT description ID of the selected term, if applicable. Null when map type is 4 (data entered as Read code). Type: Text';
COMMENT ON COLUMN immunisation_records.snomed_postcoordinated_expression IS 'Placeholder for SNOMED CT post-coordinated expressions (not supported in early phases of SNOMED implementation). Type: Text';
COMMENT ON COLUMN immunisation_records.snomed_concept_identifier IS 'Mapped SNOMED CT Concept ID, varying by mapping version used. Type: Text';
COMMENT ON COLUMN immunisation_records.snomed_mapping_assurance IS 'Indicates if the Read to SNOMED mapping is verified by a panel of physicians. Type: Boolean';
COMMENT ON COLUMN immunisation_records.snomed_mapping_indicative IS 'Indicates the reliability of the reverse SNOMED CT-Read map, used for determining direct SNOMED CT to Read code mappings. Type: Boolean';
COMMENT ON COLUMN immunisation_records.snomed_mapping_type IS 'Indicates the native encoding of the record in the Vision software (4 = Read dictionary, 5 = SNOMED CT). Type: Integer';
COMMENT ON COLUMN immunisation_records.snomed_mapping_version IS 'Version of the READ-SNOMED CT mapping table applied. Type: Integer';
COMMENT ON COLUMN immunisation_records.immunisation_location IS 'Location where the immunisation was administered (e.g., In this practice). Type: Integer';
COMMENT ON COLUMN immunisation_records.staff_identifier IS 'Identifier of the practice staff member entering the data. A value of 0 indicates unknown staff identifier. Type: Integer';
COMMENT ON COLUMN immunisation_records.immunisation_stage IS 'Stage of the immunisation given (e.g., 1, 2, B2). Type: Integer';
COMMENT ON COLUMN immunisation_records.immunisation_status IS 'Status of the immunisation (e.g., Advised, Given, Refusal). Type: Integer';
COMMENT ON COLUMN immunisation_records.system_entry_date IS 'Date the event was entered into the Vision system. Type: Date';

CREATE TABLE medical_history_events (
    additional_details_identifier INTEGER,
    consultation_identifier INTEGER,
    consultation_type_code INTEGER,
    entity_type_identifier INTEGER,
    episode_type INTEGER,
    event_date DATE,
    medical_code INTEGER,
    patient_identifier TEXT,
    snomed_description_identifier TEXT,
    snomed_postcoordinated_expression TEXT,
    snomed_concept_identifier TEXT,
    snomed_mapping_assurance BOOLEAN,
    snomed_mapping_indicative BOOLEAN,
    snomed_mapping_type INTEGER,
    snomed_mapping_version INTEGER,
    staff_identifier INTEGER,
    system_entry_date DATE 
);

COMMENT ON TABLE medical_history_events IS 'This table contains medical history events including symptoms, signs, and diagnoses recorded in the general practitioner system. The data is coded using Read codes with prospective mapping to Systematized Nomenclature of Medicine Clinical Terms (SNOMED CT) codes since April 2018.';
COMMENT ON COLUMN medical_history_events.additional_details_identifier IS 'Primary Key. Identifier that allows additional information to be retrieved for this event when used in combination with practice_identifier. A value of 0 signifies no additional information is associated with the event. Type: Integer';
COMMENT ON COLUMN medical_history_events.consultation_identifier IS 'Foreign Key. Identifier that allows consultation details to be retrieved when used in combination with practice_identifier. Type: Integer';
COMMENT ON COLUMN medical_history_events.consultation_type_code IS 'Code for the category of the event recorded within the general practitioner system (e.g., diagnosis or symptom). Type: Integer';
COMMENT ON COLUMN medical_history_events.entity_type_identifier IS 'Identifier representing the structured data area in the Vision system where the data was entered. Type: Integer';
COMMENT ON COLUMN medical_history_events.episode_type IS 'Episode type for a specific clinical event. Type: Integer';
COMMENT ON COLUMN medical_history_events.event_date IS 'Date associated with the event, as entered by the general practitioner. Type: Date, Format: DD/MM/YYYY';
COMMENT ON COLUMN medical_history_events.medical_code IS 'Unique code for the medical term selected by the general practitioner. Type: Integer';
COMMENT ON COLUMN medical_history_events.patient_identifier IS 'Encrypted unique identifier given to a patient in the CPRD GOLD dataset. Type: Text';
COMMENT ON COLUMN medical_history_events.snomed_description_identifier IS 'Contains the description ID of the selected SNOMED CT term when direct selection and entry of SNOMED CT terms is permitted. This field will be NULL when the map type is 4 (data entered as Read code). Type: Text';
COMMENT ON COLUMN medical_history_events.snomed_postcoordinated_expression IS 'A placeholder for SNOMED CT post-coordinated expressions. Not supported in the early phases of SNOMED implementation. Type: Text';
COMMENT ON COLUMN medical_history_events.snomed_concept_identifier IS 'The mapped SNOMED CT Concept ID. Mapping is conducted before data transfer and will vary by mapping version used. Type: Text';
COMMENT ON COLUMN medical_history_events.snomed_mapping_assurance IS 'Indicates whether the Read to SNOMED mapping has been verified by a panel of physicians. Type: Boolean';
COMMENT ON COLUMN medical_history_events.snomed_mapping_indicative IS 'Indicates the reliability of the reverse SNOMED CT to Read mapping. If SNOMED CT codes do not have a direct mapping to Read, the code 'Rz…00' will be used. Reserved for use when systems write SNOMED CT terms natively. Type: Boolean';
COMMENT ON COLUMN medical_history_events.snomed_mapping_type IS 'Indicates the native encoding of the record in the Vision software (4 = term selected from Read dictionary, 5 = term selected from SNOMED CT). Type: Integer';
COMMENT ON COLUMN medical_history_events.snomed_mapping_version IS 'The version of the READ to SNOMED CT mapping table applied. Type: Integer';
COMMENT ON COLUMN medical_history_events.staff_identifier IS 'Identifier of the practice staff member entering the data. A value of 0 indicates that the staff identifier is unknown. Type: Integer';
COMMENT ON COLUMN medical_history_events.system_entry_date IS 'Date the event was entered into the Vision system. Type: Date, Format: DD/MM/YYYY';

CREATE TABLE patient_information (
    acceptable_patient_flag INTEGER,
    capitation_supplement_level INTEGER,
    child_health_surveillance_registration_date DATE,
    child_health_surveillance_registered INTEGER,
    current_registration_date DATE,
    death_date DATE,
    family_number INTEGER,
    first_registration_date DATE,
    patient_gender INTEGER,
    internal_transfer_count INTEGER,
    marital_status INTEGER,
    birth_month INTEGER,
    patient_identifier TEXT,
    prescription_exemption_type INTEGER,
    registration_gap_days INTEGER,
    registration_status INTEGER,
    transfer_out_date DATE,
    transfer_out_reason INTEGER,
    vamp_identifier INTEGER,
    birth_year INTEGER 
);

COMMENT ON TABLE patient_information IS 'This table contains basic demographic and registration details of patients.';
COMMENT ON COLUMN patient_information.acceptable_patient_flag IS 'Flag to indicate whether the patient has met certain quality standards: 1 = acceptable, 0 = unacceptable. Type: Integer, Format: 1, Mapping: Boolean';
COMMENT ON COLUMN patient_information.capitation_supplement_level IS 'Level of capitation supplement the patient has currently (e.g. low, medium, high). Type: Integer, Format: 3, Mapping: Lookup CAP';
COMMENT ON COLUMN patient_information.child_health_surveillance_registration_date IS 'Date of registration with Child Health Surveillance. Type: Date, Format: DD/MM/YYYY, Mapping: DD/MM/YYYY';
COMMENT ON COLUMN patient_information.child_health_surveillance_registered IS 'Indicates whether the patient is registered with Child Health Surveillance. Type: Integer, Format: 1, Mapping: Lookup Y_N';
COMMENT ON COLUMN patient_information.current_registration_date IS 'Date when the patient’s current period of registration with the practice began. If there are no transferred out periods, the date equals the first registration date. Type: Date, Format: DD/MM/YYYY, Mapping: DD/MM/YYYY';
COMMENT ON COLUMN patient_information.death_date IS 'Date of death of the patient, derived using an internal algorithm. Type: Date, Format: DD/MM/YYYY, Mapping: DD/MM/YYYY';
COMMENT ON COLUMN patient_information.family_number IS 'Family identification number. Type: Integer, Format: 20, Mapping: None';
COMMENT ON COLUMN patient_information.first_registration_date IS 'Date the patient first registered with the practice. If the patient has only temporary records, it is the date of the first encounter. Type: Date, Format: DD/MM/YYYY, Mapping: DD/MM/YYYY';
COMMENT ON COLUMN patient_information.patient_gender IS 'Patient’s gender. Type: Integer, Format: 1, Mapping: Lookup SEX';
COMMENT ON COLUMN patient_information.internal_transfer_count IS 'Number of internal transfer out periods in the patient’s registration details. Type: Integer, Format: 2, Mapping: None';
COMMENT ON COLUMN patient_information.marital_status IS 'Patient’s current marital status. Type: Integer, Format: 3, Mapping: Lookup MAR';
COMMENT ON COLUMN patient_information.birth_month IS 'Patient’s month of birth (for those aged under 16). 0 indicates no month set. Type: Integer, Format: 2, Mapping: None';
COMMENT ON COLUMN patient_information.patient_identifier IS 'Encrypted unique identifier given to a patient. Type: Text, Format: 20, Mapping: None';
COMMENT ON COLUMN patient_information.prescription_exemption_type IS 'Type of prescribing exemption the patient has currently (e.g. medical / maternity). Type: Integer, Format: 3, Mapping: Lookup PEX';
COMMENT ON COLUMN patient_information.registration_gap_days IS 'Number of days missing in the patient’s registration details. Type: Integer, Format: 5, Mapping: PAT_GAP2';
COMMENT ON COLUMN patient_information.registration_status IS 'Status of registration detailing gaps and temporary periods. Type: Integer, Format: 2, Mapping: PAT_STAT1';
COMMENT ON COLUMN patient_information.transfer_out_date IS 'Date the patient transferred out of the practice, if relevant. Empty for patients who have not transferred out. Type: Date, Format: DD/MM/YYYY, Mapping: DD/MM/YYYY';
COMMENT ON COLUMN patient_information.transfer_out_reason IS 'Reason the patient transferred out of the practice, including 'Death' as an option. Type: Integer, Format: 3, Mapping: Lookup TRA';
COMMENT ON COLUMN patient_information.vamp_identifier IS 'Old VAMP system identifier for the patient. Type: Integer, Format: 20, Mapping: None';
COMMENT ON COLUMN patient_information.birth_year IS 'Patient’s year of birth, e.g., 1984. Type: Integer, Format: 4, Mapping: None';

CREATE TABLE practice_details (
    last_collection_date DATE,
    practice_identifier INTEGER,
    practice_region INTEGER,
    up_to_standard_date DATE 
);

COMMENT ON TABLE practice_details IS 'This table contains details of each medical practice, including region information and dates of data collection.';
COMMENT ON COLUMN practice_details.last_collection_date IS 'The date of the last collection for the practice. Type: Date, Format: DD/MM/YYYY';
COMMENT ON COLUMN practice_details.practice_identifier IS 'Primary Key. A unique encrypted identifier for each practice in the CPRD GOLD system. Type: Integer, Format: 5';
COMMENT ON COLUMN practice_details.practice_region IS 'Indicates the region in the UK where the practice is based. This denotes the ONS Region for practices within England, and the country (Wales, Scotland, or Northern Ireland) for practices in other parts. Type: Integer, Format: 3';
COMMENT ON COLUMN practice_details.up_to_standard_date IS 'The date at which the practice data is deemed to be of research quality, derived by a CPRD algorithm considering practice death recording and data gaps. Type: Date, Format: DD/MM/YYYY';

CREATE TABLE practice_staff_details (
    staff_gender INTEGER,
    staff_role INTEGER,
    staff_identifier INTEGER 
);

COMMENT ON TABLE practice_staff_details IS 'This table contains details of practice staff members, with one record per staff member.';
COMMENT ON COLUMN practice_staff_details.staff_gender IS 'The gender of the staff member. Type: Integer, Mapping: Lookup SEX';
COMMENT ON COLUMN practice_staff_details.staff_role IS 'The role of the staff member who created the event. Type: Integer, Mapping: Lookup ROL';
COMMENT ON COLUMN practice_staff_details.staff_identifier IS 'A unique identifier assigned to the practice staff member entering the data. Type: Integer';

CREATE TABLE prescription_details (
    bnf_code INTEGER,
    consultation_identifier INTEGER,
    dosage_identifier TEXT,
    drug_dmd_code TEXT,
    event_date DATE,
    issue_sequence_number INTEGER,
    number_of_days INTEGER,
    number_of_packs INTEGER,
    pack_type INTEGER,
    patient_identifier TEXT,
    as_required BOOLEAN,
    product_code INTEGER,
    total_quantity INTEGER,
    staff_identifier INTEGER,
    system_entry_date DATE 
);

COMMENT ON TABLE prescription_details IS 'This table contains details of all prescriptions, including drugs and appliances, issued by General Practitioners. It is recorded using the Gemscript product code system and includes information such as dosage, event dates, and more.';
COMMENT ON COLUMN prescription_details.bnf_code IS 'Code representing the chapter and section from the British National Formulary for the selected product. Type: Integer';
COMMENT ON COLUMN prescription_details.consultation_identifier IS 'Identifier that allows information about the consultation to be retrieved. Type: Integer';
COMMENT ON COLUMN prescription_details.dosage_identifier IS 'Identifier that allows dosage information on the event to be retrieved. Use the Common Dosages Lookup to get the anonymized dosage text and extracted numerical information. Type: Text';
COMMENT ON COLUMN prescription_details.drug_dmd_code IS 'The mapped drug Dictionary of Medicines and Devices code. Type: Text';
COMMENT ON COLUMN prescription_details.event_date IS 'Date associated with the event, as entered by the General Practitioner. Type: Date';
COMMENT ON COLUMN prescription_details.issue_sequence_number IS 'Number indicating if the event is associated with a repeat schedule. A value of 0 implies it is not part of a repeat prescription, while a value 1 or higher indicates the issue number within a repeat schedule. Type: Integer';
COMMENT ON COLUMN prescription_details.number_of_days IS 'Number of treatment days prescribed for a specific therapy event. Type: Integer';
COMMENT ON COLUMN prescription_details.number_of_packs IS 'Number of individual product packs prescribed for a specific therapy event. Type: Integer';
COMMENT ON COLUMN prescription_details.pack_type IS 'Pack size or type of the prescribed product. Type: Integer';
COMMENT ON COLUMN prescription_details.patient_identifier IS 'Encrypted unique identifier given to a patient in CPRD GOLD. Type: Text';
COMMENT ON COLUMN prescription_details.as_required IS 'Indicates if the prescription is to be supplied 'as required'. Type: Boolean';
COMMENT ON COLUMN prescription_details.product_code IS 'CPRD unique code for the treatment selected by the General Practitioner. Type: Integer';
COMMENT ON COLUMN prescription_details.total_quantity IS 'Total quantity entered by the General Practitioner for the prescribed product. Type: Integer';
COMMENT ON COLUMN prescription_details.staff_identifier IS 'Identifier of the practice staff member entering the data. A value of 0 indicates that the staff identifier is unknown. Type: Integer';
COMMENT ON COLUMN prescription_details.system_entry_date IS 'Date the event was entered into Vision. Type: Date';

CREATE TABLE referral_details (
    attendance_type INTEGER,
    consultation_identifier INTEGER,
    consultation_type_code INTEGER,
    event_date DATE,
    fhsa_specialty_code INTEGER,
    referral_type_code INTEGER,
    medical_code INTEGER,
    nhs_specialty_code INTEGER,
    patient_identifier TEXT,
    snomed_description_identifier TEXT,
    snomed_postcoordinated_expression TEXT,
    snomed_concept_identifier TEXT,
    snomed_mapping_assurance BOOLEAN,
    snomed_mapping_indicative BOOLEAN,
    snomed_mapping_type INTEGER,
    snomed_mapping_version INTEGER,
    referral_source INTEGER,
    staff_identifier INTEGER,
    system_entry_date DATE,
    referral_urgency INTEGER 
);

COMMENT ON TABLE referral_details IS 'This table contains patient referral details recorded on the General Practitioner system, including patient referrals to external care centers such as hospitals, and includes information on specialty and referral type.';
COMMENT ON COLUMN referral_details.attendance_type IS 'Category describing whether the referral event is the first visit, a follow-up, etc. Type: Integer, Mapping: Lookup Attendance';
COMMENT ON COLUMN referral_details.consultation_identifier IS 'Identifier that allows retrieval of consultation information when used in combination with practice identifier. Type: Integer, Mapping: Link Consultation Table';
COMMENT ON COLUMN referral_details.consultation_type_code IS 'Code for the category of event recorded within the General Practitioner system, such as management or administration. Type: Integer, Mapping: Lookup EventType';
COMMENT ON COLUMN referral_details.event_date IS 'Date associated with the event, as entered by the General Practitioner. Type: Date, Format: DD/MM/YYYY';
COMMENT ON COLUMN referral_details.fhsa_specialty_code IS 'Referral specialty according to the Family Health Services Authority classification. Type: Integer, Mapping: Lookup Specialty';
COMMENT ON COLUMN referral_details.referral_type_code IS 'Classification of the type of referral, such as Day case or Inpatient. Type: Integer, Mapping: Lookup ReferralType';
COMMENT ON COLUMN referral_details.medical_code IS 'CPRD unique code for the medical term selected by the General Practitioner. Type: Integer, Mapping: Lookup MedicalDictionary';
COMMENT ON COLUMN referral_details.nhs_specialty_code IS 'Referral specialty according to the National Health Service classification. Type: Integer, Mapping: Lookup Department';
COMMENT ON COLUMN referral_details.patient_identifier IS 'Encrypted unique identifier given to a patient in CPRD GOLD. Type: Text';
COMMENT ON COLUMN referral_details.snomed_description_identifier IS 'Description ID of the selected SNOMED CT term when direct selection is permitted. This field will be NULL when map type is 'Read code'. Type: Text';
COMMENT ON COLUMN referral_details.snomed_postcoordinated_expression IS 'Placeholder for SNOMED CT post-coordinated expressions, not supported in early phases of SNOMED implementation. Type: Text';
COMMENT ON COLUMN referral_details.snomed_concept_identifier IS 'Mapped SNOMED CT Concept ID, varies by mapping version used. Type: Text';
COMMENT ON COLUMN referral_details.snomed_mapping_assurance IS 'Indicates whether the Read to SNOMED mapping has been verified by a panel of physicians. Type: Boolean';
COMMENT ON COLUMN referral_details.snomed_mapping_indicative IS 'Reserved for use when systems write SNOMED CT terms natively; indicates the reliability of the reverse mapping. Type: Boolean';
COMMENT ON COLUMN referral_details.snomed_mapping_type IS 'Indicates the native encoding of the record in Vision software (4 = term from Read dictionary, 5 = term from SNOMED CT). Type: Integer';
COMMENT ON COLUMN referral_details.snomed_mapping_version IS 'The version of the READ-SNOMED CT mapping table applied. Type: Integer';
COMMENT ON COLUMN referral_details.referral_source IS 'Classification of the source of the referral, e.g., General Practitioner, Self. Type: Integer, Mapping: Lookup Source';
COMMENT ON COLUMN referral_details.staff_identifier IS 'Identifier of the practice staff member entering the data; 0 indicates staff ID is unknown. Type: Integer, Mapping: Link Staff Table';
COMMENT ON COLUMN referral_details.system_entry_date IS 'Date the event was entered into Vision. Type: Date, Format: DD/MM/YYYY';
COMMENT ON COLUMN referral_details.referral_urgency IS 'Classification of the urgency of the referral, e.g., Routine, Urgent. Type: Integer, Mapping: Lookup Urgency';