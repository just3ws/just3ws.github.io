---
layout: post
title: "The Chicago Workshop: Why Software Craftsmanship Happened in the City of Broad Shoulders"
date: 2026-10-02
description: "Why Chicago? Tracing the collision of Carl Sandburg's industrial heritage, 37signals' calm rebellion, the Metra commuter geometry, and the pursuit of practical engineering autonomy in enterprise .NET that shaped the Software Craftsmanship movement."
permalink: /ai/2026/10/02/the-chicago-crucible-why-craftsmanship-happened-here/
ai_generated: true
human_led: true
source_kind: ai-augmented-human-led
robots: noindex,follow
sitemap: false
tags:
  - Software Craftsmanship
  - Chicago
  - ChicagoRuby
  - Alt.NET
  - SCMC
  - SCNA
  - 8th Light
  - Obtiva
  - 37signals
  - UGtastic
---

_Editorial note: Mike Hall supplied the primary recollections, community context, oral history archives, and cultural framing for this essay. The events, meetings, and interviews described are grounded in the lived archives on just3ws.localhost._

---

Silicon Valley had the venture capital. Seattle had the operating systems. Boston had the academic research labs. Austin had the semiconductors. New York had the media agencies.

None of them gave birth to the **Software Craftsmanship Movement**.

It happened in Chicago, and in the suburban satellite towns strung along the heavy commuter rail lines: Libertyville, Crystal Lake, McHenry, and Evanston.

To understand why, you have to look past the superficial conference schedules and examine the collision between industrial history, blue-collar pride, enterprise friction, and dynamic language experimentation that took root in Midwestern soil.

```mermaid
flowchart TD
    A["Hog Butcher, Tool Maker, Stacker of Wheat<br>(Industrial / Freight / Trading Pit Mindset)"] --> C["The Friction Engine: .NET Monoliths vs. Dynamic Ruby"]
    B["37signals & Rails (2004, West Randolph Meatpackers)<br>(Anti-VC, Calm, Sustainable Software Ethos)"] --> C
    
    C --> D["Practical Autonomy in Enterprise .NET<br>(Alt.NET on Sears 50th Fl • WatiN/WatiR at TicketsNow)"]
    
    D --> E["The Apprenticeship Guilds<br>(8th Light Pair Friday • Obtiva Geekfest • Craftsman Swap)"]
    D --> F["The Metra Geometry<br>(90-min offline train hacking • Suburban refusal of city monopoly)"]
    
    E --> G["The Catalyst: 2009 'Too Practical' Conference Rejection"]
    F --> G
    
    G --> H["The Movement: SCNA Founded • SCM Signed (#106) • SCMC at Follett • UGtastic Rolls Tape"]
```

---

## 1. Carl Sandburg’s Ghost: Tool Makers, Not Pitch-Deck Flippers

In Silicon Valley, software by 2007 was already dominated by the **"flip."** Build an audience, burn angel money, move fast and break things, get acquired by Google or Yahoo, cash out, repeat. The code was treated as disposable wrapping paper around user acquisition metrics.

Chicago doesn't have a disposable culture. It is Carl Sandburg’s city:

> _"Hog Butcher for the World, Tool Maker, Stacker of Wheat, Player with Railroads and the Nation's Freight Handler; Stormy, husky, brawling, City of the Big Shoulders."_

Chicago software did not live in the ethereal realm of social feeds; it lived in the **physical and financial machinery of the continent**:
* It ran the options and futures pits at the Chicago Board of Trade (CBOT) and Chicago Mercantile Exchange (CME).
* It ran supply chains and inventory logistics for Sears, Walgreens, Abbott Laboratories, and United Airlines.
* It ran real-time ticketing platforms where a database race condition meant double-selling a row at Soldier Field ([TicketsNow](/ai/2026/09/02/the-skunkworks-lab-real-time-inventory/)).

If code broke in Chicago, trains stopped in Cicero, freight sat stranded on rail sidings, options contracts expired worthless, and millions of dollars evaporated in microseconds. You didn't build software to throw it away; you built it like a union ironworker riveted a bridge across the Chicago River. **Workmanship was a moral and economic obligation.**

---

## 2. The 37signals Gravity Well & The West Randolph Meatpackers

In 2003 to 2004, David Heinemeier Hansson and Jason Fried built Basecamp on West Randolph Street. At that time, the West Loop was not Michelin-starred tasting rooms; it was literal wholesale meatpackers and cold-storage warehouses where forklifts rattled across cobblestones at 5:00 AM.

Out of that gritty room came **Ruby on Rails**.

