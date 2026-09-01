---
id: TASK-271
title: Automated deployment progress monitor with learned metrics and ETA estimation
status: Done
assignee: []
created_date: '2026-09-01 16:05'
updated_date: '2026-09-01 16:06'
labels:
  - tooling
  - ci-cd
  - deployment
  - observability
milestone: Core Tooling & Developer Experience
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Create an automated deployment monitoring utility (`bin/monitor_deployment.rb`) that hooks into GitHub Actions deployment workflows, tracks live step progression, maintains an adaptive database of historical step durations, and calculates accurate real-time ETAs and progress updates during production releases.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Implement CLI utility `bin/monitor_deployment.rb` capable of monitoring a specific GitHub Actions run ID or auto-detecting the latest push run on `master`.
- [x] #2 Stream and parse structured step transitions (`checkout`, `setup-ruby`, `Run CI gate`, `html-proofer`, `Upload Pages artifact`, `Deploy to GitHub Pages`).
- [x] #3 Maintain a persistent rolling history of step durations in `tmp/deployment_metrics.json` to learn mean runtimes and standard deviations across steps.
- [x] #4 Output real-time terminal progress indicators with dynamic remaining time estimates (ETA) updated as each step executes.
- [x] #5 Implement post-deployment HTTP health verification against production endpoints (`https://www.just3ws.com/`) verifying HTTP/2 200 response and cache headers.
- [x] #6 Integrate with `bin/deploy` or Rake task (`bundle exec rake deploy:monitor`) for seamless single-command release and verification.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [x] #1 `bin/monitor_deployment.rb` passes execution tests and handles in-progress, failed, and completed GitHub Actions runs gracefully.
- [x] #2 Accurate ETA calculation verified against historical benchmark timings (~7.5m total deployment duration).
- [x] #3 Documentation and usage guidelines added to `docs/tooling-user-guide.md`.
<!-- DOD:END -->
