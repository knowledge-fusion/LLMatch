CREATE TABLE admissions (
    admission_location VARCHAR(50),
    admission_type VARCHAR(50),
    admittime TIMESTAMP(0),
    deathtime TIMESTAMP(0),
    diagnosis VARCHAR(255),
    discharge_location VARCHAR(50),
    dischtime TIMESTAMP(0),
    edouttime TIMESTAMP(0),
    edregtime TIMESTAMP(0),
    ethnicity VARCHAR(200),
    hadm_id INT,
    has_chartevents_data SMALLINT,
    hospital_expire_flag SMALLINT,
    insurance VARCHAR(255),
    language VARCHAR(10),
    marital_status VARCHAR(50),
    religion VARCHAR(50),
    row_id INT,
    subject_id INT
);

COMMENT ON TABLE admissions IS 'The ADMISSIONS table gives information regarding a patient’s admission to the hospital. Since each unique hospital visit for a patient is assigned a unique HADM_ID, the ADMISSIONS table can be considered as a definition table for HADM_ID. Information available includes timing information for admission and discharge, demographic information, the source of the admission, and so on.';';
COMMENT ON COLUMN admissions.admission_location IS 'Previous location of the patient prior to arriving at the hospital. There are 9 possible values: EMERGENCY ROOM ADMIT, TRANSFER FROM HOSP/EXTRAM, TRANSFER FROM OTHER HEALT, CLINIC REFERRAL/PREMATURE, ** INFO NOT AVAILABLE **, TRANSFER FROM SKILLED NUR, TRSF WITHIN THIS FACILITY, HMO REFERRAL/SICK, PHYS REFERRAL/NORMAL DELI.';
COMMENT ON COLUMN admissions.admission_type IS 'Describes the type of the admission: ELECTIVE, URGENT, NEWBORN, or EMERGENCY.';
COMMENT ON COLUMN admissions.admittime IS 'Date and time the patient was admitted to the hospital.';
COMMENT ON COLUMN admissions.deathtime IS 'Time of in-hospital death for the patient, if applicable. Usually the same as DISCHTIME, but discrepancies can occur due to typographical errors.';
COMMENT ON COLUMN admissions.diagnosis IS 'Preliminary, free text diagnosis for the patient on hospital admission. Assigned by the admitting clinician.';
COMMENT ON COLUMN admissions.discharge_location IS 'Location to which the patient was discharged.';
COMMENT ON COLUMN admissions.dischtime IS 'Date and time the patient was discharged from the hospital.';
COMMENT ON COLUMN admissions.edouttime IS 'Time that the patient was discharged from the emergency department.';
COMMENT ON COLUMN admissions.edregtime IS 'Time that the patient was registered in the emergency department.';
COMMENT ON COLUMN admissions.ethnicity IS 'Ethnicity of the patient. Sourced from the admission, discharge, and transfers (ADT) data from the hospital database.';
COMMENT ON COLUMN admissions.hadm_id IS 'Unique identifier for a single patient’s admission to the hospital. Ranges from 1000000 - 1999999.';
COMMENT ON COLUMN admissions.has_chartevents_data IS 'Indicates whether chart events data is available for this admission.';
COMMENT ON COLUMN admissions.hospital_expire_flag IS 'Indicates whether the patient died within the given hospitalization. 1 indicates death in the hospital, 0 indicates survival to hospital discharge.';
COMMENT ON COLUMN admissions.insurance IS 'Describes the patient\';
COMMENT ON COLUMN admissions.language IS 'Language spoken by the patient. Sourced from the admission, discharge, and transfers (ADT) data from the hospital database.';
COMMENT ON COLUMN admissions.marital_status IS 'Marital status of the patient. Sourced from the admission, discharge, and transfers (ADT) data from the hospital database.';
COMMENT ON COLUMN admissions.religion IS 'Religion of the patient. Sourced from the admission, discharge, and transfers (ADT) data from the hospital database.';
COMMENT ON COLUMN admissions.row_id IS 'Unique identifier for the row.';
COMMENT ON COLUMN admissions.subject_id IS 'Unique identifier for the patient. Can be linked to the PATIENTS table using this identifier.';

CREATE TABLE callout (
    acknowledge_status VARCHAR(20),
    acknowledgetime TIMESTAMP(0),
    callout_outcome VARCHAR(20),
    callout_service VARCHAR(10),
    callout_status VARCHAR(20),
    callout_wardid INT,
    createtime TIMESTAMP(0),
    curr_careunit VARCHAR(15),
    curr_wardid INT,
    currentreservationtime TIMESTAMP(0),
    discharge_wardid INT,
    firstreservationtime TIMESTAMP(0),
    hadm_id INT,
    outcometime TIMESTAMP(0),
    request_cdiff SMALLINT,
    request_mrsa SMALLINT,
    request_resp SMALLINT,
    request_tele SMALLINT,
    request_vre SMALLINT,
    row_id INT,
    subject_id INT,
    submit_careunit VARCHAR(15),
    submit_wardid INT,
    updatetime TIMESTAMP(0)
);

COMMENT ON TABLE callout IS 'Record of when patients were ready for discharge (called out), and the actual time of their discharge (or more generally, their outcome).';';
COMMENT ON COLUMN callout.acknowledge_status IS 'The status of the response to the call out request.';
COMMENT ON COLUMN callout.acknowledgetime IS 'Time at which the call out request was acknowledged.';
COMMENT ON COLUMN callout.callout_outcome IS 'The result of the call out request. either a cancellation or a discharge.';
COMMENT ON COLUMN callout.callout_service IS 'Identifies the service that the patient is called out to.';
COMMENT ON COLUMN callout.callout_status IS 'Current status of the call out request.';
COMMENT ON COLUMN callout.callout_wardid IS 'Identifies the ward where the patient is to be discharged to. A value of 1 indicates the first available ward. A value of 0 indicates home.';
COMMENT ON COLUMN callout.createtime IS 'Time at which the call out request was created.';
COMMENT ON COLUMN callout.curr_careunit IS 'If the ward where the patient is currently residing is an ICU, the ICU type is listed here.';
COMMENT ON COLUMN callout.curr_wardid IS 'Identifies the ward where the patient is currently residing.';
COMMENT ON COLUMN callout.currentreservationtime IS 'Latest time at which a ward was reserved for the call out request.';
COMMENT ON COLUMN callout.discharge_wardid IS 'The ward to which the patient was discharged.';
COMMENT ON COLUMN callout.firstreservationtime IS 'First time at which a ward was reserved for the call out request.';
COMMENT ON COLUMN callout.hadm_id IS 'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN callout.outcometime IS 'Time at which the outcome (cancelled or discharged) occurred.';
COMMENT ON COLUMN callout.request_cdiff IS 'Indicates if special precautions are required.';
COMMENT ON COLUMN callout.request_mrsa IS 'Indicates if special precautions are required.';
COMMENT ON COLUMN callout.request_resp IS 'Indicates if special precautions are required.';
COMMENT ON COLUMN callout.request_tele IS 'Indicates if special precautions are required.';
COMMENT ON COLUMN callout.request_vre IS 'Indicates if special precautions are required.';
COMMENT ON COLUMN callout.row_id IS 'Unique row identifier.';
COMMENT ON COLUMN callout.subject_id IS 'Foreign key. Identifies the patient.';
COMMENT ON COLUMN callout.submit_careunit IS 'If the ward where the call was submitted was an ICU, the ICU type is listed here.';
COMMENT ON COLUMN callout.submit_wardid IS 'Identifies the ward where the call out request was submitted.';
COMMENT ON COLUMN callout.updatetime IS 'Last time at which the call out request was updated.';

