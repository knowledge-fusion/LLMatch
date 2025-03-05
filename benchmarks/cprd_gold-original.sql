CREATE TABLE clinical (
    adid INTEGER,
    consid INTEGER,
    constype INTEGER,
    enttype INTEGER,
    episode INTEGER,
    eventdate DATE,
    medcode INTEGER,
    patid TEXT,
    sctdescid TEXT,
    sctexpression TEXT,
    sctid TEXT,
    sctisassured BOOLEAN,
    sctisindicative BOOLEAN,
    sctmaptype INTEGER,
    sctmapversion INTEGER,
    staffid INTEGER,
    sysdate DATE
);

COMMENT ON TABLE clinical IS 'Medical history events containing symptoms, signs, and diagnoses entered on the GP system. Coded using Read codes, with prospective mapping to SNOMED CT codes since April 2018.';';
COMMENT ON COLUMN clinical.adid IS 'Description: Identifier that allows additional information to be retrieved for this event, when used in combination with pracid. A value of 0 signifies that there is no additional information associated with the event., Type: INTEGER, Format: 20, Field Name: Additional Details Identifier, Mapping: Link Additional Clinical Details table';
COMMENT ON COLUMN clinical.consid IS 'Description: Identifier that allows information about the consultation to be retrieved, when used in combination with pracid, Type: INTEGER, Format: 20, Field Name: Consultation Identifier, Mapping: Link Consultation table';
COMMENT ON COLUMN clinical.constype IS 'Description: Code for the category of event recorded within the GP system (e.g. diagnosis or symptom), Type: INTEGER, Format: 3, Field Name: Consultation type, Mapping: Lookup SED';
COMMENT ON COLUMN clinical.enttype IS 'Description: Identifier that represents the structured data area in Vision where the data was entered, Type: INTEGER, Format: 5, Field Name: Entity type, Mapping: Lookup Entity';
COMMENT ON COLUMN clinical.episode IS 'Description: Episode type for a specific clinical event, Type: INTEGER, Format: 3, Field Name: Episode, Mapping: Lookup EPI';
COMMENT ON COLUMN clinical.eventdate IS 'Description: Date associated with the event, as entered by the GP, Type: DATE, Format: DD/MM/YYYY, Field Name: Event Date, Mapping: DD/MM/YYYY';
COMMENT ON COLUMN clinical.medcode IS 'Description: CPRD unique code for the medical term selected by the GP, Type: INTEGER, Format: 20, Field Name: Medical Code, Mapping: Lookup Medical Dictionary';
COMMENT ON COLUMN clinical.patid IS 'Description: Encrypted unique identifier given to a patient in CPRD GOLD, Type: TEXT, Format: 20, Field Name: Patient Identifier, Mapping: None';
COMMENT ON COLUMN clinical.sctdescid IS 'Description: When direct selection and entry of SNOMED CT terms is permitted this will contain the description ID of the selected term. This field will be NULL when map type = 4 (data entered as Read code), Type: TEXT, Format: 20, Field Name: SNOMED description ID, Mapping: None';
COMMENT ON COLUMN clinical.sctexpression IS 'Description: A placeholder for SNOMED CT post-coordinated expressions. This is not supported in early phases of SNOMED implementation., Type: TEXT, Format: 20, Field Name: SNOMED Expression, Mapping: None';
COMMENT ON COLUMN clinical.sctid IS 'Description: The mapped SNOMED CT Concept ID. mapping is conducted prior to data transfer and will vary by mapping version used., Type: TEXT, Format: 20, Field Name: SNOMED CT Concept ID3, Mapping: None';
COMMENT ON COLUMN clinical.sctisassured IS 'Description: Indicates whether the Read to SNOMED mapping has been verified by a panel of physicians, Type: BOOLEAN, Format: 1, Field Name: SCT Is Assured, Mapping: None';
COMMENT ON COLUMN clinical.sctisindicative IS 'Description: Reserved for use when systems write SNOMED CT terms natively. Used to indicate the reliability of the reverse SNOMED CT-Read map. Where SNOMED CT codes do not have a direct mapping to READ, the code Rz…00 will be utilised., Type: BOOLEAN, Format: 1, Field Name: SCT Is Indicative, Mapping: None';
COMMENT ON COLUMN clinical.sctmaptype IS 'Description: Indicates the native encoding of the record in the Vision software (4 = term selected from Read dictionary, 5 = term selected from SNOMED CT), Type: INTEGER, Format: 1, Field Name: SNOMED mapping type, Mapping: None';
COMMENT ON COLUMN clinical.sctmapversion IS 'Description: The version of the READ-SNOMED CT mapping table applied, Type: INTEGER, Format: 10, Field Name: SNOMED mapping Version, Mapping: None';
COMMENT ON COLUMN clinical.staffid IS 'Description: Identifier of the practice staff member entering the data. A value of 0 indicates that the staffid is unknown, Type: INTEGER, Format: 20, Field Name: Staff Identifier, Mapping: Link Staff table';
COMMENT ON COLUMN clinical.sysdate IS 'Description: Date the event was entered into Vision, Type: DATE, Format: DD/MM/YYYY, Field Name: System Date, Mapping: DD/MM/YYYY';

