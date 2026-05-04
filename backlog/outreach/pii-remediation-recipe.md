# Sample Deliverable: PII & Data Integrity Remediation Recipe

**Client:** [Sample Fintech/Healthtech]  
**Engagement:** PII Risk Remediation (Track B)  
**Date:** 2026-05-03

---

## 1. The Panoramic View: Applicant Data Surface
Based on the **ACQ Mapping** of your "Apply-to-Bureau" flow, we have identified the following silos containing sensitive Applicant PII (SSNs, DOBs).

### Silo Inventory
| Silo | Table Count | High-Risk Fields | Observed Integrity |
| :--- | :--- | :--- | :--- |
| **ACQ Monolith** | 12 | `ssn`, `tax_id`, `dob` | High (Rails managed) |
| **Legacy post-ACQ** | 8 | `encrypted_ssn` | Medium (Old encryption keys) |
| **`clarity_` Orphans** | 10 | `applicant_identifier` | **CRITICAL (Abandoned)** |

---

## 2. Discovery Findings: The "Dark Data" Layer
Using the **Orphan Discovery Framework**, I identified 3 tables in the `clarity_` prefix that are no longer referenced in the current Rails application code but continue to receive sync updates from the Bureau check process.

*   **Risk**: These tables contain raw 9-digit SSNs that bypass the current app's encryption layer.
*   **Drift**: Approximately 4.2% of records in `clarity_raw_responses` have no corresponding `user_id` in the primary monolith.

---

## 3. The Remediation Recipe (Sequence)
To safely purge this data without breaking legacy reporting or downstream syncs, the following sequence is required:

### Phase 1: Isolation (Days 1-2)
1.  **Tagging**: Apply a `remediation_pending` boolean to the `clarity_` tables.
2.  **Backfill Correlation**: Use the Bureau Request ID to map orphan records back to the `applications` table.

### Phase 2: Structural Purge (Days 3-4)
1.  **Dependency-Aware Deletion**: Execute the purge in this exact order to avoid FK violations:
    *   `clarity_raw_payloads` (Dependent)
    *   `clarity_score_components` (Dependent)
    *   `clarity_applicants` (Primary)
2.  **Zero-Fill**: For records that must remain for financial audit but exceed PII retention windows, zero-fill the `ssn` field instead of row-deletion.

### Phase 3: Integrity Lock (Day 5)
1.  **Instrumentation**: Add a Rails `ActiveSupport::Notification` hook to the Bureau sync class to alert if a record is written to a legacy table without a primary `user_id`.

---

## 4. Maintenance & "Normal State"
To maintain this remediation, the team should adopt the **Panoramic View Monitor** for the Acquisition lane, ensuring no new silos are introduced during feature development.
