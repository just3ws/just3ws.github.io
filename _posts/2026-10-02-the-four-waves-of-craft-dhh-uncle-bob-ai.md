---
layout: post
title: "The Four Waves of Craft: DHH, Uncle Bob, and Writing Software in the Age of AI"
date: 2026-10-02
description: "From Agile to Craftsmanship, from 'TDD is Dead' to Generative AI: tracing the debates of David Heinemeier Hansson and Robert C. Martin through primary-source interviews, and contextualizing what craftsmanship actually means when machines generate code."
permalink: /ai/2026/10/02/the-four-waves-of-craft-dhh-uncle-bob-ai/
ai_generated: true
human_led: true
source_kind: ai-augmented-human-led
robots: noindex,follow
sitemap: false
tags:
  - Software Craftsmanship
  - DHH
  - Uncle Bob Martin
  - UGtastic
  - SCMC
  - local-first AI
  - systems thinking
  - TDD
---

_Editorial note: Mike Hall supplied the primary-source interview transcripts, historical context from SCMC and UGtastic, and core philosophical framing for this article. The events and interviews described are drawn from the lived archive on just3ws.localhost._

---

## The Corridor and the Keynote

In April 2014, I stood in the corridor at RailsConf in Chicago with a microphone in my hand, talking to **David Heinemeier Hansson (DHH)**. He had just stepped off stage from delivering one of the most explosive keynotes in the history of the Ruby community: the speech that ignited the firestorm declaring "TDD is Dead."

When I asked him what he was trying to communicate, he didn't talk about test suites or mocks. He talked about identity and metaphor:

> _"I think the identity of most programmers is coming from an angle that doesn't fit the development of information technology very well anymore. And that angle is software engineering. What they do is they write. They're software writers. They're trying to achieve a level of clarity... Figuring out what you want to build is very much like figuring out what you want to say."_  
> [Mike Hall Interviews David Heinemeier Hansson on Clarity and Software Writing (RailsConf 2014)](/interviews/david-heinemeier-hansson-dhh-railsconf-2014/)

Two years earlier, at the University of Chicago's Gleacher Center downtown for Software Craftsmanship North America (SCNA 2012), I sat down with **Robert C. Martin ("Uncle Bob")**. In that interview, Uncle Bob spoke with the passionate intensity of an evangelist defending the sanctity of the trade:

> _"I fly all over the doggone place and give talks and yell at people and encourage them to be professional and talk about solid principles and techniques... It's just another creative outlet. Just another way for me to spread my message around the world."_  
> [Filling the Vessel: Robert 'Uncle Bob' Martin on the Craft of Performance and Clean Coders (SCNA 2012)](/interviews/robert-martin-software-craftsmanship-north-america-2012/)

A year before that, on October 5, 2011, Uncle Bob had driven out to Follett Software Company in McHenry County to deliver a keynote to our suburban user group, **Software Craftsmanship McHenry County (SCMC)**: an unvarnished lecture titled [_The A Word: Architecture_](/scmc/).

For over a decade, DHH and Uncle Bob have functioned as the twin poles of modern software discourse: the Iconoclast Writer who tears down ceremonial scaffolding, and the High Priest of Professionalism who demands rigorous technical vows.

Now, in 2026, both men find themselves in the crosshairs of a new upheaval: **Generative AI and Agentic Coding**.

When LLMs can churn out thousands of lines of syntax in seconds, what happens to DHH's "software writing"? What happens to Uncle Bob's "clean craftsmanship"? 

To understand where we are standing today, we have to look back through the **Four Waves** that brought us here.

---

## The Four Waves of Modern Development