CREATE TABLE caregivers (
    cgid INT,
    description VARCHAR(30),
    label VARCHAR(15),
    row_id INT
);

COMMENT ON TABLE caregivers IS 'List of caregivers associated with an ICU stay.';';
COMMENT ON COLUMN caregivers.cgid IS 'Unique caregiver identifier.';
COMMENT ON COLUMN caregivers.description IS 'More detailed description of the caregiver, if available.';
COMMENT ON COLUMN caregivers.label IS 'Title of the caregiver, for example MD or RN.';
COMMENT ON COLUMN caregivers.row_id IS 'Unique row identifier.';

CREATE TABLE chartevents (
    cgid INT,
    charttime TIMESTAMP(0),
    error INT,
    hadm_id INT,
    icustay_id INT,
    itemid INT,
    resultstatus VARCHAR(50),
    row_id INT,
    stopped VARCHAR(50),
    storetime TIMESTAMP(0),
    subject_id INT,
    value VARCHAR(255),
    valuenum DOUBLE,
    valueuom VARCHAR(50),
    warning INT
);

COMMENT ON TABLE chartevents IS 'Events occuring on a patient chart.';';
COMMENT ON COLUMN chartevents.cgid IS 'Foreign key. Identifies the caregiver.';
COMMENT ON COLUMN chartevents.charttime IS 'Time when the event occured.';
COMMENT ON COLUMN chartevents.error IS 'Flag to highlight an error with the event.';
COMMENT ON COLUMN chartevents.hadm_id IS 'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN chartevents.icustay_id IS 'Foreign key. Identifies the ICU stay.';
COMMENT ON COLUMN chartevents.itemid IS 'Foreign key. Identifies the charted item.';
COMMENT ON COLUMN chartevents.resultstatus IS 'Result status of lab data.';
COMMENT ON COLUMN chartevents.row_id IS 'Unique row identifier.';
COMMENT ON COLUMN chartevents.stopped IS 'Text string indicating the stopped status of an event (i.e. stopped, not stopped).';
COMMENT ON COLUMN chartevents.storetime IS 'Time when the event was recorded in the system.';
COMMENT ON COLUMN chartevents.subject_id IS 'Foreign key. Identifies the patient.';
COMMENT ON COLUMN chartevents.value IS 'Value of the event as a text string.';
COMMENT ON COLUMN chartevents.valuenum IS 'Value of the event as a number.';
COMMENT ON COLUMN chartevents.valueuom IS 'Unit of measurement.';
COMMENT ON COLUMN chartevents.warning IS 'Flag to highlight that the value has triggered a warning.';

CREATE TABLE cptevents (
    chartdate TIMESTAMP(0),
    costcenter VARCHAR(10),
    cpt_cd VARCHAR(10),
    cpt_number INT,
    cpt_suffix VARCHAR(5),
    description VARCHAR(200),
    hadm_id INT,
    row_id INT,
    sectionheader VARCHAR(50),
    subject_id INT,
    subsectionheader VARCHAR(255),
    ticket_id_seq INT
);

COMMENT ON TABLE cptevents IS 'Events recorded in Current Procedural Terminology.';';
COMMENT ON COLUMN cptevents.chartdate IS 'Date when the event occured, if available.';
COMMENT ON COLUMN cptevents.costcenter IS 'Center recording the code, for example the ICU or the respiratory unit.';
COMMENT ON COLUMN cptevents.cpt_cd IS 'Current Procedural Terminology code.';
COMMENT ON COLUMN cptevents.cpt_number IS 'Numerical element of the Current Procedural Terminology code.';
COMMENT ON COLUMN cptevents.cpt_suffix IS 'Text element of the Current Procedural Terminology, if any. Indicates code category.';
COMMENT ON COLUMN cptevents.description IS 'Description of the Current Procedural Terminology, if available.';
COMMENT ON COLUMN cptevents.hadm_id IS 'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN cptevents.row_id IS 'Unique row identifier.';
COMMENT ON COLUMN cptevents.sectionheader IS 'High-level section of the Current Procedural Terminology code.';
COMMENT ON COLUMN cptevents.subject_id IS 'Foreign key. Identifies the patient.';
COMMENT ON COLUMN cptevents.subsectionheader IS 'Subsection of the Current Procedural Terminology code.';
COMMENT ON COLUMN cptevents.ticket_id_seq IS 'Sequence number of the event, derived from the ticket ID.';

CREATE TABLE d_cpt (
    category SMALLINT,
    codesuffix VARCHAR(5),
    maxcodeinsubsection INT,
    mincodeinsubsection INT,
    row_id INT,
    sectionheader VARCHAR(50),
    sectionrange VARCHAR(100),
    subsectionheader VARCHAR(255),
    subsectionrange VARCHAR(100)
);

