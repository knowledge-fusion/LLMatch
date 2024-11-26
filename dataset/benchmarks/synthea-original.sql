CREATE TABLE allergies (
    code VARCHAR(255),
    description VARCHAR(255),
    encounter VARCHAR(255),
    patient VARCHAR(255),
    start VARCHAR(255),
    stop VARCHAR(255)
);

COMMENT ON TABLE allergies IS 'patient allergy data.';';
COMMENT ON COLUMN allergies.code IS 'allergy code from snomed-ct';
COMMENT ON COLUMN allergies.description IS 'description of the allergy';
COMMENT ON COLUMN allergies.encounter IS 'foreign key to the encounter when the allergy was diagnosed.';
COMMENT ON COLUMN allergies.patient IS 'foreign key to the patient.';
COMMENT ON COLUMN allergies.start IS 'the date the allergy was diagnosed.';
COMMENT ON COLUMN allergies.stop IS 'the date the allergy ended, if applicable.';

CREATE TABLE careplans (
    code VARCHAR(255),
    description VARCHAR(255),
    encounter VARCHAR(255),
    id VARCHAR(255),
    patient VARCHAR(255),
    reasoncode VARCHAR(255),
    reasondescription VARCHAR(255),
    start VARCHAR(255),
    stop VARCHAR(255)
);

COMMENT ON TABLE careplans IS 'patient care plan data, including goals.';';
COMMENT ON COLUMN careplans.code IS 'code from snomed-ct';
COMMENT ON COLUMN careplans.description IS 'description of the care plan.';
COMMENT ON COLUMN careplans.encounter IS 'foreign key to the encounter when the care plan was initiated.';
COMMENT ON COLUMN careplans.id IS 'primary key. unique identifier of the care plan.';
COMMENT ON COLUMN careplans.patient IS 'foreign key to the patient.';
COMMENT ON COLUMN careplans.reasoncode IS 'diagnosis code from snomed-ct that this care plan addresses.';
COMMENT ON COLUMN careplans.reasondescription IS 'description of the reason code.';
COMMENT ON COLUMN careplans.start IS 'the date the care plan was initiated.';
COMMENT ON COLUMN careplans.stop IS 'the date the care plan ended, if applicable.';

CREATE TABLE conditions (
    code VARCHAR(255),
    description VARCHAR(255),
    encounter VARCHAR(255),
    patient VARCHAR(255),
    start VARCHAR(255),
    stop VARCHAR(255)
);

COMMENT ON TABLE conditions IS 'patient conditions or diagnoses.';';
COMMENT ON COLUMN conditions.code IS 'diagnosis code from snomed-ct';
COMMENT ON COLUMN conditions.description IS 'description of the condition.';
COMMENT ON COLUMN conditions.encounter IS 'foreign key to the encounter when the condition was diagnosed.';
COMMENT ON COLUMN conditions.patient IS 'foreign key to the patient.';
COMMENT ON COLUMN conditions.start IS 'the date the condition was diagnosed.';
COMMENT ON COLUMN conditions.stop IS 'the date the condition resolved, if applicable.';

CREATE TABLE encounters (
    code VARCHAR(255),
    cost VARCHAR(255),
    description VARCHAR(255),
    encounterclass VARCHAR(255),
    id VARCHAR(255),
    patient VARCHAR(255),
    provider VARCHAR(255),
    reasoncode VARCHAR(255),
    reasondescription VARCHAR(255),
    start VARCHAR(255),
    stop VARCHAR(255)
);

COMMENT ON TABLE encounters IS 'patient encounter data.';';
COMMENT ON COLUMN encounters.code IS 'encounter code from snomed-ct';
COMMENT ON COLUMN encounters.cost IS 'the base cost of the encounter, not including any line item costs.';
COMMENT ON COLUMN encounters.description IS 'description of the type of encounter.';
COMMENT ON COLUMN encounters.encounterclass IS 'the class of the encounter, such as ambulatory or emergency.';
COMMENT ON COLUMN encounters.id IS 'primary key. unique identifier of the encounter.';
COMMENT ON COLUMN encounters.patient IS 'foreign key to the patient.';
COMMENT ON COLUMN encounters.provider IS 'foreign key to the organization.';
COMMENT ON COLUMN encounters.reasoncode IS 'diagnosis code if this encounter targeted a specific condition.';
COMMENT ON COLUMN encounters.reasondescription IS 'description of the reason code.';
COMMENT ON COLUMN encounters.start IS 'the date and time the encounter started.';
COMMENT ON COLUMN encounters.stop IS 'the date and time the encounter concluded.';

CREATE TABLE imaging_studies (
    body_site_code VARCHAR(255),
    body_site_description VARCHAR(255),
    date VARCHAR(255),
    encounter VARCHAR(255),
    id VARCHAR(255),
    modality_code VARCHAR(255),
    modality_description VARCHAR(255),
    patient VARCHAR(255),
    sop_code VARCHAR(255),
    sop_description VARCHAR(255)
);

