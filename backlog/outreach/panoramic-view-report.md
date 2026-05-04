# Sample Deliverable: Panoramic Lifecycle Map

**Client:** [Sample E-commerce/SaaS]  
**Engagement:** Panoramic Lifecycle Mapping  
**Date:** 2026-05-03

---

## 1. Executive Summary: The Acquisition Funnel "Ghost"
We identified a persistent data-loss anomaly between the **Affiliate Entry Point** and the **Customer Database**. 

*   **The Problem**: 2.5% of "Success" responses from the payment gateway are not resulting in a committed `Subscription` record in Postgres.
*   **The Root Cause**: A race condition in the `Webhook::ProcessingJob` where the `AffiliateMapping` record is not yet committed when the webhook arrives, causing a silent drop of the attribution data.

---

## 2. The Panoramic Map: Path Reconstruction
Below is the topography of the Acquisition funnel as mapped from production logs.

### Entry: Affiliate Intake
*   **Location**: `app/controllers/affiliates_controller.rb`
*   **State**: Success (200 OK)
*   **Payload**: `affiliate_id`, `click_id`, `timestamp`

### The "Silo Bridge": Redis/Sidekiq
*   **Location**: `AffiliateAttributionJob`
*   **Observed Behavior**: Requests are successfully enqueued but occasionally stall for 500ms due to Redis memory pressure.

### Exit: Subscription Commitment
*   **Location**: `app/services/subscriptions/create_service.rb`
*   **Observed Behavior**: The `after_commit` hook in the User model occasionally fails to find the corresponding `AffiliateClick` record because the attribution job is still in `retry` state.

---

## 3. Topography of Failure (Anomalies)
| Request ID | Entry State | Breakpoint | Result |
| :--- | :--- | :--- | :--- |
| `req_abc_123` | Success | `WebhookProcessor` | **SILENT DROP** (No attribution) |
| `req_def_456` | Success | `SubscriptionService` | **SUCCESS** (Fully mapped) |
| `req_ghi_789` | Error (422) | `AffiliateController` | **EXPECTED ERROR** (Invalid ID) |

---

## 4. Remediation Sequence
1.  **Immediacy**: Move the `AffiliateMapping` lookup from an async job to the synchronous controller path for high-priority funnels.
2.  **Robustness**: Implement a 3-second "Exponential Jitter" on the Webhook processing job to allow attribution persistence to catch up.
3.  **Observability**: Add `request_id` correlation across the MuleSoft bridge to ensure a true Panoramic View in your ELK/Instana dashboard.