COMMENT ON TABLE d_cpt IS 'High-level dictionary of the Current Procedural Terminology. Unlike all other definition tables, D_CPT does not have a one to one mapping with the corresponding CPT_CD in CPTEVENTS, rather each row of D_CPT maps to a range of CPT_CD';';
COMMENT ON COLUMN d_cpt.category IS 'Code category.';
COMMENT ON COLUMN d_cpt.codesuffix IS 'Text element of the Current Procedural Terminology, if any.';
COMMENT ON COLUMN d_cpt.maxcodeinsubsection IS 'Maximum code within the subsection.';
COMMENT ON COLUMN d_cpt.mincodeinsubsection IS 'Minimum code within the subsection.';
COMMENT ON COLUMN d_cpt.row_id IS 'Unique row identifier.';
COMMENT ON COLUMN d_cpt.sectionheader IS 'Section header.';
COMMENT ON COLUMN d_cpt.sectionrange IS 'Range of codes within the high-level section.';
COMMENT ON COLUMN d_cpt.subsectionheader IS 'Subsection header.';
COMMENT ON COLUMN d_cpt.subsectionrange IS 'Range of codes within the subsection.';

CREATE TABLE d_icd_diagnoses (
    icd9_code VARCHAR(10),
    long_title VARCHAR(255),
    row_id INT,
    short_title VARCHAR(50)
);

COMMENT ON TABLE d_icd_diagnoses IS 'Dictionary of the International Classification of Diseases, 9th Revision (Diagnoses).';';
COMMENT ON COLUMN d_icd_diagnoses.icd9_code IS 'ICD9 code - note that this is a fixed length character field, as whitespaces are important in uniquely identifying ICD-9 codes.';
COMMENT ON COLUMN d_icd_diagnoses.long_title IS 'Long title associated with the code.';
COMMENT ON COLUMN d_icd_diagnoses.row_id IS 'Unique row identifier.';
COMMENT ON COLUMN d_icd_diagnoses.short_title IS 'Short title associated with the code.';

CREATE TABLE d_icd_procedures (
    icd9_code VARCHAR(10),
    long_title VARCHAR(255),
    row_id INT,
    short_title VARCHAR(50)
);

COMMENT ON TABLE d_icd_procedures IS 'This table defines International Classification of Diseases Version 9 (ICD-9) codes for procedures. These codes are assigned at the end of the patient’s stay and are used by the hospital to bill for care provided. They can further be used to identify if certain procedures have been performed (e.g. surgery).';';
COMMENT ON COLUMN d_icd_procedures.icd9_code IS 'ICD9 code - note that this is a fixed length character field, as whitespaces are important in uniquely identifying ICD-9 codes.';
COMMENT ON COLUMN d_icd_procedures.long_title IS 'Long title associated with the code.';
COMMENT ON COLUMN d_icd_procedures.row_id IS 'Unique row identifier.';
COMMENT ON COLUMN d_icd_procedures.short_title IS 'Short title associated with the code.';

CREATE TABLE d_items (
    abbreviation VARCHAR(100),
    category VARCHAR(100),
    conceptid INT,
    dbsource VARCHAR(20),
    itemid INT,
    label VARCHAR(200),
    linksto VARCHAR(50),
    param_type VARCHAR(30),
    row_id INT,
    unitname VARCHAR(100)
);

COMMENT ON TABLE d_items IS 'Dictionary of non-laboratory-related charted items.';';
COMMENT ON COLUMN d_items.abbreviation IS 'Abbreviation associated with the item.';
COMMENT ON COLUMN d_items.category IS 'Category of data which the concept falls under.';
COMMENT ON COLUMN d_items.conceptid IS 'Identifier used to harmonize concepts identified by multiple ITEMIDs. CONCEPTIDs are planned but not yet implemented (all values are NULL).';
COMMENT ON COLUMN d_items.dbsource IS 'Source database of the item.';
COMMENT ON COLUMN d_items.itemid IS 'Primary key. Identifies the charted item.';
COMMENT ON COLUMN d_items.label IS 'Label identifying the item.';
COMMENT ON COLUMN d_items.linksto IS 'Table which contains data for the given ITEMID.';
COMMENT ON COLUMN d_items.param_type IS 'Type of item, for example solution or ingredient.';
COMMENT ON COLUMN d_items.row_id IS 'Unique row identifier.';
COMMENT ON COLUMN d_items.unitname IS 'Unit associated with the item.';

CREATE TABLE d_labitems (
    category VARCHAR(100),
    fluid VARCHAR(100),
    itemid INT,
    label VARCHAR(100),
    loinc_code VARCHAR(100),
    row_id INT
);

COMMENT ON TABLE d_labitems IS 'Dictionary of laboratory-related items.';';
COMMENT ON COLUMN d_labitems.category IS 'Category of item, for example chemistry or hematology.';
COMMENT ON COLUMN d_labitems.fluid IS 'Fluid associated with the item, for example blood or urine.';
COMMENT ON COLUMN d_labitems.itemid IS 'Foreign key. Identifies the charted item.';
COMMENT ON COLUMN d_labitems.label IS 'Label identifying the item.';
COMMENT ON COLUMN d_labitems.loinc_code IS 'Logical Observation Identifiers Names and Codes (LOINC) mapped to the item, if available.';
COMMENT ON COLUMN d_labitems.row_id IS 'Unique row identifier.';

CREATE TABLE datetimeevents (
    cgid INT,
    charttime TIMESTAMP(0),
    error SMALLINT,
    hadm_id INT,
    icustay_id INT,
    itemid INT,
    resultstatus VARCHAR(50),
    row_id INT,
    stopped VARCHAR(50),
    storetime TIMESTAMP(0),
    subject_id INT,
    value TIMESTAMP(0),
    valueuom VARCHAR(50),
    warning SMALLINT
);

COMMENT ON TABLE datetimeevents IS 'Events relating to a datetime.';';
COMMENT ON COLUMN datetimeevents.cgid IS 'Foreign key. Identifies the caregiver.';
COMMENT ON COLUMN datetimeevents.charttime IS 'Time when the event occured.';
COMMENT ON COLUMN datetimeevents.error IS 'Flag to highlight an error with the event.';
COMMENT ON COLUMN datetimeevents.hadm_id IS 'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN datetimeevents.icustay_id IS 'Foreign key. Identifies the ICU stay.';
COMMENT ON COLUMN datetimeevents.itemid IS 'Foreign key. Identifies the charted item.';
COMMENT ON COLUMN datetimeevents.resultstatus IS 'Result status of lab data.';
COMMENT ON COLUMN datetimeevents.row_id IS 'Unique row identifier.';
COMMENT ON COLUMN datetimeevents.stopped IS 'Event was explicitly marked as stopped. Infrequently used by caregivers.';
COMMENT ON COLUMN datetimeevents.storetime IS 'Time when the event was recorded in the system.';
COMMENT ON COLUMN datetimeevents.subject_id IS 'Foreign key. Identifies the patient.';
COMMENT ON COLUMN datetimeevents.value IS 'Value of the event as a text string.';
COMMENT ON COLUMN datetimeevents.valueuom IS 'Unit of measurement.';
COMMENT ON COLUMN datetimeevents.warning IS 'Flag to highlight that the value has triggered a warning.';

