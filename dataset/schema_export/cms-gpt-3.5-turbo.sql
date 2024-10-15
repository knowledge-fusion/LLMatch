CREATE TABLE Medicare_Beneficiary_Summary (
    date_of_birth INT,
    county_code VARCHAR(255),
    date_of_death INT,
    end_stage_renal_disease_indicator VARCHAR(255),
    total_months_part_a_coverage INT,
    total_months_hmo_coverage INT,
    beneficiary_race_code VARCHAR(255),
    sex VARCHAR(255),
    total_months_part_b_coverage INT,
    carrier_annual_beneficiary_responsibility_amount REAL,
    inpatient_annual_beneficiary_responsibility_amount REAL,
    outpatient_institutional_annual_beneficiary_responsibility_amount REAL,
    beneficiary_code VARCHAR(255),
    carrier_annual_medicare_reimbursement_amount REAL,
    inpatient_annual_medicare_reimbursement_amount REAL,
    outpatient_institutional_annual_medicare_reimbursement_amount REAL,
    total_months_part_d_plan_coverage INT,
    carrier_annual_primary_payer_reimbursement_amount REAL,
    inpatient_annual_primary_payer_reimbursement_amount REAL,
    outpatient_institutional_annual_primary_payer_reimbursement_amount REAL,
    chronic_condition_alzheimers_related_disorders_or_senile INT,
    chronic_condition_heart_failure INT,
    chronic_condition_chronic_kidney_disease INT,
    chronic_condition_cancer INT,
    chronic_condition_chronic_obstructive_pulmonary_disease INT,
    chronic_condition_depression INT,
    chronic_condition_diabetes INT,
    chronic_condition_ischemic_heart_disease INT,
    chronic_condition_osteoporosis INT,
    chronic_condition_rheumatoid_arthritis_and_osteoarthritis INT,
    state_code INT,
    chronic_condition_stroketransient_ischemic_attack INT 
);

COMMENT ON TABLE Medicare_Beneficiary_Summary IS 'This table contains summarized information about Medicare beneficiaries.';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.date_of_birth IS 'Date of birth. Type: Integer';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.county_code IS 'County code. Type: Text';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.date_of_death IS 'Date of death. Type: Integer';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.end_stage_renal_disease_indicator IS 'End stage renal disease indicator. Type: Text';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.total_months_part_a_coverage IS 'Total number of months of Part A coverage for the beneficiary. Type: Integer';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.total_months_hmo_coverage IS 'Total number of months of HMO coverage for the beneficiary. Type: Integer';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.beneficiary_race_code IS 'Beneficiary race code. Type: Text';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.sex IS 'Sex. Type: Text';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.total_months_part_b_coverage IS 'Total number of months of Part B coverage for the beneficiary. Type: Integer';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.carrier_annual_beneficiary_responsibility_amount IS 'Carrier annual beneficiary responsibility amount. Type: Real';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.inpatient_annual_beneficiary_responsibility_amount IS 'Inpatient annual beneficiary responsibility amount. Type: Real';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.outpatient_institutional_annual_beneficiary_responsibility_amount IS 'Outpatient institutional annual beneficiary responsibility amount. Type: Real';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.beneficiary_code IS 'Beneficiary code. Type: Text';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.carrier_annual_medicare_reimbursement_amount IS 'Carrier annual Medicare reimbursement amount. Type: Real';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.inpatient_annual_medicare_reimbursement_amount IS 'Inpatient annual Medicare reimbursement amount. Type: Real';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.outpatient_institutional_annual_medicare_reimbursement_amount IS 'Outpatient institutional annual Medicare reimbursement amount. Type: Real';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.total_months_part_d_plan_coverage IS 'Total number of months of Part D plan coverage for the beneficiary. Type: Integer';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.carrier_annual_primary_payer_reimbursement_amount IS 'Carrier annual primary payer reimbursement amount. Type: Real';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.inpatient_annual_primary_payer_reimbursement_amount IS 'Inpatient annual primary payer reimbursement amount. Type: Real';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.outpatient_institutional_annual_primary_payer_reimbursement_amount IS 'Outpatient institutional annual primary payer reimbursement amount. Type: Real';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.chronic_condition_alzheimers_related_disorders_or_senile IS 'Chronic condition: Alzheimer or related disorders or senile. Type: Integer';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.chronic_condition_heart_failure IS 'Chronic condition: Heart failure. Type: Integer';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.chronic_condition_chronic_kidney_disease IS 'Chronic condition: Chronic kidney disease. Type: Integer';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.chronic_condition_cancer IS 'Chronic condition: Cancer. Type: Integer';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.chronic_condition_chronic_obstructive_pulmonary_disease IS 'Chronic condition: Chronic obstructive pulmonary disease. Type: Integer';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.chronic_condition_depression IS 'Chronic condition: Depression. Type: Integer';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.chronic_condition_diabetes IS 'Chronic condition: Diabetes. Type: Integer';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.chronic_condition_ischemic_heart_disease IS 'Chronic condition: Ischemic heart disease. Type: Integer';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.chronic_condition_osteoporosis IS 'Chronic condition: Osteoporosis. Type: Integer';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.chronic_condition_rheumatoid_arthritis_and_osteoarthritis IS 'Chronic condition: Rheumatoid arthritis and osteoarthritis (RA/OA). Type: Integer';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.state_code IS 'State code. Type: Integer';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.chronic_condition_stroketransient_ischemic_attack IS 'Chronic condition: Stroke/transient ischemic attack. Type: Integer';

