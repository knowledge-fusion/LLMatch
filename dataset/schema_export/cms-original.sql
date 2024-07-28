CREATE TABLE beneficiarysummary (
    bene_birth_dt INT,
    bene_county_cd VARCHAR(255),
    bene_death_dt INT,
    bene_esrd_ind VARCHAR(255),
    bene_hi_cvrage_tot_mons INT,
    bene_hmo_cvrage_tot_mons INT,
    bene_race_cd VARCHAR(255),
    bene_sex_ident_cd VARCHAR(255),
    bene_smi_cvrage_tot_mons INT,
    benres_car REAL,
    benres_ip REAL,
    benres_op REAL,
    desynpuf_id VARCHAR(255),
    medreimb_car REAL,
    medreimb_ip REAL,
    medreimb_op REAL,
    plan_cvrg_mos_num INT,
    pppymt_car REAL,
    pppymt_ip REAL,
    pppymt_op REAL,
    sp_alzhdmta INT,
    sp_chf INT,
    sp_chrnkidn INT,
    sp_cncr INT,
    sp_copd INT,
    sp_depressn INT,
    sp_diabetes INT,
    sp_ischmcht INT,
    sp_osteoprs INT,
    sp_ra_oa INT,
    sp_state_code INT,
    sp_strketia INT
);

COMMENT ON TABLE beneficiarysummary IS 'beneficiarysummary pertains to a synthetic medicare beneficiary';';
COMMENT ON COLUMN beneficiarysummary.bene_birth_dt IS 'date of birth';
COMMENT ON COLUMN beneficiarysummary.bene_county_cd IS 'county code';
COMMENT ON COLUMN beneficiarysummary.bene_death_dt IS 'date of death';
COMMENT ON COLUMN beneficiarysummary.bene_esrd_ind IS 'end stage renal disease indicator';
COMMENT ON COLUMN beneficiarysummary.bene_hi_cvrage_tot_mons IS 'total number of months of part a coverage for the beneficiary.';
COMMENT ON COLUMN beneficiarysummary.bene_hmo_cvrage_tot_mons IS 'total number of months of hmo coverage for the beneficiary.';
COMMENT ON COLUMN beneficiarysummary.bene_race_cd IS 'beneficiary race code';
COMMENT ON COLUMN beneficiarysummary.bene_sex_ident_cd IS 'sex';
COMMENT ON COLUMN beneficiarysummary.bene_smi_cvrage_tot_mons IS 'total number of months of part b coverage for the beneficiary.';
COMMENT ON COLUMN beneficiarysummary.benres_car IS 'carrier annual beneficiary responsibility amount';
COMMENT ON COLUMN beneficiarysummary.benres_ip IS 'inpatient annual beneficiary responsibility amount';
COMMENT ON COLUMN beneficiarysummary.benres_op IS 'outpatient institutional annual beneficiary responsibility amount';
COMMENT ON COLUMN beneficiarysummary.desynpuf_id IS 'beneficiary code';
COMMENT ON COLUMN beneficiarysummary.medreimb_car IS 'carrier annual medicare reimbursement amount';
COMMENT ON COLUMN beneficiarysummary.medreimb_ip IS 'inpatient annual medicare reimbursement amount';
COMMENT ON COLUMN beneficiarysummary.medreimb_op IS 'outpatient institutional annual medicare reimbursement amount';
COMMENT ON COLUMN beneficiarysummary.plan_cvrg_mos_num IS 'total number of months of part d plan coverage for the beneficiary.';
COMMENT ON COLUMN beneficiarysummary.pppymt_car IS 'carrier annual primary payer reimbursement amount';
COMMENT ON COLUMN beneficiarysummary.pppymt_ip IS 'inpatient annual primary payer reimbursement amount';
COMMENT ON COLUMN beneficiarysummary.pppymt_op IS 'outpatient institutional annual primary payer reimbursement amount';
COMMENT ON COLUMN beneficiarysummary.sp_alzhdmta IS 'chronic condition: alzheimer or related disorders or senile';
COMMENT ON COLUMN beneficiarysummary.sp_chf IS 'chronic condition: heart failure';
COMMENT ON COLUMN beneficiarysummary.sp_chrnkidn IS 'chronic condition: chronic kidney disease';
COMMENT ON COLUMN beneficiarysummary.sp_cncr IS 'chronic condition: cancer';
COMMENT ON COLUMN beneficiarysummary.sp_copd IS 'chronic condition: chronic obstructive pulmonary disease';
COMMENT ON COLUMN beneficiarysummary.sp_depressn IS 'chronic condition: depression';
COMMENT ON COLUMN beneficiarysummary.sp_diabetes IS 'chronic condition: diabetes';
COMMENT ON COLUMN beneficiarysummary.sp_ischmcht IS 'chronic condition: ischemic heart disease';
COMMENT ON COLUMN beneficiarysummary.sp_osteoprs IS 'chronic condition: osteoporosis';
COMMENT ON COLUMN beneficiarysummary.sp_ra_oa IS 'chronic condition: rheumatoid arthritis and osteoarthritis (ra/oa)';
COMMENT ON COLUMN beneficiarysummary.sp_state_code IS 'state code';
COMMENT ON COLUMN beneficiarysummary.sp_strketia IS 'chronic condition: stroke/transient ischemic attack';

