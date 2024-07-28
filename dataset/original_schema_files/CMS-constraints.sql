-- Adding constraints to beneficiarysummary table
ALTER TABLE beneficiarysummary
ADD CONSTRAINT pk_beneficiarysummary PRIMARY KEY (desynpuf_id);

ALTER TABLE beneficiarysummary
ADD CONSTRAINT chk_bene_sex_ident_cd CHECK (bene_sex_ident_cd IN ('M', 'F'));

-- Adding constraints to carrierclaims table
ALTER TABLE carrierclaims
ADD CONSTRAINT pk_carrierclaims PRIMARY KEY (clm_id);

ALTER TABLE carrierclaims
ADD CONSTRAINT fk_carrierclaims_desynpuf_id FOREIGN KEY (desynpuf_id) REFERENCES beneficiarysummary(desynpuf_id);

-- Adding constraints to inpatientclaims table
ALTER TABLE inpatientclaims
ADD CONSTRAINT pk_inpatientclaims PRIMARY KEY (clm_id);

ALTER TABLE inpatientclaims
ADD CONSTRAINT fk_inpatientclaims_desynpuf_id FOREIGN KEY (desynpuf_id) REFERENCES beneficiarysummary(desynpuf_id);

-- Adding constraints to outpatientclaims table
ALTER TABLE outpatientclaims
ADD CONSTRAINT pk_outpatientclaims PRIMARY KEY (clm_id);

ALTER TABLE outpatientclaims
ADD CONSTRAINT fk_outpatientclaims_desynpuf_id FOREIGN KEY (desynpuf_id) REFERENCES beneficiarysummary(desynpuf_id);

-- Adding constraints to prescriptiondrugevents table
ALTER TABLE prescriptiondrugevents
ADD CONSTRAINT pk_prescriptiondrugevents PRIMARY KEY (pde_id);

ALTER TABLE prescriptiondrugevents
ADD CONSTRAINT fk_prescriptiondrugevents_desynpuf_id FOREIGN KEY (desynpuf_id) REFERENCES beneficiarysummary(desynpuf_id);
