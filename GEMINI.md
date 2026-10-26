# GEMINI.md: Gemini CLI & Antigravity Project Guidance

<!-- COLD-START RESUME STATE lives in the CURRENT FOCUS block at the top of
     >>> AGENTS.md <<< (read it first. Closing a session = rewrite that
     block in AGENTS.md, then commit). -->

## Required Project Context

Before changing this repository:
1. Read `AGENTS.md` for master agent skills, workflow roles, and registered tools.
2. Read `CONTEXT.md` for public-canon, local-runtime, and publication contracts.
3. Read `CODEX.md` before evaluating or changing resume content, positioning, titles, or generated resume surfaces.
4. Read `docs/career-strategy-audhd-principal-engineering.md` for title-to-scale role calibration and interview positioning strategies.
5. Read `docs/style-guide-and-canonical-naming.md` for permanent canonical naming, casing, and compound word standards across all content, data, and transcripts.
6. Read `.agents/skills/ponytail/SKILL.md` for the Ponytail Principle against premature technical debt.

Do not treat this repository as an isolated Jekyll checkout. Its installed localhost site is part of Mike's local system and is a required verification surface for user-facing changes.

### Non-Negotiable Canonical Entity Naming & Ecosystem Ground Truth

- **SCMC** is strictly **Software Craftsmanship McHenry County**. It is NEVER "Software Craftsmanship Movement", "Software Craftsmanship Meetup", "Software Craftsmanship Midwest", "Supply Chain Management", or anything else. Mike Hall co-founded SCMC in late 2009 with Ryan Gerry and Jim Suchy (following the October 2009 SCNA table meeting with Ryan Gerry that launched CDG in McHenry County libraries, Panera Bread, and Duke's Alehouse), hosted at Follett Software Company in McHenry, IL.

---

## The Ponytail Principle: Reducing Premature Technical Debt

Premature abstraction is the most expensive technical debt because you pay the maintenance, testing, and cognitive taxes on code that serves zero real callers.

Before introducing a new abstraction, climb the 4-rung ladder from the ground up and stop at the lowest rung that satisfies the requirement:

1. **Rung 1: Omission (YAGNI)**: If a capability is speculative or unrequested, zero lines of code carry zero bugs and zero maintenance overhead.
2. **Rung 2: Inlining (Constants Over Config)**: Hardcode sane defaults directly in place. Do not create a dynamic YAML config or database table for static values.
3. **Rung 3: Standard Library & Procedural Simplicity**: Use language built-ins and standard libraries before reaching for heavy external frameworks or event loops.
4. **Rung 4: Annotated Seam (`# ponytail: <rationale>`)**: When taking a deliberate, pragmatic shortcut, mark it explicitly. Format:
   ```ruby
   # ponytail: <what was simplified>: <why it is sufficient for single-operator local platform>;
   # upgrade trigger: <condition that justifies building full abstraction>.
   ```

Running `git grep -n "ponytail:"` must always yield a living inventory of every conscious trade-off and deliberate shortcut across the repository.

---

## Tool Namespacing, Modularity & Pruning Taxonomy

To maintain sanity, modularity, and cohesive structure across `bin/`:

1. **Unified Pipeline Driver (`bin/pipeline`)**:
   All core operational capabilities are routed through `bin/pipeline <domain> <action>`.

   - **`media`**: Video intake, streaming telemetry, swiftbar monitor, staging harness, patreon, episode workbench, youtube publishing (`intake`, `stream`, `swiftbar`, `stage`, `patreon`, `episode`, `youtube`, `status`).
   - **`validate`**: Repository hygiene, test assertions, and site gates (`fast`, `obs`, `all`, `site`, `links`).
   - **`data`**: Page generation, graph synthesis, semantic audits, and sitemaps (`generate`, `graph`, `semantic-graph`, `semantic-audit`, `semantic-snapshot`, `sitemap`).
   - **`site`**: Jekyll builds, test runners, local verification, and deployment (`build`, `test`, `ci`, `verify`, `smoke`, `resumes`, `install`).

2. **Backward Compatibility**:
   Legacy flat subcommands (such as `bin/pipeline intake`, `bin/pipeline stream`, `bin/pipeline swiftbar`, `bin/pipeline stage`) remain fully supported as direct aliases to their namespaced counterparts.

3. **Pruning & Consolidation Rules**:
   - Before authoring a new standalone script in `bin/`, check whether the capability belongs inside an existing domain tool (e.g., `bin/youtube_pipeline.rb`, `bin/intake_drive_video.rb`, or a Rake task).
   - Loose single-use scripts must be consolidated into their parent domain namespace or pruned once their migration cycle completes.
   - Maintain 100% em-dash-free compliance across all code, configuration, and documentation.

---

## Software Craftsmanship Engineering Principles

All planning, evaluation, design decisions, and narrative framing in this repository follow core **Software Craftsmanship** principles:

1. **Kent Beck's Four Rules of Simple Design** (in priority order):
   - **Passes the tests**: Behavior is verified by deterministic, fast-running automated tests and validators (`./bin/pipeline validate fast`, `bundle exec rspec`).
   - **Reveals intention**: Names of files, classes, methods, and YAML keys state their exact domain responsibility in plain practitioner language without theatrical metaphors (avoid words like "crucible", "prison break", or "insurgent").
   - **No duplication of authoritative knowledge**: Canonical facts (career dates, SCMC founding history, episode manifests, taxonomy) live in structured `_data/` sources and propagate deterministically.
   - **Fewest elements**: Governed by the Ponytail Principle above; remove speculative indirection.
2. **Michael Feathers' Legacy Seams & Characterization Tests**:
   - Before modifying complex generators, pipelines, or external integrations, identify clean seams and pin existing behavior with characterization tests so refactors preserve working contracts.
3. **Red-Green-Refactor & The Blink Test**:
   - A claim of "fixed" or "verified" requires observing the test or validator fail when the contract is broken and pass when the change is applied.
4. **Apprenticeship, Journeyman Practice & Stewardship**:
   - Frame career and community narratives around practical engineering autonomy, deliberate practice, mentorship, and long-term stewardship (Foundation & Apprenticeship -> Journeyman Practice & Architecture -> Calm Systems Leadership & Stewardship).

---

## Code Mapping, Knowledge Graph & Context Retention

To retain architectural and historical context across sessions and avoid blind, repetitive `grep` searches:

1. **Query the Code & Knowledge Graphs First**:
   - **Code & Architecture Graph (`graphify`)**: Query `graphify-out/graph.json` (9,600+ AST and doc nodes, also registered in `~/.graphify/global-graph.json` as `just3ws`) before scanning raw files:
     ```bash
     graphify query "<topic or symbol>" --graph graphify-out/graph.json --budget 800
     graphify explain "<node>" --graph graphify-out/graph.json
     graphify path "<source>" "<target>" --graph graphify-out/graph.json
     ```
   - **Archive & Concept Knowledge Graph (`_data/knowledge_graph.json`)**: Inspect curated entity relationships (interviews, interviewees, episodes, concepts, user groups, conferences, and articles) via `bin/pi-ctx-just3ws` or `_data/knowledge_graph.json`.
   - **CareerOS Datalake (`bin/query_career_datalake.rb`)**: Query across 218 full-text transcripts, 28 positions, and 185 writings via `ruby bin/query_career_datalake.rb -s "<query>"`.
2. **Keep Graphs Synchronized**:
   - Run `./bin/pipeline data graph` (`bundle exec rake knowledge_graph`) to regenerate `_data/knowledge_graph.json`, verify zero orphans/duplicates via `bin/audit_knowledge_graph.rb`, and incrementally update `graphify-out/graph.json` + `~/.graphify/global-graph.json`.
   - `.githooks/post-commit` and `.githooks/post-checkout` automatically keep `graphify-out/graph.json` current on every commit.

---

<!-- BACKLOG.MD MCP GUIDELINES START -->

<CRITICAL_SAFETY_ADVISORY>

## DESTRUCTIVE OPERATIONS SAFETY

**INCIDENT RECORD (2026-05-25):** A recursive deletion of the home directory was triggered due to an unresolved path variable.

**MANDATORY SAFETY CHECKS:**
- **Variable Validation:** Before any `rm -rf` or similar destructive command, EXPLICITLY verify that all variables are non-empty and resolve to paths strictly within the intended workspace.
- **Path Anchoring:** Always anchor paths to the project root or a known-safe subdirectory.
- **Library Preference:** Prefer language-native file utilities (e.g., Ruby's `FileUtils.rm_rf`) over shell commands when possible, as they provide better inherent safety for empty path arguments.

</CRITICAL_SAFETY_ADVISORY>

<CRITICAL_INSTRUCTION>

## BACKLOG WORKFLOW INSTRUCTIONS

This project uses Backlog.md MCP for all task and project management activities.

**CRITICAL GUIDANCE**

- If your client supports MCP resources, read `backlog://workflow/overview` to understand when and how to use Backlog for this project.
- If your client only supports tools or the above request fails, call `backlog.get_backlog_instructions()` to load the tool-oriented overview. Use the `instruction` selector when you need `task-creation`, `task-execution`, or `task-finalization`.

- **First time working here?** Read the overview resource IMMEDIATELY to learn the workflow
- **Already familiar?** You should have the overview cached ("## Backlog.md Overview (MCP)")
- **When to read it**: BEFORE creating tasks, or when you're unsure whether to track work

These guides cover:
- Decision framework for when to create tasks
- Search-first workflow to avoid duplicates
- Links to detailed guides for task creation, execution, and finalization
- MCP tools reference

You MUST read the overview resource to understand the complete workflow. The information is NOT summarized here.

</CRITICAL_INSTRUCTION>

<!-- BACKLOG.MD MCP GUIDELINES END -->
