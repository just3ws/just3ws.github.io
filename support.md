---
layout: base
title: "Support Mike Hall's independent work"
description: "Follow the workbench behind Ramblin' & Amblin', the UGtastic / WHOIS Tech Community archive, and Phalanx Duel."
permalink: /support/
body_class: page-support
---

{% assign campaign = site.data.patreon_campaign %}

<article class="container" style="max-width: 72rem; padding: 3rem 1.5rem 5rem;">
  <header style="max-width: 54rem; margin: 0 auto 3rem;">
    <p class="eyebrow">Mike Hall · just3ws</p>
    <h1>{{ campaign.title }}</h1>
    <p style="font-size: 1.2rem;">{{ campaign.short_description }}</p>
    {{ campaign.about | markdownify }}
    <p style="display: flex; flex-wrap: wrap; gap: .75rem; margin-top: 1.5rem;">
      <a href="{{ campaign.campaign_url }}" target="_blank" rel="noopener" style="display: inline-block; padding: .7rem 1rem; border-radius: var(--radius-md); background: var(--color-primary); color: white; font-weight: 700; text-decoration: none;">Visit my Patreon</a>
      <a href="https://www.youtube.com/@whoistechcmty" target="_blank" rel="noopener">Watch Ramblin' &amp; Amblin'</a>
    </p>
  </header>

  <section aria-labelledby="project-history" style="max-width: 54rem; margin: 0 auto 3rem;">
    <h2 id="project-history">A few chapters in that work</h2>
    <ol>
      {% for milestone in campaign.history %}
      <li><strong>{{ milestone.date }}</strong> — <a href="{{ milestone.url }}">{{ milestone.title }}</a></li>
      {% endfor %}
    </ol>
  </section>

  <section aria-labelledby="support-work">
    <h2 id="support-work">What this work includes</h2>
    <p>These projects share one creator and a common workbench. They have different histories, audiences, and goals.</p>
    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(17rem, 1fr)); gap: 1rem;">
      {% for project in campaign.projects %}
      <article style="padding: 1.25rem; background: var(--color-bg-card); border: 1px solid var(--color-border); border-top: 4px solid var(--color-primary); border-radius: var(--radius-md);">
        <h3>{{ project.name }}</h3>
        <p>{{ project.description }}</p>
        <p><strong>Where membership helps:</strong> {{ project.support_use }}</p>
        <a href="{{ project.url }}" target="_blank" rel="noopener">Explore {{ project.name }}</a>
      </article>
      {% endfor %}
    </div>
  </section>

  <section aria-labelledby="membership-shape" style="max-width: 54rem; margin: 3rem auto 0;">
    <h2 id="membership-shape">A low-pressure way to follow along</h2>
    <p>{{ campaign.membership_recommendation.paid_tier_description }}</p>
    <p>{{ campaign.membership_recommendation.cadence }}</p>
    <p>I'm still shaping the episode format and learning what makes a good installment. This membership is meant to support that process without turning every idea into a deliverable. The public work stays on its own channels; any member-only post will be clearly labeled on Patreon.</p>
    <p><a href="{{ campaign.campaign_url }}" target="_blank" rel="noopener">See membership options on Patreon</a></p>
  </section>
</article>
