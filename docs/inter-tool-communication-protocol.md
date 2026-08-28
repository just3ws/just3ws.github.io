# Inter-Tool Communication Protocol: `just3ws` ↔ `wwworkremote` ↔ `zdots-ctx`

This document defines the inter-tool communication protocol, data interfaces, and bus messaging channels enabling **`just3ws.localhost`** (Candidate History & System Cartography Archive), **`wwworkremote.localhost`** (Job Market Intelligence & Automation Engine), and **`zdots-ctx`** (Personal OS Knowledge Layer & Bus) to exchange context and perform automated career positioning analysis.

---

## Architecture Overview

```
 ┌────────────────────────────────────────────────────────┐
 │                    zdots-ctx                           │
 │     Personal OS Knowledge Layer & Message Bus          │
 └───────────┬────────────────────────────────┬───────────┘
             │ (zdots-ctx query)              │ (bus-post / bus-read)
             ▼                                ▼
┌──────────────────────────────────────┐  ┌──────────────────────────────────────┐
│          just3ws.localhost           │  │         wwworkremote.localhost       │
│  Candidate History & Resume Provider │  │  Job Market Intelligence & Scorer    │
└──────────────────────────────────────┘  └──────────────────────────────────────┘
   - GET /resume.json                        - GET /api/v0/job_postings
   - GET /exports/resume.md                  - GET /api/v0/job_postings/:id
   - GET /exports/history.md                 - bin/wwwr match <id> --source=<n> [--escalate]
   - MCP Server: ugtastic-archive            - LLM::ProfileMatcher / ArtifactGenerator
```

Scoring itself is single-sourced in `wwworkremote/core` (`LLM::ProfileMatcher`, keyed off its own `CareerProfile`): not `just3ws`'s `resume.json`. `bin/evaluate_job_lead.rb` here calls `bin/wwwr match` rather than re-implementing fit
scoring against the just3ws resume export, so there's one scorer instead of two that can drift apart.

---

## 1. Cross-Agent Message Bus Communication (`zdots-ctx bus-*`)

To allow AI agents across sessions, CLI tools, and different workspaces (Antigravity, Claude Code, Codex CLI) to discuss job postings and inter-tool concerns, use the `zdots-ctx` message bus:

* **Dedicated Bus Channel**: `job-leads`
* **Topic**: `Job search leads, evaluations, and inter-tool agent communication`

### CLI Usage for Agents & Developers

1. **Register Identity** (one-time per agent session):
   ```bash
   /Users/mike/.config/zsh/bin/zdots-ctx bus-register agent-antigravity --kind agent
   ```

2. **Post Lead Evaluation or Discussion**:
   ```bash
   /Users/mike/.config/zsh/bin/zdots-ctx bus-post job-leads "Evaluated Lead #112 (Huntress) - High fit. Brief generated." --as agent-antigravity
   ```

3. **Read Unread / Recent Messages**:
   ```bash
   /Users/mike/.config/zsh/bin/zdots-ctx bus-read job-leads
   ```

4. **Watch Channel for Live Updates**:
   ```bash
   /Users/mike/.config/zsh/bin/zdots-ctx bus-watch job-leads
   ```

---

## 2. Candidate History Endpoints (`just3ws.localhost`)

`just3ws.localhost` exposes machine-readable endpoints derived directly from canonical data (`_data/resume/`):

* **Structured Resume API**: `GET https://just3ws.localhost/resume.json`
  - Returns complete profile, timeline, position highlights, skills breakdown, and technical leadership records.

* **Career Datalake Master Manifest**: `GET https://just3ws.localhost/career_datalake.json`
  - Complete 550+ KB unified datalake containing candidate profile, all 29 positions, 5 archetype strategies, 4D case studies, technology provenance matrix (136 skills), 156 blog posts (2006 to 2026), 211 technical interviews, and 402-node knowledge graph.

* **Career Datalake JSONL Stream**: `GET https://just3ws.localhost/career_datalake.jsonl`
  - Line-delimited JSON format optimized for streaming, vector embedding generation, and fast semantic indexing.

* **Career Datalake Query CLI**: `ruby bin/query_career_datalake.rb [options]`
  - Fast CLI engine for deep context retrieval:
    - `--tech <skill>`: Technology provenance and all roles where a skill was used.
    - `--company <name>`: Deep position highlights and engineering context.
    - `--search <query>`: Full-text search across positions, case studies, posts, and interviews.
    - `--archetype <slug>`: Strategy and reader empathy bridge for a target tier.
    - `--interviewee <name>`: Interview and transcript records for specific guests.
    - `--json`: Formats output as raw JSON for inter-script pipelines.

