---
name: system-cartographer
description: Audits, structures, and generates 4-dimensional System Cartography case studies and legacy modernization summaries for Principal Software Engineer surfaces.
---

# System Cartographer Skill

Use this skill when evaluating, authoring, or refining technical case studies, architectural trade-offs, and legacy system discovery writeups for Mike's resume or portfolio surfaces.

## The 4 Cartography Dimensions

Every System Cartography case study or high-impact technical highlight must evaluate systems across four explicit dimensions:

1. **Interaction Surface**:
   - APIs, web contracts, client boundaries, GraphQL/REST endpoints, authentication, and external consumer contracts.
2. **Lateral State Dependencies**:
   - Cross-domain state mutations, async messaging events (Sidekiq, Redis, Kafka), transactional boundaries, and database locks.
3. **Full-Stack Topology & Infrastructure Valuation**:
   - Network paths, ingress routing, Kubernetes/container deployments, cloud infrastructure, and data store topologies.
   - Evaluates infrastructure investments by mapping key decision points directly to the systems they run on, revealing infrastructure value through the business capabilities it sustains.
4. **Supply Chain & Operational Exposure**:
   - Third-party SaaS tools, dependency drift, regulatory/HIPAA/compliance boundaries, and release safety verification gates.

## Core Cartography Doctrines

### 1. Business Decisions as Tracked Assets and Radius of Impact
Capture business decisions as concrete, tracked system assets mapped to code paths, services, and operational boundaries. Treating decisions as tracked assets establishes an explicit radius of impact, preserving critical context and preventing unintended regressions during modernization.

### 2. Infrastructure Value Mapped to Business Value
Infrastructure does not exist as an isolated compute or storage cost. When decision points are mapped to deployed infrastructure, the value of that infrastructure is revealed by the business value of the system it sustains. Decisions regarding infrastructure support and investment over time must account for holistic value: supporting both the computing infrastructure and the people who maintain it long term.

### 3. The Multi-Dimensional Time Vector
The time dimension of a transaction is not limited to network latency or API response milliseconds. In Panoramic View cartography, the time vector measures:
- **Context Loading Costs**: The cognitive and compute latency required for engineers or AI agents to recover and verify the rationale behind a system path.
- **Knowledge Attrition & Rot Acceleration**: The rate at which undocumented assumptions decay over time due to turnover, architectural drift, or organizational silos.
Sustained cartography reduces context loading friction and halts knowledge rot.

### 4. Dual Grounding: Aligning Humans and Grounding AI Agents
Panoramic View originally gave cross-functional human teams (Product, Engineering, Operations, Leadership) a shared empirical model. That same cartography is equally vital for AI agents. Autonomous coding and diagnostic agents require bounded context, explicit blast radii, and verified decision anchors to execute safely without hallucinating or thrashing.

## Panoramic View Labs (PVL) & Pavel

Panoramic View is the system-cartography technique. Panoramic View Labs (PVL, pronounced "Pavel") is the initiative and organizational umbrella. Pavel is the Panoramic View specialist agent responsible for leading runtime investigations, tracing actor journeys from browser to backend, discovering modernization seams, and enforcing the PSGOI and PCMS standards across all repositories (media-pipeline, zdots, just3ws, wwworkremote).

## The PSGOI Framework

Every system analyzed or modernized under Panoramic View uses the PSGOI scaffolding to align process architecture, support, and maintenance:

1. **Problem (P)**: The empirical friction point, legacy failure mode, or unverified cross-boundary assumption that invites technical debt or context thrashing.
2. **Strategy / Solution (S)**: The architectural mechanism chosen to isolate and resolve the problem (for example, standard BPMN 2.0 Call Activities, dual-ingress routing, or isolated aggregate health drawers).
3. **Goal (G)**: The durable system invariant that must never be compromised (for example, zero permanent local SSD consumption, fair-share FIFO dispatch, or sovereign archive integrity).
4. **Objective (O)**: The concrete, observable milestones across the execution trail (for example, sub-second STT latency, dual-format convergence on shared GPU compute, or clean error offramps).
5. **Indicator (I)**: The measurable SLI or gate decision metric recorded by the telemetry bus (for example, 24-hour intermittent failure count, p95 whole-path duration, or explicit exit versus error routing counts).

## PCMS Checklists (System Health & Evolution)

While each system operates under unique local constraints (compute hardware, storage layers, quota budgets, or third-party APIs), the Panoramic Cartography & Modernization System (PCMS) enforces universal health and evolution checklists:

### Checklist 1: Sovereign Subprocess Isolation
- Does the subsystem define and own its authoritative BPMN 2.0 flow specification (for example, `ztranscribe.v1.yml`) instead of being hardcoded as an implicit internal branch of the parent caller?
- Does the child flow declare its own distinct swimlanes, entry events, gateways, and terminal exits?

