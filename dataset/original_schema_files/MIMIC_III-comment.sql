
-- If running scripts individually, you can set the schema where all tables are created as follows:
-- SET search_path TO mimiciii;

--------------
--ADMISSIONS--
--------------

-- Table
COMMENT ON TABLE ADMISSIONS IS 'The ADMISSIONS table gives information regarding a patient’s admission to the hospital. Since each unique hospital visit for a patient is assigned a unique HADM_ID, the ADMISSIONS table can be considered as a definition table for HADM_ID. Information available includes timing information for admission and discharge, demographic information, the source of the admission, and so on.';

-- Columns
COMMENT ON COLUMN ADMISSIONS.ROW_ID IS 'Unique identifier for the row.';
COMMENT ON COLUMN ADMISSIONS.SUBJECT_ID IS 'Unique identifier for the patient. Can be linked to the PATIENTS table using this identifier.';
COMMENT ON COLUMN ADMISSIONS.HADM_ID IS 'Unique identifier for a single patient’s admission to the hospital. Ranges from 1000000 - 1999999.';
COMMENT ON COLUMN ADMISSIONS.ADMITTIME IS 'Date and time the patient was admitted to the hospital.';
COMMENT ON COLUMN ADMISSIONS.DISCHTIME IS 'Date and time the patient was discharged from the hospital.';
COMMENT ON COLUMN ADMISSIONS.DEATHTIME IS 'Time of in-hospital death for the patient, if applicable. Usually the same as DISCHTIME, but discrepancies can occur due to typographical errors.';
COMMENT ON COLUMN ADMISSIONS.ADMISSION_TYPE IS 'Describes the type of the admission: ELECTIVE, URGENT, NEWBORN, or EMERGENCY.';
COMMENT ON COLUMN ADMISSIONS.ADMISSION_LOCATION IS 'Previous location of the patient prior to arriving at the hospital. There are 9 possible values: EMERGENCY ROOM ADMIT, TRANSFER FROM HOSP/EXTRAM, TRANSFER FROM OTHER HEALT, CLINIC REFERRAL/PREMATURE, ** INFO NOT AVAILABLE **, TRANSFER FROM SKILLED NUR, TRSF WITHIN THIS FACILITY, HMO REFERRAL/SICK, PHYS REFERRAL/NORMAL DELI.';
COMMENT ON COLUMN ADMISSIONS.INSURANCE IS 'Describes the patient\'s insurance information. Sourced from the admission, discharge, and transfers (ADT) data from the hospital database.';
COMMENT ON COLUMN ADMISSIONS.LANGUAGE IS 'Language spoken by the patient. Sourced from the admission, discharge, and transfers (ADT) data from the hospital database.';
COMMENT ON COLUMN ADMISSIONS.RELIGION IS 'Religion of the patient. Sourced from the admission, discharge, and transfers (ADT) data from the hospital database.';
COMMENT ON COLUMN ADMISSIONS.MARITAL_STATUS IS 'Marital status of the patient. Sourced from the admission, discharge, and transfers (ADT) data from the hospital database.';
COMMENT ON COLUMN ADMISSIONS.ETHNICITY IS 'Ethnicity of the patient. Sourced from the admission, discharge, and transfers (ADT) data from the hospital database.';
COMMENT ON COLUMN ADMISSIONS.EDREGTIME IS 'Time that the patient was registered in the emergency department.';
COMMENT ON COLUMN ADMISSIONS.EDOUTTIME IS 'Time that the patient was discharged from the emergency department.';
COMMENT ON COLUMN ADMISSIONS.DIAGNOSIS IS 'Preliminary, free text diagnosis for the patient on hospital admission. Assigned by the admitting clinician.';
COMMENT ON COLUMN ADMISSIONS.HOSPITAL_EXPIRE_FLAG IS 'Indicates whether the patient died within the given hospitalization. 1 indicates death in the hospital, 0 indicates survival to hospital discharge.';
COMMENT ON COLUMN ADMISSIONS.HAS_CHARTEVENTS_DATA IS 'Indicates whether chart events data is available for this admission.';

-----------
--CALLOUT--
-----------

-- Table
COMMENT ON TABLE CALLOUT IS
  'Record of when patients were ready for discharge (called out), and the actual time of their discharge (or more generally, their outcome).';

-- Columns
COMMENT ON COLUMN CALLOUT.ROW_ID is
   'Unique row identifier.';
COMMENT ON COLUMN CALLOUT.SUBJECT_ID is
   'Foreign key. Identifies the patient.';
COMMENT ON COLUMN CALLOUT.HADM_ID is
   'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN CALLOUT.SUBMIT_WARDID is
   'Identifies the ward where the call out request was submitted.';
COMMENT ON COLUMN CALLOUT.SUBMIT_CAREUNIT is
   'If the ward where the call was submitted was an ICU, the ICU type is listed here.';
COMMENT ON COLUMN CALLOUT.CURR_WARDID is
   'Identifies the ward where the patient is currently residing.';
COMMENT ON COLUMN CALLOUT.CURR_CAREUNIT is
   'If the ward where the patient is currently residing is an ICU, the ICU type is listed here.';
COMMENT ON COLUMN CALLOUT.CALLOUT_WARDID is
   'Identifies the ward where the patient is to be discharged to. A value of 1 indicates the first available ward. A value of 0 indicates home.';
COMMENT ON COLUMN CALLOUT.CALLOUT_SERVICE is
   'Identifies the service that the patient is called out to.';
COMMENT ON COLUMN CALLOUT.REQUEST_TELE is
   'Indicates if special precautions are required.';
COMMENT ON COLUMN CALLOUT.REQUEST_RESP is
   'Indicates if special precautions are required.';
COMMENT ON COLUMN CALLOUT.REQUEST_CDIFF is
   'Indicates if special precautions are required.';
COMMENT ON COLUMN CALLOUT.REQUEST_MRSA is
   'Indicates if special precautions are required.';
