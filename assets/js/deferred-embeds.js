(() => {
  const allowedHosts = new Set(["www.youtube.com", "www.youtube-nocookie.com", "player.vimeo.com"]);

  function loadEmbed(container, seekSec) {
    if (!container) return null;
    const existingIframe = container.querySelector("iframe");
    if (existingIframe) {
      if (seekSec !== undefined && seekSec !== null && !isNaN(seekSec)) {
        seekIframe(existingIframe, seekSec);
      }
      return existingIframe;
    }

    let source;
    try { source = new URL(container.dataset.embedSrc, window.location.href); } catch (_) { return null; }
    if (!allowedHosts.has(source.hostname)) return null;

    source.searchParams.set("enablejsapi", "1");
    if (seekSec !== undefined && seekSec !== null && !isNaN(seekSec)) {
      const s = Math.max(0, Math.floor(seekSec));
      if (source.hostname.includes("vimeo")) {
        source.hash = "t=" + s + "s";
      } else {
        source.searchParams.set("start", s.toString());
      }
      source.searchParams.set("autoplay", "1");
    }

    const iframe = document.createElement("iframe");
    iframe.id = (container.dataset.embedId || container.id || "asset-embed") + "-player";
    iframe.src = source.href;
    iframe.title = container.dataset.embedTitle || "External video player";
    iframe.width = "100%";
    iframe.height = "250";
    iframe.loading = "lazy";
    iframe.allow = "autoplay; fullscreen; picture-in-picture; clipboard-write; encrypted-media; web-share";
    iframe.allowFullscreen = true;
    iframe.referrerPolicy = "strict-origin-when-cross-origin";
    container.replaceChildren(iframe);
    return iframe;
  }

  function seekIframe(iframe, sec) {
    const s = Math.max(0, Math.floor(sec));
    try {
      iframe.contentWindow.postMessage(JSON.stringify({
        event: 'command',
        func: 'seekTo',
        args: [s, true]
      }), '*');
      iframe.contentWindow.postMessage(JSON.stringify({
        event: 'command',
        func: 'playVideo',
        args: []
      }), '*');
    } catch (_) {}

    const src = iframe.getAttribute("src") || "";
    if (src.includes("player.vimeo.com")) {
      const clean = src.replace(/#t=\d+s/g, "");
      iframe.setAttribute("src", clean + "#t=" + s + "s");
    }
  }

  window.loadDeferredEmbed = loadEmbed;
  window.seekDeferredEmbed = seekIframe;

  document.querySelectorAll("[data-deferred-embed]").forEach((container) => {
    const button = container.querySelector("[data-load-embed]");
    if (!button) return;

    button.addEventListener("click", () => {
      loadEmbed(container);
    }, { once: true });
  });
})();