### Checklist 2: Explicit Domain Boundaries & Multi-Layer Health
- Does the parent workflow isolate subsystem failures into an aggregate health signal (Healthy, Degraded, Unhealthy) rather than halting unrelated parent stages?
- Does the subsystem health service audit the entire vertical stack through explicit operational layers:
  - L0: Compute Silicon (Metal GPU, CPU threads, hardware acceleration)
  - L1: System CLI Binaries (executables on PATH, exit codes)
  - L2: Model Weights & Static Assets (presence, integrity, checksums, sizes)
  - L3: Storage Engine & Vector Database (PostgreSQL, pgvector, HTTP health endpoints)
  - L4: Auxiliary Services (diarization tokens, secondary processors)
  - L5: Telemetry & SLO Signals (24-hour error windows, intermittent failure dampening)

### Checklist 3: 1:1 BPMN 2.0 Diagram Interchange (BPMNDI) Parity
- Does the system export valid OMG BPMN 2.0 XML containing both the semantic execution process and the complete `<bpmndi:BPMNDiagram>` plane?
- Do reusable subprocess calls use standard `<bpmn:callActivity calledElement="...">` bindings?
- Can the exported XML be loaded directly into Camunda Modeler or online viewers (such as demo.bpmn.io) with 1:1 visual fidelity, intact swimlanes, and routed waypoints?

### Checklist 4: Deterministic Proof Harness
- Does the toolchain expose an automated proof suite (for example, `bin/mp panoramic prove-subprocess`) that verifies flow contracts, gateway logic, dual ingress paths, health layers, and HTTP endpoints in CI and pre-push gates?

## Corporate Terminology Integration: SLO, SLI, SLA, OKR & Systems Health

To communicate effectively with corporate executive leadership, SRE teams, and cross-functional product organizations, Panoramic View maps clinical treatment planning, systems cartography, and corporate frameworks into a single unified health model:

### The Rosetta Stone of Systems Health & Evolution

| Health Dimension | Clinical Treatment Planning | Corporate Leadership (OKRs) | SRE & Systems Reliability | Panoramic View & PCMS |
| :--- | :--- | :--- | :--- | :--- |
| **The Friction** | Problem / Clinical Diagnosis | Strategic Bottleneck / Threat | Incident / Latent Reliability Risk | Tracked Friction Seam / Blast Radius |
| **The North Star** | **Treatment Goal** (Long-term client wellness and autonomy) | **Objective (O)** (Inspirational, qualitative strategic destination) | **SLA** (Contractual business boundary and promise) | **System Invariant** (Zero disk waste, calm autonomy, archive durability) |
| **The Target** | **Objective** (Observable, time-bound behavioral milestones) | **Key Result (KR)** (Measurable, verifiable threshold: 0 to 1.0) | **SLO** (Agreed reliability threshold, for example 99.5% success) | **Target Gateway State** (Clean exit routing, whole-path p95 target) |
| **The Measurement** | Clinical Assessment Score / Vitals | Performance Metric / Key Result Progress | **SLI** (Raw quantitative metric: latency, error rate, saturation) | **Checkpoint Measurement** (24h error count, checkpoint p95 latency) |
| **The Action** | Clinical Intervention / Modality | Strategic Initiative / Engineering Refactor | Error Budget Policy / Self-Healing Runbook | Automated Proof Harness / Isolated Degradation Seam |
| **The Continuity** | **Nurse Shift Handoff (SBAR)** | Quarterly Business Review & Cadence | On-Call Shift Handoff & Incident Review | **zdots Session Handoff & Carried Context** |

### Operational Dynamics Over Time

1. **Goals and SLAs Protect Architectural Wellness**:
   - Goals establish what the system must be to remain viable. An SLA or system invariant (such as zero permanent local SSD consumption or strict FIFO publication) is not an arbitrary metric. It defines the boundary of sustainable operation.
2. **Objectives and SLOs Govern Evolutionary Velocity**:
   - SLOs and Key Results act as the operating budget. When a system consumes its error budget (for example, when ztranscribe telemetry records two intermittent errors in 24 hours), the system does not panic or crash. It signals `DEGRADED`, triggering preflight checks and cooling publication batches until the objective is re-stabilized.
3. **Interventions Are Explicit Runbooks, Not Guesswork**:
   - When an indicator (SLI) deviates from an objective (SLO), interventions must not be ad-hoc. They are mapped directly to self-healing runbooks (for example, `bin/mp panoramic verify-scheduling` or `bin/mp panoramic prove-subprocess`).
4. **Shift Handoffs Guarantee Continuity of Care**:
   - Just as rotating clinical shifts require structured SBAR handoffs, rotating AI agents and human operators require the session handoff file (`~/.config/adots/handoffs/YYYY-MM-DD.md`). It transmits current vitals (L0-L5 stack status), open threads, pending news (background timers, async enqueue states), and watch items so the incoming shift operates with complete context.

## Evaluation & Tone Guidelines

- **Staff IC Signal**: Frame decisions around structural outcomes, risk mitigation, and unblocking engineering teams rather than tactical task completion.
- **Strict Title Compliance**: Maintain **Staff Software Engineer** as Mike's primary identity. Use **Staff Engineer** after the context is established. Principal Engineer remains a target-specific scale calibration, not the default identity. Do not introduce invented specialty titles.
- **Empirical Evidence**: Back every architectural claim with measurable scope, operational consequences, or zero-drift verification gates.
