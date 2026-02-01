# Resume Site Modernization Tasks

Track progress on upgrading the site to current HTML/CSS A11y standards and ATS compliance.

---

## Phase 1: Critical A11y & HTML Fixes

### 1.1 Fix Icon Link Accessibility
- [x] ~~Add `aria-label` to email icon link~~ (not needed - visible text present)
- [x] ~~Add `aria-label` to phone icon link~~ (not needed - visible text present)
- [x] ~~Add `aria-label` to all social media icon links~~ (not needed - visible text present)
- [x] Add `aria-hidden="true"` to decorative FontAwesome icons

### 1.2 Fix Placeholder Links
- [x] Replace `href="#"` with actual `mailto:` link for email
- [x] Replace `href="#"` with actual `tel:` link for phone
- [x] Verify all links have proper destinations

### 1.3 Fix Heading Hierarchy
- [x] Audit current heading structure (h1 → h2 → h3 → h4)
- [x] Ensure single `<h1>` (name) at top
- [x] Section titles are `<h2>` (Experience, Skills, Education)
- [x] Changed skill categories from `<h4>` to `<h3>` (proper hierarchy)
- [x] Removed footer `<h3>` (changed to `<div>`)

### 1.4 Fix Invalid HTML Structure
- [x] ~~Fix `<dl>` in history.html.liquid~~ (already valid - uses proper dt/dd pairs)
- [x] Fixed orphaned `<dd>` in recommendations.html.liquid (changed to `<div>`)
- [x] Removed invalid `alt` attributes from `<a>` tags in footer
- [x] Ran `./bin/cibuild` - HTML validates (network errors on external GA link only)

### 1.5 Add Navigation Landmarks
- [x] Add skip link to main content at top of page
- [x] Add `<main>` element wrapper
- [x] ~~Add `role="navigation"`~~ (no nav sections present)
- [x] Add `role="contentinfo"` to footer

### 1.6 Keyboard Navigation
- [x] Add visible focus styles (`:focus-visible`) in SCSS
- [x] All interactive elements are keyboard accessible
- [x] Test tab order flows logically (pa11y WCAG2AA pass, manual keyboard test)

---

## Phase 2: ATS Compliance

### 2.1 Simplify HTML for ATS Parsing
- [x] Ensure job titles are in `<h3>` or similar parseable tags (already done in `resume-minimal.html`)
- [x] Ensure company names are clearly labeled (uses Schema.org microdata)
- [x] Ensure dates are in consistent, parseable format (uses `<time>` elements)
- [x] Remove or provide text alternatives for progress bar skills (plain `<li>` in minimal version)

### 2.2 Create Plain Text Resume
- [x] Create `resume.txt` with clean text formatting
- [x] Add link to plain text version (in resume-actions nav bar)
- [x] Auto-generated from YAML data via Jekyll template

### 2.3 Improve Structured Data
- [x] Added JSON-LD include to `_layouts/minimal.html`
- [x] Enhanced `Person` schema with `hasOccupation` for work history
- [x] Added `Occupation` schema for each role (generated from timeline data)
- [x] Added `knowsAbout` for skills/technologies
- [x] Removed home address from JSON-LD for privacy
- [x] Added `sameAs` for LinkedIn and GitHub
- [ ] Validate with Google Rich Results Test (after deploy)

### 2.4 PDF Export Option
- [x] Enhanced print CSS with page-break rules
- [x] Added `.no-print` class for hiding elements in print
- [x] Added "Print / Save as PDF" button to `resume-minimal.html`
- [x] Compact skills list styling for print

---

## Phase 3: Theme Modernization

### 3.1 Bootstrap Upgrade (4 → 5)
> **Note:** This is a large change - consider a dedicated feature branch and PR.

- [ ] Review Bootstrap 5 migration guide
- [ ] Update `assets/scss/bootstrap/` vendor files
- [ ] Fix breaking changes (jQuery removal, class renames)
- [ ] Update utility classes (`ml-*` → `ms-*`, `mr-*` → `me-*`, etc.)
- [ ] Test responsive behavior

### 3.2 Color Contrast & WCAG Compliance
- [ ] Audit primary color `#22A162` against backgrounds
- [ ] Check text colors meet WCAG AA (4.5:1 for normal text)
- [ ] Fix link color contrast (currently 5.57:1 - passes AA, fails AAA)
  - pa11y recommends: change to `#0057af` or darker for AAA
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

> **Note:** Content work is independent of technical phases 2-3 and can run in parallel.

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

**Target page:** `resume-minimal.html` (passes WCAG AA as of 2026-02-01)

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
| Phase 1: A11y & HTML | Complete | 2026-01-30 | 2026-02-01 |
| Phase 2: ATS Compliance | Complete | 2026-02-01 | 2026-02-01 |
| Phase 3: Theme Modernization | Not Started | | |
| Phase 4: Staff+ Content | Not Started | | |
