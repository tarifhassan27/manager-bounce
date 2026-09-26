# Phase 1: Database setup

Database: manager_bounce (PostgreSQL 18)
Schemas: raw, clean

## Tables loaded into raw (from Transfermarkt open dataset, Kaggle mirror)
- raw.games (88,958 rows) — match results, Bundesliga competition_id = 'L1'
- raw.club_games (355,832 rows) — per-club view of each game
- raw.competitions (130 rows) — competition metadata

## Known issues / decisions
- DBeaver's CSV import auto-guessed narrow VARCHAR(50) on several text
  columns in games.csv (club names, manager names, stadium, referee) and
  failed on a long Greek club name. Fixed by creating raw.games manually
  with TEXT for all string columns instead of relying on auto-detect.
- The `date` column in raw.games was kept as TEXT, not DATE, because the
  JDBC batch insert failed casting string dates during import. This means
  any query in clean/ that sorts, filters, or windows by date MUST cast
  explicitly: date::date. Do not assume chronological sort order on the
  raw text column.