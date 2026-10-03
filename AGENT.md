# AGENT.md — just3ws.github.io Pi Guide

> Pi-optimized context for `zpi` sessions in this repo.
> Token budget: keep reads shallow — use the query CLI rather than reading raw data files.
> Full project rules live in `AGENTS.md` (plural). Read that only when you need
> policy details or agent RACI. This file is your fast-start.

## Session start — run this first

```bash
bin/pi-ctx-just3ws          # corpus brief: graph health, counts, query surfaces
```

A project-local Pi skill is also available at `.pi/skills/just3ws/skill.md`
if you want to load it explicitly: `--skill .pi/skills/`.

## What this repo is

Public resume + portfolio Jekyll site for Mike Hall. Also the **CareerOS public
canon**: 29 positions, 132 technologies, 181 articles (2006-2026), 184 oral
history interviews, and a 423-node knowledge graph.

Two sibling systems:
- `wwworkremote.localhost` — career intelligence / job search side (private)
- `zdots (~/.config/zsh)` — local platform that runs everything

**Do not read `_data/*.json` raw.** Use the query CLI below.

## PHI & boundary rules

- PHI-adjacent machine. Never read `.env`, `.zdots.secrets`, keys.
- Do not read `$HOME/my/` or `~/.homegit/` content into context.
- Everything published here must pass the Publication Gate (CONTEXT.md §Local Runtime).

## Query surfaces — use these instead of reading files

```bash
# Corpus quick-look (~10 lines, ~150 tokens)
bin/pi-ctx-just3ws

# Career datalake query (positions, skills, articles, interviews)
ruby bin/query_career_datalake.rb --stats
ruby bin/query_career_datalake.rb --tech "Ruby"
ruby bin/query_career_datalake.rb --company "onemain"
ruby bin/query_career_datalake.rb --search "observability"
ruby bin/query_career_datalake.rb --archetype "staff_platform_enablement"
ruby bin/query_career_datalake.rb --interviewee "Aaron Patterson"
ruby bin/query_career_datalake.rb --era "2009-2015"
ruby bin/query_career_datalake.rb --json [+ any flag]   # machine-readable

# Knowledge graph audit (orphan check, coverage gaps)
ruby bin/audit_knowledge_graph.rb

# Knowledge graph stats
python3 -c "
import json
g = json.load(open('_data/knowledge_graph.json'))
by_type = {}
for n in g['nodes']:
    by_type[n['type']] = by_type.get(n['type'], 0) + 1
for t, c in sorted(by_type.items()): print(f'  {t}: {c}')
print(f'  links: {len(g[\"links\"])}')
"
```

## Build & verify

```bash
./bin/pipeline build     # Jekyll build + validation
./bin/pipeline ci        # full CI path (build + specs + lint + html-proofer)
bundle exec rspec        # RSpec suite (90 specs)
bin/install-localhost    # publish to https://just3ws.localhost/
```

## Key canonical data paths

| Data | Path |
|------|------|
| Positions | `_data/resume/positions/` |
| Skills | `_data/resume/skills.yml` |
| Profile | `_data/resume/profile.yml` |
| Knowledge graph | `_data/knowledge_graph.json` (423 nodes, 676 edges) |
| KG audit | `_data/knowledge_graph_audit.json` |
| Oral history index | `_data/speakers_index_full.json` |
| Transcripts research | `_data/research/*.json` |
| Posts | `_posts/` |
| Interviews | `_interviews/` (or `interviews/`) |
| Resume exports | `exports/` |
| Agent personas | `.claude/agents/*.md` |
| Skills | `.agents/skills/` |

## What Pi should and should not do here

| Do | Don't |
|----|-------|
| Query datalake CLI to answer knowledge questions | Read raw `_data/*.json` blobs |
| Read specific `_data/resume/` YAML for position detail | Assume from memory |
| Run `bin/audit_knowledge_graph.rb` to check graph health | Edit `_data/knowledge_graph.json` directly |
| Plan changes; hand off to zaider for mutations | Commit or edit files |
| Suggest Jekyll template or SCSS changes | Edit `_site/` generated output |

## Agent personas and skills (relevant to knowledge-base work)

- `system-cartographer` — 4D system cartography case studies
- `forensic-archivist` — oral history provenance and transcript integrity
- `canonical-surface-steward` — identity and naming consistency
- `prose-humanity-auditor` — plain language / no AI jargon
- `no-em-dashes-editor` — zero em-dashes in prose
- `public-surface-auditor` — privacy and provenance before publish
- `tmi-auditor` — PII/PHI and oversharing guard

## Common Pi session patterns in this repo

```bash
# "What technologies has Mike worked with since 2018?"
ruby bin/query_career_datalake.rb --era "2018-2026" --json | jq .

# "Who are the most-connected people in the knowledge graph?"
python3 -c "
import json, collections
g = json.load(open('_data/knowledge_graph.json'))
degree = collections.Counter()
for l in g['links']:
    degree[l['source']] += 1
    degree[l['target']] += 1
for nid, cnt in degree.most_common(10):
    node = next((n for n in g['nodes'] if n['id'] == nid), {})
    print(cnt, nid, node.get('type',''))
"

# "Does this interviewee appear in the knowledge graph?"
ruby bin/query_career_datalake.rb --interviewee "Sandro Mancuso" --json

# "What are the coverage gaps in the knowledge graph?"
ruby bin/audit_knowledge_graph.rb
cat _data/knowledge_graph_audit.json | python3 -m json.tool
```