```
┌──────────────────────────────────────────────────────────────────────────────────────────┐
│                                   THE FOUR WAVES                                         │
├─────────┬───────────────────┬──────────────────────────────────┬─────────────────────────┤
│ Wave    │ Catalyst          │ Core Tension                     │ Central Controversy     │
├─────────┼───────────────────┼──────────────────────────────────┼─────────────────────────┤
│ Wave 1  │ 2001 (Snowbird)   │ Agile Manifesto vs. Corporate    │ Process vs. People      │
│         │                   │ Bureaucracy (RUP, CMMI, BDUF)    │                         │
├─────────┼───────────────────┼──────────────────────────────────┼─────────────────────────┤
│ Wave 2  │ 2008–2009         │ Software Craftsmanship vs.       │ Quality vs. Velocity    │
│         │ (Libertyville)    │ "Flaccid Scrum" & Certifications │ (Craftsmanship over     │
│         │                   │                                  │ Crap)                   │
├─────────┼───────────────────┼──────────────────────────────────┼─────────────────────────┤
│ Wave 3  │ 2014–2015         │ Software Writing vs. Clinical    │ "TDD is Dead" vs.       │
│         │ (RailsConf/SCNA)  │ Engineering (DHH vs. Fowler/Beck)│ Unit-Test Orthodoxy     │
├─────────┼───────────────────┼──────────────────────────────────┼─────────────────────────┤
│ Wave 4  │ 2023–2026         │ Human Intent vs. Synthetic Code  │ Will AI Replace         │
│         │ (The Age of AI)   │ Generation (Copilot, Claude, LLM)│ Programmers?            │
└─────────┴───────────────────┴──────────────────────────────────┴─────────────────────────┘
```

### Wave 1: The Snowbird Rebellion (2001)
The Agile Manifesto was born out of frustration with corporate paralysis. Seventeen developers at Snowbird rebelled against heavy, clinical planning regimes. They valued *working software over comprehensive documentation* and *individuals over processes*.

Over the next seven years, however, corporate America figured out how to commoditize Agile. Project managers bought certifications. Two-day ScrumMaster courses replaced technical discipline. Velocity became a quota. The movement had solved process overhead only to replace it with management bureaucracy.

### Wave 2: The Libertyville Summit & The Craftsmanship Corrective (2008–2009)
In December 2008, Uncle Bob wrote his clarion essay: *"Craftsmanship over Crap."* He warned that Agile had abandoned code quality.

Two weeks later, developers gathered at 8th Light in Libertyville, Illinois for the first Software Craftsmanship Summit. Out of that room came the **Software Craftsmanship Manifesto** in March 2009:
> *"Not only working software, but also **well-crafted software**."*

I signed that ledger on March 6, 2009 as **Signatory #106**. We started SCMC in McHenry County to practice that craft locally. The movement demanded that developers reclaim their dignity through TDD, pairing, automated testing, and clean architecture.

### Wave 3: The "TDD is Dead" Collision (2014)
By 2014, the Craftsmanship movement had developed its own dogmas. Unit-test isolation, test-first design, mock-heavy architectures, and hexagonal purity were increasingly treated as moral imperatives.

DHH stepped into RailsConf 2014 and shattered that consensus. In our corridor conversation right after his talk, he told me that driving design through unit tests produced *"test-induced design damage"*: fragmented, over-abstracted code that destroyed clarity. He advocated for system-level integration tests and treating software like prose: expressive, cohesive, and subjective.

The ensuing debate between DHH, Martin Fowler, and Kent Beck was not a fight about whether tests matter; it was a fight over **metaphor**. Is software an engineering discipline governed by clinical contracts, or a literary craft governed by clarity and human readability?

### Wave 4: The Generative Inundation (2023–2026)
And then, the machines arrived.

Large language models shattered the premise that writing syntax is the primary bottleneck of software creation. Suddenly, an LLM could generate a working Rails controller, a React component, or a database migration in 400 milliseconds.

DHH and Uncle Bob responded to the AI wave in characteristic fashion:
*   **DHH's Take on AI:** Pragmatic, anti-hype, yet integrated. He praised LLMs for exploratory boilerplate and built AI features into 37signals products (like HEY), but mocked the Silicon Valley theology that humans would stop writing code. For David, writing code is thinking; handing your thinking to an oracle is intellectual abdication.
*   **Uncle Bob's Take on AI:** Analytical, formal, and dismissive of the replacement myth. Bob argued that AI cannot replace programmers because *programming is the act of specifying requirements at the detail level*. If you use an LLM, you still have to specify what you want, verify what it generated, and take legal and ethical responsibility for the output. As Bob noted: *"You've just moved the programming language up one level of abstraction."*

---

## My Answer: What Craftsmanship Means When Code Is Free

