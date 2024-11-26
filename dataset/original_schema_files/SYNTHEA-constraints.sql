-- Constraints for table: allergies
ALTER TABLE allergies
ADD CONSTRAINT fk_allergies_encounter
FOREIGN KEY (encounter) REFERENCES encounters (id);

ALTER TABLE allergies
ADD CONSTRAINT fk_allergies_patient
FOREIGN KEY (patient) REFERENCES patients (id);

-- Constraints for table: careplans
ALTER TABLE careplans
ADD CONSTRAINT pk_careplans_id
PRIMARY KEY (id);

ALTER TABLE careplans
ADD CONSTRAINT fk_careplans_encounter
FOREIGN KEY (encounter) REFERENCES encounters (id);

ALTER TABLE careplans
ADD CONSTRAINT fk_careplans_patient
FOREIGN KEY (patient) REFERENCES patients (id);

-- Constraints for table: conditions
ALTER TABLE conditions
ADD CONSTRAINT pk_conditions_code_patient
PRIMARY KEY (code, patient);

ALTER TABLE conditions
ADD CONSTRAINT fk_conditions_encounter
FOREIGN KEY (encounter) REFERENCES encounters (id);

ALTER TABLE conditions
ADD CONSTRAINT fk_conditions_patient
FOREIGN KEY (patient) REFERENCES patients (id);

-- Constraints for table: encounters
ALTER TABLE encounters
ADD CONSTRAINT pk_encounters_id
PRIMARY KEY (id);

ALTER TABLE encounters
ADD CONSTRAINT fk_encounters_patient
FOREIGN KEY (patient) REFERENCES patients (id);

ALTER TABLE encounters
ADD CONSTRAINT fk_encounters_provider
FOREIGN KEY (provider) REFERENCES organizations (id);

-- Constraints for table: imaging_studies
ALTER TABLE imaging_studies
ADD CONSTRAINT pk_imaging_studies_id
PRIMARY KEY (id);

ALTER TABLE imaging_studies
ADD CONSTRAINT fk_imaging_studies_encounter
FOREIGN KEY (encounter) REFERENCES encounters (id);

ALTER TABLE imaging_studies
ADD CONSTRAINT fk_imaging_studies_patient
FOREIGN KEY (patient) REFERENCES patients (id);

-- Constraints for table: immunizations
ALTER TABLE immunizations
ADD CONSTRAINT pk_immunizations_code_patient
PRIMARY KEY (code, patient);

ALTER TABLE immunizations
ADD CONSTRAINT fk_immunizations_encounter
FOREIGN KEY (encounter) REFERENCES encounters (id);

ALTER TABLE immunizations
ADD CONSTRAINT fk_immunizations_patient
FOREIGN KEY (patient) REFERENCES patients (id);

-- Constraints for table: medications
ALTER TABLE medications
ADD CONSTRAINT pk_medications_code_patient
PRIMARY KEY (code, patient);

ALTER TABLE medications
ADD CONSTRAINT fk_medications_encounter
FOREIGN KEY (encounter) REFERENCES encounters (id);

ALTER TABLE medications
ADD CONSTRAINT fk_medications_patient
FOREIGN KEY (patient) REFERENCES patients (id);

-- Constraints for table: observations
ALTER TABLE observations
ADD CONSTRAINT pk_observations_code_patient
PRIMARY KEY (code, patient);

ALTER TABLE observations
ADD CONSTRAINT fk_observations_encounter
FOREIGN KEY (encounter) REFERENCES encounters (id);

ALTER TABLE observations
ADD CONSTRAINT fk_observations_patient
FOREIGN KEY (patient) REFERENCES patients (id);

-- Constraints for table: organizations
ALTER TABLE organizations
ADD CONSTRAINT pk_organizations_id
PRIMARY KEY (id);

-- Constraints for table: patients
ALTER TABLE patients
ADD CONSTRAINT pk_patients_id
PRIMARY KEY (id);

-- Constraints for table: procedures
ALTER TABLE procedures
ADD CONSTRAINT pk_procedures_code_patient
PRIMARY KEY (code, patient);

ALTER TABLE procedures
ADD CONSTRAINT fk_procedures_encounter
FOREIGN KEY (encounter) REFERENCES encounters (id);

ALTER TABLE procedures
ADD CONSTRAINT fk_procedures_patient
FOREIGN KEY (patient) REFERENCES patients (id);

-- Constraints for table: providers
ALTER TABLE providers
ADD CONSTRAINT pk_providers_id
PRIMARY KEY (id);

ALTER TABLE providers
ADD CONSTRAINT fk_providers_organization
FOREIGN KEY (organization) REFERENCES organizations (id);