* **LLM Context Export**: `GET https://just3ws.localhost/exports/resume.md`
  - High-density Markdown representation of candidate experience optimized for prompt context injection.

* **Timeline Narrative**: `GET https://just3ws.localhost/exports/history.md`
  - Complete 20+ year technical career progression.

* **Case Studies & Cartography**: `GET https://just3ws.localhost/exports/portfolio.md`
  - 4D System Cartography case studies (OneMain Financial, EMR-Bear, Phalanx Duel, WWWorkRemote).

* **Archetype Strategy & Reader Profiles**: `GET https://just3ws.localhost/reports/archetype-reader-profiles/`
  - Interactive report detailing target tier psychology, unstated pressures, wants vs needs, and empathy bridges.

* **CareerOS MCP Server**: `bin/career_datalake_mcp_server.rb`
  - Model Context Protocol STDIO server exposing callable tools (`query_career_history`, `get_technology_provenance`, `get_position_dossier`, `get_archetype_strategy`, `query_oral_history`, `query_transcript`) and resources (`career://datalake/*`, `ugtastic://archive/*`).

---

## 3. Job Market Intelligence & Scoring (`wwworkremote/core`)

* **List Ingested Postings**: `GET http://localhost:31000/api/v0/job_postings`
* **Job Posting Detail**: `GET http://localhost:31000/api/v0/job_postings/:id`
* **Fit scoring**: `cd ~/github.com/wwworkremote/core && bin/wwwr match <job_posting_id> --source=<name> [--escalate]`: the actual entry point for match analysis. `--source` is a required attribution tag (logged, not a credential: everything here is local/single-user). No `--escalate`: read-only, prints whatever analysis is already on file.
  With `--escalate`: runs a fresh `LLM::ProfileMatcher` scan and persists it (costs LLM tokens). Full contract:
  `docs/agents/interop.md` in `wwworkremote/core`.
* `admin/leads/:id` is a browser-session-authenticated admin view, not an API: don't curl it from another tool.

---

## 4. Automated Evaluation & Brief Generation Tooling

In `just3ws.github.io`, the following CLI tools and agent skills automate inter-tool queries. Fit scoring is
delegated to `bin/wwwr match` above, not reimplemented here.

* **Evaluation Script**: `ruby bin/evaluate_job_lead.rb --lead <LEAD_ID> [--escalate]`
* **Rake Tasks**: `bundle exec rake "job:evaluate[<LEAD_ID>]"` / `rake "job:evaluate[<LEAD_ID>,true]"` (the second
  positional arg escalates)
* **Agent Skills**:
  - [`.agents/skills/job-lead-evaluator/SKILL.md`](file:///Users/mike/github.com/just3ws/just3ws.github.io/.agents/skills/job-lead-evaluator/SKILL.md)
  - [`.agents/skills/executive-brief-generator/SKILL.md`](file:///Users/mike/github.com/just3ws/just3ws.github.io/.agents/skills/executive-brief-generator/SKILL.md)

---

## 5. Calibration & Tone Rules for Inter-Tool Communication

All messages, evaluations, and briefs generated across systems must enforce the following contract:

1. **Zero Fluff & Zero Hype**: Prohibit unevidenced promotional adjectives ("visionary," "transformational," "groundbreaking").
2. **Understated Fact Density**: State context, constraint, technical action, and verified outcome (-60% MTTR, domain isolation, OpenTelemetry across the service mesh).
3. **Skeptical Peer Filter**: Distinguish pure IC technical leadership (Staff/Principal Architect) from executive people management (managing managers, HR administration).

---

## 6. Collaboration Mutex & State Registry (`CareerOS::PeerMutex`)

To prevent race conditions, duplicate LLM token expenditure, and state drift during cross-repo evaluations, `just3ws` and `wwworkremote` coordinate through the shared `CareerOS::PeerMutex`:

* **File Mutex Lock**: `~/.local/state/career-os/mutex.lock` (re-entrant OS `flock` with timeout).
* **State Registry**: `~/.local/state/career-os/state.json`
  - Tracks candidate profile sync timestamp (`last_synced_at`, canonical endpoints).
  - Records active lead evaluations and brief output locations.
  - Maintains peer heartbeats (`agent-just3ws`, `agent-wwworkremote`).
* **Sync CLI**: `bin/sync_career_peer.rb`
  - Atomically updates candidate state under lock and broadcasts `PROFILE_SYNC_EVENT` to the `job-leads` channel.

