CREATE TABLE name_basics (
    birthyear VARCHAR(45),
    deathyear VARCHAR(45),
    knownfortitles VARCHAR(128),
    nconst VARCHAR(128),
    primaryname VARCHAR(128),
    primaryprofession VARCHAR(128)
);

COMMENT ON TABLE name_basics IS 'contains the following basic information for names.';
COMMENT ON COLUMN name_basics.birthyear IS 'in yyyy format.';
COMMENT ON COLUMN name_basics.deathyear IS 'in yyyy format if applicable, else '\n'.';
COMMENT ON COLUMN name_basics.knownfortitles IS 'titles the person is known for.';
COMMENT ON COLUMN name_basics.nconst IS 'alphanumeric unique identifier of the name/person.';
COMMENT ON COLUMN name_basics.primaryname IS 'name by which the person is most often credited.';
COMMENT ON COLUMN name_basics.primaryprofession IS 'the top-3 professions of the person.';

CREATE TABLE title_akas (
    attributes VARCHAR(512),
    isoriginal VARCHAR(45),
    language VARCHAR(128),
    ordering VARCHAR(128),
    region VARCHAR(128),
    title TEXT,
    titleid VARCHAR(128),
    types VARCHAR(512)
);

COMMENT ON TABLE title_akas IS 'contains the following common information for titles.';
COMMENT ON COLUMN title_akas.attributes IS 'additional terms to describe this alternative title, not enumerated.';
COMMENT ON COLUMN title_akas.isoriginal IS 'is original';
COMMENT ON COLUMN title_akas.language IS 'the language of the title.';
COMMENT ON COLUMN title_akas.ordering IS 'a number to uniquely identify rows for a given titleid.';
COMMENT ON COLUMN title_akas.region IS 'the region for this version of the title.';
COMMENT ON COLUMN title_akas.title IS 'the localized title.';
COMMENT ON COLUMN title_akas.titleid IS 'a tconst, an alphanumeric unique identifier of the title.';
COMMENT ON COLUMN title_akas.types IS 'enumerated set of attributes for this alternative title. one or more of the following: "alternative", "dvd", "festival", "tv", "video", "working", "original", "imdbdisplay". new values may be added in the future without warning.';

CREATE TABLE title_basics (
    endyear VARCHAR(45),
    genres VARCHAR(256),
    isadult VARCHAR(32),
    originaltitle VARCHAR(512),
    primarytitle VARCHAR(512),
    runtime VARCHAR(45),
    startyear VARCHAR(45),
    tconst VARCHAR(64),
    titletype VARCHAR(64)
);

COMMENT ON TABLE title_basics IS 'contains the following basic information for titles.';
COMMENT ON COLUMN title_basics.endyear IS 'tv series end year. ‘\n’ for all other title types.';
COMMENT ON COLUMN title_basics.genres IS 'includes up to three genres associated with the title.';
COMMENT ON COLUMN title_basics.isadult IS '0: non-adult title';
COMMENT ON COLUMN title_basics.originaltitle IS 'original title, in the original language.';
COMMENT ON COLUMN title_basics.primarytitle IS 'the more popular title / the title used by the filmmakers on promotional materials at the point of release.';
COMMENT ON COLUMN title_basics.runtime IS 'duration of the title';
COMMENT ON COLUMN title_basics.startyear IS 'represents the release year of a title. in the case of tv series, it is the series start year.';
COMMENT ON COLUMN title_basics.tconst IS 'alphanumeric unique identifier of the title.';
COMMENT ON COLUMN title_basics.titletype IS 'the type/format of the title (e.g. movie, short, tvseries, tvepisode, video, etc).';

CREATE TABLE title_crew (
    directors TEXT,
    tconst VARCHAR(128),
    writers TEXT
);

COMMENT ON TABLE title_crew IS 'contains the director and writer information for all the titles in imdb.';
COMMENT ON COLUMN title_crew.directors IS 'director(s) of the given title.';
COMMENT ON COLUMN title_crew.tconst IS 'alphanumeric unique identifier of the title';
COMMENT ON COLUMN title_crew.writers IS 'writer(s) of the given title.';

CREATE TABLE title_episode (
    episodenumber TEXT,
    parenttconst VARCHAR(128),
    seasonnumber TEXT,
    tconst VARCHAR(128)
);

COMMENT ON TABLE title_episode IS 'contains the tv episode information.';
COMMENT ON COLUMN title_episode.episodenumber IS 'episode number of the tconst in the tv series.';
COMMENT ON COLUMN title_episode.parenttconst IS 'alphanumeric identifier of the parent tv series.';
COMMENT ON COLUMN title_episode.seasonnumber IS 'season number the episode belongs to.';
COMMENT ON COLUMN title_episode.tconst IS 'alphanumeric identifier of episode.';

CREATE TABLE title_principals (
    category TEXT,
    characters TEXT,
    job TEXT,
    nconst VARCHAR(128),
    ordering VARCHAR(45),
    tconst VARCHAR(128)
);

COMMENT ON TABLE title_principals IS 'contains the principal cast/crew for titles.';
COMMENT ON COLUMN title_principals.category IS 'the category of job that person was in.';
COMMENT ON COLUMN title_principals.characters IS 'the name of the character played if applicable, else '\n'.';
COMMENT ON COLUMN title_principals.job IS 'the specific job title if applicable, else '\n'.';
COMMENT ON COLUMN title_principals.nconst IS 'alphanumeric unique identifier of the name/person.';
COMMENT ON COLUMN title_principals.ordering IS 'a number to uniquely identify rows for a given titleid.';
COMMENT ON COLUMN title_principals.tconst IS 'alphanumeric unique identifier of the title.';

CREATE TABLE title_ratings (
    averagerating VARCHAR(45),
    numvotes VARCHAR(45),
    tconst VARCHAR(128)
);

COMMENT ON TABLE title_ratings IS 'contains the imdb rating and votes information for titles.';
COMMENT ON COLUMN title_ratings.averagerating IS 'weighted average of all the individual user ratings.';
COMMENT ON COLUMN title_ratings.numvotes IS 'number of votes the title has received.';
COMMENT ON COLUMN title_ratings.tconst IS 'alphanumeric unique identifier of the title.';