-- Consultation table
ALTER TABLE consultation
ADD CONSTRAINT fk_consultation_patient
FOREIGN KEY (patid)
REFERENCES patient(patid);

ALTER TABLE consultation
ADD CONSTRAINT fk_consultation_practice
FOREIGN KEY (pracid)
REFERENCES practice(pracid);

ALTER TABLE consultation
ADD CONSTRAINT fk_consultation_staff
FOREIGN KEY (staffid)
REFERENCES staff(staffid);

-- Drugissue table
ALTER TABLE drugissue
ADD CONSTRAINT fk_drugissue_patient
FOREIGN KEY (patid)
REFERENCES patient(patid);

ALTER TABLE drugissue
ADD CONSTRAINT fk_drugissue_practice
FOREIGN KEY (pracid)
REFERENCES practice(pracid);

ALTER TABLE drugissue
ADD CONSTRAINT fk_drugissue_staff
FOREIGN KEY (staffid)
REFERENCES staff(staffid);

-- Observation table
ALTER TABLE observation
ADD CONSTRAINT fk_observation_patient
FOREIGN KEY (patid)
REFERENCES patient(patid);

ALTER TABLE observation
ADD CONSTRAINT fk_observation_practice
FOREIGN KEY (pracid)
REFERENCES practice(pracid);

ALTER TABLE observation
ADD CONSTRAINT fk_observation_staff
FOREIGN KEY (staffid)
REFERENCES staff(staffid);

-- Problem table
ALTER TABLE problem
ADD CONSTRAINT fk_problem_patient
FOREIGN KEY (patid)
REFERENCES patient(patid);

ALTER TABLE problem
ADD CONSTRAINT fk_problem_practice
FOREIGN KEY (pracid)
REFERENCES practice(pracid);

ALTER TABLE problem
ADD CONSTRAINT fk_problem_staff
FOREIGN KEY (lastrevstaffid)
REFERENCES staff(staffid);

-- Referral table
ALTER TABLE referral
ADD CONSTRAINT fk_referral_patient
FOREIGN KEY (patid)
REFERENCES patient(patid);

ALTER TABLE referral
ADD CONSTRAINT fk_referral_practice
FOREIGN KEY (pracid)
REFERENCES practice(pracid);

-- Patient table
ALTER TABLE patient
ADD CONSTRAINT fk_patient_practice
FOREIGN KEY (pracid)
REFERENCES practice(pracid);

ALTER TABLE patient
ADD CONSTRAINT fk_patient_usualgpstaff
FOREIGN KEY (usualgpstaffid)
REFERENCES staff(staffid);

-- Staff table
ALTER TABLE staff
ADD CONSTRAINT fk_staff_practice
FOREIGN KEY (pracid)
REFERENCES practice(pracid);

-- Observation table
ALTER TABLE observation
ADD CONSTRAINT fk_observation_consultation
FOREIGN KEY (consid)
REFERENCES consultation(consid);

-- Problem table
ALTER TABLE problem
ADD CONSTRAINT fk_problem_observation
FOREIGN KEY (obsid)
REFERENCES observation(obsid);

-- Referral table
ALTER TABLE referral
ADD CONSTRAINT fk_referral_observation
FOREIGN KEY (obsid)
REFERENCES observation(obsid);

-- Problem table
ALTER TABLE problem
ADD CONSTRAINT fk_problem_problem
FOREIGN KEY (parentprobobsid)
REFERENCES observation(obsid);