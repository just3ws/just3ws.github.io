---
name: ecosystem-datalake-steward
description: Manages, queries, and maintains the ecosystem datalake across SQLite3 FTS5, DuckDB analytical views, JSONL streams, and timeline events spanning all 4 GitHub organizations (@just3ws, @ugtastic, @wwworkremote, @phalanxduel). Use when querying cross-repository commits, exploring historical milestones, running DuckDB queries, or updating datalake schemas.
---

# /ecosystem-datalake-steward: Ecosystem Datalake & Control Plane

Use this skill when exploring cross-repository git histories, querying chronological milestones, executing analytical DuckDB queries, or maintaining the unified datalake across Mike Hall's 18-year engineering history.

The datalake is stored locally in `lake/ecosystem/` (gitignored to keep binaries out of version control):
- `lake/ecosystem/ecosystem.db`: SQLite3 database with strongly-typed tables and `ecosystem_fts` FTS5 table.
- `lake/ecosystem/ecosystem.duckdb`: Native DuckDB database with analytical views.
- `lake/ecosystem/ecosystem.jsonl`: JSONL streaming export for portable queries.
- `lake/ecosystem/ecosystem_manifest.json`: Metadata manifest with timestamps, counts, and sizes.

---

## 1. Root Control Plane Driver (`./bin/just3ws` or `./bin/pipeline`)

All operations are accessible through the unified CLI:

```bash
# View summary statistics across repositories, commits, and organizations
./bin/just3ws lake stats

# Query the chronological timeline across 18 years
./bin/just3ws lake timeline --limit 20
./bin/just3ws lake timeline "Craftsmanship Genesis"

# Search full-text across repositories, commits, artifacts, and timeline events
./bin/just3ws lake query "Alt.NET"
./bin/just3ws lake query "printable schedule"

# Execute analytical queries against DuckDB views
./bin/just3ws lake duckdb "SELECT * FROM v_timeline LIMIT 10;"
./bin/just3ws lake duckdb "SELECT * FROM v_org_summary;"
./bin/just3ws lake duckdb "SELECT * FROM v_yearly_activity WHERE year = '2026';"
./bin/just3ws lake duckdb "SELECT * FROM v_language_distribution;"

# Execute raw SQL directly against SQLite3
./bin/just3ws lake sql "SELECT count(*) FROM commits WHERE author_name LIKE '%Mike%';"

# Rebuild and re-harvest the datalake
./bin/just3ws lake build --verbose
```

---

## 2. Core Architecture (`bin/lib/ecosystem_datalake.rb`)

The shared Ruby core library encapsulates:
- Schema setup: `organizations`, `repositories`, `commits`, `historical_artifacts`, `timeline_events`, `ecosystem_fts`.
- Harvesting: `gh api` repository metadata across organizations, release notes, and local git histories.
- Chronology compiler: Categorizes events into 5 historical epochs:
  1. Craftsmanship Genesis (2008 to 2012)
  2. Distributed Services & Micro-Apps (2012 to 2015)
  3. GitHub Pages Genesis & Personal Control Plane (2016 to 2017)
  4. Calm Systems & Local Platforms (2018 to 2022)
  5. Autonomous Intake & Forensic Audio (2026)
- Export engines: Emits JSONL streams and builds DuckDB analytical tables and views.

---

## 3. Verification & Testing

Verify datalake integrity:

```bash
# Run datalake RSpec suite
bundle exec rspec spec/data/ecosystem_datalake_spec.rb

# Run full fast validation gates
./bin/just3ws validate fast
```
