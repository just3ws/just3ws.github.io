# The Architect's Diagnostic Playbook

This playbook codifies Mike's Staff-level architectural methodologies into a repeatable delivery process for solo consultancy engagements focused on **Process Mapping**.

---

## 1. Offer: Process Discovery Sprint ($4,500)
**Goal:** Establish the "Diagnostic Surface" and define the "Normal State."

### Phase 1: The Baseline Audit (Day 1)
*   **The Baseline Quiz**: Use [`baseline-quiz.md`](baseline-quiz.md) to inventory the stack.
    1.  **Technical Inventory**: Languages, frameworks (Rails/Sidekiq biased), and infrastructure ownership.
    2.  **Reach Analysis**: Where is the first write? What are the immediate FK boundaries?
*   **Business Intent**: Identify the SME and the precise "Starting Point" of the flow.

### Phase 2: Boundary Evidence Capture (Day 2)
*   **Action**: Coordinate the capture of telemetry at the identified Starting Point.
*   **Artifacts**: HAR files (Browser), Nginx logs (Web Layer), Application logs, and DB Snapshots.

### Phase 3: Token Discovery (Days 3-4)
*   **Action**: Identify the creation of the unique identifier that tracks the flow.
*   **Discovery**: How does this token move from the Entry Point into deeper systems?

### Phase 4: Diagnostic Surface Map (Day 5)
*   **Deliverable**: A comprehensive list of systems, versions, and the entry-to-token path.
*   **Risk Identification**: First-pass identification of **System of Record** conflicts.

---

## 2. Offer: Data Mapping & Integrity Triage ($7,500)
**Goal:** Structural resolution of data drift and system-of-record risk.

### Phase 1: Deep Reach Analysis (Week 1)
*   **Action**: Map every logical and physical Foreign Key connected to the process entry point.
*   **Goal**: Identify the "Surface Area" of the data. How many systems are touched by one form submission?

### Phase 2: System of Record Audit (Week 1)
*   **Action**: Identify where data is modified downstream and whether those changes are reflected in the original stack.
*   **Goal**: Find where the primary app is making decisions based on stale/local data.

### Phase 3: The Remediation Recipe (Week 2)
*   **Action**: Design a sequence for purging orphan data or synchronizing state.
*   **Outcome**: A verified path to process integrity.

---

## 3. The Engagement Value: Context & Alignment
Every layer of the Process Mapping engagement is designed to provide value to the client's team before the final report is even drafted.

### Value during Discovery:
- **Shared Context**: The "Baseline Quiz" forces teams out of silos and creates a shared language for the stack.
- **Immediate Insights**: As entry points are identified and tokens discovered, teams gain real-time awareness of their observability gaps.
- **Evidence-First Training**: Guiding the team through log correlation and HAR capture levels up their internal diagnostic capabilities.

### Value during Mapping:
- **High-Confidence Baseline**: Providing the team with a verified map of the "Normal State" reduces finger-pointing during incidents.
- **Target State Enablement**: By clearing the "mud" of the current state, Mike frees technical leadership to focus on long-horizon architectural shifts with certainty.

## 4. The Solo Architect Workflow (You + AI)
*   **Engagement Lead**: Mike facilitates the discovery sessions, ensuring the business intent is aligned with technical reality.
*   **High-Volume Correlation**: The AI clusters IDs and maps the basic system topography.
*   **Architect's Verdict**: Mike reviews the mapping and identifies the critical system breakpoints.
*   **Target State Bridge**: Mike translates the "Normal State" findings into actionable steps for the client's future architecture.
