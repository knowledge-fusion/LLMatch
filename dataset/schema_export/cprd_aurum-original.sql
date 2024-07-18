CREATE TABLE consultation (
    consdate VARCHAR(50),
    consid VARCHAR(50),
    consmedcodeid VARCHAR(50),
    conssourceid VARCHAR(50),
    cprdconstype VARCHAR(50),
    enterdate VARCHAR(50),
    patid VARCHAR(50),
    pracid VARCHAR(50),
    staffid VARCHAR(50)
);

CREATE TABLE drugissue (
    dosageid VARCHAR(50),
    drugrecid VARCHAR(50),
    duration VARCHAR(50),
    enterdate VARCHAR(50),
    estnhscost VARCHAR(50),
    issuedate VARCHAR(50),
    issueid VARCHAR(50),
    patid VARCHAR(50),
    pracid VARCHAR(50),
    probobsid VARCHAR(50),
    prodcodeid VARCHAR(50),
    quantity VARCHAR(50),
    quantunitid VARCHAR(50),
    staffid VARCHAR(50)
);

CREATE TABLE observation (
    consid VARCHAR(50),
    enterdate VARCHAR(50),
    medcodeid VARCHAR(50),
    numrangehigh VARCHAR(50),
    numrangelow VARCHAR(50),
    numunitid VARCHAR(50),
    obsdate VARCHAR(50),
    obsid VARCHAR(50),
    obstypeid VARCHAR(50),
    parentobsid VARCHAR(50),
    patid VARCHAR(50),
    pracid VARCHAR(50),
    probobsid VARCHAR(50),
    staffid VARCHAR(50),
    value VARCHAR(50)
);

CREATE TABLE patient (
    acceptable VARCHAR(50),
    cprd_ddate VARCHAR(50),
    emis_ddate VARCHAR(50),
    gender VARCHAR(50),
    mob VARCHAR(50),
    patid VARCHAR(50),
    patienttypeid VARCHAR(50),
    pracid VARCHAR(50),
    regenddate VARCHAR(50),
    regstartdate VARCHAR(50),
    usualgpstaffid VARCHAR(50),
    yob VARCHAR(50)
);

CREATE TABLE practice (
    lcd VARCHAR(50),
    pracid VARCHAR(50),
    region VARCHAR(50),
    uts VARCHAR(50)
);

CREATE TABLE problem (
    expduration VARCHAR(50),
    lastrevdate VARCHAR(50),
    lastrevstaffid VARCHAR(50),
    obsid VARCHAR(50),
    parentprobobsid VARCHAR(50),
    parentprobrelid VARCHAR(50),
    patid VARCHAR(50),
    pracid VARCHAR(50),
    probenddate VARCHAR(50),
    probstatusid VARCHAR(50),
    signid VARCHAR(50)
);

CREATE TABLE referral (
    obsid VARCHAR(50),
    patid VARCHAR(50),
    pracid VARCHAR(50),
    refmodeid VARCHAR(50),
    refservicetypeid VARCHAR(50),
    refsourceorgid VARCHAR(50),
    reftargetorgid VARCHAR(50),
    refurgencyid VARCHAR(50)
);

CREATE TABLE staff (
    jobcatid VARCHAR(50),
    pracid VARCHAR(50),
    staffid VARCHAR(50)
);