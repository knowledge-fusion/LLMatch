CREATE TABLE beneficiary_summary (
    beneficiary_birth_date INT,
    beneficiary_county_code VARCHAR(255),
    beneficiary_death_date INT,
    beneficiary_esrd_indicator VARCHAR(255),
    part_a_coverage_months INT,
    hmo_coverage_months INT,
    beneficiary_race_code VARCHAR(255),
    beneficiary_sex_code VARCHAR(255),
    part_b_coverage_months INT,
    carrier_annual_beneficiary_responsibility_amount REAL,
    inpatient_annual_beneficiary_responsibility_amount REAL,
    outpatient_annual_beneficiary_responsibility_amount REAL,
    beneficiary_code VARCHAR(255),
    carrier_annual_medicare_reimbursement_amount REAL,
    inpatient_annual_medicare_reimbursement_amount REAL,
    outpatient_annual_medicare_reimbursement_amount REAL,
    part_d_coverage_months INT,
    carrier_annual_primary_payer_reimbursement_amount REAL,
    inpatient_annual_primary_payer_reimbursement_amount REAL,
    outpatient_annual_primary_payer_reimbursement_amount REAL,
    chronic_condition_alzheimers INT,
    chronic_condition_heart_failure INT,
    chronic_condition_chronic_kidney_disease INT,
    chronic_condition_cancer INT,
    chronic_condition_copd INT,
    chronic_condition_depression INT,
    chronic_condition_diabetes INT,
    chronic_condition_ischemic_heart_disease INT,
    chronic_condition_osteoporosis INT,
    chronic_condition_rheumatoid_arthritis_osteoarthritis INT,
    state_code INT,
    chronic_condition_stroke_tia INT 
);

COMMENT ON TABLE beneficiary_summary IS 'This table contains detailed information about synthetic Medicare beneficiaries, including personal characteristics, coverages, reimbursements, and chronic conditions.';
COMMENT ON COLUMN beneficiary_summary.beneficiary_birth_date IS 'Date of birth of the beneficiary. Type: Integer';
COMMENT ON COLUMN beneficiary_summary.beneficiary_county_code IS 'County code where the beneficiary resides. Type: Text';
COMMENT ON COLUMN beneficiary_summary.beneficiary_death_date IS 'Date of death of the beneficiary. Type: Integer';
COMMENT ON COLUMN beneficiary_summary.beneficiary_esrd_indicator IS 'Indicator for End-Stage Renal Disease. Type: Text';
COMMENT ON COLUMN beneficiary_summary.part_a_coverage_months IS 'Total number of months of Part A coverage for the beneficiary. Type: Integer';
COMMENT ON COLUMN beneficiary_summary.hmo_coverage_months IS 'Total number of months of HMO coverage for the beneficiary. Type: Integer';
COMMENT ON COLUMN beneficiary_summary.beneficiary_race_code IS 'Race code of the beneficiary. Type: Text';
COMMENT ON COLUMN beneficiary_summary.beneficiary_sex_code IS 'Sex of the beneficiary. Type: Text';
COMMENT ON COLUMN beneficiary_summary.part_b_coverage_months IS 'Total number of months of Part B coverage for the beneficiary. Type: Integer';
COMMENT ON COLUMN beneficiary_summary.carrier_annual_beneficiary_responsibility_amount IS 'Annual beneficiary responsibility amount for carrier services. Type: Real';
COMMENT ON COLUMN beneficiary_summary.inpatient_annual_beneficiary_responsibility_amount IS 'Annual beneficiary responsibility amount for inpatient services. Type: Real';
COMMENT ON COLUMN beneficiary_summary.outpatient_annual_beneficiary_responsibility_amount IS 'Annual beneficiary responsibility amount for outpatient institutional services. Type: Real';
COMMENT ON COLUMN beneficiary_summary.beneficiary_code IS 'Unique identifier for the beneficiary. Type: Text';
COMMENT ON COLUMN beneficiary_summary.carrier_annual_medicare_reimbursement_amount IS 'Annual Medicare reimbursement amount for carrier services. Type: Real';
COMMENT ON COLUMN beneficiary_summary.inpatient_annual_medicare_reimbursement_amount IS 'Annual Medicare reimbursement amount for inpatient services. Type: Real';
COMMENT ON COLUMN beneficiary_summary.outpatient_annual_medicare_reimbursement_amount IS 'Annual Medicare reimbursement amount for outpatient institutional services. Type: Real';
COMMENT ON COLUMN beneficiary_summary.part_d_coverage_months IS 'Total number of months of Part D plan coverage for the beneficiary. Type: Integer';
COMMENT ON COLUMN beneficiary_summary.carrier_annual_primary_payer_reimbursement_amount IS 'Annual primary payer reimbursement amount for carrier services. Type: Real';
COMMENT ON COLUMN beneficiary_summary.inpatient_annual_primary_payer_reimbursement_amount IS 'Annual primary payer reimbursement amount for inpatient services. Type: Real';
COMMENT ON COLUMN beneficiary_summary.outpatient_annual_primary_payer_reimbursement_amount IS 'Annual primary payer reimbursement amount for outpatient institutional services. Type: Real';
COMMENT ON COLUMN beneficiary_summary.chronic_condition_alzheimers IS 'Indicator for chronic condition: Alzheimer's or related disorders or senile. Type: Integer';
COMMENT ON COLUMN beneficiary_summary.chronic_condition_heart_failure IS 'Indicator for chronic condition: Heart failure. Type: Integer';
COMMENT ON COLUMN beneficiary_summary.chronic_condition_chronic_kidney_disease IS 'Indicator for chronic condition: Chronic kidney disease. Type: Integer';
COMMENT ON COLUMN beneficiary_summary.chronic_condition_cancer IS 'Indicator for chronic condition: Cancer. Type: Integer';
COMMENT ON COLUMN beneficiary_summary.chronic_condition_copd IS 'Indicator for chronic condition: Chronic obstructive pulmonary disease. Type: Integer';
COMMENT ON COLUMN beneficiary_summary.chronic_condition_depression IS 'Indicator for chronic condition: Depression. Type: Integer';
COMMENT ON COLUMN beneficiary_summary.chronic_condition_diabetes IS 'Indicator for chronic condition: Diabetes. Type: Integer';
COMMENT ON COLUMN beneficiary_summary.chronic_condition_ischemic_heart_disease IS 'Indicator for chronic condition: Ischemic heart disease. Type: Integer';
COMMENT ON COLUMN beneficiary_summary.chronic_condition_osteoporosis IS 'Indicator for chronic condition: Osteoporosis. Type: Integer';
COMMENT ON COLUMN beneficiary_summary.chronic_condition_rheumatoid_arthritis_osteoarthritis IS 'Indicator for chronic condition: Rheumatoid arthritis and osteoarthritis (RA/OA). Type: Integer';
COMMENT ON COLUMN beneficiary_summary.state_code IS 'State code where the beneficiary resides. Type: Integer';
COMMENT ON COLUMN beneficiary_summary.chronic_condition_stroke_tia IS 'Indicator for chronic condition: Stroke/Transient Ischemic Attack. Type: Integer';

