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
    <img class="support-hero-image" src="{{ campaign.cover_image }}" alt="A warmly lit maker's workbench with a system map, audio recorder, interview pages, and camera." fetchpriority="high">
    <div class="support-hero-copy">
      <p class="support-eyebrow">Mike Hall <span aria-hidden="true">·</span> just3ws</p>
      <h1>Making useful things with people</h1>
      <p class="support-lede">{{ campaign.short_description }}</p>
      <div class="support-actions">
        {% if campaign.page_status == "published" %}
        <a class="support-primary-action" href="{{ campaign.campaign_url }}" target="_blank" rel="noopener">Follow my work on Patreon</a>
        {% endif %}
        <a href="https://www.youtube.com/@whoistechcmty" target="_blank" rel="noopener">Watch Ramblin' &amp; Amblin'</a>
      </div>
    </div>
  </header>

  <section class="support-story" aria-labelledby="support-story-title">
    <p class="support-eyebrow">A little context</p>
    <h2 id="support-story-title">I'm Mike. Here's the thread.</h2>
    {{ campaign.about | markdownify }}
  </section>

  <section class="support-projects" aria-labelledby="support-projects-title">
    <div class="support-section-heading">
      <p class="support-eyebrow">Different projects, one workbench</p>
      <h2 id="support-projects-title">What I'm making and keeping</h2>
    </div>
    <div class="support-project-grid">
      {% for project in campaign.projects %}
      <article class="support-project-card">
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
      <h2 id="support-invitation-title">A studio note now and then</h2>
      <p>{{ campaign.membership_recommendation.paid_tier_description }}</p>
      <p>{{ campaign.membership_recommendation.cadence }}</p>
      <p>Your support helps make room for the work as a whole. It doesn't assign your contribution to one project or change what I choose to publish.</p>
    </div>
    <a class="support-primary-action" href="{{ campaign.campaign_url }}" target="_blank" rel="noopener">See Studio Notes on Patreon</a>
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
</article>
