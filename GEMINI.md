
<!-- BACKLOG.MD MCP GUIDELINES END -->

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
