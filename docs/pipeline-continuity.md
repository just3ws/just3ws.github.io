# Archive Pipeline: Technical Handoff & Continuity Guide

## 1. Overview
The archive operates on a modular **ETLT (Extract, Transform, Load, Transform)** pipeline located in `bin/archive/`, integrated with the **zdots / My platform system** (`~/.config/zsh`, `~/my`). This system processes, transcribes, annotates, and indexes the ~207-item UGtastic/SCNA oral history corpus.

## 2. Pipeline Architecture & Modules
- **Controller:** `bin/archive/pipeline.rb`
- **Automation CLI:** `bin/transcript_ops.rb`
- **Modules:** `bin/archive/modules/`
  - `ingest`: Raw transcript text to YAML (`_data/transcripts/<id>.yml`).
  - `normalize`: Lexical perfection (*8th Light*, *ActiveJDBC*, *Clojure*, *ChiPy*, *SCNA*).
  - `structure`: Heuristic speaker turns.
  - `restructure`: High-fidelity AI dialogue restoration and `pyannote.audio` 3.1 neural speaker diarization (`bin/diarize`).
  - `enrich`: AI-generated summaries, technical topics, and durable wisdom insights.
  - `validate`: **The Gatekeeper.** Performs forensic word-count drift, turn length, and interviewer overload audits.
  - `index`: Loads enriched transcripts into `zdots-ctx` / `my` PostgreSQL vector database (`pgvector`) for RAG & semantic search.
  - `sync`: Syncs transcript metadata back to global `_data/` files.

## 3. zdots Platform & Context Engine Integration
The pipeline leverages the local **zdots platform** context system:
- **Vocabulary Priming (`primed` stage):** Injects metadata and `known_vocabulary` terms into `whisper.cpp` (`large-v3` model) to eliminate mishearings of technical terms at the raw transcription level.
- **Neural Diarization (`diarized` stage):** Uses `pyannote.audio` 3.1 (`pyannote/speaker-diarization-3.1`) with Metal GPU acceleration on Apple Silicon M4 and speaker count hints (`num_speakers = interviewees + 1`).
- **Intro/Outro Boundaries:** Uses `zdots-backfill-boundaries` and `etc/theme-songs.yml` to non-destructively generate `.boundaries.json` sidecar annotations for video player intro skipping.
- **Internal Context Engine (`@context-engine` / `ContextBot`):** Interrogates `zdots-ctx` live during pipeline execution for speaker names, organization terms, and inter-run observations.

## 4. State-Awareness & Idempotency
Each transcript in `_data/transcripts/*.yml` tracks its processing state:
- `normalized_at`: Locked-in spelling and branding normalization.
- `restructured_at`: Locked-in high-fidelity back-and-forth dialogue.
- `enriched_at`: AI executive summary and technical insights generated.
- `indexed_at` & `zdots_lesson_id`: Vector embeddings indexed in `my` PostgreSQL database.
- `validated_at`: Passed forensic integrity audit.
- `validation_error`: Error message present if the audit failed (e.g. Interviewer Overload).

## 5. Rake Automation & CLI Commands

```bash
# Unified Operations CLI
./bin/transcript_ops.rb --status              # Full archive & RAG status report
./bin/transcript_ops.rb --seed-context        # Seed domain vocabulary into zdots-ctx
./bin/transcript_ops.rb --backfill-boundaries # Generate theme-song boundary sidecars
./bin/transcript_ops.rb --index-enriched      # Index enriched items into zdots-ctx
./bin/transcript_ops.rb --forensic-audit      # Run forensic quality audit
./bin/transcript_ops.rb --all                 # Execute full maintenance & RAG pipeline

# Rake Automation Commands
bundle exec rake transcript:forensic_audit
bundle exec rake transcript:boundaries
bundle exec rake transcript:index
bundle exec rake transcript:pipeline[stage,id]
```

## 6. Vector RAG & Semantic Search Usage
Once transcripts are indexed in the `my` database, perform live semantic vector searches:

```bash
# Query the local context engine
zdots-ctx query "faster CSV"

# Perform pgvector similarity search over transcript chunks
zdots-search "Faster CSV"
```

## 7. Safety Mandates for Future Agents
1. **Never "Bulldoze":** Do not use `FORCE=true` on heuristic turn splitters. Use neural diarization via `ingest_media` / `bin/diarize`.
2. **Context First:** Always query `@context-engine` or `zdots-ctx` for speaker names and domain vocabulary before re-transcribing audio.
3. **Audit First:** Before committing transcript batches, run `bundle exec rake transcript:forensic_audit` and `bundle exec rake validate:data_integrity`.
