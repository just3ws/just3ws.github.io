<!-- ═══════════════════════════════════════════════════════════════════════
     CURRENT FOCUS - last updated 2026-09-04
     Cold-start resume state, canonical for every agent tool. Whoever closes
     a session rewrites this block in place - step one, before the wrap-up.
     Backlog + git log are truth for exact task status / SHAs; if this block
     contradicts them, trust them and fix the block.

     THIS REPO IS PUBLIC. This block is committed and world-readable - keep
     it to "what content/feature is being built". Anything about employment
     status, targeting, or career narrative goes ONLY in the local deep
     handoff, never here.

       In flight: verify against Backlog (`backlog/tasks/`).
       Recent threads:
       - Deploy was stuck ~2 days (last green 42da2e92, 2026-09-02) behind a
         stack of gates each hidden behind the one before it in `rake ci`.
         Fixed and pushed as d1feda2a; run 33880797073 completed success:
         - repo_hygiene: allowlisted the new phalanx-duel/ top-level dir.
         - prose_humanity: docs/voice-actor.md's own banned-words table was
           tripping the jargon filter it defines; backticked the two terms.
         - semantic_output: phalanx-duel/index.html had a nested <main>
           inside the base layout's <main>; exports/reports/*.html gained
           frontmatter (for sitemap:false) that let the default layout wrap
           two already-complete HTML docs, now `layout: none`; new
           interviews/word-clouds/index.html is an aggregate page, added to
           the validator's interview-JSON-LD skip list.
         - ats_benchmarks (52.1% -> 89.9%): 054e1de3 had switched
           bin/generate_archetype_resumes.rb to read canonical-only
           public_* fields for all 5 role-targeted archetypes, collapsing
           them onto one shared thin voice. Reverted the generator to read
           summary/highlights directly; canonical /resume/ voice unchanged.
       - Built tmi-auditor skill: TMI/PII/PHI/*ism guards (ageism, ableism,
         familism) walking full sitemap.xml spine, 879 URLs, 0 quarantine findings.
       - Created docs/voice-actor.md: canonical Mike Hall voice and vocabulary
         definition for all content-generating agents.
       - Added bin/tmi_audit_sitemap.rb, bin/tmi_fix_sitemap_exclusions.rb,
         rake audit:tmi_gate (CI gate), rake audit:tmi_pipeline (full run).
       - Fixed phone suppression on /resume/positions/* sub-pages via Liquid
         unless conditional in _includes/resume/profile-header.html.
       - 90 examples, 0 failures. TMI gate: PASS.
       Deep handoff (local-only, never commit):
         ~/.config/adots/handoffs/2026-09-04-2.md

     Close ritual: rewrite this block + commit; write the deep handoff for
     anything personal or unfinished. Reference impl: wwworkremote/core's
     docs/agents/session-handoff.md.
     ═══════════════════════════════════════════════════════════════════════ -->

# Project Agent Instructions

## Required Project Context

Before changing this repository:

1. Read `CONTEXT.md` for the public-canon, local-runtime, and publication
   contracts.
2. Read `CODEX.md` before evaluating or changing resume content, positioning,
   titles, or generated resume surfaces.
3. Read `docs/career-strategy-audhd-principal-engineering.md` for title-to-scale
   role calibration and interview positioning strategies.
4. Read `docs/style-guide-and-canonical-naming.md` for permanent canonical naming,
   casing, and compound word standards across all content, data, and transcripts.

Do not treat this repository as an isolated Jekyll checkout. Its installed
localhost site is part of Mike's local system and is a required verification
surface for user-facing changes.

## System Identity

You are operating in `just3ws.github.io` — Mike Hall's public resume/
portfolio Jekyll site, the public-facing half of a two-repo CareerOS
platform. Peer system: `wwworkremote.localhost` (career intelligence / job
search side), synchronized via `src/collaboration/peer_mutex.rb`
(`CareerOS::PeerMutex`) and `bin/sync_career_peer.rb`.

Cross-session and cross-repo comms run on the zdots message bus. This
repo's registered identity is `agent-just3ws`:

- `zdots-ctx bus-whoami` — confirm identity resolves; if not,
  `zdots-ctx bus-register agent-just3ws --kind agent` then
  `export ZDOTS_BUS_PARTICIPANT=agent-just3ws`.
- `job-leads` channel — just3ws <-> wwworkremote coordination.
- `general` channel — cross-cutting platform ops; also reaches Mike
  (`mike`) and `zdots` (formerly `claude-code-main`).
- Bus problems get filed as a `zdots-issue` — this repo's agents don't
  patch zdots infrastructure directly.

Every persona under `.claude/agents/` operates inside this same identity
and system context, not as an isolated actor.

## Panoramic View Labs (PVL) Platform Identity

Canonical naming is permanent. Read this before using any Panoramic View term in prose, code, or agent output.

- **Panoramic View** is a technique (the system-cartography method). It is not an initiative name.
- **Panoramic View Labs** (short code `PVL`, pronounced "Pavel") is the initiative name. Use it when referring to the organizational umbrella, not the method.
- **Pavel** is the name of the Panoramic View specialist agent. Named from the PVL pronunciation.
- **zdots** is the root local-system platform for the Panoramic View initiative. All PVL capabilities live in and depend on zdots, not just3ws or wwworkremote.

Full disambiguation rules: `docs/style-guide-and-canonical-naming.md` §7.

## Agent skills

### Issue tracker

GitHub issues. See `docs/agents/issue-tracker.md`.

### Triage labels
Standard triage workflow labels. See `docs/agents/triage-labels.md`.

### Domain docs
Single-context layout (root-level CONTEXT.md + docs/adr/). See `docs/agents/domain.md`.

## Registered Skills
Use these skills by default for this repository. **Status**: 8 of the 21
below have real `SKILL.md` content in `.agents/skills/` (marked ✓; see
`docs/tooling-user-guide.md` §6) — the other 13 have no skill file anywhere.
All 21 also have `.claude/agents/*.md` subagent persona coverage (TASK-262),
which is a separate mechanism (a spawned subagent, not a loaded skill) and
does not require a `.agents/skills/` file to exist.

## Persona Review Council

Aneta is the trusted editorial and strategy lead for Mike's public identity.
The council definition and method map live in
`docs/persona-review-council.md`. Its independent reviewers protect methods,
provenance, professional audiences, practitioner audiences, accessibility,
prose, privacy, and public-boundary safety.

Use the council before publishing or revising a method, quote, diagram, title,
metric, named person, historical interpretation, or cross-link between archive
and professional surfaces. An unresolved authorship or public-safety concern is
a hold, not an invitation to invent a smoother explanation.

1. `gh-fix-ci` - Diagnose and fix failing GitHub Actions checks.
2. `gh-address-comments` - Process and resolve PR review comments.
3. `playwright` - Run browser-based smoke checks and regression checks.
4. `screenshot` - Capture visual evidence for UI regressions.
5. `security-best-practices` - Run focused security reviews (JS/TS/Ruby-adjacent patterns).
6. `security-threat-model` - Produce threat models for pipeline/content flows.
7. `transcript-import-batch` - Batch ingest transcript files from outbox with dry-run/apply + validation workflow.
8. `transcript-review-gate` - Review low-confidence transcript mappings before apply.
9. `transcript-quality-check` - Audit transcript integrity and content quality in canonical data.
10. `transcript-ops-report` - Summarize transcript ingestion throughput and corpus growth.
11. `site-refresh-director` - Audit a site surface and produce a bounded, evidence-backed refresh brief.
12. `site-refresh-builder` - Implement an approved refresh brief in the existing Jekyll/Liquid/SCSS stack.
13. `site-refresh-reviewer` - Independently gate visual, accessibility, SEO, and public-archive quality.
14. `system-cartographer` ✓ - Audit, structure, and generate 4-dimensional System Cartography case studies.
15. `executive-brief-generator` ✓ - Generate tailored 1-page executive pitch briefs for target Principal Engineer roles.
16. `job-lead-evaluator` ✓ - Evaluate job leads from wwworkremote against personal OS context and canonical resume data.
17. `prose-humanity-auditor` ✓ - Audit technical prose across site Markdown, YAML data, and resume surfaces for plain language, neuroinclusive readability, cognitive load, and zero AI jargon.
18. `no-em-dashes` ✓ - Enforce em-dash-free writing across prose, case studies, briefs, and documentation to eliminate machine-writing cadence and maintain authentic human voice.
19. `public-surface-auditor` ✓ - Audit the rendered public boundary for privacy, provenance, quarantine, and internal topology leaks before publication.
20. `tmi-auditor` ✓ - Audit public-facing content for oversharing, discrimination-vector signals, and PII/PHI exposure.
21. `canonical-surface-steward` ✓ - Keep canonical identity, shorthand, agents, skills, documentation, CLI help, validators, and generated surfaces synchronized.

## Career Datalake & MCP Server Interface

This repository provides full-corpus deterministic query interfaces over the career archive (29 positions, 136 skills, 156 blog posts, 211 interviews, and 402 knowledge graph nodes):

* **CLI Query Engine:** `ruby bin/query_career_datalake.rb [options]` (supports `--tech`, `--company`, `--search`, `--archetype`, `--era`, `--interviewee`, `--json`, and `--man`).
* **MCP Server:** `ruby bin/career_datalake_mcp_server.rb` registered in `mcp.json` (tools: `query_career_history`, `get_technology_provenance`, `get_position_dossier`, `get_archetype_strategy`, `query_oral_history`, `query_transcript`).
* **HTTP Endpoints:** `https://just3ws.localhost/career_datalake.json` and `https://just3ws.localhost/career_datalake.jsonl`.
* **Guides:** See `docs/career-datalake-and-mcp-guide.md` and `docs/mcp-setup-guide.md`.

## Automated Resume Quality & ATS Benchmarking Suite

This repository maintains continuous ATS parseability, keyword match density, and structural data validation:

* **Resume Quality Validator:** `bundle exec rake validate:resume_quality` (`bin/validate_resume_quality.rb`) - Simulates ATS plain-text parsing, checks Schema.org `Person` JSON-LD linked data, action verb ratios, and enforces strict zero em dashes.
* **ATS Keyword Benchmark Engine:** `bundle exec rake benchmark:ats` (`bin/benchmark_ats_keywords.rb`) - Benchmarks resume exports against 5 target Staff+/Principal role profiles (Huntress Rails/SOC, Coder Platform, Enterprise Telemetry, Fintech Modernizer, Founding Staff AI).
* **Automated CI/CD Gating:** `bundle exec rake validate:ats_benchmarks` asserts composite match score >= 85.0% and minimum archetype floor >= 75.0%.
* **Guides:** See `docs/resume-narrative-and-storytelling-guide.md`, `docs/resume-quality-and-ats-benchmarking-guide.md`, and `docs/tooling-user-guide.md` (§8, §9).

## Executive Pitch Briefs & Direct Outreach Tooling ("Wayfinder")

This repository provides automated generation of tailored 1-page executive pitch briefs, interview calibration scripts, and high-signal outreach copy:

* **Executive Brief Generator:** `ruby bin/generate_executive_brief.rb [options]` (supports `--company`, `--role`, `--domain`, `--tier`, `--comp`, `--mandate`, `--html`, `--pdf`, `--json`).
* **MCP Tool Integration:** `generate_executive_brief` in `bin/career_datalake_mcp_server.rb` callable by `wwworkremote.localhost` and any agent tool.
* **Direct Outreach Playbook:** `docs/direct-hiring-manager-outreach-playbook.md` (cold hiring manager, warm peer, and founder/CTO outreach archetypes).
* **Protocol & Specifications:** `docs/executive-brief-generator-protocol.md` and `docs/career-strategy-audhd-principal-engineering.md`.
* **Rendered Briefs Hub:** `https://just3ws.localhost/exports/briefs/` with downloadable vector PDFs.


## Site Refresh Agent Workflow

For visual refresh work, use the three roles in order:

1. `$site-refresh-director` outputs a Refresh Brief and does not edit code.
2. `$site-refresh-builder` implements one authorized slice and outputs Build Evidence.
3. `$site-refresh-reviewer` inspects rendered desktop and mobile output and returns `pass` or `changes requested`.

Do not let the builder self-approve a visual change. Preserve routes, navigation labels, canonical content, analytics hooks, accessibility wins, and archive provenance unless the user explicitly expands scope.

## GitHub Pages / Pipeline Focus
For this site, prioritize:

1. CI reliability and reproducibility (Ruby/Bundler parity).
2. Jekyll build + internal link validation as required checks.
3. Smoke testing key pages via Playwright before merge.

## SEO + HTML Standards Guidance
There is no dedicated curated skill currently installed for HTML standards or SEO architecture.
Use this stack instead:

1. `playwright` for navigation/indexability smoke tests.
2. Jekyll plugins and templates (`jekyll-seo-tag`, sitemap, metadata includes) for structured SEO output.
3. CI checks (`html-proofer` + targeted assertions) for broken links and markup regressions.

<!-- BACKLOG.MD MCP GUIDELINES START -->

<CRITICAL_INSTRUCTION>

## BACKLOG WORKFLOW INSTRUCTIONS

This project uses Backlog.md MCP for all task and project management activities.

**CRITICAL GUIDANCE**

- If your client supports MCP resources, read `backlog://workflow/overview` to understand when and how to use Backlog for this project.
- If your client only supports tools or the above request fails, call `backlog.get_backlog_instructions()` to load the tool-oriented overview. Use the `instruction` selector when you need `task-creation`, `task-execution`, or `task-finalization`.

- **First time working here?** Read the overview resource IMMEDIATELY to learn the workflow
- **Already familiar?** You should have the overview cached ("## Backlog.md Overview (MCP)")
- **When to read it**: BEFORE creating tasks, or when you're unsure whether to track work

These guides cover:
- Decision framework for when to create tasks
- Search-first workflow to avoid duplicates
- Links to detailed guides for task creation, execution, and finalization
- MCP tools reference

You MUST read the overview resource to understand the complete workflow. The information is NOT summarized here.

</CRITICAL_INSTRUCTION>

<!-- BACKLOG.MD MCP GUIDELINES END -->

## graphify

This project has a knowledge graph at graphify-out/ with god nodes, community structure, and cross-file relationships.

When the user types `/graphify`, use the installed graphify skill or instructions before doing anything else.

Rules:
- For codebase questions, first run `graphify query "<question>"` when graphify-out/graph.json exists. Use `graphify path "<A>" "<B>"` for relationships and `graphify explain "<concept>"` for focused concepts. These return a scoped subgraph, usually much smaller than GRAPH_REPORT.md or raw grep output.
- Dirty graphify-out/ files are expected after hooks or incremental updates; dirty graph files are not a reason to skip graphify. Only skip graphify if the task is about stale or incorrect graph output, or the user explicitly says not to use it.
- If graphify-out/wiki/index.md exists, use it for broad navigation instead of raw source browsing.
- Read graphify-out/GRAPH_REPORT.md only for broad architecture review or when query/path/explain do not surface enough context.
- After modifying code, run `graphify update .` to keep the graph current (AST-only, no API cost).