CREATE TABLE carrierclaims (
    clm_from_dt INT,
    clm_id BIGINT,
    clm_thru_dt INT,
    desynpuf_id VARCHAR(255),
    hcpcs_cd VARCHAR(255),
    icd9_dgns_cd VARCHAR(255),
    line_alowd_chrg_amt REAL,
    line_bene_prmry_pyr_pd_amt REAL,
    line_bene_ptb_ddctbl_amt REAL,
    line_coinsrnc_amt REAL,
    line_icd9_dgns_cd VARCHAR(255),
    line_nch_pmt_amt REAL,
    line_prcsg_ind_cd VARCHAR(255),
    prf_physn_npi INT,
    tax_num INT
);

COMMENT ON TABLE carrierclaims IS 'carrierclaims pertains to a synthetic physician or supplier claim';';
COMMENT ON COLUMN carrierclaims.clm_from_dt IS 'claims start date';
COMMENT ON COLUMN carrierclaims.clm_id IS 'claim id';
COMMENT ON COLUMN carrierclaims.clm_thru_dt IS 'claims end date';
COMMENT ON COLUMN carrierclaims.desynpuf_id IS 'beneficiary code';
COMMENT ON COLUMN carrierclaims.hcpcs_cd IS 'line hcfa common procedure coding system 1 – line hcfa common procedure coding system 13';
COMMENT ON COLUMN carrierclaims.icd9_dgns_cd IS 'claim diagnosis code 1 – claim diagnosis code 8';
COMMENT ON COLUMN carrierclaims.line_alowd_chrg_amt IS 'line allowed charge amount 1 – line allowed charge amount 13';
COMMENT ON COLUMN carrierclaims.line_bene_prmry_pyr_pd_amt IS 'line beneficiary primary payer paid amount 1 – line beneficiary primary payer paid amount 13';
COMMENT ON COLUMN carrierclaims.line_bene_ptb_ddctbl_amt IS 'line beneficiary part b deductible amount 1 – line beneficiary part b deductible amount 13';
COMMENT ON COLUMN carrierclaims.line_coinsrnc_amt IS 'line coinsurance amount 1 – line coinsurance amount 13';
COMMENT ON COLUMN carrierclaims.line_icd9_dgns_cd IS 'line diagnosis code 1 – line diagnosis code 13';
COMMENT ON COLUMN carrierclaims.line_nch_pmt_amt IS 'line nch payment amount 1 – line nch payment amount 13';
COMMENT ON COLUMN carrierclaims.line_prcsg_ind_cd IS 'line processing indicator code 1 – line processing indicator code13';
COMMENT ON COLUMN carrierclaims.prf_physn_npi IS 'provider physician – national provider identifier number';
COMMENT ON COLUMN carrierclaims.tax_num IS 'provider institution tax number';

