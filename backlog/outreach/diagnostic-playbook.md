# The Architect's Diagnostic Playbook

This playbook codifies Mike's Staff-level architectural methodologies into a repeatable delivery process for solo consultancy engagements focused on **Process Mapping**.

---

## 1. Offer: Process Discovery Sprint ($4,500)
**Goal:** Establish the "Diagnostic Surface" and define the "Normal State."

### Phase 1: The Baseline Audit (Day 1)
*   **The Baseline Quiz**: For every system in the suspected path, identify:
    1.  **Languages & Versions**: (e.g., Ruby 3.2, Node 18)
    2.  **Frameworks & Versions**: (e.g., Rails 7.1, Express 4)
    3.  **Infrastructure Ownership**: Do you manage the servers/DB, or is it delegated? To which group?
*   **Business Entry Point**: Where does the business consider the start of the critical flow?
    *   Is it a customer-initiated click? 
    *   Is it a scheduled job?
    *   Document the precise starting point from the business perspective.

### Phase 2: Boundary Evidence Capture (Day 2)
*   **Action**: Help the team capture telemetry at the starting point.
*   **Evidence Types**:
    1.  **Browser/UI**: HAR files.
    2.  **Web Layer**: Nginx/Apache logs.
    3.  **App Layer**: Rails/App production logs.
    4.  **Analytics**: Segment/Mixpanel/Amplitude dumps.

### Phase 3: Token Discovery (Days 3-4)
*   **Action**: Identify the creation of the unique identifier that tracks the flow.
*   **Goal**: Find the `Request ID`, `Correlation ID`, `JWT`, or `Transaction Token` that is relevant to the business flow.
*   **Discovery**: How does this token move from the Entry Point into deeper systems?

### Phase 4: Diagnostic Surface Map (Day 5)
*   **Deliverable**: A comprehensive list of systems, versions, owners, and the entry-to-token path. 
*   **Outcome**: The client now has a legible map of what they are actually running, ready for full mapping.

---

## 2. Offer: Panoramic Process Mapping ($7,500)
**Goal:** Full topography reconstruction (Follow-on to Discovery).

### Phase 1: Cross-Silo Correlation (Week 1)
*   **Action**: Use the Process Token to trace requests through the identified systems.
*   **Goal**: Identify every system boundary where the token is lost or dropped.

### Phase 2: Topography Visualization (Week 2)
*   **Action**: Map the actual path vs. the business intent.
*   **Outcome**: Identify "silent drops" and integrity drift.

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
