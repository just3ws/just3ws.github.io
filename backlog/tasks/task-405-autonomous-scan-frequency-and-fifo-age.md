---
id: TASK-405
title: "Tune Autonomous Scan Frequency and Chronological FIFO Age Resolution"
status: Completed
category: media
created_date: '2026-10-26 02:41'
type: feature
priority: medium
tags:
  - media-pipeline
  - queue-polling
  - fifo-ordering
  - camera-timestamps
---

## Description
<!-- SECTION:DESCRIPTION:BEGIN -->
Closes Gaps 4 and 5 by tuning Solid Queue recurring polling frequency and restoring multi-tiered chronological FIFO age resolution:

1. **Autonomous Polling Latency**:
   - In `config/recurring.yml`, `scan_intake_queues` currently runs `every 10 minutes` in `development`.
   - Update to run `every 1 minute` in `development` so new camera uploads are processed autonomously with minimal delay.

2. **Chronological FIFO Age Resolution**:
   - `ScanIntakeQueuesJob#find_first_eligible_candidate` currently sorts candidates strictly by `File.mtime`. Cloud storage synchronization often stamps the file's `mtime` with sync time rather than recording time.
   - Update to parse camera recording timestamp (`VID_YYYYMMDD_HHMMSS`), falling back to APFS `File.birthtime`, and lastly `File.mtime`.
<!-- SECTION:DESCRIPTION:END -->

## Execution Plan
<!-- SECTION:PLAN:BEGIN -->
- [x] Step 1: Update `config/recurring.yml` to set `scan_intake_queues` to `every 1 minute` in development.
- [x] Step 2: Implement multi-tiered timestamp resolution in `ScanIntakeQueuesJob#file_age_timestamp`.
- [x] Step 3: Write specs verifying candidates are ordered chronologically by recording date.
- [x] Step 4: Verify test suite and fast validation pass cleanly.
<!-- SECTION:PLAN:END -->
