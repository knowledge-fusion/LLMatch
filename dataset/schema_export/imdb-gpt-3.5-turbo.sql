CREATE TABLE alternate_titles (
    additional_terms VARCHAR(512),
    is_original_title VARCHAR(45),
    title_language VARCHAR(128),
    title_order VARCHAR(128),
    title_region VARCHAR(128),
    localized_title TEXT,
    title_identifier VARCHAR(128),
    title_attributes VARCHAR(512)
);

COMMENT ON TABLE alternate_titles IS 'This table contains a list of alternate titles for IMDb entries.';
COMMENT ON COLUMN alternate_titles.additional_terms IS 'Additional terms to describe this alternative title (array), not enumerated. Type: Varchar(512)';
COMMENT ON COLUMN alternate_titles.is_original_title IS '0: not original title. 1: original title (boolean). Type: Varchar(45)';
COMMENT ON COLUMN alternate_titles.title_language IS 'The language of the title (string). Type: Varchar(128)';
COMMENT ON COLUMN alternate_titles.title_order IS 'A number to uniquely identify rows for a given titleId (integer). Type: Varchar(128)';
COMMENT ON COLUMN alternate_titles.title_region IS 'The region for this version of the title (string). Type: Varchar(128)';
COMMENT ON COLUMN alternate_titles.localized_title IS 'The localized title (string). Type: Text';
COMMENT ON COLUMN alternate_titles.title_identifier IS 'A tconst (string, an alphanumeric unique identifier of the title). Type: Varchar(128)';
COMMENT ON COLUMN alternate_titles.title_attributes IS 'Enumerated set of attributes for this alternative title (array). One or more of the following: "alternative", "dvd", "festival", "tv", "video", "working", "original", "imdbDisplay". New values may be added in the future without warning. Type: Varchar(512)';

CREATE TABLE person_information (
    year_of_birth VARCHAR(45),
    year_of_death VARCHAR(45),
    known_for VARCHAR(128),
    person_identifier VARCHAR(128),
    credited_name VARCHAR(128),
    top_professions VARCHAR(128)
);

COMMENT ON TABLE person_information IS 'This table contains basic information about people listed in IMDb.';
COMMENT ON COLUMN person_information.year_of_birth IS 'The year of birth of the person. Type: String';
COMMENT ON COLUMN person_information.year_of_death IS 'The year of death of the person if applicable. Else NULL. Type: String';
COMMENT ON COLUMN person_information.known_for IS 'An array of title identifiers for the titles the person is known for. Type: String';
COMMENT ON COLUMN person_information.person_identifier IS 'Primary Key. Alphanumeric unique identifier for each person. Type: String';
COMMENT ON COLUMN person_information.credited_name IS 'The name by which the person is most commonly credited. Type: String';
COMMENT ON COLUMN person_information.top_professions IS 'An array of the top 3 professions of the person. Type: String';

CREATE TABLE title_cast_and_crew (
    job_category TEXT,
    character_name TEXT,
    job_title TEXT,
    person_identifier VARCHAR(128),
    title_order VARCHAR(45),
    title_identifier VARCHAR(128)
);

COMMENT ON TABLE title_cast_and_crew IS 'This table contains information about the principal cast and crew for IMDb titles';
COMMENT ON COLUMN title_cast_and_crew.job_category IS 'The category of job that the person was in. Type: Text';
COMMENT ON COLUMN title_cast_and_crew.character_name IS 'The name of the character played if applicable. Type: Text';
COMMENT ON COLUMN title_cast_and_crew.job_title IS 'The specific job title if applicable. Type: Text';
COMMENT ON COLUMN title_cast_and_crew.person_identifier IS 'Alphanumeric unique identifier of the name/person. Type: Varchar(128)';
COMMENT ON COLUMN title_cast_and_crew.title_order IS 'A number to uniquely identify rows for a given titleId. Type: Varchar(45)';
COMMENT ON COLUMN title_cast_and_crew.title_identifier IS 'Alphanumeric unique identifier of the title. Type: Varchar(128)';

