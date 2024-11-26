CREATE TABLE clinical (
    adid INTEGER,
    consid INTEGER,
    constype INTEGER,
    enttype INTEGER,
    episode INTEGER,
    eventdate DATE,
    medcode INTEGER,
    patid TEXT,
    sctdescid TEXT,
    sctexpression TEXT,
    sctid TEXT,
    sctisassured BOOLEAN,
    sctisindicative BOOLEAN,
    sctmaptype INTEGER,
    sctmapversion INTEGER,
    staffid INTEGER,
    sysdate DATE
);

CREATE TABLE consultation (
    consid INTEGER,
    constype INTEGER,
    duration INTEGER,
    eventdate DATE,
    patid TEXT,
    staffid INTEGER,
    sysdate DATE
);

CREATE TABLE immunisation (
    batch INTEGER,
    compound INTEGER,
    consid INTEGER,
    constype INTEGER,
    eventdate DATE,
    immstype INTEGER,
    medcode INTEGER,
    method INTEGER,
    patid TEXT,
    reason INTEGER,
    sctdescid TEXT,
    sctexpression TEXT,
    sctid TEXT,
    sctisassured BOOLEAN,
    sctisindicative BOOLEAN,
    sctmaptype INTEGER,
    sctmapversion INTEGER,
    source INTEGER,
    staffid INTEGER,
    stage INTEGER,
    status INTEGER,
    sysdate DATE
);

CREATE TABLE patient (
    accept INTEGER,
    capsup INTEGER,
    chsdate DATE,
    chsreg INTEGER,
    crd DATE,
    deathdate DATE,
    famnum INTEGER,
    frd DATE,
    gender INTEGER,
    internal INTEGER,
    marital INTEGER,
    mob INTEGER,
    patid TEXT,
    prescr INTEGER,
    reggap INTEGER,
    regstat INTEGER,
    tod DATE,
    toreason INTEGER,
    vmid INTEGER,
    yob INTEGER
);

CREATE TABLE practice (
    lcd DATE,
    pracid INTEGER,
    region INTEGER,
    uts DATE
);

CREATE TABLE referral (
    attendance INTEGER,
    consid INTEGER,
    constype INTEGER,
    eventdate DATE,
    fhsaspec INTEGER,
    inpatient INTEGER,
    medcode INTEGER,
    nhsspec INTEGER,
    patid TEXT,
    sctdescid TEXT,
    sctexpression TEXT,
    sctid TEXT,
    sctisassured BOOLEAN,
    sctisindicative BOOLEAN,
    sctmaptype INTEGER,
    sctmapversion INTEGER,
    source INTEGER,
    staffid INTEGER,
    sysdate DATE,
    urgency INTEGER
);

CREATE TABLE staff (
    gender INTEGER,
    role INTEGER,
    staffid INTEGER
);

CREATE TABLE test (
    consid INTEGER,
    constype INTEGER,
    enttype INTEGER,
    eventdate DATE,
    medcode INTEGER,
    patid TEXT,
    sctdescid TEXT,
    sctexpression TEXT,
    sctid TEXT,
    sctisassured BOOLEAN,
    sctisindicative BOOLEAN,
    sctmaptype INTEGER,
    sctmapversion INTEGER,
    staffid INTEGER,
    sysdate DATE
);

CREATE TABLE therapy (
    bnfcode INTEGER,
    consid INTEGER,
    dosageid TEXT,
    drugdmd TEXT,
    eventdate DATE,
    issueseq INTEGER,
    numdays INTEGER,
    numpacks INTEGER,
    packtype INTEGER,
    patid TEXT,
    prn BOOLEAN,
    prodcode INTEGER,
    qty INTEGER,
    staffid INTEGER,
    sysdate DATE
);