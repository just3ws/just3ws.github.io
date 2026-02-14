---
layout: minimal
title: LinkedIn Article Import
description: Workflow for importing LinkedIn articles into the site with attribution, linkback, and image handling.
breadcrumb: LinkedIn Import
breadcrumb_parent_name: Docs
breadcrumb_parent_url: /docs/
---

{% include breadcrumbs.html %}

# LinkedIn Article Import

This workflow imports your LinkedIn articles into `_posts` with:

- full article HTML body
- original hero image (downloaded locally)
- attribution and linkback to LinkedIn

## 1) Extract Article JSON In Browser

Open a LinkedIn article page while logged in, then run this snippet in Chrome DevTools Console.

```js
(() => {
  const text = (node) => (node && node.textContent ? node.textContent.trim() : "");
  const attr = (sel, key) => {
    const el = document.querySelector(sel);
    return el ? (el.getAttribute(key) || "").trim() : "";
  };

  const title =
    attr('meta[property="og:title"]', "content") ||
    text(document.querySelector("h1")) ||
    document.title.replace(/\s*\|\s*LinkedIn\s*$/, "");

  const originalUrl =
    attr('meta[property="og:url"]', "content") ||
    window.location.href;

  const heroImageUrl = attr('meta[property="og:image"]', "content");
  const excerpt =
    attr('meta[name="description"]', "content") ||
    attr('meta[property="og:description"]', "content");

  // LinkedIn article pages vary; target the immersive content blocks first.
  const contentRoot =
    document.querySelector('[data-scaffold-immersive-reader-content] .reader-content-blocks-container') ||
    document.querySelector(".reader-content-blocks-container") ||
    document.querySelector('[data-scaffold-immersive-reader-content]') ||
    document.querySelector(".reader-article-content") ||
    document.querySelector("article") ||
    document.querySelector("main");

  const contentHtml = contentRoot ? contentRoot.innerHTML.trim() : "";

  // Optional byline extraction.
  const authorName =
    text(document.querySelector('[data-test-id="article-author-name"]')) ||
    text(document.querySelector(".author-name")) ||
    "";

  const publishedAt =
    attr('meta[property="article:published_time"]', "content") ||
    text(document.querySelector("time")) ||
    "";

  const payload = {
    title,
    original_url: originalUrl,
    published_at: publishedAt,
    author_name: authorName,
    author_profile_url: "https://www.linkedin.com/in/just3ws/",
    hero_image_url: heroImageUrl,
    excerpt,
    content_html: contentHtml
  };

  copy(JSON.stringify(payload, null, 2));
  console.log("Copied article JSON to clipboard.");
})();
```

Paste each copied payload into one JSON array file, for example:

`tmp/linkedin/articles.json`

```json
[
  {
    "title": "...",
    "original_url": "...",
    "published_at": "...",
    "author_name": "...",
    "author_profile_url": "https://www.linkedin.com/in/just3ws/",
    "hero_image_url": "...",
    "excerpt": "...",
    "content_html": "..."
  }
]
```

## 2) Dry Run

```bash
bin/import_linkedin_articles.rb --input tmp/linkedin/articles.json --dry-run
```

## 3) Import

```bash
bin/import_linkedin_articles.rb --input tmp/linkedin/articles.json
```

Outputs:

- Posts: `_posts/YYYY-MM-DD-<slug>.md`
- Images: `assets/images/writing/linkedin/`

## 4) Build + Review

```bash
bundle exec jekyll build
```

Then review:

- `/writing/`
- each new post page for formatting/image quality
