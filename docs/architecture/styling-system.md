---
layout: minimal
title: Styling System
description: Shared style core with separate resume and site themes.
breadcrumb: Styling System
breadcrumb_parent_name: Docs
breadcrumb_parent_url: /docs/
---

{% include breadcrumbs.html %}

# Styling System

The styling model is split into:

- `assets/css/core.css` shared baseline tokens and reset.
- `assets/css/themes/resume.css` resume-focused theme.
- `assets/css/themes/site.css` archive/site-focused theme.

## Layout-to-Theme Mapping

- `_layouts/resume.html` loads `core.css` + `themes/resume.css`
- `_layouts/minimal.html` loads `core.css` + `themes/site.css`

## Compatibility Paths

Wrapper files exist for compatibility with legacy references:

- `assets/css/resume.css`
- `assets/css/site.css`

These wrappers import the new core + themed files.

## Design Intent

- Resume pages remain visually stable and conservative.
- Non-resume pages can evolve navigation and component styling without destabilizing resume output.