CREATE TABLE healthcare_claims (
    claim_start_date INT,
    claim_identifier BIGINT,
    claim_end_date INT,
    beneficiary_identifier VARCHAR(255),
    common_procedure_code VARCHAR(255),
    diagnosis_code VARCHAR(255),
    line_allowed_charge_amount REAL,
    line_beneficiary_primary_payer_paid_amount REAL,
    line_beneficiary_part_b_deductible_amount REAL,
    line_coinsurance_amount REAL,
    line_diagnosis_code VARCHAR(255),
    line_nch_payment_amount REAL,
    line_processing_indicator_code VARCHAR(255),
    provider_physician_national_provider_identifier INT,
    provider_institution_tax_number INT 
);

COMMENT ON TABLE healthcare_claims IS 'This table contains information regarding healthcare claims made by synthetic physicians or suppliers.';
COMMENT ON COLUMN healthcare_claims.claim_start_date IS 'The date on which the claim was initiated. Type: Integer';
COMMENT ON COLUMN healthcare_claims.claim_identifier IS 'Primary Key. A unique identifier for each claim. Type: BigInt';
COMMENT ON COLUMN healthcare_claims.claim_end_date IS 'The date on which the claim was closed. Type: Integer';
COMMENT ON COLUMN healthcare_claims.beneficiary_identifier IS 'A unique identifier for each beneficiary. Type: Text';
COMMENT ON COLUMN healthcare_claims.common_procedure_code IS 'The Common Procedure Coding System code associated with a particular healthcare claim. Type: Text';
COMMENT ON COLUMN healthcare_claims.diagnosis_code IS 'The diagnosis code(s) associated with a particular healthcare claim. Type: Text';
COMMENT ON COLUMN healthcare_claims.line_allowed_charge_amount IS 'The allowed charge amount associated with each line of the healthcare claim. Type: Real';
COMMENT ON COLUMN healthcare_claims.line_beneficiary_primary_payer_paid_amount IS 'The amount the beneficiary's primary payer paid for each line of the healthcare claim. Type: Real';
COMMENT ON COLUMN healthcare_claims.line_beneficiary_part_b_deductible_amount IS 'The amount of beneficiary's part B deductible applied to each line of the healthcare claim. Type: Real';
COMMENT ON COLUMN healthcare_claims.line_coinsurance_amount IS 'The amount of coinsurance associated with each line of the healthcare claim. Type: Real';
COMMENT ON COLUMN healthcare_claims.line_diagnosis_code IS 'The diagnosis code(s) associated with each line of the healthcare claim. Type: Text';
COMMENT ON COLUMN healthcare_claims.line_nch_payment_amount IS 'The Medicare payment amount associated with each line of the healthcare claim. Type: Real';
COMMENT ON COLUMN healthcare_claims.line_processing_indicator_code IS 'The processing indicator code associated with each line of the healthcare claim. Type: Text';
COMMENT ON COLUMN healthcare_claims.provider_physician_national_provider_identifier IS 'The unique National Provider Identifier for the physician associated with the healthcare claim. Type: Integer';
COMMENT ON COLUMN healthcare_claims.provider_institution_tax_number IS 'The tax number associated with the institution associated with the healthcare claim. Type: Integer';

