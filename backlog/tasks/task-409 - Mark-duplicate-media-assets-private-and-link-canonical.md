---
id: TASK-409
title: Mark duplicate media assets private and link canonical
status: In Progress
assignee: []
created_date: '2026-11-07T01:52:00Z'
updated_date: '2026-11-07T01:53:00Z'
labels: []
dependencies: []
documentation:
  - AGENTS.md
  - docs/workflow-map.md
  - app/models/media_asset.rb
  - app/controllers/media_assets_controller.rb
  - app/services/site_sync_service.rb
  - spec/requests/media_assets_spec.rb
modified_files:
  - app/models/media_asset.rb
  - app/controllers/media_assets_controller.rb
  - config/routes.rb
  - app/views/media_assets/show.html.erb
  - spec/requests/media_assets_spec.rb
  - docs/workflow-map.md
priority: high
type: feature
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Add an operator action on a media asset that sets its linked YouTube video to private, marks the record as a duplicate, links it to a canonical asset in the same target, retracts the private video from public site surfaces, and records an audit event. Preserve the source and YouTube identity so the owner can prune deliberately after confirming the canonical original.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 An operator can select a different canonical asset from the same media target and mark the current asset as its duplicate.
- [ ] #2 When the duplicate has a YouTube video ID, YouTube must confirm the privacy update to private before the local record is marked duplicate.
- [ ] #3 On success, the duplicate record has private privacy, duplicate status, a canonical asset link, no evergreen pin, and an audit event with the canonical ID and source.
- [ ] #4 Public site manifests and transcript exports are retracted through the existing SiteSyncService privacy path.
- [ ] #5 The asset page displays the canonical link and offers the duplicate action only when the asset is not already a duplicate or in active work.
- [ ] #6 Invalid canonical links and remote privacy failures leave local duplicate state unchanged and produce a clear operator message.
- [ ] #7 No source file or YouTube video is deleted by this action.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Context brief (L2)
- Existing identity: `MediaAsset#duplicate_of` and the `duplicate` AASM state already represent linked duplicates. `MediaContentIdentityService` records duplicate events and Panoramic checkpoints for byte-identical intake.
- Existing privacy path: `MediaAsset#update_privacy!`, `YoutubeClient#set_video_privacy`, the `set_privacy` member route, and the visibility buttons. Existing privacy sync updates the public site through `SiteSyncService#retract_from_public_archive!`.
- Existing audit/UI: `MediaAsset#record_event!`; the show page already renders a duplicate link and offers privacy buttons. Preserve unrelated user edits in the controller and edit view.
- Main risk: changing local status before YouTube confirms privacy could leave a public video mislabeled. Make the operator operation remote-first and fail closed. Reject self/cross-target/canceled/duplicate canonical links and assets in active work. Site retraction occurs after the record change; surface a specific partial-failure message if it fails.
- Reuse those local patterns. No migration and no destructive source or YouTube deletion are needed.

## Plan
1. Add a model operation that validates the canonical asset, confirms YouTube privacy is `private` when a video ID exists, then sets local privacy, duplicate link/state, clears evergreen, records an operator event, and emits the existing Panoramic duplicate checkpoint.
2. Add a POST member route and controller action with clear invalid-link, remote failure, and public-site sync failure feedback.
3. On the asset detail page, show the canonical link and provide a same-target canonical selector/action only for eligible assets. State clearly that source and YouTube record remain available for later pruning.
4. Add the operator-resolution contract to the workflow documentation.
5. Run Ruby syntax checks and focused lint on changed files, inspect the final diff, and leave the real queue and YouTube assets untouched.
<!-- SECTION:PLAN:END -->
