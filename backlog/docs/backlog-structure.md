---
id: doc-009
title: Backlog Structure Overview
type: other
created_date: '2026-04-01 15:29'
---

# Backlog Structure Overview

This project uses a structured backlog system located in the `backlog/` directory, with a central dashboard at `Backlog.md` in the root.

## Directory Structure

- **`backlog/tasks/`**: Individual task files. Each task is a Markdown file describing the goal, status, priority, and acceptance criteria.
- **`backlog/decisions/`**: Architectural Decision Records (ADRs). These document "why" a significant architectural change was made.
- **`backlog/docs/`**: Technical and operational documentation. All documentation from the legacy `docs/` folder has been consolidated here.
- **`backlog/completed/`**: Historical task files that have been finished.
- **`backlog/archive/`**: Outdated or superseded documentation and tasks.

## Working with Tasks

1. **Discovery:** Before starting work, check the `Backlog.md` and `backlog/tasks/` for existing items.
2. **Creation:** New tasks should be created as Markdown files in `backlog/tasks/`.
3. **Execution:** Update the status of the task as work progresses.
4. **Finalization:** When a task is complete, move the file to `backlog/completed/` and update the `Backlog.md` summary.

## Working with Decisions

All significant architectural changes must be preceded by an ADR in `backlog/decisions/`. This ensures that the rationale for changes is preserved for future maintainers.

