---
name: no-em-dashes
description: Enforce em-dash-free writing. Use this skill whenever writing or editing prose, case studies, briefs, blog posts, documentation, and website copy so the output contains zero em dashes and avoids the sentence structures that invite them.
---

# No Em Dashes Skill

Guarantee that writing produced across this repository contains no em dashes (`—` / `\u2014`), double hyphens (`--`), or spaced hyphens (` - `) used as sentence pauses, and that sentences are structured directly without reaching for dramatic punctuation crutches.

---

## 🎯 Why This Matters

1. **Fingerprint of Machine Text**: Heavy em-dash usage is one of the primary markers of LLM-generated prose. Removing it keeps technical writing reading as direct, human, and authentic.
2. **Cadence & Sentence Discipline**: The em dash encourages breathy parenthetical tangents and tacked-on reveals. Removing it forces tighter, more deliberate, and neuroinclusive sentence structures.

---

## 🛑 The Core Rules

1. **Zero Em Dashes**: Never use `—` (U+2014) in prose.
2. **No Disguised Stand-Ins**: Do not use ` -- `, ` - `, or stray en dashes (`–`) between words as substitutes for a pause.
3. **Recast the Sentence Shape**:
   * **Split with a period**: Break long, runaway sentences into two concise, focused sentences.
   * **Use a colon**: When introducing an explanation, list, or direct outcome.
   * **Use a comma or semicolon**: For natural syntactic clauses without theatrical pauses.
   * **Use parentheses**: For true secondary notes or definitions.

---

## ✅ What Stays (Do Not Overcorrect)

* Ordinary compound words: `state-of-the-art`, `open-source`, `built-in`, `five-year-old`.
* Number, date, and score ranges: `2010–2013`, `pages 10–25`, `2006-2015`.
* Code, file paths, URLs, CLI flags, and math: `--verbose`, `/var/log`, `x - y`.
* Markdown syntax: YAML frontmatter delimiters (`---`), horizontal rules, and table dividers (`| --- |`).
