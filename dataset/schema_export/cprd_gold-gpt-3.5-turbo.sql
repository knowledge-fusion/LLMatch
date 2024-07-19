CREATE TABLE gp_test_record (
    consultation_identifier INTEGER,
    consultation_type INTEGER,
    entity_type INTEGER,
    event_date DATE,
    medical_code INTEGER,
    patient_identifier TEXT,
    snomed_description_id TEXT,
    snomed_expression TEXT,
    snomed_ct_concept_id TEXT,
    snomed_is_assured BOOLEAN,
    snomed_is_indicative BOOLEAN,
    snomed_mapping_type INTEGER,
    snomed_mapping_version INTEGER,
    staff_identifier INTEGER,
    system_date DATE
);

COMMENT ON TABLE gp_test_record IS 'This table contains records of test data on the GP system, coded using Read codes chosen by the GP. Test types are identified by entity types, with varying data fields.';
COMMENT ON COLUMN gp_test_record.consultation_identifier IS 'Primary Key. Identifier that allows information about the consultation to be retrieved, when used in combination with pracid. Type: Integer';
COMMENT ON COLUMN gp_test_record.consultation_type IS 'Code for the category of event recorded within the GP system (e.g. examination). Type: Integer';
COMMENT ON COLUMN gp_test_record.entity_type IS 'Identifier that represents the structured data area in Vision where the data was entered. Type: Integer';
COMMENT ON COLUMN gp_test_record.event_date IS 'Date associated with the event, as entered by the GP. Type: Date';
COMMENT ON COLUMN gp_test_record.medical_code IS 'CPRD unique code for the medical term selected by the GP. Type: Integer';
COMMENT ON COLUMN gp_test_record.patient_identifier IS 'Encrypted unique identifier given to a patient in CPRD GOLD. Type: Text';
COMMENT ON COLUMN gp_test_record.snomed_description_id IS 'When direct selection and entry of SNOMED CT terms is permitted this will contain the description ID of the selected term. This field will be NULL when map type = 4 (data entered as Read code). Type: Text';
COMMENT ON COLUMN gp_test_record.snomed_expression IS 'A placeholder for SNOMED CT post-coordinated expressions. This is not supported in early phases of SNOMED implementation. Type: Text';
COMMENT ON COLUMN gp_test_record.snomed_ct_concept_id IS 'The mapped SNOMED CT Concept ID. Mapping is conducted prior to data transfer and will vary by mapping version used. Type: Text';
COMMENT ON COLUMN gp_test_record.snomed_is_assured IS 'Indicates whether the Read to SNOMED mapping has been verified by a panel of physicians. Type: Boolean';
COMMENT ON COLUMN gp_test_record.snomed_is_indicative IS 'Reserved for use when systems write SNOMED CT terms natively. Used to indicate the reliability of the reverse SNOMED CT-Read map. Where SNOMED CT codes do not have a direct mapping to READ, the code 'Rz'…00' will be utilised. Type: Boolean';
COMMENT ON COLUMN gp_test_record.snomed_mapping_type IS 'Indicates the native encoding of the record in the Vision software (4 = term selected from Read dictionary, 5= term selected from SNOMED CT). Type: Integer';
COMMENT ON COLUMN gp_test_record.snomed_mapping_version IS 'The version of the READ-SNOMED CT mapping table applied. Type: Integer';
COMMENT ON COLUMN gp_test_record.staff_identifier IS 'Identifier of the practice staff member entering the data. A value of 0 indicates that the staffid is unknown. Type: Integer';
COMMENT ON COLUMN gp_test_record.system_date IS 'Date the event was entered into Vision. Type: Date';

CREATE TABLE immunisation_records (
    batch_number INTEGER,
    immunisation_compound INTEGER,
    consultation_identifier INTEGER,
    event_category_code INTEGER,
    event_date DATE,
    immunisation_type INTEGER,
    medical_code INTEGER,
    administration_route INTEGER,
    patient_identifier TEXT,
    administered_reason_code INTEGER,
    snomed_description_id TEXT,
    snomed_expression TEXT,
    snomed_ct_concept_id TEXT,
    snomed_is_assured BOOLEAN,
    snomed_is_indicative BOOLEAN,
    snomed_mapping_type INTEGER,
    snomed_mapping_version INTEGER,
    immunisation_source INTEGER,
    staff_identifier INTEGER,
    immunisation_stage INTEGER,
    immunisation_status INTEGER,
    system_date DATE
);

