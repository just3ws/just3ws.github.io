---
id: TASK-291
title: Calibrate Software Craftsmanship Principles, SCMC 2-Year Transition, and Knowledge Graph Memory
status: Done
assignee:
  - '@antigravity'
created_date: '2026-10-16 10:00'
updated_date: '2026-10-16 11:40'
labels:
  - craftsmanship
  - knowledge-graph
  - editorial
dependencies:
  - TASK-290
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Eliminate remaining theatrical "crucible" terminology across prose, career datalake, and broadcast documentation in favor of grounded Software Craftsmanship principles (Kent Beck's Four Rules of Simple Design, Michael Feathers' legacy seams and characterization tests, Red-Green-Refactor / The Blink Test, and Apprenticeship -> Journeyman Practice -> Stewardship). Ensure all surfaces state the verified SCMC founding and transition timeline (co-founded by Mike Hall, Ryan Gerry, and Jim Suchy in 2010 at Follett Software Company, with Ryan Gerry continuing to run SCMC after Mike stepped away after the 2-year anniversary). Integrate persistent code and archive knowledge graphing (`graphify` + `_data/knowledge_graph.json`) and end-to-end validation guards across production and localhost builds.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Codify Software Craftsmanship engineering principles and graph-first memory workflow in GEMINI.md and AGENTS.md
- [x] #2 Replace remaining 'crucible' framing in 3-Act Career Narrative, blog posts, thumbnail generator, and rollout docs with Software Craftsmanship language
- [x] #3 Update Episode 05 dossier, teleprompter script, SCMC retrospective, community timeline, topic prompts, and editorial skills with verified SCMC co-founding (Mike Hall, Ryan Gerry, Jim Suchy) and 2-year anniversary transition
- [x] #4 Upgrade bin/generate_knowledge_graph.rb and _data/concepts.yml with all 38 Episode Dossiers, SCMC user group, and knowledge concepts with 0 orphan nodes
- [x] #5 Refresh graphify-out/graph.json, register in ~/.graphify/global-graph.json, install git hooks, and wire into ./bin/pipeline data graph
- [x] #6 Guard localhost_only navigation and command-palette links in production builds so ./bin/pipeline validate passes end-to-end
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [x] #1 All validation gates (validate:fast, validate:all, validate:obs, stage:all, verify_mcp_spec, rspec) pass with 0 errors
<!-- DOD:END -->