COMMENT ON COLUMN CALLOUT.REQUEST_VRE is
   'Indicates if special precautions are required.';
COMMENT ON COLUMN CALLOUT.CALLOUT_STATUS is
   'Current status of the call out request.';
COMMENT ON COLUMN CALLOUT.CALLOUT_OUTCOME is
   'The result of the call out request; either a cancellation or a discharge.';
COMMENT ON COLUMN CALLOUT.DISCHARGE_WARDID is
   'The ward to which the patient was discharged.';
COMMENT ON COLUMN CALLOUT.ACKNOWLEDGE_STATUS is
   'The status of the response to the call out request.';
COMMENT ON COLUMN CALLOUT.CREATETIME is
   'Time at which the call out request was created.';
COMMENT ON COLUMN CALLOUT.UPDATETIME is
   'Last time at which the call out request was updated.';
COMMENT ON COLUMN CALLOUT.ACKNOWLEDGETIME is
   'Time at which the call out request was acknowledged.';
COMMENT ON COLUMN CALLOUT.OUTCOMETIME is
   'Time at which the outcome (cancelled or discharged) occurred.';
COMMENT ON COLUMN CALLOUT.FIRSTRESERVATIONTIME is
   'First time at which a ward was reserved for the call out request.';
COMMENT ON COLUMN CALLOUT.CURRENTRESERVATIONTIME is
   'Latest time at which a ward was reserved for the call out request.';

--------------
--CAREGIVERS--
--------------

-- Table
COMMENT ON TABLE CAREGIVERS IS
   'List of caregivers associated with an ICU stay.';

-- Columns
COMMENT ON COLUMN CAREGIVERS.ROW_ID is
   'Unique row identifier.';
COMMENT ON COLUMN CAREGIVERS.CGID is
   'Unique caregiver identifier.';
COMMENT ON COLUMN CAREGIVERS.LABEL is
   'Title of the caregiver, for example MD or RN.';
COMMENT ON COLUMN CAREGIVERS.DESCRIPTION is
   'More detailed description of the caregiver, if available.';

---------------
--CHARTEVENTS--
---------------

-- Table
COMMENT ON TABLE CHARTEVENTS IS
   'Events occuring on a patient chart.';

-- Columns
COMMENT ON COLUMN CHARTEVENTS.ROW_ID is
   'Unique row identifier.';
COMMENT ON COLUMN CHARTEVENTS.SUBJECT_ID is
   'Foreign key. Identifies the patient.';
COMMENT ON COLUMN CHARTEVENTS.HADM_ID is
   'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN CHARTEVENTS.ICUSTAY_ID is
   'Foreign key. Identifies the ICU stay.';
COMMENT ON COLUMN CHARTEVENTS.ITEMID is
   'Foreign key. Identifies the charted item.';
COMMENT ON COLUMN CHARTEVENTS.CHARTTIME is
   'Time when the event occured.';
COMMENT ON COLUMN CHARTEVENTS.STORETIME is
   'Time when the event was recorded in the system.';
COMMENT ON COLUMN CHARTEVENTS.CGID is
   'Foreign key. Identifies the caregiver.';
COMMENT ON COLUMN CHARTEVENTS.VALUE is
   'Value of the event as a text string.';
COMMENT ON COLUMN CHARTEVENTS.VALUENUM is
   'Value of the event as a number.';
COMMENT ON COLUMN CHARTEVENTS.VALUEUOM is
   'Unit of measurement.';
COMMENT ON COLUMN CHARTEVENTS.WARNING is
   'Flag to highlight that the value has triggered a warning.';
COMMENT ON COLUMN CHARTEVENTS.ERROR is
   'Flag to highlight an error with the event.';
COMMENT ON COLUMN CHARTEVENTS.RESULTSTATUS is
   'Result status of lab data.';
COMMENT ON COLUMN CHARTEVENTS.STOPPED is
   'Text string indicating the stopped status of an event (i.e. stopped, not stopped).';

-------------
--CPTEVENTS--
-------------

-- Table
COMMENT ON TABLE CPTEVENTS IS
   'Events recorded in Current Procedural Terminology.';

-- Columns
COMMENT ON COLUMN CPTEVENTS.ROW_ID is
   'Unique row identifier.';
COMMENT ON COLUMN CPTEVENTS.SUBJECT_ID is
   'Foreign key. Identifies the patient.';
COMMENT ON COLUMN CPTEVENTS.HADM_ID is
   'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN CPTEVENTS.COSTCENTER is
   'Center recording the code, for example the ICU or the respiratory unit.';
COMMENT ON COLUMN CPTEVENTS.CHARTDATE is
   'Date when the event occured, if available.';
COMMENT ON COLUMN CPTEVENTS.CPT_CD is
   'Current Procedural Terminology code.';
COMMENT ON COLUMN CPTEVENTS.CPT_NUMBER is
   'Numerical element of the Current Procedural Terminology code.';
COMMENT ON COLUMN CPTEVENTS.CPT_SUFFIX is
   'Text element of the Current Procedural Terminology, if any. Indicates code category.';
COMMENT ON COLUMN CPTEVENTS.TICKET_ID_SEQ is
   'Sequence number of the event, derived from the ticket ID.';
COMMENT ON COLUMN CPTEVENTS.SECTIONHEADER is
   'High-level section of the Current Procedural Terminology code.';
COMMENT ON COLUMN CPTEVENTS.SUBSECTIONHEADER is
   'Subsection of the Current Procedural Terminology code.';
COMMENT ON COLUMN CPTEVENTS.DESCRIPTION is
   'Description of the Current Procedural Terminology, if available.';

----------
--D_CPT---
----------

-- Table
COMMENT ON TABLE D_CPT IS
   'High-level dictionary of the Current Procedural Terminology.';

-- Columns
COMMENT ON COLUMN D_CPT.ROW_ID is
   'Unique row identifier.';
