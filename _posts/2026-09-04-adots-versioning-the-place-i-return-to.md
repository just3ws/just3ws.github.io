---
layout: post
title: "adots: Versioning the Place I Return To"
date: 2026-09-02
description: "A field note on treating home configuration as durable infrastructure with explicit safety boundaries."
permalink: /ai/2026/09/02/adots-versioning-the-place-i-return-to/
redirect_from:
  - /2026/09/02/adots-versioning-the-place-i-return-to.html
ai_generated: true
human_led: true
source_kind: ai-augmented-human-led
robots: noindex,follow
sitemap: false
tags:
  - adots
  - dotfiles
  - personal infrastructure
  - reproducibility
  - systems thinking
---

_Editorial note: A human sat down and guided the AI through this process. Mike
Hall supplied the source material, memories, direction, corrections, and final
judgment. AI assistance helped organize the public-safe documentation and
express the diagrams. It did not witness the system or become the author._

In a Unix environment, `$HOME` is more than a path. It is the place I return
to.

That makes the configuration under it more consequential than a collection of
preferences. Shell settings, editor settings, credentials boundaries, local
service conventions, and command-line habits all meet there.

I call the home configuration layer adots. It is the versioned memory of how my
working environment is supposed to be assembled.

```mermaid
flowchart TD
    A[Versioned home configuration] --> B[Shell defaults]
    A --> C[Editor defaults]
    A --> D[Local service conventions]
    A --> E[Safety and privacy boundaries]
    B --> F[Repeatable workbench]
    C --> F
    D --> F
    E --> F
```

## The home directory is a system boundary

The useful question is not “Which dotfile should I edit?” It is “Which part of
the operating model owns this decision?”

That question keeps the configuration from becoming a pile of convenient but
unrelated tricks. A home-level rule should be durable across projects. A
project-specific rule should remain with the project. A secret should not be
versioned into either one.

```mermaid
flowchart LR
    H[Home operating model] --> P[Project repository]
    P --> W[Project-specific workflow]
    H --> S[Shared safety rule]
    S --> P
    X[Secret or private value] -. never enters public history .-> H
```

This is why a bare repository and a work-tree can be useful. The mechanism can
track the home system without pretending that every file in the home directory
belongs to the same public story.

## Restore is a test of the model

The strongest configuration is not the one that works only on the machine where
it was born. It is the one whose intent can be recovered.

```mermaid
sequenceDiagram
    participant M as Machine
    participant A as adots history
    participant B as Bootstrap process
    participant Z as zdots
    M->>A: Read declared configuration
    A-->>B: Restore versioned intent
    B->>Z: Install platform conventions
    Z-->>M: Expose usable workbench
    M->>A: Verify behavior and capture corrections
```

The restore path exposes hidden assumptions. A missing tool, an undocumented
environment dependency, or a safety rule that lives only in memory becomes
visible.

That is the point of versioning the place I return to. Home is not static. It is
basecamp, and basecamp needs maintenance.