CREATE TABLE title_crew_information (
    director_identifiers TEXT,
    title_identifier VARCHAR(128),
    writer_identifiers TEXT
);

COMMENT ON TABLE title_crew_information IS 'This table contains crew information for IMDb titles.';
COMMENT ON COLUMN title_crew_information.director_identifiers IS 'The director(s) of the given title (array of nconsts). Type: Text';
COMMENT ON COLUMN title_crew_information.title_identifier IS 'Alphanumeric unique identifier of the title. Type: varchar(128)';
COMMENT ON COLUMN title_crew_information.writer_identifiers IS 'The writer(s) of the given title (array of nconsts). Type: Text';

CREATE TABLE title_information (
    end_year VARCHAR(45),
    associated_genres VARCHAR(256),
    adult VARCHAR(32),
    original_title VARCHAR(512),
    popular_title VARCHAR(512),
    runtime_minutes VARCHAR(45),
    release_year VARCHAR(45),
    title_identifier VARCHAR(64),
    title_format VARCHAR(64)
);

COMMENT ON TABLE title_information IS 'This table contains basic information about IMDb titles.';
COMMENT ON COLUMN title_information.end_year IS 'TV Series end year in YYYY format. 'NULL' for all other title types. Type: Varchar(45)';
COMMENT ON COLUMN title_information.associated_genres IS 'This column includes up to three genres associated with the title (string array). Type: Varchar(256)';
COMMENT ON COLUMN title_information.adult IS 'This column indicates if the title is adult. 0: non-adult title. 1: adult title. Type: Varchar(32)';
COMMENT ON COLUMN title_information.original_title IS 'The original title of a title in the original language. Type: Varchar(512)';
COMMENT ON COLUMN title_information.popular_title IS 'The more popular title used by filmmakers on promotional materials at the point of release. Type: Varchar(512)';
COMMENT ON COLUMN title_information.runtime_minutes IS 'Primary runtime of the title in minutes. Type: Varchar(45)';
COMMENT ON COLUMN title_information.release_year IS 'Represents the release year of a title (YYYY). In the case of TV Series, it is the series start year. Type: Varchar(45)';
COMMENT ON COLUMN title_information.title_identifier IS 'Alphanumeric unique identifier of the title. Type: Varchar(64)';
COMMENT ON COLUMN title_information.title_format IS 'The format of the title (e.g. movie, short, tvseries, tvepisode, video, etc). Type: Varchar(64)';

CREATE TABLE title_rating_information (
    weighted_average_rating VARCHAR(45),
    vote_count VARCHAR(45),
    title_identifier VARCHAR(128)
);

COMMENT ON TABLE title_rating_information IS 'This table contains user ratings for IMDb titles.';
COMMENT ON COLUMN title_rating_information.weighted_average_rating IS 'The weighted average of all individual user ratings. Type: Float';
COMMENT ON COLUMN title_rating_information.vote_count IS 'The number of votes the title has received. Type: Integer';
COMMENT ON COLUMN title_rating_information.title_identifier IS 'Alphanumeric unique identifier of the title. Type: Text';

CREATE TABLE tv_series_episode (
    episode_number TEXT,
    parent_identifier VARCHAR(128),
    season_number TEXT,
    episode_identifier VARCHAR(128)
);

COMMENT ON TABLE tv_series_episode IS 'This table contains episode information for TV series in IMDb.';
COMMENT ON COLUMN tv_series_episode.episode_number IS 'The episode number of the tconst in the TV series. Type: Text';
COMMENT ON COLUMN tv_series_episode.parent_identifier IS 'Alphanumeric identifier of the parent TV Series. Type: Text';
COMMENT ON COLUMN tv_series_episode.season_number IS 'The season number the episode belongs to. Type: Text';
COMMENT ON COLUMN tv_series_episode.episode_identifier IS 'Alphanumeric identifier of the episode. Type: Text';