COMMENT ON TABLE imaging_studies IS 'patient imaging metadata.';';
COMMENT ON COLUMN imaging_studies.body_site_code IS 'a snomed body structures code describing what part of the body the images in the series were taken of.';
COMMENT ON COLUMN imaging_studies.body_site_description IS 'description of the body site.';
COMMENT ON COLUMN imaging_studies.date IS 'the date the imaging study was conducted.';
COMMENT ON COLUMN imaging_studies.encounter IS 'foreign key to the encounter where the imaging study was conducted.';
COMMENT ON COLUMN imaging_studies.id IS 'primary key. unique identifier of the imaging study.';
COMMENT ON COLUMN imaging_studies.modality_code IS 'a dicom-dcm code describing the method used to take the images.';
COMMENT ON COLUMN imaging_studies.modality_description IS 'description of the modality.';
COMMENT ON COLUMN imaging_studies.patient IS 'foreign key to the patient.';
COMMENT ON COLUMN imaging_studies.sop_code IS 'a dicom-sop code describing the subject-object pair (sop) that constitutes the image.';
COMMENT ON COLUMN imaging_studies.sop_description IS 'description of the sop code.';

CREATE TABLE immunizations (
    code VARCHAR(255),
    cost VARCHAR(255),
    date VARCHAR(255),
    description VARCHAR(255),
    encounter VARCHAR(255),
    patient VARCHAR(255)
);

COMMENT ON TABLE immunizations IS 'patient immunization data.';';
COMMENT ON COLUMN immunizations.code IS 'immunization code from CVX.';
COMMENT ON COLUMN immunizations.cost IS 'the line item cost of the immunization.';
COMMENT ON COLUMN immunizations.date IS 'the date the immunization was administered.';
COMMENT ON COLUMN immunizations.description IS 'description of the immunization.';
COMMENT ON COLUMN immunizations.encounter IS 'foreign key to the encounter where it was administered.';
COMMENT ON COLUMN immunizations.patient IS 'foreign key to the patient.';

CREATE TABLE medications (
    code VARCHAR(255),
    cost VARCHAR(255),
    description VARCHAR(255),
    encounter VARCHAR(255),
    patient VARCHAR(255),
    reasoncode VARCHAR(255),
    reasondescription VARCHAR(255),
    start VARCHAR(255),
    stop VARCHAR(255)
);

COMMENT ON TABLE medications IS 'patient medication data.';';
COMMENT ON COLUMN medications.code IS 'medication code from RxNorm.';
COMMENT ON COLUMN medications.cost IS 'the line item cost of the medication.';
COMMENT ON COLUMN medications.description IS 'description of the medication.';
COMMENT ON COLUMN medications.encounter IS 'foreign key to the encounter where prescribed.';
COMMENT ON COLUMN medications.patient IS 'foreign key to the patient.';
COMMENT ON COLUMN medications.reasoncode IS 'diagnosis code specifying the reason for the prescription.';
COMMENT ON COLUMN medications.reasondescription IS 'description of the reason code.';
COMMENT ON COLUMN medications.start IS 'the date the medication was prescribed.';
COMMENT ON COLUMN medications.stop IS 'the date the prescription ended, if applicable.';

CREATE TABLE observations (
    code VARCHAR(255),
    date VARCHAR(255),
    description VARCHAR(255),
    encounter VARCHAR(255),
    patient VARCHAR(255),
    type VARCHAR(255),
    units VARCHAR(255),
    value VARCHAR(255)
);

COMMENT ON TABLE observations IS 'patient observations including vital signs.';';
COMMENT ON COLUMN observations.code IS 'observation or lab code from LOINC.';
COMMENT ON COLUMN observations.date IS 'the date the observation was performed.';
COMMENT ON COLUMN observations.description IS 'description of the observation or lab.';
COMMENT ON COLUMN observations.encounter IS 'foreign key to the encounter where performed.';
COMMENT ON COLUMN observations.patient IS 'foreign key to the patient.';
COMMENT ON COLUMN observations.type IS 'the datatype of the value (e.g., text or numeric).';
COMMENT ON COLUMN observations.units IS 'the units of measure for the value.';
COMMENT ON COLUMN observations.value IS 'the recorded value of the observation.';

CREATE TABLE organizations (
    address VARCHAR(255),
    city VARCHAR(255),
    id VARCHAR(255),
    name VARCHAR(255),
    phone VARCHAR(255),
    state VARCHAR(255),
    utilization VARCHAR(255),
    zip VARCHAR(255)
);

COMMENT ON TABLE organizations IS 'provider organizations including hospitals.';';
COMMENT ON COLUMN organizations.address IS 'organization\';
COMMENT ON COLUMN organizations.city IS 'street address city.';
COMMENT ON COLUMN organizations.id IS 'primary key of the organization.';
COMMENT ON COLUMN organizations.name IS 'name of the organization.';
COMMENT ON COLUMN organizations.phone IS 'organization\';
COMMENT ON COLUMN organizations.state IS 'street address state abbreviation.';
COMMENT ON COLUMN organizations.utilization IS 'number of encounters performed by this organization.';
COMMENT ON COLUMN organizations.zip IS 'street address zip or postal code.';

