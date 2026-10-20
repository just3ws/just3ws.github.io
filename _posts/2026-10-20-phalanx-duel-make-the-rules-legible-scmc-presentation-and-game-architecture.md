---
layout: post
title: "Phalanx Duel: Make the Rules Legible (SCMC Presentation, Tabletop Rules & Quiet Architecture)"
date: 2026-10-20 12:00:00 -0500
permalink: /2026/10/20/phalanx-duel-make-the-rules-legible-scmc-presentation-and-game-architecture.html
redirect_from:
  - /ai/2026/10/20/phalanx-duel-make-the-rules-legible-scmc-presentation-and-game-architecture/
  - /2026/10/20/phalanx-duel-make-the-rules-legible-scmc-presentation-and-game-architecture/
  - /phalanx-duel/presentation/
ai_generated: false
human_led: true
source_kind: organic-practitioner-essay
robots: index,follow
sitemap: true
categories: [architecture, craftsmanship, games]
tags: [phalanx-duel, scmc, state-machines, typescript, ruby, game-architecture, psychological-safety]
description: "How a rainy week designing a tactical card game at Boy Scout Camp Tesomas evolved into a deterministic multiplayer engine, an SCMC presentation, and a masterclass in quiet, safe systems architecture."
---

In July 2022, during a steady, soaking rain at Boy Scout Camp Tesomas in northern Wisconsin, I sat at a wooden picnic table with two standard 52-card decks, a pen, and a notebook.

The camp schedule had paused under the downpour. While water ran off the corrugated pavilion roof, I wanted to solve a specific game design puzzle: could you build a deep, tactical two-player card duel using only two everyday decks of cards, with zero dice rolls and no mid-game shuffle?

Every outcome had to follow strictly from the cards visible on the table and the choices each player made. If an attack succeeded, you could trace exactly why. If a column fell, you could see the math. The rules had to be simple enough for two scouts to understand on a damp bench, yet mathematically sound enough to run identically in software.

That rainy afternoon experiment became **Phalanx Duel**.

