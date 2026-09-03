(() => {
  const allowedHosts = new Set(["www.youtube.com", "www.youtube-nocookie.com", "player.vimeo.com"]);

  document.querySelectorAll("[data-deferred-embed]").forEach((container) => {
    const button = container.querySelector("[data-load-embed]");
    if (!button) return;

    button.addEventListener("click", () => {
      let source;
      try { source = new URL(container.dataset.embedSrc, window.location.href); } catch (_) { return; }
      if (!allowedHosts.has(source.hostname)) return;

      source.searchParams.set("enablejsapi", "1");
      const iframe = document.createElement("iframe");
      iframe.src = source.href;
      iframe.title = container.dataset.embedTitle || "External video player";
      iframe.width = "100%";
      iframe.height = "250";
      iframe.loading = "lazy";
      iframe.allow = "autoplay; fullscreen; picture-in-picture; clipboard-write; encrypted-media; web-share";
      iframe.allowFullscreen = true;
      iframe.referrerPolicy = "strict-origin-when-cross-origin";
      container.replaceChildren(iframe);
    }, { once: true });
  });
})();
