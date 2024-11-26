CREATE TABLE consultation (
    consdate DATE,
    consid TEXT,
    consmedcodeid TEXT,
    conssourceid TEXT,
    cprdconstype INTEGER,
    enterdate DATE,
    patid TEXT,
    pracid INTEGER,
    staffid TEXT
);


CREATE TABLE drugissue (
    dosageid TEXT,
    drugrecid TEXT,
    duration INTEGER,
    enterdate DATE,
    estnhscost DECIMAL,
    issuedate DATE,
    issueid TEXT,
    patid TEXT,
    pracid INTEGER,
    probobsid TEXT,
    prodcodeid TEXT,
    quantity DECIMAL,
    quantunitid INTEGER,
    staffid TEXT
);


CREATE TABLE observation (
    consid TEXT,
    enterdate DATE,
    medcodeid TEXT,
    numrangehigh NUMERIC,
    numrangelow NUMERIC,
    numunitid INTEGER,
    obsdate DATE,
    obsid TEXT,
    obstypeid INTEGER,
    parentobsid TEXT,
    patid TEXT,
    pracid INTEGER,
    probobsid TEXT,
    staffid TEXT,
    value NUMERIC
);


CREATE TABLE patient (
    acceptable INTEGER,
    cprd_ddate DATE,
    emis_ddate DATE,
    gender INTEGER,
    mob INTEGER,
    patid TEXT,
    patienttypeid INTEGER,
    pracid INTEGER,
    regenddate DATE,
    regstartdate DATE,
    usualgpstaffid TEXT,
    yob INTEGER
);


CREATE TABLE practice (
    lcd DATE,
    pracid INTEGER,
    region INTEGER,
    uts DATE
);


CREATE TABLE problem (
    expduration INTEGER,
    lastrevdate DATE,
    lastrevstaffid TEXT,
    obsid TEXT,
    parentprobobsid TEXT,
    parentprobrelid INTEGER,
    patid TEXT,
    pracid INTEGER,
    probenddate DATE,
    probstatusid INTEGER,
    signid INTEGER
);


CREATE TABLE referral (
    obsid TEXT,
    patid TEXT,
    pracid INTEGER,
    refmodeid INTEGER,
    refservicetypeid INTEGER,
    refsourceorgid INTEGER,
    reftargetorgid INTEGER,
    refurgencyid INTEGER
);


CREATE TABLE staff (
    jobcatid INTEGER,
    pracid INTEGER,
    staffid TEXT
);