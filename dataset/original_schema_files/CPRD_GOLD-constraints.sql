ALTER TABLE clinical
ADD CONSTRAINT fk_clinical_consultation_cons_id
FOREIGN KEY (consid)
REFERENCES consultation(consid);

ALTER TABLE clinical
ADD CONSTRAINT fk_clinical_consultation_cons_type
FOREIGN KEY (constype)
REFERENCES consultation(constype);

ALTER TABLE clinical
ADD CONSTRAINT fk_clinical_patient
FOREIGN KEY (patid)
REFERENCES patient(patid);

ALTER TABLE clinical
ADD CONSTRAINT fk_clinical_staff
FOREIGN KEY (staffid)
REFERENCES staff(staffid);

ALTER TABLE immunisation
ADD CONSTRAINT fk_immunisation_consultation_cons_id
FOREIGN KEY (consid)
REFERENCES consultation(consid);

ALTER TABLE immunisation
ADD CONSTRAINT fk_immunisation_consultation_cons_type
FOREIGN KEY (constype)
REFERENCES consultation(constype);

ALTER TABLE immunisation
ADD CONSTRAINT fk_immunisation_patient
FOREIGN KEY (patid)
REFERENCES patient(patid);

ALTER TABLE immunisation
ADD CONSTRAINT fk_immunisation_staff
FOREIGN KEY (staffid)
REFERENCES staff(staffid);

ALTER TABLE referral
ADD CONSTRAINT fk_referral_consultation_cons_id
FOREIGN KEY (consid)
REFERENCES consultation(consid);

ALTER TABLE referral
ADD CONSTRAINT fk_referral_consultation_cons_type
FOREIGN KEY (constype)
REFERENCES consultation(constype);

ALTER TABLE referral
ADD CONSTRAINT fk_referral_patient
FOREIGN KEY (patid)
REFERENCES patient(patid);

ALTER TABLE referral
ADD CONSTRAINT fk_referral_staff
FOREIGN KEY (staffid)
REFERENCES staff(staffid);

ALTER TABLE test
ADD CONSTRAINT fk_test_consultation_cons_id
FOREIGN KEY (consid)
REFERENCES consultation(consid);

ALTER TABLE test
ADD CONSTRAINT fk_test_consultation_cons_type
FOREIGN KEY (constype)
REFERENCES consultation(constype);

ALTER TABLE test
ADD CONSTRAINT fk_test_patient
FOREIGN KEY (patid)
REFERENCES patient(patid);

ALTER TABLE test
ADD CONSTRAINT fk_test_staff
FOREIGN KEY (staffid)
REFERENCES staff(staffid);

ALTER TABLE therapy
ADD CONSTRAINT fk_therapy_consultation_cons_id
FOREIGN KEY (consid)
REFERENCES consultation(consid);

ALTER TABLE therapy
ADD CONSTRAINT fk_therapy_patient
FOREIGN KEY (patid)
REFERENCES patient(patid);

ALTER TABLE therapy
ADD CONSTRAINT fk_therapy_staff
FOREIGN KEY (staffid)
REFERENCES staff(staffid);




ALTER TABLE clinical
ADD CONSTRAINT fk_clinical_patient
FOREIGN KEY (patid)
REFERENCES patient(patid);

ALTER TABLE consultation
ADD CONSTRAINT fk_consultation_patient
FOREIGN KEY (patid)
REFERENCES patient(patid);

ALTER TABLE immunisation
ADD CONSTRAINT fk_immunisation_patient
FOREIGN KEY (patid)
REFERENCES patient(patid);

ALTER TABLE referral
ADD CONSTRAINT fk_referral_patient
FOREIGN KEY (patid)
REFERENCES patient(patid);

ALTER TABLE test
ADD CONSTRAINT fk_test_patient
FOREIGN KEY (patid)
REFERENCES patient(patid);

ALTER TABLE therapy
ADD CONSTRAINT fk_therapy_patient
FOREIGN KEY (patid)
REFERENCES patient(patid);


ALTER TABLE clinical
ADD CONSTRAINT fk_clinical_staff
FOREIGN KEY (staffid)
REFERENCES staff(staffid);

ALTER TABLE consultation
ADD CONSTRAINT fk_consultation_staff
FOREIGN KEY (staffid)
REFERENCES staff(staffid);

ALTER TABLE immunisation
ADD CONSTRAINT fk_immunisation_staff
FOREIGN KEY (staffid)
REFERENCES staff(staffid);

ALTER TABLE referral
ADD CONSTRAINT fk_referral_staff
FOREIGN KEY (staffid)
REFERENCES staff(staffid);

ALTER TABLE test
ADD CONSTRAINT fk_test_staff
FOREIGN KEY (staffid)
REFERENCES staff(staffid);

ALTER TABLE therapy
ADD CONSTRAINT fk_therapy_staff
FOREIGN KEY (staffid)
REFERENCES staff(staffid);