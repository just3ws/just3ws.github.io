"use strict";

(() => {
  const root = document.getElementById("home-featured-carousel");
  if (!root) return;

  const source = document.getElementById("home-featured-candidates");
  if (!source) return;

  const link = document.getElementById("home-featured-link");
  const image = document.getElementById("home-featured-image");
  const caption = document.getElementById("home-featured-caption");
  const kicker = document.getElementById("home-featured-kicker");
  const title = document.getElementById("featured-article-title");
  const summary = document.getElementById("home-featured-summary");
  const cta = document.getElementById("home-featured-cta");
  const prev = document.getElementById("home-carousel-prev");
  const next = document.getElementById("home-carousel-next");
  const controls = document.getElementById("home-carousel-controls");

  const candidates = Array.from(source.querySelectorAll("[data-title]")).map((node) => ({
    kind: node.dataset.kind || "article",
    kicker: node.dataset.kicker || "Featured",
    caption: node.dataset.caption || "",
    title: node.dataset.title || "",
    url: node.dataset.url || "/home/",
    image: node.dataset.image || "",
    summary: node.dataset.summary || "",
    cta: node.dataset.cta || "View"
  })).filter((item) => item.title && item.url && item.image);

  if (!candidates.length) {
    if (controls) controls.hidden = true;
    return;
  }

  const applyItem = (item) => {
    root.classList.add("is-transitioning");
    window.setTimeout(() => {
      if (link) {
        link.href = item.url;
        link.setAttribute("aria-label", `${item.cta}: ${item.title}`);
      }
      if (image) {
        image.src = item.image;
        image.alt = `${item.kind === "video" ? "Thumbnail" : "Cover image"} for ${item.title}`;
      }
      if (caption) caption.textContent = item.caption;
      if (kicker) kicker.textContent = item.kicker;
      if (title) title.textContent = item.title;
      if (summary) summary.textContent = item.summary;
      if (cta) {
        cta.href = item.url;
        cta.textContent = item.cta;
      }
      root.classList.remove("is-transitioning");
    }, 120);
  };

  const shuffle = (items) => {
    const copy = items.slice();
    for (let i = copy.length - 1; i > 0; i -= 1) {
      const j = Math.floor(Math.random() * (i + 1));
      [copy[i], copy[j]] = [copy[j], copy[i]];
    }
    return copy;
  };

  let queue = shuffle(candidates);
  let index = 0;
  let timer = null;
  const intervalMs = 9000;

  const show = (newIndex) => {
    index = (newIndex + queue.length) % queue.length;
    applyItem(queue[index]);
  };

  const nextItem = () => show(index + 1);
  const prevItem = () => show(index - 1);

  const start = () => {
    if (queue.length < 2) return;
    stop();
    timer = window.setInterval(nextItem, intervalMs);
  };

  const stop = () => {
    if (!timer) return;
    window.clearInterval(timer);
    timer = null;
  };

  if (prev) prev.addEventListener("click", () => { prevItem(); start(); });
  if (next) next.addEventListener("click", () => { nextItem(); start(); });

  root.addEventListener("mouseenter", stop);
  root.addEventListener("mouseleave", start);
  root.addEventListener("focusin", stop);
  root.addEventListener("focusout", start);

  show(Math.floor(Math.random() * queue.length));
  if (queue.length < 2 && controls) controls.hidden = true;
  start();
})();
