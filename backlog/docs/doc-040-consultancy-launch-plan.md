---
id: doc-040
title: consultancy-launch-plan.md
type: other
created_date: '2026-05-03 18:59'
---
# Revenue-first launch plan for a Rails and Postgres consultancy

**Executive summary.** The shortest path to paid consulting is not an AI product, a general “fractional engineering” pitch, or a broad Rails agency offer. It is a fixed-scope diagnostic service for expensive, already-visible problems inside Rails/Postgres systems: broken production behavior, upgrade blockers, slow queries, lock contention, broken sync jobs, and funnel or data-integrity anomalies. That market is real right now. The official Rails Job Board is active with senior Rails roles; current startup hiring on Wellfound spans both 11–50 and 51–200 employee companies; founder-led startups on Y Combinator’s jobs platform explicitly expose founders as the hiring contact; and current freelance listings show buyers paying for urgent short-term Rails/Postgres work, including expert fixed-price integration work and legacy rescue projects.

The practical plan is to sell one main productized offer and one narrower add-on. The main offer should be a **System Behavior Deep-Dive** priced to close quickly, not optimized for lifetime margin on day one. A secondary **PII & Data Integrity Remediation** should exist for buyers whose problem is visibly in Postgres, Sidekiq-style background processing, or third-party sync paths. Current market rates support that packaging: Upwork’s current Rails cost guide shows typical historical hourly ranges, its same page shows intermediate and expert bands, and Arc’2026 rate data puts Rails freelancers at a median of \$61–80/hr and an average of \$81–100/hr. A \$4,500 entry Deep-Dive and a \$7,500 deeper remediation are therefore inside market, especially when the alternative is continued revenue leakage, downtime, or blocked delivery.

AI belongs in the workflow, but not in the liability boundary. Use it locally to compress logs, summarize `EXPLAIN` output, cluster anomalies, and produce first-pass system maps. Keep human judgment on scope, evidence selection, root-cause calls, risk ranking, and the final recommendation memo. That division is consistent with the current market: Stack Overflow’s 2025 survey shows 84% of respondents using or planning to use AI in development, but 46% said they do not trust the accuracy of AI output. The winning message is therefore not “I do AI consulting.” It is “I tell you what your system is actually doing, fast, with evidence.”

## Milestones & Architectural Shift

The ultimate goal is to establish the consultancy as the primary brand. This requires a structural shift in the site's presence.

| Milestone | Objective | Key Actions |
|---|---|---|
| **M1: Resume Migration** | Relegate resume to sub-path | Migrate `index.html` (current resume) to `/resume` and `/resume.html`; verify all deep links. |
| **M2: Surface Build** | Create consultancy intake | Build landing page at `/consultancy` (staging); implement intake surface and tiers. |
| **M3: Root Swap** | **Consultancy as Primary Presence** | Move consultancy landing page to `/` (site root); configure 301 redirects for legacy resume SEO; update navigation. |
| **M4: Market Entry** | First paid engagement | Execute the "Customer Acquisition" sprint; secure first signed engagement. |

## Market reality

This is not a “will anyone still pay for Rails?” problem. The official Rails Job Board currently lists senior and staff Rails roles with salaries in the six figures, and it explicitly supports contract and freelance terms. On Wellfound, current Rails openings appear at both 11–50 and 51–200 employee companies. One active Rails-board posting from a mature, founder-owned company describes a Rails monolith with Postgres, heavy third-party integration work, live-issue debugging, careful concurrency control, and production-data analysis as core engineering work. Another current posting from a profitable telehealth company ties Rails/Postgres directly to acquisition-funnel revenue, event-sourced state, background jobs, and a Head of Engineering reporting line. In plain English: companies are still running serious revenue-bearing Rails/Postgres systems, and the problems they hire for match your skill set unusually well.

Buyers spend fastest when the pain is attached to money, downtime, or a deadline they cannot move. A 2025 outage analysis found that 54% of respondents said their most recent significant outage cost more than \$100,000, and one in five said it cost more than \$1 million. The same report found that four in five operators believed better management or processes would have prevented their most recent downtime incident. That matters here because your offer is not “general advice”; it is a short operational intervention for problems buyers already perceive as costly and embarrassingly unresolved.

The other important signal is that external specialist spend is already normalized in the Postgres market. The official PostgreSQL professional-services directory includes firms serving early-stage startups, mid-market customers, and enterprises with offerings around database audits, tuning, migrations, HA/DR, and 24x7 support. That means “bring in a PostgreSQL specialist for a narrow, production problem” is already a familiar buying motion rather than a strange category you must invent.