COMMENT ON TABLE immunisation_records IS 'This table contains details of immunisation records on the GP system.';
COMMENT ON COLUMN immunisation_records.batch_number IS 'A batch number used to track immunisation administration. Type: Integer';
COMMENT ON COLUMN immunisation_records.immunisation_compound IS 'The compound administered which may be a single or multicomponent preparation, e.g. MMR. Type: Integer';
COMMENT ON COLUMN immunisation_records.consultation_identifier IS 'Identifier that allows information about the consultation to be retrieved, when used in combination with pracid. Type: Integer';
COMMENT ON COLUMN immunisation_records.event_category_code IS 'Code for the category of event recorded within the GP system (e.g. intervention). Type: Integer';
COMMENT ON COLUMN immunisation_records.event_date IS 'Date associated with the event, as entered by the GP. Type: Date';
COMMENT ON COLUMN immunisation_records.immunisation_type IS 'The individual components of an immunisation, e.g. Mumps, Rubella, Measles. Type: Integer';
COMMENT ON COLUMN immunisation_records.medical_code IS 'CPRD unique code for the medical term selected by the GP. Type: Integer';
COMMENT ON COLUMN immunisation_records.administration_route IS 'Route of administration for the immunisation, e.g. Oral, Intramuscular. Type: Integer';
COMMENT ON COLUMN immunisation_records.patient_identifier IS 'Encrypted unique identifier given to a patient in CPRD GOLD. Type: Text';
COMMENT ON COLUMN immunisation_records.administered_reason_code IS 'Reason for administering the immunisation, e.g. Routine measure. Type: Integer';
COMMENT ON COLUMN immunisation_records.snomed_description_id IS 'When direct selection and entry of SNOMED CT terms is permitted this will contain the description ID of the selected term. This field will be NULL when map type = 4 (data entered as Read code). Type: Text';
COMMENT ON COLUMN immunisation_records.snomed_expression IS 'A placeholder for SNOMED CT post-coordinated expressions. This is not supported in early phases of SNOMED implementation. Type: Text';
COMMENT ON COLUMN immunisation_records.snomed_ct_concept_id IS 'The mapped SNOMED CT Concept ID. Mapping is conducted prior to data transfer and will vary by mapping version used. Type: Text';
COMMENT ON COLUMN immunisation_records.snomed_is_assured IS 'Indicates whether the Read to SNOMED mapping has been verified by a panel of physicians. Type: Boolean';
COMMENT ON COLUMN immunisation_records.snomed_is_indicative IS 'Reserved for use when systems write SNOMED CT terms natively. Used to indicate the reliability of the reverse SNOMED CT-Read map. Where SNOMED CT codes do not have a direct mapping to READ, the code Rz 600 will be utilised. Type: Boolean';
COMMENT ON COLUMN immunisation_records.snomed_mapping_type IS 'Indicates the native encoding of the record in the Vision software (4 = term selected from Read dictionary, 5= term selected from SNOMED CT). Type: Integer';
COMMENT ON COLUMN immunisation_records.snomed_mapping_version IS 'The version of the READ-SNOMED CT mapping table applied. Type: Integer';
COMMENT ON COLUMN immunisation_records.immunisation_source IS 'Location where the immunisation was administered, e.g. In this practice. Type: Integer';
COMMENT ON COLUMN immunisation_records.staff_identifier IS 'Identifier of the practice staff member entering the data. A value of 0 indicates that the staffid is unknown. Type: Integer';
COMMENT ON COLUMN immunisation_records.immunisation_stage IS 'Stage of the immunisation given, e.g. 1, 2, B2. Type: Integer';
COMMENT ON COLUMN immunisation_records.immunisation_status IS 'Status of the immunisation e.g. Advised, Given, Refusal. Type: Integer';
COMMENT ON COLUMN immunisation_records.system_date IS 'Date the event was entered into Vision. Type: Date';

CREATE TABLE medical_consultation (
    consultation_identifier INTEGER,
    consultation_type INTEGER,
    consultation_duration INTEGER,
    event_date DATE,
    patient_identifier TEXT,
    staff_identifier INTEGER,
    system_date DATE
);

