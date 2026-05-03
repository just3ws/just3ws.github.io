# Domain Docs

This repo uses a **single-context** layout for domain knowledge and architectural decisions.

## Locations

- **Domain Language**: `backlog/docs/`
  - Skills like `improve-codebase-architecture` and `diagnose` should prioritize files in this directory to understand the project's purpose and terminology.
- **Architectural Decisions (ADR)**: `backlog/decisions/`
  - Skills should read these to understand past technical choices and constraints.

## Consumer Rules
1. **Read-only**: Skills should read these files to gain context.
2. **Updates**: If a skill (like `to-prd`) crystallizes a new decision, it should suggest updating or creating a new ADR in `backlog/decisions/` via the `backlog.document_create` tool.
