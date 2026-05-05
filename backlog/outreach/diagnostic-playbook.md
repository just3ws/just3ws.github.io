# The Architect's Diagnostic & Enablement Playbook

This playbook codifies Mike's Staff-level architectural methodologies into a repeatable delivery process for solo consultancy engagements focused on **System Topography** and **Team Enablement**.

---

## 1. Offer: System Topography Sprint ($4,500)
**Goal:** Establish the "Diagnostic Surface" and generate a "Panoramic View" of the Normal State while enabling the client's team.

### Phase 1: The Topography Audit (Day 1)
*   **The Baseline Quiz**: Use [`baseline-quiz.md`](baseline-quiz.md) to inventory the stack.
    1.  **Technical Inventory**: Languages, frameworks (Rails/Sidekiq biased), and hidden infrastructure coupling.
    2.  **Topography Reach**: Where is the first write? What are the immediate FK boundaries?
*   **Business Intent**: Identify the SME and the precise "Starting Point" of the flow.

### Phase 2: Boundary Evidence Capture (Day 2)
*   **Action**: Coordinate the capture of telemetry at the identified Starting Point.
*   **Artifacts**: HAR files (Browser), Nginx logs (Web Layer), Application logs, and DB Snapshots.

### Phase 3: Token Discovery (Days 3-4)
*   **Action**: Identify the creation of the unique "Process Token" that tracks the flow end-to-end.
*   **Coaching**: Explain the significance of the token and how it bridges system boundaries.

### Phase 4: The Topography Map Deliverable (Day 5)
*   **The Map**: A visual, left-to-right timeline of the business process.
    *   **Step-by-Step**: Screenshots of each stage of the user/customer interaction.
    *   **Data Flow**: Explicit input (left) and output (right) for every critical transition.
    *   **System Stack**: A vertical stack of the underlying systems, services, and calls involved in each step.
    *   **Decision Points**: "Big Red Xs" marking the critical code/logic paths where decisions are made.
*   **Optionality Review**: Present the findings and discuss next steps: internal execution, specialized hire, or continued partnership.

---

## 2. Offer: Process Integrity & SLOs ($7,500)
**Goal:** Structural resolution of debt and enabling long-term monitoring.

### Phase 1: Deep Reach & Upgrade Triage (Week 1)
*   **Action**: Map every logical and physical Foreign Key connected to the process entry point.
*   **Enablement**: Teach the team how to perform reach analysis for future paths.

### Phase 2: System of Record & Integrity Audit (Week 1)
*   **Action**: Identify where data is modified downstream and whether those changes are reflected in the original stack.
*   **Goal**: Find where the primary app is making decisions based on stale/local data.

### Phase 3: The Modernization Recipe (Week 2)
*   **Action**: Design a prioritized sequence for patching, purging, and executing platform upgrades.
*   **Outcome**: A high-confidence modernization roadmap and the capability to execute it.

---

## 3. The Engagement Value: Capability Transfer
Every layer of the Topography engagement is designed to level up the client's team while providing immediate architectural clarity.

### Value during Discovery:
- **Team Enablement**: The "Direct & Drive" model acts as a masterclass in system diagnostics. Your team doesn't just watch; they learn the methodology for mapping their own systems.
- **Architectural Autonomy**: By showing the team "how to fish," Mike provides the company with long-term options for maintaining system legibility without indefinite outside support.
- **Evidence-First Training**: Guiding the team through log correlation and HAR capture builds an internal culture of evidence-based decision making.

---

## 4. The Solo Architect Workflow (Architect as Coach)
*   **Advisory Phase**: Mike provides specific instructions on enabling log levels, diagnostic gems, and stat collection, teaching the team why these signals matter.
*   **Cross-Functional Discovery**: Mike coaches the Product Owner and Developer through the "Ground Truth" recording, teaching them how to reconcile business logic with technical artifacts.
*   **Mapping & Synthesis**: Mike builds the physical map alongside the team, explaining the architectural patterns and risks as they emerge.
*   **Strategic Hand-off**: Mike translates the findings into a roadmap that the team is now equipped to evaluate or execute themselves.
