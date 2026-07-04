---
id: doc-042
title: Interview Archive Pipeline — DAG
type: specification
created_date: '2026-07-04 14:19'
tags:
  - pipeline
  - dag
  - transcripts
  - youtube
  - vimeo
---
# Interview Archive Pipeline — DAG

Milestone: **Interview Archive Pipeline** (TASK-241 → TASK-258). Sequential, dependency-linked plan covering transcript accuracy + diarization, analysis/insight extraction, YouTube publishing, and Vimeo→YouTube migration. Cleanup from the ponytail audit is the foundation track.

## Scope decisions (from the user)
- **Vimeo migration** = re-upload Vimeo-only videos to YouTube, then retire Vimeo.
- **YouTube publishing** = captions + metadata sync + video upload + playlists/Shorts (all four).
- **Diarization** = hybrid: acoustic turns (WhisperX/pyannote) + LLM labeling of interviewer vs named interviewee.
- **Cleanup** = included as the foundation track.

## Key design rules
- Everything async runs on the **zdots** queue (job types `transcription`/`distill`/`embed`/`docs_sync`), reusing the `bin/batch_ztranscribe.rb` enqueue pattern. No hand-rolled direct-LLM calls.
- The `transcript-conversational-audit` skill already produces `speaker_map`/`turns`/`insights`/`youtube` metadata. So several nodes are **deltas on existing capability**, not greenfield: T2 grounds the skill's heuristic turns on acoustic diarization; I1 extends the existing insight schema; Y3 only *pushes* already-generated metadata.
- **One engine per output:** per-interview insight text stays in the audit skill; the zdots `embed` job owns only cross-interview linking/search (reuses `zdots-brain query --semantic`).
- Every outward-facing node (Y2–Y5, V3) has a **dry-run + explicit human-approval gate** before any live write.

## Tracks and nodes

### Track 0 — Foundation
- **TASK-241** Retire spent one-shot + vendored scripts (deps: —)
- **TASK-242** Route direct-LLM enrichment scripts onto the zdots queue (deps: —)

### Track 1 — Transcription & Diarization
- **TASK-244** Add acoustic diarization to the zdots transcription job (deps: 242)
- **TASK-247** Fuse acoustic diarization into the audit skill's speaker map (deps: 244)
- **TASK-250** Backfill diarized transcripts across the corpus — coordinates TASK-124/125, TASK-022–025, unblocks TASK-031–115 (deps: 247)

### Track 2 — Analysis & Insights
- **TASK-251** Extend the interview insight schema (deps: 247)
- **TASK-254** Cross-interview embedding + semantic linking (deps: 251, 242)
- **TASK-255** Enrich insights with interviewee/era/conference context (deps: 251)
- **TASK-257** Generate the content-opportunity backlog from insights — feeds TASK-236/237/238 (deps: 254, 255)

### Track 3 — YouTube Publishing
- **TASK-245** YouTube Data API auth + publish client (deps: 242)
- **TASK-248** Push generated YouTube metadata to the channel (deps: 245)
- **TASK-249** Resumable video upload pipeline (deps: 245)
- **TASK-252** Publish diarized transcripts as YouTube captions (deps: 245, 247)
- **TASK-258** Publish playlists and Shorts from insights (deps: 245, 257, 249)

### Track 4 — Vimeo → YouTube Migration
- **TASK-243** Inventory Vimeo-only assets + build migration set (deps: —)
- **TASK-246** Download Vimeo masters (deps: 243)
- **TASK-253** Re-upload migrated Vimeo videos to YouTube (deps: 246, 249)
- **TASK-256** Retire Vimeo as a platform; repoint site (deps: 253)

## Topology
- **Entry nodes (parallel start):** TASK-241, TASK-242, TASK-243
- **Critical path:** 242 → 244 → 247 → 251 → 254 → 257 → 258
- **Cross-track joins:** Y2 (252) needs diarized transcripts (247); V3 (253) needs the upload pipeline (249); Y5 (258) needs content opportunities (257); migrated videos from V3 (253) re-enter transcription backfill (250) + captions (252) + metadata (248).
