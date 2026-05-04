# Specialized Diagnostic Frameworks

This document codifies the high-value architectural frameworks for transforming raw client data into "Panoramic Views" through **Process Mapping**.

## 1. The Panoramic View Framework
**Goal:** Establish "System Normalcy" by mapping the end-to-end topography of a process and correlating requests through the entire stack.

### The Methodology:
1. **Entry Point Identification**: Identifying the start of a business process (e.g., UI interaction, API call, incoming webhook).
2. **Exit Point Identification**: Identifying the final resolution state (e.g., Database commit, external API success, notification).
3. **Error State Capture**: Pinpointing every state where the process deviates from "Normal."
4. **Topography Correlation**: Mapping the request as it traverses the stack (Rails, Redis, Background Jobs, Middleware, Postgres).

### AI Prompt Template:
> "Perform an end-to-end **Process Mapping** on these logs. 
> 1. Correlate all Request IDs involved in this specific business process.
> 2. Identify the system topography: which services, jobs, and tables are touched?
> 3. Trace the path from Entry to Exit.
> 4. Identify 'orphaned' or 'stalled' states where the process diverges from the Normal State."

---

## 2. Process to System Mapping (Legacy Entanglement)
**Goal:** Identifying all systems involved in a business process to resolve obscured behavior.

### The Methodology:
- **System Identification**: Cataloging every service, dependency, and data store touched by a process.
- **Boundary Analysis**: Defining where data enters and leaves each system.
- **Request Correlation**: Using unique identifiers to trace a single business action through the entire topography.

---

## 3. PII & Data Integrity Remediation
**Goal:** Structural cleanup of institutional data liabilities through process mapping.

### The Methodology:
- **Orphan Discovery**: Identifying data silos that are no longer part of the "Normal State" process flow.
- **Process Audit**: Mapping how sensitive data flows through the stack to identify unencrypted or legacy leakage points.
- **The Purge Recipe**: Building a dependency-aware sequence for institutional data purging.
