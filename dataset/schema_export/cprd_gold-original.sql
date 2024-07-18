CREATE TABLE clinical (
    adid VARCHAR(50),
    consid VARCHAR(50),
    constype VARCHAR(50),
    enttype VARCHAR(50),
    episode VARCHAR(50),
    eventdate VARCHAR(50),
    medcode VARCHAR(50),
    patid VARCHAR(50),
    sctdescid VARCHAR(50),
    sctexpression VARCHAR(50),
    sctid VARCHAR(50),
    sctisassured VARCHAR(50),
    sctisindicative VARCHAR(50),
    sctmaptype VARCHAR(50),
    sctmapversion VARCHAR(50),
    staffid VARCHAR(50),
    sysdate VARCHAR(50)
);

CREATE TABLE consultation (
    consid VARCHAR(50),
    constype VARCHAR(50),
    duration VARCHAR(50),
    eventdate VARCHAR(50),
    patid VARCHAR(50),
    staffid VARCHAR(50),
    sysdate VARCHAR(50)
);

CREATE TABLE immunisation (
    batch VARCHAR(50),
    compound VARCHAR(50),
    consid VARCHAR(50),
    constype VARCHAR(50),
    eventdate VARCHAR(50),
    immstype VARCHAR(50),
    medcode VARCHAR(50),
    method VARCHAR(50),
    patid VARCHAR(50),
    reason VARCHAR(50),
    sctdescid VARCHAR(50),
    sctexpression VARCHAR(50),
    sctid VARCHAR(50),
    sctisassured VARCHAR(50),
    sctisindicative VARCHAR(50),
    sctmaptype VARCHAR(50),
    sctmapversion VARCHAR(50),
    source VARCHAR(50),
    staffid VARCHAR(50),
    stage VARCHAR(50),
    status VARCHAR(50),
    sysdate VARCHAR(50)
);

CREATE TABLE patient (
    accept VARCHAR(50),
    capsup VARCHAR(50),
    chsdate VARCHAR(50),
    chsreg VARCHAR(50),
    crd VARCHAR(50),
    deathdate VARCHAR(50),
    famnum VARCHAR(50),
    frd VARCHAR(50),
    gender VARCHAR(50),
    internal VARCHAR(50),
    marital VARCHAR(50),
    mob VARCHAR(50),
    patid VARCHAR(50),
    prescr VARCHAR(50),
    reggap VARCHAR(50),
    regstat VARCHAR(50),
    tod VARCHAR(50),
    toreason VARCHAR(50),
    vmid VARCHAR(50),
    yob VARCHAR(50)
);

CREATE TABLE practice (
    lcd VARCHAR(50),
    pracid VARCHAR(50),
    region VARCHAR(50),
    uts VARCHAR(50)
);

CREATE TABLE referral (
    attendance VARCHAR(50),
    consid VARCHAR(50),
    constype VARCHAR(50),
    eventdate VARCHAR(50),
    fhsaspec VARCHAR(50),
    inpatient VARCHAR(50),
    medcode VARCHAR(50),
    nhsspec VARCHAR(50),
    patid VARCHAR(50),
    sctdescid VARCHAR(50),
    sctexpression VARCHAR(50),
    sctid VARCHAR(50),
    sctisassured VARCHAR(50),
    sctisindicative VARCHAR(50),
    sctmaptype VARCHAR(50),
    sctmapversion VARCHAR(50),
    source VARCHAR(50),
    staffid VARCHAR(50),
    sysdate VARCHAR(50),
    urgency VARCHAR(50)
);

CREATE TABLE staff (
    gender VARCHAR(50),
    role VARCHAR(50),
    staffid VARCHAR(50)
);

CREATE TABLE test (
    consid VARCHAR(50),
    constype VARCHAR(50),
    enttype VARCHAR(50),
    eventdate VARCHAR(50),
    medcode VARCHAR(50),
    patid VARCHAR(50),
    sctdescid VARCHAR(50),
    sctexpression VARCHAR(50),
    sctid VARCHAR(50),
    sctisassured VARCHAR(50),
    sctisindicative VARCHAR(50),
    sctmaptype VARCHAR(50),
    sctmapversion VARCHAR(50),
    staffid VARCHAR(50),
    sysdate VARCHAR(50)
);

CREATE TABLE therapy (
    bnfcode VARCHAR(50),
    consid VARCHAR(50),
    dosageid VARCHAR(50),
    drugdmd VARCHAR(50),
    eventdate VARCHAR(50),
    issueseq VARCHAR(50),
    numdays VARCHAR(50),
    numpacks VARCHAR(50),
    packtype VARCHAR(50),
    patid VARCHAR(50),
    prn VARCHAR(50),
    prodcode VARCHAR(50),
    qty VARCHAR(50),
    staffid VARCHAR(50),
    sysdate VARCHAR(50)
);