COMMENT ON COLUMN D_CPT.CATEGORY is
   'Code category.';
COMMENT ON COLUMN D_CPT.SECTIONRANGE is
   'Range of codes within the high-level section.';
COMMENT ON COLUMN D_CPT.SECTIONHEADER is
   'Section header.';
COMMENT ON COLUMN D_CPT.SUBSECTIONRANGE is
   'Range of codes within the subsection.';
COMMENT ON COLUMN D_CPT.SUBSECTIONHEADER is
   'Subsection header.';
COMMENT ON COLUMN D_CPT.CODESUFFIX is
   'Text element of the Current Procedural Terminology, if any.';
COMMENT ON COLUMN D_CPT.MINCODEINSUBSECTION is
   'Minimum code within the subsection.';
COMMENT ON COLUMN D_CPT.MAXCODEINSUBSECTION is
   'Maximum code within the subsection.';

----------
--D_ICD_DIAGNOSES--
----------

-- Table
COMMENT ON TABLE D_ICD_DIAGNOSES IS
   'Dictionary of the International Classification of Diseases, 9th Revision (Diagnoses).';

-- Columns
COMMENT ON COLUMN D_ICD_DIAGNOSES.ROW_ID is
   'Unique row identifier.';
COMMENT ON COLUMN D_ICD_DIAGNOSES.ICD9_CODE is
   'ICD9 code - note that this is a fixed length character field, as whitespaces are important in uniquely identifying ICD-9 codes.';
COMMENT ON COLUMN D_ICD_DIAGNOSES.SHORT_TITLE is
   'Short title associated with the code.';
COMMENT ON COLUMN D_ICD_DIAGNOSES.LONG_TITLE is
   'Long title associated with the code.';

----------
--D_ICD_PROCEDURES--
----------

-- Table
COMMENT ON TABLE D_ICD_PROCEDURES  IS
   'Dictionary of the International Classification of Diseases, 9th Revision (Procedures).';

-- Columns
COMMENT ON COLUMN D_ICD_PROCEDURES.ROW_ID is
   'Unique row identifier.';
COMMENT ON COLUMN D_ICD_PROCEDURES.ICD9_CODE is
   'ICD9 code - note that this is a fixed length character field, as whitespaces are important in uniquely identifying ICD-9 codes.';
COMMENT ON COLUMN D_ICD_PROCEDURES.SHORT_TITLE is
   'Short title associated with the code.';
COMMENT ON COLUMN D_ICD_PROCEDURES.LONG_TITLE is
   'Long title associated with the code.';

-----------
--D_ITEMS--
-----------

-- Table
COMMENT ON TABLE D_ITEMS IS
   'Dictionary of non-laboratory-related charted items.';

-- Columns
COMMENT ON COLUMN D_ITEMS.ROW_ID is
   'Unique row identifier.';
COMMENT ON COLUMN D_ITEMS.ITEMID is
   'Primary key. Identifies the charted item.';
COMMENT ON COLUMN D_ITEMS.LABEL is
   'Label identifying the item.';
COMMENT ON COLUMN D_ITEMS.ABBREVIATION is
   'Abbreviation associated with the item.';
COMMENT ON COLUMN D_ITEMS.DBSOURCE is
   'Source database of the item.';
COMMENT ON COLUMN D_ITEMS.LINKSTO is
   'Table which contains data for the given ITEMID.';
COMMENT ON COLUMN D_ITEMS.CATEGORY is
   'Category of data which the concept falls under.';
COMMENT ON COLUMN D_ITEMS.UNITNAME is
   'Unit associated with the item.';
COMMENT ON COLUMN D_ITEMS.PARAM_TYPE is
   'Type of item, for example solution or ingredient.';
COMMENT ON COLUMN D_ITEMS.CONCEPTID is
   'Identifier used to harmonize concepts identified by multiple ITEMIDs. CONCEPTIDs are planned but not yet implemented (all values are NULL).';

---------------
--D_LABITEMS--
---------------

-- Table
COMMENT ON TABLE D_LABITEMS  IS
   'Dictionary of laboratory-related items.';

-- Columns
COMMENT ON COLUMN D_LABITEMS.ROW_ID is
   'Unique row identifier.';
COMMENT ON COLUMN D_LABITEMS.ITEMID is
   'Foreign key. Identifies the charted item.';
COMMENT ON COLUMN D_LABITEMS.LABEL is
   'Label identifying the item.';
COMMENT ON COLUMN D_LABITEMS.FLUID is
   'Fluid associated with the item, for example blood or urine.';
COMMENT ON COLUMN D_LABITEMS.CATEGORY is
   'Category of item, for example chemistry or hematology.';
COMMENT ON COLUMN D_LABITEMS.LOINC_CODE is
   'Logical Observation Identifiers Names and Codes (LOINC) mapped to the item, if available.';

------------------
--DATETIMEEVENTS--
------------------

-- Table
COMMENT ON TABLE DATETIMEEVENTS IS
   'Events relating to a datetime.';

-- Columns
COMMENT ON COLUMN DATETIMEEVENTS.ROW_ID is
   'Unique row identifier.';
COMMENT ON COLUMN DATETIMEEVENTS.SUBJECT_ID is
   'Foreign key. Identifies the patient.';
COMMENT ON COLUMN DATETIMEEVENTS.HADM_ID is
   'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN DATETIMEEVENTS.ICUSTAY_ID is
   'Foreign key. Identifies the ICU stay.';
COMMENT ON COLUMN DATETIMEEVENTS.ITEMID is
   'Foreign key. Identifies the charted item.';
COMMENT ON COLUMN DATETIMEEVENTS.CHARTTIME is
   'Time when the event occured.';
COMMENT ON COLUMN DATETIMEEVENTS.STORETIME is
   'Time when the event was recorded in the system.';
COMMENT ON COLUMN DATETIMEEVENTS.CGID is
   'Foreign key. Identifies the caregiver.';