CREATE TABLE diagnoses_icd (
    hadm_id INT,
    icd9_code VARCHAR(10),
    row_id INT,
    seq_num INT,
    subject_id INT
);

COMMENT ON TABLE diagnoses_icd IS 'During routine hospital care, patients are billed by the hospital for diagnoses associated with their hospital stay. This table contains a record of all diagnoses a patient was billed for during their hospital stay using the ICD-9 and ICD-10 ontologies. Diagnoses are billed on hospital discharge, and are determined by trained persons who read signed clinical notes.';';
COMMENT ON COLUMN diagnoses_icd.hadm_id IS 'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN diagnoses_icd.icd9_code IS 'ICD9 code for the diagnosis.';
COMMENT ON COLUMN diagnoses_icd.row_id IS 'Unique row identifier.';
COMMENT ON COLUMN diagnoses_icd.seq_num IS 'The priority assigned to the diagnoses. The priority can be interpreted as a ranking of which diagnoses are “important”, but many caveats to this broad statement exist. For example, patients who are diagnosed with sepsis must have sepsis as their 2nd billed condition. The 1st billed condition must be the infectious agent. There’s also less importance placed on ranking low priority diagnoses “correctly” (as there may be no correct ordering of the priority of the 5th - 10th diagnosis codes, for example).';
COMMENT ON COLUMN diagnoses_icd.subject_id IS 'Foreign key. Identifies the patient.';

CREATE TABLE drgcodes (
    description VARCHAR(255),
    drg_code VARCHAR(20),
    drg_mortality SMALLINT,
    drg_severity SMALLINT,
    drg_type VARCHAR(20),
    hadm_id INT,
    row_id INT,
    subject_id INT
);

COMMENT ON TABLE drgcodes IS 'Diagnosis related groups (DRGs) are used by the hospital to obtain reimbursement for a patient’s hospital stay. The codes correspond to the primary reason for a patient’s stay at the hospital.';';
COMMENT ON COLUMN drgcodes.description IS 'Description of the Diagnosis-Related Group';
COMMENT ON COLUMN drgcodes.drg_code IS 'Diagnosis-Related Group code';
COMMENT ON COLUMN drgcodes.drg_mortality IS 'Relative mortality, available for type APR only.';
COMMENT ON COLUMN drgcodes.drg_severity IS 'Relative severity, available for type APR only.';
COMMENT ON COLUMN drgcodes.drg_type IS 'Type of Diagnosis-Related Group, for example APR is All Patient Refined';
COMMENT ON COLUMN drgcodes.hadm_id IS 'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN drgcodes.row_id IS 'Unique row identifier.';
COMMENT ON COLUMN drgcodes.subject_id IS 'Foreign key. Identifies the patient.';

CREATE TABLE icustays (
    dbsource VARCHAR(20),
    first_careunit VARCHAR(20),
    first_wardid SMALLINT,
    hadm_id INT,
    icustay_id INT,
    intime TIMESTAMP(0),
    last_careunit VARCHAR(20),
    last_wardid SMALLINT,
    los DOUBLE,
    outtime TIMESTAMP(0),
    row_id INT,
    subject_id INT
);

COMMENT ON TABLE icustays IS 'List of ICU admissions.';';
COMMENT ON COLUMN icustays.dbsource IS 'Source database of the item.';
COMMENT ON COLUMN icustays.first_careunit IS 'First careunit associated with the ICU stay.';
COMMENT ON COLUMN icustays.first_wardid IS 'Identifier for the first ward the patient was located in.';
COMMENT ON COLUMN icustays.hadm_id IS 'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN icustays.icustay_id IS 'Primary key. Identifies the ICU stay.';
COMMENT ON COLUMN icustays.intime IS 'Time of admission to the ICU.';
COMMENT ON COLUMN icustays.last_careunit IS 'Last careunit associated with the ICU stay.';
COMMENT ON COLUMN icustays.last_wardid IS 'Identifier for the last ward the patient is located in.';
COMMENT ON COLUMN icustays.los IS 'Length of stay in the ICU in minutes.';
COMMENT ON COLUMN icustays.outtime IS 'Time of discharge from the ICU.';
COMMENT ON COLUMN icustays.row_id IS 'Unique row identifier.';
COMMENT ON COLUMN icustays.subject_id IS 'Foreign key. Identifies the patient.';

CREATE TABLE inputevents_cv (
    amount DOUBLE,
    amountuom VARCHAR(30),
    cgid INT,
    charttime TIMESTAMP(0),
    hadm_id INT,
    icustay_id INT,
    itemid INT,
    linkorderid INT,
    newbottle INT,
    orderid INT,
    originalamount DOUBLE,
    originalamountuom VARCHAR(30),
    originalrate DOUBLE,
    originalrateuom VARCHAR(30),
    originalroute VARCHAR(30),
    originalsite VARCHAR(30),
    rate DOUBLE,
    rateuom VARCHAR(30),
    row_id INT,
    stopped VARCHAR(30),
    storetime TIMESTAMP(0),
    subject_id INT
);

