# Contributing to Mike Hall's Archive & Resume Project

Thank you for contributing! This document outlines the standards and workflows for maintaining the repository.

## Core Directives

- **Structure over Content**: Focus on structural, presentation, and data integrity improvements. Content changes (resume text, personal details) are typically handled separately by the owner.
- **Data-Driven Architecture**: Most pages are generated from YAML data in `_data/`. Avoid manual edits to HTML files in `interviews/` or `videos/` as they are overwritten by generators.
- **Impeccable Standards**: Maintain clean markup, WCAG-compliant accessibility, and ATS-friendly semantic structures.

## Development Workflow

### 1. Setup
```bash
# Install Ruby dependencies
bundle install

# Install Node dependencies (for Playwright smoke tests)
npm install
```

### 2. Local Development
```bash
# Run local Jekyll server
./bin/server
```

### 3. Build & Validate
Before submitting changes, ensure the full pipeline passes:
```bash
# Run build, unit tests, and validation
./bin/pipeline ci

# Run browser smoke checks
./bin/pipeline smoke
```

## Pull Request Expectations

- **Atomic Commits**: Keep changes focused and well-described.
- **Validated Output**: Every PR must include the updated `_site/` output (until the modernization phase to move this to CI is complete).
- **Test Coverage**: Add or update RSpec tests in `spec/` for any changes to generator logic or template filters.
- **Repository Hygiene**: Follow the [Repository Hygiene Policy](backlog/docs/repo-hygiene.md). Declare any new top-level files in `_data/repo_hygiene.yml`.

## Task Management (Backlog.md)

This project uses a local `Backlog.md` file for task tracking.
- **Search First**: Before creating a task, search for duplicates.
- **Lifecycle**: Follow the standard Draft -> To Do -> In Progress -> Done workflow.
- **Documentation**: Use the `backlog://workflow/overview` MCP resource for detailed guidance.

## Standards & Tools

- **Static Site Generator**: Jekyll 4.x
- **CSS**: Minimal custom SCSS in `_sass/`, compiled to `assets/css/site.css`.
- **Validation**:
  - `htmlproofer` for link and structure checks.
  - `Playwright` for browser smoke tests.
  - Custom Ruby validators for data integrity.
- **Optimization**: Use `svgo` for vector assets and the `image_optim` plugin for raster images.

## Architectural Decisions

Major changes to the system architecture should be documented via an ADR (Architecture Decision Record) in `docs/adr/`.
