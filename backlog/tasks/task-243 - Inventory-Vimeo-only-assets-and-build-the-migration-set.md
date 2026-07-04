---
id: TASK-243
title: Inventory Vimeo-only assets and build the migration set
status: To Do
assignee: []
created_date: '2026-07-04 03:23'
updated_date: '2026-07-04 14:27'
labels:
  - pipeline
  - vimeo
milestone: Interview Archive Pipeline
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Identify every video_asset hosted only on Vimeo (no youtube platform id) and produce a migration manifest — asset id, vimeo id, title, interview slug, current transcript/caption status. This is the discovery gate for the Vimeo→YouTube re-upload; nothing migrates until this set is known and reviewed.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 A manifest of all Vimeo-only assets is generated from _data
- [ ] #2 Each entry maps vimeo id → interview slug → current transcript/caption status
- [ ] #3 The manifest is committed as a review surface (yml or backlog doc) for sign-off before migration
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Discovery gate: inventory Vimeo-only assets → migration manifest

### Sole hosting source (verified)
- Video hosting/platform records live ONLY in `_data/video_assets.yml` (`items[].platforms[]`, each `{platform, asset_id, url, embed_url, ...}`). 207 items total.
- `_data/scmc_videos.yml`, `oneoff_videos.yml`, `interview_related_videos.yml`, `interviews.yml` reference assets by **id** (`video_asset_id`/`slug`), they carry NO independent vimeo embed. scmc_videos.yml's `video_asset_id: vimeo-<id>` slugs are just identifiers for a subset of the standalone assets below; do not treat as extra hosting.

### Detection rule (Vimeo-only)
An asset is in the migration set iff its `platforms[]` contains a `platform == "vimeo"` entry AND contains NO `platform == "youtube"` entry (compare on presence of `asset_id`).
Ruby detection (read-only):
```ruby
pids = ->(it,n){ (it["platforms"]||[]).select{|p| p["platform"]==n}.map{|p| p["asset_id"]} }
vimeo_only = items.select{|it| !pids.(it,"vimeo").empty? && pids.(it,"youtube").empty? }
```
Result computed during planning: **27 Vimeo-only assets** (none has >1 vimeo id).
- 13 have `interview_id` → map to `_data/interviews.yml` (slug = interview id where `video_asset_id == asset.id`).
- 14 are standalone (`vimeo-<id>` ids + 2 `mike-hall-*` solo talks), no interview_id; 12 of these are cross-listed in `scmc_videos.yml`.
- Contrast (context only, NOT this task): 106 assets carry a vimeo platform entry (retirement scope for TASK-256); 28 have `primary_platform: vimeo`.

### Transcript / caption status
- Transcripts resolve via Jekyll as `site.data.transcripts[transcript_id]`, i.e. file `_data/transcripts/<transcript_id>.yml` (196 files). Status = structured if that file has non-empty `turns` (or `content`), else none.
- Computed: **19 of 27 have structured transcripts**, 8 have none.
- Captions: pre-migration there are NO YouTube caption tracks for these (they only live on Vimeo). So define caption status as derived, not a separately-populated field: the 19 with transcripts are **caption-ready** (existing transcript → YouTube caption track in TASK-252); the 8 without are **needs-transcription** first (TASK-250). State this relationship in the manifest rather than an unpopulatable column.

### Manifest format (review surface for sign-off)
Generate `_data/vimeo_migration_manifest.yml` from a small read-only `bin/` script (build/inspection input, not a hand-edited data file). Per-entry shape:
```yaml
generated_at: <iso8601>
source: _data/video_assets.yml
total_vimeo_only: 27
items:
  - asset_id: dave-thomas-software-craftsmanship-north-america-2013
    vimeo_id: '90550222'
    vimeo_url: https://vimeo.com/90550222
    title: '...'
    interview_slug: dave-thomas-...-2013   # null for standalone
    primary_platform: vimeo
    duration_seconds: 861                  # from vimeo platform entry (integrity ref for TASK-246)
    thumbnail_local: /assets/vimeo/thumbs/ugtastic/90550222.jpg
    transcript_id: dave-thomas-...-2013     # null if none
    transcript_status: structured           # structured | none
    transcript_turns: 61
    caption_readiness: caption-ready        # caption-ready | needs-transcription
    youtube_id: null                        # populated by TASK-253
    migration_state: pending                # pending|downloaded|uploaded|unlisted|public|retired
```

### Acceptance mapping
- AC#1: script emits `_data/vimeo_migration_manifest.yml` with all 27 entries derived from `_data`.
- AC#2: each entry carries vimeo_id, interview_slug, transcript_status + caption_readiness.
- AC#3: commit the manifest (yml) as the review/sign-off surface; migration_state gates downstream tasks. Add a summary line (27 total / 19 caption-ready / 8 needs-transcription / 13 interview-linked / 14 standalone).

### Boundary
Structure/data only — no content edits to titles/descriptions. Manifest is generated, reviewed, then TASK-246 consumes it.
<!-- SECTION:PLAN:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->
