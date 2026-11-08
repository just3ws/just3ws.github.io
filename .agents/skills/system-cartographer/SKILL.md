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

## Evaluation & Tone Guidelines

- **Staff IC Signal**: Frame decisions around structural outcomes, risk mitigation, and unblocking engineering teams rather than tactical task completion.
- **Strict Title Compliance**: Maintain **Staff Software Engineer** as Mike's primary identity. Use **Staff Engineer** after the context is established. Principal Engineer remains a target-specific scale calibration, not the default identity. Do not introduce invented specialty titles.
- **Empirical Evidence**: Back every architectural claim with measurable scope, operational consequences, or zero-drift verification gates.