CREATE TABLE consultation (
    consid INTEGER,
    constype INTEGER,
    duration INTEGER,
    eventdate DATE,
    patid TEXT,
    staffid INTEGER,
    sysdate DATE
);

COMMENT ON TABLE consultation IS 'Information relating to the type of consultation entered by the GP, linked to events via the consultation identifier (consid).';';
COMMENT ON COLUMN consultation.consid IS 'Description: The consultation identifier linking events at the same consultation, when used in combination with pracid, Type: INTEGER, Format: 20, Field Name: Consultation Identifier, Mapping: Link Event tables';
COMMENT ON COLUMN consultation.constype IS 'Description: type of consultation (e.g. Surgery Consultation, Night Visit, Emergency etc.), Type: INTEGER, Format: 3, Field Name: Consultation type, Mapping: Lookup COT';
COMMENT ON COLUMN consultation.duration IS 'Description: The length of time (minutes) between the opening, and closing of the consultation record, Type: INTEGER, Format: 10, Field Name: Duration, Mapping: None';
COMMENT ON COLUMN consultation.eventdate IS 'Description: Date associated with the event, as entered by the GP, Type: DATE, Format: DD/MM/YYYY, Field Name: Event Date, Mapping: DD/MM/YYYY';
COMMENT ON COLUMN consultation.patid IS 'Description: Encrypted unique identifier given to a patient in CPRD GOLD, Type: TEXT, Format: 20, Field Name: Patient Identifier, Mapping: None';
COMMENT ON COLUMN consultation.staffid IS 'Description: The identifier of the practice staff member entering the data. A value of 0 indicates that the staffid is unknown, Type: INTEGER, Format: 20, Field Name: Staff Identifier, Mapping: Link Staff table';
COMMENT ON COLUMN consultation.sysdate IS 'Description: Date the event was entered into Vision, Type: DATE, Format: DD/MM/YYYY, Field Name: System Date, Mapping: DD/MM/YYYY';

CREATE TABLE immunisation (
    batch INTEGER,
    compound INTEGER,
    consid INTEGER,
    constype INTEGER,
    eventdate DATE,
    immstype INTEGER,
    medcode INTEGER,
    method INTEGER,
    patid TEXT,
    reason INTEGER,
    sctdescid TEXT,
    sctexpression TEXT,
    sctid TEXT,
    sctisassured BOOLEAN,
    sctisindicative BOOLEAN,
    sctmaptype INTEGER,
    sctmapversion INTEGER,
    source INTEGER,
    staffid INTEGER,
    stage INTEGER,
    status INTEGER,
    sysdate DATE
);