CREATE TABLE inpatient_claims_information (
    admitting_diagnosis_code VARCHAR(255),
    attending_physician_national_provider_identifier BIGINT,
    inpatient_admission_date INT,
    claim_diagnosis_related_group_code VARCHAR(255),
    claim_start_date INT,
    claim_identifier BIGINT,
    claim_per_diem_amount REAL,
    claim_payment_amount REAL,
    claim_end_date INT,
    claim_utilization_day_count INT,
    beneficiary_code VARCHAR(255),
    revenue_center_procedure_coding_system_code VARCHAR(255),
    claim_diagnosis_code VARCHAR(255),
    claim_procedure_code VARCHAR(255),
    beneficiary_blood_deductible_liability_amount REAL,
    inpatient_discharged_date INT,
    beneficiary_inpatient_deductible_amount REAL,
    beneficiary_part_a_coinsurance_liability_amount REAL,
    primary_payer_claim_paid_amount REAL,
    operating_physician_national_provider_identifier BIGINT,
    other_physician_national_provider_identifier BIGINT,
    provider_institution_number BIGINT,
    claim_line_segment INT 
);

COMMENT ON TABLE inpatient_claims_information IS 'The inpatient claims information pertains to a synthetic inpatient claim.';
COMMENT ON COLUMN inpatient_claims_information.admitting_diagnosis_code IS 'Code of the diagnosis at admission';
COMMENT ON COLUMN inpatient_claims_information.attending_physician_national_provider_identifier IS 'National Provider Identifier number of the attending physician';
COMMENT ON COLUMN inpatient_claims_information.inpatient_admission_date IS 'Date of inpatient admission';
COMMENT ON COLUMN inpatient_claims_information.claim_diagnosis_related_group_code IS 'Diagnosis Related Group code for the claim';
COMMENT ON COLUMN inpatient_claims_information.claim_start_date IS 'Start date of the claim';
COMMENT ON COLUMN inpatient_claims_information.claim_identifier IS 'Identification code for claims';
COMMENT ON COLUMN inpatient_claims_information.claim_per_diem_amount IS 'Per Diem amount of the claim';
COMMENT ON COLUMN inpatient_claims_information.claim_payment_amount IS 'Amount paid for the claim';
COMMENT ON COLUMN inpatient_claims_information.claim_end_date IS 'End date of the claim';
COMMENT ON COLUMN inpatient_claims_information.claim_utilization_day_count IS 'Count of days for claim utilization';
COMMENT ON COLUMN inpatient_claims_information.beneficiary_code IS 'Code to Identify Beneficiary';
COMMENT ON COLUMN inpatient_claims_information.revenue_center_procedure_coding_system_code IS 'Procedure coding system code of the revenue center';
COMMENT ON COLUMN inpatient_claims_information.claim_diagnosis_code IS 'Diagnosis code for the claim';
COMMENT ON COLUMN inpatient_claims_information.claim_procedure_code IS 'Procedure code for the claim';
COMMENT ON COLUMN inpatient_claims_information.beneficiary_blood_deductible_liability_amount IS 'Liability amount for blood deductible of beneficiary';
COMMENT ON COLUMN inpatient_claims_information.inpatient_discharged_date IS 'Discharge date of inpatient';
COMMENT ON COLUMN inpatient_claims_information.beneficiary_inpatient_deductible_amount IS 'Deductible amount for inpatient beneficiary';
COMMENT ON COLUMN inpatient_claims_information.beneficiary_part_a_coinsurance_liability_amount IS 'Liability amount for Part A coinsurance of beneficiary';
COMMENT ON COLUMN inpatient_claims_information.primary_payer_claim_paid_amount IS 'Amount paid by the primary payer for the claim';
COMMENT ON COLUMN inpatient_claims_information.operating_physician_national_provider_identifier IS 'National Provider Identifier number of the operating physician';
COMMENT ON COLUMN inpatient_claims_information.other_physician_national_provider_identifier IS 'National Provider Identifier number of the other physician';
COMMENT ON COLUMN inpatient_claims_information.provider_institution_number IS 'Identification number of the provider institution';
COMMENT ON COLUMN inpatient_claims_information.claim_line_segment IS 'Line segment of the claim';

