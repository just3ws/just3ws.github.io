---
id: TASK-297
title: Implement Local Jev-Style Decision Classifier Engine & Ingress Router
status: Done
assignee: []
created_date: '2026-10-16 14:30'
updated_date: '2026-10-16 14:35'
labels:
  - machine-learning
  - pipeline
  - classification
  - zero-egress
dependencies:
  - TASK-296
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Implement a lightweight, local-first "System One" decision classifier engine (`bin/lib/pipeline_classifier.rb`) following the Jev model pattern (emitting strictly typed JSON probability distributions over discrete choices rather than verbose generative text). Connect the classifier to the media intake pipeline for ingress archetype routing (`freeform_field_notes` vs `structured_errata` vs `technical_rewatch`) and self-healing error triage (`transient_network_retry`, `audio_codec_resample`, `credential_refresh`, `quarantine_operator_review`) with zero external cloud dependencies.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Build PipelineClassifier engine in bin/lib/pipeline_classifier.rb supporting discrete probability scoring over arbitrary option sets with zero external cloud egress
- [x] #2 Implement ingress archetype classifier routing candidate transcripts into freeform_field_notes, structured_errata, or technical_rewatch
- [x] #3 Implement self-healing error triage classifier routing pipeline exceptions into retry, resample, reauth, or quarantine decisions
- [x] #4 Write comprehensive unit tests in spec/youtube/pipeline_classifier_spec.rb with 100% passing specs
- [x] #5 Wire classifier into bin/intake_drive_video.rb and live dashboard streamer telemetry
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [x] #1 All classifier tests passing, zero em dashes, and fast validation gate passing cleanly
<!-- DOD:END -->
