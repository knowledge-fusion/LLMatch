
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
    benres_car  REAL,
    benres_ip  REAL,
    benres_op  REAL,
    desynpuf_id VARCHAR(255),
    medreimb_car  REAL,
    medreimb_ip  REAL,
    medreimb_op  REAL,
    plan_cvrg_mos_num INT,
    pppymt_car  REAL,
    pppymt_ip  REAL,
    pppymt_op  REAL,
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
    nch_bene_blood_ddctbl_lblty_am REAL,
    nch_prmry_pyr_clm_pd_amt REAL,
    clm_pmt_amt REAL,
    op_physn_npi BIGINT,
    ot_physn_npi BIGINT,
    prvdr_num BIGINT,
    segment INT
);


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
    clm_pmt_amt REAL,
    op_physn_npi BIGINT,
    ot_physn_npi BIGINT,
    prvdr_num BIGINT,
    segment INT
);


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
