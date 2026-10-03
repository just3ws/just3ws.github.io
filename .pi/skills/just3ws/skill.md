---
name: just3ws
description: Query and explore the just3ws.github.io CareerOS knowledge-base — 28 positions, 132 skills, 184 interviews, 423-node knowledge graph. Use when working in ~/github.com/just3ws/just3ws.github.io, answering career history questions, exploring the oral history canon, or checking knowledge graph health.
---

# just3ws — CareerOS Knowledge-Base

Public resume + portfolio site. Also the **CareerOS public canon**.
Full rules in `AGENT.md` (auto-loaded by `zpi` when in this directory).

## Corpus at a glance

Run this first — always:

```bash
bin/pi-ctx-just3ws          # ~8 lines, ~150 tokens
```

## Primary query CLI

```bash
ruby bin/query_career_datalake.rb --stats
ruby bin/query_career_datalake.rb --tech "<skill>"
ruby bin/query_career_datalake.rb --company "<slug>"
ruby bin/query_career_datalake.rb --search "<query>"
ruby bin/query_career_datalake.rb --archetype "<slug>"
ruby bin/query_career_datalake.rb --interviewee "<name>"
ruby bin/query_career_datalake.rb --era "<YYYY-YYYY>"
ruby bin/query_career_datalake.rb --json [+ any flag]
```

Archetype slugs: `principal_systems_architect` | `staff_platform_enablement` |
`observability_resilience_specialist` | `founding_staff_fullstack` |
`senior_ruby_rails_contractor`

## Knowledge graph

```bash
ruby bin/audit_knowledge_graph.rb           # health: orphans, edges, gaps
bin/pi-ctx-just3ws --graph                  # node-type breakdown
```

Graph lives at `_data/knowledge_graph.json` (423 nodes, 676 edges).
**Do not read it raw** — use the audit script or the Python one-liners in `AGENT.md`.

## Key rule

Pi reads and plans. Hand off edits to `zaider`. Do not mutate `_data/` directly.