Crucially, 37signals preached an unapologetic gospel that acted as a cultural shield across Chicagoland:
* **No Venture Capital:** Taking VC money was a drug that turned developers into metric-farming cattle for institutional investors.
* **Calm Software:** Small teams, readable prose, high aesthetic standards, and sustainable customer-funded revenue.
* **Software as Writing:** Code was literature to be read by humans, not opaque binary slurry for compilers.

This established a cultural counterweight against Silicon Valley FOMO. Midwest developers had living proof that you did not have to grovel on Sand Hill Road. You could stay in the Midwest, write elegant code, charge real money for value delivered, and go home to your family at 5:30 PM.

---

## 3. The Friction Engine: Practical Autonomy in Enterprise .NET

This is the great unwritten truth of the movement: **If Chicago had been a pure Ruby monoculture from day one, Software Craftsmanship would never have existed.**

Craftsmanship was forged by **friction**. Chicago was a major Microsoft/.NET and Java enterprise hub:
* Developers spent their working hours inside Visual Studio, working with SOAP envelopes, BizTalk schemas, heavy XML configuration blocks, and Microsoft Enterprise Library wrappers.
* Management often adopted "Agile" as a bureaucratic reporting cadence: daily standups where project managers demanded hourly burndown estimates, while automated testing, refactoring, and code reviews were treated as "unbillable overhead."

When enterprise .NET developers like Sergio Pereira ([Chicago Alt.NET](/interviews/sergio-pereira-chicago-alt-net-software-craftsmanship-north-america-2011/)) or Mike Hall at TicketsNow encountered open-source .NET tools and Ruby (via [WatiN/WatiR](/timeline/community/), NUnit, NHibernate, StructureMap, and Cucumber), it was not a trendy lifestyle choice. **It was a search for practical engineering autonomy.**

They realized:
> _"I can test an entire domain model in 3 seconds without spinning up IIS or waiting 15 minutes for a compile? How do we bring this feedback loop into our daily work?"_

Chicago Alt.NET created a peer learning workshop inside the enterprise ecosystem. When they met at Redpoint Technologies on the 50th floor of the Sears Tower, they were not just talking about syntax; they were demonstrating how to bring TDD, BDD, dependency injection, and NHibernate into corporate .NET shops through working code.

---

## 4. The Guilds: Obtiva, 8th Light, and the "Craftsman Swap"

Silicon Valley built tech campuses with ping-pong tables and free dry cleaning to keep developers at their desks 16 hours a day.

Chicago built **Guilds**.

Firms like **Obtiva** (Dave Hoover, Kevin Taylor) and **8th Light** (Micah Martin, Robert "Uncle Bob" Martin, Doug Bradbury, Paul Pagel) explicitly resurrected medieval craft terminology:
* You were not hired as a "Junior Developer." You became an **Apprentice**.
* You studied under a **Journeyman** or **Master Craftsman**.
* You practiced deliberate katas: the Bowling Game, Prime Factors, Roman Numerals.
* At Obtiva, Dave Hoover launched **Geekfest** in 2007 around sandwiches from Jimmy John's, studying draft manuscripts of Martin Fowler's refactoring books.
* At 8th Light in Libertyville, Micah Martin ran **Pair Friday** (which later grew into **8th Light University / 8LU**), opening their office doors to anyone with a laptop to sit side-by-side with craftsmen and write open-source code.

And in what other city on earth would competing commercial consulting firms initiate the **"Craftsman Swap"**? 8th Light and Obtiva literally traded developers between their offices to cross-pollinate TDD habits, Vim configurations, and pairing styles, because raising the standard of the entire regional talent pool mattered more than hoarding proprietary secrets.

---

## 5. Metra Geometry: The Radial Commute and the Suburban Workshop

Look at a transit map of northeastern Illinois. It is not a campus grid. It is a radial starburst of heavy commuter rail (Metra lines) running 50 to 60 miles outward into the prairie:
* **Union Pacific Northwest (UP-NW):** Crystal Lake, McHenry, Woodstock.
* **Milwaukee District North (MD-N):** Libertyville, Deerfield.
* **Union Pacific North (UP-N):** Evanston.

This geographic reality forced two cultural behaviors:
1. **The 90-Minute Offline Hacking Session:** Developers sat on the bilevel commuter train twice a day. In 2008, there were no reliable mobile hotspots. You opened your laptop, booted Vim, and ran unit tests completely offline against local code. You read technical monographs. It bred radical self-reliance.
2. **The Refusal of Urban Monopolies:** Engineers in Crystal Lake, McHenry, or Libertyville had families, backyards, and mortgages. They asked a practical question:
   > _"Why do I have to ride a train for two hours into the Loop to talk to people who care about good code?"_

