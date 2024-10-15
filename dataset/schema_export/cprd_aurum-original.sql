CREATE TABLE consultation (
    consdate DATE,
    consid TEXT,
    consmedcodeid TEXT,
    conssourceid TEXT,
    cprdconstype INTEGER,
    enterdate DATE,
    patid TEXT,
    pracid INTEGER,
    staffid TEXT 
);

COMMENT ON TABLE consultation IS 'The Consultation file (Consultation_NNN.txt) contains information relating to the type of consultation as entered by the GP (e.g. telephone, home visit, practice visit). Some consultations are linked to observations that occur during the consultation via the consultation identifier (consid).';';
COMMENT ON COLUMN consultation.consdate IS 'Description: Date associated with the event, Type: DATE, Format: DD/MM/YYYY, Field Name: Event date, Mapping: None';
COMMENT ON COLUMN consultation.consid IS 'Description: Unique identifier given to the consultation. This is the primary key for this table., Type: TEXT, Format: Up to 19 numeric characters, Field Name: Consultation identifier, Mapping: None';
COMMENT ON COLUMN consultation.consmedcodeid IS 'Description: Source of the consultation from EMIS® software. This is a medical code that can be used with the medical dictionary. It may contain information similar to the consultation source identifiers but is available for use now. Some of the codes may not be interpretable e.g. Awaiting clinical code migration to EMIS Web®., Type: TEXT, Format: 6-18 numeric characters, Field Name: Consultation source code identifier, Mapping: Medical dictionary. Maps to medcodeid';
COMMENT ON COLUMN consultation.conssourceid IS 'Description: Identifier that allows retrieval of anonymised information on the source or location of the consultation as recorded in the EMIS® software. Only the most frequently occurring strings have been anonymised and are included in the lookup. All others have been withheld by CPRD, pending anonymisation where feasible., Type: TEXT, Format: Up to 10 numeric characters, Field Name: EMIS® consultation source identifier, Mapping: Lookup: ConsSource.txt';
COMMENT ON COLUMN consultation.cprdconstype IS 'Description: Type of consultation: this will be generated by CPRD based on information recorded in the consmedcodeid and conssourceid variables. [Not currently populated], Type: INTEGER, Format: 3, Field Name: CPRD consultation source identifier, Mapping: Lookup: cprdconstype.txt [not included in initial release]';
COMMENT ON COLUMN consultation.enterdate IS 'Description: Date the event was entered into the practice system, Type: DATE, Format: DD/MM/YYYY, Field Name: Entered date, Mapping: None';
COMMENT ON COLUMN consultation.patid IS 'Description: Encrypted unique identifier given to a patient in CPRD Aurum. The patient identifier is unique to CPRD Aurum and may represent a different patient in the CPRD GOLD database., Type: TEXT, Format: 6-19 numeric characters, Field Name: Patient identifier, Mapping: Link Patient table';
COMMENT ON COLUMN consultation.pracid IS 'Description: Encrypted unique identifier given to a practice in CPRD Aurum, Type: INTEGER, Format: 5, Field Name: Practice identifier, Mapping: Link Practice table';
COMMENT ON COLUMN consultation.staffid IS 'Description: Encrypted unique identifier given to the practice staff member who took the consultation in CPRD Aurum, Type: TEXT, Format: Up to 10 numeric characters, Field Name: Staff identifier, Mapping: Link Staff table';

CREATE TABLE drugissue (
    dosageid TEXT,
    drugrecid TEXT,
    duration INTEGER,
    enterdate DATE,
    estnhscost DECIMAL,
    issuedate DATE,
    issueid TEXT,
    patid TEXT,
    pracid INTEGER,
    probobsid TEXT,
    prodcodeid TEXT,
    quantity DECIMAL,
    quantunitid INTEGER,
    staffid TEXT 
);

