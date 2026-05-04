# Sample Deliverable: PII & Data Integrity Remediation Recipe

**Client:** [Sample Enterprise]  
**Engagement:** PII Risk Remediation  
**Date:** 2026-05-03

---

## 1. Process Mapping: Sensitive Data Surface
Based on the **Process Mapping** of your "User Onboarding" flow, we have identified the following silos containing sensitive data (SSNs, DOBs).

### Silo Inventory
| Silo | System Role | High-Risk Fields | Observed Integrity |
| :--- | :--- | :--- | :--- |
| **Primary Rails App** | User Intake | `encrypted_ssn` | High (Standard Rails pattern) |
| **Identity Service** | Verification | `raw_ssn` | **CRITICAL (Logging Leak)** |
| **Legacy Audit DB** | Historic Storage | `applicant_id`, `ssn` | Medium (Abandoned Silo) |

---

## 2. Discovery Findings: The "Dark Data" Layer
Using the **Orphan Discovery Framework**, I identified 3 tables in the legacy audit database that are no longer referenced in the current application logic but continue to receive writes via a background sync process.

*   **Risk**: These tables contain raw, unencrypted SSNs that bypass the primary system's security controls.
*   **Drift**: Approximately 4% of records in this silo have no corresponding `user_id` in the current system of record, representing an untraceable data liability.

---

## 3. The Remediation Recipe (Sequence)
To safely purge this data without breaking historical audit requirements or downstream syncs, the following sequence is required:

### Phase 1: Isolation (Days 1-2)
1.  **Tagging**: Flag all records in the orphan silo for review.
2.  **Correlation Mapping**: Use the `Correlation ID` from the intake log to map orphan records back to the primary identity system.

### Phase 2: Structural Purge (Days 3-4)
1.  **Dependency-Aware Deletion**: Execute the purge in this exact order to avoid data-integrity failures:
    *   `raw_response_logs` (Dependent)
    *   `temp_identity_fragments` (Dependent)
    *   `legacy_audit_records` (Primary)
2.  **Encryption Migration**: For records that must be retained, migrate them to the primary encrypted silo and purge the raw source.

### Phase 3: Process Integrity Lock (Day 5)
1.  **Instrumentation**: Add a `Process Mapping` hook to the background sync class to alert if a record is written to a legacy silo without a valid `request_id` correlation.
