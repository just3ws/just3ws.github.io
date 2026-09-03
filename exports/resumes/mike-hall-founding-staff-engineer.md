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

0-to-1 Full-Stack Architecture & Rapid Prototyping, Local-First AI Orchestration (llama.cpp, whisper.cpp, Claude API), Vector Embeddings & Semantic Search (PostgreSQL pgvector), Prompt Injection Defense & Multi-Stage Guardrails, AI Agent Workflows & MCP Server Integration (Python, Node.js), Automated Schema Inference & Dynamic JSON Pipelines, Ruby on Rails, Node.js, WebSockets & Real-Time Sync, High Agency, Autonomous Problem Solving

---

## Experience & Leadership

### Associate Director, Staff Engineer at OneMain Financial

**January 2021 - February 2026** | Remote

**Target Focus:** Built practical AI prototypes with a hackathon team, introduced local-first workflows through Geekfest@OMF, and helped establish safer ways to apply emerging tools to platform work.

**Key Outcomes:**
- Led modernization of high-consequence customer workflows, aligning engineering, product, and operations around explicit system boundaries.
- Built data-risk remediation and architecture-discovery practices that made legacy dependencies visible and safer to change.
- Diagnosed a production state-management defect affecting application completion and moved the system to a more durable session design without interrupting service.
- Established distributed observability across application and integration boundaries, improving the evidence available during incident response.
- Built communities of practice, mentoring loops, and handoff mechanisms that distributed technical ownership beyond a single engineer.

### Principal Architect at Phalanx Duel

**January 2022 - Present** | Independent Project

**Target Focus:** Built a server-authoritative deterministic game platform in TypeScript and Node.js: pure rules engine, append-only action ledger, WebSocket real-time sync, and property-based Truth Gate verification gates across the full state lifecycle.

**Key Outcomes:**
- Designed replayable state transitions so complex outcomes remain reproducible and independently reviewable.
- Built verification gates that test system behavior across the full lifecycle.

### Principal Architect at WWWorkRemote

**January 2021 - Present** | Independent Project

**Target Focus:** Architected multi-source Rails ingestion pipeline, pgvector semantic search, local-first YAML model registry, 4-stage prompt injection defense, and 16-adapter MV3 Chrome extension.

**Key Outcomes:**
- Unified fragmented sources into a searchable data model for downstream analysis.
- Designed local-first AI workflows with explicit safety boundaries around untrusted input and sensitive context.

### Principal Engineer & Curator at Technical Conversation Archive

**January 2011 - Present** | Independent Project

**Target Focus:** Built local-only Whisper transcription pipeline, semantic taxonomy cross-linking, and build-time schema enforcement gates for a multi-decade tech interview media corpus.

**Key Outcomes:**
- Local-Only AI Restoration Pipeline: Built a Whisper and local-LLM pipeline that transcribes, diarizes, and structures long-form interview audio entirely on-device, keeping a large private media corpus off third-party inference services.

- Schema-Validated Content Platform: Runs on a contract-validated data layer: every interview, asset, and transcript is checked against an explicit schema at build time, with referential-integrity checks that fail the build rather than publishing broken data.

- Semantic Cross-Linking & Taxonomy Generation: Generates a topic taxonomy, knowledge graph, and semantic cross-links across the corpus, turning an unstructured media archive into navigable, individually indexed pages.

- Primary-Source Capture: Conducted the original interviews on-site at GOTO Conference, Software Craftsmanship North America, RailsConf, and WindyCityRails, with practitioners including Dave Thomas, Stuart Halloway, Corey Haines, Sandro Mancuso, and Micah Martin.

- Digital Archaeology: Recovered and reconstructed material from defunct platforms and web archives, reconciling incomplete metadata across sources to restore provenance for recordings that would otherwise have been lost.


---

## Selected Production Projects

### Principal Architect (Local AI Orchestration & Developer Runtime)
**January 2026 - Present**

Built and operate three MCP (Model Context Protocol) servers that expose live system state as callable tools to any MCP client, alongside the Claude Code skills, context-isolated subagents, and commit-time checks that keep agent work bounded and reviewable.


- Bidirectional Knowledge Server: Built ctx-mcp, an MCP server fronting a PostgreSQL knowledge suite that agents both query and write back to, so methodologies and lessons learned in one session are retrievable in the next rather than re-derived.

- Telemetry-Driven Diagnosis: Built o2-mcp, exposing on-demand OpenObserve telemetry (errors, slow spans, failed jobs, distributed traces) as agent-callable tools, so an agent diagnoses a running system from observed behavior instead of inferring from source.

- Context as a Budgeted Resource: Designed context-isolated subagents that keep high-volume audit work out of the main conversation's context window, with per-client registration tooling and pre-commit hooks that reject any agent asset that isn't self-describing.


---

## Additional Experience

- **Open-Source Transition Lead**, Coderwall (January 2014 - December 2014): Hired as a contractor by the founder to lead the open-source transition of the Coderwall developer reputation platform, a Y Combinator-backed professional network for software engineers (856 GitHub stars, 304 forks). Delivered security hardening, proprietary service extraction, infrastructure modernization, and community leadership as the top contributor to the open-source codebase.
- **Senior Software Developer**, ReachLocal (March 2015 - November 2016): Owned API design and modernization strategy, leading incremental legacy migration for a high-volume digital marketing platform.
- **Senior Backend Developer**, SK Holdings, Inc. (January 2019 - December 2020): Led backend stability, performance, and modernization for high-traffic Rails products, improving full-text search, campaign delivery pipelines, and data layer reliability while systems remained under production load.
- **Software Engineer & Technical Onboarding Lead (Fraud & Taxonomy Systems)**, Groupon (July 2011 - May 2013): Owned core backend systems for fraud and taxonomy, leading global engineering enablement during hyper-growth.
- **Senior .NET Developer**, TicketsNow (November 2005 - March 2007): Owned real-time inventory systems, leading transactional integrity and iterative delivery for revenue-critical operations.

---

## Earlier Experience

**Selected earlier experience**

Built and operated enterprise integrations, transactional systems, and early web products across consulting and product organizations, establishing the production discipline and community-centered craftsmanship that inform my leadership today.

- **Revenue-critical commerce**: Designed real-time inventory, locking, and fulfillment services for a high-volume ticket marketplace later acquired by a major industry operator.
- **Consulting and software craftsmanship**: Delivered systems across client environments while mentoring engineers, adopting Ruby and Rails, and helping build Chicago's craftsmanship community.
- **Enterprise and operational systems**: Built integration and operational software across large organizations, grounded in .NET, SQL, messaging, production support, and direct user needs.
