---
layout: post
title: "Conway's Law in the Trenches: Why We Split Growth and Enablement Squads"
date: "2026-08-30"
description: "When engineering velocity stalls, bad code is rarely the primary culprit. Here is how aligning team topologies into Growth and Enablement squads unblocks feature delivery."
categories:
  - Architecture
  - Leadership
tags:
  - engineering-leadership
  - team-topologies
  - conways-law
  - platform-engineering
  - agile
  - system-architecture
---

Every engineering leader has witnessed the same sudden deceleration: a high-performing product team that used to ship features every sprint gradually grinds to a halt.

Tickets linger in code review for weeks. Production releases become terrifying high-stress events. Sprints are consistently derailed by urgent production escalations, flaky CI tests, and broken shared staging environments.

When leadership asks why velocity has cratered, the answers usually sound technical:
* *"The monolith is too legacy."*
* *"We have too much tech debt."*
* *"The test suite is too slow."*

In reality, technical debt is often a symptom. The root cause is **Conway's Law in reverse**: your team topology is forcing engineers with competing incentives to work in the exact same blast radius.

```
+-------------------------------------------------------------------------+
|                  THE DUAL-SQUAD TEAM TOPOLOGY MODEL                     |
+-------------------------------------------------------------------------+
|  [ GROWTH SQUADS ]       --> Focused on conversion, A/B tests & revenue |
|           │                  Protected from infrastructure firefights   |
|           v                                                             |
|  [ ENABLEMENT SQUAD ]    --> De-risks legacy boundaries, refactors state|
|                              machines, builds CI/CD verification gates  |
+-------------------------------------------------------------------------+
```

---

## 1. The Conflict of Competing Incentives

When you assign feature development, technical debt refactoring, and operational firefighting to a single engineering squad, feature delivery always loses:

1. **The Growth Imperative:** Product managers are incentivized to test new marketing funnels, optimize onboarding flows, and ship business experiments as fast as possible.
2. **The Platform Reality:** Deep legacy refactoring (such as decoupling multi-step state machines or purging PII across 30+ tables) requires intense focus, rigorous verification, and zero interruptions.

When these two responsibilities collide inside the same sprint, one of two dysfunctions occurs:
* **The Band-Aid Anti-Pattern:** Engineers take shortcuts to meet product deadlines, wrapping legacy code in fragile conditional logic that multiplies tech debt.
* **The Modernization Paralysis:** Engineers spend three sprints refactoring deep architectural boundaries, completely stalling user-facing feature delivery.

To restore velocity, you must decouple your team topology.

---

## 2. The Solution: Founding the Enablement Squad

During our acquisition lane scaling at OneMain Financial, our feature squads faced mounting friction from legacy monolith dependencies. To break the deadlock, we restructured our engineering topology by establishing **ACQ Enablement**.

Instead of treating platform modernization as an unfunded background task, we split our engineers into two complementary archetypes:

### 1. Growth Squads (The Explorers):
* **Mandate:** Maximize conversion efficiency, run A/B experiments, and integrate new partner acquisition channels.
* **Operating Contract:** Growth engineers operate in high-velocity domain slices. They are shielded from platform firefights and deep database schema refactors.

### 2. The Enablement Squad (The Stabilizers):
* **Mandate:** Discover system cartography, decouple fragile boundaries, harden CI/CD verification gates, and build self-service developer tooling.
* **Operating Contract:** Enablement acts as internal consultants and platform multipliers. They do not own end-user features; they own the safety and velocity of the Growth squads.

---

## 3. The 3 Core Responsibilities of an Enablement Squad

An effective Enablement squad is not a passive DevOps team that handles Jira tickets; it is an active architectural strike team.

```
+-------------------------------------------------------------------------+
|                ENABLEMENT SQUAD CORE RESPONSIBILITIES                   |
+-------------------------------------------------------------------------+
| 1. STRANGLER-FIG DECOUPLING  --> Carves clear API boundaries            |
| 2. VERIFICATION GATES        --> Fast, deterministic CI test suites     |
| 3. INTERNAL OPEN SOURCE      --> Reusable middleware & telemetry gems   |
+-------------------------------------------------------------------------+
```

### 1. Strangler-Fig Decoupling:
When Growth squads need to modify a legacy, high-risk subsystem, the Enablement squad steps in ahead of time. Enablement maps the lateral state dependencies, isolates database locks, and builds a clean, modern interface. Growth squads can then build against a stable facade without touching radioactive legacy code.

### 2. Hardening Verification Gates:
Enablement owns CI/CD pipeline reliability. If tests are flaky, test runners are slow, or deployment gates are ambiguous, Enablement treats it as a Sev-1 platform outage. By reducing CI execution times and ensuring deterministic builds, they give Growth engineers the confidence to ship multiple times a day.

### 3. Reusable Middleware and Telemetry Tooling:
Enablement standardizes cross-cutting concerns (e.g., OpenTelemetry trace propagation, PII sanitization filters, cryptographic idempotency helpers) into internal libraries. Growth squads simply include the gem or package, getting enterprise-grade compliance and observability out of the box.

---

## 4. Measuring Enablement Success: The Multiplier Metric

How do you evaluate whether an Enablement squad is succeeding?

Never evaluate an Enablement squad by story points completed. Measure them by **Developer Experience and System Multipliers**:

* **Lead Time for Changes:** How many days does it take a Growth squad to take a feature from first commit to production?
* **Deployment Frequency:** Did daily production deployments increase without causing downtime?
* **Change Failure Rate:** Did incidents caused by feature releases decrease across all lanes?
* **Cross-Team Blockers:** Did Growth squad pull requests stall waiting on infrastructure approvals?

At OneMain Financial, establishing ACQ Enablement unblocked four parallel feature streams, eliminated recurring outage cascades, and restored developer morale across the acquisition organization.

---

## Summary: Structure Drives Speed

You cannot solve organizational friction with architectural refactoring alone.

When team velocity stalls:
1. Recognize the conflict between immediate feature velocity and long-term platform stability.
2. Establish dedicated Enablement squads to absorb architectural complexity and protect critical paths.
3. Align Enablement incentives around developer productivity, automated verification, and system legibility.

When your organizational topology matches your architectural goals, high velocity and rock-solid stability become mutually reinforcing reality.
