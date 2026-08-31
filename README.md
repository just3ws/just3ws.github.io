# Mike Hall — Principal Software Engineer & Systems Architect

[![CI Pipeline](https://github.com/just3ws/just3ws.github.io/actions/workflows/build-and-validate.yml/badge.svg)](https://github.com/just3ws/just3ws.github.io/actions)
[![ATS Readiness Benchmark](https://img.shields.io/badge/ATS%20Readiness-90.6%25%20Composite-brightgreen)](https://www.just3ws.com/exports/resumes/)
[![Zero Em Dashes](https://img.shields.io/badge/Prose%20Standard-Zero%20Em%20Dashes-blue)](https://www.just3ws.com)
[![License](https://img.shields.io/badge/License-MIT-purple.svg)](LICENSE)

> Principal Systems Architect and Staff Platform Lead with 20+ years of verifiable experience leading legacy modernizations, system cartography audits, production reliability engineering, and autonomous agent systems across high-scale fintech, healthcare, and enterprise platforms.

> **Available for hire:** Mike Hall is open to Principal Software Engineer, Staff Platform Architect, observability/resilience, legacy modernization, and founding AI/MCP engineering engagements. [View the Principal resume](https://www.just3ws.com/resumes/mike-hall-principal-software-engineer/) or [start a conversation](https://www.just3ws.com/contact/).

---

## 🎯 Quick Command Reference

| Action | Command | Description |
| :--- | :--- | :--- |
| **Local Dev Server** | `./bin/server` | Clean build and serve at `http://127.0.0.1:4000/` with live reload |
| **Full Build Pipeline** | `./bin/pipeline build` | Regenerate data pages, exports, PDFs, and compile Jekyll site |
| **Run Full CI** | `./bin/pipeline ci` | Full build, RSpec unit tests, ATS benchmarking, and contract audits |
| **ATS Benchmark Suite** | `bundle exec rake benchmark:ats` | Benchmark resume surfaces against 5 Staff+/Principal archetypes |
| **Resume Quality Audit** | `bundle exec rake validate:resume_quality` | Assert outcome causality, action verbs, and zero em dashes |
| **Datalake Query CLI** | `ruby bin/query_career_datalake.rb --help` | Deterministic CLI queries across 20+ years of career history |
| **Executive Pitch Generator** | `ruby bin/generate_executive_brief.rb --help` | Generate tailored 1-page executive pitch briefs with PDF exports |

---

## 📄 Sovereign Resume Canon & Bespoke Archetypes

The canonical career history is entirely data-driven from `_data/resume/`, validated against Schema.org `Person` JSON-LD specifications, and compiled into 5 tailored archetype exports:

* **[Principal Systems Architect](https://www.just3ws.com/resumes/mike-hall-principal-software-engineer/)** — Large-scale legacy modernization, system cartography, domain boundaries, and high-throughput architecture.
* **[Staff Platform & Enablement Lead](https://www.just3ws.com/resumes/mike-hall-staff-platform-lead/)** — Developer velocity, CI/CD pipelines, internal developer platforms, and engineering mentorship.
* **[Observability & Resilience Specialist](https://www.just3ws.com/resumes/mike-hall-observability-resilience-specialist/)** — OpenTelemetry, distributed tracing, eBPF, SLOs/error budgets, and production incident response.
* **[Founding Staff AI Engineer](https://www.just3ws.com/resumes/mike-hall-founding-staff-engineer/)** — Agentic workflows, MCP servers, local LLM evaluation harnesses, and deterministic datalakes.
* **[Senior Ruby on Rails Architect](https://www.just3ws.com/resumes/mike-hall-senior-ruby-rails-contractor/)** — 15+ years of deep Ruby/Rails internals, high-performance ActiveRecord, and zero-downtime upgrades.

**Direct Raw Exports:** [Markdown (`/exports/resume.md`)](https://www.just3ws.com/exports/resume.md) • [JSON (`/exports/resumes/*.json`)](https://www.just3ws.com/exports/resumes/) • [Plain Text (`/resume.txt`)](https://www.just3ws.com/resume.txt) • [LinkedIn Experience Formatter (`/linkedin/`)](https://www.just3ws.com/linkedin/)

---

## 📐 System Cartography & Engineering Proof Engine

* **[4D System Cartography Framework](https://www.just3ws.com/panoramic-view/)** — Operational blueprint for mapping multi-decade monoliths across Static Code Topology, Runtime Dynamics, Historical Telemetry, and Organizational Ownership.
* **[Flagship Modernization Essay](https://www.just3ws.com/2026/08/29/system-cartography-how-to-map-a-ten-year-old-monolith/)** — Practical field guide on safely refactoring legacy codebases.
* **[Production Case Studies](https://www.just3ws.com/case-studies/)** — Verifiable case studies from OneMain Financial ($1B+ debit network), EMR Bear (HIPAA/PHI clinical telemetry), Groupon (hypergrowth polyglot scaling), and ActiveCampaign.

## ⚔️ Phalanx Duel: A Current Architecture Laboratory

Phalanx Duel is Mike’s hands-on proof project for deterministic systems, product architecture, replay integrity, and controlled AI-assisted engineering. It combines a TypeScript rules engine, server-authoritative multiplayer, replayable action logs, CI verification gates, and an observable browser client.

* **[Play Phalanx Duel](https://play.phalanxduel.com/)**
* **[Phalanx Duel repository](https://github.com/phalanxduel/phalanxduel)**
* **[Architecture and craftsmanship brief](https://github.com/phalanxduel/phalanxduel/blob/main/docs/talks/phalanx-duel-commercial-and-user-group.md)**

---

## 🎙️ Historical Oral History Archive & Podcasts

This repository preserves the public oral history of the Midwest software craftsmanship movement (2009–2015) with 100% video parity, closed captions, and full interactive transcripts:

* **[Video Archive & Transcripts (212 Videos)](https://www.just3ws.com/interviews/)** — Searchable transcripts and video playback featuring 191 technical leaders and creators (Uncle Bob Martin, DHH, Dave Hoover, Corey Haines, Michael Feathers, Trisha Gee, Kyle Kingsbury).
* **[Software Craftsmanship McHenry County (SCMC)](https://www.just3ws.com/scmc/)** — The suburban user group founded in 2009 by Mike Hall, Ryan Gerry, and Jim Suchy. Includes the [Official SCMC YouTube Playlist](https://www.youtube.com/playlist?list=PLC2qBbsulKdk).
* **[The IronLanguages Podcast (2010)](https://www.just3ws.com/podcasts/ironlanguages/)** — Archival records exploring IronRuby, IronPython, the DLR, and the origins of Chocolatey package management.
* **[Chicago Craftsmanship Monograph](https://www.just3ws.com/chicago-craftsmanship/)** — Authoritative retrospective on how developer frustration with corporate Agile sparked SCNA and Chicago's $10B+ tech boom.
* **[UGtastic Audio Podcast Feed (`/podcast.xml`)](https://www.just3ws.com/podcast.xml)** — Apple Podcasts / Spotify-compliant RSS 2.0 feed.

---

## 🤖 Career Datalake & MCP Server Interface

Query the entire 20+ year technical knowledge base deterministically via CLI or Model Context Protocol:

```bash
# Query career achievements by technology keyword
ruby bin/query_career_datalake.rb --tech OpenTelemetry

# Retrieve company dossier and position highlights
ruby bin/query_career_datalake.rb --company Groupon

# Start MCP Server for LLM / Agent pair programming
ruby bin/career_datalake_mcp_server.rb
```

* **HTTP JSON Endpoints:** `https://www.just3ws.com/career_datalake.json` and `career_datalake.jsonl`
* **MCP Tools:** `query_career_history`, `get_technology_provenance`, `get_position_dossier`, `get_archetype_strategy`, `query_oral_history`, `generate_executive_brief`.

---

## 📬 Contact & Connect

* **Email:** [mike@just3ws.com](mailto:mike@just3ws.com)
* **Phone:** [(847) 877-3825](tel:+18478773825)
* **LinkedIn:** [linkedin.com/in/just3ws](https://www.linkedin.com/in/just3ws)
* **GitHub:** [github.com/just3ws](https://github.com/just3ws)
* **Advisory Retainers & Audits:** [Advisory & Engagements Hub](https://www.just3ws.com/engagements/)

---

## 🛠️ Contributing & Governance

* **Architecture & Standards:** See [CONTRIBUTING.md](CONTRIBUTING.md) and [CONTEXT.md](CONTEXT.md).
* **Agent Workflows:** See [AGENTS.md](AGENTS.md) and [CODEX.md](CODEX.md).
* **Release History:** See [CHANGELOG.md](CHANGELOG.md).
