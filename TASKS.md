# Resume Site Modernization Tasks

Track progress on upgrading the site to current HTML/CSS A11y standards and ATS compliance.

---

## Phase 1: Critical A11y & HTML Fixes

### 1.1 Fix Icon Link Accessibility
- [ ] Add `aria-label` to email icon link (`_includes/resume/header.html.liquid:10`)
- [ ] Add `aria-label` to phone icon link (`_includes/resume/header.html.liquid:13`)
- [ ] Add `aria-label` to all social media icon links in header
- [ ] Add `aria-hidden="true"` to decorative FontAwesome icons

### 1.2 Fix Placeholder Links
- [ ] Replace `href="#"` with actual `mailto:` link for email
- [ ] Replace `href="#"` with actual `tel:` link for phone
- [ ] Verify all links have proper destinations

### 1.3 Fix Heading Hierarchy
- [ ] Audit current heading structure (h1 → h2 → h3 → h4)
- [ ] Ensure single `<h1>` (name) at top
- [ ] Section titles should be `<h2>` (Experience, Skills, Education)
- [ ] Subsections should be `<h3>` (individual jobs, skill categories)
- [ ] Fix footer `<h3>` to appropriate level or remove

### 1.4 Fix Invalid HTML Structure
- [ ] Fix `<dl>` misuse in `_includes/resume/history.html.liquid:2`
- [ ] Fix orphaned `<dd>` in `_includes/resume/recommendations.html.liquid:4`
- [ ] Remove invalid `alt` attribute from `<a>` tags in footer (`_includes/resume/footer.html.liquid:3,5`)
- [ ] Run `bundle exec rake htmlproofer` to verify fixes

### 1.5 Add Navigation Landmarks
- [ ] Add skip link to main content at top of page
- [ ] Add `role="main"` or `<main>` element wrapper
- [ ] Add `role="navigation"` to any nav sections
- [ ] Add `role="contentinfo"` to footer or use `<footer>` semantically

### 1.6 Keyboard Navigation
- [ ] Add visible focus styles (`:focus-visible`) in SCSS
- [ ] Ensure all interactive elements are keyboard accessible
- [ ] Test tab order flows logically

---

## Phase 2: ATS Compliance

### 2.1 Simplify HTML for ATS Parsing
- [ ] Ensure job titles are in `<h3>` or similar parseable tags
- [ ] Ensure company names are clearly labeled
- [ ] Ensure dates are in consistent, parseable format
- [ ] Remove or provide text alternatives for progress bar skills

### 2.2 Create Plain Text Resume
- [ ] Create `resume.txt` with clean text formatting
- [ ] Add link to plain text version in footer
- [ ] Consider auto-generating from YAML data

### 2.3 Improve Structured Data
- [ ] Audit existing JSON-LD in `_includes/json-ld.html`
- [ ] Add `JobPosting` schema for positions
- [ ] Enhance `Person` schema with `hasOccupation` properties
- [ ] Add `knowsAbout` for skills/technologies
- [ ] Validate with Google Rich Results Test

### 2.4 PDF Export Option
- [ ] Research Jekyll PDF generation options
- [ ] Create print-friendly CSS (`@media print`)
- [ ] Add "Download PDF" link to header/footer

---

## Phase 3: Theme Modernization

### 3.1 Bootstrap Upgrade (4 → 5)
- [ ] Review Bootstrap 5 migration guide
- [ ] Update `assets/scss/bootstrap/` vendor files
- [ ] Fix breaking changes (jQuery removal, class renames)
- [ ] Update utility classes (`ml-*` → `ms-*`, `mr-*` → `me-*`, etc.)
- [ ] Test responsive behavior

### 3.2 Color Contrast & WCAG Compliance
- [ ] Audit primary color `#22A162` against backgrounds
- [ ] Check text colors meet WCAG AA (4.5:1 for normal text)
- [ ] Check link colors meet WCAG AA
- [ ] Document color palette with contrast ratios
- [ ] Fix any failing contrasts in SCSS variables

### 3.3 Modern CSS Improvements
- [ ] Add CSS custom properties (variables) for theming
- [ ] Implement `prefers-reduced-motion` media query
- [ ] Implement `prefers-color-scheme` for dark mode (optional)
- [ ] Add `font-display: swap` for web fonts
- [ ] Optimize critical CSS path

### 3.4 Visual Refresh (Optional)
- [ ] Evaluate keeping Pillar theme vs. new theme
- [ ] If new theme: select modern, minimal, ATS-friendly design
- [ ] Preserve YAML data structure compatibility
- [ ] Maintain 6 color variant system or simplify

---

## Phase 4: Staff+ Content Strategy

### 4.1 Achievement Restructuring
- [ ] Audit each position for impact-first language
- [ ] Add quantified results where possible (%, $, scale)
- [ ] Lead bullets with action verbs + business outcome
- [ ] Remove generic responsibility descriptions

### 4.2 Add Scope Indicators
- [ ] Add team size to leadership roles
- [ ] Add user/revenue scale where applicable
- [ ] Highlight cross-functional influence
- [ ] Note architectural decisions and their impact

### 4.3 Technical Leadership Highlights
- [ ] Add "Architecture & Technical Leadership" section or integrate
- [ ] Highlight mentorship and team growth
- [ ] Document technical strategy contributions
- [ ] Add speaking/writing/open source if applicable

### 4.4 Content Review
- [ ] Review all 24 positions in `_data/resume/positions/`
- [ ] Prioritize recent/relevant roles with detailed achievements
- [ ] Consider condensing older roles (pre-2015)
- [ ] Ensure consistent voice and formatting

---

## Validation Checklist

Run these after each phase:

```bash
# Build and validate HTML
./bin/cibuild

# HTML validation only
bundle exec rake htmlproofer

# Manual checks
# - Screen reader testing (VoiceOver, NVDA)
# - Keyboard-only navigation
# - ATS parser test (JobScan, ResumeWorded)
# - WAVE browser extension for A11y
# - Lighthouse audit in Chrome DevTools
```

---

## Files Reference

Key files to modify:

| File | Purpose |
|------|---------|
| `_includes/resume/header.html.liquid` | Header with contact links |
| `_includes/resume/footer.html.liquid` | Footer with invalid `alt` attrs |
| `_includes/resume/timeline/item.html.liquid` | Job entry template |
| `_includes/resume/skills-tools-item-percentile.html.liquid` | Progress bar skills |
| `_includes/resume/recommendations.html.liquid` | Invalid `<dl>` structure |
| `_includes/resume/history.html.liquid` | Invalid `<dl>` structure |
| `_layouts/default.html` | Main layout, landmarks |
| `assets/scss/pillar-*.scss` | Theme styles (6 variants) |
| `_data/resume/positions/*.yml` | Position content (24 files) |

---

## Progress

| Phase | Status | Started | Completed |
|-------|--------|---------|-----------|
| Phase 1: A11y & HTML | Not Started | | |
| Phase 2: ATS Compliance | Not Started | | |
| Phase 3: Theme Modernization | Not Started | | |
| Phase 4: Staff+ Content | Not Started | | |
