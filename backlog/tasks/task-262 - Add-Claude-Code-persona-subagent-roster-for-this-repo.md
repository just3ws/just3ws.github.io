---
id: TASK-262
title: Add Claude Code persona subagent roster for this repo
status: In Progress
assignee: []
created_date: '2026-08-25 16:47'
updated_date: '2026-08-25 16:52'
labels: []
dependencies: []
type: chore
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
AGENTS.md documents 18 "Registered Skills" (gh-fix-ci, job-lead-evaluator, site-refresh-director/builder/reviewer, transcript-*, security-*, playwright, screenshot, system-cartographer, executive-brief-generator, prose-humanity-auditor, no-em-dashes, gh-address-comments) as if they're live tooling, but none exist as real files anywhere: not in this repo's .claude/agents/, not in ~/.claude/agents/, not in the active skills list. They're aspirational documentation only.

Mike wants a full roster of Claude Code subagent personas for this repo spanning creative, consultant, fixer, copywriter, contractor, intern, expert, manager, coordinator, admin, and customer archetypes, so recurring repo work has real invocable subagents instead of aspirational docs. This includes building real subagents for all 18 already-named-but-missing roles, plus net-new personas for gaps AGENTS.md doesn't cover: SEO/structure consulting, accessibility auditing, career-strategy evaluation (implementing the existing CODEX.md contract as an invocable persona), Backlog.md task ownership, build/release operations, a supervised low-autonomy intern role, and a privacy/consent auditor formalizing a name-redaction issue found and fixed this session (a former employer's founder named without permission in resume content).

Separately, this repo has an established peer relationship with a sibling system, wwworkremote (job-search/career-intelligence side), synchronized via src/collaboration/peer_mutex.rb (CareerOS::PeerMutex) and bin/sync_career_peer.rb. The job-lead-evaluator persona and a new peer-liaison persona should be aware of this peer relationship (shared state file, job-leads bus channel) rather than treating job-lead evaluation as an isolated concern.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Every skill named in AGENTS.md's Registered Skills list has a corresponding working Claude Code subagent definition in this repo
- [x] #2 New subagents exist covering SEO/structure consulting, accessibility auditing, career-strategy evaluation, Backlog.md task ownership, build/release operations, a supervised low-autonomy research role, and privacy/consent auditing of resume content
- [x] #3 Content-facing subagents (career-strategy evaluation, executive brief generation, prose/style editing, privacy auditing) respect CODEX.md's resume-editing constraints and CONTEXT.md's 3-tier content classification
- [x] #4 The privacy/consent auditor persona is explicitly scoped to resume-facing content only and explicitly excludes the interview archive, which is a published feature and not a consent issue
- [x] #5 A persona exists that is aware of the just3ws/wwworkremote peer relationship (CareerOS::PeerMutex shared state, job-leads bus channel) for job-lead evaluation and profile-sync decisions
- [ ] #6 All new subagent definitions are discoverable by Claude Code's Agent tool without additional configuration
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Created 21 files under .claude/agents/*.md, all with plain name/description/tools frontmatter (no permissionMode/hooks fields, per a security flag on unverified research earlier in the session). Mapped all 18 AGENTS.md-named skills to 13 files (folded pairwise/quadwise where they're one pipeline: browser-qa=playwright+screenshot, security-reviewer=security-best-practices+security-threat-model, forensic-archivist=all 4 transcript-* skills). Added 8 net-new: seo-structure-consultant, accessibility-auditor, career-strategist, backlog-coordinator, build-release-operator, research-apprentice, privacy-consent-auditor, peer-liaison. Verified via grep that every file's name: field matches its filename.

BLOCKER on AC #6: attempted to smoke-test by invoking the new build-release-operator subagent via the Agent tool. It failed — 'Agent type not found. Available agents: claude, claude-code-guide, Explore, general-purpose, Plan, statusline-setup' — the original 6 built-ins only. The Agent tool's subagent_type list appears fixed at session start, not polled live, contradicting an earlier (already-flagged-as-unverified) claim that new agent files are auto-detected without a restart. Files are confirmed correctly created and formatted; discoverability itself needs verification in a fresh Claude Code session, which this session cannot perform. Leaving AC #6 unchecked and status as In Progress until Mike confirms in a new session.
<!-- SECTION:NOTES:END -->
