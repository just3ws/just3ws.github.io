# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Personal resume/portfolio website for Mike Hall (just3ws.com). Built with Jekyll and deployed via GitHub Pages.

## Commands

```bash
# Install dependencies
bundle install

# Run local development server (includes draft posts)
./bin/server

# Build and validate (CI pipeline)
./bin/cibuild

# Run HTML validation only
bundle exec rake htmlproofer
```

## Architecture

**Static Site Generator**: Jekyll 3.x via the `github-pages` gem

**Resume Data Structure**:
- `_data/resume/timeline.yml` - List of position references
- `_data/resume/positions/*.yml` - Individual YAML file per employer with role details
- `_includes/resume/` - Liquid templates that render resume sections

**Styling**: Bootstrap-based Pillar theme with 6 color variants in `assets/scss/pillar-*.scss`

**Key Configuration**:
- `_config.yml` - Jekyll config with 12 plugins, HTML/CSS compression settings
- `.tool-versions` - Ruby 3.4.8 (for asdf/rtx)
- `CNAME` - Custom domain (www.just3ws.com)

**Build Output**: `_site/` (git-ignored, auto-generated)
