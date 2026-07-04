---
id: TASK-245
title: YouTube Data API auth and publish client
status: To Do
assignee: []
created_date: '2026-07-04 03:23'
updated_date: '2026-07-04 14:27'
labels:
  - pipeline
  - youtube
milestone: Interview Archive Pipeline
dependencies:
  - TASK-242
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Stand up OAuth credentials and a thin YouTube Data API client, exposed as zdots publish jobs (following the queue pattern). This is the foundation for captions, metadata sync, video upload, and playlist/shorts publishing. No live writes beyond an authenticated read/quota check in this task.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 OAuth flow completes and refresh credentials for the channel are stored securely
- [ ] #2 A thin client wraps the captions/videos/playlists endpoints
- [ ] #3 Publish actions run as zdots jobs (retry/idempotent)
- [ ] #4 An authenticated dry-run (read channel + quota) is verified; no live writes in this task
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Foundation: OAuth + thin YouTube Data API client as zdots publish jobs

This task is the shared substrate for TASK-248/249/252/258. No live writes here beyond an authenticated read.

### OAuth scopes (unified set for the whole publishing track)
- `https://www.googleapis.com/auth/youtube.force-ssl` — read + write incl. **captions** (captions.* REQUIRE force-ssl); covers videos.list/update, playlists.*, playlistItems.*.
- `https://www.googleapis.com/auth/youtube.upload` — resumable videos.insert (TASK-249/258 Shorts).
- (Reads for dry-runs are covered by force-ssl; no separate youtube.readonly needed.)
- App type: **Desktop/Installed** OAuth client (loopback/OOB redirect). Single channel (owner is the user), so a one-time consent → long-lived refresh token.

### Credential storage (never committed)
- Client secret + refresh token live outside git. `.env` is already gitignored. Store `YT_CLIENT_ID` / `YT_CLIENT_SECRET` in `.env`, and the obtained refresh token in a gitignored file (e.g. `.credentials/youtube_oauth.json`) or `YT_REFRESH_TOKEN` env. Add `.credentials/` to `.gitignore`.
- Access tokens are ephemeral (refreshed at runtime, never persisted to repo).

### Client dependency decision
- Gemfile already has `faraday` + `faraday-retry` + `faraday-multipart` (good for resumable multipart) but **no** signet/google-auth. Choose one and record it: add `signet` (+ optionally `google-apis-youtube_v3`) for OAuth refresh, OR hand-roll the refresh grant over faraday. Recommendation: add `signet` for the token flow, keep API calls on the existing faraday stack to stay thin.

### Thin client
- New shared module (e.g. `bin/lib/youtube_client.rb`, mirroring `bin/archive/modules/*.rb`): OAuth refresh + a thin wrapper over the endpoints the track needs:
  - videos: `videos.list`, `videos.update`, resumable `videos.insert`, thumbnails.set
  - captions: `captions.list`, `captions.insert`, `captions.update`, `captions.delete`
  - playlists: `playlists.list/insert`, `playlistItems.list/insert`
- Loaders resolve the transcript→asset join (transcript stem = `transcript_id` → `_data/video_assets.yml` item → `platforms[youtube].asset_id`).

### zdots publish jobs (reuse batch_ztranscribe pattern)
- New job types on the queue following `bin/batch_ztranscribe.rb` / doc-041: `youtube_metadata` (248), `youtube_upload` (249), `youtube_captions` (252), `youtube_playlist` + `youtube_short` (258). Enqueue via `zdots-ctx enqueue <type> '<json>'` / `ctx_enqueue`; worker drains; fingerprint-idempotent + retried.

### Two-phase dry-run / approval gate (defined here, referenced by 248/249/252/258)
- **Never block the worker for human input** (same failure class as the ffmpeg/stdin hang in doc-041). Instead:
  1. **Dry-run job** — read-only: fetch live state, compute desired-vs-live diff, emit a diff artifact + a fingerprint of live state. No writes.
  2. Human reviews the artifact and approves.
  3. **Apply job** — separate enqueue carrying the approval token; before writing it **re-verifies the live-state fingerprint still matches the dry-run** and aborts on drift (so a stale diff is never rubber-stamped).

### Quota (YouTube Data API v3, default 10,000 units/day)
Per-call: videos.list 1 · videos.update 50 · videos.insert 1600 · captions.list 50 · captions.insert 400 · captions.update 450 · captions.delete 50 · playlists.insert 50 · playlistItems.insert 50 · search.list 100 (avoid — use stored asset_ids). Aggregate budgeting lives in the consuming tasks.

### Verification (AC#4 — no live writes)
- Run an authenticated read-only dry-run: `channels.list(mine=true)` + a `videos.list` on a known asset_id → confirms OAuth refresh works and prints remaining quota headroom. Zero write calls in this task.

### Files touched
- `bin/lib/youtube_client.rb` (new), `Gemfile`/`Gemfile.lock` (signet), `.gitignore` (`.credentials/`), `.env` (local only, ungit). Reads: `_data/video_assets.yml`, `_data/transcripts/*.yml`.
<!-- SECTION:PLAN:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->
