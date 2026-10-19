---
id: TASK-401
title: "Digital Ephemerality with Sovereign Archiving: Rolling Horizon Sweeper & Sentiment Classifier"
status: Completed
category: media
created_date: '2026-10-19 12:50'
type: feature
priority: high
tags:
  - media-pipeline
  - digital-ephemerality
  - youtube-sweeper
  - sentiment-analysis
  - ramblin-amblin
---

## Description
<!-- SECTION:DESCRIPTION:BEGIN -->
Implements **Digital Ephemerality with Sovereign Archiving** for the Ramblin' & Amblin' series (`PLNtb969T2-l0`), adopting the **Anchor-and-Gravitational-Tail** rolling horizon:

1. **Declarative Ephemerality Configuration (`_data/media_intake_targets.yml`)**:
   - `window_days`: Sliding window (default: 3 days).
   - `carry_tail_count`: Maximum number of preceding videos carried by an active anchor (default: 2).
   - `vault_playlist_id`: Destination private vault playlist for rolled-out episodes.
   - `retired_privacy`: Video privacy status upon rollout (`private`).
   - `cherry_pick_tag`: Asset exemption flag in `_data/video_assets.yml` (`evergreen: true` or `pinned: true`).

2. **Autonomous Playlist Sweeper Integration (`bin/youtube_sweeper.rb`)**:
   - Evaluates the newest video as the **Anchor** ($T_{anchor}$).
   - If $\text{Age}(T_{anchor}) > N\text{ days}$, the anchor has expired and all videos roll out to private vault.
   - If $\text{Age}(T_{anchor}) \le N\text{ days}$, videos within $N$ days plus up to $K$ preceding videos are retained by gravity. Older unpinned videos roll out.
   - Moves rolled-out videos from public playlist to private vault playlist and updates YouTube privacy to `private`.
   - Supports `--sweep-ephemerality` (with `--apply` and dry-run default).

3. **Local Panopticon Classifier for the Self (`bin/analyze_ramblin_cadence.rb`)**:
   - Analyzes all local Whisper transcripts in `_data/transcripts/ramblin-amblin-*.yml`.
   - Computes Words Per Minute (WPM), contemplative silence / pause ratios, sentiment polarity, and lexical topic drift over time.
   - Ingests analytical metrics into SQLite / DuckDB view `v_ramblin_cadence_drift`.
<!-- SECTION:DESCRIPTION:END -->

## Execution Plan
<!-- SECTION:PLAN:BEGIN -->
- [x] Step 1: Document backlog task and design architecture.
- [x] Step 2: Add declarative `ephemerality` policy block to `_data/media_intake_targets.yml` under `ramblin-amblin`.
- [x] Step 3: Implement Anchor-and-Tail rolling horizon logic and private vault migration in `bin/lib/youtube_deduplicator.rb` and `bin/youtube_sweeper.rb`.
- [x] Step 4: Write unit and characterization specs for ephemerality logic in `spec/youtube/playlist_dedupe_spec.rb` and `spec/youtube/youtube_sweeper_spec.rb`.
- [x] Step 5: Implement `bin/analyze_ramblin_cadence.rb` to extract sentiment, WPM cadence, and lexical drift across Whisper transcripts into the ecosystem datalake (`v_ramblin_cadence_drift`).
- [x] Step 6: Verify fast validation, datalake build, and test suite clean passes.
<!-- SECTION:PLAN:END -->
