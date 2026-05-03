# Issue Tracker: Backlog.md MCP

This project uses the **Backlog.md MCP service** for all task and project management.

## Workflow

### 1. Discovery
Before creating new work, search the backlog:
- `rtk backlog.task_search --query "your search"`
- `rtk backlog.task_list`

### 2. Creation
When work requires planning or decision-making (see `CLAUDE.md` guidelines), create a task:
- `rtk backlog.task_create --title "..." --description "..."`
- By default, new tasks are created with `status: "Draft"` for triage.

### 3. Execution
To work on a task:
- Move it to `In Progress`: `rtk backlog.task_edit --id "TASK-ID" --status "In Progress"`
- Use `task_edit` to update `implementationNotes` and `acceptanceCriteria`.

### 4. Finalization
When complete:
- Mark as `Done`: `rtk backlog.task_edit --id "TASK-ID" --status "Done"`
- Periodically move batch of `Done` tasks to the completed folder using `task_complete`.

## Tool Reference
Always use the `backlog.*` prefix for MCP tools. Never edit `Backlog.md` or files in `backlog/tasks/` directly.
