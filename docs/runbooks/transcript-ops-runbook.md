# Archive Operations Runbook & Playbook

Operational runbook and troubleshooting playbook for managing, transcribing, auditing, repairing, and RAG-indexing the ~207-item UGtastic / SCNA audio-video archive on `just3ws.github.io` and the **zdots / My platform**.

---

## 1. Quick Reference & CLI Matrix

| Task | Command | Description |
|---|---|---|
| **Archive Status Report** | `./bin/transcript_ops.rb --status` | Shows counts for interviews, video assets, transcripts, validation errors, boundary sidecars, and RAG vector index state. |
| **Run Full Pipeline** | `./bin/transcript_ops.rb --all` | Executes context seeding, boundary backfilling, RAG vector indexing, and forensic auditing in sequence. |
| **Forensic Repair** | `ruby bin/forensic_repair.rb <id>` | Automatically splits long turns (>3000 chars) and interviewer overload single-turn collapses. |
| **Cross-Dataset ID Rename** | `ruby bin/rename_transcript_id.rb <old_id> <new_id>` | Renames transcript and interview IDs across all 6 site datasets and verifies data integrity. |
| **Vector RAG Indexing** | `./bin/transcript_ops.rb --index-enriched` | Embeds enriched transcripts into the `my` PostgreSQL database (`zdots-ctx` pgvector). |
| **Theme Boundary Backfill** | `./bin/transcript_ops.rb --backfill-boundaries` | Generates `.boundaries.json` theme-song intro/outro sidecars in `~/.local/state/zdots/ingest-sources`. |
| **Seed Context Vocabulary** | `./bin/transcript_ops.rb --seed-context` | Seeds UGtastic domain terminology into `zdots-ctx` for ASR whisper.cpp priming. |
| **Rake Data Validation** | `bundle exec rake validate:data_uniqueness validate:data_integrity` | Verifies zero broken links, schema compliance, and data uniqueness across all YAML files. |

---

## 2. Operational Playbooks

### Playbook A: Repairing Forensic Validation Errors (`validation_error`)

When `./bin/transcript_ops.rb --status` or `rake transcript:forensic_audit` reports validation errors:

1. **Diagnose Error Type:**
   ```bash
   ruby bin/archive/modules/validate.rb <transcript_id> --force
   ```
2. **Apply Automated Forensic Turn Splitting:**
   ```bash
   ruby bin/forensic_repair.rb <transcript_id>
   ```
3. **If Neural Diarization is Required (collapsed guest turns):**
   Run `pyannote.audio` 3.1 diarization via the zdots pipeline:
   ```bash
   bin/diarize ~/.local/state/zdots/ingest-sources/<transcript_id>.wav --num-speakers <interviewees_count + 1>
   ```
4. **Verify Validation Clearance:**
   ```bash
   bundle exec rake validate:data_integrity
   ```

---

### Playbook B: Ingesting Missing Media Assets (11 Assets Lacking Transcripts)

1. **Identify Missing Assets:**
   ```bash
   ./bin/transcript_ops.rb --status
   ```
2. **Execute Ingestion with Vocabulary Priming:**
   ```bash
   ztranscribe ~/.local/state/zdots/ingest-sources/<video_asset_id>.mp4 \
     --vocabulary "8th Light, ActiveJDBC, Clojure, ChiPy, SCNA, WindyCityRails, Refactor Chicago"
   ```
3. **Import & Normalize into Archive:**
   ```bash
   ruby bin/archive/pipeline.rb --stage ingest --id <video_asset_id>
   ruby bin/archive/pipeline.rb --stage normalize --id <video_asset_id>
   ruby bin/archive/pipeline.rb --stage structure --id <video_asset_id>
   ruby bin/archive/pipeline.rb --stage enrich --id <video_asset_id>
   ```
4. **Index into PostgreSQL Vector Store:**
   ```bash
   ./bin/transcript_ops.rb --index-enriched
   ```

---

### Playbook C: Renaming Transcript / Interview ID Slugs

When a slug typo or naming inconsistency is identified in `_data/`:

1. **Execute Safe Rename:**
   ```bash
   ruby bin/rename_transcript_id.rb <old_id> <new_id>
   ```
   *This automatically updates `_data/transcripts/`, `_data/interviews.yml`, `_data/video_assets.yml`, `_data/interview_topics.yml`, `_data/interviewees_index.yml`, and `_data/video_metadata_completeness.yml`.*

2. **Verify Data Integrity:**
   ```bash
   bundle exec rake validate:data_uniqueness validate:data_integrity
   ```

---

### Playbook D: Vector RAG & Semantic Context Engine Operations

1. **Interrogate the Context Engine:**
   ```bash
   zdots-ctx query "faster CSV James Edward Gray"
   ```
2. **Perform Semantic Vector Search over Archive Lessons:**
   ```bash
   zdots-search "ActiveJDBC ORM design"
   ```
3. **Verify Index Parity:**
   Ensure 100% of enriched transcripts have `indexed_at` and `zdots_lesson_id` fields set in `_data/transcripts/*.yml`.

---

## 3. Maintenance Checklist for Operators & AI Agents

- [ ] `./bin/transcript_ops.rb --status` shows 0 unhandled critical errors.
- [ ] `bundle exec rake validate:data_uniqueness validate:data_integrity` exits with code 0.
- [ ] 100% of enriched transcripts are indexed in `zdots-ctx` pgvector store.
- [ ] Session handoff log recorded in `~/.config/adots/handoffs/YYYY-MM-DD.md`.
