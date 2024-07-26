CREATE TABLE alternate_titles (
    additional_terms VARCHAR(512),
    is_original_title VARCHAR(45),
    title_language VARCHAR(128),
    row_identifier VARCHAR(128),
    title_region VARCHAR(128),
    localized_title TEXT,
    title_identifier VARCHAR(128),
    title_attributes VARCHAR(512)
);

COMMENT ON TABLE alternate_titles IS 'This table contains alternate titles for IMDb entries.';
COMMENT ON COLUMN alternate_titles.additional_terms IS 'Additional terms to describe this alternate title. Type: Text';
COMMENT ON COLUMN alternate_titles.is_original_title IS 'Indicator if it is the original title (0: not original, 1: original). Type: Boolean';
COMMENT ON COLUMN alternate_titles.title_language IS 'The language of the title. Type: Text';
COMMENT ON COLUMN alternate_titles.row_identifier IS 'A number to uniquely identify rows for a given title. Type: Integer';
COMMENT ON COLUMN alternate_titles.title_region IS 'The region for this version of the title. Type: Text';
COMMENT ON COLUMN alternate_titles.localized_title IS 'The localized title. Type: Text';
COMMENT ON COLUMN alternate_titles.title_identifier IS 'A unique identifier for the title. Type: Text';
COMMENT ON COLUMN alternate_titles.title_attributes IS 'Set of attributes for this alternate title. Type: Text';

CREATE TABLE people_basic_information (
    birth_year VARCHAR(45),
    death_year VARCHAR(45),
    known_titles VARCHAR(128),
    name_identifier VARCHAR(128),
    primary_name VARCHAR(128),
    primary_profession VARCHAR(128)
);

COMMENT ON TABLE people_basic_information IS 'This table contains basic information about people in IMDb, including their birth year, death year, known titles, primary name, and profession.';
COMMENT ON COLUMN people_basic_information.birth_year IS 'The birth year of the person in YYYY format. Type: Text';
COMMENT ON COLUMN people_basic_information.death_year IS 'The death year of the person in YYYY format if applicable, else left blank. Type: Text';
COMMENT ON COLUMN people_basic_information.known_titles IS 'An array containing the titles the person is known for. Type: Text';
COMMENT ON COLUMN people_basic_information.name_identifier IS 'A unique alphanumeric identifier for the person. Type: Text';
COMMENT ON COLUMN people_basic_information.primary_name IS 'The name by which the person is most often credited. Type: Text';
COMMENT ON COLUMN people_basic_information.primary_profession IS 'An array of the top-3 professions of the person. Type: Text';

CREATE TABLE principal_cast_and_crew_information (
    job_category TEXT,
    character_name TEXT,
    specific_job_title TEXT,
    name_identifier VARCHAR(128),
    row_identifier VARCHAR(45),
    title_identifier VARCHAR(128)
);

COMMENT ON TABLE principal_cast_and_crew_information IS 'This table contains information about the principal cast and crew members for IMDb titles, including their roles and identifiers.';
COMMENT ON COLUMN principal_cast_and_crew_information.job_category IS 'The category of job that the person was involved in. Type: Text';
COMMENT ON COLUMN principal_cast_and_crew_information.character_name IS 'The name of the character played, if applicable. Type: Text';
COMMENT ON COLUMN principal_cast_and_crew_information.specific_job_title IS 'The specific job title if applicable. Type: Text';
COMMENT ON COLUMN principal_cast_and_crew_information.name_identifier IS 'Alphanumeric unique identifier of the name/person. Type: Text';
COMMENT ON COLUMN principal_cast_and_crew_information.row_identifier IS 'A number to uniquely identify rows for a given title. Type: Text';
COMMENT ON COLUMN principal_cast_and_crew_information.title_identifier IS 'Alphanumeric unique identifier of the title. Type: Text';

