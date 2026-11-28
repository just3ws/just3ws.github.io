---
marp: true
theme: default
paginate: true
backgroundColor: "#faf8f5"
color: "#1e232a"
style: |
  section {
    font-family: "Inter", system-ui, -apple-system, sans-serif;
    border-top: 6px solid #0f766e;
  }
  h1, h2 {
    color: #0f172a;
  }
  h1 {
    border-bottom: 3px solid #0f766e;
    padding-bottom: 0.25em;
  }
  strong {
    color: #0f766e;
  }
  blockquote {
    background: #f4f0e8;
    border-left: 5px solid #b45309;
    padding: 0.75em 1em;
    color: #1e232a;
  }
  code {
    background: #f4f0e8;
    color: #0f766e;
  }
---

# Phalanx Duel: Make the Rules Legible

### Software Craftsmanship McHenry County (SCMC)

Mike Hall · Staff Software Engineer · `just3ws.com` · `phalanxduel.com`

---

## Why Build a Zero-RNG Tactical Card Game?

- Born on a rainy afternoon at Camp Tesomas (July 2022) with **two standard 52-card decks** and a notebook.
- **Zero dice, zero mid-game reshuffles.** Every outcome is a pure function of visible cards and player intent.
- **Core engineering invariant:** What two humans can verify by hand at a table is *identical* to what the server enforces on every turn.

---

## The 2×4 Formation & Symmetric Fog of War

- Each player deploys **4 front-rank vanguard** slots and **4 back-rank flank** slots.
- Cards on the battlefield are public; hands and draw piles stay hidden and **server-redacted**.
- No hidden state leaks to the client. Spectators and players only receive role-safe projections.

---

## Deterministic Combat Cascade

1. Front-rank attacker strikes an opposing column.
2. **Front Vanguard** absorbs initial damage.
3. Destroyed cards pass overflow down the column:
   - **Diamonds (♦):** Reduce carryover between cards.
   - **Clubs (♣):** Double one eligible overflow.
   - **Hearts (♥):** Shield final carryover before Life Points.
   - **Spades (♠):** Double damage reaching Life Points (`20 LP -> 0 LP`).

---

## From Tabletop Rules to Production Architecture

- **Pure TypeScript Rules Engine:** Deterministic state transitions with zero side effects.
- **Server-Authoritative Multiplayer:** Web client, native Go CLI (`duel-cli`), and Glicko-2 ranked ladder.
- **Hash-Chained Replays:** Every match produces a verifiable, scrubbable cryptographic event log.

> When the domain model is legible enough for cardboard, the software stays testable, explainable, and calm under change.

---

## Play, Read, and Inspect the System

- **Play live:** `https://phalanxduel.com`
- **5-Part Engineering Series:** `https://www.just3ws.com/2026/11/26/phalanx-duel-series-part-1-the-game-and-concepts.html`
- **33-Episode Video Curriculum:** `@just3ws-mike` on YouTube
