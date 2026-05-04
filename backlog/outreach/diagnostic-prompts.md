# Specialized Diagnostic Frameworks

This document codifies the high-value architectural frameworks derived from Mike's career as a Senior Staff Architect. These prompts and methodologies are used to transform raw client data into "Panoramic Views."

## 1. The Panoramic View Framework
**Goal:** Establish "System Normalcy" by mapping the end-to-end topography of a process.

### The Methodology:
1. **Entry Point Capture**: Identify the absolute start of the request (e.g., Affiliate link, API call).
2. **Exit Point Capture**: Identify the final success state (e.g., Postgres record committed, 200 OK).
3. **Error State Capture**: Identify every breakpoint (Retry loops, silent drops, exceptions).
4. **Topography Mapping**: Reconstruct the flow across Rails, background jobs, and third-party silos.

### AI Prompt Template:
> "Analyze these Rails logs using the Panoramic View framework. 
> 1. Cluster all Request IDs that share a common Entry Point.
> 2. Trace them to their final Exit Point in the DB or downstream service.
> 3. Identify any 'orphan' requests that have an entry but no visible exit.
> 4. Map the 'error topography'—where do these orphans typically stall?"

---

## 2. ACQ Mapping (Legacy Entanglement)
**Goal:** Untangle mixed logic in legacy monoliths to define "What exactly is our product?"

### The Methodology:
- **Asset Identification**: Cataloging every Rails file, service, and DB table responsible for the lane.
- **Decision Logic Extraction**: Pulling out the hidden business rules mixed with infrastructure code.
- **Dependency Mapping**: Identifying "MuleSoft/IBM i/z" style dependencies that obscure the flow.

---

## 3. PII & Orphan Remediation
**Goal:** Structural cleanup of institutional data liabilities.

### The Methodology:
- **Orphan Discovery**: Searching for legacy table prefixes (e.g., `clarity_`) or abandoned applicant tables.
- **Deep Schema Audit**: Searching for 9-digit patterns (SSNs) in non-obvious fields.
- **The Purge Recipe**: Building a dependency-aware deletion sequence to ensure data integrity during cleanup.

---

## 4. The "Bourne" Pattern (Solo Execution)
**Goal:** High-competence, autonomous resolution of systemic messes.
- **Solo Advantage**: Direct access, zero "junior" overhead, architect-level judgment.
- **Mechanism**: Use AI for compression and clustering; use Mike for the "System Normal" verdict.