COMMENT ON TABLE immunisation IS 'Details of immunisation records on the GP system.';';
COMMENT ON COLUMN immunisation.batch IS 'Description: Immunisation batch number, Type: INTEGER, Format: 20, Field Name: Batch Number, Mapping: Lookup BatchNumber';
COMMENT ON COLUMN immunisation.compound IS 'Description: Immunisation compound administered – may be a single or multicomponent preparation, e.g. MMR, Type: INTEGER, Format: 4, Field Name: Compound, Mapping: Lookup IMC';
COMMENT ON COLUMN immunisation.consid IS 'Description: Identifier that allows information about the consultation to be retrieved, when used in combination with pracid, Type: INTEGER, Format: 20, Field Name: Consultation Identifier, Mapping: Link Consultation table';
COMMENT ON COLUMN immunisation.constype IS 'Description: Code for the category of event recorded within the GP system (e.g. intervention), Type: INTEGER, Format: 3, Field Name: Consultation type, Mapping: Lookup SED';
COMMENT ON COLUMN immunisation.eventdate IS 'Description: Date associated with the event, as entered by the GP, Type: DATE, Format: DD/MM/YYYY, Field Name: Event Date, Mapping: DD/MM/YYYY';
COMMENT ON COLUMN immunisation.immstype IS 'Description: Individual components of an immunisation, e.g. Mumps, Rubella, Measles, Type: INTEGER, Format: 4, Field Name: type, Mapping: Lookup IMT';
COMMENT ON COLUMN immunisation.medcode IS 'Description: CPRD unique code for the medical term selected by the GP, Type: INTEGER, Format: 20, Field Name: Medical Code, Mapping: Lookup Medical Dictionary';
COMMENT ON COLUMN immunisation.method IS 'Description: Route of administration for the immunisation, e.g. Oral, Intramuscular, Type: INTEGER, Format: 3, Field Name: Method, Mapping: Lookup IME';
COMMENT ON COLUMN immunisation.patid IS 'Description: Encrypted unique identifier given to a patient in CPRD GOLD, Type: TEXT, Format: 20, Field Name: Patient Identifier, Mapping: None';
COMMENT ON COLUMN immunisation.reason IS 'Description: Reason for administering the immunisation, e.g. Routine measure, Type: INTEGER, Format: 3, Field Name: Reason, Mapping: Lookup RIN';
COMMENT ON COLUMN immunisation.sctdescid IS 'Description: When direct selection and entry of SNOMED CT terms is permitted this will contain the description ID of the selected term. This field will be NULL when map type = 4 (data entered as Read code), Type: TEXT, Format: 20, Field Name: SNOMED description ID, Mapping: None';
COMMENT ON COLUMN immunisation.sctexpression IS 'Description: A placeholder for SNOMED CT post-coordinated expressions. This is not supported in early phases of SNOMED implementation., Type: TEXT, Format: 20, Field Name: SNOMED Expression, Mapping: None';
COMMENT ON COLUMN immunisation.sctid IS 'Description: The mapped SNOMED CT Concept ID. mapping is conducted prior to data transfer and will vary by mapping version used., Type: TEXT, Format: 20, Field Name: SNOMED CT Concept ID3, Mapping: None';
COMMENT ON COLUMN immunisation.sctisassured IS 'Description: Indicates whether the Read to SNOMED mapping has been verified by a panel of physicians., Type: BOOLEAN, Format: 1, Field Name: SCT Is Assured, Mapping: None';
COMMENT ON COLUMN immunisation.sctisindicative IS 'Description: Reserved for use when systems write SNOMED CT terms natively. Used to indicate the reliability of the reverse SNOMED CT-Read map. Where SNOMED CT codes do not have a direct mapping to READ, the code Rz…00 will be utilised., Type: BOOLEAN, Format: 1, Field Name: SCT Is Indicative, Mapping: None';
COMMENT ON COLUMN immunisation.sctmaptype IS 'Description: Indicates the native encoding of the record in the Vision software (4 = term selected from Read dictionary, 5= term selected from SNOMED CT), Type: INTEGER, Format: 1, Field Name: SNOMED mapping type, Mapping: None';
COMMENT ON COLUMN immunisation.sctmapversion IS 'Description: The version of the READ-SNOMED CT mapping table applied, Type: INTEGER, Format: 10, Field Name: SNOMED mapping Version, Mapping: None';
COMMENT ON COLUMN immunisation.source IS 'Description: Location where the immunisation was administered, e.g. In this practice, Type: INTEGER, Format: 3, Field Name: Source, Mapping: Lookup INP';
COMMENT ON COLUMN immunisation.staffid IS 'Description: Identifier of the practice staff member entering the data. A value of 0 indicates that the staffid is unknown, Type: INTEGER, Format: 20, Field Name: Staff Identifier, Mapping: Link Staff table';
COMMENT ON COLUMN immunisation.stage IS 'Description: Stage of the immunisation given, e.g. 1, 2, B2, Type: INTEGER, Format: 2, Field Name: Stage, Mapping: Lookup IST';
COMMENT ON COLUMN immunisation.status IS 'Description: Status of the immunisation e.g. Advised, Given, Refusal, Type: INTEGER, Format: 3, Field Name: Status, Mapping: Lookup IMM';
COMMENT ON COLUMN immunisation.sysdate IS 'Description: Date the event was entered into Vision, Type: DATE, Format: DD/MM/YYYY, Field Name: System Date, Mapping: DD/MM/YYYY';