CREATE TABLE patients (
    address VARCHAR(255),
    birthdate VARCHAR(255),
    birthplace VARCHAR(255),
    city VARCHAR(255),
    deathdate VARCHAR(255),
    drivers VARCHAR(255),
    ethnicity VARCHAR(255),
    first VARCHAR(255),
    gender VARCHAR(255),
    id VARCHAR(255),
    last VARCHAR(255),
    maiden VARCHAR(255),
    marital VARCHAR(255),
    passport VARCHAR(255),
    prefix VARCHAR(255),
    race VARCHAR(255),
    ssn VARCHAR(255),
    state VARCHAR(255),
    suffix VARCHAR(255),
    zip VARCHAR(255)
);

COMMENT ON TABLE patients IS 'patient demographic data.';';
COMMENT ON COLUMN patients.address IS 'patient\';
COMMENT ON COLUMN patients.birthdate IS 'the date the patient was born.';
COMMENT ON COLUMN patients.birthplace IS 'name of the town where the patient was born.';
COMMENT ON COLUMN patients.city IS 'patient\';
COMMENT ON COLUMN patients.deathdate IS 'the date the patient died.';
COMMENT ON COLUMN patients.drivers IS 'patient driver\';
COMMENT ON COLUMN patients.ethnicity IS 'patient\';
COMMENT ON COLUMN patients.first IS 'first name of the patient.';
COMMENT ON COLUMN patients.gender IS 'gender (m for male, f for female).';
COMMENT ON COLUMN patients.id IS 'primary key. unique identifier of the patient.';
COMMENT ON COLUMN patients.last IS 'last name of the patient.';
COMMENT ON COLUMN patients.maiden IS 'maiden name of the patient.';
COMMENT ON COLUMN patients.marital IS 'marital status (m for married, s for single).';
COMMENT ON COLUMN patients.passport IS 'patient\';
COMMENT ON COLUMN patients.prefix IS 'name prefix (e.g., Mr., Dr.).';
COMMENT ON COLUMN patients.race IS 'patient\';
COMMENT ON COLUMN patients.ssn IS 'patient\';
COMMENT ON COLUMN patients.state IS 'state in the patient\';
COMMENT ON COLUMN patients.suffix IS 'name suffix (e.g., PhD, MD).';
COMMENT ON COLUMN patients.zip IS 'zip or postal code of the patient\';

CREATE TABLE procedures (
    code VARCHAR(255),
    cost VARCHAR(255),
    date VARCHAR(255),
    description VARCHAR(255),
    encounter VARCHAR(255),
    patient VARCHAR(255),
    reasoncode VARCHAR(255),
    reasondescription VARCHAR(255)
);

COMMENT ON TABLE procedures IS 'patient procedure data including surgeries.';';
COMMENT ON COLUMN procedures.code IS 'procedure code from SNOMED-CT.';
COMMENT ON COLUMN procedures.cost IS 'the line item cost of the procedure.';
COMMENT ON COLUMN procedures.date IS 'the date the procedure was performed.';
COMMENT ON COLUMN procedures.description IS 'description of the procedure.';
COMMENT ON COLUMN procedures.encounter IS 'foreign key to the encounter.';
COMMENT ON COLUMN procedures.patient IS 'foreign key to the patient.';
COMMENT ON COLUMN procedures.reasoncode IS 'diagnosis code specifying the reason for the procedure.';
COMMENT ON COLUMN procedures.reasondescription IS 'description of the reason code.';

CREATE TABLE providers (
    address VARCHAR(255),
    city VARCHAR(255),
    gender VARCHAR(255),
    id VARCHAR(255),
    name VARCHAR(255),
    organization VARCHAR(255),
    specialty VARCHAR(255),
    state VARCHAR(255),
    utilization VARCHAR(255),
    zip VARCHAR(255)
);

COMMENT ON TABLE providers IS 'clinicians that provide patient care.';';
COMMENT ON COLUMN providers.address IS 'provider\';
COMMENT ON COLUMN providers.city IS 'street address city.';
COMMENT ON COLUMN providers.gender IS 'gender (m for male, f for female).';
COMMENT ON COLUMN providers.id IS 'primary key of the provider.';
COMMENT ON COLUMN providers.name IS 'first and last name of the provider.';
COMMENT ON COLUMN providers.organization IS 'foreign key to the organization.';
COMMENT ON COLUMN providers.specialty IS 'provider\';
COMMENT ON COLUMN providers.state IS 'street address state abbreviation.';
COMMENT ON COLUMN providers.utilization IS 'number of encounters performed by this provider.';
COMMENT ON COLUMN providers.zip IS 'street address zip or postal code.';