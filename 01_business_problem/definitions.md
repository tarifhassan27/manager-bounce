# Phase 4: Locked definitions (committed before any outcome is computed)

## Slump (entry condition)
A club-match is a "slump point" if ppg_prior_10 <= 1.0.

## Treated group
Slump points where a manager change (from clean.manager_changes) occurs
at that point, excluding changes on match_no >= 33 (end-of-season noise,
confirmed in Phase 3).

## Control group
Slump points where no manager change occurs in the following 10 matches.
Matched to treated events on:
  - ppg_prior_10 (closest available value)
  - league position at the slump point (closest available value)
Match within the same season where possible; otherwise nearest season.

## Outcome
ppg_next_10 - ppg_prior_10, compared treated vs. control (mean difference,
then difference-in-differences regression in Phase 5 with statsmodels).

## Hypothesis
H0: sacking the manager produces no larger improvement than staying with
the same manager through an equivalent slump (regression to the mean
explains the "bounce").
H1: sacking the manager produces a significantly larger improvement.

Locked: 2026-09-24. Not to be edited after Phase 5 begins.