| Priority | Buyer | Company profile | Trigger that opens budget | Why this buyer is first |
|---|---|---|---|---|
| High | Founder or CEO | 11–50 employee SaaS or founder-led product company | One broken path affects revenue, launch date, or investor confidence | Founder access is explicit on Y Combinator, and Wellfound shows many Rails companies in this size band. |
| High | Head of Engineering or CTO | 20–200 employee growth or mature SaaS | Recurring incidents, blocked upgrades, “nobody understands this path” | This role directly owns engineering risk, delivery, and vendor spend. |
| High | Growth or acquisition engineering lead with budget cover | 20–200 employee subscription or ecommerce business | Checkout/CVR anomalies, user-state drift, event/funnel mismatch | The pain maps directly to money, so diagnostics are easier to justify. |
| Medium | Database or platform owner | 15–100+ product company with meaningful Postgres load | Slow queries, lock waits, migration risk, integrity issues | The Postgres services market already treats tuning and audits as normal purchases. |
| Medium | Marketplace client | SMB to 10–99 employee company | Acute short-term problem with a visible symptom | Fastest short-term cash path, but more price competition and noisier demand. |

## Problem-offer fit

Do not sell “consulting.” Sell diagnosis of one painful, expensive, specific failure mode. The right buyer is not trying to buy your general intelligence. They want one part of their system to stop behaving like a haunted house. The offer has to meet that mental state.

| Concrete problem | Why it is urgent | Why teams stall | Best offer | AI-enabled advantage |
|---|---|---|---|---|
| Silent record loss in a signup, checkout, import, or sync path | Revenue loss, support load, trust damage | Ownership crosses app code, jobs, and DB state | System Behavior Deep-Dive | Cluster logs, reconstruct event sequence, summarize likely breakpoints |
| Slow query or lock contention under production load | User-facing slowness, incidents, deploy hesitation | Teams argue about app code vs DB cause | PII & Data Integrity Remediation | Rank query pain from `pg_stat_statements`; summarize `EXPLAIN` JSON fast |
| Retry storms or stale background jobs causing duplicate or missing side effects | Money, messaging, or state corruption | Job framework behavior is asynchronous and distributed | PII & Data Integrity Remediation | Cluster retry classes, payload shapes, and timing windows |
| Rails/Ruby/Postgres upgrade blocked by hidden coupling | Security and delivery risk accumulates | Fear of regressions blocks movement | System Behavior Deep-Dive | Build a dependency/risk map from code, logs, and schema faster |
| Third-party integration drift | Finance or ops teams lose confidence in the data | Internal teams lack time to trace both ends | PII & Data Integrity Remediation | Compare event logs, payload samples, and DB state across the sync path |
| Same incident keeps recurring with no agreed root cause | On-call fatigue and leadership distrust | Tests pass; production still misbehaves | System Behavior Deep-Dive | Compress previous incident artifacts into hypothesis clusters |
| Event-sourced, callback-heavy, or command-pattern behavior diverges from the team’s mental model | Product and engineering start arguing about “expected” state | State is emergent, not obvious from one file | System Behavior Deep-Dive | Produce first-pass state machine summaries from traces and code |
| Key engineer left and nobody knows the behavior envelope | Key-person risk becomes a business risk | Knowledge is trapped in history, not docs | System Behavior Deep-Dive | Use local retrieval over logs/schema/code to rebuild operating context |

## Minimal service design

The market already understands audit-style work. Multiple specialist Rails and Postgres consultancies publicly sell code audits, application reviews, upgrade roadmaps, performance tuning, and database consulting, and publicly describe those engagements in days, not quarters. Your launch version should be narrower than a full code audit and much easier to buy.

| Offer | Exact scope | Deliverables | Timebox | Launch price | Standard price | Explicit exclusions |
|---|---|---|---|---:|---:|---|
| System Behavior Deep-Dive | One app, one DB, one critical path, one visible symptom; read-only production access mandatory | Two-to-four page report, behavior map, top three risks, evidence appendix, prioritized next steps, 60-minute walkthrough | 1 business week | \$4,500 | \$6,000 | No code changes, no on-call, no rewrite plan, no multi-service estate review |
| PII & Data Integrity Remediation | One query cluster, lock/contention pattern, or one sync/data-integrity path | Remediation recipe, orphan discovery map, integrity checks, remediation sequence, 60-minute walkthrough | 1 business week | \$7,500 | \$10,000 | No migration implementation, no warehouse work, no full observability rollout, no feature shipping |

## AI leverage

The operating rule is blunt: use AI for compression, pattern clustering, and draft synthesis; do not use it as the final arbiter of truth. That stance matches the current developer market. AI use is already mainstream, but trust is not. Your differentiation is therefore not “I used a model.” It is “I used local models to move faster and still made human evidence calls.”