COMMENT ON TABLE drugissue IS 'The Drug issue file (DrugIssue_NNN.txt) contains details of all prescriptions on the GP system. This file contains data relating to all prescriptions (for drugs and appliances) issued by the GP. Some prescriptions are linked to problem-type observations via the Observation file, using the observation identifier (obsid).';';
COMMENT ON COLUMN drugissue.dosageid IS 'Description: Identifier that allows dosage information on the event to be retrieved. Not included in first release, Type: TEXT, Format: 64 characters, Field Name: Dosage identifier, Mapping: Lookup: common_dosages.txt';
COMMENT ON COLUMN drugissue.drugrecid IS 'Description: Unique identifier to a drug template record, which is not currently for release. At present this may be used to group repeat prescriptions from the same template., Type: TEXT, Format: Up to 19 numeric characters, Field Name: Drug record identifier, Mapping: None';
COMMENT ON COLUMN drugissue.duration IS 'Description: Duration of the treatment in days, Type: INTEGER, Format: 10, Field Name: Course duration in days, Mapping: None';
COMMENT ON COLUMN drugissue.enterdate IS 'Description: Date the event was entered into EMIS Web®, Type: DATE, Format: DD/MM/YYYY, Field Name: Entered date, Mapping: None';
COMMENT ON COLUMN drugissue.estnhscost IS 'Description: Estimated cost of the treatment to the NHS, Type: DECIMAL, Format: 10.4, Field Name: Estimated NHS cost, Mapping: None';
COMMENT ON COLUMN drugissue.issuedate IS 'Description: Date associated with the event, Type: DATE, Format: DD/MM/YYYY, Field Name: Event date, Mapping: None';
COMMENT ON COLUMN drugissue.issueid IS 'Description: Unique identifier given to the issue record. This is the primary key for this table., Type: TEXT, Format: Up to 19 numeric characters, Field Name: Issue record identifier, Mapping: None';
COMMENT ON COLUMN drugissue.patid IS 'Description: Encrypted unique identifier given to a patient in CPRD Aurum. The patient identifier is unique to CPRD Aurum and may represent a different patient in the CPRD GOLD database., Type: TEXT, Format: 6-19 numeric characters, Field Name: Patient identifier, Mapping: Link Patient table';
COMMENT ON COLUMN drugissue.pracid IS 'Description: Encrypted unique identifier given to a practice in CPRD Aurum, Type: INTEGER, Format: 5, Field Name: Practice identifier, Mapping: Link Practice table';
COMMENT ON COLUMN drugissue.probobsid IS 'Description: Unique identifier for the observation that links to a problem under which this prescription was issued. This refers to an ‘obsid’ in the Observation table which, in turn, can be linked to a record in the Problem table using ‘obsid’., Type: TEXT, Format: Up to 19 numeric characters, Field Name: Problem observation identifier, Mapping: Link Observation and Problem tables';
COMMENT ON COLUMN drugissue.prodcodeid IS 'Description: Unique CPRD code for the treatment selected by the GP, Type: TEXT, Format: 6-18 numeric characters, Field Name: Drug code identifier, Mapping: Lookup: Product dictionary';
COMMENT ON COLUMN drugissue.quantity IS 'Description: Total quantity entered by the GP for the prescribed treatment, Type: DECIMAL, Format: 9.31, Field Name: Quantity, Mapping: None';
COMMENT ON COLUMN drugissue.quantunitid IS 'Description: Unit of the treatment (capsule, tablet), Type: INTEGER, Format: 2, Field Name: Quantity unit identifier, Mapping: Lookup: QuantUnit.txt';
COMMENT ON COLUMN drugissue.staffid IS 'Description: Encrypted unique identifier given to the practice staff member issued the treatment in CPRD Aurum, Type: TEXT, Format: Up to 10 numeric characters, Field Name: Staff identifier, Mapping: Link Staff table';

CREATE TABLE observation (
    consid TEXT,
    enterdate DATE,
    medcodeid TEXT,
    numrangehigh NUMERIC,
    numrangelow NUMERIC,
    numunitid INTEGER,
    obsdate DATE,
    obsid TEXT,
    obstypeid INTEGER,
    parentobsid TEXT,
    patid TEXT,
    pracid INTEGER,
    probobsid TEXT,
    staffid TEXT,
    value NUMERIC 
);

