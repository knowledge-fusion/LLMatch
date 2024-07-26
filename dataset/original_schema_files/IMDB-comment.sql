-- Add comments to the title.akas table
COMMENT ON TABLE title_akas IS 'Table containing alternate titles for IMDb entries';

-- Add comments to the columns of title.akas
COMMENT ON COLUMN title_akas.titleId IS 'a tconst (string, an alphanumeric unique identifier of the title)';
COMMENT ON COLUMN title_akas.ordering IS 'a number to uniquely identify rows for a given titleId (integer)';
COMMENT ON COLUMN title_akas.title IS 'the localized title (string)';
COMMENT ON COLUMN title_akas.region IS 'the region for this version of the title (string)';
COMMENT ON COLUMN title_akas.language IS 'the language of the title (string)';
COMMENT ON COLUMN title_akas.types IS 'Enumerated set of attributes for this alternative title (array). One or more of the following: "alternative", "dvd", "festival", "tv", "video", "working", "original", "imdbDisplay". New values may be added in the future without warning';
COMMENT ON COLUMN title_akas.attributes IS 'Additional terms to describe this alternative title (array), not enumerated';
COMMENT ON COLUMN title_akas.isOriginalTitle IS '0: not original title. 1: original title (boolean)';


-- Add comments to the title.basics table
COMMENT ON TABLE title_basics IS 'Table containing basic information about IMDb titles';

-- Add comments to the columns of title.basics
COMMENT ON COLUMN title_basics.tconst IS 'alphanumeric unique identifier of the title (string)';
COMMENT ON COLUMN title_basics.titleType IS 'the type/format of the title (string) (e.g. movie, short, tvseries, tvepisode, video, etc)';
COMMENT ON COLUMN title_basics.primaryTitle IS 'the more popular title (string) (the title used by the filmmakers on promotional materials at the point of release)';
COMMENT ON COLUMN title_basics.originalTitle IS 'original title (string) (in the original language)';
COMMENT ON COLUMN title_basics.isAdult IS '0: non-adult title. 1: adult title (boolean)';
COMMENT ON COLUMN title_basics.startYear IS 'represents the release year of a title (YYYY). In the case of TV Series, it is the series start year';
COMMENT ON COLUMN title_basics.endYear IS 'TV Series end year (YYYY). ‘\N’ for all other title types';
COMMENT ON COLUMN title_basics.runtimeMinutes IS 'primary runtime of the title (integer, in minutes)';
COMMENT ON COLUMN title_basics.genres IS 'includes up to three genres associated with the title (string array)';

-- Add comments to the title.crew table
COMMENT ON TABLE title_crew IS 'Table containing crew information for IMDb titles';

-- Add comments to the columns of title.crew
COMMENT ON COLUMN title_crew.tconst IS 'alphanumeric unique identifier of the title (string)';
COMMENT ON COLUMN title_crew.directors IS 'director(s) of the given title (array of nconsts)';
COMMENT ON COLUMN title_crew.writers IS 'writer(s) of the given title (array of nconsts)';

-- Add comments to the title.episode table
COMMENT ON TABLE title_episode IS 'Table containing episode information for TV series in IMDb';

-- Add comments to the columns of title.episode
COMMENT ON COLUMN title_episode.tconst IS 'alphanumeric identifier of episode (string)';
COMMENT ON COLUMN title_episode.parentTconst IS 'alphanumeric identifier of the parent TV Series (string)';
COMMENT ON COLUMN title_episode.seasonNumber IS 'season number the episode belongs to (integer)';
COMMENT ON COLUMN title_episode.episodeNumber IS 'episode number of the tconst in the TV series (integer)';

-- Add comments to the title.principals table
COMMENT ON TABLE title_principals IS 'Table containing principal cast and crew information for IMDb titles';

-- Add comments to the columns of title.principals
COMMENT ON COLUMN title_principals.tconst IS 'alphanumeric unique identifier of the title (string)';
COMMENT ON COLUMN title_principals.ordering IS 'a number to uniquely identify rows for a given titleId (integer)';
COMMENT ON COLUMN title_principals.nconst IS 'alphanumeric unique identifier of the name/person (string)';
COMMENT ON COLUMN title_principals.category IS 'the category of job that person was in (string)';
COMMENT ON COLUMN title_principals.job IS 'the specific job title if applicable, else ''\\N'' (string)';
COMMENT ON COLUMN title_principals.characters IS 'the name of the character played if applicable, else ''\\N'' (string)';

-- Add comments to the title.ratings table
COMMENT ON TABLE title_ratings IS 'Table containing user ratings for IMDb titles';

-- Add comments to the columns of title.ratings
COMMENT ON COLUMN title_ratings.tconst IS 'alphanumeric unique identifier of the title (string)';
COMMENT ON COLUMN title_ratings.averageRating IS 'weighted average of all the individual user ratings (float)';
COMMENT ON COLUMN title_ratings.numVotes IS 'number of votes the title has received (integer)';

-- Add comments to the name.basics table
COMMENT ON TABLE name_basics IS 'Table containing basic information about people in IMDb';

-- Add comments to the columns of name.basics
COMMENT ON COLUMN name_basics.nconst IS 'alphanumeric unique identifier of the name/person (string)';
COMMENT ON COLUMN name_basics.primaryName IS 'name by which the person is most often credited (string)';
COMMENT ON COLUMN name_basics.birthYear IS 'birth year (YYYY)';
COMMENT ON COLUMN name_basics.deathYear IS 'death year if applicable, else ''\\N'' (YYYY)';
COMMENT ON COLUMN name_basics.primaryProfession IS 'the top-3 professions of the person (array of strings)';
COMMENT ON COLUMN name_basics.knownForTitles IS 'titles the person is known for (array of tconsts)';