As someone who stood with DHH in 2014, hosted Uncle Bob at SCMC in 2011, signed the SCM ledger at #106 in 2009, and operates an agentic, local-first LLM development platform in 2026 (*zdots*), here is my answer to the controversy:

### 1. DHH Is Right: Software Is Writing, Not Manufacturing
DHH's insight has never been more relevant. If software is writing, then **an LLM is an autocomplete with a thesaurus**. 

Anyone who has used ChatGPT or Claude to write essays knows what happens without strong human editing: you get fluent, bloated, generic prose that says very little with an enormous number of words. The same thing happens with AI-generated code. Left to itself, an LLM will invent speculative classes, introduce unnecessary dependencies, duplicate abstractions, and generate synthetic bloat.

In the AI era, **the programmer's role shifts from typist to editor**. Editing is harder than typing. It requires taste, brevity, and the courage to delete. (As Kevin's Law reminds us: *"Why waste time, say lot word when few word do trick?"*).

### 2. Uncle Bob Is Right: Stewardship Cannot Be Delegated
Uncle Bob's demand for professional rigor is the only thing standing between the industry and an avalanche of catastrophic failure.

An LLM has no skin in the game. It does not go on call at 3:00 AM when a race condition corrupts an account balance. It does not face regulatory auditors when PHI leaks into a telemetry pipe. It does not care if an architecture rots.

If you accept code from an AI agent without understanding its lateral dependencies, failure modes, and test contracts, you are not practicing software development; you are laundering technical debt. The craftsman's vow, to take responsibility for the system, becomes *more* critical when code generation is effortless.

### 3. The New Synthesis: System Cartography & Legible Rules
When I returned to SCMC on September 15, 2026 to present [_Phalanx Duel: Make the Rules Legible_](/phalanx-duel/), I was demonstrating what software development must look like in the age of intelligent agents.

In *Phalanx Duel*, the card game rules are deterministic, visible, and traceably verified. Every state transition has an explanation; every outcome has evidence.

That is the future of Software Craftsmanship:
*   **Not typing every character by hand**, but **governing the boundaries**.
*   **System Cartography:** Understanding the 4D topology of your data models, service boundaries, and state machines so clearly that you can guide an AI agent to execute precise, bounded surgery.
*   **The Blink Test:** Refusing to trust any code, human or synthetic, until it has proven itself green, red, and green again under rigorous regression checks.
*   **Deterministic Restraint:** Applying the Ponytail Principle to refuse speculative abstractions, whether dreamed up by an over-eager engineer or hallucinated by a 70B parameter model.

---

## The Book Ahead

The controversy between DHH and Uncle Bob was never a petty dispute about syntax. It was a 15-year argument over the soul of the developer: **Are we factory workers executing tickets, literary writers crafting text, or licensed engineers building bridges?**

The answer is that we are **custodians of living systems**.

The 184 interviews in the UGtastic archive, the 17 years of monthly meetings at SCMC, and the 27,601 signatures in the DuckDB datalake are not museum pieces. They are the field manual for how human developers maintain their agency, their culture, and their standards in a world where machines can write everything except meaning.

That is the story I am documenting. That is the book that needs to be written.

---

### Primary Source References on `just3ws.localhost`

*   **DHH RailsConf 2014 Interview:** [`/interviews/david-heinemeier-hansson-dhh-railsconf-2014/`](/interviews/david-heinemeier-hansson-dhh-railsconf-2014/)
*   **Uncle Bob SCNA 2012 Interview:** [`/interviews/robert-martin-software-craftsmanship-north-america-2012/`](/interviews/robert-martin-software-craftsmanship-north-america-2012/)
*   **Uncle Bob SCMC Keynote (2011):** *The A Word: Architecture* ([`vimeo-30083598`](/scmc/))
*   **Living History of Software Craftsmanship (2009–2026):** [`/reports/software-craftsmanship-forensics/living-history/`](/reports/software-craftsmanship-forensics/living-history/)
*   **The Manifesto Intersection Cartography:** [`/reports/software-craftsmanship-forensics/agile-manifesto-intersection/`](/reports/software-craftsmanship-forensics/agile-manifesto-intersection/)
*   **The SCMC Dedicated Archive:** [`/scmc/`](/scmc/)
