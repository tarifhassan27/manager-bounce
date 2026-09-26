-- Phase 6: robustness check — 5-match window (vs. Phase 5's 10-match window)
-- Same slump/treatment/control/matching logic as Phase 5, applied to
-- rolling PPG over 5 matches instead of 10.
--
-- Result: gap widens to 0.225 (vs 0.117 at 10 matches) and becomes
-- statistically significant (paired t-test, n=117 after dropping 2
-- pairs with missing ppg_next_5 near season boundaries; t=2.86, p=0.0051)
-- vs. p=0.061 at the 10-match window.
--
-- Interpretation: the effect may be front-loaded (fades by game 10),
-- but the 5-match PPG scale is coarse (6 possible values), which
-- produces easier exact ties in matching (avg match_dist = 0) and may
-- overstate match quality. Report both results, not just the
-- significant one.

ALTER TABLE clean.club_matches ADD COLUMN ppg_prior_5 NUMERIC;
ALTER TABLE clean.club_matches ADD COLUMN ppg_next_5 NUMERIC;

CREATE TABLE clean.ppg5_lookup AS
SELECT game_id, club_id,
    AVG(points) OVER (PARTITION BY club_id, season ORDER BY match_no
        ROWS BETWEEN 5 PRECEDING AND 1 PRECEDING) AS prior_5,
    AVG(points) OVER (PARTITION BY club_id, season ORDER BY match_no
        ROWS BETWEEN 1 FOLLOWING AND 5 FOLLOWING) AS next_5
F