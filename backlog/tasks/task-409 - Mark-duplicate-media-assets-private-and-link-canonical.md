---
id: TASK-409
title: Mark duplicate media assets private and link canonical
status: Done
assignee: []
created_date: '2026-11-07T01:52:00Z'
updated_date: '2026-11-07T02:12:00Z'
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
  - AGENTS.md
  - app/controllers/media_assets_controller.rb
  - app/models/media_asset.rb
  - app/views/media_assets/show.html.erb
  - config/routes.rb
  - docs/workflow-map.md
  - spec/requests/media_assets_spec.rb
  - spec/services/site_sync_service_spec.rb
priority: high
type: feature
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Add an operator action on a media asset that sets its linked YouTube video to private, marks the record as a duplicate, links it to a canonical asset in the same target, retracts the private video from public site surfaces, and records an audit event. Preserve the source and YouTube identity so the owner can prune deliberately after confirming the canonical original.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 An operator can select a different canonical asset from the same media target and mark the current asset as its duplicate.
- [x] #2 When the duplicate has a YouTube video ID, YouTube must confirm the privacy update to private before the local record is marked duplicate.
- [x] #3 On success, the duplicate record has private privacy, duplicate status, a canonical asset link, no evergreen pin, and an audit event with the canonical ID and source.
- [x] #4 Public site manifests and transcript exports are retracted through the existing SiteSyncService privacy path.
- [x] #5 The asset page displays the canonical link and offers the duplicate action only when the asset is not already a duplicate or in active work.
- [x] #6 Invalid canonical links and remote privacy failures leave local duplicate state unchanged and produce a clear operator message.
- [x] #7 No source file or YouTube video is deleted by this action.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [x] #1 AC criteria is completed and the change has been verified
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

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Implemented the operator duplicate action in the media-pipeline worktree. It makes an attached YouTube video private first and requires a private status in the API response before local mutation. It then records the duplicate link and state, clears evergreen, appends an operator event and Panoramic checkpoint, and uses SiteSyncService to retract public site entries. The action rejects active work, canceled assets, cross-target canonical records, and unresolved YouTube upload sessions. No source or YouTube video is deleted.

Verification: Ruby syntax checks passed; RuboCop passed on the changed Ruby files; Rails route listing shows POST /media_assets/:id/mark_duplicate; Rails ERB compilation passed; live GET for asset 319 returned HTTP 200 and the duplicate action and canonical selector were present; docs/workflow-map.md passed mdl; graphify update completed. RSpec was not run and no real asset action was submitted. The service queue and YouTube assets were left unchanged.

The AGENTS.md whole-file markdown lint reports formatting issues in older sections (MD005, MD007, MD022, MD031, MD032). The new current-focus entry adds no reported lint errors.

Final validation: full RSpec and the pre-commit verification hook passed with 353 examples and 0 failures. bin/mp-lint passed RuboCop, ERB lint, Prettier, Markdown lint, YAML/JSON validation, Mandoc, Brakeman with 0 warnings, and zero-em-dash checks. The focused asset and SiteSync specs passed with 25 examples. The site-sync regression proves private assets are removed from the public manifest and unreferenced transcript export.

Commit 7455a2a feat(media): mark reviewed duplicates private includes only this feature. The two earlier local commits cc029c7 and 84c9bdf are also ahead of origin/main. Push was attempted twice, including a one-command DNS bypass. GitHub HTTPS is reachable by resolved IP, but the GitHub CLI token is invalid, osxkeychain cannot provide a credential in this execution environment, and SSH fails because UID 501 has no user record. No remote refs changed. Reauthenticate GitHub CLI and configure git credential integration before retrying push.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Implemented and committed the operator action that makes a reviewed duplicate private, links it to a canonical asset, records audit and Panoramic provenance, and retracts public site entries without deleting source or YouTube media. Live detail rendering, all 353 RSpec examples, full media-pipeline lint and verification gates passed. Commit 7455a2a is local; push remains pending because this environment has no usable GitHub credential and its system resolver fails for github.com. Unrelated dirty worktree changes were not staged.
<!-- SECTION:FINAL_SUMMARY:END -->
