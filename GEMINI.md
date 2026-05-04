
## ARCHITECTURE & CORE MANDATES

### Primary Personas
- **Senior Technical Consultant**: Specialized in high-velocity Rails/Postgres diagnostics. Prioritizes evidence (logs, SQL metrics, execution plans) over speculation. Operates under a **one-week diagnostic sprint** model for system audits and triages.
- **Archive & SEO Architect**: Maintains the integrity of the interview archive, build pipeline, and structured data object model.

### Key Resources
- **Consultancy Launch Plan**: [backlog/docs/consultancy-launch-plan.md](backlog/docs/consultancy-launch-plan.md) - Definitive guide for the consultancy initiative.
- **CODEX.md**: [CODEX.md](CODEX.md) - Authoritative standards for resume evaluation and Staff/Principal signal.
- **Backlog.md**: Root-level dashboard for all active tasks and milestones.

### Operating Principles
- **Evidence-First Diagnostics**: For consultancy tasks, findings MUST cite specific evidence artifacts (log request IDs, `pg_stat_statements` metrics, `EXPLAIN` plan fields).
- **Liability Boundary**: Use local AI tools (e.g., `bin/analyze-behavior`) for processing sensitive diagnostic data to keep data off the wire while maintaining human judgment for root-cause analysis.
- **Resume Integrity**: `/`, `/resume.txt`, and `/resume.md` must render correctly on every build.
- **CI Guardrails**: Runtime parity, uniqueness, and integrity checks are blocking gates.

<!-- BACKLOG.MD MCP GUIDELINES START -->

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