CREATE TABLE patient (
    accept INTEGER,
    capsup INTEGER,
    chsdate DATE,
    chsreg INTEGER,
    crd DATE,
    deathdate DATE,
    famnum INTEGER,
    frd DATE,
    gender INTEGER,
    internal INTEGER,
    marital INTEGER,
    mob INTEGER,
    patid TEXT,
    prescr INTEGER,
    reggap INTEGER,
    regstat INTEGER,
    tod DATE,
    toreason INTEGER,
    vmid INTEGER,
    yob INTEGER
);

COMMENT ON TABLE patient IS 'Basic patient demographics and registration details.';';
COMMENT ON COLUMN patient.accept IS 'Description: Flag to indicate whether the patient has met certain quality standards: 1 = acceptable, 0 = unacceptable, Type: INTEGER, Format: 1, Field Name: Acceptable Patient Flag, Mapping: Boolean';
COMMENT ON COLUMN patient.capsup IS 'Description: Level of capitation supplement the patient has currently (e.g. low, medium, high), Type: INTEGER, Format: 3, Field Name: Capitation Supplement, Mapping: Lookup CAP';
COMMENT ON COLUMN patient.chsdate IS 'Description: Date of registration with Child Health Surveillance, Type: DATE, Format: DD/MM/YYYY, Field Name: CHS Registration Date, Mapping: DD/MM/YYYY';
COMMENT ON COLUMN patient.chsreg IS 'Description: Value to indicate whether the patient is registered with Child Health Surveillance, Type: INTEGER, Format: 1, Field Name: CHS Registered, Mapping: Lookup Y_N';
COMMENT ON COLUMN patient.crd IS 'Description: Date the patients current period of registration with the practice began (date of the first permanent record after the latest transferred out period). If there are no transferred out periods, the date is equal to frd, Type: DATE, Format: DD/MM/YYYY, Field Name: Current Registration Date, Mapping: DD/MM/YYYY';
COMMENT ON COLUMN patient.deathdate IS 'Description: Date of death of patient – derived using a CPRD algorithm, Type: DATE, Format: DD/MM/YYYY, Field Name: Death Date, Mapping: DD/MM/YYYY';
COMMENT ON COLUMN patient.famnum IS 'Description: Family ID number, Type: INTEGER, Format: 20, Field Name: Family Number, Mapping: None';
COMMENT ON COLUMN patient.frd IS 'Description: Date the patient first registered with the practice. If patient only has temporary records, the date is the first encounter with the practice. if patient has permanent records it is the date of the first permanent record (excluding preceding temporary records), Type: DATE, Format: DD/MM/YYYY, Field Name: First Registration Date, Mapping: DD/MM/YYYY';
COMMENT ON COLUMN patient.gender IS 'Description: Patients gender, Type: INTEGER, Format: 1, Field Name: Patient Gender, Mapping: Lookup SEX';
COMMENT ON COLUMN patient.internal IS 'Description: Number of internal transfer out periods, in the patients registration details, Type: INTEGER, Format: 2, Field Name: Internal Transfer, Mapping: None';
COMMENT ON COLUMN patient.marital IS 'Description: Patients current marital status, Type: INTEGER, Format: 3, Field Name: Marital Status, Mapping: Lookup MAR';
COMMENT ON COLUMN patient.mob IS 'Description: Patients month of birth (for those aged under 16). 0 indicates no month set, Type: INTEGER, Format: 2, Field Name: Birth Month, Mapping: None';
COMMENT ON COLUMN patient.patid IS 'Description: Encrypted unique identifier given to a patient in CPRD GOLD, Type: TEXT, Format: 20, Field Name: Patient Identifier, Mapping: None';
COMMENT ON COLUMN patient.prescr IS 'Description: type of prescribing exemption the patient has currently (e.g. medical / maternity), Type: INTEGER, Format: 3, Field Name: Prescription Exemption, Mapping: Lookup PEX';
COMMENT ON COLUMN patient.reggap IS 'Description: Number of days missing in the patients registration details, Type: INTEGER, Format: 5, Field Name: Registration Gaps, Mapping: PAT_GAP2';
COMMENT ON COLUMN patient.regstat IS 'Description: Status of registration detailing gaps and temporary patients, Type: INTEGER, Format: 2, Field Name: Registration Status, Mapping: PAT_STAT1';
COMMENT ON COLUMN patient.tod IS 'Description: Date the patient transferred out of the practice, if relevant. Empty for patients who have not transferred out, Type: DATE, Format: DD/MM/YYYY, Field Name: Transfer Out Date, Mapping: DD/MM/YYYY';
COMMENT ON COLUMN patient.toreason IS 'Description: Reason the patient transferred out of the practice. Includes ';
COMMENT ON COLUMN patient.vmid IS 'Description: Old VM id for the patient when the practice was using the VAMP system, Type: INTEGER, Format: 20, Field Name: VAMP Identifier, Mapping: None';
COMMENT ON COLUMN patient.yob IS 'Description: Patients year of birth. This is actual year of birth e.g. 1984, Type: INTEGER, Format: 4, Field Name: Birth Year, Mapping: None';

