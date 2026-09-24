-- Phase 2: build clean.club_matches
-- One row per club per match (home/away unpivoted), Bundesliga only.
-- Adds points (3/1/0) and match_no (chronological order within club+season).
-- Depends on raw.games.date being cast explicitly (date::date) — see phase1_notes.md.

CREATE TABLE clean.bl_staging AS
SELECT
    game_id, season, date::date AS match_date,
    home_club_id, away_club_id,
    home_club_goals, away_club_goals,
    home_club_manager_name, away_club_manager_name
FROM raw.games
WHERE competition_id = 'L1';

CREATE TABLE clean.club_matches AS
SELECT
    game_id, season, match_date,
    home_club_id AS club_id, away_club_id AS opponent_id,
    home_club_goals AS goals_for, away_club_goals AS goals_against,
    home_club_manager_name AS manager_name,
    CASE WHEN home_club_goals > away_club_goals THEN 3
         WHEN home_club_goals = away_club_goals THEN 1 ELSE 0 END AS points,
    'home' AS venue
FROM clean.bl_staging;

INSERT INTO clean.club_matches
SELECT
    game_id, season, match_date,
    away_club_id AS club_id, home_club_id AS opponent_id,
    away_club_goals AS goals_for, home_club_goals AS goals_against,
    away_club_manager_name AS manager_name,
    CASE WHEN away_club_goals > home_club_goals THEN 3
         WHEN away_club_goals = home_club_goals THEN 1 ELSE 0 END AS points,
    'away' AS venue
FROM clean.bl_staging;

ALTER TABLE clean.club_matches ADD COLUMN match_no INTEGER;

CREATE TABLE clean.match_no_lookup AS
SELECT game_id, club_id,
       ROW_NUMBER() OVER (PARTITION BY club_id, season ORDER BY match_date) AS rn
FROM clean.club_matches;

UPDATE clean.club_matches cm
SET match_no = ml.rn
FROM clean.match_no_lookup ml
WHERE cm.game_id = ml.game_id AND cm.club_id = ml.club_id;

DROP TABLE clean.match_no_lookup;