COMMENT ON TABLE inputevents_cv IS 'Events relating to fluid input for patients whose data was originally stored in the CareVue database.';';
COMMENT ON COLUMN inputevents_cv.amount IS 'Amount of the item administered to the patient.';
COMMENT ON COLUMN inputevents_cv.amountuom IS 'Unit of measurement for the amount.';
COMMENT ON COLUMN inputevents_cv.cgid IS 'Foreign key. Identifies the caregiver.';
COMMENT ON COLUMN inputevents_cv.charttime IS 'Time of that the input was started or received.';
COMMENT ON COLUMN inputevents_cv.hadm_id IS 'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN inputevents_cv.icustay_id IS 'Foreign key. Identifies the ICU stay.';
COMMENT ON COLUMN inputevents_cv.itemid IS 'Foreign key. Identifies the charted item.';
COMMENT ON COLUMN inputevents_cv.linkorderid IS 'Identifier linking orders across multiple administrations. LINKORDERID is always equal to the first occuring ORDERID of the series.';
COMMENT ON COLUMN inputevents_cv.newbottle IS 'Indicates when a new bottle of the solution was hung at the bedside.';
COMMENT ON COLUMN inputevents_cv.orderid IS 'Identifier linking items which are grouped in a solution.';
COMMENT ON COLUMN inputevents_cv.originalamount IS 'Amount of the item which was originally charted.';
COMMENT ON COLUMN inputevents_cv.originalamountuom IS 'Unit of measurement for the original amount.';
COMMENT ON COLUMN inputevents_cv.originalrate IS 'Rate of administration originally chosen for the item.';
COMMENT ON COLUMN inputevents_cv.originalrateuom IS 'Unit of measurement for the rate originally chosen.';
COMMENT ON COLUMN inputevents_cv.originalroute IS 'Route of administration originally chosen for the item.';
COMMENT ON COLUMN inputevents_cv.originalsite IS 'Anatomical site for the original administration of the item.';
COMMENT ON COLUMN inputevents_cv.rate IS 'Rate at which the item is being administered to the patient.';
COMMENT ON COLUMN inputevents_cv.rateuom IS 'Unit of measurement for the rate.';
COMMENT ON COLUMN inputevents_cv.row_id IS 'Unique row identifier.';
COMMENT ON COLUMN inputevents_cv.stopped IS 'Event was explicitly marked as stopped. Infrequently used by caregivers.';
COMMENT ON COLUMN inputevents_cv.storetime IS 'Time when the event was recorded in the system.';
COMMENT ON COLUMN inputevents_cv.subject_id IS 'Foreign key. Identifies the patient.';

CREATE TABLE inputevents_mv (
    amount DOUBLE,
    amountuom VARCHAR(30),
    cancelreason SMALLINT,
    cgid INT,
    comments_canceledby VARCHAR(40),
    comments_date TIMESTAMP(0),
    comments_editedby VARCHAR(30),
    continueinnextdept SMALLINT,
    endtime TIMESTAMP(0),
    hadm_id INT,
    icustay_id INT,
    isopenbag SMALLINT,
    itemid INT,
    linkorderid INT,
    ordercategorydescription VARCHAR(50),
    ordercategoryname VARCHAR(100),
    ordercomponenttypedescription VARCHAR(200),
    orderid INT,
    originalamount DOUBLE,
    originalrate DOUBLE,
    patientweight DOUBLE,
    rate DOUBLE,
    rateuom VARCHAR(30),
    row_id INT,
    secondaryordercategoryname VARCHAR(100),
    starttime TIMESTAMP(0),
    statusdescription VARCHAR(30),
    storetime TIMESTAMP(0),
    subject_id INT,
    totalamount DOUBLE,
    totalamountuom VARCHAR(50)
);

COMMENT ON TABLE inputevents_mv IS 'Events relating to fluid input for patients whose data was originally stored in the MetaVision database.';';
COMMENT ON COLUMN inputevents_mv.amount IS 'Amount of the item administered to the patient.';
COMMENT ON COLUMN inputevents_mv.amountuom IS 'Unit of measurement for the amount.';
COMMENT ON COLUMN inputevents_mv.cancelreason IS 'Reason for cancellation, if cancelled.';
COMMENT ON COLUMN inputevents_mv.cgid IS 'Foreign key. Identifies the caregiver.';
COMMENT ON COLUMN inputevents_mv.comments_canceledby IS 'The title of the caregiver who canceled the order.';
COMMENT ON COLUMN inputevents_mv.comments_date IS 'Time at which the caregiver edited or cancelled the order.';
COMMENT ON COLUMN inputevents_mv.comments_editedby IS 'The title of the caregiver who edited the order.';
COMMENT ON COLUMN inputevents_mv.continueinnextdept IS 'Indicates whether the item will be continued in the next department where the patient is transferred to.';
COMMENT ON COLUMN inputevents_mv.endtime IS 'Time when the event ended.';
COMMENT ON COLUMN inputevents_mv.hadm_id IS 'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN inputevents_mv.icustay_id IS 'Foreign key. Identifies the ICU stay.';
COMMENT ON COLUMN inputevents_mv.isopenbag IS 'Indicates whether the bag containing the solution is open.';
COMMENT ON COLUMN inputevents_mv.itemid IS 'Foreign key. Identifies the charted item.';
COMMENT ON COLUMN inputevents_mv.linkorderid IS 'Identifier linking orders across multiple administrations. LINKORDERID is always equal to the first occuring ORDERID of the series.';
COMMENT ON COLUMN inputevents_mv.ordercategorydescription IS 'The type of item administered.';
COMMENT ON COLUMN inputevents_mv.ordercategoryname IS 'A group which the item corresponds to.';
COMMENT ON COLUMN inputevents_mv.ordercomponenttypedescription IS 'The role of the item administered in the order.';
COMMENT ON COLUMN inputevents_mv.orderid IS 'Identifier linking items which are grouped in a solution.';
COMMENT ON COLUMN inputevents_mv.originalamount IS 'Amount of the item which was originally charted.';
COMMENT ON COLUMN inputevents_mv.originalrate IS 'Rate of administration originally chosen for the item.';
COMMENT ON COLUMN inputevents_mv.patientweight IS 'For drugs dosed by weight, the value of the weight used in the calculation.';
COMMENT ON COLUMN inputevents_mv.rate IS 'Rate at which the item is being administered to the patient.';
COMMENT ON COLUMN inputevents_mv.rateuom IS 'Unit of measurement for the rate.';
COMMENT ON COLUMN inputevents_mv.row_id IS 'Unique row identifier.';
COMMENT ON COLUMN inputevents_mv.secondaryordercategoryname IS 'A secondary group for those items with more than one grouping possible.';
COMMENT ON COLUMN inputevents_mv.starttime IS 'Time when the event started.';
COMMENT ON COLUMN inputevents_mv.statusdescription IS 'The current status of the order: stopped, rewritten, running or cancelled.';
COMMENT ON COLUMN inputevents_mv.storetime IS 'Time when the event was recorded in the system.';
COMMENT ON COLUMN inputevents_mv.subject_id IS 'Foreign key. Identifies the patient.';
COMMENT ON COLUMN inputevents_mv.totalamount IS 'The total amount in the solution for the given item.';
COMMENT ON COLUMN inputevents_mv.totalamountuom IS 'Unit of measurement for the total amount in the solution.';

