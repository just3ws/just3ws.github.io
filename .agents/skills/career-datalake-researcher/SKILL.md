---
name: career-datalake-researcher
description: Queries the local knowledge system, video transcripts, and CareerOS datalake across 218 transcribed interviews, 28 engineering roles, 185 writings, and 132 technologies. Use when researching what was spoken in past videos, finding verbatim quotes, exploring community connections, or preparing episode context.
---

# /career-datalake-researcher: CareerOS Knowledgebase & Video Datalake

Use this skill when researching past video content, extracting quotes, connecting practitioners across conferences and user groups, or verifying historical engineering context across Mike Hall's 20-year archive.

The local knowledge system is fully indexed in `career_datalake.json` and `career_datalake.jsonl`, compiling:
- 218 video interview transcripts with full spoken text
- 28 engineering positions and leadership roles
- 185 technical writings, case studies, and field notes
- 132 mapped technologies and historical eras
- 426 interconnected community and knowledge graph entities

---

## 1. CLI Query Engine (`bin/query_career_datalake.rb`)

Fast local searches directly in the terminal:

```sh
# Full-text search across transcripts, case studies, and posts
ruby bin/query_career_datalake.rb -s "distributed consensus"
ruby bin/query_career_datalake.rb -s "Alt.NET"

# Search interviews by speaker name or topic
ruby bin/query_career_datalake.rb -i "Sergio Pereira"
ruby bin/query_career_datalake.rb -i "Ola Bini"
ruby bin/query_career_datalake.rb -i "Tim Ottinger"

# Search technology provenance, active eras, and related roles
ruby bin/query_career_datalake.rb -t "Ruby"
ruby bin/query_career_datalake.rb -t "PostgreSQL"

# Search company history and engineering accomplishments
ruby bin/query_career_datalake.rb -c "Groupon"
ruby bin/query_career_datalake.rb -c "Obtiva"

# Display datalake statistics and index health
ruby bin/query_career_datalake.rb --stats
```

---

## 2. Regenerating the Datalake

When new video transcripts are ingested from the autonomous media intake pipeline into `_data/transcripts/<slug>.yml`, recompile the datalake:

```sh
# Rebuild datalake JSON and JSONL exports
ruby bin/generate_career_datalake.rb

# Run via unified pipeline router
./bin/pipeline data generate
```

---

## 3. CareerOS MCP Server Integration

The repository equips a dedicated Model Context Protocol (MCP) server for agents:
- Executable: `bin/career_datalake_mcp_server.rb`
- Tools exposed:
  * `query_career_history` (alias `query_career_datalake`): Full-text searches across positions, case studies, technical articles, and transcripts.
  * `query_oral_history`: Searches across all 218 software engineering interviews and full spoken transcripts.
  * `query_transcript` (alias `get_interview_transcript`): Retrieves full structured dialogue turns and speaker map for a specific transcript ID (`_data/transcripts/<slug>.yml`).
  * `get_technology_provenance`: Retrieves complete timeline, active era, and specific roles where a technology or skill was used.
  * `get_position_dossier` (alias `get_position_details`): Deep dive into specific company tenures, deliverables, and skills.
  * `get_archetype_strategy`: Retrieves tailored pitch strategy, target tier, and cover letter empathy anchors.
  * `query_witc_corpus` & `get_witc_corpus_stats`: Bounded FTS5 search and corpus statistics over the local WITC/UGtastic SQLite database.
  * `get_narrative_synthesis_baseline` & `generate_executive_brief`: Canonical 3-Act narrative baseline and automated 1-page executive brief generator.

---

## 4. Operational Invariants

1. **Zero Cloud Leaks**: Queries execute 100% locally against JSON and YAML datasets on Apple Silicon.
2. **Contextual Quotes with Provenance**: Transcript search results include exact spoken quotes and direct YouTube timestamp links.
3. **Zero Em-Dash Standard**: Enforce strict em-dash-free compliance across all generated research notes, briefs, and dossiers.
