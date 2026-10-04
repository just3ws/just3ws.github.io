# The Sound Above: UGtastic Oral History Rewatch Series

## Executive Overview and Master Curation Guide

Curated and hosted by Mike Hall (Software Craftsmanship Signatory #106, SCMC Co-Founder, UGtastic Host).

This curation guide provides the complete thematic sequencing, historical context, discussion prompts, and technical production notes for livestreaming the UGtastic oral history rewatch series.

---

## The Core Philosophy: "The Sound Above"

In January 2025, Mike Hall authored the foundational essay titled "The Sound Above: Bridging Inspiration and Understanding in Tech":

> "The sound above represents the echoes of ideas, inspirations, and cultural touchstones that have shaped an industry or a mindset. It is the legacy carried forward by those who came before, forming an unspoken language and shared context among those who lived through it... If we want the next generation to care about the sound above, to find inspiration in the values and stories that shaped us, we must first help them thrive. Only then can we inspire them to look up, to hear the echoes of the past and add their own notes to the sound of the future."

When listening to great musicians, jazz players, or painters, we often ask: who inspired them before they became household names? What records were playing in their apartments when they were teenagers? Who was their teacher before they stepped onto the main stage?

In software engineering, the same truth applies. The industry is currently undergoing a massive transformation with the arrival of large language models, agentic workflows, and automated code generation. As we navigate questions about the identity and future of software development, the grassroots lessons from the Software Craftsmanship era (2005–2015) have never been more urgent.

The Software Craftsmanship movement became global, but its deepest roots are planted firmly in Chicago:
- The 2008 Libertyville Summit that drafted the Software Craftsmanship Manifesto
- Mike Hall signing the Manifesto as Signatory #106 on March 6, 2009
- The founding of Software Craftsmanship McHenry County (SCMC) in spring 2009
- The emergence of 8th Light, Obtiva, Chicago Alt.NET, and ChicagoRuby
- Over 200 video interviews recorded under the UGtastic banner at conferences including SCNA, RailsConf, GOTO Chicago, and regional user groups

This rewatch series is not passive nostalgia. It is an active forensic investigation:
1. What were we actually doing in this space when the cameras rolled?
2. What were the unspoken connections between practitioners?
3. Who inspired the interviewees before they wrote the books and keynoted the conferences?
4. How do these exact lessons on deliberate practice, feedback loops, modular design, and professional stewardship guide our craft as we orchestrate autonomous AI agents today?

---

## Why Rework the Sequence?

The original UGtastic videos were recorded opportunisticly in conference hallways, hotel lobbies, and meetup backrooms between 2010 and 2015. They were published across Vimeo, Tumblr, and early video platforms in the order they were edited, not in a coherent narrative arc.

This curation reworks the archive into five cohesive thematic movements:
1. **Movement 1: The Chicago Crucible (2005–2010)**: The pre-manifesto rooms, breaking out of corporate Microsoft monoliths, and founding grassroots communities.
2. **Movement 2: The Practice and the Dojo (2010–2012)**: Deliberate practice, code katas, browser automation roots, and the pursuit of sub-second feedback loops.
3. **Movement 3: The Philosophy and Deliberate Discovery (2012–2014)**: BDD, humility, unlearning dogma, team sociology, and the true cost of change.
4. **Movement 4: The Architecture and Testing Reckoning (2014–2016)**: The "TDD is Dead" corridor debates, open work verification, and the shift from monolithic frameworks to distributed boundaries.
5. **Movement 5: The AI Horizon and The Observable Control Plane (2026)**: Applying seventeen years of craftsmanship disciplines to multi-agent fleets, sovereign inference, and deterministic system cartography.

---

## The Five Curated Movements

### Movement 1: The Chicago Crucible (2005–2010)

The origin story of the Chicago tech renaissance and grassroots software craftsmanship.

#### Episode 01: Sergio Pereira: The First Room and Escaping Monoliths
- **Interviewee**: Sergio Pereira (Founder, Chicago Alt.NET)
- **Conference / Date**: SCNA 2011 (Chicago, IL)
- **Archive Route**: `/interviews/` (Slug: `sergio-pereira-chicago-alt-net-software-craftsmanship-north-america-2011`)
- **The Sound Above Inquiry**: Who inspired the early .NET practitioners to break out of Microsoft corporate orthodoxy? What made Alt.NET a sanctuary for test-driven developers?
- **Chicago Context**: Chicago Alt.NET was the incubator where practitioners shared WatiN, Castle Windsor, and NHibernate while corporate enterprise shops resisted open source.
- **AI Era Parallel**: Questioning monolithic AI platforms. Moving from vendor lock-in to open, legible local architectures.
- **Companion Reading**: `_data/community_timeline.yml` (Episode 1 Spotlight).

#### Episode 02: Ray Hightower: The Ambassador of Grassroots Hospitality
- **Interviewee**: Ray Hightower (Founder, ChicagoRuby)
- **Conference / Date**: SCNA 2011 (Chicago, IL)
- **The Sound Above Inquiry**: What inspired Ray's philosophy of radical hospitality? How did ChicagoRuby sustain twenty years of continuous monthly meetings?
- **Chicago Context**: Ray was the vital bridge connecting corporate IT executives with grassroots open-source rebels.
- **AI Era Parallel**: In an era of synthetic code, human community stewardship and welcoming mentorship are the rarest assets.

#### Episode 03: Micah Martin and Mike Jansen: Pair Friday and Apprenticeship
- **Interviewee**: Micah Martin and Mike Jansen (8th Light)
- **Conference / Date**: SCNA 2012 / 2013
- **The Sound Above Inquiry**: How did Carl Sagan's cosmic perspective influence 8th Light's company culture? Who taught them the apprenticeship model?
- **Chicago Context**: 8th Light's suburban Libertyville roots and the weekly "Pair Friday" workbench culture.
- **AI Era Parallel**: Pairing with an LLM requires the same clear contracts and cognitive pacing as pairing with a junior apprentice.

#### Episode 04: Dave Hoover: From Psychology to Apprenticeship Patterns
- **Interviewee**: Dave Hoover (Obtiva, Author of Apprenticeship Patterns)
- **Conference / Date**: SCNA 2011
- **The Sound Above Inquiry**: Why did a background in clinical psychology produce one of the best books on software mentorship?
- **Chicago Context**: Dave Hoover's Geekfest events and Obtiva's Chicago apprenticeship program.
- **AI Era Parallel**: Apprenticeship patterns ("Expose Your Ignorance", "Deep Roots") counteract shallow LLM copy-paste habits.

#### Episode 05: Ryan Gerry and Jim Suchy: The 17-Year Continuous Room
- **Interviewee**: Ryan Gerry and Jim Suchy (SCMC Co-Founders)
- **Conference / Date**: GOTO Chicago 2014 / SCMC Retrospectives
- **The Sound Above Inquiry**: How does a zero-dollar suburban user group meet every single month for seventeen straight years?
- **Chicago Context**: SCMC #106 founded in Crystal Lake and McHenry County, meeting in Follett Software Company, Panera Bread, and local libraries.
- **AI Era Parallel**: Psychological safety to critique new technologies without corporate marketing pressure.
- **Companion Critical Rewatch**: Uncle Bob Martin's 2011 SCMC Keynote (Follett).

---

### Movement 2: The Practice and the Dojo (2010–2012)

Focusing on code katas, deliberate practice, browser automation tools, and the mechanics of testing.

#### Episode 06: Corey Haines: Cranking Design to 11 and Deliberate Practice
- **Interviewee**: Corey Haines (Originator, Global Day of Coderetreat)
- **Conference / Date**: SCNA 2011
- **The Sound Above Inquiry**: Who taught Corey to treat coding like practicing scales on a trumpet? What was the breakthrough that created Conway's Game of Life retreats?
- **Discussion Focus**: The Four Rules of Simple Design (passes tests, reveals intent, no duplication, fewest elements).
- **AI Era Parallel**: Kent Beck's Four Rules are the ultimate validation criteria for evaluating LLM-generated solutions.

#### Episode 07: Charley Baker: The Toolmakers and Browser Automation
- **Interviewee**: Charley Baker (Denver Community Lead, Watir Maintainer)
- **Conference / Date**: SCNA 2011
- **The Sound Above Inquiry**: What inspired the early open-source browser automation contributors before Chrome or Selenium WebDriver existed?
- **Chicago Context**: Early test automation experiments at TicketsNow (Crystal Lake, IL) using WatiN and WatiR.
- **AI Era Parallel**: Modern agentic browser workflows (Playwright, Puppeteer) trace their direct lineage to Watir.

#### Episode 08: Tim Ottinger: Clean Code and Daily Practice
- **Interviewee**: Tim Ottinger (Object Mentor Consultant, Agile in a Flash)
- **Conference / Date**: SCNA 2011
- **The Sound Above Inquiry**: What was the mentorship lineage inside Object Mentor (Lake Zurich and Gurnee, IL)?
- **AI Era Parallel**: Precise, intention-revealing names reduce cognitive load for both humans and AI tokenizers.

#### Episode 09: Andrea Magnorsky: Game Jams and Functional Cross-Pollination
- **Interviewee**: Andrea Magnorsky (Alt.NET, Global Game Jam)
- **Conference / Date**: SCNA 2012
- **The Sound Above Inquiry**: How did indie game developers bring experimental, joyful coding into serious architectural discussions?
- **AI Era Parallel**: Entity-component architectures and real-time game loops provide superior mental models for multi-agent system telemetry.

#### Episode 10: Gary Bernhardt: The Fast Feedback Loop (Critical Rewatch)
- **Interviewee / Focus**: Gary Bernhardt (Destroy All Software, SCNA Speaker)
- **Source Videos**: "Boundaries" (SCNA 2012) and "WAT" (CodeMash 2012)
- **The Sound Above Inquiry**: Who inspired Gary's pursuit of sub-millisecond feedback loops and radical Unix workbench speed?
- **AI Era Parallel**: AI agent orchestration loops die when tests are slow. Fast, isolated unit tests are mandatory for autonomous agent verification.

---

### Movement 3: The Philosophy and Deliberate Discovery (2012–2014)

Challenging dogma, cultivating humility, understanding team sociology, and calculating the true cost of change.

#### Episode 11: Dan North: Software as Communication and BDD Origins
- **Interviewee**: Dan North (Originator of BDD, Deliberate Discovery)
- **Conference / Date**: SCNA 2013
- **The Sound Above Inquiry**: Why did Dan refuse to trademark or certify BDD? Who inspired his insight that "if you want an idea to travel, you cannot travel with it"?
- **AI Era Parallel**: Deliberate discovery acknowledges that ignorance, not code syntax, is the limiting factor in systems engineering.

#### Episode 12: Dave "pragdave" Thomas: Unlearning Dogma
- **Interviewee**: Dave Thomas (Snowbird 17 Agile Author, The Pragmatic Programmer)
- **Conference / Date**: SCNA 2013
- **The Sound Above Inquiry**: What did the original authors of the Agile Manifesto feel when they watched their ideas turned into corporate certification mills?
- **AI Era Parallel**: The Agile Manifesto was about individuals and interactions over processes and tools; modern AI development must avoid the exact same bureaucratic traps.

#### Episode 13: Hadi Hariri: The Truck Driver's Wisdom
- **Interviewee**: Hadi Hariri (JetBrains)
- **Conference / Date**: SCNA 2012
- **The Sound Above Inquiry**: Why did an experience with military recruits remind Hadi that developers in ivory towers are not more important than the truck driver?
- **AI Era Parallel**: Humility in the face of automated tools: software is a service to human beings, not a monument to engineer vanity.

#### Episode 14: Sarah Mei: The Sociological System and Team Cognition
- **Interviewee**: Sarah Mei (DevChix, RailsConf Keynote)
- **Conference / Date**: RailsConf 2014 / SCNA
- **The Sound Above Inquiry**: Who showed Sarah Mei that code problems are almost always social and communication problems in disguise?
- **AI Era Parallel**: Multi-agent swarms exhibit the exact same sociotechnical breakdown modes as human developer teams.

#### Episode 15: Sandi Metz: Practical Object-Oriented Design (POODR)
- **Interviewee**: Sandi Metz (Author of POODR, GOTO Chicago Speaker)
- **Conference / Date**: GOTO Chicago 2014
- **The Sound Above Inquiry**: What Smalltalk masters inspired Sandi's relentless focus on message passing, duck typing, and small methods?
- **AI Era Parallel**: Small, single-purpose methods with clear boundaries are the single most reliable structure for LLM reasoning and refactoring.
- **Companion Critical Rewatch**: Bret Victor's "Inventing on Principle" (2012) and Rich Hickey's "Simple Made Easy" (2011).

---

### Movement 4: The Architecture and Testing Reckoning (2014–2016)

The seismic shifts in testing philosophy, developer identity, and distributed system boundaries.

#### Episode 16: David Heinemeier Hansson (DHH): The Chicago Corridor Interview
- **Interviewee**: David Heinemeier Hansson (Creator of Ruby on Rails)
- **Conference / Date**: RailsConf 2014 (Chicago, IL)
- **The Sound Above Inquiry**: What was the mood in the hallway immediately following DHH's explosive "TDD is Dead" keynote? Who inspired DHH's philosophy of software as writing?
- **Chicago Context**: Recorded in a quiet hotel corridor during RailsConf 2014 in Chicago.
- **AI Era Parallel**: Contrasting DHH's prose-first aesthetic with Uncle Bob's engineering-first discipline: the two competing mental models for AI-assisted programming.
- **Companion Rewatch**: The Martin Fowler, Kent Beck, and DHH video debate series: "Is TDD Dead?".

#### Episode 17: Matt Deiters: Proof of Work and Developer Identity
- **Interviewee**: Matt Deiters (Founder, Coderwall and Assembly)
- **Conference / Date**: Chicago Tech Scene (2013)
- **The Sound Above Inquiry**: What inspired the earliest experiments to verify developer competence through public code rather than resumes?
- **AI Era Parallel**: In an era where anyone can prompt an AI to write a resume, cryptographic work provenance and verifiable commits are the only ground truth.

#### Episode 18: Jason Cranford Teague: The Transition of Knowledge
- **Interviewee**: Jason Cranford Teague (Tech Author and Speaker)
- **Conference / Date**: WebVisions 2013 (Chicago, IL)
- **The Sound Above Inquiry**: What happened when physical computer book publishing collapsed into web search and documentation wikis?
- **AI Era Parallel**: Moving from search engines to LLM context windows: how do we ensure foundational technical wisdom is preserved and cited?

---

### Movement 5: The AI Horizon and The Observable Control Plane (2026)

Bridging seventeen years of craftsmanship discipline directly into local AI orchestration.

#### Episode 19: The Platform Capstone: Without zdots, There Was Nothing
- **Host Monologue and Demonstration**: Mike Hall
- **Focus**: Presenting the local observable control plane at SCMC 2026.
- **Key Concepts**:
  - Why the machine had to be legible before language models arrived
  - Deterministic contracts, Jaeger traces, and OpenObserve telemetry
  - The Blink Test: Green, Red, Green again before any claim of success is accepted
  - The Schrute Test, Snake in a Can, and Cook Ding's Blade
- **Live Verification**: Showing local OpenTelemetry traces flowing from shell commands and multi-agent coordination.

#### Episode 20: Phalanx Duel: Legible State and Game Architecture
- **Host Demonstration**: Mike Hall
- **Focus**: How building a real-time multiplayer tactical game engine pushed observability, state legibility, and testing to its limit.
- **AI Era Parallel**: Why autonomous agents require deterministic rule engines and explicit state machines to prevent drift and hallucination.

#### Episode 21: The Sound Above Community Roundtable
- **Format**: Live panel with Chicago Craftsmanship veterans and next-generation engineers.
- **Focus**: What is the sound above for the coming decade? How do we build bridges rather than gates?

---

## Live Stream Show Format and Segment Guide

Each rewatch stream is calibrated for a 60 to 90 minute broadcast:

```
[00:00 - 05:00]  Scene 01: Starting Soon
                 Warm music, quote carousel, cued episode metadata.

[05:00 - 15:00]  Scene 02: Monologue / The Frame
                 Mike sets the historical stage:
                 - What year was it?
                 - What was happening in Chicago at that exact moment?
                 - Who was this person to the community?
                 - What was "the sound above" for them?

[15:00 - 45:00]  Scene 03 & 04: The Rewatch & Reaction
                 Playing the archival video from Orion browser:
                 - Listening closely to phrasing and unspoken context
                 - Pausing at inflection points
                 - Switching to Scene 04 (Split Screen) to cross-reference
                   transcripts on just3ws.localhost, signatory records,
                   or historical articles.

[45:00 - 65:00]  Scene 05: The Workbench / The AI Connection
                 Switching to full terminal / code environment:
                 - How does this concept look in real code today?
                 - Running tests or reproducing an architectural pattern
                 - Demonstrating the parallel in multi-agent orchestration
                 - Verifying claims with the Blink Test.

[65:00 - 75:00]  Scene 02 / 06: Community Takeaways & Co-Host Discussion
                 Synthesizing the core lesson:
                 - What do we carry forward?
                 - What dogma should we discard?
                 - Inviting chat comments or co-host reflections.

[75:00 - 80:00]  Scene 08: Outro & Next Stream Preview
                 Closing quote from "The Sound Above" essay, links to
                 the open archive, next episode date.
```

---

## Technical Setup Notes for the Host

1. **Browser Video Playback**:
   - Use Orion (or dedicated clean browser profile) in full 1080p window.
   - ScreenCaptureKit Application Audio capture automatically routes Orion's sound directly into OBS without desktop echo or mic bleed.
2. **Local Archive Cross-Referencing**:
   - Keep `https://just3ws.localhost/timeline/community/` and `https://just3ws.localhost/interviews/` open in a second browser window for instant lookup.
3. **Updating Stream Overlays**:
   - Run `obs/scripts/update-overlay-state.sh --episode N` before each stream. All browser overlays automatically update via JSON polling.