COMMENT ON COLUMN DATETIMEEVENTS.VALUE is
   'Value of the event as a text string.';
COMMENT ON COLUMN DATETIMEEVENTS.VALUEUOM is
   'Unit of measurement.';
COMMENT ON COLUMN DATETIMEEVENTS.WARNING is
   'Flag to highlight that the value has triggered a warning.';
COMMENT ON COLUMN DATETIMEEVENTS.ERROR is
   'Flag to highlight an error with the event.';
COMMENT ON COLUMN DATETIMEEVENTS.RESULTSTATUS is
   'Result status of lab data.';
COMMENT ON COLUMN DATETIMEEVENTS.STOPPED is
   'Event was explicitly marked as stopped. Infrequently used by caregivers.';

-----------------
--DIAGNOSES_ICD--
-----------------

-- Table
COMMENT ON TABLE DIAGNOSES_ICD IS
   'Diagnoses relating to a hospital admission coded using the ICD9 system.';

-- Columns
COMMENT ON COLUMN DIAGNOSES_ICD.ROW_ID is
   'Unique row identifier.';
COMMENT ON COLUMN DIAGNOSES_ICD.SUBJECT_ID is
   'Foreign key. Identifies the patient.';
COMMENT ON COLUMN DIAGNOSES_ICD.HADM_ID is
   'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN DIAGNOSES_ICD.SEQ_NUM is
   'Priority of the code. Sequence 1 is the primary code.';
COMMENT ON COLUMN DIAGNOSES_ICD.ICD9_CODE is
   'ICD9 code for the diagnosis.';

--------------
---DRGCODES---
--------------

-- Table
COMMENT ON TABLE DRGCODES IS
   'Hospital stays classified using the Diagnosis-Related Group system.';

-- Columns
COMMENT ON COLUMN DRGCODES.ROW_ID is
   'Unique row identifier.';
COMMENT ON COLUMN DRGCODES.SUBJECT_ID is
   'Foreign key. Identifies the patient.';
COMMENT ON COLUMN DRGCODES.HADM_ID is
   'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN DRGCODES.DRG_TYPE is
   'Type of Diagnosis-Related Group, for example APR is All Patient Refined';
COMMENT ON COLUMN DRGCODES.DRG_CODE is
   'Diagnosis-Related Group code';
COMMENT ON COLUMN DRGCODES.DESCRIPTION is
   'Description of the Diagnosis-Related Group';
COMMENT ON COLUMN DRGCODES.DRG_SEVERITY is
   'Relative severity, available for type APR only.';
COMMENT ON COLUMN DRGCODES.DRG_MORTALITY is
   'Relative mortality, available for type APR only.';

-----------------
--ICUSTAYS--
-----------------

-- Table
COMMENT ON TABLE ICUSTAYS IS
   'List of ICU admissions.';

-- Columns
COMMENT ON COLUMN ICUSTAYS.ROW_ID is
   'Unique row identifier.';
COMMENT ON COLUMN ICUSTAYS.SUBJECT_ID is
   'Foreign key. Identifies the patient.';
COMMENT ON COLUMN ICUSTAYS.HADM_ID is
   'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN ICUSTAYS.ICUSTAY_ID is
   'Primary key. Identifies the ICU stay.';
COMMENT ON COLUMN ICUSTAYS.DBSOURCE is
   'Source database of the item.';
COMMENT ON COLUMN ICUSTAYS.INTIME is
   'Time of admission to the ICU.';
COMMENT ON COLUMN ICUSTAYS.OUTTIME is
   'Time of discharge from the ICU.';
COMMENT ON COLUMN ICUSTAYS.LOS is
   'Length of stay in the ICU in minutes.';
COMMENT ON COLUMN ICUSTAYS.FIRST_CAREUNIT is
   'First careunit associated with the ICU stay.';
COMMENT ON COLUMN ICUSTAYS.LAST_CAREUNIT is
   'Last careunit associated with the ICU stay.';
COMMENT ON COLUMN ICUSTAYS.FIRST_WARDID is
   'Identifier for the first ward the patient was located in.';
COMMENT ON COLUMN ICUSTAYS.LAST_WARDID is
   'Identifier for the last ward the patient is located in.';

-- -------------- --
-- INPUTEVENTS_CV --
-- -------------- --

-- Table
COMMENT ON TABLE INPUTEVENTS_CV IS
   'Events relating to fluid input for patients whose data was originally stored in the CareVue database.';

-- Columns
COMMENT ON COLUMN INPUTEVENTS_CV.ROW_ID is
   'Unique row identifier.';
COMMENT ON COLUMN INPUTEVENTS_CV.SUBJECT_ID is
   'Foreign key. Identifies the patient.';
COMMENT ON COLUMN INPUTEVENTS_CV.HADM_ID is
   'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN INPUTEVENTS_CV.ICUSTAY_ID is
   'Foreign key. Identifies the ICU stay.';
COMMENT ON COLUMN INPUTEVENTS_CV.CHARTTIME is
   'Time of that the input was started or received.';
COMMENT ON COLUMN INPUTEVENTS_CV.ITEMID is
   'Foreign key. Identifies the charted item.';
COMMENT ON COLUMN INPUTEVENTS_CV.AMOUNT is
   'Amount of the item administered to the patient.';
COMMENT ON COLUMN INPUTEVENTS_CV.AMOUNTUOM is
   'Unit of measurement for the amount.';
COMMENT ON COLUMN INPUTEVENTS_CV.RATE is
   'Rate at which the item is being administered to the patient.';
COMMENT ON COLUMN INPUTEVENTS_CV.RATEUOM is
   'Unit of measurement for the rate.';
COMMENT ON COLUMN INPUTEVENTS_CV.STORETIME is
   'Time when the event was recorded in the system.';
COMMENT ON COLUMN INPUTEVENTS_CV.CGID is
   'Foreign key. Identifies the caregiver.';
COMMENT ON COLUMN INPUTEVENTS_CV.ORDERID is
   'Identifier linking items which are grouped in a solution.';
