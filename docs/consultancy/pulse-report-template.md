# Postgres Pulse: Finding Summary
**Client:** [Company Name]
**Date:** [Date]
**Consultant:** [Your Name]

---

## 1. The "Smoking Gun"
**Query ID:** `[Query ID]`
**Impact:** `[X]% of Total Execution Time`
**Diagnosis:** [One sentence: e.g., "Missing index on a high-churn table causing lock contention during peak load."]

## 2. Top 3 Performance Bottlenecks
| Rank | Query / Path | Primary Pain | Severity |
| :--- | :--- | :--- | :--- |
| 1 | `SELECT ... FROM orders` | Sequential Scan / IO | 🔥 High |
| 2 | `Sidekiq: TransactionJob` | Lock Contention | ⚠️ Med |
| 3 | `Auth Path` | Bloated Result Set | ℹ️ Low |

## 3. Evidence Notes
*   **IO Wait:** We observed high `IO:DataFileRead` on the `line_items` table.
*   **Memory:** Several queries are spilling to disk (External Merge Sort).
*   **Concurrency:** Lock waits detected on the `users` table during `ActiveRecord` callbacks.

## 4. Immediate Action Items
- [ ] **Create Index:** `CREATE INDEX CONCURRENTLY idx_orders_on_status_and_id...`
- [ ] **Rails Patch:** Wrap the `update_totals` call in a non-blocking background job.
- [ ] **Tuning:** Increase `maintenance_work_mem` to `256MB` for faster index builds.

---

## Next Steps: The 48-Hour Behavior Audit
While the **Pulse** identifies the *what*, the **Behavior Audit** maps the *why*. 
- Reconstruct the full end-to-end topography of the `Checkout` path.
- Identify silent record loss in background syncs.
- Deliver a verified "Normal State" map for your upcoming Rails 8 upgrade.

**Price:** $2,500 (Fixed)
**Timeline:** 2 Business Days
**[Link to Strategic Intake]**