COMMENT ON TABLE medical_consultation IS 'This table contains information related to medical consultation entered by the GP.';
COMMENT ON COLUMN medical_consultation.consultation_identifier IS 'Primary Key. The unique identifier linking events at the same consultation, when used in combination with pracid. Type: Integer';
COMMENT ON COLUMN medical_consultation.consultation_type IS 'Type of consultation (e.g. Surgery Consultation, Night Visit, Emergency etc.). Type: Integer';
COMMENT ON COLUMN medical_consultation.consultation_duration IS 'The length of time (minutes) between the opening, and closing of the consultation record. Type: Integer';
COMMENT ON COLUMN medical_consultation.event_date IS 'The date associated with the event, as entered by the GP. Type: Date';
COMMENT ON COLUMN medical_consultation.patient_identifier IS 'Encrypted unique identifier given to a patient in CPRD GOLD. Type: Text';
COMMENT ON COLUMN medical_consultation.staff_identifier IS 'The identifier of the practice staff member entering the data. A value of 0 indicates that the staffid is unknown. Type: Integer';
COMMENT ON COLUMN medical_consultation.system_date IS 'Date the event was entered into Vision. Type: Date';

CREATE TABLE medical_history (
    additional_details_identifier INTEGER,
    consultation_identifier INTEGER,
    consultation_type INTEGER,
    entity_type INTEGER,
    episode_type INTEGER,
    event_date DATE,
    medical_code INTEGER,
    patient_identifier TEXT,
    snomed_description_id TEXT,
    snomed_expression TEXT,
    snomed_ct_concept_id TEXT,
    snomed_is_assured BOOLEAN,
    snomed_is_indicative BOOLEAN,
    snomed_mapping_type INTEGER,
    snomed_mapping_version INTEGER,
    staff_identifier INTEGER,
    system_date DATE
);

COMMENT ON TABLE medical_history IS 'This table contains medical history events recorded on the GP system, coded using Read codes with prospective mapping to SNOMED CT codes since April 2018.';
COMMENT ON COLUMN medical_history.additional_details_identifier IS 'A unique identifier that allows additional information to be retrieved for this event, when used in combination with pracid. A value of 0 signifies that there is no additional information associated with the event. Type: Integer. Primary Key. Table Mapping: Link Additional Clinical Details table';
COMMENT ON COLUMN medical_history.consultation_identifier IS 'A unique identifier that allows information about the consultation to be retrieved, when used in combination with pracid. Type: Integer. Table Mapping: Link Consultation table';
COMMENT ON COLUMN medical_history.consultation_type IS 'The category of event recorded within the GP system (e.g. diagnosis or symptom). Type: Integer. Format: 3. Table Mapping: Lookup SED';
COMMENT ON COLUMN medical_history.entity_type IS 'A unique identifier that represents the structured data area in Vision where the data was entered. Type: Integer. Format: 5. Table Mapping: Lookup Entity';
COMMENT ON COLUMN medical_history.episode_type IS 'The episode type for a specific clinical event. Type: Integer. Format: 3. Table Mapping: Lookup EPI';
COMMENT ON COLUMN medical_history.event_date IS 'The date associated with the event, as entered by the GP. Type: Date. Format: DD/MM/YYYY. Table Mapping: DD/MM/YYYY';
COMMENT ON COLUMN medical_history.medical_code IS 'CPRD unique code for the medical term selected by the GP. Type: Integer. Format: 20. Table Mapping: Lookup Medical Dictionary';
COMMENT ON COLUMN medical_history.patient_identifier IS 'Encrypted unique identifier given to a patient in CPRD GOLD. Type: Text. Format: 20.';
COMMENT ON COLUMN medical_history.snomed_description_id IS 'When direct selection and entry of SNOMED CT terms is permitted this will contain the description ID of the selected term. This field will be NULL when map type = 4 (data entered as Read code). Type: Text. Format: 20.';
COMMENT ON COLUMN medical_history.snomed_expression IS 'A placeholder for SNOMED CT post-coordinated expressions. This is not supported in early phases of SNOMED implementation. Type: Text. Format: 20.';
COMMENT ON COLUMN medical_history.snomed_ct_concept_id IS 'The mapped SNOMED CT Concept ID. Mapping is conducted prior to data transfer and will vary by mapping version used. Type: Text. Format: 20.';
COMMENT ON COLUMN medical_history.snomed_is_assured IS 'Indicates whether the Read to SNOMED mapping has been verified by a panel of physicians. Type: Boolean. Format: 1.';
COMMENT ON COLUMN medical_history.snomed_is_indicative IS 'Reserved for use when systems write SNOMED CT terms natively. Used to indicate the reliability of the reverse SNOMED CT-Read map. Where SNOMED CT codes do not have a direct mapping to READ, the code ‘Rz…00’ will be utilised. Type: Boolean. Format: 1.';
COMMENT ON COLUMN medical_history.snomed_mapping_type IS 'Indicates the native encoding of the record in the Vision software. Type: Integer. Format: 1.';
COMMENT ON COLUMN medical_history.snomed_mapping_version IS 'The version of the READ-SNOMED CT mapping table applied. Type: Integer. Format: 10.';
COMMENT ON COLUMN medical_history.staff_identifier IS 'Identifier of the practice staff member entering the data. A value of 0 indicates that the staffid is unknown. Type: Integer. Format: 20. Table Mapping: Link Staff table';
COMMENT ON COLUMN medical_history.system_date IS 'The date the event was entered into Vision. Type: Date. Format: DD/MM/YYYY. Table Mapping: DD/MM/YYYY';