COMMENT ON COLUMN INPUTEVENTS_CV.LINKORDERID is
   'Identifier linking orders across multiple administrations. LINKORDERID is always equal to the first occuring ORDERID of the series.';
COMMENT ON COLUMN INPUTEVENTS_CV.STOPPED is
   'Event was explicitly marked as stopped. Infrequently used by caregivers.';
COMMENT ON COLUMN INPUTEVENTS_CV.NEWBOTTLE is
   'Indicates when a new bottle of the solution was hung at the bedside.';
COMMENT ON COLUMN INPUTEVENTS_CV.ORIGINALAMOUNT is
   'Amount of the item which was originally charted.';
COMMENT ON COLUMN INPUTEVENTS_CV.ORIGINALAMOUNTUOM is
   'Unit of measurement for the original amount.';
COMMENT ON COLUMN INPUTEVENTS_CV.ORIGINALROUTE is
   'Route of administration originally chosen for the item.';
COMMENT ON COLUMN INPUTEVENTS_CV.ORIGINALRATE is
   'Rate of administration originally chosen for the item.';
COMMENT ON COLUMN INPUTEVENTS_CV.ORIGINALRATEUOM is
   'Unit of measurement for the rate originally chosen.';
COMMENT ON COLUMN INPUTEVENTS_CV.ORIGINALSITE is
   'Anatomical site for the original administration of the item.';

----------------- --
-- INPUTEVENTS_MV --
----------------- --

-- Table
COMMENT ON TABLE INPUTEVENTS_MV IS
   'Events relating to fluid input for patients whose data was originally stored in the MetaVision database.';

-- Columns
COMMENT ON COLUMN INPUTEVENTS_MV.ROW_ID is
  'Unique row identifier.';
COMMENT ON COLUMN INPUTEVENTS_MV.SUBJECT_ID is
  'Foreign key. Identifies the patient.';
COMMENT ON COLUMN INPUTEVENTS_MV.HADM_ID is
  'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN INPUTEVENTS_MV.ICUSTAY_ID is
  'Foreign key. Identifies the ICU stay.';
COMMENT ON COLUMN INPUTEVENTS_MV.STARTTIME is
  'Time when the event started.';
COMMENT ON COLUMN INPUTEVENTS_MV.ENDTIME is
  'Time when the event ended.';
COMMENT ON COLUMN INPUTEVENTS_MV.ITEMID is
  'Foreign key. Identifies the charted item.';
COMMENT ON COLUMN INPUTEVENTS_MV.AMOUNT is
  'Amount of the item administered to the patient.';
COMMENT ON COLUMN INPUTEVENTS_MV.AMOUNTUOM is
  'Unit of measurement for the amount.';
COMMENT ON COLUMN INPUTEVENTS_MV.RATE is
  'Rate at which the item is being administered to the patient.';
COMMENT ON COLUMN INPUTEVENTS_MV.RATEUOM is
  'Unit of measurement for the rate.';
COMMENT ON COLUMN INPUTEVENTS_MV.STORETIME is
  'Time when the event was recorded in the system.';
COMMENT ON COLUMN INPUTEVENTS_MV.CGID is
  'Foreign key. Identifies the caregiver.';
COMMENT ON COLUMN INPUTEVENTS_MV.ORDERID is
  'Identifier linking items which are grouped in a solution.';
COMMENT ON COLUMN INPUTEVENTS_MV.LINKORDERID is
  'Identifier linking orders across multiple administrations. LINKORDERID is always equal to the first occuring ORDERID of the series.';
COMMENT ON COLUMN INPUTEVENTS_MV.ORDERCATEGORYNAME is
  'A group which the item corresponds to.';
COMMENT ON COLUMN INPUTEVENTS_MV.SECONDARYORDERCATEGORYNAME is
  'A secondary group for those items with more than one grouping possible.';
COMMENT ON COLUMN INPUTEVENTS_MV.ORDERCOMPONENTTYPEDESCRIPTION is
  'The role of the item administered in the order.';
COMMENT ON COLUMN INPUTEVENTS_MV.ORDERCATEGORYDESCRIPTION is
  'The type of item administered.';
COMMENT ON COLUMN INPUTEVENTS_MV.PATIENTWEIGHT is
  'For drugs dosed by weight, the value of the weight used in the calculation.';
COMMENT ON COLUMN INPUTEVENTS_MV.TOTALAMOUNT is
  'The total amount in the solution for the given item.';
COMMENT ON COLUMN INPUTEVENTS_MV.TOTALAMOUNTUOM is
  'Unit of measurement for the total amount in the solution.';
COMMENT ON COLUMN INPUTEVENTS_MV.ISOPENBAG is
  'Indicates whether the bag containing the solution is open.';
COMMENT ON COLUMN INPUTEVENTS_MV.CONTINUEINNEXTDEPT is
  'Indicates whether the item will be continued in the next department where the patient is transferred to.';
COMMENT ON COLUMN INPUTEVENTS_MV.CANCELREASON is
  'Reason for cancellation, if cancelled.';
COMMENT ON COLUMN INPUTEVENTS_MV.STATUSDESCRIPTION is
  'The current status of the order: stopped, rewritten, running or cancelled.';
COMMENT ON COLUMN INPUTEVENTS_MV.COMMENTS_EDITEDBY is
  'The title of the caregiver who edited the order.';
COMMENT ON COLUMN INPUTEVENTS_MV.COMMENTS_CANCELEDBY is
  'The title of the caregiver who canceled the order.';
COMMENT ON COLUMN INPUTEVENTS_MV.COMMENTS_DATE is
  'Time at which the caregiver edited or cancelled the order.';
COMMENT ON COLUMN INPUTEVENTS_MV.ORIGINALAMOUNT is
  'Amount of the item which was originally charted.';
COMMENT ON COLUMN INPUTEVENTS_MV.ORIGINALRATE is
  'Rate of administration originally chosen for the item.';

