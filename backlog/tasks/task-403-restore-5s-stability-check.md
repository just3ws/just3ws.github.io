---
id: TASK-403
title: "Restore 5-Second Multi-Sample Ingress Stability Verification Guard"
status: Pending
category: media
created_date: '2026-10-26 02:41'
type: bug
priority: high
tags:
  - media-pipeline
  - stability-guard
  - ingress
  - file-upload
---

## Description
<!-- SECTION:DESCRIPTION:BEGIN -->
Closes Gap 2 by restoring the robust 5-second multi-sample stability verification algorithm in `ScanIntakeQueuesJob`:

1. **Root Cause**:
   - `ScanIntakeQueuesJob#stable_file?` currently sleeps only `0.2` seconds (200ms) between size measurements.
   - During mobile cellular or bursty Wi-Fi uploads, multi-gigabyte file chunks easily pause for >200ms between TCP window flushes.
   - Files are prematurely admitted to `pending` queue while in-flight, causing truncated audio and FFmpeg stream corruption.

2. **Resolution Algorithm**:
   - Sample file size at $t_0$.
   - Sleep 3 seconds, sample at $t_1$.
   - Sleep 2 seconds, sample at $t_2$.
   - Verify $t_0 == t_1$, $t_1 == t_2$, and $t_0 > 0$.
   - Reject zero-byte or size-changing files until mobile sync completely finishes.
<!-- SECTION:DESCRIPTION:END -->

## Execution Plan
<!-- SECTION:PLAN:BEGIN -->
- [ ] Step 1: Update `ScanIntakeQueuesJob#stable_file?` with 3s + 2s multi-sample verification.
- [ ] Step 2: Ensure test environment bypasses or stubs the sleep duration to keep RSpec test runs fast.
- [ ] Step 3: Write characterization specs in `spec/jobs/scan_intake_queues_job_spec.rb` verifying active uploads are rejected and settled files are accepted.
- [ ] Step 4: Verify test suite and fast validation pass cleanly.
<!-- SECTION:PLAN:END -->