CREATE TABLE patient_information (
    acceptable_patient_flag INTEGER,
    capitation_supplement_level INTEGER,
    child_health_surveillance_registration_date DATE,
    child_health_surveillance_registered_flag INTEGER,
    current_registration_date DATE,
    death_date DATE,
    family_number INTEGER,
    first_registration_date DATE,
    patient_gender INTEGER,
    internal_transfer_out_periods_number INTEGER,
    patient_marital_status INTEGER,
    birth_month INTEGER,
    patient_identifier TEXT,
    prescription_exemption_type INTEGER,
    registration_gaps_days INTEGER,
    registration_status INTEGER,
    transfer_out_date DATE,
    transfer_out_reason INTEGER,
    vamp_identifier INTEGER,
    birth_year INTEGER
);

COMMENT ON TABLE patient_information IS 'This table contains basic patient demographics and registration details.';
COMMENT ON COLUMN patient_information.acceptable_patient_flag IS 'Flag to indicate whether the patient has met certain quality standards. Type: Integer. Format: 1. Primary Key. Mapping: Boolean';
COMMENT ON COLUMN patient_information.capitation_supplement_level IS 'Level of capitation supplement the patient has currently (e.g. low, medium, high). Type: Integer. Format: 3. Mapping: Lookup CAP';
COMMENT ON COLUMN patient_information.child_health_surveillance_registration_date IS 'Date of registration with Child Health Surveillance. Type: Date. Format: DD/MM/YYYY. Mapping: DD/MM/YYYY';
COMMENT ON COLUMN patient_information.child_health_surveillance_registered_flag IS 'Value to indicate whether the patient is registered with Child Health Surveillance. Type: Integer. Format: 1. Mapping: Lookup Y_N';
COMMENT ON COLUMN patient_information.current_registration_date IS 'Date the patient’s current period of registration with the practice began (date of the first ‘permanent’ record after the latest transferred out period). If there are no ‘transferred out periods’, the date is equal to ‘frd’. Type: Date. Format: DD/MM/YYYY. Mapping: DD/MM/YYYY';
COMMENT ON COLUMN patient_information.death_date IS 'Date of death of patient – derived using a CPRD algorithm. Type: Date. Format: DD/MM/YYYY. Mapping: DD/MM/YYYY';
COMMENT ON COLUMN patient_information.family_number IS 'Family ID number. Type: Integer. Format: 20. Mapping: None';
COMMENT ON COLUMN patient_information.first_registration_date IS 'Date the patient first registered with the practice. If patient only has ‘temporary’ records, the date is the first encounter with the practice; if patient has ‘permanent’ records it is the date of the first ‘permanent’ record (excluding preceding temporary records). Type: Date. Format: DD/MM/YYYY. Mapping: DD/MM/YYYY';
COMMENT ON COLUMN patient_information.patient_gender IS 'Patient’s gender. Type: Integer. Format: 1. Mapping: Lookup SEX';
COMMENT ON COLUMN patient_information.internal_transfer_out_periods_number IS 'Number of internal transfer out periods, in the patient’s registration details. Type: Integer. Format: 2. Mapping: None';
COMMENT ON COLUMN patient_information.patient_marital_status IS 'Patient’s current marital status. Type: Integer. Format: 3. Mapping: Lookup MAR';
COMMENT ON COLUMN patient_information.birth_month IS 'Patient’s month of birth (for those aged under 16). 0 indicates no month set. Type: Integer. Format: 2. Mapping: None';
COMMENT ON COLUMN patient_information.patient_identifier IS 'Encrypted unique identifier given to a patient in CPRD GOLD. Type: Text. Format: 20. Mapping: None';
COMMENT ON COLUMN patient_information.prescription_exemption_type IS 'Type of prescribing exemption the patient has currently (e.g. medical / maternity). Type: Integer. Format: 3. Mapping: Lookup PEX';
COMMENT ON COLUMN patient_information.registration_gaps_days IS 'Number of days missing in the patient’s registration details. Type: Integer. Format: 5. Mapping: PAT_GAP2';
COMMENT ON COLUMN patient_information.registration_status IS 'Status of registration detailing gaps and temporary patients. Type: Integer. Format: 2. Mapping: PAT_STAT1';
COMMENT ON COLUMN patient_information.transfer_out_date IS 'Date the patient transferred out of the practice, if relevant. Empty for patients who have not transferred out. Type: Date. Format: DD/MM/YYYY. Mapping: DD/MM/YYYY';
COMMENT ON COLUMN patient_information.transfer_out_reason IS 'Reason the patient transferred out of the practice. Includes 'Death' as an option. Type: Integer. Format: 3. Mapping: Lookup TRA';
COMMENT ON COLUMN patient_information.vamp_identifier IS 'Old VM id for the patient when the practice was using the VAMP system. Type: Integer. Format: 20. Mapping: None';
COMMENT ON COLUMN patient_information.birth_year IS 'Patient’s year of birth. This is actual year of birth e.g. 1984. Type: Integer. Format: 4. Mapping: None';