COMMENT ON TABLE observation IS 'The Observation file (Observation_NNN.txt) contains medical history data entered on the GP system, including symptoms, clinical measurements, laboratory test results, diagnoses, and demographic information recorded as a clinical code (e.g. patient ethnicity). Observations that occur during a consultation can be linked via the consultation identifier. CPRD Aurum data are structured in a long format (multiple rows per subject), and observations can be linked to a parent observation.';';
COMMENT ON COLUMN observation.consid IS 'Description: Linked consultation identifier. In EMIS Web® it is not necessary to enter observations within a consultation, so this identifier may be missing., Type: TEXT, Format: Up to 19 numeric characters, Field Name: Consultation identifier, Mapping: Link Consultation table';
COMMENT ON COLUMN observation.enterdate IS 'Description: Date the event was entered into EMIS Web®, Type: DATE, Format: DD/MM/YYYY, Field Name: Entered date, Mapping: None';
COMMENT ON COLUMN observation.medcodeid IS 'Description: CPRD unique code for the medical term selected by the GP, Type: TEXT, Format: 6-18 numeric characters, Field Name: Medical code, Mapping: Lookup: Medical dictionary';
COMMENT ON COLUMN observation.numrangehigh IS 'Description: Value representing the high boundary of the normal range for this measurement, Type: NUMERIC, Format: 19.3, Field Name: Numeric range high, Mapping: None';
COMMENT ON COLUMN observation.numrangelow IS 'Description: Value representing the low boundary of the normal range for this measurement, Type: NUMERIC, Format: 19.3, Field Name: Numeric range low, Mapping: None';
COMMENT ON COLUMN observation.numunitid IS 'Description: Unit of measurement, Type: INTEGER, Format: 10, Field Name: Numeric unit identifier, Mapping: Lookup: NumUnit.txt';
COMMENT ON COLUMN observation.obsdate IS 'Description: Date associated with the event, Type: DATE, Format: DD/MM/YYYY, Field Name: Event date, Mapping: None';
COMMENT ON COLUMN observation.obsid IS 'Description: Unique identifier given to the observation. This is the primary key for this table., Type: TEXT, Format: Up to 19 numeric characters, Field Name: Observation identifier, Mapping: None';
COMMENT ON COLUMN observation.obstypeid IS 'Description: Type of observation (allergy, family history, observation), Type: INTEGER, Format: 5, Field Name: Observation type identifier, Mapping: Lookup: ObsType.txt';
COMMENT ON COLUMN observation.parentobsid IS 'Description: Observation identifier (obsid) that is the parent to the observation. This enables grouping of multiple observations, such as systolic and diastolic blood pressure, or blood test results., Type: TEXT, Format: Up to 19 numeric characters, Field Name: Parent observation identifier, Mapping: Link Observation table';
COMMENT ON COLUMN observation.patid IS 'Description: Encrypted unique identifier given to a patient in CPRD Aurum. The patient identifier is unique to CPRD Aurum and may represent a different patient in the CPRD GOLD database., Type: TEXT, Format: 6-19 numeric characters, Field Name: Patient identifier, Mapping: Link Patient table';
COMMENT ON COLUMN observation.pracid IS 'Description: Encrypted unique identifier given to a practice in CPRD Aurum, Type: INTEGER, Format: 5, Field Name: Practice identifier, Mapping: Link Practice table';
COMMENT ON COLUMN observation.probobsid IS 'Description: Observation identifier (obsid) of any problem that an observation is associated with. An example of this might be an overarching condition that the current observation is associated with such as ‘wheezing’ with the problem observation identifier that links to an observation of ‘asthma’, that in turn contains information in the problem table., Type: TEXT, Format: Up to 19 numeric characters, Field Name: Problem observation identifier, Mapping: Link Observation table';
COMMENT ON COLUMN observation.staffid IS 'Description: Encrypted unique identifier given to the practice staff member who took the consultation in CPRD Aurum, Type: TEXT, Format: Up to 10 numeric characters, Field Name: Staff identifier, Mapping: Link Staff table';
COMMENT ON COLUMN observation.value IS 'Description: Measurement or test value, Type: NUMERIC, Format: 19.3, Field Name: Value, Mapping: None';