CREATE TABLE labevents (
    charttime TIMESTAMP(0),
    flag VARCHAR(20),
    hadm_id INT,
    itemid INT,
    row_id INT,
    subject_id INT,
    value VARCHAR(200),
    valuenum DOUBLE,
    valueuom VARCHAR(20)
);

COMMENT ON TABLE labevents IS 'Events relating to laboratory tests.';';
COMMENT ON COLUMN labevents.charttime IS 'Time when the event occured.';
COMMENT ON COLUMN labevents.flag IS 'Flag indicating whether the lab test value is considered abnormal (null if the test was normal).';
COMMENT ON COLUMN labevents.hadm_id IS 'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN labevents.itemid IS 'Foreign key. Identifies the charted item.';
COMMENT ON COLUMN labevents.row_id IS 'Unique row identifier.';
COMMENT ON COLUMN labevents.subject_id IS 'Foreign key. Identifies the patient.';
COMMENT ON COLUMN labevents.value IS 'Value of the event as a text string.';
COMMENT ON COLUMN labevents.valuenum IS 'Value of the event as a number.';
COMMENT ON COLUMN labevents.valueuom IS 'Unit of measurement.';

CREATE TABLE microbiologyevents (
    ab_itemid INT,
    ab_name VARCHAR(30),
    chartdate TIMESTAMP(0),
    charttime TIMESTAMP(0),
    dilution_comparison VARCHAR(20),
    dilution_text VARCHAR(10),
    dilution_value DOUBLE,
    hadm_id INT,
    interpretation VARCHAR(5),
    isolate_num SMALLINT,
    org_itemid INT,
    org_name VARCHAR(100),
    row_id INT,
    spec_itemid INT,
    spec_type_desc VARCHAR(100),
    subject_id INT
);

COMMENT ON TABLE microbiologyevents IS 'Events relating to microbiology tests.';';
COMMENT ON COLUMN microbiologyevents.ab_itemid IS 'Foreign key. Identifies the antibody.';
COMMENT ON COLUMN microbiologyevents.ab_name IS 'Name of the antibody used.';
COMMENT ON COLUMN microbiologyevents.chartdate IS 'Date when the event occured.';
COMMENT ON COLUMN microbiologyevents.charttime IS 'Time when the event occured, if available.';
COMMENT ON COLUMN microbiologyevents.dilution_comparison IS 'The comparison component of DILUTION_TEXT: either <= (less than or equal), = (equal), or >= (greater than or equal), or null when not available.';
COMMENT ON COLUMN microbiologyevents.dilution_text IS 'The dilution amount tested for and the comparison which was made against it (e.g. <=4).';
COMMENT ON COLUMN microbiologyevents.dilution_value IS 'The value component of DILUTION_TEXT: must be a floating point number.';
COMMENT ON COLUMN microbiologyevents.hadm_id IS 'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN microbiologyevents.interpretation IS 'Interpretation of the test.';
COMMENT ON COLUMN microbiologyevents.isolate_num IS 'Isolate number associated with the test.';
COMMENT ON COLUMN microbiologyevents.org_itemid IS 'Foreign key. Identifies the organism.';
COMMENT ON COLUMN microbiologyevents.org_name IS 'Name of the organism.';
COMMENT ON COLUMN microbiologyevents.row_id IS 'Unique row identifier.';
COMMENT ON COLUMN microbiologyevents.spec_itemid IS 'Foreign key. Identifies the specimen.';
COMMENT ON COLUMN microbiologyevents.spec_type_desc IS 'Description of the specimen.';
COMMENT ON COLUMN microbiologyevents.subject_id IS 'Foreign key. Identifies the patient.';

CREATE TABLE noteevents (
    category VARCHAR(50),
    cgid INT,
    chartdate TIMESTAMP(0),
    charttime TIMESTAMP(0),
    description VARCHAR(255),
    hadm_id INT,
    iserror CHAR(1),
    row_id INT,
    storetime TIMESTAMP(0),
    subject_id INT,
    text TEXT
);

COMMENT ON TABLE noteevents IS 'Notes associated with hospital stays.';';
COMMENT ON COLUMN noteevents.category IS 'Category of the note, e.g. Discharge summary.';
COMMENT ON COLUMN noteevents.cgid IS 'Foreign key. Identifies the caregiver.';
COMMENT ON COLUMN noteevents.chartdate IS 'Date when the note was charted.';
COMMENT ON COLUMN noteevents.charttime IS 'Date and time when the note was charted. Note that some notes (e.g. discharge summaries) do not have a time associated with them: these notes have NULL in this column.';
COMMENT ON COLUMN noteevents.description IS 'A more detailed categorization for the note, sometimes entered by free-text.';
COMMENT ON COLUMN noteevents.hadm_id IS 'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN noteevents.iserror IS 'Flag to highlight an error with the note.';
COMMENT ON COLUMN noteevents.row_id IS 'Unique row identifier.';
COMMENT ON COLUMN noteevents.storetime IS 'records the date and time at which a note was saved into the system. Notes with a CATEGORY value of ‘Discharge Summary’, ‘ECG’, ‘Radiology’, and ‘Echo’ never have a STORETIME. All other notes have a STORETIME.';
COMMENT ON COLUMN noteevents.subject_id IS 'Foreign key. Identifies the patient.';
COMMENT ON COLUMN noteevents.text IS 'Content of the note.';

CREATE TABLE outputevents (
    cgid INT,
    charttime TIMESTAMP(0),
    hadm_id INT,
    icustay_id INT,
    iserror INT,
    itemid INT,
    newbottle CHAR(1),
    row_id INT,
    stopped VARCHAR(30),
    storetime TIMESTAMP(0),
    subject_id INT,
    value DOUBLE,
    valueuom VARCHAR(30)
);

