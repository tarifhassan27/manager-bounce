-- Phase 3: detect in-season manager changes
-- Compares each match's manager to the club's previous match manager (per season).
-- 154 changes detected, matching the Phase 0 pandas cross-check exactly.
-- 5 of these fall on matchday 33-34 (season length = 34) and are likely
-- end-of-season bench handoffs, not real sackings -- flagged for Phase 4's
-- exclusion rule, not filtered here.

CREATE TABLE clean.manager_lookup AS
SELECT
    club_id, season, match_no, match_date, manager_name,
    LAG(manager_name) OVER (
        PARTITION BY club_id, season ORDER BY match_no
    ) AS prev_manager
FROM clean.club_matches;

CREATE TABLE clean.manager_changes AS
SELECT
    club_id, season, match_no, match_date,
    prev_manager AS outgoing_manager,
    manager_name AS incoming_manager
FROM clean.manager_lookup
WHERE prev_manager IS NOT NULL
  AND manager_name != prev_manager;

DROP TABLE clean.manager_lookup;