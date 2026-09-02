---
layout: minimal
title: Context Wiki Frontmatter Contract
description: A public contract for article concepts, relationships, provenance, and machine-readable archive mapping.
robots: noindex,follow
sitemap: false
---

# Context Wiki Frontmatter Contract

Frontmatter is the small control panel above an article. It can tell the site
what a page is about, where it came from, and how it should connect to the rest
of the archive. The prose remains for people. The metadata gives tools a clean
surface for maps, previews, search, and structured data.

## The context wiki block

Use `context_wiki` when an article needs a curated concept set or a deliberate
relationship map:

```yaml
context_wiki:
  concepts:
    - aspect-oriented-programming
    - pointcut
    - join-point
    - advice
  related:
    - /ai/2026/09/01/aop-opentelemetry-strangler-fig/
    - /ai/2026/08/20/system-cartography-part-3-aop-as-a-diagnostic-lens/
  graph:
    role: explainer
    edges:
      - relationship: demonstrates
        target: /2026/08/30/rolling-out-opentelemetry-in-the-real-world.html
```

When `concepts` is present, the automatic linker uses only those registered
concepts on that page. When it is absent, the linker can discover any matching
registered concept in the article body. That gives a page an easy default and a
precise escape hatch.

## Useful metadata beyond links

Frontmatter can also carry:

- `content_type`: essay, field note, transcript, presentation, or synthesis;
- `source_kind`: organic writing, transcript, or AI-augmented human-led;
- `source_ids`: stable transcript, video, post, or project identifiers;
- `provenance`: dates, source URLs, transformation notes, and confidence limits;
- `audience`: the reader perspective the page serves;
- `reading_time` and `difficulty`: optional guidance for cognitive load;
- `graph.role`: explainer, evidence, bridge, origin, or companion;
- `graph.edges`: explicit relationships with a named verb and a stable target.

The values should describe the page honestly. Metadata is not a place to make a
weak connection look stronger. A historical date stays historical. An AI-
augmented synthesis stays visibly distinct from an organic essay.

## Why this helps

The same frontmatter can feed several humane surfaces:

1. inline concept links and lazy previews;
2. a definitions drawer for readers who want more scaffolding;
3. graph imports with stable entities and relationship verbs;
4. JSON-LD `Article`, `DefinedTerm`, and `about` data;
5. related-reading trails that explain why a link is present;
6. archive audits that find pages with concepts but no article-backed definition.

This is a map legend, not a maze. The page remains readable without JavaScript,
and every preview points to a full article that can be read directly.
