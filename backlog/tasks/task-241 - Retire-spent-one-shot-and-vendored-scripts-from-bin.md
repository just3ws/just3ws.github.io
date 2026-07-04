---
id: TASK-241
title: Retire spent one-shot and vendored scripts from bin/
status: Done
assignee: []
created_date: '2026-07-04 03:23'
updated_date: '2026-07-04 14:53'
labels:
  - pipeline
  - cleanup
milestone: Interview Archive Pipeline
dependencies: []
priority: low
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Remove spent one-shot repair/split scripts (repair_dave_thomas{,_2015}, manual_split_dave, split_erik{,_advanced}, restructure_{dean_wampler,erik_meijer}, fix_gary_flip — ~494 lines, each named after a single person/event with the fix already baked into the data) and the zdots platform CLI vendored into this repo (bin/zdots-brain-{local,debug}, ~818 lines, hard-coding /Users/mike absolute requires — belongs in the zdots repo, not the site). Resolve the three stale Rakefile tasks pointing at missing scripts (generate_interview_pages, generate_video_asset_pages, generate_interview_taxonomy_pages). Foundation cleanup from the ponytail audit; unblocks a clean base for the rest of the pipeline.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 The 8 named one-shot scripts are removed from bin/
- [x] #2 bin/zdots-brain-local and bin/zdots-brain-debug are removed (or relocated to the zdots repo)
- [x] #3 The three stale Rakefile tasks are removed or repaired to point at real scripts
- [x] #4 rake build and the test suite are green after removal
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## TASK-241 Implementation Plan — retire spent one-shot + vendored scripts

### Verified deletion set
`git grep` on each basename found NO references outside the file's own body and `backlog/` docs (`_site/` is git-ignored build output). Safe to delete.

**One-shot repair/split scripts (8) — `git rm`:**
- bin/repair_dave_thomas.rb
- bin/repair_dave_thomas_2015.rb
- bin/manual_split_dave.rb
- bin/split_erik.rb
- bin/split_erik_advanced.rb
- bin/restructure_dean_wampler.rb
- bin/restructure_erik_meijer.rb
- bin/fix_gary_flip.rb

**Vendored zdots CLI (2) — `git rm`:** zero references anywhere in repo; both hard-code `require_relative "/Users/mike/.config/zsh/lib/zdots/..."` (belongs in the zdots repo, not the site):
- bin/zdots-brain-local
- bin/zdots-brain-debug

### Rakefile changes (single file: /Users/mike/github.com/just3ws/just3ws.github.io/Rakefile)
Confirmed on disk: `generate_interview_pages.rb`, `generate_video_asset_pages.rb`, `generate_interview_taxonomy_pages.rb` are all MISSING (replaced by the InterviewGenerator / VideoAssetGenerator / TaxonomyGenerator Jekyll plugins).
- Remove the three orphan task definitions at lines 62-72: `task :interview_pages`, `task :video_pages`, `task :taxonomy` (each `sh`'s a missing script).
- Remove the three commented-out references in the `generate:all` array at lines 37-39 (`# :interview_pages`, `# :video_pages`, `# :taxonomy`).

### Order
1. `git rm` the 10 files (one command).
2. Edit Rakefile: delete task blocks (62-72) and the 3 comment lines (37-39); leave all surrounding tasks untouched.
3. `bundle exec rake build` (runs generate:all + jekyll build) then `bundle exec rspec`.
4. `rake -T` sanity check — no dangling task references remain.

### Commands
```
git rm bin/repair_dave_thomas.rb bin/repair_dave_thomas_2015.rb bin/manual_split_dave.rb \
  bin/split_erik.rb bin/split_erik_advanced.rb bin/restructure_dean_wampler.rb \
  bin/restructure_erik_meijer.rb bin/fix_gary_flip.rb bin/zdots-brain-local bin/zdots-brain-debug
# then edit Rakefile (lines 37-39 comments + 62-72 task defs)
bundle exec rake build && bundle exec rspec
```

### Surprises / risks (low)
- The three stale rake tasks are ALREADY commented out of `generate:all` (lines 37-39), so the task definitions at 62-72 are pure dead code never invoked by any pipeline — removal is zero functional risk.
- OVERLAP WITH TASK-242 (DAG-ordering note): `repair_dave_thomas.rb`, `restructure_dean_wampler.rb`, `restructure_erik_meijer.rb` also contain direct `http://127.0.0.1:8080/v1` LLM calls, so they surface in TASK-242's `git grep "8080/v1"` sweep. They are DELETED here, not routed. Sequence: run/scope 241 first (or independently) so 242 does not attempt to route files that are about to be removed. 242's own target list does not include these three.
- No docs reference any of the 10 deleted files (verified — docs only mention `forensic_restructure` and `bin/archive/pipeline.rb`, which are NOT in this deletion set). No doc edits needed.

### Verify (AC #4)
- `bundle exec rake build` green and `bundle exec rspec` green after removal.
- `git grep` for each deleted basename returns nothing outside `backlog/`.
- `rake -T` lists tasks with no reference to the removed generators.
<!-- SECTION:PLAN:END -->

## Comments

<!-- COMMENTS:BEGIN -->
author: claude
created: 2026-07-04 14:47
---
Executed: `git rm` on all 10 files (8 one-shots + 2 vendored zdots CLIs), removed Rakefile lines 37-39 (commented generate:all refs) and the three orphan task defs (interview_pages/video_pages/taxonomy). Verified: `rake -T` has no dangling refs, `rake build` green, `rspec` 53 examples / 0 failures. Changes are STAGED/working-tree only — NOT committed, awaiting review before commit.
---

author: claude
created: 2026-07-04 14:53
---
Committed to master as 8b922e9 (not pushed). Working tree clean; build + tests green. Done.
---
<!-- COMMENTS:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [x] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->
