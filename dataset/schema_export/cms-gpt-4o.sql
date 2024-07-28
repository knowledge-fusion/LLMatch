CREATE TABLE Medicare_Beneficiary_Summary (
    beneficiary_date_of_birth VARCHAR(255),
    county_code VARCHAR(255),
    beneficiary_date_of_death VARCHAR(255),
    end_stage_renal_disease_indicator VARCHAR(255),
    Total_Months_Part_A_Coverage VARCHAR(255),
    Total_Months_HMO_Coverage VARCHAR(255),
    beneficiary_race_code VARCHAR(255),
    beneficiary_sex_identifier VARCHAR(255),
    Total_Months_Part_B_Coverage VARCHAR(255),
    Carrier_Annual_Beneficiary_Responsibility VARCHAR(255),
    Inpatient_Annual_Beneficiary_Responsibility VARCHAR(255),
    Outpatient_Institutional_Annual_Beneficiary_Responsibility VARCHAR(255),
    beneficiary_code VARCHAR(255),
    Carrier_Annual_Medicare_Reimbursement VARCHAR(255),
    Inpatient_Annual_Medicare_Reimbursement VARCHAR(255),
    Outpatient_Institutional_Annual_Medicare_Reimbursement VARCHAR(255),
    Total_Months_Part_D_Plan_Coverage VARCHAR(255),
    Carrier_Annual_Primary_Payer_Reimbursement VARCHAR(255),
    Inpatient_Annual_Primary_Payer_Reimbursement VARCHAR(255),
    Outpatient_Institutional_Annual_Primary_Payer_Reimbursement VARCHAR(255),
    Alzheimer_Related_Disorders VARCHAR(255),
    Heart_Failure_Condition VARCHAR(255),
    Chronic_Kidney_Disease VARCHAR(255),
    Cancer_Condition VARCHAR(255),
    COPD_Condition VARCHAR(255),
    Depression VARCHAR(255),
    Diabetes VARCHAR(255),
    Ischemic_Heart_Disease VARCHAR(255),
    Osteoporosis VARCHAR(255),
    Rheumatoid_Arthritis_Osteoarthritis VARCHAR(255),
    state_code VARCHAR(255),
    Stroke_Transient_Ischemic_Attack VARCHAR(255)
);

COMMENT ON TABLE Medicare_Beneficiary_Summary IS 'This table pertains to synthetic Medicare beneficiary information.';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.beneficiary_date_of_birth IS 'The date of birth of the beneficiary.';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.county_code IS 'The code of the county where the beneficiary is located.';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.beneficiary_date_of_death IS 'The date of death of the beneficiary, if applicable.';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.end_stage_renal_disease_indicator IS 'Indication of end stage renal disease in the beneficiary.';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.Total_Months_Part_A_Coverage IS 'The total number of months of Part A coverage for the beneficiary.';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.Total_Months_HMO_Coverage IS 'The total number of months of HMO coverage for the beneficiary.';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.beneficiary_race_code IS 'A code representing the race of the beneficiary.';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.beneficiary_sex_identifier IS 'The sex of the beneficiary.';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.Total_Months_Part_B_Coverage IS 'The total number of months of Part B coverage for the beneficiary.';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.Carrier_Annual_Beneficiary_Responsibility IS 'Yearly amount that the beneficiary is responsible to pay the carrier.';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.Inpatient_Annual_Beneficiary_Responsibility IS 'Yearly amount that the beneficiary is responsible for inpatient treatment.';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.Outpatient_Institutional_Annual_Beneficiary_Responsibility IS 'Yearly amount that the beneficiary is responsible for outpatient institutional treatment.';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.beneficiary_code IS 'A unique code to identify each beneficiary.';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.Carrier_Annual_Medicare_Reimbursement IS 'Yearly reimbursement amount from Medicare given to the carrier.';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.Inpatient_Annual_Medicare_Reimbursement IS 'Yearly reimbursement amount from Medicare for inpatient treatment.';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.Outpatient_Institutional_Annual_Medicare_Reimbursement IS 'Yearly reimbursement amount from Medicare for outpatient institutional treatment.';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.Total_Months_Part_D_Plan_Coverage IS 'The total number of months of Part D plan coverage for the beneficiary.';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.Carrier_Annual_Primary_Payer_Reimbursement IS 'Yearly reimbursement amount from primary payer given to the carrier.';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.Inpatient_Annual_Primary_Payer_Reimbursement IS 'Yearly reimbursement amount from primary payer for inpatient treatment.';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.Outpatient_Institutional_Annual_Primary_Payer_Reimbursement IS 'Yearly reimbursement amount from primary payer for outpatient institutional treatment.';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.Alzheimer_Related_Disorders IS 'Indication of Alzheimer related disorders or senile in the beneficiary.';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.Heart_Failure_Condition IS 'Indication of heart failure condition in the beneficiary.';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.Chronic_Kidney_Disease IS 'Indication of chronic kidney disease in the beneficiary.';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.Cancer_Condition IS 'Indication of cancer condition in the beneficiary.';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.COPD_Condition IS 'Indication of chronic obstructive pulmonary disease (COPD) condition in the beneficiary.';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.Depression IS 'Indication of depression in the beneficiary.';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.Diabetes IS 'Indication of diabetes in the beneficiary.';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.Ischemic_Heart_Disease IS 'Indication of ischemic heart disease in the beneficiary.';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.Osteoporosis IS 'Indication of osteoporosis in the beneficiary.';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.Rheumatoid_Arthritis_Osteoarthritis IS 'Indication of rheumatoid arthritis and osteoarthritis (RA/OA) in the beneficiary.';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.state_code IS 'The code of the state where the beneficiary is located.';
COMMENT ON COLUMN Medicare_Beneficiary_Summary.Stroke_Transient_Ischemic_Attack IS 'Indication of stroke or transient ischemic attack in the beneficiary.';