COMMENT ON TABLE outputevents IS 'Output data for patients.';';
COMMENT ON COLUMN outputevents.cgid IS 'Identifier for the caregiver who validated the given measurement.';
COMMENT ON COLUMN outputevents.charttime IS 'The time of an output event.';
COMMENT ON COLUMN outputevents.hadm_id IS 'Identifier which is unique to a patient hospital stay.';
COMMENT ON COLUMN outputevents.icustay_id IS 'Identifier which is unique to a patient ICU stay.';
COMMENT ON COLUMN outputevents.iserror IS 'A Metavision checkbox where a caregiver can specify that an observation is an error. No other details are provided.';
COMMENT ON COLUMN outputevents.itemid IS 'Identifier for a single measurement type in the database. Each row associated with one ITEMID (e.g. 212) corresponds to an instantiation of the same measurement (e.g. heart rate). Metavision ITEMID values are all above 220000. A subset of commonly used medications in CareVue data have ITEMID values between 30000-39999. The remaining input/output ITEMID values are between 40000-49999.';
COMMENT ON COLUMN outputevents.newbottle IS 'Indicates that a new bag of solution was hung at the given CHARTTIME.';
COMMENT ON COLUMN outputevents.row_id IS 'Unique identifier for the row.';
COMMENT ON COLUMN outputevents.stopped IS 'Indicates if the order was disconnected at the given CHARTTIME.';
COMMENT ON COLUMN outputevents.storetime IS 'Records the time at which an observation was manually input or manually validated by a member of the clinical staff.';
COMMENT ON COLUMN outputevents.subject_id IS 'Identifier which is unique to a patient.';
COMMENT ON COLUMN outputevents.value IS 'Lists the amount of a substance at the CHARTTIME (when the exact start time is unknown, but usually up to an hour before).';
COMMENT ON COLUMN outputevents.valueuom IS 'Lists the unit of measure for the VALUE at the CHARTTIME (when the exact start time is unknown, but usually up to an hour before).';

CREATE TABLE patients (
    dob TIMESTAMP(0),
    dod TIMESTAMP(0),
    dod_hosp TIMESTAMP(0),
    dod_ssn TIMESTAMP(0),
    expire_flag INT,
    gender VARCHAR(5),
    row_id INT,
    subject_id INT
);

COMMENT ON TABLE patients IS 'Patients associated with an admission to the ICU.';';
COMMENT ON COLUMN patients.dob IS 'Date of birth.';
COMMENT ON COLUMN patients.dod IS 'Date of death. Null if the patient was alive at least 90 days post hospital discharge.';
COMMENT ON COLUMN patients.dod_hosp IS 'Date of death recorded in the hospital records.';
COMMENT ON COLUMN patients.dod_ssn IS 'Date of death recorded in the social security records.';
COMMENT ON COLUMN patients.expire_flag IS 'Flag indicating that the patient has died.';
COMMENT ON COLUMN patients.gender IS 'Gender.';
COMMENT ON COLUMN patients.row_id IS 'Unique row identifier.';
COMMENT ON COLUMN patients.subject_id IS 'Primary key. Identifies the patient.';

CREATE TABLE prescriptions (
    dose_unit_rx VARCHAR(120),
    dose_val_rx VARCHAR(120),
    drug VARCHAR(100),
    drug_name_generic VARCHAR(100),
    drug_name_poe VARCHAR(100),
    drug_type VARCHAR(100),
    enddate TIMESTAMP(0),
    form_unit_disp VARCHAR(120),
    form_val_disp VARCHAR(120),
    formulary_drug_cd VARCHAR(120),
    gsn VARCHAR(200),
    hadm_id INT,
    icustay_id INT,
    ndc VARCHAR(120),
    prod_strength VARCHAR(120),
    route VARCHAR(120),
    row_id INT,
    startdate TIMESTAMP(0),
    subject_id INT
);

COMMENT ON TABLE prescriptions IS 'Medicines prescribed.';';
COMMENT ON COLUMN prescriptions.dose_unit_rx IS 'Unit of measurement associated with the dose.';
COMMENT ON COLUMN prescriptions.dose_val_rx IS 'Dose of the drug prescribed.';
COMMENT ON COLUMN prescriptions.drug IS 'Name of the drug.';
COMMENT ON COLUMN prescriptions.drug_name_generic IS 'Generic drug name.';
COMMENT ON COLUMN prescriptions.drug_name_poe IS 'Name of the drug on the Provider Order Entry interface.';
COMMENT ON COLUMN prescriptions.drug_type IS 'Type of drug.';
COMMENT ON COLUMN prescriptions.enddate IS 'Date when the prescription ended.';
COMMENT ON COLUMN prescriptions.form_unit_disp IS 'Unit of measurement associated with the formulation.';
COMMENT ON COLUMN prescriptions.form_val_disp IS 'Amount of the formulation dispensed.';
COMMENT ON COLUMN prescriptions.formulary_drug_cd IS 'Formulary drug code.';
COMMENT ON COLUMN prescriptions.gsn IS 'Generic Sequence Number.';
COMMENT ON COLUMN prescriptions.hadm_id IS 'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN prescriptions.icustay_id IS 'Foreign key. Identifies the ICU stay.';
COMMENT ON COLUMN prescriptions.ndc IS 'National Drug Code.';
COMMENT ON COLUMN prescriptions.prod_strength IS 'Strength of the drug (product).';
COMMENT ON COLUMN prescriptions.route IS 'Route of administration, for example intravenous or oral.';
COMMENT ON COLUMN prescriptions.row_id IS 'Unique row identifier.';
COMMENT ON COLUMN prescriptions.startdate IS 'Date when the prescription started.';
COMMENT ON COLUMN prescriptions.subject_id IS 'Foreign key. Identifies the patient.';

CREATE TABLE procedureevents_mv (
    cancelreason SMALLINT,
    cgid INT,
    comments_canceledby VARCHAR(30),
    comments_date TIMESTAMP(0),
    comments_editedby VARCHAR(30),
    continueinnextdept SMALLINT,
    endtime TIMESTAMP(0),
    hadm_id INT,
    icustay_id INT,
    isopenbag SMALLINT,
    itemid INT,
    linkorderid INT,
    location VARCHAR(30),
    locationcategory VARCHAR(30),
    ordercategorydescription VARCHAR(50),
    ordercategoryname VARCHAR(100),
    orderid INT,
    row_id INT,
    secondaryordercategoryname VARCHAR(100),
    starttime TIMESTAMP(0),
    statusdescription VARCHAR(30),
    storetime TIMESTAMP(0),
    subject_id INT,
    value DOUBLE,
    valueuom VARCHAR(30)
);

