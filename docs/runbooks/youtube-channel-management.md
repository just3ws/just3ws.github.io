# Runbook: YouTube Channel Management & Sync Pipeline

This runbook documents the architecture, CLI commands, safety guardrails, and validation contracts for managing the technical interview and conference talk video archive on YouTube.

---

## 1. Architecture Overview

```
[ Local Canonical Archives ]
  - _data/transcripts/*.yml
  - _data/research/*.json
  - assets/subtitles/*.vtt
            │
            ▼
[ 1:1 Parity Metadata Generator ]  ───►  _data/video_assets.yml (Jekyll Site)
  (bin/generate_youtube_metadata.rb) ──►  _data/youtube_metadata_staged.json
            │
            ▼
[ Validation Suite & Schemas ]
  - src/validators/site_schema.rb (Validators::YouTubeStagedMetadataContract)
  - spec/schemas/youtube_metadata_staged_schema.json
  - spec/youtube/youtube_metadata_spec.rb
            │
            ▼
[ YouTube Data API v3 Client ]
  - .credentials/youtube_oauth.json (OAuth2 Refresh Token)
  - bin/publish_youtube_metadata.rb (Titles, Descriptions, Chapters, Tags)
  - bin/sync_youtube_captions.rb (Timed WebVTT Subtitles)
```

---

## 2. Safety Guardrails & Principles

1. **A4 Guardrail (No Un-Gated Writes)**:
   - Always perform a `--dry-run` inspection before applying updates to YouTube.
   - Review generated markdown reports in `tmp/youtube-dry-run-report.md`.
2. **Rate Limiting & Quota Budgeting**:
   - Google Cloud provides a default daily quota of **10,000 units/day** (resets at Midnight PST / 02:00 CST).
   - `videos.update` costs **50 units/video**.
   - `captions.insert` costs **50 units/caption**.
   - All tools implement automatic exponential backoff (2s, 4s, 8s) and graceful halting on 403 `quotaExceeded`.
3. **State Checkpointing & Idempotency**:
   - Updates are tracked in `tmp/youtube_metadata_sync_state.json` and `tmp/youtube_captions_sync_state.json`.
   - Re-running tools automatically skips already updated assets without consuming API quota.

---

## 3. CLI Command Reference

### A. Authorizing Google Cloud OAuth (One-Time Setup)
```bash
# Starts local listener and prompts for OAuth approval:
ruby bin/authorize_youtube_oauth.rb

# Test active channel connection and quota status:
ruby bin/publish_youtube_metadata.rb --check-auth
```

### B. Generating 1:1 Metadata & Chapters
```bash
# Enriches _data/video_assets.yml and stages _data/youtube_metadata_staged.json:
ruby bin/generate_youtube_metadata.rb

# Run contract tests to verify 1:1 parity and schema compliance:
bundle exec rspec spec/youtube/youtube_metadata_spec.rb
```

### C. Publishing Video Titles, Descriptions & Chapters
```bash
# 1. Preview changes and calculate quota costs in dry-run mode:
ruby bin/publish_youtube_metadata.rb --dry-run

# 2. Update a single video:
ruby bin/publish_youtube_metadata.rb --video-id nZSaZ2kETT8 --apply

# 3. Batch update videos (e.g. 25 videos):
ruby bin/publish_youtube_metadata.rb --apply --limit 25
```

### D. Uploading WebVTT Subtitle Caption Tracks
```bash
# 1. Validate caption track availability:
ruby bin/sync_youtube_captions.rb

# 2. Upload subtitles to a single video:
ruby bin/sync_youtube_captions.rb --video-id nZSaZ2kETT8 --upload

# 3. Batch upload subtitle tracks (e.g. 25 videos):
ruby bin/sync_youtube_captions.rb --upload --limit 25
```
