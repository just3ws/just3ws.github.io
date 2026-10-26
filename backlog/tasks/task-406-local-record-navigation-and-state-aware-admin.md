---
id: TASK-406
title: "Implement Operations Cockpit Local Record Navigation and State-Aware Admin Interface"
status: Completed
category: media
created_date: '2026-10-26 02:55'
type: feature
priority: high
tags:
  - media-pipeline
  - operations-cockpit
  - ui-navigation
  - pre-flight-editing
  - race-condition-guard
---

## Description
<!-- SECTION:DESCRIPTION:BEGIN -->
Addresses user feedback on Operations Cockpit usability and lifecycle administration:

1. **Operations Cockpit Navigation**:
   - Provide direct navigation links into local video entries (`/media_assets/:id`) and editing views (`/media_assets/:id/edit`) across all swimlane columns (Staged, Pending, Processing, Processed, Blocked, Failed).
   - In Processed cards, provide direct clickable links to both the published YouTube video and the series playlist.
   - In the Recent Pipeline Executions table, make asset titles clickable links to `/media_assets/:id` with explicit `[Edit]` action links.
   - In dynamic SSE updates (`renderSwimlanesFromPayload`), preserve and render all clickable navigation links.

2. **State-Aware Administration & Race Condition Prevention**:
   - Show a prominent lifecycle state banner and BPMN substate badges in `/media_assets/:id/edit` and `/media_assets/:id`.
   - When an asset is `processing`, display an active warning indicating that background STT metadata synthesis is in flight to prevent race conditions.
   - When an asset is `pending`, present a Pre-Flight Mode banner explaining that operator edits will be preserved as canonical overrides when the worker starts processing.
   - Provide the operator with an explicit choice via separate submission buttons:
     - `Save Local Record Only`: Updates the local database, YAML sidecar, and static site knowledge system without touching the YouTube API.
     - `Save & Push to YouTube Now`: Pushes metadata changes directly to the remote YouTube video via `videos.update` without video re-upload.

3. **Pre-Flight Metadata Override Preservation**:
   - In `ProcessMediaAssetJob#resolve_metadata`, honor operator-entered pre-flight titles, descriptions, tags, and privacy settings before falling back to speech hooks or templates.

4. **Specification Updates**:
   - Keep `purpose-specification.md`, `original-pipeline-specification.md`, and `feature-migration-matrix.md` synchronized across both repositories.
<!-- SECTION:DESCRIPTION:END -->

## Execution Plan
<!-- SECTION:PLAN:BEGIN -->
- [x] Step 1: Update `app/views/dashboard/_tab_queue.html.erb` and `_scripts.html.erb` to include record links, edit actions, and playlist links across all swimlane cards and execution rows.
- [x] Step 2: Update `app/views/media_assets/edit.html.erb` and `show.html.erb` with lifecycle state banners, substate progress badges, and separate local vs YouTube push buttons.
- [x] Step 3: Update `MediaAssetsController#update` to honor `save_local` vs `save_and_push` commit actions.
- [x] Step 4: Update `ProcessMediaAssetJob#resolve_metadata` to preserve manual pre-flight metadata.
- [x] Step 5: Update specification documents in both repositories.
- [x] Step 6: Verify RSpec test suite, RuboCop, and Markdown validators pass cleanly with zero em dashes.
<!-- SECTION:PLAN:END -->