CREATE TABLE inpatient_claims (
    admitting_diagnosis_code VARCHAR(255),
    attending_physician_npi BIGINT,
    admission_date INT,
    diagnosis_related_group_code VARCHAR(255),
    claim_start_date INT,
    claim_identifier BIGINT,
    claim_pass_thru_per_diem_amount REAL,
    claim_payment_amount REAL,
    claim_end_date INT,
    claim_utilization_day_count INT,
    beneficiary_code VARCHAR(255),
    common_procedure_code VARCHAR(255),
    diagnosis_code VARCHAR(255),
    procedure_code VARCHAR(255),
    blood_deductible_liability_amount REAL,
    discharge_date INT,
    inpatient_deductible_amount REAL,
    part_a_coinsurance_liability_amount REAL,
    primary_payer_claim_paid_amount REAL,
    operating_physician_npi BIGINT,
    other_physician_npi BIGINT,
    provider_identifier BIGINT,
    claim_line_segment INT 
);

COMMENT ON TABLE inpatient_claims IS 'This table contains information on synthetic inpatient claims.';
COMMENT ON COLUMN inpatient_claims.admitting_diagnosis_code IS 'Diagnosis code recorded upon admission. Type: Text';
COMMENT ON COLUMN inpatient_claims.attending_physician_npi IS 'National Provider Identifier (NPI) of the Attending Physician. Type: Integer';
COMMENT ON COLUMN inpatient_claims.admission_date IS 'Date of Admission. Type: Integer';
COMMENT ON COLUMN inpatient_claims.diagnosis_related_group_code IS 'Code identifying the billing diagnosis related group. Type: Text';
COMMENT ON COLUMN inpatient_claims.claim_start_date IS 'Start date of the claim. Type: Integer';
COMMENT ON COLUMN inpatient_claims.claim_identifier IS 'Primary Key. Unique identifier for the claim. Type: Integer';
COMMENT ON COLUMN inpatient_claims.claim_pass_thru_per_diem_amount IS 'Amount paid per day over and above the per diem rate. Type: Real';
COMMENT ON COLUMN inpatient_claims.claim_payment_amount IS 'Amount paid for the claim. Type: Real';
COMMENT ON COLUMN inpatient_claims.claim_end_date IS 'End date of the claim. Type: Integer';
COMMENT ON COLUMN inpatient_claims.claim_utilization_day_count IS 'Number of days the claim was utilized. Type: Integer';
COMMENT ON COLUMN inpatient_claims.beneficiary_code IS 'Code that uniquely identifies the beneficiary. Type: Text';
COMMENT ON COLUMN inpatient_claims.common_procedure_code IS 'Common procedure code identifying the revenue center. Type: Text';
COMMENT ON COLUMN inpatient_claims.diagnosis_code IS 'Diagnosis code for the claim. Type: Text';
COMMENT ON COLUMN inpatient_claims.procedure_code IS 'Procedure code for the claim. Type: Text';
COMMENT ON COLUMN inpatient_claims.blood_deductible_liability_amount IS 'Blood deductible liability amount for the beneficiary. Type: Real';
COMMENT ON COLUMN inpatient_claims.discharge_date IS 'Date of discharge for inpatient claims. Type: Integer';
COMMENT ON COLUMN inpatient_claims.inpatient_deductible_amount IS 'Amount of deductible for inpatient claims. Type: Real';
COMMENT ON COLUMN inpatient_claims.part_a_coinsurance_liability_amount IS 'Part A coinsurance liability amount for the beneficiary. Type: Real';
COMMENT ON COLUMN inpatient_claims.primary_payer_claim_paid_amount IS 'Amount paid by primary payer for the claim. Type: Real';
COMMENT ON COLUMN inpatient_claims.operating_physician_npi IS 'National Provider Identifier (NPI) of the operating physician. Type: Integer';
COMMENT ON COLUMN inpatient_claims.other_physician_npi IS 'National Provider Identifier (NPI) of other physician. Type: Integer';
COMMENT ON COLUMN inpatient_claims.provider_identifier IS 'Unique identifier of the provider institution. Type: Integer';
COMMENT ON COLUMN inpatient_claims.claim_line_segment IS 'Claim line segment. Type: Integer';

