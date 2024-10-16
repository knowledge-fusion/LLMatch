CREATE TABLE allergies (
    code VARCHAR(255),
    description VARCHAR(255),
    encounter VARCHAR(255),
    patient VARCHAR(255),
    start VARCHAR(255),
    stop VARCHAR(255)
);

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

CREATE TABLE conditions (
    code VARCHAR(255),
    description VARCHAR(255),
    encounter VARCHAR(255),
    patient VARCHAR(255),
    start VARCHAR(255),
    stop VARCHAR(255)
);

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

CREATE TABLE immunizations (
    code VARCHAR(255),
    cost VARCHAR(255),
    date VARCHAR(255),
    description VARCHAR(255),
    encounter VARCHAR(255),
    patient VARCHAR(255)
);

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
