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

## 3. The Solo Architect Workflow (You + AI)
*   **Phase 1 (Discovery)**: Mike leads the "Baseline Quiz" and "Entry Point" sessions. AI helps summarize the findings.
*   **Phase 2 (Mapping)**: AI clusters the Process Tokens through log dumps. Mike provides the architectural verdict on the breakpoints.
