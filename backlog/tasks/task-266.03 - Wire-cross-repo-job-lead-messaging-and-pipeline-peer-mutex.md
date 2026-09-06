---
id: TASK-266.03
title: Wire cross-repo job-lead messaging and pipeline peer mutex
status: To Do
assignee: []
created_date: '2026-09-06 16:58'
updated_date: '2026-09-06 16:58'
labels:
  - outreach
  - career-os
  - message-bus
  - synchronization
dependencies: []
documentation:
  - docs/direct-hiring-manager-outreach-playbook.md
  - src/collaboration/peer_mutex.rb
  - bin/sync_career_peer.rb
modified_files:
  - src/collaboration/peer_mutex.rb
  - docs/direct-hiring-manager-outreach-playbook.md
parent_task_id: TASK-266
priority: medium
type: integration
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Connect the zdots message bus (`job-leads` channel) with `agent-wwworkremote` to synchronize target job lead states between `just3ws` and `wwworkremote`. Track outreach lifecycle states (lead discovered, brief generated, outreach sent, response received, interview scheduled) in `CareerOS::PeerMutex` and the status table in `docs/direct-hiring-manager-outreach-playbook.md`.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Validate zdots bus participant registration for `agent-just3ws` on the `job-leads` channel.
- [ ] #2 Implement lead sync handler in `bin/sync_career_peer.rb` to consume new leads and update `CareerOS::PeerMutex`.
- [ ] #3 Document bidirectional message schema for lead status transitions and outreach timestamp tracking.
- [ ] #4 Add verification test ensuring mutex state transitions avoid race conditions across local repos.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 Cross-repo messaging and peer mutex synchronization pass integration verification.
<!-- DOD:END -->
