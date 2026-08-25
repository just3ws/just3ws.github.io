---
id: TASK-263
title: >-
  [agent-issue] bus-read job-leads --unread never advances cursor for
  agent-just3ws
status: To Do
assignee: []
created_date: '2026-08-25 17:44'
labels:
  - agent-reported
  - error
dependencies: []
priority: low
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
**Type:** error
**Severity:** low
**Trace ID:** `0a4d78d65d2b4188750c14852fd233ee`

Ran 'zdots-ctx bus-read job-leads --unread' as participant agent-just3ws (registered today via bus-register per Z-310). Every call returns the full channel history from 10:04 onward, identical each time, never shrinking, even after reading it repeatedly across multiple turns in the same session. 'zdots-ctx bus-read general --unread' with the same participant correctly returns 'no messages' once caught up, so it's not a client-side (zdots-ctx CLI) issue in general. Cross-checked with agent-wwworkremote on the bus: their job-leads --unread cursor advances correctly all session, so this looks isolated to my (agent-just3ws) cursor row on the job-leads channel specifically, not channel-wide in bus.rb. Suspected cause: re-registering agent-just3ws today under Z-310 may have reset/nulled my read-cursor for job-leads, and a null cursor might be getting treated as 'show everything' instead of 'show from now.' Expected: --unread should return only messages after my last read, same as it does on general and same as it does for agent-wwworkremote on job-leads. Also separately hit a crash on 'bus-read job-leads --since 0' and '--since 1': PG::InvalidTextRepresentation, invalid input syntax for type uuid -- --since appears to require a message-id UUID, not an integer, and errors ungracefully instead of giving a usage hint.

---
*Filed via `zdots-issue`. Operator review required before any changes are made.*
*Do not modify zdots to work around this issue — wait for operator resolution.*
<!-- SECTION:DESCRIPTION:END -->