CREATE TABLE inpatient_claims_information (
    admitting_diagnosis_code VARCHAR(255),
    attending_physician_national_provider_identifier VARCHAR(255),
    inpatient_admission_date VARCHAR(255),
    claim_diagnosis_related_group_code VARCHAR(255),
    claim_start_date VARCHAR(255),
    claim_identifier VARCHAR(255),
    claim_per_diem_amount VARCHAR(255),
    claim_payment_amount VARCHAR(255),
    claim_end_date VARCHAR(255),
    claim_utilization_day_count VARCHAR(255),
    beneficiary_code VARCHAR(255),
    revenue_center_procedure_coding_system_code VARCHAR(255),
    claim_diagnosis_code VARCHAR(255),
    claim_procedure_code VARCHAR(255),
    beneficiary_blood_deductible_liability_amount VARCHAR(255),
    inpatient_discharged_date VARCHAR(255),
    beneficiary_inpatient_deductible_amount VARCHAR(255),
    beneficiary_part_a_coinsurance_liability_amount VARCHAR(255),
    primary_payer_claim_paid_amount VARCHAR(255),
    operating_physician_national_provider_identifier VARCHAR(255),
    other_physician_national_provider_identifier VARCHAR(255),
    provider_institution_number VARCHAR(255),
    claim_line_segment VARCHAR(255)
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
    attending_physician_national_provider_identifier VARCHAR(255),
    claim_start_date VARCHAR(255),
    claim_identifier VARCHAR(255),
    claim_payment_amount VARCHAR(255),
    claim_end_date VARCHAR(255),
    beneficiary_code VARCHAR(255),
    revenue_center_procedure_coding_system_code VARCHAR(255),
    claim_diagnosis_code VARCHAR(255),
    claim_procedure_code VARCHAR(255),
    beneficiary_blood_deductible_liability_amount VARCHAR(255),
    beneficiary_part_b_coinsurance_amount VARCHAR(255),
    beneficiary_part_b_deductible_amount VARCHAR(255),
    primary_payer_claim_paid_amount VARCHAR(255),
    operating_physician_national_provider_identifier VARCHAR(255),
    other_physician_national_provider_identifier VARCHAR(255),
    provider_institution_number VARCHAR(255),
    claim_line_segment VARCHAR(255)
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
    claim_start_date VARCHAR(255),
    claim_identifier VARCHAR(255),
    claim_end_date VARCHAR(255),
    beneficiary_code VARCHAR(255),
    common_procedure_coding_system VARCHAR(255),
    claim_diagnosis_code VARCHAR(255),
    allowed_charge_amount VARCHAR(255),
    primary_payer_paid_amount VARCHAR(255),
    beneficiary_deductible_amount VARCHAR(255),
    coinsurance_amount VARCHAR(255),
    diagnosis_code VARCHAR(255),
    payment_amount VARCHAR(255),
    processing_indicator_code VARCHAR(255),
    provider_physician_national_provider_identifier_number VARCHAR(255),
    provider_institution_tax_number VARCHAR(255)
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
    days_of_supply VARCHAR(255),
    beneficiary_code VARCHAR(255),
    part_d_event_number VARCHAR(255),
    product_service_identifier VARCHAR(255),
    patient_payment_amount VARCHAR(255),
    quantity_dispensed VARCHAR(255),
    service_date VARCHAR(255),
    total_prescription_cost VARCHAR(255)
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