-------------
--LABEVENTS--
-------------

-- Table
COMMENT ON TABLE LABEVENTS IS
   'Events relating to laboratory tests.';

-- Columns
COMMENT ON COLUMN LABEVENTS.ROW_ID is
   'Unique row identifier.';
COMMENT ON COLUMN LABEVENTS.SUBJECT_ID is
   'Foreign key. Identifies the patient.';
COMMENT ON COLUMN LABEVENTS.HADM_ID is
   'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN LABEVENTS.ITEMID is
   'Foreign key. Identifies the charted item.';
COMMENT ON COLUMN LABEVENTS.CHARTTIME is
   'Time when the event occured.';
COMMENT ON COLUMN LABEVENTS.VALUE is
   'Value of the event as a text string.';
COMMENT ON COLUMN LABEVENTS.VALUENUM is
   'Value of the event as a number.';
COMMENT ON COLUMN LABEVENTS.VALUEUOM is
   'Unit of measurement.';
COMMENT ON COLUMN LABEVENTS.FLAG is
   'Flag indicating whether the lab test value is considered abnormal (null if the test was normal).';

----------------------
--MICROBIOLOGYEVENTS--
----------------------

-- Table
COMMENT ON TABLE MICROBIOLOGYEVENTS IS
   'Events relating to microbiology tests.';

-- Columns
COMMENT ON COLUMN MICROBIOLOGYEVENTS.ROW_ID is
   'Unique row identifier.';
COMMENT ON COLUMN MICROBIOLOGYEVENTS.SUBJECT_ID is
   'Foreign key. Identifies the patient.';
COMMENT ON COLUMN MICROBIOLOGYEVENTS.HADM_ID is
   'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN MICROBIOLOGYEVENTS.CHARTDATE is
   'Date when the event occured.';
COMMENT ON COLUMN MICROBIOLOGYEVENTS.CHARTTIME is
   'Time when the event occured, if available.';
COMMENT ON COLUMN MICROBIOLOGYEVENTS.SPEC_ITEMID is
   'Foreign key. Identifies the specimen.';
COMMENT ON COLUMN MICROBIOLOGYEVENTS.SPEC_TYPE_DESC is
   'Description of the specimen.';
COMMENT ON COLUMN MICROBIOLOGYEVENTS.ORG_ITEMID is
   'Foreign key. Identifies the organism.';
COMMENT ON COLUMN MICROBIOLOGYEVENTS.ORG_NAME is
   'Name of the organism.';
COMMENT ON COLUMN MICROBIOLOGYEVENTS.ISOLATE_NUM is
   'Isolate number associated with the test.';
COMMENT ON COLUMN MICROBIOLOGYEVENTS.AB_ITEMID is
   'Foreign key. Identifies the antibody.';
COMMENT ON COLUMN MICROBIOLOGYEVENTS.AB_NAME is
   'Name of the antibody used.';
COMMENT ON COLUMN MICROBIOLOGYEVENTS.DILUTION_TEXT is
   'The dilution amount tested for and the comparison which was made against it (e.g. <=4).';
COMMENT ON COLUMN MICROBIOLOGYEVENTS.DILUTION_COMPARISON is
   'The comparison component of DILUTION_TEXT: either <= (less than or equal), = (equal), or >= (greater than or equal), or null when not available.';
COMMENT ON COLUMN MICROBIOLOGYEVENTS.DILUTION_VALUE is
   'The value component of DILUTION_TEXT: must be a floating point number.';
COMMENT ON COLUMN MICROBIOLOGYEVENTS.INTERPRETATION is
   'Interpretation of the test.';

--------------
--NOTEEVENTS--
--------------

-- Table
COMMENT ON TABLE NOTEEVENTS IS
   'Notes associated with hospital stays.';

-- Columns
COMMENT ON COLUMN NOTEEVENTS.ROW_ID is
   'Unique row identifier.';
COMMENT ON COLUMN NOTEEVENTS.SUBJECT_ID is
   'Foreign key. Identifies the patient.';
COMMENT ON COLUMN NOTEEVENTS.HADM_ID is
   'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN NOTEEVENTS.CHARTDATE is
   'Date when the note was charted.';
COMMENT ON COLUMN NOTEEVENTS.CHARTTIME is
   'Date and time when the note was charted. Note that some notes (e.g. discharge summaries) do not have a time associated with them: these notes have NULL in this column.';
COMMENT ON COLUMN NOTEEVENTS.CATEGORY is
   'Category of the note, e.g. Discharge summary.';
COMMENT ON COLUMN NOTEEVENTS.DESCRIPTION is
   'A more detailed categorization for the note, sometimes entered by free-text.';
COMMENT ON COLUMN NOTEEVENTS.CGID is
   'Foreign key. Identifies the caregiver.';
COMMENT ON COLUMN NOTEEVENTS.ISERROR is
   'Flag to highlight an error with the note.';
COMMENT ON COLUMN NOTEEVENTS.TEXT is
   'Content of the note.';

------------
--PATIENTS--
------------

-- Table
COMMENT ON TABLE PATIENTS IS
   'Patients associated with an admission to the ICU.';

-- Columns
COMMENT ON COLUMN PATIENTS.ROW_ID is
   'Unique row identifier.';
COMMENT ON COLUMN PATIENTS.SUBJECT_ID is
   'Primary key. Identifies the patient.';
COMMENT ON COLUMN PATIENTS.GENDER is
   'Gender.';
COMMENT ON COLUMN PATIENTS.DOB is
   'Date of birth.';
COMMENT ON COLUMN PATIENTS.DOD is
   'Date of death. Null if the patient was alive at least 90 days post hospital discharge.';
COMMENT ON COLUMN PATIENTS.DOD_HOSP is
   'Date of death recorded in the hospital records.';
COMMENT ON COLUMN PATIENTS.DOD_SSN is
   'Date of death recorded in the social security records.';
