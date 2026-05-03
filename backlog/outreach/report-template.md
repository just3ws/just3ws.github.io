# Diagnostic Audit Report: [Client Name] - [System/Path]

**Engagement Type:** [48-Hour System Behavior Audit | Query & Data Integrity Triage]
**Analysis Date:** [Date]
**Consultant:** Mike Hall

---

## 1. Executive Summary
[High-level summary of the findings. What is the most critical bottleneck or risk identified? State the confidence level in the findings.]

## 2. Risk Ranking & Impact
| Risk | Severity | Business Impact |
|---|---|---|
| [Risk 1] | High | [e.g., Revenue leakage, data corruption] |
| [Risk 2] | Medium | [e.g., Deploy hesitation, support load] |

## 3. Behavior Map & Root Cause Analysis
### 3.1 Observed Execution Path
[Description of how the system actually behaves under the reported symptom, based on log reconstruction and trace analysis.]

### 3.2 Identified Root Cause
[Evidence-backed explanation of the failure mode. Cite specific log IDs, query metrics, or schema coupling.]

## 4. Query & Database Profile (if applicable)
[Summary of hot queries, lock contention patterns, or IO bottlenecks.]

## 5. Prioritized Remediation Plan
1. **Immediate (Next 24h):** [High-impact, low-effort fix]
2. **Short-term (Next Sprint):** [Architectural or indexing change]
3. **Strategic:** [Long-term resilience improvements]

---

## Appendix: Evidence Pack
- **Logs:** [Cluster summaries or relevant request IDs]
- **SQL:** [EXPLAIN output or slow query stats]
- **Schema:** [Relationship/hotspot maps]
