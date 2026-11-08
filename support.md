---
layout: base
title: "Mike Hall · just3ws"
description: "The work of Mike Hall: software, communities, interviews, and Ramblin' & Amblin'."
permalink: /support/
body_class: page-support
---

{% assign campaign = site.data.patreon_campaign %}

<article class="support-page">
  <header class="support-hero">
    <div class="support-hero-copy">
      <p class="support-eyebrow">Mike Hall <span aria-hidden="true">·</span> just3ws</p>
      <h1>Making useful things with people</h1>
      <p class="support-lede">{{ campaign.short_description }}</p>
      <div class="support-actions">
        {% if campaign.page_status == "published" %}
        <a class="support-primary-action" href="{{ campaign.campaign_url }}" target="_blank" rel="noopener">Follow free on Patreon</a>
        {% endif %}
        <a href="https://www.youtube.com/@whoistechcmty" target="_blank" rel="noopener">Watch Ramblin' &amp; Amblin'</a>
      </div>
    </div>
    <figure class="support-hero-figure">
      <img class="support-hero-image" src="{{ campaign.support_hero_image }}" alt="{{ campaign.support_hero_image_alt }}" fetchpriority="high">
      <figcaption>A frame from my Ramblin' &amp; Amblin' video about proximity and technical skill.</figcaption>
    </figure>
  </header>

  <section class="support-story" aria-labelledby="support-story-title">
    <p class="support-eyebrow">A little context</p>
    <h2 id="support-story-title">I'm Mike. Here's the thread.</h2>
    {{ campaign.about | markdownify }}
  </section>

  <section class="support-story" id="studio-note" aria-labelledby="studio-note-title">
    <p class="support-eyebrow">A sample from the workbench</p>
    <h2 id="studio-note-title">{{ campaign.studio_note_sample.title }}</h2>
    {% for paragraph in campaign.studio_note_sample.paragraphs %}
      <p>{{ paragraph }}</p>
    {% endfor %}
    <p>{{ campaign.studio_note_sample.provenance }}</p>
    <ul>
      {% for link in campaign.studio_note_sample.links %}
        <li><a href="{{ link.url }}">{{ link.label }}</a></li>
      {% endfor %}
    </ul>
  </section>

  <section class="support-projects" aria-labelledby="support-projects-title">
    <div class="support-section-heading">
      <p class="support-eyebrow">Different projects, one workbench</p>
      <h2 id="support-projects-title">What I'm making and keeping</h2>
    </div>
    <div class="support-project-grid">
      {% for project in campaign.projects %}
      <article class="support-project-card">
        {% if project.image %}
        <img class="support-project-image{% if project.image_fit == 'contain' %} support-project-image-contain{% endif %}" src="{{ project.image }}" alt="{{ project.image_alt }}">
        {% endif %}
        <h3>{{ project.name }}</h3>
        <p>{{ project.description }}</p>
        <a href="{{ project.url }}" target="_blank" rel="noopener">Explore {{ project.name }}</a>
      </article>
      {% endfor %}
    </div>
  </section>

  <section class="support-invitation" aria-labelledby="support-invitation-title">
    {% if campaign.page_status == "published" %}
    <div>
      <p class="support-eyebrow">Support the independent work</p>
      <h2 id="support-invitation-title">Studio Notes &amp; The Hallway Chatroom</h2>
      <p>{{ campaign.membership_recommendation.paid_tier_description }}</p>
      <p>Members also get access to <strong>{{ campaign.community_chat.name }}</strong>, our direct chatroom on Patreon for conversations about software craft, audio forensics, archive history, and live workbench questions.</p>
      <p>{{ campaign.membership_recommendation.cadence }}</p>
      <p>Your support helps make room for the work as a whole. It doesn't assign your contribution to one project or change what I choose to publish.</p>
    </div>
    <div class="support-actions">
      <a class="support-primary-action" href="{{ campaign.campaign_url }}" target="_blank" rel="noopener">Join {{ campaign.membership_recommendation.paid_tier_name }} for ${{ campaign.membership_recommendation.paid_tier_price_usd }}/month</a>
      <a href="{{ campaign.campaign_url }}" target="_blank" rel="noopener">Follow free on Patreon</a>
    </div>
    {% else %}
    <div>
      <p class="support-eyebrow">Coming soon</p>
      <h2 id="support-invitation-title">I'm preparing a small Patreon launch</h2>
      <p>I'm starting with occasional studio notes about the videos, the interview archive, and making software. I'll share the membership page here once it's ready.</p>
    </div>
    <div class="support-actions">
      <a href="https://www.youtube.com/@whoistechcmty" target="_blank" rel="noopener">Watch my videos</a>
      <a href="https://www.just3ws.com/interviews/">Explore the interview archive</a>
    </div>
    {% endif %}
  </section>

  <section class="support-projects" aria-labelledby="support-channels-title">
    <div class="support-section-heading">
      <p class="support-eyebrow">Direct ways to back the work</p>
      <h2 id="support-channels-title">Funding channels &amp; community support</h2>
      <p style="color: var(--color-text-muted); max-width: 60ch; line-height: 1.6;">Whether you want to join monthly studio discussions, sponsor open-source developer tooling, send a quick one-time tip, or partner on a focused systems investigation, every contribution keeps these efforts independent and freely shared.</p>
    </div>
    <div class="support-project-grid">
      {% for channel in campaign.funding_channels %}
      <article class="support-project-card">
        <span class="support-eyebrow" style="margin-top: 1.25rem;">{{ channel.badge }}</span>
        <h3>{{ channel.name }}</h3>
        <p>{{ channel.description }}</p>
        <a href="{{ channel.url }}" {% if channel.url contains 'http' %}target="_blank" rel="noopener"{% endif %}>{{ channel.action_label }} &rarr;</a>
      </article>
      {% endfor %}
    </div>
  </section>
  <section class="support-story" aria-labelledby="support-engineering-title">
    <p class="support-eyebrow">Working together</p>
    <h2 id="support-engineering-title">Need help understanding a system?</h2>
    <p>For engineering work, start with a focused investigation of one important workflow. We agree the question, access, scope, timing, and fee before work begins.</p>
    <p><a href="/engagements/#workflow-investigation">See the workflow investigation and proposed outputs</a>, or <a href="/contact/#professional">contact me about your team</a>.</p>
    <p>Engineering engagements are separate from Patreon membership.</p>
  </section>
</article>