| Input | Why you want it | Local transformation | Human decision that remains |
|---|---|---|---|
| `schema.rb` or `structure.sql` plus a few representative models/jobs/controllers | Rebuild the real data and behavior surface fast | Chunk and summarize relationship and lifecycle hotspots | Decide which path is in scope and which coupling is actually risky |
| `pg_stat_statements` top queries | Surface real query cost by planning/execution stats | Rank and cluster by total time, mean time, and calls | Decide what is causal vs incidental |
| `EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)` output | Compare planner estimates to reality and inspect IO/cache behavior | Convert JSON plans into terse natural-language summaries | Decide query/index/transaction remediation order |
| `pg_stat_activity` snapshots and wait events | See lock, IO, IPC, and wait patterns live | Group waits and likely blockers | Decide whether the root problem is transaction design, workload shape, or deployment timing |
| Rails logs with request IDs / correlated IDs | Reconstruct the actual execution path | Deduplicate, cluster, and summarize divergent paths | Decide which anomalies are real, not noise |
| Targeted Rails instrumentation if current logs are thin | Add evidence for one hot path without standing up a new observability program | Generate event timelines from custom Notifications hooks | Decide what is instrument and when the evidence is sufficient |

## Customer acquisition

Use direct outreach first and marketplaces second. Direct wins because the buyer is easier to frame around a symptom and a fixed outcome. Marketplaces are secondary because good Rails/Postgres jobs attract fast competition.

| Day | Objective | Exact actions | Exit condition |
|---|---|---|---|
| Day 1 | Build the conversion surface | **Execute Milestone M1 & M2** (Migrate resume, stage intake page); prepare target list of 40 names | Site is live and the target list exists |
| Day 2 | Warm outreach | Send 15 direct emails/DMs to former colleagues, founders, and engineering leads; ask for referral if not a fit | At least 5 replies or referral paths |
| Day 3 | Cold targeted outreach | Send 10 short messages to Rails-company founders/heads from Rails Job Board, YC, and Wellfound | At least 2 live conversations |
| Day 4 | Community touches | Post one concise offer note in Rails/Postgres communities where allowed; reply to existing “help needed” or hiring threads | At least 3 direct contacts from community touchpoints |
| Day 5 | Marketplace capture | Bid on 5 newest expert-level Upwork jobs; apply to Toptal only if you can spare the screening overhead | At least 1 scoped opportunity with explicit pain |
| Day 6 | Quote and close | Send fixed-price proposals with exclusions, ask for payment before kickoff, cap scoping call at 15 minutes if needed | One signed or verbally committed engagement |
| Day 7 | Start delivery | Collect evidence pack, begin analysis, and front-load confidence-building communication | Buyer sees momentum within 24 hours |

## Risk analysis

The launch risk is not mainly technical. It is commercial discipline. The most common failure is slipping from “small, expensive diagnostic” into “generic senior contractor.”

| Failure mode | Early signal | Corrective action |
|---|---|---|
| No replies | People say “interesting” but do not engage with a concrete problem | Rewrite copy around one trigger: recurring incident, data drift, slow query, upgrade blocker |
| Replies ask for feature work | Prospects think you are a dev shop | Lead with audit deliverable and exclusions, not your resume |
| Lots of calls, no closes | Buyers do not understand what they are buying | Send a one-page sample deliverable and fixed price before a live call |
| Scope creep during sale | Buyer keeps adding systems and symptoms | Enforce one-path rule; sell the second path as a second engagement |
| AI introduces weak findings | Memo contains plausible but unsupported claims | Require every finding to cite evidence from logs, SQL, or plans |
| Marketplaces consume time | Fresh jobs quickly show large proposal counts | Cap bids to newest expert/urgent jobs and keep direct outreach primary |
| Buyer cannot provide evidence | Kickoff stalls immediately | Make data availability a qualification gate before payment |
| You underprice too long | Work lands but cash flow does not improve | End launch pricing after two wins or one testimonial |

## Scaling after first revenue

Do not optimize before the first sale. After the first sale, optimize hard. The scaling path is about raising certainty, price, and reuse—not adding service sprawl.

| Milestone | Move | Why |
|---|---|---|
| After first paid audit | Ask for one testimonial and one referral immediately | Proof matters more than polishing |
| After two paid audits | End launch pricing; move Audit to \$3,500 standard | You now have evidence the offer closes |
| After three to four audits | Add a follow-on “Fix Sprint” or “Upgrade Readiness Sprint” | Capture implementation work without bloating the base offer |
| After five audits | Turn scripts, queries, prompts, and templates into a private playbook | Reduce delivery time per engagement |
| After six or more audits | Split landing pages by pain: upgrade blockers, revenue-path drift, query triage | Better conversion from specific pains, not broader branding |
| After consistent demand | Add a small retainer only for previous audit clients | Retainers make sense after trust, not before |