CREATE TABLE inpatientclaims (
    admtng_icd9_dgns_cd VARCHAR(255),
    at_physn_npi BIGINT,
    clm_admsn_dt INT,
    clm_drg_cd VARCHAR(255),
    clm_from_dt INT,
    clm_id BIGINT,
    clm_pass_thru_per_diem_amt REAL,
    clm_pmt_amt REAL,
    clm_thru_dt INT,
    clm_utlztn_day_cnt INT,
    desynpuf_id VARCHAR(255),
    hcpcs_cd VARCHAR(255),
    icd9_dgns_cd VARCHAR(255),
    icd9_prcdr_cd VARCHAR(255),
    nch_bene_blood_ddctbl_lblty_am REAL,
    nch_bene_dschrg_dt INT,
    nch_bene_ip_ddctbl_amt REAL,
    nch_bene_pta_coinsrnc_lblty_am REAL,
    nch_prmry_pyr_clm_pd_amt REAL,
    op_physn_npi BIGINT,
    ot_physn_npi BIGINT,
    prvdr_num BIGINT,
    segment INT
);

COMMENT ON TABLE inpatientclaims IS 'inpatientclaims pertains to a synthetic inpatient claim';';
COMMENT ON COLUMN inpatientclaims.admtng_icd9_dgns_cd IS 'claim admitting diagnosis code';
COMMENT ON COLUMN inpatientclaims.at_physn_npi IS 'attending physician – national provider identifier number';
COMMENT ON COLUMN inpatientclaims.clm_admsn_dt IS 'inpatient admission date';
COMMENT ON COLUMN inpatientclaims.clm_drg_cd IS 'claim diagnosis related group code';
COMMENT ON COLUMN inpatientclaims.clm_from_dt IS 'claims start date';
COMMENT ON COLUMN inpatientclaims.clm_id IS 'claim id';
COMMENT ON COLUMN inpatientclaims.clm_pass_thru_per_diem_amt IS 'claim pass thru per diem amount';
COMMENT ON COLUMN inpatientclaims.clm_pmt_amt IS 'claim payment amount';
COMMENT ON COLUMN inpatientclaims.clm_thru_dt IS 'claims end date';
COMMENT ON COLUMN inpatientclaims.clm_utlztn_day_cnt IS 'claim utilization day count';
COMMENT ON COLUMN inpatientclaims.desynpuf_id IS 'beneficiary code';
COMMENT ON COLUMN inpatientclaims.hcpcs_cd IS 'revenue center hcfa common procedure coding system 1 – revenue center hcfa common procedure coding system 45';
COMMENT ON COLUMN inpatientclaims.icd9_dgns_cd IS 'claim diagnosis code 1 – claim diagnosis code 10';
COMMENT ON COLUMN inpatientclaims.icd9_prcdr_cd IS 'claim procedure code 1 – claim procedure code 6';
COMMENT ON COLUMN inpatientclaims.nch_bene_blood_ddctbl_lblty_am IS 'nch beneficiary blood deductible liability amount';
COMMENT ON COLUMN inpatientclaims.nch_bene_dschrg_dt IS 'inpatient discharged date';
COMMENT ON COLUMN inpatientclaims.nch_bene_ip_ddctbl_amt IS 'nch beneficiary inpatient deductible amount';
COMMENT ON COLUMN inpatientclaims.nch_bene_pta_coinsrnc_lblty_am IS 'nch beneficiary part a coinsurance liability amount';
COMMENT ON COLUMN inpatientclaims.nch_prmry_pyr_clm_pd_amt IS 'nch primary payer claim paid amount';
COMMENT ON COLUMN inpatientclaims.op_physn_npi IS 'operating physician – national provider identifier number';
COMMENT ON COLUMN inpatientclaims.ot_physn_npi IS 'other physician – national provider identifier number';
COMMENT ON COLUMN inpatientclaims.prvdr_num IS 'provider institution';
COMMENT ON COLUMN inpatientclaims.segment IS 'claim line segment';

