---
id: TASK-408
title: Prepare creator launch and engineering inquiry path
status: In Progress
assignee: []
created_date: '2026-11-05T20:07:00Z'
updated_date: '2026-11-05T20:16:00Z'
labels: []
dependencies: []
documentation:
  - docs/patreon-integration-guide.md
  - docs/lived-history-photo-timeline.md
  - docs/persona-review-council.md
modified_files:
  - _data/engagements.yml
  - _data/lived_history_timeline.yml
  - _data/patreon_campaign.yml
  - _sass/_p_timeline.scss
  - bin/lib/ecosystem_datalake.rb
  - docs/ecosystem-history-and-datalake-chronology.md
  - docs/lived-history-photo-timeline.md
  - docs/runbooks/creator-launch.md
  - docs/runbooks/timeline-context-roadmap.md
  - docs/style-guide-and-canonical-naming.md
  - engagements/index.html
  - support.md
  - timeline/community/index.html
  - timeline/index.html
  - timeline/lived-history/index.html
  - spec/youtube/patreon_and_staging_spec.rb
type: feature
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Mike authorized a small launch using the existing public archive, free following and a $5 Studio Notes membership, with one bounded engineering offer. Visitors currently reach a coming-soon support page; the recent timeline remains local. The launch must preserve archive evidence and avoid promising a schedule or unpublished benefits.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Timeline readers can reach an honest support invitation and see a real example of the proposed notes.
- [x] #2 A bounded engineering inquiry describes the problem, deliverable, and next contact step without invented pricing or availability.
- [x] #3 Three reviewed promotion drafts and launch instructions are available without sending messages.
- [x] #4 Historical discrepancies affecting promoted stories are resolved against evidence or explicitly held.
- [ ] #5 Build, rendered links, public boundary, and desktop/mobile checks have recorded results and limitations.
- [ ] #6 Public deployment and Patreon signup are verified, or concrete access and release blockers are recorded without claiming launch.
- [x] #7 Timeline research cites primary guidance and applies guided project threads, a complete event index, source limitations, shareable events, and correction paths while preserving existing records.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Use existing editorial layouts and support styles to add a modest timeline invitation, an evidence-based Studio Notes example, and a bounded engineering inquiry using the existing contact route. Preserve Patreon draft gating until live publication can be verified. Resolve promoted historical wording against primary public transcripts. Prepare three unsent promotion drafts and a launch checklist outside the public build. Run focused rendered-link and campaign-state checks, required public-boundary audit, installed localhost verification, and independent council/browser review. Audit accumulated commits before any production push; record access limitations honestly.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
User expanded scope to research timeline best practices and comprehensive project context. Added four curated threads and a linked event index; preserved the chronology and event-level evidence. Research/design brief and staged possibilities are in excluded docs/runbooks/timeline-context-roadmap.md. Independent provenance review found no primary evidence for the Redpoint floor; removed the number, replaced an altered quote with attributed prose, and narrowed an unsupported influence claim. Existing timeline/OneMain route corrections are preserved.

Implementation committed locally as 90a39f2e; stale Patreon credits test corrected in 5480b230. No source promotion was sent. Campaign status remains draft because current Patreon/live signup could not be verified. Existing media/generated artifacts remain unstaged.

Validation: validate:fast and rake publish_check passed; final production and development builds passed (1062/1066 pages; zero accessibility markup warnings). Installed timeline/support/engagement pages returned HTTP 200. Four-page production DOM checks passed single main/H1, unique IDs, local links and fragments; runbooks and local cockpit excluded from production. Liquid checks covered draft (zero Patreon links) and published (free plus $5/month) states. Five focused Patreon CLI RSpec examples pass. Graphify refreshed.

Independent council: keep scoped content, trails, source limitations, AI-assisted sample, and separate engineering inquiry. Minor draft heading corrected. Source/DOM reviewer found no new blocker/major regression. Full visual reviewer requests changes pending real desktop and 375px browser/keyboard evidence; Chrome aborts and alternative browser binaries are absent.

Release remains open. Production/GitHub DNS and API access fail; Patreon campaign API lookup fails. Strict public-surface audit exits 1 with 1337 findings, including 1246 high-risk detector matches and 841 quarantined uncertainty claims across existing source. Many are broad heuristics or intentional public contacts; no blanket decisions were fabricated. Required contextual review must finish before production publication. Existing global /obs/ navigation target is unresolved, outside this slice. No push or Patreon publication occurred.
<!-- SECTION:NOTES:END -->
