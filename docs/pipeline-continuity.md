# Archive Pipeline: Technical Handoff & Continuity Guide

## 1. Overview
The archive has been migrated to a modular **ETLT (Extract, Transform, Load, Transform)** pipeline located in `bin/archive/`. This system is designed for high-fidelity technical transcription processing, specifically targeting the 214-item UGtastic/SCNA corpus.

## 2. Pipeline Architecture
- **Controller:** `bin/archive/pipeline.rb`
- **Modules:** `bin/archive/modules/`
  - `ingest`: Raw text to YAML.
  - `normalize`: Lexical perfection (8th Light, ActiveJDBC, Clojure).
  - `structure`: Heuristic speaker turns (fast, lower fidelity).
  - `restructure`: **High-Fidelity AI Dialogue Restoration** (uses local `llama.cpp` @ port 8080).
  - `enrich`: AI-generated summaries and topics.
  - `validate`: **The Gatekeeper.** Performs forensic word-count drift and diarization audits.
  - `sync`: Syncs metadata back to global `_data/` files.

## 3. State-Awareness & Idempotency
Each transcript in `_data/transcripts/*.yml` tracks its own state via metadata keys:
- `normalized_at`: Locked-in spelling/branding.
- `restructured_at`: Locked-in high-fidelity back-and-forth dialogue.
- `validated_at`: Passed the forensic integrity audit.
- `validation_error`: Present if the audit failed (e.g., word count drift).

**CRITICAL:** The pipeline automatically skips "Perfect" (restructured/validated) items unless the `--force` flag is used. This protects manual repairs (e.g., Micah Martin, Sergio Pereira).

## 4. Current State (Audit Report)
- **Total Archive:** 197-214 items.
- **Normalized:** ~98% (Technical lexicon is globally applied).
- **Validated:** ~50%.
- **Forensic Backlog:** **95 items** currently fail the forensic audit (Significant Word Count Drift or Interviewer Overload).

## 5. Resumption Instructions
To resume the restoration of the 95 failed items:

```bash
# 1. Check service health
zdots-ctl status
# If llama-server or other services are down:
zdots-ctl up

# 2. Run the restructure stage only for failed items
# (Requires llama_cpp service @ http://127.0.0.1:8080)
./bin/archive/pipeline.rb --only-failed --stage=restructure

# 3. Re-validate to clear the error state
./bin/archive/pipeline.rb --only-failed --stage=validate

# 4. (Optional) Index for semantic search
# (Requires 'my' database and zdots-ctx)
./bin/archive/pipeline.rb --only-failed --stage=index
```

## 6. Platform Integration Notes
- **Local AI:** Restructuring and Enrichment use the `qwen2.5-coder-7b` model via `llama.cpp`. 
- **Context Database:** The `index` stage loads data into the `my` database via the `zdots-ctx` interface. All writes MUST go through this interface.
- **Observability:** Pipeline metrics and logs are exported to the local Grafana instance via OpenTelemetry if `otelcol` is active.
- **Service Control:** Use `zdots-ctl check` to verify the entire stack's health.

## 7. Safety Mandates for Future Agents
1. **Never "Bulldoze":** Do not use `FORCE=true` on the old `bin/structure_transcript_heuristics.rb` script. Use the modular pipeline instead.
2. **AI Stability:** The `restructure` module uses 500-word chunks to prevent `llama.cpp` OOM errors.
3. **Audit First:** Before syncing any batch, run `--stage=validate` to ensure no data was lost.
