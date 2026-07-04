---
id: TASK-256
title: Retire Vimeo as a platform
status: To Do
assignee: []
created_date: '2026-07-04 09:24'
updated_date: '2026-07-04 14:28'
labels:
  - pipeline
  - vimeo
milestone: Interview Archive Pipeline
dependencies:
  - TASK-253
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Once content lives on YouTube, repoint the site off Vimeo: update embeds/players to YouTube, reconcile or remove the Vimeo thumbs (assets/vimeo/thumbs/*), and drop Vimeo from the platform records in _data. Structure/presentation cleanup — the final step of the migration.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Site players/embeds point at YouTube, not Vimeo
- [ ] #2 Vimeo thumbs are reconciled or removed
- [ ] #3 Vimeo is dropped from platform records in _data
- [ ] #4 No broken links/images; rake build and repo hygiene are green
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Retire Vimeo as a platform (structure/presentation — the final step)

### Retirement set (bigger than the migration set — do not undercount)
- Migration set was 27 (vimeo-only). Retirement touches EVERY asset carrying a vimeo entry: **106 assets** in `_data/video_assets.yml` have a `platform: vimeo` entry, and **28 have `primary_platform: vimeo`** (27 = the vimeo-only just migrated; the 1 extra already has a youtube id but a stale `primary_platform`). All must be reconciled, not just the 27.

### Per-asset migration-complete gate (safety)
- Only strip an asset's vimeo entry once that asset has a confirmed youtube `asset_id` in `platforms[]`. Stripping vimeo from an asset with no youtube entry would leave `platforms[]` empty → template preferred=nil → broken/blank embed. Drive removal off the manifest (`migration_state` at `public`/`retired`) or a live check for a youtube platform id. Any TASK-253 failure leaves that one asset on vimeo rather than breaking it.

### Templates rendering Vimeo embeds (mostly data-driven — auto-repoint)
The players already bias to youtube and iterate `platforms[]`, so dropping vimeo from records repoints them with no template edits:
- `_includes/video-stage.html` — the actual `<iframe>/<video>` embed. `preferred = platforms where youtube | else primary_platform | else first`. Also renders a "Watch on {{platform}}" link per `platforms[]` entry (the vimeo link disappears when the entry is removed).
- `_includes/schema-factory.html` — JSON-LD `embedUrl`/`contentUrl`/`sameAs` (two blocks, ~L94 and ~L179) use the same youtube-first `preferred`. Auto-corrects.
- `_includes/video-asset-player.html` — same youtube-first `preferred` selection (L19-23).
- Layouts `_layouts/video_asset.html` + `_layouts/interview.html` include the above (no direct vimeo).
Explicit vimeo code to REMOVE:
- `_includes/interview-card.html` L2 `{% assign vimeo = asset.platforms | where: "platform","vimeo" | first %}` (dead var) and simplify the L4 fallback chain `youtube | default: vimeo | default: platforms.first` → `youtube | default: platforms.first`.

### Data changes
- Remove every `platform: vimeo` entry from `_data/video_assets.yml` `platforms[]` (106 assets), gated per-asset as above.
- Flip remaining `primary_platform: vimeo` → `youtube` (28 assets).
- Leave scmc_videos.yml `video_asset_id: vimeo-<id>` **slugs as-is** — they are stable identifiers/URLs, not live vimeo links; renaming would break interview links. Note as intentionally out of scope.

### Thumbnails
- `assets/vimeo/thumbs/ugtastic/` holds 71 `.jpg`; `_data/video_assets.yml` has 140 `thumbnail_local: /assets/vimeo/thumbs/...` refs (asset-level + platform-level). Options: (a) keep the local jpgs and just repoint refs to the youtube thumbnail, or (b) remove the vimeo thumbs dir and null the `thumbnail_local` so templates fall back to `thumbnail`/youtube thumb (`interview-card.html` L6 chain, `video-stage.html` poster). Choose one and apply consistently; verify no template still points at a deleted path.

### Validation ("green")
- `validate_repo_hygiene.rb` only asserts the top-level file/dir allowlist (`_data/repo_hygiene.yml`) + `/backlog/docs/` link routing — it does NOT scan `assets/` for orphaned thumbs, so removing thumbs won't trip it but also won't catch a dangling ref. Therefore ALSO: `rake build` (generate:all + jekyll build) must be clean, and grep the built `_site/` + templates for any surviving `vimeo.com`/`player.vimeo.com`/`/assets/vimeo/` to prove no broken embed/image/link remains.
- Full gate: `rake ci` (build + rspec + validate:all) green; `./bin/pipeline smoke` if repointed players need a browser check.

### Acceptance mapping
- AC#1: embeds/players point at youtube (achieved by dropping vimeo entries; interview-card dead var removed).
- AC#2: vimeo thumbs reconciled (repointed) or removed, with zero dangling refs.
- AC#3: vimeo dropped from all platform records (106) + primary flipped (28), gated per-asset.
- AC#4: no broken links/images; `rake ci` + hygiene green; `_site` grep clean of vimeo.

### Boundary
Pure structure/presentation (in-scope per CLAUDE.md). No content edits. Planning only now.
<!-- SECTION:PLAN:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->
