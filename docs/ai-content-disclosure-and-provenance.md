---
layout: minimal
title: AI Content Disclosure and Provenance Policy
description: How the public archive distinguishes organic writing, human-led AI assistance, exploratory synthesis, and evidence-preserving transcript work.
robots: index,follow
sitemap: true
---

# AI Content Disclosure and Provenance Policy

This public archive uses AI tools as research and writing assistants. Mike Hall
is the human author and publisher of the articles that carry this disclosure.
He supplies the intent, source material, interpretation, corrections, and final
approval.

AI tools can help organize a large archive, suggest structure, summarize source
material, and draw diagrams. They cannot independently verify a memory, hear a
recording, establish a historical fact, or take responsibility for a claim.

## The publication rule

Every article must make its authorship and production process legible. A reader
should be able to answer four questions without guessing:

1. Who is responsible for the article?
2. What source material shaped it?
3. How did AI assistance affect the result?
4. Where should a reader go to verify an important claim?

The visible article notice is backed by frontmatter, provenance links, the
canonical Markdown source, and automated validation. The goal is a strong,
repeatable publication contract. No single policy can promise universal legal or
platform compliance in every jurisdiction, so material claims still require
human review and source-level verification.

## Disclosure levels

| Level | Use | Public treatment | Required disclosure |
| --- | --- | --- | --- |
| Organic writing | Mike wrote and edited the article without generative AI | Normal publication | Author and ordinary source notes when useful |
| AI-assisted, human-led | Mike provided the subject, evidence, direction, corrections, and approval. AI helped organize, draft, or illustrate | Public and indexable when the content is ready | Visible notice, human responsibility, process description, and source links |
| Exploratory AI synthesis | AI produced substantial structure or prose while Mike is still evaluating the result | Quarantined under `/ai/`, `noindex,follow`, and excluded from the sitemap | Visible notice, explicit uncertainty, provenance, and primary-source links |
| Transcript support | AI helped transcribe, normalize, or align a recording | The transcript remains a best-faith record of the speaker or speakers | Identify the speaker model, preserve the source recording and its timestamps, and never present AI as a speaker or author |

“AI-generated” is retained as a technical flag for substantial machine
assistance and quarantine. It does not mean that AI is the author. Where the
human-led relationship is known, the article also records `human_led: true` and
`source_kind: ai-augmented-human-led`.

For this archive, “Strong Enough to be Gentle” is the last organic article in
the recent writing run. Articles published from 2026-08-29 onward that were
created with substantial AI assistance are classified as exploratory AI
syntheses, even when Mike supplied the memories, evidence, direction, and
final judgment. They live under `/ai/`, receive the standard visible notice,
use `noindex,follow`, and stay out of the sitemap.

The early LinkedIn essays from late 2024 and early 2025 are a different case.
Mike developed them through interactive ChatGPT prompting and human editorial
direction. They remain public and indexable, but now carry the same visible
ethics notice and an explicit historical-production note. “The Sound of
Tokens” is restored to the public archive as a human-led personal essay with
its former `/ai/` route retained as a redirect. “From Y2K Panic to AI Anxiety”
remains quarantined because its personal detail exceeds the public lesson's
useful surface area.

## What the notice means

The site notice is intentionally plain:

- Mike Hall led the article.
- Mike supplied the subject, source material, corrections, and editorial
  judgment.
- AI helped organize or draft the material.
- AI is not an independent historical authority.
- Published claims remain Mike's responsibility.
- Important claims should be checked against the linked primary archive.

For quarantined material, the notice also states that the page is exploratory,
non-canonical, and excluded from search indexing. A transcript gets a different
provenance treatment from an essay because the recording is the primary source.
The transcript is a best-faith attempt to preserve the words, speaker
attribution, turn boundaries, and timing of a historical recording. AI may be
used in service of that fidelity. It does not become a speaker, author, or
independent witness.

The independently inspectable evidence is the recording hosted by the original
service and the timestamps visible in that player. A reader can compare the
transcript against the recording. If a transcript time label is inferred from
text alignment rather than supplied by the source, the implementation must not
present that label as a frame-accurate measurement. A wording, attribution, or
turn-boundary question should be reported with the recording timestamp so the
archive can be corrected against evidence.

## Verification checklist

Before publication, the article must pass these checks:

- The human author is identified as Mike Hall.
- The frontmatter identifies the assistance level and source kind.
- The article has a title, description, normal heading structure, and source
  note where historical claims need one.
- The article distinguishes what happened, what is interpretation, and what is
  uncertain.
- Important dates, names, numbers, quotes, and causal claims resolve to a
  public source or are labeled as personal recollection.
- AI is not listed as the author, speaker, witness, or independent authority.
- Exploratory AI synthesis is under `/ai/` with `noindex,follow` and
  `sitemap: false`.
- Public AI-assisted work is not silently presented as organic writing.
- Markdown, YAML, links, rendered HTML, and prose quality checks pass.

The validator runs this checklist against the repository's flagged articles.
The layout test verifies that every flagged article receives the same visible
notice. This creates an auditable floor. Human review remains the final gate.

## External guidance

This policy follows the direction of primary guidance rather than treating a
disclosure as a marketing label:

- [Google Search guidance on helpful, people-first content](https://developers.google.com/search/docs/fundamentals/creating-helpful-content)
  recommends clear authorship and context about how automation was used when a
  reader could reasonably ask how the content was created.
- [Google Search guidance on generative AI content](https://developers.google.com/search/docs/fundamentals/using-gen-ai-content)
  emphasizes accuracy, quality, relevance, and added value over the mere use of
  an AI tool.
- [UNESCO's Recommendation on the Ethics of Artificial Intelligence](https://www.unesco.org/en/articles/recommendation-ethics-artificial-intelligence?hub=66973)
  centers human dignity, transparency, fairness, and human oversight.
- [C2PA Content Credentials](https://spec.c2pa.org/specifications/specifications/2.4/specs/ContentCredentials.html)
  provides a machine-readable vocabulary for AI disclosure, provenance, and
  levels of human oversight. It is especially useful for media assets. For
  Markdown articles, frontmatter, stable source links, and visible notices are
  the practical equivalent.

This policy is itself human-led and AI-assisted. Mike Hall supplied the intent,
the publication requirements, and the final editorial judgment. AI assistance
helped organize the policy and its checklist.
