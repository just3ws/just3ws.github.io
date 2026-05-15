---
id: TASK-126
title: Verify and Ingest SCMC and Archive Transcripts
status: To Do
assignee: []
created_date: '2026-05-15 01:58'
labels: []
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
We recently enqueued the remaining non-UGtastic videos (SCMC and Archive collections) into the `zdots-ctx` background worker. 

Once the worker completes them, we need to ingest them into the repository and ensure their metadata is properly formatted. Because these are often single-speaker presentations rather than conversational interviews, they may require a slightly different audit prompt or manual review.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Confirm the 8 SCMC and Archive videos enqueued in the previous wave completed successfully
- [ ] #2 Stage and ingest the resulting transcripts using `./bin/transcripts ingest`
- [ ] #3 Run the `transcript-conversational-audit` on them if appropriate, or manually format them if they are presentations rather than interviews
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->
