---
id: doc-042
title: Interview Archive Pipeline — DAG
type: specification
created_date: '2026-07-04 14:19'
updated_date: '2026-07-04 14:49'
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
- **Diarization** = hybrid: acoustic turns (whisper.cpp + pyannote 3.1) + LLM labeling of interviewer vs named interviewee.
- **Cleanup** = included as the foundation track.

## Repo ⇄ zdots boundary (target architecture)
zdots is the transcription/AI **service provider**; this repo is a **consumer**.
- **zdots owns** the generic, reusable heavy lifting: ASR transcription, acoustic diarization, distillation, embedding, semantic search. This code lives in the zdots platform repo (`~/.config/zsh/lib/zdots`).
- **This repo owns** only what is unique to the interview archive: the `_data` schema, the human canonical-review/audit loop, site rendering, and the orchestration that enqueues zdots jobs and evaluates/automates on the results.
- **Consequences:** TASK-242 is a capability-extraction refactor (move generic transforms into zdots, keep interview-unique orchestration here), not a "route scripts onto the queue" swap. TASK-244's pyannote pass is a zdots-side change; this repo only defines the additive `diarization` schema block it consumes. TASK-254's embedding is zdots; this repo only maps neighbors back to slugs. Tasks with a zdots-repo component: 242, 244, 254 (and the transcription engine behind 250).

## Key design rules
- Everything async runs on the **zdots** queue (job types `transcription`/`distill`/`embed`/`docs_sync`), reusing the `bin/batch_ztranscribe.rb` enqueue pattern. No hand-rolled direct-LLM calls.
- The `transcript-conversational-audit` skill already produces `speaker_map`/`turns`/`insights`/`youtube` metadata. So several nodes are **deltas on existing capability**, not greenfield: T2 grounds the skill's heuristic turns on acoustic diarization; I1 extends the existing insight schema; Y3 only *pushes* already-generated metadata (which lives in `_data/transcripts/*.yml`).
- **One engine per output:** per-interview insight text stays in the audit skill; the zdots `embed` job owns only cross-interview linking/search (reuses `zdots-brain query --semantic`).
- **Additive, backward-compatible schema changes:** diarization block (v-implicit) and `schema_version: 2` insights are additive; the 196 existing structured transcripts stay valid.
- Every outward-facing node (Y2–Y5, V3) has a **dry-run + explicit human-approval gate** before any live write. The gate is a two-phase job (read-only dry-run emits a diff + live-state fingerprint; a separate apply job re-verifies the fingerprint), so the worker never blocks on human input.

## Tracks and nodes

### Track 0 — Foundation
- **TASK-241** Retire spent one-shot + vendored scripts (deps: —) — ✅ executed (staged, uncommitted): 10 files removed, Rakefile cleaned, rake build + rspec (53/0) green.
- **TASK-242** Extract generic AI capabilities into zdots; keep interview-unique orchestration (deps: —) — rescoped; spans zdots repo.

### Track 1 — Transcription & Diarization
- **TASK-244** Acoustic diarization (pyannote in the zdots transcription job) + additive schema (deps: 242)
- **TASK-247** Fuse acoustic diarization into the audit skill's speaker map; repairs the `prepare_audit_prompt.rb` nil-`content` bug (deps: 244)
- **TASK-250** Backfill diarized transcripts across the corpus — coordinates TASK-124/125, TASK-022–025, unblocks TASK-031–115; exit gate = retranscribe queue at zero high-severity (deps: 247)

### Track 2 — Analysis & Insights
- **TASK-251** Extend the interview insight schema (`schema_version: 2`; era/conference/topic/interviewee context, lessons_for_now, followups, quote/timestamp reserved, cross_links) (deps: 247)
- **TASK-254** Cross-interview embedding + semantic linking (reuses existing zdots embed + pgvector; mostly verify) (deps: 251, 242)
- **TASK-255** Enrich insights with interviewee/era/conference context, sourced/uncertain-flagged (deps: 251)
- **TASK-257** Generate `_data/content_opportunities.yml` review surface (articles/playlists/shorts/linkedin/ai-discovery/research), merge-preserve on stable ids — feeds TASK-236/237/238 (deps: 254, 255)

### Track 3 — YouTube Publishing
- **TASK-245** YouTube Data API auth + `bin/lib/youtube_client.rb` (scopes: youtube.force-ssl + youtube.upload; needs `signet`) (deps: 242)
- **TASK-248** Push generated YouTube metadata (from `_data/transcripts/*.yml`) to the channel (deps: 245)
- **TASK-249** Resumable video upload pipeline; quota-bound (~6 uploads/day) (deps: 245)
- **TASK-252** Publish diarized transcripts as YouTube captions (needs timecoded turns from 247) (deps: 245, 247)
- **TASK-258** Publish playlists and Shorts (ffmpeg vertical clip → 249 uploader; playlists seed from existing `playlist:` field) (deps: 245, 257, 249)

### Track 4 — Vimeo → YouTube Migration
- **TASK-243** Inventory Vimeo-only assets + build migration set (deps: —) — ✅ executed (staged, uncommitted): `_data/vimeo_migration_manifest.yml`, 27 assets (19 caption-ready, 8 need transcription).
- **TASK-246** Download Vimeo masters (deps: 243)
- **TASK-253** Re-upload migrated Vimeo videos to YouTube (deps: 246, 249)
- **TASK-256** Retire Vimeo as a platform; repoint site — broader scope (106 assets carry a vimeo entry, 28 primary_platform vimeo, 71-file thumbs dir) (deps: 253)

## Topology
- **Entry nodes (parallel start):** TASK-241, TASK-242, TASK-243
- **Critical path:** 242 → 244 → 247 → 251 → 254 → 257 → 258
- **Cross-track joins:** Y2 (252) needs diarized transcripts (247); V3 (253) needs the upload pipeline (249); Y5 (258) needs content opportunities (257); migrated videos from V3 (253) re-enter transcription backfill (250) + captions (252) + metadata (248).
