# Triage Labels

The `triage` skill moves issues through a state machine. This repo maps the five canonical triage roles to **Backlog.md MCP** statuses and labels.

## Canonical Role Mapping

| Role | Backlog.md Mapping | Notes |
| :--- | :--- | :--- |
| `needs-triage` | `status: "Draft"` | Default state for new tasks |
| `needs-info` | `status: "To Do"` + `status:blocked` | Label used for clarification |
| `ready-for-agent` | `status: "To Do"` | Fully specified, AFK-ready |
| `ready-for-human` | `status: "To Do"` + `human-required` | Needs human implementation |
| `wontfix` | `task_archive` | Removed from active backlog |

## Common Labels
- `type:bug` - Defect in existing functionality
- `type:feature` - New capability
- `priority:high` - Blocking or critical path
- `priority:medium` - Standard priority
- `priority:low` - Nice-to-have or optimization