CREATE TABLE outpatient_claims (
    admitting_diagnosis_code VARCHAR(255),
    attending_physician_npi BIGINT,
    claim_start_date INT,
    claim_identifier BIGINT,
    claim_payment_amount REAL,
    claim_end_date INT,
    beneficiary_code VARCHAR(255),
    common_procedure_code VARCHAR(255),
    diagnosis_code VARCHAR(255),
    procedure_code VARCHAR(255),
    blood_deductible_liability_amount REAL,
    part_b_coinsurance_amount REAL,
    part_b_deductible_amount REAL,
    primary_payer_claim_paid_amount REAL,
    operating_physician_npi BIGINT,
    other_physician_npi BIGINT,
    provider_identifier BIGINT,
    claim_line_segment INT 
);

COMMENT ON TABLE outpatient_claims IS 'This table contains all the details related to synthetic outpatient claims.';
COMMENT ON COLUMN outpatient_claims.admitting_diagnosis_code IS 'Admitting diagnosis code. Type: Text';
COMMENT ON COLUMN outpatient_claims.attending_physician_npi IS 'National Provider Identifier Number of the attending physician. Type: BigInt';
COMMENT ON COLUMN outpatient_claims.claim_start_date IS 'Claim start date. Type: Integer';
COMMENT ON COLUMN outpatient_claims.claim_identifier IS 'Claim Identifier. Primary Key. Type: BigInt';
COMMENT ON COLUMN outpatient_claims.claim_payment_amount IS 'Payment amount for the claim. Type: Real';
COMMENT ON COLUMN outpatient_claims.claim_end_date IS 'Claim end date. Type: Integer';
COMMENT ON COLUMN outpatient_claims.beneficiary_code IS 'Code of the beneficiary. Type: Text';
COMMENT ON COLUMN outpatient_claims.common_procedure_code IS 'HCFA Common Procedure Coding System for revenue center. Type: Text';
COMMENT ON COLUMN outpatient_claims.diagnosis_code IS 'Diagnosis code for the claim. Type: Text';
COMMENT ON COLUMN outpatient_claims.procedure_code IS 'Procedure code for the claim. Type: Text';
COMMENT ON COLUMN outpatient_claims.blood_deductible_liability_amount IS 'Beneficiary deductible liability amount for blood. Type: Real';
COMMENT ON COLUMN outpatient_claims.part_b_coinsurance_amount IS 'Part B coinsurance amount for beneficiary. Type: Real';
COMMENT ON COLUMN outpatient_claims.part_b_deductible_amount IS 'Part B deductible amount for beneficiary. Type: Real';
COMMENT ON COLUMN outpatient_claims.primary_payer_claim_paid_amount IS 'Amount paid for the claim by primary payer. Type: Real';
COMMENT ON COLUMN outpatient_claims.operating_physician_npi IS 'National Provider Identifier Number of the operating physician. Type: BigInt';
COMMENT ON COLUMN outpatient_claims.other_physician_npi IS 'National Provider Identifier Number of the other physician. Type: BigInt';
COMMENT ON COLUMN outpatient_claims.provider_identifier IS 'Identifier of the provider institution. Type: BigInt';
COMMENT ON COLUMN outpatient_claims.claim_line_segment IS 'Segment of the claim line. Type: Integer';

CREATE TABLE prescription_events (
    days_supply INT,
    beneficiary_code VARCHAR(255),
    partd_event_num VARCHAR(255),
    product_service_id VARCHAR(255),
    patient_pay_amount REAL,
    quantity_dispensed INT,
    service_date INT,
    gross_drug_cost REAL 
);

COMMENT ON TABLE prescription_events IS 'This table contains information on prescription drug events.';
COMMENT ON COLUMN prescription_events.days_supply IS 'The number of days a prescription should last. Type: Integer';
COMMENT ON COLUMN prescription_events.beneficiary_code IS 'The unique identifier for the beneficiary. Type: Text';
COMMENT ON COLUMN prescription_events.partd_event_num IS 'The unique identifier for the part d event. Type: Text';
COMMENT ON COLUMN prescription_events.product_service_id IS 'The identifier for a product or a service. Type: Text';
COMMENT ON COLUMN prescription_events.patient_pay_amount IS 'The amount the patient has to pay for the prescription. Type: Real';
COMMENT ON COLUMN prescription_events.quantity_dispensed IS 'The quantity of the drug dispensed. Type: Integer';
COMMENT ON COLUMN prescription_events.service_date IS 'Date of the service. Type: Integer';
COMMENT ON COLUMN prescription_events.gross_drug_cost IS 'The total cost of the drug. Type: Real';