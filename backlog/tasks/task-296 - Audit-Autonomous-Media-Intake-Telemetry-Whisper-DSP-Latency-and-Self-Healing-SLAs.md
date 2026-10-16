---
id: TASK-296
title: Audit Autonomous Media Intake Telemetry, Whisper DSP Latency & Self-Healing SLAs
status: To Do
assignee: []
created_date: '2026-10-16 11:40'
updated_date: '2026-10-16 11:40'
labels:
  - media-pipeline
  - telemetry
  - observability
dependencies:
  - TASK-291
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Review execution telemetry in `~/.local/state/just3ws/pipeline_execution_history.jsonl` and `.receipt.json` across incoming *Ramblin' & Amblin'* and *Errata* field recordings from Google Drive, verifying BPMN stage SLO compliance, upload throughput (MB/s), whisper.cpp Metal transcription accuracy, and self-healing recovery behavior.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Audit stage_durations_sec and upload_mbps across newly ingested Google Drive videos in youtube/dashboard.html (#tab-funnel and #tab-bpmn)
- [ ] #2 Verify generated _data/transcripts/<slug>.yml files and _data/video_assets.yml entries for newly processed videos
- [ ] #3 Rebuild CareerOS datalake (./bin/pipeline data generate) after new video ingestion to keep full-text transcript search current
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 All pending Google Drive uploads processed with 0 quarantined failures and indexed in career_datalake.json
<!-- DOD:END -->