CREATE TABLE practice (
    lcd DATE,
    pracid INTEGER,
    region INTEGER,
    uts DATE
);

COMMENT ON TABLE practice IS 'Details of each practice, including region and collection information.';';
COMMENT ON COLUMN practice.lcd IS 'Description: Date of the last collection for the practice, Type: DATE, Format: DD/MM/YYYY, Field Name: Last Collection Date, Mapping: DD/MM/YYYY';
COMMENT ON COLUMN practice.pracid IS 'Description: Encrypted unique identifier given to a specific practice in CPRD GOLD, Type: INTEGER, Format: 5, Field Name: Practice identifier, Mapping: None';
COMMENT ON COLUMN practice.region IS 'Description: Value to indicate where in the UK the practice is based. The region denotes the ONS Region for practices within England, and the country i.e. Wales, Scotland, or Northern Ireland for the rest, Type: INTEGER, Format: 3, Field Name: Region, Mapping: Lookup PRG';
COMMENT ON COLUMN practice.uts IS 'Description: Date at which the practice data is deemed to be of research quality. Derived using a CPRD algorithm that primarily looks at practice death recording and gaps in the data, Type: DATE, Format: DD/MM/YYYY, Field Name: Up-to-standard date, Mapping: DD/MM/YYYY';

CREATE TABLE referral (
    attendance INTEGER,
    consid INTEGER,
    constype INTEGER,
    eventdate DATE,
    fhsaspec INTEGER,
    inpatient INTEGER,
    medcode INTEGER,
    nhsspec INTEGER,
    patid TEXT,
    sctdescid TEXT,
    sctexpression TEXT,
    sctid TEXT,
    sctisassured BOOLEAN,
    sctisindicative BOOLEAN,
    sctmaptype INTEGER,
    sctmapversion INTEGER,
    source INTEGER,
    staffid INTEGER,
    sysdate DATE,
    urgency INTEGER
);

