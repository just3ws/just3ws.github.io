---
id: TASK-262
title: Add Claude Code persona subagent roster for this repo
status: In Progress
assignee: []
created_date: '2026-08-25 16:47'
updated_date: '2026-08-25 17:35'
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

AC#6 blocked, root cause identified: this Claude Code session's `Agent` tool subagent_type roster is fixed at process start and does not rescan `.claude/agents/` mid-session — confirmed by re-testing `build-release-operator` after a full context compaction/continue, which still returned only the 6 built-in types (claude, claude-code-guide, Explore, general-purpose, Plan, statusline-setup). Ruled out as causes: all 21 persona files confirmed present in `.claude/agents/` with correct filenames; no `.claude/settings.json` exists; `.claude/settings.local.json` contains only a Bash/Read permission allowlist, nothing that restricts or filters subagent types. This narrows the blocker to session-lifecycle behavior of the Agent tool itself, not a file or config defect on this repo's side. Verification requires a genuinely new `claude` process (new terminal invocation in this repo) attempting to invoke one of the 21 personas directly — this cannot be performed from inside an existing session, however long-running or compacted. Handed to Mike to run that check; if a fresh process still can't see them, next suspects are the installed Claude Code CLI version or a `claude-code-guide` lookup on subagent-file discovery requirements.

Correction to the AC#6 root-cause note above: it's not a universal hard rule. Confirmed via the zdots bus (job-leads/general, 2026-08-25) that agent-wwworkremote's 12 new personas in wwworkremote/core showed up in that session's Agent-tool listing immediately after being written, no restart needed -- verified for real against their git log (b5522475), not just their say-so. So this repo's specific block (build-release-operator and siblings still invisible after a full compaction/continue) is session/timing-dependent behavior, not evidence that fresh-process verification is the only path. Still recommend Mike test a fresh `claude` process here as the reliable fallback, but don't treat same-session failure as proof it can never work same-session.

CORRECTION to this task's own description: it claims none of the 18 AGENTS.md-named skills 'exist as real files anywhere... not in the active skills list. They're aspirational documentation only.' That's wrong for 5 of them -- job-lead-evaluator, executive-brief-generator, system-cartographer, prose-humanity-auditor, and no-em-dashes all have real, well-formed `.agents/skills/<name>/SKILL.md` content (confirmed via `find .agents -type f`), documented in `docs/tooling-user-guide.md` §6. That doc's own §6 was itself wrong in the other direction -- it claimed site-refresh-builder/site-refresh-reviewer had SKILL.md files there, which don't exist -- so it's now corrected too, and it was missing no-em-dashes, also now added. Root cause of my error: `.agents/skills/` was never checked as a location during TASK-262's original investigation; only `.claude/agents/` and `~/.claude/agents/` were. The 13 genuinely-missing skills (gh-fix-ci, gh-address-comments, playwright, screenshot, security-best-practices, security-threat-model, the 4 transcript-*, the 3 site-refresh-*) had no file anywhere, confirmed. Net effect: the 21 `.claude/agents/*.md` personas built by this task are a different mechanism (spawned subagent vs. loaded skill) and don't conflict with or replace the 5 real `.agents/skills/` files -- both can coexist for the same 5 concerns. AGENTS.md's Registered Skills list now marks which 5 are real with a ✓. Left as an open design question for Mike, not decided here: whether the 5 overlapping concerns should eventually consolidate to one mechanism.
<!-- SECTION:NOTES:END -->
