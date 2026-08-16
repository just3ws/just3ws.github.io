# SCMC & UGtastic Content Synthesis Roadmap

This document outlines a structured plan for identifying, synthesizing, and publishing new historical articles and deep-dive posts derived from the intersection of **SCMC (Software Craftsmanship Movement Chicago) meetings**, **UGtastic interviews**, **written blog posts**, and **Mike Hall's career timeline**.

---

## 1. Core Intersections & Article Candidates

### Article Candidate 1: "The Chicago Movement — How SCMC & SCNA Built Chicago's Tech Boom"
- **Intersection:** SCMC meetings (Steve Kim, Jim Suchy, Andy Maleh) x SCNA Keynotes (Uncle Bob Martin, Sandro Mancuso) x Groupon L&D Partner role (`groupon.yml`).
- **Core Narrative:** How frustration with corporate Agile led Chicago developers to found SCMC and SCNA, creating the talent pipeline that powered Chicago's 2010–2015 high-growth tech surge.
- **Primary Source Data:** `vimeo-30083598` (Uncle Bob Martin), `vimeo-44387717` (Andy Maleh), `dave-hoover-geekfest-geekfest` interview, `2025-01-18` blog post.

### Article Candidate 2: "Polyglot Java & Ruby Interop — Lessons from SCMC Presentations"
- **Intersection:** SCMC presentation `ActiveJDBC & ActiveWeb` (Igor Polevoy) x UGtastic interview `igor-polevoy-general` x `activecampaign.yml` & `reachlocal.yml`.
- **Core Narrative:** How early SCMC presentations demonstrated dynamic language patterns (ActiveRecord-style ORMs for Java, JRuby concurrency) to safely modernize coupled legacy enterprise platforms.
- **Primary Source Data:** `vimeo-38936294` (Igor Polevoy), `charles-oliver-nutter-general` interview, `2015-04-27-leverage-the-j-in-jruby` blog post.

### Article Candidate 3: "Practice vs. Repetition — From SCMC Katas to AI-Augmented Systems"
- **Intersection:** SCMC PechaKucha presentation (`pechakucha-teach-yourself-beginning-community...`) x UGtastic interviews (Katrina Owen, Paul Baker, Corey Haines) x `benchprep.yml` & `phalanx-duel.yml`.
- **Core Narrative:** Tracing the evolution of deliberate practice (Code Retreats, Exercism.io katas) into modern AI-augmented engineering workflows where human developers govern agent output rather than treating LLMs as authoritative.
- **Primary Source Data:** `katrina-owen-general`, `corey-haines-general`, `2025-01-04-practice-vs-repetition` blog post.

### Article Candidate 4: "Architecture Beyond Hype — The A Word Keynote Synthesis"
- **Intersection:** SCMC Keynote `The A Word: Architecture` (Uncle Bob Martin) x UGtastic interview `robert-martin-software-craftsmanship-north-america-2012` x OneMain & EMR-Bear case studies (`/case-studies/`).
- **Core Narrative:** Comparing Uncle Bob's 2011 SCMC architecture warnings with modern 4D System Cartography principles (Interaction Surface, Lateral State Dependencies, Full-Stack Topologies, Supply Chain Exposure).
- **Primary Source Data:** `vimeo-30083598` (Uncle Bob Martin), `_data/case_studies.yml`, `2026-05-20-214-technical-conversations` post.

---

## 2. Navigation & Site Integration

1. **Top-Level Navigation Link**: Added `SCMC History` under the **Archive** dropdown in `_data/navigation.yml`.
2. **Resume Position Cross-Links**: Linked SCMC synthesis entries inside position pages (`obtiva.html`, `groupon.html`, `activecampaign.html`, `benchprep.html`, `reachlocal.html`, `tandem.html`).
3. **Canonical Route**: Published at `/scmc/` (`scmc/index.html`).

---

## 3. Publication Workflow

```
[Audited Transcript Corpus]
            ↓
[Subagent Historical Synthesis]
            ↓
[Draft Article in _posts/ / docs/]
            ↓
[Verify via ruby bin/validate_data.rb & node bin/verify_mcp_spec.js]
            ↓
[Commit & Push to master -> Deployed to Production]
```
