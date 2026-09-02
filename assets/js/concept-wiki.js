(function () {
  function initConceptWiki() {
    const links = Array.from(document.querySelectorAll('.concept-link'));
    const toggle = document.querySelector('.concept-definitions-toggle');
    const definitions = document.getElementById('conceptDefinitions');
    const definitionList = document.querySelector('.concept-definitions-list');
    const preview = document.getElementById('conceptPreview');
    const tools = document.querySelector('.concept-wiki-tools');

    if (!links.length || !preview) {
      if (tools) tools.remove();
      if (preview) preview.remove();
      return;
    }

    let hideTimer;
    const cache = new Map();

    function scheduleHide() {
      clearTimeout(hideTimer);
      hideTimer = setTimeout(() => { preview.hidden = true; }, 180);
    }

    function showPreview(link, payload) {
      preview.innerHTML = '';
      const label = document.createElement('strong');
      label.textContent = payload.label || link.textContent;
      const definition = document.createElement('p');
      definition.textContent = payload.definition || link.dataset.definition || 'A trail marker in the archive.';
      const read = document.createElement('span');
      read.className = 'concept-preview-read';
      read.textContent = 'Follow the link for the full article →';
      preview.append(label, definition, read);
      preview.hidden = false;

      const rect = link.getBoundingClientRect();
      const width = Math.min(340, window.innerWidth - 24);
      preview.style.maxWidth = width + 'px';
      preview.style.left = Math.max(12, Math.min(window.innerWidth - width - 12, rect.left)) + 'px';
      preview.style.top = Math.min(window.innerHeight - 180, rect.bottom + 10) + 'px';
    }

    function loadPreview(link) {
      const url = link.dataset.previewUrl;
      if (!url) return;
      clearTimeout(hideTimer);
      if (cache.has(url)) {
        showPreview(link, cache.get(url));
        return;
      }
      fetch(url, { headers: { Accept: 'application/json' } })
        .then(response => response.ok ? response.json() : Promise.reject(response.status))
        .then(payload => { cache.set(url, payload); showPreview(link, payload); })
        .catch(() => showPreview(link, { label: link.textContent, definition: link.dataset.definition }));
    }

    links.forEach(link => {
      link.addEventListener('mouseenter', () => loadPreview(link));
      link.addEventListener('focus', () => loadPreview(link));
      link.addEventListener('mouseleave', scheduleHide);
      link.addEventListener('blur', scheduleHide);
    });
    preview.addEventListener('mouseenter', () => clearTimeout(hideTimer));
    preview.addEventListener('mouseleave', scheduleHide);

    if (toggle && definitions && definitionList) {
      const seen = new Set();
      links.forEach(link => {
        if (seen.has(link.dataset.concept)) return;
        seen.add(link.dataset.concept);
        const item = document.createElement('div');
        item.className = 'concept-definition-item';
        const anchor = document.createElement('a');
        anchor.href = link.href;
        anchor.textContent = link.textContent;
        const text = document.createElement('span');
        text.textContent = link.dataset.definition || '';
        item.append(anchor, text);
        definitionList.appendChild(item);
      });

      toggle.addEventListener('click', () => {
        const open = toggle.getAttribute('aria-expanded') === 'true';
        toggle.setAttribute('aria-expanded', String(!open));
        toggle.textContent = open ? 'Show definitions' : 'Hide definitions';
        definitions.hidden = open;
      });
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initConceptWiki, { once: true });
  } else {
    initConceptWiki();
  }
})();