CREATE TABLE patient (
    acceptable INTEGER,
    cprd_ddate DATE,
    emis_ddate DATE,
    gender INTEGER,
    mob INTEGER,
    patid TEXT,
    patienttypeid INTEGER,
    pracid INTEGER,
    regenddate DATE,
    regstartdate DATE,
    usualgpstaffid TEXT,
    yob INTEGER 
);

COMMENT ON TABLE patient IS 'The Patient file (Patient_NNN.txt) contains basic patient demographics and patient registration details for the patients.';';
COMMENT ON COLUMN patient.acceptable IS 'Description: Flag to indicate whether the patient has met certain quality standards: 1 =acceptable, 0 = unacceptable, Type: INTEGER, Format: 1, Field Name: Acceptable flag, Mapping: None';
COMMENT ON COLUMN patient.cprd_ddate IS 'Description: Estimated date of death of patient – derived using a CPRD algorithm, Type: DATE, Format: DD/MM/YYYY, Field Name: CPRD death date, Mapping: None';
COMMENT ON COLUMN patient.emis_ddate IS 'Description: Date of death as recorded in the EMIS® software. Researchers are advised to treat the emis_ddate with caution and consider using the cprd_ddate variable below., Type: DATE, Format: DD/MM/YYYY, Field Name: Date of death, Mapping: None';
COMMENT ON COLUMN patient.gender IS 'Description: Patient’s gender, Type: INTEGER, Format: 3, Field Name: Gender, Mapping: Lookup: Gender.txt';
COMMENT ON COLUMN patient.mob IS 'Description: Patient’s month of birth (for those aged under 16)., Type: INTEGER, Format: 2, Field Name: Month of birth, Mapping: None';
COMMENT ON COLUMN patient.patid IS 'Description: Encrypted unique identifier given to a patient in CPRD Aurum. The patient identifier is unique to CPRD Aurum and may represent a different patient in the CPRD GOLD database. This is the primary key for this table. The last 5 characters will be same as the CPRD practice identifier, Type: TEXT, Format: 6-19 numeric characters, Field Name: Patient identifier, Mapping: None';
COMMENT ON COLUMN patient.patienttypeid IS 'Description: The category that the patient has been assigned to e.g. private, regular, temporary., Type: INTEGER, Format: 5, Field Name: Patient type, Mapping: Lookup: PatientType.txt';
COMMENT ON COLUMN patient.pracid IS 'Description: Encrypted unique identifier given to a practice in CPRD Aurum, Type: INTEGER, Format: 5, Field Name: CPRD practice identifier, Mapping: Link Practice table';
COMMENT ON COLUMN patient.regenddate IS 'Description: Date the patient';
COMMENT ON COLUMN patient.regstartdate IS 'Description: The date that the patient registered with the CPRD contributing practice. Most recent date the patient is recorded as having registered at the practice. If a patient deregistered for a period of time and returned, the return date would be recorded., Type: DATE, Format: DD/MM/YYYY, Field Name: Registration start date, Mapping: None';
COMMENT ON COLUMN patient.usualgpstaffid IS 'Description: The GP that the patient is nominally registered with. To be used with the Staff table for reference, Type: TEXT, Format: Up to 10 numeric characters, Field Name: Usual GP, Mapping: Link Staff table';
COMMENT ON COLUMN patient.yob IS 'Description: Patient’s year of birth. This is actual year of birth e.g. 1984., Type: INTEGER, Format: 4, Field Name: Year of birth, Mapping: None';

CREATE TABLE practice (
    lcd DATE,
    pracid INTEGER,
    region INTEGER,
    uts DATE 
);

COMMENT ON TABLE practice IS 'The Practice file (Practice_NNN.txt) contains details of each practice, including the practice identifier, practice region, and the last collection date.';';
COMMENT ON COLUMN practice.lcd IS 'Description: Date of the most recent CPRD data collection for the practice., Type: DATE, Format: DD/MM/YYYY, Field Name: Last Collection Date, Mapping: None';
COMMENT ON COLUMN practice.pracid IS 'Description: Encrypted unique identifier given to a practice in CPRD Aurum. This is the primary key for this table., Type: INTEGER, Format: 5, Field Name: Practice identifier, Mapping: None';
COMMENT ON COLUMN practice.region IS 'Description: Value to indicate where in the UK the practice is based. The region denotes the Strategic Health Authority (for builds to Dec 2021) or ONS region (for builds from Jan 2022) for English practices., Type: INTEGER, Format: 5, Field Name: Region, Mapping: Lookup: Region.txt';
COMMENT ON COLUMN practice.uts IS 'Description: The date at which the practice data is deemed to be of research quality, based on CPRD algorithm. [Not currently populated], Type: DATE, Format: DD/MM/YYYY, Field Name: Up-to-standard date, Mapping: None';