COMMENT ON COLUMN PATIENTS.EXPIRE_FLAG is
   'Flag indicating that the patient has died.';

-----------------
--PRESCRIPTIONS--
-----------------

-- Table
COMMENT ON TABLE PRESCRIPTIONS IS
   'Medicines prescribed.';

-- Columns
COMMENT ON COLUMN PRESCRIPTIONS.ROW_ID is
   'Unique row identifier.';
COMMENT ON COLUMN PRESCRIPTIONS.SUBJECT_ID is
   'Foreign key. Identifies the patient.';
COMMENT ON COLUMN PRESCRIPTIONS.HADM_ID is
   'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN PRESCRIPTIONS.ICUSTAY_ID is
   'Foreign key. Identifies the ICU stay.';
COMMENT ON COLUMN PRESCRIPTIONS.STARTDATE is
   'Date when the prescription started.';
COMMENT ON COLUMN PRESCRIPTIONS.ENDDATE is
   'Date when the prescription ended.';
COMMENT ON COLUMN PRESCRIPTIONS.DRUG_TYPE is
   'Type of drug.';
COMMENT ON COLUMN PRESCRIPTIONS.DRUG is
   'Name of the drug.';
COMMENT ON COLUMN PRESCRIPTIONS.DRUG_NAME_POE is
   'Name of the drug on the Provider Order Entry interface.';
COMMENT ON COLUMN PRESCRIPTIONS.DRUG_NAME_GENERIC is
   'Generic drug name.';
COMMENT ON COLUMN PRESCRIPTIONS.FORMULARY_DRUG_CD is
   'Formulary drug code.';
COMMENT ON COLUMN PRESCRIPTIONS.GSN is
   'Generic Sequence Number.';
COMMENT ON COLUMN PRESCRIPTIONS.NDC is
   'National Drug Code.';
COMMENT ON COLUMN PRESCRIPTIONS.PROD_STRENGTH is
   'Strength of the drug (product).';
COMMENT ON COLUMN PRESCRIPTIONS.DOSE_VAL_RX is
   'Dose of the drug prescribed.';
COMMENT ON COLUMN PRESCRIPTIONS.DOSE_UNIT_RX is
   'Unit of measurement associated with the dose.';
COMMENT ON COLUMN PRESCRIPTIONS.FORM_VAL_DISP is
   'Amount of the formulation dispensed.';
COMMENT ON COLUMN PRESCRIPTIONS.FORM_UNIT_DISP is
   'Unit of measurement associated with the formulation.';
COMMENT ON COLUMN PRESCRIPTIONS.ROUTE is
   'Route of administration, for example intravenous or oral.';

------------------
--PROCEDURES_ICD--
------------------

-- Table
COMMENT ON TABLE PROCEDURES_ICD IS
   'Procedures relating to a hospital admission coded using the ICD9 system.';

-- Columns
COMMENT ON COLUMN PROCEDURES_ICD.ROW_ID is
   'Unique row identifier.';
COMMENT ON COLUMN PROCEDURES_ICD.SUBJECT_ID is
   'Foreign key. Identifies the patient.';
COMMENT ON COLUMN PROCEDURES_ICD.HADM_ID is
   'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN PROCEDURES_ICD.SEQ_NUM is
   'Lower procedure numbers occurred earlier.';
COMMENT ON COLUMN PROCEDURES_ICD.ICD9_CODE is
   'ICD9 code associated with the procedure.';

------------
--SERVICES--
------------

-- Table
COMMENT ON TABLE SERVICES IS
  'Hospital services that patients were under during their hospital stay.';

-- Columns
COMMENT ON COLUMN SERVICES.ROW_ID is
   'Unique row identifier.';
COMMENT ON COLUMN SERVICES.SUBJECT_ID is
   'Foreign key. Identifies the patient.';
COMMENT ON COLUMN SERVICES.HADM_ID is
   'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN SERVICES.TRANSFERTIME is
   'Time when the transfer occured.';
COMMENT ON COLUMN SERVICES.PREV_SERVICE is
   'Previous service type.';
COMMENT ON COLUMN SERVICES.CURR_SERVICE is
   'Current service type.';

-------------
--TRANSFERS--
-------------

-- Table
COMMENT ON TABLE TRANSFERS IS
   'Location of patients during their hospital stay.';

-- Columns
COMMENT ON COLUMN TRANSFERS.ROW_ID is
   'Unique row identifier.';
COMMENT ON COLUMN TRANSFERS.SUBJECT_ID is
   'Foreign key. Identifies the patient.';
COMMENT ON COLUMN TRANSFERS.HADM_ID is
   'Foreign key. Identifies the hospital stay.';
COMMENT ON COLUMN TRANSFERS.ICUSTAY_ID is
   'Foreign key. Identifies the ICU stay.';
COMMENT ON COLUMN TRANSFERS.DBSOURCE is
   'Source database of the item.';
COMMENT ON COLUMN TRANSFERS.EVENTTYPE is
   'Type of event, for example admission or transfer.';
COMMENT ON COLUMN TRANSFERS.PREV_WARDID is
   'Identifier for the previous ward the patient was located in.';
COMMENT ON COLUMN TRANSFERS.CURR_WARDID is
   'Identifier for the current ward the patient is located in.';
COMMENT ON COLUMN TRANSFERS.PREV_CAREUNIT is
   'Previous careunit.';
COMMENT ON COLUMN TRANSFERS.CURR_CAREUNIT is
   'Current careunit.';
COMMENT ON COLUMN TRANSFERS.INTIME is
   'Time when the patient was transferred into the unit.';
COMMENT ON COLUMN TRANSFERS.OUTTIME is
   'Time when the patient was transferred out of the unit.';
COMMENT ON COLUMN TRANSFERS.LOS is
   'Length of stay in the unit in minutes.';

