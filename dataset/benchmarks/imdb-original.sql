CREATE TABLE name_basics (
    birthyear VARCHAR(45),
    deathyear VARCHAR(45),
    knownfortitles VARCHAR(128),
    nconst VARCHAR(128),
    primaryname VARCHAR(128),
    primaryprofession VARCHAR(128)
);

COMMENT ON TABLE name_basics IS 'Table containing basic information about people in IMDb';';
COMMENT ON COLUMN name_basics.birthyear IS 'birth year (YYYY)';
COMMENT ON COLUMN name_basics.deathyear IS 'death year if applicable, else ';
COMMENT ON COLUMN name_basics.knownfortitles IS 'titles the person is known for (array of tconsts)';
COMMENT ON COLUMN name_basics.nconst IS 'alphanumeric unique identifier of the name/person (string)';
COMMENT ON COLUMN name_basics.primaryname IS 'name by which the person is most often credited (string)';
COMMENT ON COLUMN name_basics.primaryprofession IS 'the top-3 professions of the person (array of strings)';

CREATE TABLE title_akas (
    attributes VARCHAR(512),
    isoriginaltitle VARCHAR(45),
    language VARCHAR(128),
    ordering VARCHAR(128),
    region VARCHAR(128),
    title TEXT,
    titleid VARCHAR(128),
    types VARCHAR(512)
);

COMMENT ON TABLE title_akas IS 'Table containing alternate titles for IMDb entries';';
COMMENT ON COLUMN title_akas.attributes IS 'Additional terms to describe this alternative title (array), not enumerated';
COMMENT ON COLUMN title_akas.isoriginaltitle IS '0: not original title. 1: original title (boolean)';
COMMENT ON COLUMN title_akas.language IS 'the language of the title (string)';
COMMENT ON COLUMN title_akas.ordering IS 'a number to uniquely identify rows for a given titleId (integer)';
COMMENT ON COLUMN title_akas.region IS 'the region for this version of the title (string)';
COMMENT ON COLUMN title_akas.title IS 'the localized title (string)';
COMMENT ON COLUMN title_akas.titleid IS 'a tconst (string, an alphanumeric unique identifier of the title)';
COMMENT ON COLUMN title_akas.types IS 'Enumerated set of attributes for this alternative title (array). One or more of the following: "alternative", "dvd", "festival", "tv", "video", "working", "original", "imdbDisplay". New values may be added in the future without warning';

CREATE TABLE title_basics (
    endyear VARCHAR(45),
    genres VARCHAR(256),
    isadult VARCHAR(32),
    originaltitle VARCHAR(512),
    primarytitle VARCHAR(512),
    runtimeminutes VARCHAR(45),
    startyear VARCHAR(45),
    tconst VARCHAR(64),
    titletype VARCHAR(64)
);

COMMENT ON TABLE title_basics IS 'Table containing basic information about IMDb titles';';
COMMENT ON COLUMN title_basics.endyear IS 'TV Series end year (YYYY). ‘\N’ for all other title types';
COMMENT ON COLUMN title_basics.genres IS 'includes up to three genres associated with the title (string array)';
COMMENT ON COLUMN title_basics.isadult IS '0: non-adult title. 1: adult title (boolean)';
COMMENT ON COLUMN title_basics.originaltitle IS 'original title (string) (in the original language)';
COMMENT ON COLUMN title_basics.primarytitle IS 'the more popular title (string) (the title used by the filmmakers on promotional materials at the point of release)';
COMMENT ON COLUMN title_basics.runtimeminutes IS 'primary runtime of the title (integer, in minutes)';
COMMENT ON COLUMN title_basics.startyear IS 'represents the release year of a title (YYYY). In the case of TV Series, it is the series start year';
COMMENT ON COLUMN title_basics.tconst IS 'alphanumeric unique identifier of the title (string)';
COMMENT ON COLUMN title_basics.titletype IS 'the type/format of the title (string) (e.g. movie, short, tvseries, tvepisode, video, etc)';

CREATE TABLE title_crew (
    directors TEXT,
    tconst VARCHAR(128),
    writers TEXT
);

COMMENT ON TABLE title_crew IS 'Table containing crew information for IMDb titles';';
COMMENT ON COLUMN title_crew.directors IS 'director(s) of the given title (array of nconsts)';
COMMENT ON COLUMN title_crew.tconst IS 'alphanumeric unique identifier of the title (string)';
COMMENT ON COLUMN title_crew.writers IS 'writer(s) of the given title (array of nconsts)';

CREATE TABLE title_episode (
    episodenumber TEXT,
    parenttconst VARCHAR(128),
    seasonnumber TEXT,
    tconst VARCHAR(128)
);

COMMENT ON TABLE title_episode IS 'Table containing episode information for TV series in IMDb';';
COMMENT ON COLUMN title_episode.episodenumber IS 'episode number of the tconst in the TV series (integer)';
COMMENT ON COLUMN title_episode.parenttconst IS 'alphanumeric identifier of the parent TV Series (string)';
COMMENT ON COLUMN title_episode.seasonnumber IS 'season number the episode belongs to (integer)';
COMMENT ON COLUMN title_episode.tconst IS 'alphanumeric identifier of episode (string)';

CREATE TABLE title_principals (
    category TEXT,
    characters TEXT,
    job TEXT,
    nconst VARCHAR(128),
    ordering VARCHAR(45),
    tconst VARCHAR(128)
);

COMMENT ON TABLE title_principals IS 'Table containing principal cast and crew information for IMDb titles';';
COMMENT ON COLUMN title_principals.category IS 'the category of job that person was in (string)';
COMMENT ON COLUMN title_principals.characters IS 'the name of the character played if applicable, else ';
COMMENT ON COLUMN title_principals.job IS 'the specific job title if applicable, else ';
COMMENT ON COLUMN title_principals.nconst IS 'alphanumeric unique identifier of the name/person (string)';
COMMENT ON COLUMN title_principals.ordering IS 'a number to uniquely identify rows for a given titleId (integer)';
COMMENT ON COLUMN title_principals.tconst IS 'alphanumeric unique identifier of the title (string)';

CREATE TABLE title_ratings (
    averagerating VARCHAR(45),
    numvotes VARCHAR(45),
    tconst VARCHAR(128)
);

COMMENT ON TABLE title_ratings IS 'Table containing user ratings for IMDb titles';';
COMMENT ON COLUMN title_ratings.averagerating IS 'weighted average of all the individual user ratings (float)';
COMMENT ON COLUMN title_ratings.numvotes IS 'number of votes the title has received (integer)';
COMMENT ON COLUMN title_ratings.tconst IS 'alphanumeric unique identifier of the title (string)';