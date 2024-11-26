-- MySQL dump 10.13  Distrib 8.0.17, for macos10.14 (x86_64)
--
-- Host: localhost    Database: imdbnew
-- ------------------------------------------------------
-- Server version	8.0.19


--
-- Table structure for table name_basics
--

DROP TABLE IF EXISTS name_basics;


CREATE TABLE name_basics (
  nconst varchar(128) DEFAULT NULL,
  primaryname varchar(128) DEFAULT NULL,
  birthyear varchar(45) DEFAULT NULL,
  deathyear varchar(45) DEFAULT NULL,
  primaryprofession varchar(128) DEFAULT NULL,
  knownfortitles varchar(128) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4;


--
-- Table structure for table title_akas
--

DROP TABLE IF EXISTS title_akas;


CREATE TABLE title_akas (
  titleid varchar(128) DEFAULT NULL,
  ordering varchar(128) DEFAULT NULL,
  title text,
  region varchar(128) DEFAULT NULL,
  language varchar(128) DEFAULT NULL,
  types varchar(512) DEFAULT NULL,
  attributes varchar(512) DEFAULT NULL,
  isOriginalTitle varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4;


--
-- Table structure for table title_basics
--

DROP TABLE IF EXISTS title_basics;


CREATE TABLE title_basics (
  tconst varchar(64) NOT NULL,
  titletype varchar(64) DEFAULT NULL,
  primarytitle varchar(512) DEFAULT NULL,
  originaltitle varchar(512) DEFAULT NULL,
  isadult varchar(32) DEFAULT NULL,
  startyear varchar(45) DEFAULT NULL,
  endyear varchar(45) DEFAULT NULL,
  runtimeminutes varchar(45) DEFAULT NULL,
  genres varchar(256) DEFAULT NULL,
  PRIMARY KEY (tconst)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4;


--
-- Table structure for table title_crew
--

DROP TABLE IF EXISTS title_crew;


CREATE TABLE title_crew (
  tconst varchar(128) DEFAULT NULL,
  directors text,
  writers text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4;


--
-- Table structure for table title_episode
--

DROP TABLE IF EXISTS title_episode;


CREATE TABLE title_episode (
  tconst varchar(128) NOT NULL,
  parenttconst varchar(128) DEFAULT NULL,
  seasonnumber text,
  episodenumber text,
  PRIMARY KEY (tconst)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4;


--
-- Table structure for table title_principals
--

DROP TABLE IF EXISTS title_principals;


CREATE TABLE title_principals (
  tconst varchar(128) DEFAULT NULL,
  ordering varchar(45) DEFAULT NULL,
  nconst varchar(128) DEFAULT NULL,
  category text,
  job text,
  characters text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4;


--
-- Table structure for table title_ratings
--

DROP TABLE IF EXISTS title_ratings;


CREATE TABLE title_ratings (
  tconst varchar(128) NOT NULL,
  averagerating varchar(45) DEFAULT NULL,
  numvotes varchar(45) DEFAULT NULL,
  PRIMARY KEY (tconst)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4;

