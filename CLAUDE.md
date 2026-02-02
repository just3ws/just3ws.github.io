# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Primary Directive

**Focus on structure and presentation only.** The user will handle all content changes separately.

The number one goal is an accessible and progressive adoption of clean standards with impeccable markup and style rules that comply with ATS best guidance for a parseable and machine-legible website.

### In Scope
- HTML structure and semantic markup
- CSS styling and print optimization
- Accessibility (WCAG compliance)
- ATS parsing optimization
- Schema.org structured data (JSON-LD)
- Template logic and data flow
- Build configuration and validation

### Out of Scope
- Resume content (descriptions, achievements, skills lists)
- Position details and dates
- Personal information changes

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
- `_data/resume/timeline.yml` - List of position references (controls display order)
- `_data/resume/positions/*.yml` - Individual YAML file per employer with role details
- `index.html` - Main resume template (uses minimal layout)
- `resume.txt` - Plain text version (auto-generated from YAML)

**Styling**: Minimal custom CSS in `assets/css/minimal.css`
- No framework dependencies
- Print-optimized with `@media print`
- ATS-friendly semantic structure

**Structured Data**:
- `_includes/json-ld.html` - Schema.org Person + Occupation data

**Key Configuration**:
- `_config.yml` - Jekyll config with plugins, excludes
- `.tool-versions` - Ruby 3.4.8 (for asdf/rtx)
- `CNAME` - Custom domain (www.just3ws.com)

**Build Output**: `_site/` (git-ignored, auto-generated)

## Position YAML Structure

```yaml
company:
  name: Company Name
  location: City, ST
title: Job Title
type: Full-time | Contract
start_date: Month YYYY
end_date: Month YYYY
context: >-
  Business context for the role (reference only, not displayed)
scope:
  scale: User/revenue scale
  ownership: What you owned
  influence: Cross-functional reach
description: >-
  Role summary (displayed on site)
achievements:
  highlights:
    - Achievement bullet points
skills:
  - Skill 1
  - Skill 2
```

## Validation Standards

- HTML: Valid HTML5, semantic elements, proper heading hierarchy
- Accessibility: WCAG 2.1 AA compliance, skip links, focus states
- ATS: Parseable text, Schema.org markup, plain text fallback
- Print: Clean PDF output via browser print