CREATE TABLE patient_referral (
    referral_attendance_type INTEGER,
    consultation_identifier INTEGER,
    consultation_type INTEGER,
    referral_event_date DATE,
    fhsa_speciality INTEGER,
    referral_type INTEGER,
    medical_code INTEGER,
    nhs_speciality INTEGER,
    patient_identifier TEXT,
    snomed_description_id TEXT,
    snomed_expression TEXT,
    snomed_ct_concept_id TEXT,
    snomed_is_assured BOOLEAN,
    snomed_is_indicative BOOLEAN,
    snomed_mapping_type INTEGER,
    snomed_mapping_version INTEGER,
    immunisation_source INTEGER,
    staff_identifier INTEGER,
    system_date DATE,
    referral_urgency INTEGER
);

COMMENT ON TABLE patient_referral IS 'This table contains details of patient referrals to external care centres such as hospitals. It includes specialty, referral type, and referral source.';
COMMENT ON COLUMN patient_referral.referral_attendance_type IS 'Type: Integer(2). A category describing whether the referral event is the first visit, a follow-up, etc.';
COMMENT ON COLUMN patient_referral.consultation_identifier IS 'Type: Integer(20). Primary Key. An identifier that allows information about the consultation to be retrieved when used in combination with pracid. Linked to consultation table.';
COMMENT ON COLUMN patient_referral.consultation_type IS 'Type: Integer(3). A code for the category of event recorded within the GP system (e.g., management or administration). Use Sedentary to lookup.';
COMMENT ON COLUMN patient_referral.referral_event_date IS 'Type: Date (DD/MM/YYYY). The date associated with the event as entered by the GP.';
COMMENT ON COLUMN patient_referral.fhsa_speciality IS 'Type: Integer(3). The referral speciality according to the Family Health Services Authority (FHSA) classification. Use Specialty to lookup.';
COMMENT ON COLUMN patient_referral.referral_type IS 'Type: Integer(2). The classification of the type of referral, e.g. Day case, In patient. Use Referral From Type to lookup.';
COMMENT ON COLUMN patient_referral.medical_code IS 'Type: Integer(20). A CPRD unique code for the medical term selected by the GP. Use Medical Dictionary to lookup.';
COMMENT ON COLUMN patient_referral.nhs_speciality IS 'Type: Integer(3). The referral speciality according to the National Health Service (NHS) classification. Use Department to lookup.';
COMMENT ON COLUMN patient_referral.patient_identifier IS 'Type: Text (20). Encrypted unique identifier given to a patient in CPRD GOLD.';
COMMENT ON COLUMN patient_referral.snomed_description_id IS 'Type: Text (20). When direct selection and entry of SNOMED CT terms is permitted, this will contain the description ID of the selected term. This field will be NULL when map type = 4 (data entered as Read code).';
COMMENT ON COLUMN patient_referral.snomed_expression IS 'Type: Text (20). A placeholder for SNOMED CT post-coordinated expressions. This is not supported in early phases of SNOMED implementation.';
COMMENT ON COLUMN patient_referral.snomed_ct_concept_id IS 'Type: Text (20). The mapped SNOMED CT Concept ID. Mapping is conducted prior to data transfer and will vary by mapping version used.';
COMMENT ON COLUMN patient_referral.snomed_is_assured IS 'Type: Boolean(1). Indicates whether the Read to SNOMED mapping has been verified by a panel of physicians.';
COMMENT ON COLUMN patient_referral.snomed_is_indicative IS 'Type: Boolean(1). Reserved for use when systems write SNOMED CT terms natively. Used to indicate the reliability of the reverse SNOMED CT-Read map. Where SNOMED CT codes do not have a direct mapping to READ, the code ';
COMMENT ON COLUMN patient_referral.snomed_mapping_type IS 'Type: Integer(1). Indicates the native encoding of the record in the Vision software (4 = term selected from Read dictionary, 5= term selected from SNOMED CT).';
COMMENT ON COLUMN patient_referral.snomed_mapping_version IS 'Type: Integer(10). The version of the READ-SNOMED CT mapping table applied.';
COMMENT ON COLUMN patient_referral.immunisation_source IS 'Type: Integer(2). A classification of the source of the referral. e.g. GP, Self. Use Source to lookup.';
COMMENT ON COLUMN patient_referral.staff_identifier IS 'Type: Integer(20). Identifier of the practice staff member entering the data. A value of 0 indicates that the staffid is unknown. Linked to Staff table.';
COMMENT ON COLUMN patient_referral.system_date IS 'Type: Date(DD/MM/YYYY). The date the event was entered into Vision.';
COMMENT ON COLUMN patient_referral.referral_urgency IS 'Type: Integer(2). A classification of the urgency of the referral, e.g., Routine, Urgent. Use Urgency to lookup.';

