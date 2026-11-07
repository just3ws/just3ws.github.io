---
id: TASK-409
title: Mark duplicate media assets private and link canonical
status: In Progress
assignee: []
created_date: '2026-11-07T01:52:00Z'
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
