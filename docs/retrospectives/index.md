---
layout: minimal
title: Retrospective Protocol
description: Standard retrospective format for what worked, what did not, and process improvements.
breadcrumb: Retrospectives
breadcrumb_parent_name: Docs
breadcrumb_parent_url: /docs/
---

{% include breadcrumbs.html %}

# Retrospective Protocol

Use this format after each meaningful implementation cycle. Keep it concise, evidence-based, and action-oriented.

## Required Sections

1. What Worked
- Concrete behaviors or decisions that improved outcomes.
- Include evidence: CI run IDs, validator results, timings, or commit references.

2. What Did Not Work
- Concrete issues, failures, or friction points.
- Include impact and trigger conditions.

3. What Went Well
- Positive execution patterns worth repeating.
- Distinct from "what worked" by focusing on team/process quality.

4. What Could Be Better
- Gaps where outcomes were acceptable but not optimal.
- Include why improvement matters.

5. Process Improvements
- List only actionable items.
- Each item must include:
  - owner
  - expected outcome
  - due checkpoint (date or next milestone)
  - validation method

6. Follow-up Review (next retrospective)
- For each prior improvement item, mark:
  - status: upheld, improved, maintained, regressed, or dropped
  - evidence
  - adjustment (if needed)

## Retrospective Template

```md
## Retrospective (YYYY-MM-DD)

### Context
- Scope:
- Time window:
- Relevant commits:
- CI runs:

### What Worked
- [ ] item + evidence

### What Did Not Work
- [ ] item + impact + trigger

### What Went Well
- [ ] item

### What Could Be Better
- [ ] item + why

### Process Improvements
1. Improvement:
   - Owner:
   - Expected outcome:
   - Due checkpoint:
   - Validation method:

### Prior Improvement Follow-up
1. Improvement:
   - Status:
   - Evidence:
   - Adjustment:
```

## Quality Bar

- Do not include generic statements without evidence.
- Keep process improvements small and testable.
- Keep retrospective updates in the same commit series as behavior/policy changes when possible.