COMMENT ON TABLE referral IS 'Referral details recorded on the GP system, involving patient referrals to external care centres such as hospitals. Includes specialty and referral type.';';
COMMENT ON COLUMN referral.attendance IS 'Description: Category describing whether the referral event is the first visit, a follow-up etc., Type: INTEGER, Format: 2, Field Name: Attendance type, Mapping: Lookup ATT';
COMMENT ON COLUMN referral.consid IS 'Description: Identifier that allows information about the consultation to be retrieved, when used in combination with pracid, Type: INTEGER, Format: 20, Field Name: Consultation Identifier, Mapping: Link Consultation table';
COMMENT ON COLUMN referral.constype IS 'Description: Code for the category of event recorded within the GP system (e.g. management or administration), Type: INTEGER, Format: 3, Field Name: Consultation type, Mapping: Lookup SED';
COMMENT ON COLUMN referral.eventdate IS 'Description: Date associated with the event, as entered by the GP, Type: DATE, Format: DD/MM/YYYY, Field Name: Event Date, Mapping: DD/MM/YYYY';
COMMENT ON COLUMN referral.fhsaspec IS 'Description: Referral speciality according to the Family Health Services Authority (FHSA) classification, Type: INTEGER, Format: 3, Field Name: FHSA Speciality, Mapping: Lookup SPE';
COMMENT ON COLUMN referral.inpatient IS 'Description: Classification of the type of referral, e.g. Day case, In patient, Type: INTEGER, Format: 2, Field Name: In Patient, Mapping: Lookup RFT';
COMMENT ON COLUMN referral.medcode IS 'Description: CPRD unique code for the medical term selected by the GP, Type: INTEGER, Format: 20, Field Name: Medical Code, Mapping: Lookup Medical Dictionary';
COMMENT ON COLUMN referral.nhsspec IS 'Description: Referral speciality according to the National Health Service (NHS) classification, Type: INTEGER, Format: 3, Field Name: NHS Speciality, Mapping: Lookup DEP';
COMMENT ON COLUMN referral.patid IS 'Description: Encrypted unique identifier given to a patient in CPRD GOLD, Type: TEXT, Format: 20, Field Name: Patient Identifier, Mapping: None';
COMMENT ON COLUMN referral.sctdescid IS 'Description: When direct selection and entry of SNOMED CT terms is permitted this will contain the description ID of the selected term. This field will be NULL when map type = 4 (data entered as Read code), Type: TEXT, Format: 20, Field Name: SNOMED description ID, Mapping: None';
COMMENT ON COLUMN referral.sctexpression IS 'Description: A placeholder for SNOMED CT post-coordinated expressions. This is not supported in early phases of SNOMED implementation., Type: TEXT, Format: 20, Field Name: SNOMED Expression, Mapping: None';
COMMENT ON COLUMN referral.sctid IS 'Description: The mapped SNOMED CT Concept ID. mapping is conducted prior to data transfer and will vary by mapping version used., Type: TEXT, Format: 20, Field Name: SNOMED CT Concept ID3, Mapping: None';
COMMENT ON COLUMN referral.sctisassured IS 'Description: Indicates whether the Read to SNOMED mapping has been verified by a panel of physicians, Type: BOOLEAN, Format: 1, Field Name: SCT Is Assured, Mapping: None';
COMMENT ON COLUMN referral.sctisindicative IS 'Description: Reserved for use when systems write SNOMED CT terms natively. Used to indicate the reliability of the reverse SNOMED CT-Read map. Where SNOMED CT codes do not have a direct mapping to READ, the code Rz…00 will be utilised., Type: BOOLEAN, Format: 1, Field Name: SCT Is Indicative, Mapping: None';
COMMENT ON COLUMN referral.sctmaptype IS 'Description: Indicates the native encoding of the record in the Vision software (4 = term selected from Read dictionary, 5= term selected from SNOMED CT), Type: INTEGER, Format: 1, Field Name: SNOMED mapping type, Mapping: None';
COMMENT ON COLUMN referral.sctmapversion IS 'Description: The version of the READ-SNOMED CT mapping table applied, Type: INTEGER, Format: 10, Field Name: SNOMED mapping Version, Mapping: None';
COMMENT ON COLUMN referral.source IS 'Description: Classification of the source of the referral e.g. GP, Self, Type: INTEGER, Format: 2, Field Name: Source, Mapping: Lookup SOU';
COMMENT ON COLUMN referral.staffid IS 'Description: Identifier of the practice staff member entering the data. A value of 0 indicates that the staffid is unknown, Type: INTEGER, Format: 20, Field Name: Staff Identifier, Mapping: Link Staff table';
COMMENT ON COLUMN referral.sysdate IS 'Description: Date the event was entered into Vision, Type: DATE, Format: DD/MM/YYYY, Field Name: System Date, Mapping: DD/MM/YYYY';
COMMENT ON COLUMN referral.urgency IS 'Description: Classification of the urgency of the referral e.g. Routine, Urgent, Type: INTEGER, Format: 2, Field Name: Urgency, Mapping: Lookup URG';

CREATE TABLE staff (
    gender INTEGER,
    role INTEGER,
    staffid INTEGER
);

COMMENT ON TABLE staff IS 'Practice staff details, with one record per member of staff.';';
COMMENT ON COLUMN staff.gender IS 'Description: Staff members gender, Type: INTEGER, Format: 1, Field Name: Staff Gender, Mapping: Lookup SEX';
COMMENT ON COLUMN staff.role IS 'Description: Role of the member of staff who created the event, Type: INTEGER, Format: 3, Field Name: Staff Role, Mapping: Lookup ROL';
COMMENT ON COLUMN staff.staffid IS 'Description: Encrypted unique identifier given to the practice staff member entering the data, Type: INTEGER, Format: 20, Field Name: Staff Identifier, Mapping: None';