COMMENT ON TABLE procedureevents_mv IS 'Contains procedures for patients.';';
COMMENT ON COLUMN procedureevents_mv.cancelreason IS 'Reason for canceling the procedure.';
COMMENT ON COLUMN procedureevents_mv.cgid IS 'Identifier for each caregiver. The identification number of the provider associated with the procedure record, for example, the provider who performed the procedure.';
COMMENT ON COLUMN procedureevents_mv.comments_canceledby IS 'Identifier of the person who canceled the comments.';
COMMENT ON COLUMN procedureevents_mv.comments_date IS 'Date when the comments were made.';
COMMENT ON COLUMN procedureevents_mv.comments_editedby IS 'Identifier of the person who edited the comments.';
COMMENT ON COLUMN procedureevents_mv.continueinnextdept IS 'Indicates if the procedure will continue in the next department.';
COMMENT ON COLUMN procedureevents_mv.endtime IS 'The time the procedure ended.';
COMMENT ON COLUMN procedureevents_mv.hadm_id IS 'Identifier for each hospital admission. The unique identifier for the visit during which the procedure took place.';
COMMENT ON COLUMN procedureevents_mv.icustay_id IS 'Identifier for each intensive care unit stay. The identifier for the detailed visit record during which the Procedure took place, such as the Intensive Care Unit stay during the hospital visit.';
COMMENT ON COLUMN procedureevents_mv.isopenbag IS 'Indicates whether the bag is open.';
COMMENT ON COLUMN procedureevents_mv.itemid IS 'Identifier for each item in the procedure. This field houses the unique concept identifier for the procedure. This is used primarily for analyses and network studies.';
COMMENT ON COLUMN procedureevents_mv.linkorderid IS 'Identifier for the linked order associated with the procedure.';
COMMENT ON COLUMN procedureevents_mv.location IS 'Location where the procedure was performed.';
COMMENT ON COLUMN procedureevents_mv.locationcategory IS 'Category of the location where the procedure was performed.';
COMMENT ON COLUMN procedureevents_mv.ordercategorydescription IS 'Description of the order category.';
COMMENT ON COLUMN procedureevents_mv.ordercategoryname IS 'The name of the order category.';
COMMENT ON COLUMN procedureevents_mv.orderid IS 'Identifier for the order associated with the procedure.';
COMMENT ON COLUMN procedureevents_mv.row_id IS 'Unique identifier for the row.';
COMMENT ON COLUMN procedureevents_mv.secondaryordercategoryname IS 'The name of the secondary order category.';
COMMENT ON COLUMN procedureevents_mv.starttime IS 'The time the procedure started. The exact time when the procedure happened.';
COMMENT ON COLUMN procedureevents_mv.statusdescription IS 'Description of the status of the procedure.';
COMMENT ON COLUMN procedureevents_mv.storetime IS 'Records the time at which an observation was manually input or manually validated by a member of the clinical staff.';
COMMENT ON COLUMN procedureevents_mv.subject_id IS 'Identifier for each patient. The unique identifier of the patient for whom the procedure is recorded. This may be a system generated code.';
COMMENT ON COLUMN procedureevents_mv.value IS 'Value of the item in the procedure. The original value from the source data that represents the actual procedure performed.';
COMMENT ON COLUMN procedureevents_mv.valueuom IS 'Unit of measure for the value of the item in the procedure.';

CREATE TABLE procedures_icd (
    hadm_id INT,
    icd9_code VARCHAR(10),
    row_id INT,
    seq_num INT,
    subject_id INT
);

COMMENT ON TABLE procedures_icd IS 'Procedures relating to a hospital admission coded using the ICD9 system.';';
COMMENT ON COLUMN procedures_icd.hadm_id IS 'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN procedures_icd.icd9_code IS 'ICD9 code associated with the procedure.';
COMMENT ON COLUMN procedures_icd.row_id IS 'Unique row identifier.';
COMMENT ON COLUMN procedures_icd.seq_num IS 'Lower procedure numbers occurred earlier.';
COMMENT ON COLUMN procedures_icd.subject_id IS 'Foreign key. Identifies the patient.';

CREATE TABLE services (
    curr_service VARCHAR(20),
    hadm_id INT,
    prev_service VARCHAR(20),
    row_id INT,
    subject_id INT,
    transfertime TIMESTAMP(0)
);

COMMENT ON TABLE services IS 'Hospital services that patients were under during their hospital stay.';';
COMMENT ON COLUMN services.curr_service IS 'Current service type.';
COMMENT ON COLUMN services.hadm_id IS 'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN services.prev_service IS 'Previous service type.';
COMMENT ON COLUMN services.row_id IS 'Unique row identifier.';
COMMENT ON COLUMN services.subject_id IS 'Foreign key. Identifies the patient.';
COMMENT ON COLUMN services.transfertime IS 'Time when the transfer occured.';

CREATE TABLE transfers (
    curr_careunit VARCHAR(20),
    curr_wardid SMALLINT,
    dbsource VARCHAR(20),
    eventtype VARCHAR(20),
    hadm_id INT,
    icustay_id INT,
    intime TIMESTAMP(0),
    los DOUBLE,
    outtime TIMESTAMP(0),
    prev_careunit VARCHAR(20),
    prev_wardid SMALLINT,
    row_id INT,
    subject_id INT
);

COMMENT ON TABLE transfers IS 'Location of patients during their hospital stay.';';
COMMENT ON COLUMN transfers.curr_careunit IS 'Current careunit.';
COMMENT ON COLUMN transfers.curr_wardid IS 'Identifier for the current ward the patient is located in.';
COMMENT ON COLUMN transfers.dbsource IS 'Source database of the item.';
COMMENT ON COLUMN transfers.eventtype IS 'Type of event, for example admission or transfer.';
COMMENT ON COLUMN transfers.hadm_id IS 'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN transfers.icustay_id IS 'Foreign key. Identifies the ICU stay.';
COMMENT ON COLUMN transfers.intime IS 'Time when the patient was transferred into the unit.';
COMMENT ON COLUMN transfers.los IS 'Length of stay in the unit in minutes.';
COMMENT ON COLUMN transfers.outtime IS 'Time when the patient was transferred out of the unit.';
COMMENT ON COLUMN transfers.prev_careunit IS 'Previous careunit.';
COMMENT ON COLUMN transfers.prev_wardid IS 'Identifier for the previous ward the patient was located in.';
COMMENT ON COLUMN transfers.row_id IS 'Unique row identifier.';
COMMENT ON COLUMN transfers.subject_id IS 'Foreign key. Identifies the patient.';