# Workflow Guide

This document describes the core workflows for maintaining the site data, building the archive, and performing deployments.

## Site Architecture

The site is built with Jekyll but is primarily data-driven.
- **`_data/`**: Canonical YAML files for interviews, video assets, resumes, and taxonomy.
- **`bin/`**: Generator scripts that transform YAML data into Jekyll-readable HTML files.
- **`_site/`**: The rendered static site (historically committed to Git, but planned to be ignored in the modernization phase).

## Core Workflows

### 1. Updating Resume Content
Resume content is stored in `_data/resume/`.
- `timeline.yml`: Controls the order of positions.
- `positions/*.yml`: Contains detailed role descriptions.
- Changes to these files will automatically update the HTML, plain text, and Markdown resume formats.

### 2. Adding New Interviews
1. Add the interview metadata to `_data/interviews.yml`.
2. Add the video asset metadata to `_data/video_assets.yml`.
3. If a transcript is available, add it to `_data/transcripts/`.
4. Run `./bin/pipeline build` to generate the new pages.

### 3. Build & Deployment
The canonical entry point for all operations is `./bin/pipeline`.

```bash
# Full local CI build and validation
./bin/pipeline ci

# Run smoke tests
./bin/pipeline smoke
```

### 4. Data Validation
Data integrity is enforced by multiple scripts in the CI pipeline.
- `validate_data_integrity.rb`: Checks for required fields and cross-references.
- `validate_data_uniqueness.rb`: Ensures IDs and slugs are unique.
- `audit_transcripts.rb`: Checks for missing or malformed transcripts.

## Modernization Strategy

The project is currently transitioning to a more automated and robust architecture:
- Moving build/deploy to GitHub Actions.
- Using Jekyll memory-based generators instead of disk-based HTML generation.
- Consolidating fragmented scripts into a unified CLI.