CREATE TABLE title_crew_information (
    directors_identifier TEXT,
    title_identifier VARCHAR(128),
    writers_identifier TEXT
);

COMMENT ON TABLE title_crew_information IS 'This table contains crew information for IMDb titles.';
COMMENT ON COLUMN title_crew_information.directors_identifier IS 'The directors of the given title. This is an array of director identifiers.';
COMMENT ON COLUMN title_crew_information.title_identifier IS 'A unique alphanumeric identifier for the title. Type: Text';
COMMENT ON COLUMN title_crew_information.writers_identifier IS 'The writers of the given title. This is an array of writer identifiers.';

CREATE TABLE title_information (
    end_year VARCHAR(45),
    genre_list VARCHAR(256),
    is_adult VARCHAR(32),
    original_title VARCHAR(512),
    primary_title VARCHAR(512),
    runtime_duration VARCHAR(45),
    runtime_minutes VARCHAR(45),
    start_year VARCHAR(45),
    title_identifier VARCHAR(64),
    title_type VARCHAR(64)
);

COMMENT ON TABLE title_information IS 'This table contains basic information about IMDb titles.';
COMMENT ON COLUMN title_information.end_year IS 'The end year of the TV series (YYYY). Use '\N' for all other title types. Type: Text';
COMMENT ON COLUMN title_information.genre_list IS 'Includes up to three genres associated with the title. Type: Text';
COMMENT ON COLUMN title_information.is_adult IS 'Indicates if the title is an adult title (1) or non-adult title (0). Type: Text';
COMMENT ON COLUMN title_information.original_title IS 'The original title in the original language. Type: Text';
COMMENT ON COLUMN title_information.primary_title IS 'The more popular title used by the filmmakers on promotional materials at the point of release. Type: Text';
COMMENT ON COLUMN title_information.runtime_duration IS 'The duration of the title. Type: Text';
COMMENT ON COLUMN title_information.runtime_minutes IS 'The primary runtime of the title in minutes. Type: Text';
COMMENT ON COLUMN title_information.start_year IS 'The release year of the title (YYYY). For TV series, it is the series start year. Type: Text';
COMMENT ON COLUMN title_information.title_identifier IS 'A unique alphanumeric identifier for the title. Type: Text';
COMMENT ON COLUMN title_information.title_type IS 'The type or format of the title (e.g. movie, short, TV series, TV episode, video, etc.). Type: Text';

CREATE TABLE title_user_ratings (
    average_rating VARCHAR(45),
    number_of_votes VARCHAR(45),
    title_identifier VARCHAR(128)
);

COMMENT ON TABLE title_user_ratings IS 'This table contains user ratings data for IMDb titles, including average ratings and number of votes.';
COMMENT ON COLUMN title_user_ratings.average_rating IS 'The weighted average of all individual user ratings. Type: Decimal';
COMMENT ON COLUMN title_user_ratings.number_of_votes IS 'The number of votes the title has received. Type: Integer';
COMMENT ON COLUMN title_user_ratings.title_identifier IS 'Primary Key. An alphanumeric unique identifier for the title. Type: String';

CREATE TABLE tv_series_episode_information (
    episode_number TEXT,
    parent_series_identifier VARCHAR(128),
    season_number TEXT,
    episode_identifier VARCHAR(128)
);

COMMENT ON TABLE tv_series_episode_information IS 'Table containing detailed episode information for TV series in IMDb.';
COMMENT ON COLUMN tv_series_episode_information.episode_number IS 'The number of the episode in the TV series. Type: Text';
COMMENT ON COLUMN tv_series_episode_information.parent_series_identifier IS 'Unique alphanumeric identifier of the parent TV series. Type: Text';
COMMENT ON COLUMN tv_series_episode_information.season_number IS 'The season number to which the episode belongs. Type: Text';
COMMENT ON COLUMN tv_series_episode_information.episode_identifier IS 'Unique alphanumeric identifier of the episode. Type: Text';