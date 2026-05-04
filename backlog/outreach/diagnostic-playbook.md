# The Architect's Diagnostic Playbook

This playbook codifies Mike's Staff-level architectural methodologies into a repeatable delivery process for solo consultancy engagements focused on **Process Mapping**.

---

## 1. Offer: Panoramic Process Mapping ($5,500)
**Core Methodology:** Process-to-System Mapping & Request Correlation.

### Phase 1: Context Download (Day 1)
*   **Action:** 90-minute expert walkthrough.
*   **Goal:** Identify the "Normal State" baseline. What is the business intent for this process?
*   **Evidence:** Document the expected entry, the systems involved in the stack, and the final exit/resolution.

### Phase 2: Evidence Validation (Day 2)
*   **Action:** Validate log verbosity and correlation ID coverage.
*   **Workflow:**
    1.  Client runs Mike's PII-scrubbing/sanitization script on production logs.
    2.  Mike validates that a unique `Request ID` or `Correlation ID` is traceable through at least two systems in the stack.
    3.  If logs are insufficient to map the topography, pause the sprint and guide the team to enable targeted instrumentation.

### Phase 3: Topography Correlation (Days 3-4)
*   **Action:** Apply the **Process Mapping Prompt** to the log clusters.
*   **Deliverable Steps:**
    1.  Map the system topography: identify every service and database touched by the process.
    2.  Identify "Orphan" or "Stalled" requests (Entry but no Exit).
    3.  Cluster failures by the specific system boundary where they occur.

### Phase 4: Legibility Briefing (Day 5)
*   **Action:** Deliver the "System Legibility Map."
*   **Outcome:** A visualization of the actual process flow vs. the expected intent. Hand back a prioritized sequence for instrumentation and remediation.

---

## 2. Offer: PII & Data Integrity Remediation ($7,500)
**Core Methodology:** Orphan Discovery & Structural Purging through Process Mapping.

### Phase 1: Data Silo Identification (Days 1-2)
*   **Action:** Identify all systems and tables that handle sensitive data for a specific process.
*   **Workflow:**
    1.  Perform a schema audit to find tables that are no longer part of the "Normal State" flow.
    2.  Search for "Dark Data": tables receiving writes that the primary application layer does not read.

### Phase 2: Process Integrity Audit (Day 3)
*   **Action:** Map how sensitive fields flow through the stack to identify leakage points.
*   **Outcome:** A catalog of PII risk areas that bypass the system's primary encryption or retention policies.

### Phase 3: The Remediation Recipe (Days 4-5)
*   **Action:** Design the "Dependency-Aware Deletion" sequence.
*   **Deliverable:** A literal SQL/Ruby recipe for purging the data safely across all identified silos.
*   **Outcome:** The client's team executes the purge; Mike validates that the remaining state matches the "Normal State" map.

---

## 3. The Solo Architect Workflow (You + AI)
*   **High-Volume Correlation:** The AI clusters IDs and maps the basic system topography.
*   **Architect's Verdict:** Mike reviews the mapping and identifies the critical system breakpoints.
*   **Liability Boundary:** Mike performs the final review of all AI-generated findings to ensure they reflect business and engineering reality.