Over the next four years, it grew from cards on a picnic table into an executable Ruby combat prototype, then into a server-authoritative TypeScript engine, a native Go command-line client, an automated container release pipeline, and a live production platform at [phalanxduel.com](https://phalanxduel.com).

Along the way, it became something more than a game: it became an architecture laboratory. And when I began preparing the broadcast workflows, teleprompter rundowns, and streaming infrastructure for *The Sound Above*, Phalanx Duel was the working product, and Software Craftsmanship McHenry County (SCMC) was the community room where I proved the presentation system could work.

---

### Prototyping in Ruby: Making the Rules Executable

Every software craftsman knows the gap between a design in your head and running software. Tabletop game rules suffer from the exact same challenge: edge cases hide behind ambiguous English phrasing.

To test the physical rules, I wrote a prototype in Ruby. The model was straightforward:
- Each player controls an eight-card formation arranged in two ranks across four columns.
- The front rank serves as the vanguard, taking the brunt of attacks and striking opposing columns.
- The back rank serves as the flank, reinforcing the line and absorbing overflow damage.
- When an attack strikes a column, damage must chew through the vanguard and flank before a single point can reach the player's Life Points.

Suits determine how damage behaves. Diamonds absorb shock and reduce carryover between cards. Hearts shield remaining Life Points. Clubs double eligible overflow. Spades double whatever damage reaches the player's core.

Writing the combat prototype in Ruby exposed rule ambiguities within hours. What happens when a column collapses mid-attack? Who decides reinforcement timing? By writing executable specifications, the rules stopped being an informal tabletop argument and became a legible contract.

```ruby
# Ruby prototype seam: verifying column damage carryover
def resolve_attack(attacker_card, defender_column)
  damage = attacker_card.value
  defender_column.cards.each do |target|
    break if damage <= 0
    absorbed = [damage, target.defense_value].min
    target.damage += absorbed
    damage -= absorbed
    apply_suit_modifiers(target, damage)
  end
  damage # Remainder reaches Life Points
end
```

The prototype proved the rules worked. But taking those rules into a networked multiplayer environment required a complete shift in systems thinking.

---

### The Architecture Laboratory: Server Authority and the Meaning of a Move

When engineering multiplayer systems, the most dangerous mistake is trusting the client to resolve state.

In early 2023, I rebuilt Phalanx Duel from the ground up as a server-authoritative TypeScript monorepo. In this architecture, clients never dictate what happens. A client merely expresses **intent**: *"Player 1 wants to attack column 3 with card 8 of Spades."*

```mermaid
sequenceDiagram
    participant P as Player Client
    participant S as Authoritative Server
    participant E as Rules Engine
    participant L as Immutable Ledger
    P->>S: Send Move Intent (WebSocket)
    S->>E: Validate Intent Against Current State
    alt Legal Transition
        E-->>S: Next Deterministic State
        S->>L: Append Transition & Cryptographic Hash
        S-->>P: Broadcast Role-Safe Projection
    else Invalid Intent
        E-->>S: Reject Transition (Rule Violation)
        S-->>P: Return Action Error
    end
```

The server receives that intent over WebSockets, passes it to a pure, isolated TypeScript engine package, validates it against the current match state, and computes the next state. If the move is illegal, the engine rejects it with a specific rule identifier. If legal, the server records the transition in an append-only ledger and broadcasts a **role-safe projection** to each participant:
- Player 1 receives their hand and visible table cards.
- Player 2 receives their hand and visible table cards.
- Spectators receive a time-delayed view with hidden information masked.

The client is just a dumb terminal rendering a projection. The server and the engine are the sole arbiters of reality.

---

### The Presentation Question: Can I Build a Presentation for this System?

In late summer 2026, as I designed the multi-camera OBS broadcast studio and teleprompter workflow for *The Sound Above*, I confronted a practical question:

*Can I build a presentation for this system?*

Could the structured dossier manifests, the 6-act teleprompter scripts, the OpenTelemetry spans, and the live demonstration overlays hold together in front of real software practitioners?

I needed a place to test the entire apparatus: the spoken cadence, the visual evidence, the technical slides, and the live terminal demos. Software Craftsmanship McHenry County was the natural home.

On September 15, 2026, I walked into SCMC and delivered **Phalanx Duel: Make the Rules Legible**.

```mermaid
flowchart TD
    A["Tabletop Game (July 2022)"] --> B["Ruby Prototype (Executable Rules)"]
    B --> C["TypeScript Engine (Server Authority)"]
    C --> D["SCMC Presentation (September 2026)"]
    D --> E["OBS Broadcast Pipeline (The Sound Above)"]
    E --> F["Quiet Enterprise Architecture"]
    classDef step fill:#f8fafc,stroke:#0f766e,color:#0f172a,stroke-width:1.5px;
    class A,B,C,D,E,F step;
```

We walked through the journey:
1. **The physical cards**: Demonstrating the two-page quickstart guide.
2. **The state machine**: Tracing how turns move from deployment to combat, cleanup, reinforcement, and draw.
3. **Replay verification**: Demonstrating how every completed match generates a cryptographic fingerprint that allows any match to be replayed tick by tick.
4. **OpenTelemetry instrumentation**: Inspecting distributed spans across WebSocket disconnects and reconnects.
5. **The Model Context Protocol (MCP)**: Showing how AI agents can connect to the engine as players or analysts through an explicit, bounded tool interface.

The presentation worked because Phalanx Duel was real. It was not a slide deck about hypothetical microservices. It was a tangible game running in production that everyone in the room could touch, inspect, and understand.

---

### Zarathustra's Child: Safe Not Scary, Competence is Quiet

Reflecting on Phalanx Duel and SCMC helped clarify something much deeper about software engineering and technical leadership:

**Competence is quiet. Safe is better than scary.**

In Friedrich Nietzsche's *Thus Spoke Zarathustra*, the philosopher describes the three metamorphoses of the spirit:
1. **The Camel**: The beast of burden that carries heavy loads, masters the existing rules, and trudges across the dry desert.
2. **The Lion**: The rebel who battles the great dragon called "Thou Shalt." The Lion says "I will not!" and fights for autonomy, tearing down false idols and breaking bad patterns.
3. **The Child**: A new beginning, a game, a wheel rolling out of itself, a first movement, a sacred "Yes."

Many experienced engineers get stuck in the Lion phase. After seeing bad architectures, broken migrations, and enterprise dysfunction, they become fierce critics. They adopt the intense vocabulary of combat: *auditing, war rooms, forensics, quarantines, fatal flaws, uncompromising truth*.

To the engineer, that intensity feels like vigilance and integrity. But to teammates, engineering managers, and product partners, it can be intimidating and frightening. It raises the temperature in the room. People start to worry: *Will this person judge my code? Will they turn every pull request into an ideological battle? Will they make our team feel unsafe?*

Tabletop games remind us of the Child's voice:
- A game is an invitation to play, to explore, and to collaborate.
- You sit across from someone not to conquer them, but to share a common space governed by clear, fair agreements.
- When an engineer approaches a legacy system with the curiosity of a child, the fear disappears. Instead of declaring "this code is slop," the quiet engineer asks: *"What is this system trying to do? Isn't this interesting? How can we make this safe and simple together?"*

Google's famous Project Aristotle study revealed that psychological safety: the shared belief that a team is safe for interpersonal risk-taking: is the single highest predictor of engineering performance.

True Staff+ leadership is not about showcasing how much you know or how intense your standards are. It is about **lowering the collective anxiety of the team**. It is about making production changes so predictable, observable, and reversible that developers look forward to deploying.

---

### Deterministic Boundaries in the Age of AI

This mindset directly informs how we must approach generative AI and autonomous developer agents.

When language models generate fluent code, it is tempting to treat them as authoritative. But fluent text is not verified truth. An LLM cannot be trusted with authoritative business logic or state transitions because it operates in probabilistic approximations.

Phalanx Duel demonstrates the clean boundary:
- The **engine** is deterministic, immutable, and strictly validated.
- The **model** is an external agent interacting with the engine through an explicit MCP tool schema.
- The model can suggest moves, evaluate tactics, or query game state, but it can never bypass the server's rules validation.

```mermaid
flowchart LR
    subgraph NonDeterministic ["Probabilistic Space"]
        LLM["Generative AI Agent / Player"]
    end
    subgraph Boundary ["Strict Protocol Seam"]
        MCP["Model Context Protocol (Tool Contract)"]
    end
    subgraph Deterministic ["Authoritative Engine"]
        SRV["Server State Machine"]
        LED["Immutable Replay Ledger"]
    end
    LLM -->|Suggests Intent| MCP
    MCP -->|Validates Schema| SRV
    SRV -->|Appends Transition| LED
    SRV -.->|Role-Safe State| LLM
```

By keeping the rules legible and the engine authoritative, the AI becomes a creative participant rather than an operational hazard.

---

### The Takeaway for Enterprise Engineering

The lessons of Phalanx Duel are the exact lessons that allow engineering organizations to modernize high-stakes legacy platforms:
1. **Make the rules legible**: If a business workflow cannot be explained on paper, it cannot be safely automated in software.
2. **Server authority is non-negotiable**: Never trust the caller to maintain system invariants.
3. **Replayability is trust**: When every state transition can be deterministically replayed and audited, fear vanishes from production.
4. **Cultivate the child's voice**: Approach difficult legacy systems with curiosity, playfulness, and generosity. Make working with you a safe, empowering experience where the whole team wins together.

Phalanx Duel started at a soggy camp table. It helped build the broadcast studio for *The Sound Above*. And it stands as a permanent reminder that the highest expression of engineering craftsmanship is not complexity or intensity: it is quiet, legible simplicity that keeps everyone safe.

---

*Presentation materials, the two-page quickstart PDF, and the editable slide deck are available at [just3ws.com/phalanx-duel/](/phalanx-duel/). Play a live match at [phalanxduel.com](https://phalanxduel.com).*
