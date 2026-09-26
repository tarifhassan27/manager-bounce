# AI Workflow

This project used Claude in three distinct roles: SQL/analysis pair-work,
LinkedIn carousel design (Claude Design, a separate tool/chat), and a
numbers-verification pass across every deliverable before publishing.
The verification pass caught two real errors — logged here rather than
smoothed over, since catching them is as much a part of the method as
the analysis itself.

## What Claude did

- Wrote and reviewed SQL for each phase (match spine, manager-change
  detection via `LAG()`, matched-pair construction, robustness check),
  one query at a time.
- Cross-verified every quantitative result independently in Python
  (`pandas`/`scipy`) against the SQL output before it was accepted as
  final — a standing rule for this project, not a one-off check.
- Built the LinkedIn carousel deck via Claude Design, then verified its
  chart against the source data pixel-by-pixel rather than by eye.
- Wrote the final chart image directly from `event_study.csv` (not an
  AI redraw) once the first Design-generated version was found to drift
  from the real values.

## What broke, and what it cost

1. **`raw.games.date` stored as TEXT, not DATE.** A JDBC casting failure
   on import silently broke type inference. Every date-based query from
   Phase 1 onward needed an explicit `date::date` cast. Logged in
   `02_data/data_notes.md`.

2. **154 detected ≠ 108 analyzed — a slide almost shipped the wrong
   number.** A LinkedIn carousel slide stated "154 manager changes
   analyzed," conflating the raw count of detected manager changes with
   108, the actual matched analytical sample used in the result. Caught
   during a pre-publish review pass, not before. Fixed by explicitly
   splitting "154 detected" from "108 analyzed" on the slide.

3. **The README and a slide caption described the chart backwards.**
   An early draft claimed sacked clubs "dip below the control group for
   several matches" after the change. Pixel-extracting the actual
   event-study values showed the opposite: sacked clubs sit *above* the
   kept-manager group in 7 of the first 11 post-change matches. The
   README and the slide 5 caption were rewritten to match what the data
   actually shows — the rebound looks large mostly because sacked clubs
   were sacked at their single lowest point (PPG 0.17 at match −1, the
   floor of either group across the full 21-match window), not because
   changing the manager caused an unusually strong recovery.

4. **A stylized, AI-redrawn chart drifted from the source values.** The
   first Design-generated chart approximated the curve shape by eye; a
   calibrated pixel overlay against the real chart showed the pre-event
   dip was measurably shallower than the true −1 trough. Replaced with a
   chart rendered directly from the CSV, in the deck's own palette, so
   the shape is exact rather than approximate.

## Why this belongs in the writeup

Every one of these was a case of trusting a plausible-looking output
(a slide, a caption, a redrawn chart) without checking it against the
underlying numbers first. The discipline that caught them — always
re-derive from source data, never accept a restatement at face value —
is the same discipline the analysis itself is built on.
