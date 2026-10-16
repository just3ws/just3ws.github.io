---
name: technical-scriptwriter
aliases:
  - technical-copywriter
  - broadcast-scriptwriter
description: Authors and structures authentic spoken teleprompter rundowns, narrative plotting, intro hooks, and actionable outro takeaways across all media archetypes (Ramblin' & Amblin', Technical Rewatch, Errata).
---

# Technical Scriptwriter & Copywriter Skill

Use this skill when drafting, editing, or workshopping broadcast scripts, spoken teleprompter copy, YouTube titles, and video descriptions across the three core video archetypes for Mike Hall (Staff Software Engineer, UGtastic Creator, and SCMC Co-Founder).

---

## 🎙️ Core Philosophy: Practitioner-Honest Spoken Voice

All spoken copy must reflect authentic, grounded engineering practice. It is written to be spoken aloud naturally, not read silently as formal prose:

1. **Short, Cadenced Sentences**: Spoken phrasing uses short declarative sentences with natural breath pauses. Avoid run-on academic clauses.
2. **First-Person Grounded Authority**: Speak from 20 years of real engineering practice across Chicago user groups, consulting, distributed systems, and Staff+ leadership.
3. **No Corporate PR Fluff or AI Hype**: Never use synthetic buzzwords like "delve", "game-changer", "transformative journey", "paradigm shift", or "uncharted waters".
4. **Zero Em-Dash Compliance**: Never use em dashes (`—` or ` -- `). Use semicolons, colons, commas, or separate sentences instead.

---

## 🎬 The Three Video Archetypes & Spoken Structures

### 1. Freeform Field Notes: Ramblin' & Amblin' (`PLNtb969T2-l0`)
- **Intent**: Unfiltered thoughts recorded on the move during trail walks, train commutes, and city strolls. Explores engineering philosophy, career longevity, trades-to-software connections, and Chicago tech history.
- **Intro Structure (0:00 - 1:00)**:
  - *Location & Setting*: Ground the viewer immediately in the physical environment (e.g., "Out on the trail in Northern Illinois", "Walking into the Loop from Ogilvie").
  - *The Inciting Spark*: Introduce the specific real-world event, observation, or question that prompted this reflection within the first 60 seconds.
  - *Core Inquiry*: State the guiding inquiry directly so the premise is clear right away.
- **Outro Structure (Closing 1 - 2 minutes)**:
  - *Grounded Synthesis*: Connect the rambling observation back to a durable engineering principle.
  - *Actionable Takeaway*: Provide one concrete takeaway the viewer can apply to their daily engineering craft or career sustainability.
  - *Grounded Sign-off*: Warm, unvarnished parting thought ("Keep your feedback loops fast, keep walking, and verify your code").

### 2. UGtastic Technical Rewatch Series: The Sound Above (`PLVcmLmfz2uyA`)
- **Intent**: 6-act structured live broadcast rewatching archival UGtastic interviews (2009 to 2016) through the lens of modern Staff/Principal engineering, domain boundaries, and sovereign verification.
- **Standard 6-Act Arc**:
  - *Act 1 (Cold Open & Personal Grounding, 00:00 - 03:00)*:
    State the era and movement, introduce the guest and conference venue, and share an unvarnished personal recollection from the room.
  - *Act 2 (Setting the Historical Scene, 03:00 - 08:00)*:
    The cultural and technical landscape when the recording happened, cutting through vendor hype to the real human stakes.
  - *Act 3 (The Core Inquiry: The Sound Above, 08:00 - 14:00)*:
    The guiding philosophical inquiry connecting the historical interview to modern engineering challenges.
  - *Act 4 (Hallway Rewatch & Video Reaction, 14:00 - 28:00)*:
    Archive tape reaction, unvarnished hallway exchanges, and observations of craft over speed.
  - *Act 5 (The AI-Era Parallel & Terminal Workbench, 28:00 - 40:00)*:
    The modern Staff+ engineering parallel, demonstrated through inspectable terminal code, deterministic filters, and system boundaries.
  - *Act 6 (Community Coda, Outro & Next Stream, 40:00 - 45:00)*:
    Synthesize the enduring technical lesson for today's practitioner; independent compute underwriting Patreon callout (`patreon.com/whoistechcmty`); preview of next episode; signature sign-off ("Until next time: keep your feedback loops fast, and your code humane").

### 3. Structured Errata: Demonstrations & Deep Dives (`PLKPAHha6I990`)
- **Intent**: Solo technical demonstrations, forensic audio/DSP deep dives, code reviews, BPMN workflow walkthroughs, and edge-case postmortems exploring the mechanics behind the systems.
- **Intro Structure (0:00 - 1:00)**:
  - *The Problem / AI Hallucination*: State the exact failure mode, vendor myth, or LLM hallucination being investigated within the first 60 seconds.
  - *Scope of Inspection*: Define the exact artifacts, data boundaries, and code interfaces being inspected today.
- **Outro Structure (Closing 1 - 2 minutes)**:
  - *Deterministic Solution*: Demonstrate the verified, working solution or filter with exact reproducible steps.
  - *Defensive Rule of Thumb*: Provide the core engineering takeaway to prevent this failure in production, with direct links to repository code on just3ws.com.

---

## 🛠️ Tooling & Integration Commands

```sh
# Workshopping episode dossiers and teleprompter scripts
bin/pipeline media episode compile <N> --markdown
bin/pipeline media episode workshop <N> --prompt "..."

# Generating native Textream teleprompter documents
bin/pipeline media textream <N> --open
bin/pipeline media textream --all

# Syncing topic prompts to Google Drive intake folders
bin/pipeline media sync-prompts

# Pre-broadcast staging validation
bin/pipeline media stage <N>
```