That refusal is why **8th Light set up shop in Libertyville**. It is why Mike Hall and Ryan Gerry launched **CDG (Cloud Developers Group)** in McHenry County libraries, Panera Bread, and Duke's Alehouse after meeting at an SCNA table in October 2009, and why Mike Hall, Ryan Gerry, and Jim Suchy co-founded **SCMC (Software Craftsmanship McHenry County)** in 2010 at Follett Software Company in McHenry, with Ryan continuing to run the group for over 15 years after Mike stepped away after the two-year anniversary. The suburbs were not a passive bedroom community; they were the engine rooms where practitioners lived and built.

---

## 6. The "Too Practical" Insult: The Spark That Lit SCNA

The movement went from local meetups to a global manifesto because of a singular, unforgettable rejection.

In 2009, local Chicago practitioners submitted talk proposals to mainstream enterprise conferences (including the upcoming Agile 2010 conference scheduled for downtown Chicago).

The conference review committees sent back rejection notices with feedback that became legendary:
> _"Your talks are too practical. Showing live pairing, TDD refactoring, and code katas on stage is too tactical for an executive engineering conference."_

In the Midwest, telling an engineer their work is **"too practical"** is like telling a carpenter that knowing how to hammer a nail is beneath them. It crystallized everything that had gone wrong with commercial Agile: it had drifted toward certification tracks and project management rituals detached from working code.

The response was immediate and constructive:
* **"If you won't give practical code a stage, we will build our own stage."**
* 8th Light and Obtiva teamed up to launch **Software Craftsmanship North America (SCNA 2009)**. Slides-only talks were deprioritized; live pairing, terminal execution, and architectural debate took center stage.
* The **Software Craftsmanship Manifesto** was drafted in Libertyville and published on March 6, 2009, declaring: _Not only working software, but well-crafted software._

---

## 7. What's Missing from the Standard Lore? The Pastiche

The conference history books often focus on the keynote speakers: Uncle Bob Martin, Gary Bernhardt, Corey Haines, Michael Feathers.

Equally important was the **pastiche**, the connective tissue of organizers and practitioners that made the rooms possible:
* **Ray Hightower ([ChicagoRuby](/interviews/ray-hightower-chicagoruby-software-craftsmanship-north-america-2011/)):** The indispensable ambassador who met .NET developers at suburban diners, showed them Cucumber, and welcomed newcomers into the community.
* **Sergio Pereira ([Chicago Alt.NET](/interviews/sergio-pereira-chicago-alt-net-software-craftsmanship-north-america-2011/)):** Who gave Mike Hall his first audience on the 50th floor of the Sears Tower, showing that community curation was about encouraging members to step up and speak.
* **Charley Baker ([Watir](/interviews/charler-baker-denver-community-software-craftsmanship-north-america-2011/)):** Who proved that testing automation was not a QA afterthought, but a core developer discipline.
* **The Zero-Dollar Infrastructure:** Running **Chicago Code Camp** for 500 people with custom blind-review CFP software; building **UGl.st** to index independent regional meetups.
* **UGtastic Itself:** The roving camera that captured 184 oral histories so these practitioner conversations would endure.
* **Ryan Gerry & Jim Suchy ([SCMC](/scmc/)):** Co-founding SCMC with Mike Hall at Follett in McHenry in 2010, with Ryan keeping the projector running and the monthly room open for 17 continuous years after Mike stepped away following the two-year anniversary.

---

## The Lesson for the Age of AI

Why does this matter in 2026?

Because we have entered the fourth wave. Generative AI and LLMs now produce boilerplate code instantly. The commercial tech industry is once again tempted by "fast, disposable, unexamined" software, the exact same trap that commercial Agile fell into twenty years ago.

The lesson of Chicago in 2009 was that **the code is not disposable**. When generation is cheap, the value shifts to the **editor-craftsman**: the practitioner who understands systemic constraints, verifies deterministic state, preserves institutional memory, and takes personal responsibility for the systems that run in production.

That discipline was honed in Chicago. Rewatching Sergio Pereira is not nostalgia; it is picking up the tools of the craft to build the next twenty years.

---

### Connected Records & Further Exploration
* **Interactive Timeline:** [The Community Pastiche Timeline](/timeline/community/)
* **Series Episode 1:** [Sergio Pereira Interview Verbatim Transcript & Video Stage](/interviews/sergio-pereira-chicago-alt-net-software-craftsmanship-north-america-2011/)
* **Foundational Monograph:** [The Chicago Software Craftsmanship Movement (2006 to 2015)](/chicago-craftsmanship/)
* **Community Hub:** [Software Craftsmanship McHenry County (17-Year Canon)](/scmc/)
* **Forensic Audit:** [Signatory Ledger Forensics](/reports/software-craftsmanship-forensics/)
* **Philosophical Essay:** [The Four Waves of Craft: DHH, Uncle Bob, and Writing Software in the Age of AI](/ai/2026/10/02/the-four-waves-of-craft-dhh-uncle-bob-ai/)
