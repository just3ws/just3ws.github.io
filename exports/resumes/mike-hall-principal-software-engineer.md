# Mike Hall

**Principal Software Engineer / Systems Architect**
Chicago, IL

- Email: [mike@just3ws.com](mailto:mike@just3ws.com)
- Phone: [(847) 877-3825](tel:+18478773825)
- Website: [just3ws.com](https://www.just3ws.com)
- LinkedIn: [linkedin.com/in/just3ws/](https://www.linkedin.com/in/just3ws/)
- GitHub: [github.com/just3ws](https://github.com/just3ws)

---

## Professional Summary

Principal Software Engineer specializing in high-consequence legacy modernization, distributed systems architecture, and platform resilience. Combines hands-on software engineering with platform architecture, OpenTelemetry distributed tracing, cross-lane boundary mediation, and zero-downtime data migrations across Ruby on Rails, PostgreSQL, and cloud infrastructure.

---

## Core Competencies & Skills

Platform Architecture & Legacy Modernization, Cross-Domain Boundary Architecture & Governance, OpenTelemetry & Distributed Trace Context Propagation, High-Consequence Incident Escalation & Root Cause Analysis, Zero-Downtime Data Migrations & Schema Partitioning, Ruby on Rails, PostgreSQL, Sidekiq & Redis, AWS, Docker, Kubernetes & CI/CD Pipelines, Privacy-Conscious Local AI Orchestration & Tooling

---

## Experience & Leadership

### Associate Director, Staff Engineer at OneMain Financial

**January 2021 - February 2026** | Remote

**Target Focus:** Progressed from Digital Origination Team Lead to Software Architect for the Acquisition Lane, converting to Associate Director, Staff Engineer upon corporate architecture track restructuring, while founding the ACQ Enablement team, resolving a 4% application drop via DynamoDB session remediation, and leading the OpenTelemetry Working Group to establish the Enterprise Trace across Rails, MuleSoft, and Mainframe backends.

**Key Outcomes:**
- Originations IC Delivery & Speedfunds: Led the Originations Verification squad through consecutive Exceeds Expectations ratings, architecting and shipping the Speedfunds instant loan disbursement pipeline (funding to debit cards in minutes). Appointed Software Architect for the Acquisition Lane, later converting to Associate Director, Staff Engineer.

- ACQ Enablement & Architecture Discovery: Founded the ACQ Enablement team and mapped seven heterogeneous acquisition channels; architected an automated 5-phase PII Remediation deletion engine and data migration across 30+ tables, eliminating legacy state machine corruptions.

- Enterprise Resilience & DynamoDB Session Remediation: Diagnosed and eliminated a critical CookieOverflow defect that caused 4% silent traffic loss of digital loan applications during e-signing; architected zero-downtime blue/green migration to DynamoDB session store with zero incidents.

- Enterprise Trace & Operational Alignment: Architected distributed telemetry across Rails distributed monoliths, MuleSoft APIs, and IBM mainframe backends; partnered directly with Cybersecurity, EMC, SRE, and Incident Command to align monitoring with end-to-end distributed tracing.

- Community Enablement & SRE Handoff: Founded weekly Geekfest@OMF and scaled the enterprise OpenTelemetry Working Group to 40+ cross-lane engineers; mentored and partnered with SRE leads to transition ongoing operational facilitation, establishing a durable community of practice.

- Applied AI & Innovation Leadership: Placed in two corporate hackathons building conversational agents with Rasa and Bonsai Buckaroos schema inference tools; pioneered local LLM orchestration and privacy-conscious AI developer tooling at Geekfest@OMF.


### Senior Backend Developer at SK Holdings, Inc.

**January 2019 - December 2020** | Chicago, IL

**Target Focus:** Modernized search and asynchronous messaging pipelines under live production load, executing zero-downtime Rails framework upgrades and database relational indexing.

**Key Outcomes:**
- Search Infrastructure Modernization: Eliminated external cluster failure modes and reduced operating footprint by migrating legacy Sphinx to optimized MySQL full-text search and relational indices under live production traffic.

- Zero-Downtime Rails Upgrades: Led Ruby and Rails framework upgrades across core applications, sequencing database migrations to ensure zero downtime during platform modernization.


### Senior Software Developer at ActiveCampaign

**September 2018 - December 2018** | Chicago, IL

**Target Focus:** Improved testability and performance inside a tightly coupled PHP/MySQL CRM backend, introducing structured query patterns and cache strategies, and hardening the Ember.js frontend test suite across core contact management workflows.

**Key Outcomes:**
- Legacy Query Modernization: Replaced ad-hoc global data access with structured, cacheable query patterns in the PHP backend, enabling unit testability and sub-second query execution.
- Frontend Verification Gates: Hardened Ember.js automated test suites across core CRM contact workflows, creating safety gates that enabled non-breaking legacy PHP refactoring.

### Software Engineer & Technical Onboarding Lead (Fraud & Taxonomy Systems) at Groupon

**July 2011 - May 2013** | Chicago, IL

**Target Focus:** Implemented a centralized merchant taxonomy service in Java and MySQL, engineered analytical fraud detection in Vertica, and led global technical onboarding curricula during hyper-growth.

**Key Outcomes:**
- Centralized Taxonomy Service: Implemented merchant taxonomy service in Java and MySQL, eliminating categorization drift across distributed product teams during hypergrowth.
- Analytical Fraud Detection: Built analytical fraud detection queries in Vertica and conducted exploratory spikes on Hadoop and Clojure for transaction anomaly scoring.
- Merchant Analytics Pipelines: Built high-throughput merchant analytics tools in Ruby and CouchDB, surfacing market insights for global sales operations.
- Global Engineering Enablement: Redesigned technical onboarding curricula, standardizing engineering practices and shortening time-to-first-commit for 100+ global engineering hires.

---

## Selected Production Projects

### Principal Architect (WWWorkRemote)
**January 2021 - Present**

Rails 8 platform for multi-source job ingestion, semantic matching, and application automation, built as a working laboratory for local-first LLM orchestration and treating scraped third-party text as hostile input.


- Multi-Source Data Ingestion: Built a multi-source Rails ingestion pipeline and PostgreSQL storage schema, unifying fragmented job market datasets for structured downstream analysis.

- Semantic Search & Embeddings: Implemented vector search embeddings via pgvector, enabling high-precision semantic matching between complex candidate profiles and job requirements.

- Local-First AI Orchestration: Designed provider-agnostic LLM orchestration layer (llama.cpp/Ollama with hosted Claude fallback), enforcing local-first inference for sensitive data with per-call model routing.

- Prompt Injection Defense: Built a 4-stage guardrails pipeline screening untrusted scraped text via weighted heuristics and instruction-density scoring before model ingestion.

- Browser Extension & Lifecycle Capture: Built an MV3 Chrome extension with 16 provider adapters that extracts postings from live ATS pages and captures full application lifecycles.

- Architectural Constraint Injection: Injected static analysis rules and architectural constraints into model context windows, preventing drift between generated outputs and security contracts.


### Principal Engineer & Curator (Technical Conversation Archive)
**January 2011 - Present**

Recorded, and later restored, an archive of 214 technical interviews with practitioners from the Ruby, JVM, and Software Craftsmanship movements, using a local-only AI pipeline to transcribe, structure, and cross-link a longitudinal record of primary-source material into a searchable knowledge graph.


- Local-Only AI Restoration Pipeline: Built a Whisper and local-LLM pipeline that transcribes, diarizes, and structures long-form interview audio entirely on-device, keeping a large private media corpus off third-party inference services.

- Schema-Validated Content Platform: Runs on a contract-validated data layer: every interview, asset, and transcript is checked against an explicit schema at build time, with referential-integrity checks that fail the build rather than publishing broken data.

- Semantic Cross-Linking & Taxonomy Generation: Generates a topic taxonomy, knowledge graph, and semantic cross-links across the corpus, turning an unstructured media archive into navigable, individually indexed pages.

- Primary-Source Capture: Conducted the original interviews on-site at GOTO Conference, Software Craftsmanship North America, RailsConf, and WindyCityRails, with practitioners including Dave Thomas, Stuart Halloway, Corey Haines, Sandro Mancuso, and Micah Martin.

- Digital Archaeology: Recovered and reconstructed material from defunct platforms and web archives, reconciling incomplete metadata across sources to restore provenance for recordings that would otherwise have been lost.


### Principal Architect (Local AI Orchestration & Developer Runtime)
**January 2026 - Present**

Built and operate three MCP (Model Context Protocol) servers that expose live system state as callable tools to any MCP client, alongside the Claude Code skills, context-isolated subagents, and commit-time checks that keep agent work bounded and reviewable.


- Bidirectional Knowledge Server: Built ctx-mcp, an MCP server fronting a PostgreSQL knowledge suite that agents both query and write back to, so methodologies and lessons learned in one session are retrievable in the next rather than re-derived.

- Telemetry-Driven Diagnosis: Built o2-mcp, exposing on-demand OpenObserve telemetry (errors, slow spans, failed jobs, distributed traces) as agent-callable tools, so an agent diagnoses a running system from observed behavior instead of inferring from source.

- Context as a Budgeted Resource: Designed context-isolated subagents that keep high-volume audit work out of the main conversation's context window, with per-client registration tooling and pre-commit hooks that reject any agent asset that isn't self-describing.


---

## Additional Experience

- **Senior Software Developer**, BenchPrep (March 2017 - February 2018): Owned enterprise assessment workflows, leading correctness and platform security in a high-concurrency environment.
- **Senior Software Developer**, ReachLocal (March 2015 - November 2016): Owned API design and modernization strategy, leading incremental legacy migration for a high-volume digital marketing platform.
- **Open-Source Transition Lead**, Coderwall (January 2014 - December 2014): Hired as a contractor by the founder to lead the open-source transition of the Coderwall developer reputation platform, a Y Combinator-backed professional network for software engineers (856 GitHub stars, 304 forks). Delivered security hardening, proprietary service extraction, infrastructure modernization, and community leadership as the top contributor to the open-source codebase.
- **Principal Consultant**, Tandem (August 2018 - August 2018): Conducted an on-site architectural and operational assessment for an at-risk federal software program (DoD MEPS), delivering viability analysis and risk mitigation recommendations directly to executive leadership.

---

## Earlier Experience

**1999 - 2011**

Built and operated enterprise integrations, transactional systems, and early web products across consulting and product organizations, establishing the production discipline and community-centered craftsmanship that inform my leadership today.

- **Revenue-critical commerce**: Designed real-time inventory, locking, and fulfillment services for a high-volume ticket marketplace later acquired by a major industry operator.
- **Consulting and software craftsmanship**: Delivered systems across client environments while mentoring engineers, adopting Ruby and Rails, and helping build Chicago's craftsmanship community.
- **Enterprise and operational systems**: Built integration and operational software across large organizations, grounded in .NET, SQL, messaging, production support, and direct user needs.