CREATE TABLE outpatientclaims (
    admtng_icd9_dgns_cd VARCHAR(255),
    at_physn_npi BIGINT,
    clm_from_dt INT,
    clm_id BIGINT,
    clm_pmt_amt REAL,
    clm_thru_dt INT,
    desynpuf_id VARCHAR(255),
    hcpcs_cd VARCHAR(255),
    icd9_dgns_cd VARCHAR(255),
    icd9_prcdr_cd VARCHAR(255),
    nch_bene_blood_ddctbl_lblty_am REAL,
    nch_bene_ptb_coinsrnc_amt REAL,
    nch_bene_ptb_ddctbl_amt REAL,
    nch_prmry_pyr_clm_pd_amt REAL,
    op_physn_npi BIGINT,
    ot_physn_npi BIGINT,
    prvdr_num BIGINT,
    segment INT
);

COMMENT ON TABLE outpatientclaims IS 'outpatientclaims pertains to a synthetic outpatient claim';';
COMMENT ON COLUMN outpatientclaims.admtng_icd9_dgns_cd IS 'claim admitting diagnosis code';
COMMENT ON COLUMN outpatientclaims.at_physn_npi IS 'attending physician – national provider identifier number';
COMMENT ON COLUMN outpatientclaims.clm_from_dt IS 'claims start date';
COMMENT ON COLUMN outpatientclaims.clm_id IS 'claim id';
COMMENT ON COLUMN outpatientclaims.clm_pmt_amt IS 'claim payment amount';
COMMENT ON COLUMN outpatientclaims.clm_thru_dt IS 'claims end date';
COMMENT ON COLUMN outpatientclaims.desynpuf_id IS 'beneficiary code';
COMMENT ON COLUMN outpatientclaims.hcpcs_cd IS 'revenue center hcfa common procedure coding system 1 – revenue center hcfa common procedure coding system 45';
COMMENT ON COLUMN outpatientclaims.icd9_dgns_cd IS 'claim diagnosis code 1 – claim diagnosis code 10';
COMMENT ON COLUMN outpatientclaims.icd9_prcdr_cd IS 'claim procedure code 1 – claim procedure code 6';
COMMENT ON COLUMN outpatientclaims.nch_bene_blood_ddctbl_lblty_am IS 'nch beneficiary blood deductible liability amount';
COMMENT ON COLUMN outpatientclaims.nch_bene_ptb_coinsrnc_amt IS 'nch beneficiary part b coinsurance amount';
COMMENT ON COLUMN outpatientclaims.nch_bene_ptb_ddctbl_amt IS 'nch beneficiary part b deductible amount';
COMMENT ON COLUMN outpatientclaims.nch_prmry_pyr_clm_pd_amt IS 'nch primary payer claim paid amount';
COMMENT ON COLUMN outpatientclaims.op_physn_npi IS 'operating physician – national provider identifier number';
COMMENT ON COLUMN outpatientclaims.ot_physn_npi IS 'other physician – national provider identifier number';
COMMENT ON COLUMN outpatientclaims.prvdr_num IS 'provider institution';
COMMENT ON COLUMN outpatientclaims.segment IS 'claim line segment';

CREATE TABLE prescriptiondrugevents (
    days_suply_num INT,
    desynpuf_id VARCHAR(255),
    pde_id VARCHAR(255),
    prod_srvc_id VARCHAR(255),
    ptnt_pay_amt REAL,
    qty_dspnsd_num INT,
    srvc_dt INT,
    tot_rx_cst_amt REAL
);

COMMENT ON TABLE prescriptiondrugevents IS 'prescriptiondrugevents pertains to a synthetic part d event';';
COMMENT ON COLUMN prescriptiondrugevents.days_suply_num IS 'days supply';
COMMENT ON COLUMN prescriptiondrugevents.desynpuf_id IS 'beneficiary code';
COMMENT ON COLUMN prescriptiondrugevents.pde_id IS 'ccw part d event number';
COMMENT ON COLUMN prescriptiondrugevents.prod_srvc_id IS 'product service id';
COMMENT ON COLUMN prescriptiondrugevents.ptnt_pay_amt IS 'patient pay amount';
COMMENT ON COLUMN prescriptiondrugevents.qty_dspnsd_num IS 'quantity dispensed';
COMMENT ON COLUMN prescriptiondrugevents.srvc_dt IS 'rx service date';
COMMENT ON COLUMN prescriptiondrugevents.tot_rx_cst_amt IS 'gross drug cost';