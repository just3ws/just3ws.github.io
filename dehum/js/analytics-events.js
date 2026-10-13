/**
 * GoatCounter & Telemetry Integration
 * Privacy-preserving aggregate event tracking matching just3ws.com standard
 */
(function () {
  'use strict';

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
        title: title || name,
        event: true
      });
    });
  }

  // Track interactive clicks across navigation, CTAs, audio players, and code copies
  document.addEventListener('DOMContentLoaded', function () {
    // 1. Copy button tracking
    var copyButtons = document.querySelectorAll('[data-action="copy"]');
    copyButtons.forEach(function (btn) {
      btn.addEventListener('click', function () {
        var targetId = btn.getAttribute('data-target');
        var targetEl = document.getElementById(targetId);
        if (targetEl) {
          navigator.clipboard.writeText(targetEl.innerText).then(function () {
            var origText = btn.innerText;
            btn.innerText = 'Copied!';
            setTimeout(function () {
              btn.innerText = origText;
            }, 2000);
            trackEvent('copy_code', 'Copied command snippet: ' + targetId);
          });
        }
      });
    });

    // 2. Audio playback telemetry
    var audios = document.querySelectorAll('audio');
    audios.forEach(function (audio) {
      audio.addEventListener('play', function () {
        var label = audio.getAttribute('aria-label') || audio.id || 'unlabeled audio';
        trackEvent('play_audio_sample', 'Audio sample played: ' + label);
      });
    });

    // 3. Outbound links & syndication tracking
    document.addEventListener('click', function (e) {
      var anchor = e.target.closest('a');
      if (!anchor) return;

      var href = anchor.getAttribute('href') || '';
      if (!href) return;

      if (href.indexOf('github.com') !== -1) {
        trackEvent('click_github', 'Outbound GitHub link: ' + href);
      } else if (href.indexOf('linkedin.com') !== -1) {
        trackEvent('click_linkedin', 'Outbound LinkedIn link');
      } else if (href.indexOf('youtu.be') !== -1 || href.indexOf('youtube.com') !== -1) {
        trackEvent('click_youtube', 'Outbound YouTube Master link');
      } else if (href.indexOf('just3ws.com') !== -1) {
        trackEvent('click_companion_article', 'Outbound Case Study link');
      }
    });
  });
})();