CREATE TABLE outpatient_medical_claims (
    claim_admitting_diagnosis_code VARCHAR(255),
    attending_physician_national_provider_identifier BIGINT,
    claim_start_date INT,
    claim_identifier BIGINT,
    claim_payment_amount REAL,
    claim_end_date INT,
    beneficiary_code VARCHAR(255),
    revenue_center_procedure_coding_system_code VARCHAR(255),
    claim_diagnosis_code VARCHAR(255),
    claim_procedure_code VARCHAR(255),
    beneficiary_blood_deductible_liability_amount REAL,
    beneficiary_part_b_coinsurance_amount REAL,
    beneficiary_part_b_deductible_amount REAL,
    primary_payer_claim_paid_amount REAL,
    operating_physician_national_provider_identifier BIGINT,
    other_physician_national_provider_identifier BIGINT,
    provider_institution_number BIGINT,
    claim_line_segment INT 
);

COMMENT ON TABLE outpatient_medical_claims IS 'Outpatient medical claims table pertains to synthetic outpatient medical claims.';
COMMENT ON COLUMN outpatient_medical_claims.claim_admitting_diagnosis_code IS 'Admitting diagnosis code of the claim';
COMMENT ON COLUMN outpatient_medical_claims.attending_physician_national_provider_identifier IS 'National provider identifier number of the attending physician';
COMMENT ON COLUMN outpatient_medical_claims.claim_start_date IS 'Start date of the claim';
COMMENT ON COLUMN outpatient_medical_claims.claim_identifier IS 'Identifier for the claim';
COMMENT ON COLUMN outpatient_medical_claims.claim_payment_amount IS 'Payment amount of the claim';
COMMENT ON COLUMN outpatient_medical_claims.claim_end_date IS 'End date of the claim';
COMMENT ON COLUMN outpatient_medical_claims.beneficiary_code IS 'Code of the beneficiary';
COMMENT ON COLUMN outpatient_medical_claims.revenue_center_procedure_coding_system_code IS 'Procedure coding system code of the revenue center';
COMMENT ON COLUMN outpatient_medical_claims.claim_diagnosis_code IS 'Diagnosis code of the claim';
COMMENT ON COLUMN outpatient_medical_claims.claim_procedure_code IS 'Procedure code of the claim';
COMMENT ON COLUMN outpatient_medical_claims.beneficiary_blood_deductible_liability_amount IS 'Liability amount of the beneficiary blood deductible';
COMMENT ON COLUMN outpatient_medical_claims.beneficiary_part_b_coinsurance_amount IS 'Coinsurance amount of the beneficiary part B';
COMMENT ON COLUMN outpatient_medical_claims.beneficiary_part_b_deductible_amount IS 'Deductible amount of the beneficiary part B';
COMMENT ON COLUMN outpatient_medical_claims.primary_payer_claim_paid_amount IS 'Paid amount of the primary payer claim';
COMMENT ON COLUMN outpatient_medical_claims.operating_physician_national_provider_identifier IS 'National provider identifier number of the operating physician';
COMMENT ON COLUMN outpatient_medical_claims.other_physician_national_provider_identifier IS 'National provider identifier number of another physician';
COMMENT ON COLUMN outpatient_medical_claims.provider_institution_number IS 'Number of the provider institution';
COMMENT ON COLUMN outpatient_medical_claims.claim_line_segment IS 'Segment of the claim line';