CREATE TABLE practice_details (
    last_collection_date DATE,
    practice_identifier INTEGER,
    location_region INTEGER,
    up_to_standard_date DATE
);

COMMENT ON TABLE practice_details IS 'This table contains details of each practice including region and collection information.';
COMMENT ON COLUMN practice_details.last_collection_date IS 'The date of the last collection for the practice. Type: Date in DD/MM/YYYY format. Primary key.';
COMMENT ON COLUMN practice_details.practice_identifier IS 'Encrypted unique identifier given to a specific practice in CPRD GOLD. Type: Integer with 5 digits.';
COMMENT ON COLUMN practice_details.location_region IS 'A value that indicates where in the UK the practice is based. The region denotes the ONS Region for practices within England, and the country i.e. Wales, Scotland, or Northern Ireland for the rest. Type: Integer with 3 digits. Foreign Key to Lookup_PRG table.';
COMMENT ON COLUMN practice_details.up_to_standard_date IS 'The date at which the practice data is deemed to be of research quality. Derived using a CPRD algorithm that primarily looks at practice death recording and gaps in the data. Type: Date in DD/MM/YYYY format.';

CREATE TABLE prescription_details (
    bnf_code INTEGER,
    consultation_identifier INTEGER,
    dosage_identifier TEXT,
    drug_mapped_dmd_code TEXT,
    event_date DATE,
    issue_sequence_number INTEGER,
    number_of_days INTEGER,
    number_of_packs INTEGER,
    pack_type INTEGER,
    patient_identifier TEXT,
    prescribed_as_required BOOLEAN,
    product_code INTEGER,
    total_quantity INTEGER,
    staff_identifier INTEGER,
    system_date DATE
);

