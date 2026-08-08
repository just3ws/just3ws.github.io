# bin/ Directory Command Index

This directory contains executable tools and drivers for building, validating, and ingesting data for the site.

## Primary Human Drivers

| Command | Usage | Description |
| :--- | :--- | :--- |
| [`./bin/server`](file:///Users/mike/github.com/just3ws/just3ws.github.io/bin/server) | `./bin/server` | Launches local Jekyll development server on `http://127.0.0.1:4000/` with live-reload. |
| [`./bin/pipeline`](file:///Users/mike/github.com/just3ws/just3ws.github.io/bin/pipeline) | `./bin/pipeline <command>` | Unified runner (`generate`, `build`, `test`, `validate`, `smoke`, `ci`). |

---

## Command Categories & Naming Conventions

All scripts in `bin/` follow standard prefix naming conventions:

### 1. Unified Drivers & CLI Tools
- `server`: Local dev server launcher.
- `pipeline`: Main pipeline CLI (`./bin/pipeline build`, `./bin/pipeline ci`, etc.).
- `deploy_status`: Check deployment status.

### 2. Generators (`generate_*`)
Scripts that read `_data/*.yml` sources and compile pages/artifacts into Jekyll source:
- `generate_timeline_data.rb`
- `generate_speakers_data.rb`
- `generate_resume_position_pages.rb`
- `generate_context_summaries.rb`

### 3. Validators (`validate_*`)
Quality checks executed by CI (`./bin/pipeline ci`):
- `validate_exports.rb`: Verifies JSON, Markdown, and text resume exports.
- `validate_repo_hygiene.rb`: Enforces repo file tracking policies.
- `validate_seo_output.rb`: Checks structured metadata and SEO tags.
- `validate_data_uniqueness.rb`: Checks for duplicate records in YAML data.

### 4. Archival & Ingestion Tasks (`import_*`, `enrich_*`, `audit_*`)
Automated data processing and archival tools:
- `import_transcripts_from_outbox.rb`: Batch ingest transcripts.
- `enrich_speaker_profiles.rb`: Deep research and speaker enrichment.
- `audit_metadata.rb`: Comprehensive metadata completeness audit.
