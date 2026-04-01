# DEC-002: Consolidate Scripts into unified Rakefile/CLI

**Status:** Accepted
**Date:** 2026-04-01

## Context
The project has over 20 independent Ruby and shell scripts in `bin/` with significant overlap in logic. This duplication leads to:
- High maintenance overhead.
- Inconsistent behavior across scripts.
- Redundant data loading and parsing during the build process.

## Decision
We will consolidate all scripts in `bin/` into a unified CLI tool (e.g., using `Rake` or a Ruby script).
- Common logic for YAML loading and text normalization will be moved to a shared library (`src/generators/core/`).
- The unified CLI will become the canonical way to run all build, generate, and validate tasks.

## Consequences
- Single entry point for all developer and CI operations.
- Better performance and cleaner code.
- Unified logging and error reporting.