CREATE TABLE problem (
    expduration INTEGER,
    lastrevdate DATE,
    lastrevstaffid TEXT,
    obsid TEXT,
    parentprobobsid TEXT,
    parentprobrelid INTEGER,
    patid TEXT,
    pracid INTEGER,
    probenddate DATE,
    probstatusid INTEGER,
    signid INTEGER 
);

COMMENT ON TABLE problem IS 'b. The Problem file (Problem_NNN.txt) contains details of the patient’s medical history that have been defined by the GP as a ‘problem’. Data in the problem file are linked to the observation file and contain ‘add-on’ data for problem-type observations. Information on identifying associated problems, the significance of the problem, and its expected duration can be found in this table. GPs may use ‘problems’ to manage chronic conditions as it would allow them to group clinical events (including drug prescriptions, measurements, symptom recording) by problem rather than chronologically. To obtain the full problem record (including the clinical code for the problem), problems should be linked to the Observation file using the observation identifier (obsid).';';
COMMENT ON COLUMN problem.expduration IS 'Description: Expected duration of the problem in days, Type: INTEGER, Format: 5, Field Name: Expected duration, Mapping: None';
COMMENT ON COLUMN problem.lastrevdate IS 'Description: Date the problem was last reviewed, Type: DATE, Format: DD/MM/YYYY, Field Name: Last review date, Mapping: None';
COMMENT ON COLUMN problem.lastrevstaffid IS 'Description: Staff member who last reviewed the problem, Type: TEXT, Format: Up to 10 numeric characters, Field Name: Last review staff identifier, Mapping: Link Staff table';
COMMENT ON COLUMN problem.obsid IS 'Description: Unique identifier given to the observation. This is the primary key for this table., Type: TEXT, Format: Up to 19 numeric characters, Field Name: Observation identifier, Mapping: Link Observation table';
COMMENT ON COLUMN problem.parentprobobsid IS 'Description: Observation identifier for the parent observation of the problem. This can be used to group problems via the Observation table., Type: TEXT, Format: Up to 19 numeric characters, Field Name: Parent problem observation identifier, Mapping: Link Observation table';
COMMENT ON COLUMN problem.parentprobrelid IS 'Description: Description of the relationship of the problem to another problem e.g. the problem may have evolved or been merged with another problem as the problem, or the GP’s understanding of the problem, changes, Type: INTEGER, Format: 5, Field Name: Parent problem relationship identifier, Mapping: Lookup ParentProbRel.txt';
COMMENT ON COLUMN problem.patid IS 'Description: Encrypted unique identifier given to a patient in CPRD Aurum. The patient identifier is unique to CPRD Aurum and may represent a different patient in the CPRD GOLD database., Type: TEXT, Format: 6-19 numeric characters, Field Name: Patient identifier, Mapping: Link Patient table';
COMMENT ON COLUMN problem.pracid IS 'Description: Encrypted unique identifier given to a practice in CPRD Aurum, Type: INTEGER, Format: 5, Field Name: Practice identifier, Mapping: Link Practice table';
COMMENT ON COLUMN problem.probenddate IS 'Description: Date the problem ended, Type: DATE, Format: DD/MM/YYYY, Field Name: Problem end date, Mapping: None';
COMMENT ON COLUMN problem.probstatusid IS 'Description: Status of the problem (active, past), Type: INTEGER, Format: 5, Field Name: Problem status identifier, Mapping: Lookup: ProbStatus.txt';
COMMENT ON COLUMN problem.signid IS 'Description: Significance of the problem (minor, significant), Type: INTEGER, Format: 5, Field Name: Significance, Mapping: Lookup: Sign.txt';