CREATE TABLE test (
    consid INTEGER,
    constype INTEGER,
    enttype INTEGER,
    eventdate DATE,
    medcode INTEGER,
    patid TEXT,
    sctdescid TEXT,
    sctexpression TEXT,
    sctid TEXT,
    sctisassured BOOLEAN,
    sctisindicative BOOLEAN,
    sctmaptype INTEGER,
    sctmapversion INTEGER,
    staffid INTEGER,
    sysdate DATE
);

COMMENT ON TABLE test IS 'Records of test data on the GP system, coded using Read codes chosen by the GP. Test types are identified by entity types, with varying data fields.';';
COMMENT ON COLUMN test.consid IS 'Description: Identifier that allows information about the consultation to be retrieved, when used in combination with pracid, Type: INTEGER, Format: 20, Field Name: Consultation Identifier, Mapping: Link Consultation table';
COMMENT ON COLUMN test.constype IS 'Description: Code for the category of event recorded within the GP system (e.g. examination), Type: INTEGER, Format: 3, Field Name: Consultation type, Mapping: Lookup SED';
COMMENT ON COLUMN test.enttype IS 'Description: Identifier that represents the structured data area in Vision where the data was entered, Type: INTEGER, Format: 5, Field Name: Entity type, Mapping: Lookup Entity';
COMMENT ON COLUMN test.eventdate IS 'Description: Date associated with the event, as entered by the GP, Type: DATE, Format: DD/MM/YYYY, Field Name: Event Date, Mapping: DD/MM/YYYY';
COMMENT ON COLUMN test.medcode IS 'Description: CPRD unique code for the medical term selected by the GP, Type: INTEGER, Format: 20, Field Name: Medical Code, Mapping: Lookup Medical Dictionary';
COMMENT ON COLUMN test.patid IS 'Description: Encrypted unique identifier given to a patient in CPRD GOLD, Type: TEXT, Format: 20, Field Name: Patient Identifier, Mapping: None';
COMMENT ON COLUMN test.sctdescid IS 'Description: When direct selection and entry of SNOMED CT terms is permitted this will contain the description ID of the selected term. This field will be NULL when map type = 4 (data entered as Read code), Type: TEXT, Format: 20, Field Name: SNOMED description ID, Mapping: None';
COMMENT ON COLUMN test.sctexpression IS 'Description: A placeholder for SNOMED CT post-coordinated expressions. This is not supported in early phases of SNOMED implementation., Type: TEXT, Format: 20, Field Name: SNOMED Expression, Mapping: None';
COMMENT ON COLUMN test.sctid IS 'Description: The mapped SNOMED CT Concept ID. mapping is conducted prior to data transfer and will vary by mapping version used., Type: TEXT, Format: 20, Field Name: SNOMED CT Concept ID3, Mapping: None';
COMMENT ON COLUMN test.sctisassured IS 'Description: Indicates whether the Read to SNOMED mapping has been verified by a panel of physicians, Type: BOOLEAN, Format: 1, Field Name: SCT Is Assured, Mapping: None';
COMMENT ON COLUMN test.sctisindicative IS 'Description: Reserved for use when systems write SNOMED CT terms natively. Used to indicate the reliability of the reverse SNOMED CT-Read map. Where SNOMED CT codes do not have a direct mapping to READ, the code Rz…00 will be utilised., Type: BOOLEAN, Format: 1, Field Name: SCT Is Indicative, Mapping: None';
COMMENT ON COLUMN test.sctmaptype IS 'Description: Indicates the native encoding of the record in the Vision software (4 = term selected from Read dictionary, 5= term selected from SNOMED CT), Type: INTEGER, Format: 1, Field Name: SNOMED mapping type, Mapping: None';
COMMENT ON COLUMN test.sctmapversion IS 'Description: The version of the READ-SNOMED CT mapping table applied, Type: INTEGER, Format: 10, Field Name: SNOMED mapping Version, Mapping: None';
COMMENT ON COLUMN test.staffid IS 'Description: Identifier of the practice staff member entering the data. A value of 0 indicates that the staffid is unknown, Type: INTEGER, Format: 20, Field Name: Staff Identifier, Mapping: Link Staff table';
COMMENT ON COLUMN test.sysdate IS 'Description: Date the event was entered into Vision, Type: DATE, Format: DD/MM/YYYY, Field Name: System Date, Mapping: DD/MM/YYYY';

