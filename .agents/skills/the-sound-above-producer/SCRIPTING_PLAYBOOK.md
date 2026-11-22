# The Sound Above: Scripting & Outline Playbook

This playbook defines how to transform deep research into spoken teleprompter scripts (Track A) and conversational deep-dive prompts (Track B) for **The Sound Above** series.

---

## 1. Track A: The 6-Act Broadcast Arc

Every primary episode follows an unvarying 6-act broadcast structure designed for seamless OBS scene transitions:

| Act | Scene Target | Format | Approximate Time | Primary Goal |
| :--- | :--- | :--- | :--- | :--- |
| **Act 1** | `01. Starting Soon` &rarr; `02. Monologue` | Scripted Prompter | 2-3 min | Hook, series premise, guest introduction, and personal connection. |
| **Act 2** | `02. Monologue` | Scripted Prompter | 2-3 min | Setting the historical scene: venue logistics, meeting timing, room size. |
| **Act 3** | `04. Split Screen` | Scripted Prompter | 2 min | Walking through 3 archival receipts and stating the core episode inquiry. |
| **Act 4** | `03. Reaction` / `04. Split Screen` | Unscripted Cues | 12-18 min | Live rewatch with pause triggers. No script read aloud. |
| **Act 5** | `02. Monologue` | Scripted Prompter | 3-4 min | Synthesis, anchor transcript quote, and 2026 AI-era echo. |
| **Act 6** | `08. Outro` | Scripted Prompter | 1-2 min | Acknowledging guest, community comments invitation, and next episode tease. |

---

## 2. Act-by-Act Breakdown & Writing Guidance

### Act 1: Cold Open & Personal Context
- **Begins on Scene 01 (Starting Soon)**: Start with an evocative voiceover hook that establishes why we listen to historical influences.
  *(Example: "If you want to really appreciate Jimi Hendrix, you ask one question: who did Jimi Hendrix listen to?")*
- **Switches to Scene 02 (Monologue)**: Look directly into camera. Welcome the viewer, state the series premise plainly, introduce the featured guest, and share your personal connection.
- **Rules**:
  - State the recording venue and date early (e.g., Swissotel Chicago, November 19, 2011).
  - Describe the physical recording setup (e.g., unibody MacBook Pro in Photo Booth).

### Act 2: Setting the Historical Scene
- **Camera remains on Scene 02 (Monologue)**:
- Establish the practical community mechanics of that year. Focus on logistics rather than slogans:
  - What day and time did they meet?
  - Who provided the room, and who bought the pizza?
  - Why was the room size (e.g., twenty-five people) significant for encouraging first-time speakers?
- Connect the historical schedule to working developers' actual lives (e.g., catching the Metra train home to the suburbs).

### Act 3: Primary-Source Receipts & Core Inquiry
- **Transition to Scene 04 (Split Screen)**:
- Walk through three verified archival receipts displayed in the research pane:
  - Receipt 1: A contemporary meeting announcement or recap.
  - Receipt 2: An era-specific debate or empirical experiment.
  - Receipt 3: A code commit record or Manifesto signatory verification.
- Conclude Act 3 with the episode's **Core Inquiry Question** before rolling the tape.

### Act 4: Live Rewatch (No Script Read Aloud)
- **Transition to Scene 03 (Reaction) & Scene 04 (Split Screen)**:
- **Do not read a script during Act 4**. The prompter displays a cue board summarizing the jump times, guest quotes, and watch-for moments.
- **Director Rules for Act 4**:
  - Start playback on the canonical hosted interview page from `00:00`.
  - Pick 3-4 pre-planned pause triggers from the cue board.
  - Leave a half-second beat after a thought lands before hitting pause so the thought completes cleanly.
  - React naturally on camera. Bounce into Scene 04 whenever pulling up an archival tab or code receipt.

### Act 5: Monologue Wrap-Up & Present-Day Echo
- **Transition back to Scene 02 (Monologue)**:
- Anchor the wrap-up in the interactive transcript (e.g., citing a specific dialogue line).
- Contrast the era's technical dilemma with today's 2026 engineering dilemma:
  - Connect past paradigm shifts (e.g., drag-and-drop WebForms vs. tested MVC) to present-day shifts (e.g., black-box AI code generation vs. verified domain boundaries).
  - Emphasize the enduring value of small peer rooms, empirical verification, and humane craftsmanship.

### Act 6: Outro, Credits & Next Episode Tease
- **Transition to Scene 08 (Outro)**:
- Thank the interviewee by name.
- Direct viewers to the episode page and transcript at `just3ws.com`.
- Invite community memories and corrections in the comments.
- Tease the next weekly episode and interviewee.
- Finish with the series sign-off: *"Until next time: keep your feedback loops fast, and your code humane."*

---

## 3. Mike's Authentic Spoken Voice Rules

Textream scripts must reflect spoken dialogue, not written prose:

1. **Strictly First-Person Singular (`I` / `my`)**:
   - Use `I`, `me`, and `my` for Mike's own experiences, observations, and decisions.
   - Reserve `we` and `our` strictly for genuine plurals (e.g., *"Sergio and I traded roles"* or *"we worked together on Chicago Code Camp"*). Never use the editorial "we" when speaking about your own actions.
2. **Sibilant Cluster Smoothing**:
   - Spoken teleprompters easily cause trip-ups on dense sibilant consonant clusters (`s`, `z`, `sh`, `ch`, `ts`, `sts`, `sks` and `s`-`th` collisions).
   - *Awkward*: "tests software craftsmanship's systems"
   - *Smooth*: "tests how software craft works in practice"
   - Keep proper nouns exact, but rephrase adjacent descriptive words to ensure clean articulation into the microphone.
3. **Breath Blocks & Pacing**:
   - Write in short paragraphs of 2-3 sentences.
   - Separate every paragraph with a double newline (`\n\n`).
   - In Textream, set `showParagraphDividers = 1` so visual dividers appear between thoughts.
4. **Zero Em Dashes**:
   - Never use em dashes (`\u2014`) anywhere in spoken scripts or stage directions.
   - Use periods, commas, colons, or parentheses to create spoken pauses.
5. **Stage Cues in Brackets**:
   - Format director cues clearly in square brackets so they are never read aloud:
     `[SCENE: 02. Monologue]`
     `[PAUSE]`
     `[SHOW: November 2008 Wayback snapshot]`
     `[FREEFORM: Share what you remember about the Metra commute]`

---

## 4. Track B: Companion Errata Framing

Companion Errata episodes are unscripted, practitioner-level conversations exploring the material in greater technical depth:

1. **Zero Prompter Script**:
   - Errata has no teleprompter document. It is guided entirely by `errata.unscripted_prompts` on the workbench.
2. **Focus Statement**:
   - A single sentence describing the technical scope of the session.
3. **Structured Discussion Prompts**:
   - 2-4 bulleted prompts highlighting historical curiosities, forensic catches, or legacy code walkthroughs.
4. **Demonstrations**:
   - Specific hands-on items to show on screen:
     - Navigating Wayback captures to show forgotten sponsor lists or team rosters.
     - Live code inspection in legacy repositories (`twatio.com`, `just3ws/ccs`, `fluffle`).
     - Demonstrating audio DSP filtering and hum removal (`dehum`).
     - Showing Whisper transcript ear-checks side-by-side with primary source documents.
5. **Mandatory Convergence**:
   - Even though Errata is unscripted, it must explicitly reference the primary episode number and point viewers to the canonical hosted interview page.
