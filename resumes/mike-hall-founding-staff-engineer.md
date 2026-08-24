---
layout: archetype-resume
body_class: ats-resume
archetype_key: founding_staff_fullstack
title: "Founding Staff Engineer (0-to-1 Product & AI Systems)"
description: "Hands-on Founding Staff Engineer who translates product ambiguity into robust, production-ready software. Combines full-stack web development (Rails, P"
permalink: /resumes/mike-hall-founding-staff-engineer/
sitemap: false
robots: noindex,nofollow
---

# Mike Hall

**Founding Staff Engineer (0-to-1 Product & AI Systems)**
Chicago, IL

- Email: [mike@just3ws.com](mailto:mike@just3ws.com)
- Phone: [(847) 877-3825](tel:+18478773825)
- Website: [just3ws.com](https://www.just3ws.com)
- LinkedIn: [linkedin.com/in/just3ws/](https://www.linkedin.com/in/just3ws/)
- GitHub: [github.com/just3ws](https://github.com/just3ws)

---

## Professional Summary

Hands-on Founding Staff Engineer who translates product ambiguity into robust, production-ready software. Combines full-stack web development (Rails, PostgreSQL, modern JS/TypeScript) with practical local-first AI engineering (pgvector embeddings, local LLM orchestration, prompt injection defense, and browser automation).

---

## Core Competencies & Skills

0-to-1 Full-Stack Architecture & Rapid Prototyping, Local-First AI Orchestration (llama.cpp, Ollama, Claude API), Vector Embeddings & Semantic Search (PostgreSQL pgvector), Prompt Injection Defense & Multi-Stage Guardrails, Manifest V3 Chrome Extension Development, Contract-Validated Data Pipelines & Schema Enforcement, Ruby on Rails, Node.js, WebSockets & Real-Time Sync, High Agency, Autonomous Problem Solving

---

## Experience & Leadership

### Creator at WWWorkRemote

**2021 - Present** | Independent Project

**Target Focus:** Architected multi-source Rails ingestion pipeline, pgvector semantic search, local-first YAML model registry, 4-stage prompt injection defense, and 16-adapter MV3 Chrome extension.

**Key Outcomes:**
- Data Ingestion & Normalization: Built a multi-source Rails ingestion pipeline and PostgreSQL storage schema, unifying fragmented job market datasets for structured downstream analysis.

- Semantic Search & Matching: Implemented vector search embeddings via pgvector, enabling high-precision semantic matching between complex candidate profiles and job requirements.

- Local-First AI Orchestration: Designed a provider-agnostic LLM orchestration layer behind a YAML-driven model registry, local-first by default (llama.cpp/Ollama primary, hosted Claude as fallback), so routine inference never leaves the machine while a stronger hosted model can be selected per call site.

- Prompt Injection Defense: Built a four-stage guardrails pipeline (normalize, weighted heuristic scan, risk classify, output validate) screening every untrusted scraped document before it reaches a model, scoring known injection patterns plus an instruction-density heuristic to secure ingestion against hostile inputs.

- Browser Extension & Lifecycle Capture: Built an MV3 Chrome extension with 16 provider adapters that extracts postings from live ATS pages and captures the full application lifecycle (questions asked and answers given) back into the platform.

- Static Signal Integration: Injected static analysis rules and architectural constraints into model context windows, preventing drift between generated outputs and system security contracts.


### Creator & Forensic Engineer at Technical Conversation Archive

**2011 - Present** | Independent Project

**Target Focus:** Built local-only Whisper transcription pipeline, semantic taxonomy cross-linking, and build-time schema enforcement gates for a multi-decade tech interview media corpus.

**Key Outcomes:**
- Local-Only AI Restoration Pipeline: Built a Whisper and local-LLM pipeline that transcribes, diarizes, and structures long-form interview audio entirely on-device, keeping a large private media corpus off third-party inference services.

- Schema-Validated Content Platform: Runs on a contract-validated data layer: every interview, asset, and transcript is checked against an explicit schema at build time, with referential-integrity checks that fail the build rather than publishing broken data.

- Semantic Cross-Linking & Taxonomy Generation: Generates a topic taxonomy, knowledge graph, and semantic cross-links across the corpus, turning an unstructured media archive into navigable, individually indexed pages.

- Primary-Source Capture: Conducted the original interviews on-site at GOTO Conference, Software Craftsmanship North America, RailsConf, and WindyCityRails, with practitioners including Dave Thomas, Stuart Halloway, Corey Haines, Sandro Mancuso, and Micah Martin.

- Digital Archaeology: Recovered and reconstructed material from defunct platforms and web archives, reconciling incomplete metadata across sources to restore provenance for recordings that would otherwise have been lost.


### Creator & Principal Architect at Phalanx Duel

**2022 - Present** | Independent Project

**Target Focus:** Built deterministic head-to-head strategy game in Ruby with hotwire interactions and zero-drift game state resolution.

**Key Outcomes:**
- Designed a deterministic engine with replayable action logs and server-authoritative state transitions, making complex outcomes reproducible and independently verifiable.

- Built replay validation, adversarial coverage, and CI verification gates so state transitions can be checked across the complete lifecycle.

- Uses controlled agent workflows with bounded tasks, acceptance criteria, automated checks, and human-reviewed outputs rather than treating model output as authority.


### Associate Director, Staff Engineer at OneMain Financial

**January 2021 - February 2026** | Remote

**Target Focus:** Introduced local AI exploration workflows for legacy code discovery and chartered ACQ Enablement for rapid platform modernization.

**Key Outcomes:**
- Technical Leadership & Team Consolidation: Progressed from Digital Origination Team Lead to Software Architect for the Acquisition Lane, merging two attrition-impacted teams into a unified, high-functioning engineering unit before converting to Associate Director, Staff Engineer upon corporate architecture track restructuring.

- ACQ Enablement Founding & Engineering Mandates: Founded and technically led the ACQ Enablement team to protect core engineering concerns from product feature pressure: driving platform stabilization, legacy modernization, system process mapping, architecture documentation, PII remediation, and fraud investigations.

- Observability & Enterprise Trace: Founded and led the OpenTelemetry Working Group (OTel WG) to establish the Enterprise Trace across high-volume Instant Prequalification flows, connecting onemain_frontend, Rails acquisition services, MuleSoft, and IBM mainframe backends to eliminate blind spots and align engineering around real-time service maps.

- State Machine Refactoring & Data Integrity: Refactored fragile multi-step Rails workflow state machines, eliminating hidden lateral state mutations across asynchronous boundaries and resolving persistent data integrity failures in core acquisition flows.

- Incident Response & Technical Escalation: Served as final escalation point for high-severity outages, translating live root-cause investigations into stronger telemetry, explicit component ownership, and reusable system knowledge.

- AI-Augmented Systems Investigation: Introduced privacy-conscious local AI workflows for legacy code analysis and engineering support, expanding investigative capacity while keeping human review, security constraints, and source evidence explicit.


### Senior .NET Developer at TicketsNow

**November 2005 - March 2007** | Crystal Lake, IL

**Target Focus:** Architected real-time inventory locking and transaction reconciliation service, preventing race conditions on concurrent ticket purchases ($2M+ protected revenue).

**Key Outcomes:**
- Architected a real-time inventory locking and transaction reconciliation service, preventing race conditions on concurrent ticket sales and generating $2M+ in protected revenue.
- Introduced and led Scrum agile practices for the core transaction engineering team, improving sprint delivery predictability.

---

## Selected Production Projects

### Creator (Agent Tooling (MCP Servers & Agent Workflows))
**2026 - Present**

Built and operate three MCP (Model Context Protocol) servers that expose live system state as callable tools to any MCP client, alongside the Claude Code skills, context-isolated subagents, and commit-time checks that keep agent work bounded and reviewable.


- Bidirectional Knowledge Server: Built ctx-mcp, an MCP server fronting a PostgreSQL knowledge suite that agents both query and write back to, so methodologies and lessons learned in one session are retrievable in the next rather than re-derived.

- Telemetry-Driven Diagnosis: Built o2-mcp, exposing on-demand OpenObserve telemetry (errors, slow spans, failed jobs, distributed traces) as agent-callable tools, so an agent diagnoses a running system from observed behavior instead of inferring from source.

- Compliance-Safe Observability: Telemetry reaches agents already PHI-scrubbed at the OpenTelemetry ingest edge, keeping a compliance-sensitive platform debuggable by an AI without exposing protected data.

- Local Inference Tooling: Built llama-mcp, exposing a local llama.cpp inference stack as callable tools for interrogation and validation, keeping routine inference on-box.

- Context as a Budgeted Resource: Designed context-isolated subagents that keep high-volume audit work out of the main conversation's context window, with per-client registration tooling and pre-commit hooks that reject any agent asset that isn't self-describing.


### Creator (WWWorkRemote)
**2021 - Present**

Rails 8 platform for multi-source job ingestion, semantic matching, and application automation, built as a working laboratory for local-first LLM orchestration and treating scraped third-party text as hostile input.


- Data Ingestion & Normalization: Built a multi-source Rails ingestion pipeline and PostgreSQL storage schema, unifying fragmented job market datasets for structured downstream analysis.

- Semantic Search & Matching: Implemented vector search embeddings via pgvector, enabling high-precision semantic matching between complex candidate profiles and job requirements.

- Local-First AI Orchestration: Designed a provider-agnostic LLM orchestration layer behind a YAML-driven model registry, local-first by default (llama.cpp/Ollama primary, hosted Claude as fallback), so routine inference never leaves the machine while a stronger hosted model can be selected per call site.

- Prompt Injection Defense: Built a four-stage guardrails pipeline (normalize, weighted heuristic scan, risk classify, output validate) screening every untrusted scraped document before it reaches a model, scoring known injection patterns plus an instruction-density heuristic to secure ingestion against hostile inputs.

- Browser Extension & Lifecycle Capture: Built an MV3 Chrome extension with 16 provider adapters that extracts postings from live ATS pages and captures the full application lifecycle (questions asked and answers given) back into the platform.

- Static Signal Integration: Injected static analysis rules and architectural constraints into model context windows, preventing drift between generated outputs and system security contracts.


### Creator & Forensic Engineer (Technical Conversation Archive)
**2011 - Present**

Recorded, and later restored, an archive of 214 technical interviews with practitioners from the Ruby, JVM, and Software Craftsmanship movements, using a local-only AI pipeline to transcribe, structure, and cross-link two decades of primary-source material into a searchable knowledge graph.


- Local-Only AI Restoration Pipeline: Built a Whisper and local-LLM pipeline that transcribes, diarizes, and structures long-form interview audio entirely on-device, keeping a large private media corpus off third-party inference services.

- Schema-Validated Content Platform: Runs on a contract-validated data layer: every interview, asset, and transcript is checked against an explicit schema at build time, with referential-integrity checks that fail the build rather than publishing broken data.

- Semantic Cross-Linking & Taxonomy Generation: Generates a topic taxonomy, knowledge graph, and semantic cross-links across the corpus, turning an unstructured media archive into navigable, individually indexed pages.

- Primary-Source Capture: Conducted the original interviews on-site at GOTO Conference, Software Craftsmanship North America, RailsConf, and WindyCityRails, with practitioners including Dave Thomas, Stuart Halloway, Corey Haines, Sandro Mancuso, and Micah Martin.

- Digital Archaeology: Recovered and reconstructed material from defunct platforms and web archives, reconciling incomplete metadata across sources to restore provenance for recordings that would otherwise have been lost.


---

## Additional Experience

- **Open-Source Transition Lead**, Coderwall (January 2014 - December 2014): Hired as a contractor by founder Matt Deiters to lead the open-source transition of the Coderwall developer reputation platform, a Y Combinator-backed professional network for software engineers (856 GitHub stars, 304 forks). Delivered security hardening, proprietary service extraction, infrastructure modernization, and community leadership as the top contributor to the open-source codebase.
- **Senior Software Developer**, ReachLocal (March 2015 - November 2016): Owned API design and modernization strategy, leading incremental legacy migration for a high-volume digital marketing platform.
- **Senior Backend Developer**, SK Holdings, Inc. (January 2019 - December 2020): Led backend stability, performance, and modernization for high-traffic Rails products, improving full-text search, campaign delivery pipelines, and data layer reliability while systems remained under production load.
- **Engineering Learning & Development Business Partner**, Groupon (July 2011 - May 2013): Owned core backend systems for fraud and taxonomy, leading global engineering enablement during hyper-growth.

---

## Career Foundations

**1999 - 2011**

Built and operated enterprise integrations, transactional systems, and early web products across consulting and product organizations, establishing the production discipline and community-centered craftsmanship that still shape my leadership.

- **Revenue-critical commerce**: Designed real-time inventory, locking, and fulfillment services for a high-volume ticket marketplace later acquired by a major industry operator.
- **Consulting and software craftsmanship**: Delivered systems across client environments while mentoring engineers, adopting Ruby and Rails, and helping build Chicago's craftsmanship community.
- **Enterprise and operational systems**: Built integration and operational software across large organizations, grounded in .NET, SQL, messaging, production support, and direct user needs.