CREATE TABLE referral (
    obsid TEXT,
    patid TEXT,
    pracid INTEGER,
    refmodeid INTEGER,
    refservicetypeid INTEGER,
    refsourceorgid INTEGER,
    reftargetorgid INTEGER,
    refurgencyid INTEGER 
);

COMMENT ON TABLE referral IS 'a. The Referral file (Referral_NNN.txt) contains referral details recorded on the GP system. Data in the referral file are linked to the observation file and contain ‘add-on’ data for referral-type observations. These files contain information involving both inbound and outbound patient referrals to or from external care centres (normally to secondary care locations such as hospitals for inpatient or outpatient care). To obtain the full referral record (including reason for the referral and date), referrals should be linked to the Observation file using the observation identifier (obsid).';';
COMMENT ON COLUMN referral.obsid IS 'Description: Unique identifier given to the observation. This is the primary key for this table., Type: TEXT, Format: Up to 19 numeric characters, Field Name: Observation identifier, Mapping: Link Observation table';
COMMENT ON COLUMN referral.patid IS 'Description: Encrypted unique identifier given to a patient in CPRD Aurum. The patient identifier is unique to CPRD Aurum and may represent a different patient in the CPRD GOLD database., Type: TEXT, Format: 6-19 numeric characters, Field Name: Patient identifier, Mapping: Link Patient table';
COMMENT ON COLUMN referral.pracid IS 'Description: Encrypted unique identifier given to a practice in CPRD Aurum, Type: INTEGER, Format: 5, Field Name: Practice identifier, Mapping: Link Practice table';
COMMENT ON COLUMN referral.refmodeid IS 'Description: Mode by which the referral was made e.g. telephone, written, Type: INTEGER, Format: 1, Field Name: Referral mode identifier, Mapping: Lookup: RefMode.txt';
COMMENT ON COLUMN referral.refservicetypeid IS 'Description: Type of service the referral relates to e.g. assessment, management, investigation, Type: INTEGER, Format: 2, Field Name: Referral service type identifier, Mapping: Lookup: RefServiceType.txt';
COMMENT ON COLUMN referral.refsourceorgid IS 'Description: Source organisation of the referral. Organisations are identified by an ID number and each organisation has a type (e.g. hospital inpatient department, community clinic). Both the organisation table and the OrgType lookup are required. The lookups are undergoing anonymisation work. [Not currently populated], Type: INTEGER, Format: 10, Field Name: Referral source organisation identifier, Mapping: Lookups: Organisation.txt [not included in initial release] and OrgType.txt';
COMMENT ON COLUMN referral.reftargetorgid IS 'Description: Source organisation of the referral. Organisations are identified by an ID number and each organisation has a type (e.g. hospital inpatient department, community clinic). Both the organisation table and the OrgType lookup are required. The lookups are undergoing anonymisation work. [Not currently populated], Type: INTEGER, Format: 10, Field Name: Referral target organisation identifier, Mapping: Lookups: Organisation.txt [not included in initial release] and OrgType.txt';
COMMENT ON COLUMN referral.refurgencyid IS 'Description: Urgency of the referral e.g. routine, urgent, dated, Type: INTEGER, Format: 1, Field Name: Referral urgency identifier, Mapping: Lookup: RefUrgency.txt';

CREATE TABLE staff (
    jobcatid INTEGER,
    pracid INTEGER,
    staffid TEXT 
);

COMMENT ON TABLE staff IS 'The Staff file (Staff_NNN.txt) contains practice staff details for each staff member, including job category.';';
COMMENT ON COLUMN staff.jobcatid IS 'Description: Job category of the staff member who created the event, Type: INTEGER, Format: 5, Field Name: Job category, Mapping: Lookup JobCat.txt';
COMMENT ON COLUMN staff.pracid IS 'Description: Encrypted unique identifier given to a practice in CPRD Aurum, Type: INTEGER, Format: 5, Field Name: Practice identifier, Mapping: Link Practice table';
COMMENT ON COLUMN staff.staffid IS 'Description: Encrypted unique identifier given to the practice staff member in CPRD Aurum. This is the primary key for this table., Type: TEXT, Format: Up to 10 numeric characters, Field Name: Staff identifier, Mapping: None';