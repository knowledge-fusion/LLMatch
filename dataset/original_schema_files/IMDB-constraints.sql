-- Adding foreign key constraints without ON DELETE CASCADE and ON UPDATE CASCADE

ALTER TABLE title_akas
ADD CONSTRAINT fk_title_akas_titleid
FOREIGN KEY (titleid) REFERENCES title_basics (tconst);

ALTER TABLE title_crew
ADD CONSTRAINT fk_title_crew_tconst
FOREIGN KEY (tconst) REFERENCES title_basics (tconst);

ALTER TABLE title_episode
ADD CONSTRAINT fk_title_episode_tconst
FOREIGN KEY (tconst) REFERENCES title_basics (tconst);
ALTER TABLE title_episode
ADD CONSTRAINT fk_title_episode_parent
FOREIGN KEY (parenttconst) REFERENCES title_basics (tconst);

ALTER TABLE title_principals
ADD CONSTRAINT fk_title_principals_tconst
FOREIGN KEY (tconst) REFERENCES title_basics (tconst);
ALTER TABLE title_principals
ADD CONSTRAINT fk_title_principals_nconst
FOREIGN KEY (nconst) REFERENCES name_basics (nconst);

ALTER TABLE title_ratings
ADD CONSTRAINT fk_title_ratings_tconst
FOREIGN KEY (tconst) REFERENCES title_basics (tconst);