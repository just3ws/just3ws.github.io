# The 90-Day System Cartography Playbook for Founder Transitions

When taking over a legacy platform after a founder transition or acquisition, traditional technical due diligence fails because it measures static code lines rather than operational state topology.

Here is the **4-Dimensional System Cartography Playbook** I used to stabilize a 130-clinic healthcare platform (EMR-Bear) in 90 days with **zero clinical downtime** and a **60% reduction in MTTR**.

---

### 1. Dimension 1: The Interaction Surface (Where Users Touch State)
- **Problem**: 130 clinics relying on real-time schedule syncing and clinical notes.
- **Action**: Map all public HTTP endpoints, background polling loops, and UI state triggers.
- **Rule**: Never trust architecture diagrams; trust TCP socket connections and network trace routes.

### 2. Dimension 2: Lateral State Dependencies (Where Shared Mutexes Hide)
- **Problem**: Hidden database locks during batch billing runs causing UI freezes during peak clinical hours.
- **Action**: Instrument PostgreSQL slow query logs and OpenTelemetry span attributes to isolate transactional contention points.
- **Rule**: If two asynchronous workers write to the same table, they are functionally synchronous.

### 3. Dimension 3: Supply Chain & Runtime Exposure (Where Third Parties Fail You)
- **Problem**: External API dependencies (e-prescribing, insurance eligibility checks) stalling web request worker threads.
- **Action**: Implement circuit breakers, strict timeout boundaries, and asynchronous queue isolation.
- **Rule**: Never allow a 3rd-party HTTP call to execute inside an un-budgeted database transaction.

### 4. Dimension 4: Measured Operational Proof (The Non-Negotiable Contract)
- **Outcome**: 
  - Reduced MTTR by **60%**.
  - **Zero clinical downtime** across 130+ clinics during a 90-day founder transition.
  - Reduced background queue backlog by **85%**.

---

*Mike Hall is a Principal Software Engineer & Systems Architect specializing in production reliability, legacy modernization, and 4D System Cartography audits for scaling engineering teams.*  
*Read full case study proof: [just3ws.com/case-studies/](https://just3ws.com/case-studies/)*