CREATE TABLE therapy (
    bnfcode INTEGER,
    consid INTEGER,
    dosageid TEXT,
    drugdmd TEXT,
    eventdate DATE,
    issueseq INTEGER,
    numdays INTEGER,
    numpacks INTEGER,
    packtype INTEGER,
    patid TEXT,
    prn BOOLEAN,
    prodcode INTEGER,
    qty INTEGER,
    staffid INTEGER,
    sysdate DATE
);

COMMENT ON TABLE therapy IS 'Details of all prescriptions (drugs and appliances) issued by the GP. Recorded using the Gemscript product code system.';';
COMMENT ON COLUMN therapy.bnfcode IS 'Description: Code representing the chapter & section from the British National Formulary for the product selected by GP, Type: INTEGER, Format: 5, Field Name: BNF Code, Mapping: Lookup BNFCodes';
COMMENT ON COLUMN therapy.consid IS 'Description: Identifier that allows information about the consultation to be retrieved, when used in combination with pracid, Type: INTEGER, Format: 20, Field Name: Consultation Identifier, Mapping: Link Consultation table';
COMMENT ON COLUMN therapy.dosageid IS 'Description: Identifier that allows dosage information on the event to be retrieved. Use the Common Dosages Lookup to obtain the anonymised dosage text and extracted numerical information such as daily dose., Type: TEXT, Format: 64, Field Name: Dosage Identifier, Mapping: Lookup Common Dosages';
COMMENT ON COLUMN therapy.drugdmd IS 'Description: The mapped drug DMD code, Type: TEXT, Format: 20, Field Name: DMD Code, Mapping: None';
COMMENT ON COLUMN therapy.eventdate IS 'Description: Date associated with the event, as entered by the GP, Type: DATE, Format: DD/MM/YYYY, Field Name: Event Date, Mapping: DD/MM/YYYY';
COMMENT ON COLUMN therapy.issueseq IS 'Description: Number to indicate whether the event is associated with a repeat schedule. Value of 0 implies the event is not part of a repeat prescription. A value ≥ 1 denotes the issue number for the prescription within a repeat schedule, Type: INTEGER, Format: 20, Field Name: Issue Sequence Number, Mapping: None';
COMMENT ON COLUMN therapy.numdays IS 'Description: Number of treatment days prescribed for a specific therapy event, Type: INTEGER, Format: 20, Field Name: Number of Days, Mapping: None';
COMMENT ON COLUMN therapy.numpacks IS 'Description: Number of individual product packs prescribed for a specific therapy event, Type: INTEGER, Format: 8, Field Name: Number of Packs, Mapping: None';
COMMENT ON COLUMN therapy.packtype IS 'Description: Pack size or type of the prescribed product, Type: INTEGER, Format: 10, Field Name: Pack type, Mapping: Lookup Packtype';
COMMENT ON COLUMN therapy.patid IS 'Description: Encrypted unique identifier given to a patient in CPRD GOLD, Type: TEXT, Format: 20, Field Name: Patient Identifier, Mapping: None';
COMMENT ON COLUMN therapy.prn IS 'Description: Indicates if the prescription is to be supplied as required. Field available to GPs from end 2020., Type: BOOLEAN, Format: 1, Field Name: As Required, Mapping: None';
COMMENT ON COLUMN therapy.prodcode IS 'Description: CPRD unique code for the treatment selected by the GP, Type: INTEGER, Format: 20, Field Name: Product Code, Mapping: Lookup Product Dictionary';
COMMENT ON COLUMN therapy.qty IS 'Description: Total quantity entered by the GP for the prescribed product, Type: INTEGER, Format: 20, Field Name: Total Quantity, Mapping: None';
COMMENT ON COLUMN therapy.staffid IS 'Description: Identifier of the practice staff member entering the data. A value of 0 indicates that the staffid is unknown, Type: INTEGER, Format: 20, Field Name: Staff Identifier, Mapping: Link Staff table';
COMMENT ON COLUMN therapy.sysdate IS 'Description: Date the event was entered into Vision, Type: DATE, Format: DD/MM/YYYY, Field Name: System Date, Mapping: DD/MM/YYYY';