CREATE TABLE physician_supplier_claim_information (
    claim_start_date INT,
    claim_identifier BIGINT,
    claim_end_date INT,
    beneficiary_code VARCHAR(255),
    common_procedure_coding_system VARCHAR(255),
    claim_diagnosis_code VARCHAR(255),
    allowed_charge_amount REAL,
    primary_payer_paid_amount REAL,
    beneficiary_deductible_amount REAL,
    coinsurance_amount REAL,
    diagnosis_code VARCHAR(255),
    payment_amount REAL,
    processing_indicator_code VARCHAR(255),
    provider_physician_national_provider_identifier_number INT,
    provider_institution_tax_number INT 
);

COMMENT ON TABLE physician_supplier_claim_information IS 'The physician supplier claim information table pertains to synthetic physician or supplier claims.';
COMMENT ON COLUMN physician_supplier_claim_information.claim_start_date IS 'The starting date of the claim.';
COMMENT ON COLUMN physician_supplier_claim_information.claim_identifier IS 'A unique identification for each claim.';
COMMENT ON COLUMN physician_supplier_claim_information.claim_end_date IS 'The end date of the claim.';
COMMENT ON COLUMN physician_supplier_claim_information.beneficiary_code IS 'A code to identify the beneficiary.';
COMMENT ON COLUMN physician_supplier_claim_information.common_procedure_coding_system IS 'The common procedure coding system used by the healthcare industry.';
COMMENT ON COLUMN physician_supplier_claim_information.claim_diagnosis_code IS 'The diagnosis code related to the claim.';
COMMENT ON COLUMN physician_supplier_claim_information.allowed_charge_amount IS 'The allowed charge amount for the claim.';
COMMENT ON COLUMN physician_supplier_claim_information.primary_payer_paid_amount IS 'The amount paid by the primary payer.';
COMMENT ON COLUMN physician_supplier_claim_information.beneficiary_deductible_amount IS 'The deductible amount for the beneficiary.';
COMMENT ON COLUMN physician_supplier_claim_information.coinsurance_amount IS 'The coinsurance amount for the claim.';
COMMENT ON COLUMN physician_supplier_claim_information.diagnosis_code IS 'The diagnosis code related to the claim.';
COMMENT ON COLUMN physician_supplier_claim_information.payment_amount IS 'The payment amount for the claim.';
COMMENT ON COLUMN physician_supplier_claim_information.processing_indicator_code IS 'The code indicating the processing status of the claim.';
COMMENT ON COLUMN physician_supplier_claim_information.provider_physician_national_provider_identifier_number IS 'National Provider Identifier number of the provider physician.';
COMMENT ON COLUMN physician_supplier_claim_information.provider_institution_tax_number IS 'Tax number of the provider institution.';

CREATE TABLE prescription_drug_events (
    days_of_supply INT,
    beneficiary_code VARCHAR(255),
    part_d_event_number VARCHAR(255),
    product_service_identifier VARCHAR(255),
    patient_payment_amount REAL,
    quantity_dispensed INT,
    service_date INT,
    total_prescription_cost REAL 
);

COMMENT ON TABLE prescription_drug_events IS 'Prescription drug events relates to a synthetic part D event.';
COMMENT ON COLUMN prescription_drug_events.days_of_supply IS 'Number of days the supplied amount will last.';
COMMENT ON COLUMN prescription_drug_events.beneficiary_code IS 'Identifier code for beneficiary.';
COMMENT ON COLUMN prescription_drug_events.part_d_event_number IS 'Chronically Ill and Disabled Warehouse part D event number.';
COMMENT ON COLUMN prescription_drug_events.product_service_identifier IS 'Identifier for product service.';
COMMENT ON COLUMN prescription_drug_events.patient_payment_amount IS 'The amount paid by the patient.';
COMMENT ON COLUMN prescription_drug_events.quantity_dispensed IS 'Number of items dispensed.';
COMMENT ON COLUMN prescription_drug_events.service_date IS 'Date of prescription service.';
COMMENT ON COLUMN prescription_drug_events.total_prescription_cost IS 'The total cost of the drug.';