COMMENT ON TABLE prescription_details IS 'This table contains details of all prescriptions (drugs and appliances) issued by the GP.';
COMMENT ON COLUMN prescription_details.bnf_code IS 'Code representing the chapter and section from the British National Formulary for the product selected by GP. Type: Integer, Format: 5, Field Name: BNF Code, Mapping: Lookup BNFCodes';
COMMENT ON COLUMN prescription_details.consultation_identifier IS 'Identifier that allows information about the consultation to be retrieved, when used in combination with pracid. Primary Key. Type: Integer, Format: 20, Field Name: Consultation Identifier, Mapping: Link Consultation table';
COMMENT ON COLUMN prescription_details.dosage_identifier IS 'Identifier that allows dosage information on the event to be retrieved. Use the Common Dosages Lookup to obtain the anonymised dosage text and extracted numerical information such as daily dose. Type: Text, Format: 64, Field Name: Dosage Identifier, Mapping: Lookup Common Dosages';
COMMENT ON COLUMN prescription_details.drug_mapped_dmd_code IS 'The mapped drug Dictionary of Medicines and Devices (DMD) code. Type: Text, Format: 20, Field Name: DMD Code, Mapping: None';
COMMENT ON COLUMN prescription_details.event_date IS 'Date associated with the event, as entered by the GP. Type: Date, Format: DD/MM/YYYY, Field Name: Event Date, Mapping: DD/MM/YYYY';
COMMENT ON COLUMN prescription_details.issue_sequence_number IS 'Number to indicate whether the event is associated with a repeat schedule. Value of 0 implies the event is not part of a repeat prescription. A value >= 1 denotes the issue number for the prescription within a repeat schedule. Type: Integer, Format: 20, Field Name: Issue Sequence Number, Mapping: None';
COMMENT ON COLUMN prescription_details.number_of_days IS 'Number of treatment days prescribed for a specific therapy event. Type: Integer, Format: 20, Field Name: Number of Days, Mapping: None';
COMMENT ON COLUMN prescription_details.number_of_packs IS 'Number of individual product packs prescribed for a specific therapy event. Type: Integer, Format: 8, Field Name: Number of Packs, Mapping: None';
COMMENT ON COLUMN prescription_details.pack_type IS 'Pack size or type of the prescribed product. Type: Integer, Format: 10, Field Name: Pack type, Mapping: Lookup Packtype';
COMMENT ON COLUMN prescription_details.patient_identifier IS 'Encrypted unique identifier given to a patient in CPRD GOLD. Type: Text, Format: 20, Field Name: Patient Identifier, Mapping: None';
COMMENT ON COLUMN prescription_details.prescribed_as_required IS 'Indicates if the prescription is to be supplied 'as required'. Field available to GPs from end 2020. Type: Boolean, Format: 1, Field Name: As Required, Mapping: None';
COMMENT ON COLUMN prescription_details.product_code IS 'CPRD unique code for the treatment selected by the GP. Type: Integer, Format: 20, Field Name: Product Code, Mapping: Lookup Product Dictionary';
COMMENT ON COLUMN prescription_details.total_quantity IS 'Total quantity entered by the GP for the prescribed product. Type: Integer, Format: 20, Field Name: Total Quantity, Mapping: None';
COMMENT ON COLUMN prescription_details.staff_identifier IS 'Identifier of the practice staff member entering the data. A value of 0 indicates that the staffid is unknown. Type: Integer, Format: 20, Field Name: Staff Identifier, Mapping: Link Staff table';
COMMENT ON COLUMN prescription_details.system_date IS 'Date the event was entered into Vision. Type: Date, Format: DD/MM/YYYY, Field Name: System Date, Mapping: DD/MM/YYYY';

CREATE TABLE staff_information (
    staff_gender INTEGER,
    staff_role INTEGER,
    staff_identifier INTEGER
);

COMMENT ON TABLE staff_information IS 'This table contains details about practice staff, with one record per member of staff.';
COMMENT ON COLUMN staff_information.staff_gender IS 'The gender of the staff member. Type: Integer. 1 indicates male, 2 indicates female.';
COMMENT ON COLUMN staff_information.staff_role IS 'The role of the member of staff who created the event. Type: Integer. Format: 3.';
COMMENT ON COLUMN staff_information.staff_identifier IS 'Encrypted unique identifier given to the practice staff member entering the data. Type: Integer. Format: 20.';