COMMENT ON TABLE outputevents IS 'Output data for patients.';
COMMENT ON COLUMN outputevents.SUBJECT_ID IS 'Identifier which is unique to a patient.';
COMMENT ON COLUMN outputevents.HADM_ID IS 'Identifier which is unique to a patient hospital stay.';
COMMENT ON COLUMN outputevents.ICUSTAY_ID IS 'Identifier which is unique to a patient ICU stay.';

COMMENT ON COLUMN outputevents.CHARTTIME IS 'The time of an output event.';

COMMENT ON COLUMN outputevents.ITEMID IS 'Identifier for a single measurement type in the database. Each row associated with one ITEMID (e.g. 212) corresponds to an instantiation of the same measurement (e.g. heart rate). Metavision ITEMID values are all above 220000. A subset of commonly used medications in CareVue data have ITEMID values between 30000-39999. The remaining input/output ITEMID values are between 40000-49999.';

COMMENT ON COLUMN outputevents.VALUE IS 'Lists the amount of a substance at the CHARTTIME (when the exact start time is unknown, but usually up to an hour before).';
COMMENT ON COLUMN outputevents.VALUEUOM IS 'Lists the unit of measure for the VALUE at the CHARTTIME (when the exact start time is unknown, but usually up to an hour before).';

COMMENT ON COLUMN outputevents.STORETIME IS 'Records the time at which an observation was manually input or manually validated by a member of the clinical staff.';

COMMENT ON COLUMN outputevents.CGID IS 'Identifier for the caregiver who validated the given measurement.';

COMMENT ON COLUMN outputevents.STOPPED IS 'Indicates if the order was disconnected at the given CHARTTIME.';
COMMENT ON COLUMN outputevents.NEWBOTTLE IS 'Indicates that a new bag of solution was hung at the given CHARTTIME.';
COMMENT ON COLUMN outputevents.ISERROR IS 'A Metavision checkbox where a caregiver can specify that an observation is an error. No other details are provided.';

COMMENT ON TABLE PROCEDUREEVENTS_MV IS 'Contains procedures for patients.';
COMMENT ON COLUMN PROCEDUREEVENTS_MV.ROW_ID IS 'Unique identifier for the row.';
COMMENT ON COLUMN PROCEDUREEVENTS_MV.SUBJECT_ID IS 'Identifier for each patient. The unique identifier of the patient for whom the procedure is recorded. This may be a system generated code.';
COMMENT ON COLUMN PROCEDUREEVENTS_MV.HADM_ID IS 'Identifier for each hospital admission. The unique identifier for the visit during which the procedure took place.';
COMMENT ON COLUMN PROCEDUREEVENTS_MV.ICUSTAY_ID IS 'Identifier for each intensive care unit stay. The identifier for the detailed visit record during which the Procedure took place, such as the Intensive Care Unit stay during the hospital visit.';
COMMENT ON COLUMN PROCEDUREEVENTS_MV.STARTTIME IS 'The time the procedure started. The exact time when the procedure happened.';
COMMENT ON COLUMN PROCEDUREEVENTS_MV.ENDTIME IS 'The time the procedure ended.';
COMMENT ON COLUMN PROCEDUREEVENTS_MV.ITEMID IS 'Identifier for each item in the procedure. This field houses the unique concept identifier for the procedure. This is used primarily for analyses and network studies.';
COMMENT ON COLUMN PROCEDUREEVENTS_MV.VALUE IS 'Value of the item in the procedure. The original value from the source data that represents the actual procedure performed.';
COMMENT ON COLUMN PROCEDUREEVENTS_MV.VALUEUOM IS 'Unit of measure for the value of the item in the procedure.';
COMMENT ON COLUMN PROCEDUREEVENTS_MV.LOCATION IS 'Location where the procedure was performed.';
COMMENT ON COLUMN PROCEDUREEVENTS_MV.LOCATIONCATEGORY IS 'Category of the location where the procedure was performed.';
COMMENT ON COLUMN PROCEDUREEVENTS_MV.STORETIME IS 'Records the time at which an observation was manually input or manually validated by a member of the clinical staff.';
COMMENT ON COLUMN PROCEDUREEVENTS_MV.CGID IS 'Identifier for each caregiver. The identification number of the provider associated with the procedure record, for example, the provider who performed the procedure.';
COMMENT ON COLUMN PROCEDUREEVENTS_MV.ORDERID IS 'Identifier for the order associated with the procedure.';
COMMENT ON COLUMN PROCEDUREEVENTS_MV.LINKORDERID IS 'Identifier for the linked order associated with the procedure.';
COMMENT ON COLUMN PROCEDUREEVENTS_MV.ORDERCATEGORYNAME IS 'The name of the order category.';
COMMENT ON COLUMN PROCEDUREEVENTS_MV.SECONDARYORDERCATEGORYNAME IS 'The name of the secondary order category.';
COMMENT ON COLUMN PROCEDUREEVENTS_MV.ORDERCATEGORYDESCRIPTION IS 'Description of the order category.';
COMMENT ON COLUMN PROCEDUREEVENTS_MV.ISOPENBAG IS 'Indicates whether the bag is open.';
COMMENT ON COLUMN PROCEDUREEVENTS_MV.CONTINUEINNEXTDEPT IS 'Indicates if the procedure will continue in the next department.';
COMMENT ON COLUMN PROCEDUREEVENTS_MV.CANCELREASON IS 'Reason for canceling the procedure.';
COMMENT ON COLUMN PROCEDUREEVENTS_MV.STATUSDESCRIPTION IS 'Description of the status of the procedure.';
COMMENT ON COLUMN PROCEDUREEVENTS_MV.COMMENTS_EDITEDBY IS 'Identifier of the person who edited the comments.';
COMMENT ON COLUMN PROCEDUREEVENTS_MV.COMMENTS_CANCELEDBY IS 'Identifier of the person who canceled the comments.';
COMMENT ON COLUMN PROCEDUREEVENTS_MV.COMMENTS_DATE IS 'Date when the comments were made.';