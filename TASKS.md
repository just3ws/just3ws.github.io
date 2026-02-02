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

> **Status: SKIPPED** - Pillar theme removed entirely. Site now uses minimal theme only.

### 3.1-3.4 All Skipped
- [x] ~~Bootstrap upgrade~~ - Bootstrap removed, not needed
- [x] ~~Color contrast~~ - Minimal theme uses system defaults
- [x] ~~Modern CSS~~ - Minimal.css is already clean
- [x] ~~Visual refresh~~ - Completed by adopting minimal theme

### 3.5 Theme Cleanup (Completed 2026-02-01)
- [x] Removed Pillar theme (12 SCSS/CSS files)
- [x] Removed Bootstrap vendor directory (146 files, ~1.4 MB)
- [x] Removed old resume Liquid templates (29 files)
- [x] Removed unused includes (facebook.html, open_graph.html)
- [x] Removed unused assets (profile.jpg)
- [x] Promoted `resume-minimal.html` to `index.html`
- [x] Added redirect from `/resume-minimal.html` to `/`

---

## Phase 4: Staff+ Content Strategy

> **Note:** Content work is independent of technical phases and is the primary remaining work.

### 4.1 Add Job Context
Add `context` field to position YAML files to frame the business/company situation:
- [x] OneMain Financial - consumer lending scale, regulatory environment, revenue-critical systems
- [x] SK Holdings - digital media/affiliate marketing, campaign scale
- [x] ActiveCampaign - marketing automation platform, 180K+ customers
- [x] BenchPrep - ed-tech/LMS, high-stakes certification platforms
- [x] ReachLocal - digital marketing for SMBs, acquired by Gannett
- [x] KloboMedia - startup, CTO/technical co-founder role

### 4.2 Achievement Restructuring
Recent positions restructured with impact-first language:
- [x] OneMain Financial - already strong, minor refinements
- [x] SK Holdings - consolidated 15→7 achievements, outcome-focused
- [x] ActiveCampaign - consolidated 4→3 achievements, UX/performance emphasis
- [x] BenchPrep - rewritten with security/reliability emphasis
- [x] ReachLocal - consolidated, payment migration highlighted
- [x] KloboMedia - leadership/ownership emphasis
- [ ] Older positions (pre-2015) - consider condensing per career_history.md guidance

### 4.3 Add Scope Indicators
Added `scope` field to recent positions with scale, ownership, and influence:
- [x] OneMain Financial - millions of customers, lane-level ownership, cross-functional influence
- [x] SK Holdings - millions of contacts, platform ownership
- [x] ActiveCampaign - 180K+ customers, high-traffic systems
- [x] BenchPrep - enterprise clients (ACT, HRCI), assessment integrity
- [x] ReachLocal - thousands of SMB clients, cross-team influence
- [x] KloboMedia - full technical ownership as CTO/co-founder

### 4.4 Technical Leadership Highlights
- [x] Added "Technical Leadership" section to index.html and resume.txt
- [x] Highlighted OpenTelemetry initiative (enterprise-wide observability)
- [x] Highlighted Groupon onboarding/training programs
- [x] Highlighted Communities of Practice founding
- [x] Highlighted WHOIS Tech Community / UGtastic
- [x] Highlighted team enablement functions

### 4.5 Content Review
- [x] Reviewed all 24 positions in `_data/resume/positions/`
- [x] Timeline reduced to 7 recent/relevant roles (2011+)
- [x] Pre-2014 roles collapsed into "Earlier Experience" summary
- [x] Consistent voice and formatting across all sections

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

**Main page:** `index.html` (was resume-minimal.html, passes WCAG AA)

Key files:

| File | Purpose |
|------|---------|
| `index.html` | Main resume page |
| `resume.txt` | Plain text version (auto-generated) |
| `_layouts/minimal.html` | Layout template |
| `_includes/json-ld.html` | Structured data for SEO/ATS |
| `assets/css/minimal.css` | Styles (screen + print) |
| `_data/resume/timeline.yml` | Position order |
| `_data/resume/positions/*.yml` | Position content (24 files) |

---

## Progress

| Phase | Status | Started | Completed |
|-------|--------|---------|-----------|
| Phase 1: A11y & HTML | Complete | 2026-01-30 | 2026-02-01 |
| Phase 2: ATS Compliance | Complete | 2026-02-01 | 2026-02-01 |
| Phase 3: Theme Modernization | Skipped | 2026-02-01 | 2026-02-01 |
| Phase 4: Staff+ Content | Complete | 2026-02-01 | 2026-02-02 |
