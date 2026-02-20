(function () {
  function withGoatCounter(callback, attempts) {
    var retries = typeof attempts === 'number' ? attempts : 20;

    if (window.goatcounter && typeof window.goatcounter.count === 'function') {
      callback();
      return;
    }

    if (retries <= 0) {
      return;
    }

    window.setTimeout(function () {
      withGoatCounter(callback, retries - 1);
    }, 250);
  }

  function trackEvent(name, title) {
    withGoatCounter(function () {
      window.goatcounter.count({
        path: '/event/' + name,
        title: title,
        event: true,
      });
    });
  }

  function normalizeTitle(url) {
    var value = (url && url.href) ? url.href : String(url || '');
    return value.length > 220 ? value.slice(0, 220) : value;
  }

  function isEmbedHost(hostname) {
    return /(^|\.)youtube\.com$/i.test(hostname) ||
      /(^|\.)youtu\.be$/i.test(hostname) ||
      /(^|\.)vimeo\.com$/i.test(hostname);
  }

  function handleLinkClick(event) {
    var anchor = event.target.closest && event.target.closest('a[href]');
    if (!anchor) {
      return;
    }

    var href = anchor.getAttribute('href') || '';
    if (!href || href.indexOf('javascript:') === 0 || href.indexOf('#') === 0) {
      return;
    }

    if (href.indexOf('mailto:') === 0) {
      trackEvent('mailto_click', href.replace(/^mailto:/i, ''));
      return;
    }

    if (href.indexOf('tel:') === 0) {
      trackEvent('tel_click', href.replace(/^tel:/i, ''));
      return;
    }

    var url;
    try {
      url = new URL(anchor.href, window.location.origin);
    } catch (error) {
      return;
    }

    var pathname = url.pathname || '';
    if (/\/(resume\.(txt|md))$/i.test(pathname)) {
      trackEvent('resume_download', normalizeTitle(url));
      return;
    }

    if (/\.(pdf|zip|doc|docx|txt|md)$/i.test(pathname)) {
      trackEvent('file_download', normalizeTitle(url));
      return;
    }

    if (url.origin !== window.location.origin) {
      if (isEmbedHost(url.hostname)) {
        trackEvent('outbound_video_click', normalizeTitle(url));
      } else {
        trackEvent('outbound_click', normalizeTitle(url));
      }
    }
  }

  document.addEventListener('click', handleLinkClick, { capture: true });
})();
