---
layout: post
title: "From Geekfest to SRE: The 3-Year Lifecycle of a Sustainable Engineering Community"
date: "2026-08-30"
description: "Grassroots engineering communities often die when their founders move on. Here is the 3-phase framework for turning a grassroots meetup into permanent institutional capability."
categories:
  - Leadership
  - Culture
tags:
  - engineering-culture
  - communities-of-practice
  - sre
  - leadership
  - staff-plus
---

Many engineering organizations suffer from the **Hero Founder Trap**:

A passionate senior engineer notices a gap in team knowledge or technical excellence. They start a bi-weekly lunch-and-learn or technical discussion group. For six months, energy is high. Attendance is strong, presentations are engaging, and attendees leave inspired.

Then the founder changes roles, switches projects, or leaves the company. Within three months, the meetup evaporates. Calendar invites are cancelled, Slack channels go silent, and the organization reverts to its baseline silos.

If a community of practice cannot survive the departure of its founder, it was never an organizational capability; it was merely a personality project.

To build an engineering culture that outlasts individual champions, you must design your community around a deliberate **3-Phase Lifecycle**.

```
+-------------------------------------------------------------------------+
|             THE 3-PHASE COMMUNITY OF PRACTICE LIFECYCLE                |
+-------------------------------------------------------------------------+
| Phase 1: THE FOUNDER CATALYST       --> Grassroots excitement & wins    |
| Phase 2: THE WORKING GROUP CADENCE  --> Hands-on pairing & shared code  |
| Phase 3: INSTITUTIONAL STEWARDSHIP  --> Formal handoff to SRE / Core Ops|
+-------------------------------------------------------------------------+
```

---

## 1. Phase 1: The Founder Catalyst (Igniting the Spark)

In the beginning, energy must be concentrated. You cannot create a vibrant culture by assigning committee mandates.

During my career, inspired by the weekly Geekfest format pioneered by Dave Hoover and Kevin Taylor at Obtiva, I created **Geekfest@OMF** to bridge knowledge silos between disparate application squads at Options Monster and OneMain Financial.

In Phase 1, the founder's role is to act as the energetic catalyst:
* **The No-Friction Format:** Keep entry friction near zero. Avoid mandatory attendance, rigid slide decks, or formal approval gates.
* **Demonstrating Practical Craft:** Focus on tangible, immediate engineering problems rather than abstract theory. Show live terminal demonstrations, benchmark comparisons, and practical refactoring techniques.
* **Creating a Psychological Safe Haven:** Make it an environment where developers can openly discuss what went wrong during an outage without fear of blame.

Phase 1 succeeds when engineers start attending not because they were invited, but because they learn something actionable every single session.

---

## 2. Phase 2: The Working Group Cadence (Turning Talk into Tooling)

The most common failure point for technical communities is remaining stuck in Phase 1 as an informal "talk shop."

Discussions are enjoyable, but organizational leverage requires **building shared artifacts**. In Phase 2, transition the community into an active **Working Group**:

```
[ PRESENTATION / DISCUSSION ] ──> [ HANDS-ON PAIRING LAB ] ──> [ SHARED INTERNAL ARTIFACT ]
```

### The Working Group Evolution:
At OneMain Financial, as Geekfest@OMF expanded, we spun up focused working groups, including the **OpenTelemetry Working Group**:
1. **Live Cross-Team Pairing:** Rather than lecturing about distributed tracing, we paired with engineers from different squads on their active staging pull requests.
2. **Internal Helper Gems:** When multiple squads hit the same friction point (e.g. propagating W3C trace headers across legacy gateways), the working group authored shared internal libraries to solve it once for everyone.
3. **Cross-Lane Representation:** We recruited rotating co-hosts from Platform, Growth, Security, and Core backend squads, deliberately diluting single-person dependency.

---

## 3. Phase 3: Institutional Stewardship (The Sustainable Handoff)

The ultimate test of a Principal Engineer's leadership is whether the systems and cultures they create continue to thrive when they step away.

In Phase 3, you deliberately engineer the **stewardship transition**:

### 1. Transferring Operational Ownership:
Identify the formal organizational department whose permanent mission aligns with the community's output. For our OpenTelemetry initiatives, that natural home was **Site Reliability Engineering (SRE)** and the **Enterprise Monitoring Center (EMC)**.

### 2. Codifying the Rituals:
Document the meeting cadence, agenda templates, shared dashboards, and facilitation guidelines into standard platform engineering documentation.

### 3. Stepping Back into Mentorship:
The founding architect transitions from primary speaker to executive sponsor and peer mentor, allowing emerging staff and senior engineers to lead sessions, present retrospectives, and drive architectural standards.

---

## Summary: Crafting Enduring Engineering Culture

Great technical leadership is measured not by how essential you are to daily meetings, but by how smoothly those meetings run without you.

To build sustainable engineering communities:
1. Start with grassroots enthusiasm and zero-friction practical demonstrations.
2. Transition discussions into focused working groups that produce shared tools and code.
3. Hand off operational facilitation to permanent institutional stewards.

When you engineer communities with intentional succession, you leave behind an organization that continues to learn, build, and elevate craftsmanship for years to come.
