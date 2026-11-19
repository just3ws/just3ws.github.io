---
layout: minimal
title: "Episode 03: From Chicago Code Camp to Code Camp Server — AGPLv3 & Next Steps"
description: "Anchoring prod-2012-05, archiving master, relicensing main to GNU AGPL v3, and charting the Rails 8 + Railway modernization roadmap."
permalink: /ai/series/chicago-code-camp/episode-03/
date: 2026-11-19
ai_generated: true
source_kind: ai-generated-research-synthesis
robots: noindex,follow
sitemap: false
---

<article class="page">
  <p><a href="/ai/series/chicago-code-camp/">&larr; Back to Series Index</a></p>

  <div style="background: var(--color-bg-card, #2a2a37); border-left: 5px solid #e6c384; padding: 1rem 1.25rem; border-radius: 0 8px 8px 0; margin-bottom: 1.5rem;">
    <strong>Quarantined Tier 3 Synthesis:</strong> Documents the November 2026 repository reorganization and modernization plan for <code>just3ws/ccs</code>.
  </div>

  <h1>Episode 03: From Chicago Code Camp to Code Camp Server</h1>

  <h2>1. Preserving Lineage Without Losing History</h2>
  <p>
    Rather than starting a separate repository and losing 16 years of commit history, <code>just3ws/ccs</code> was reorganized cleanly around the last verified 2012 production commit:
  </p>
  <ul>
    <li><strong>Production Anchor:</strong> Tagged <code>1b5f639</code> (May 15, 2012) as <code>prod-2012-05</code>.</li>
    <li><strong>Archived History:</strong> Renamed <code>master</code> (2018 tweaks) to <code>archive/master-2018</code> and preserved <code>origin/2012-05</code>, <code>origin/2.0</code>, and <code>origin/2025-12</code>.</li>
    <li><strong>New <code>main</code> Branch:</strong> Branched directly from <code>prod-2012-05</code> (<code>1b5f639</code>) so the forward-looking codebase starts from known-working production lineage.</li>
  </ul>

  <h2>2. Why GNU AGPL v3</h2>
  <p>
    <code>ccs</code> was GPL v2 from April 2010 onward because the intent was always a community-owned, share-alike conference platform. For a hosted web application, GPLv2/v3 leaves a SaaS gap—someone can run a modified server without distributing binaries. Switching <code>main</code> to <strong>GNU AGPL v3</strong> closes that gap and matches the original community spirit.
  </p>

  <h2>3. Roadmap: Generalized Code Camp Server on Rails 8 + Railway</h2>
  <ol>
    <li><strong>Static Archive First:</strong> Captured the 2012 site in <code>ccs-2012-static</code> plus a 1080p walkthrough video so the 2012 Chicago Code Camp site is preserved permanently.</li>
    <li><strong>Clean-Slate Rails 8 Port in <code>main</code>:</strong> Port the 19-table schema, 17 models, 15 controllers, and 25 spec/feature files onto current Ruby + Rails 8, replacing 2012 gems (<code>devise ~1</code>, <code>cancan</code>, <code>activeadmin 0.4.3</code>, <code>formtastic</code>, <code>heroku_san</code>) with modern equivalents while keeping the <code>origin/2025-12</code> Colima container as the behavioral oracle.</li>
    <li><strong>True Code Camp Server:</strong> Extract hardcoded Chicago Code Camp domains, mailers, and copy into event configuration, packaged for Railway.</li>
  </ol>

  <p><a href="/ai/series/chicago-code-camp/episode-02/">&larr; Episode 02</a> · <a href="/ai/series/chicago-code-camp/">Series Index &rarr;</a></p>
</article>
