(() => {
  const imgs = Array.from(document.querySelectorAll('img[src*="/assets/diagrams/"][src$=".svg"]'));
  if (!imgs.length) return;

  const style = document.createElement("style");
  style.textContent = `
    .diagram-zoom-wrap { position: relative; }
    .diagram-zoom-trigger {
      cursor: zoom-in;
      transition: transform 0.15s ease, box-shadow 0.15s ease;
    }
    .diagram-zoom-trigger:hover {
      box-shadow: 0 4px 16px rgba(15, 118, 110, 0.14);
    }
    .diagram-zoom-btn {
      position: absolute;
      top: 0.65rem;
      right: 0.65rem;
      min-height: 44px;
      padding: 0.45rem 0.8rem;
      border-radius: 6px;
      border: 1px solid var(--color-border, #e3dfd7);
      background: var(--color-bg-card, #ffffff);
      color: var(--color-primary, #0f766e);
      font: 700 0.8rem/1 var(--font-sans-ui, system-ui, sans-serif);
      cursor: pointer;
      box-shadow: 0 2px 8px rgba(0,0,0,0.08);
    }
    .diagram-zoom-btn:focus-visible {
      outline: 2px solid var(--color-primary, #0f766e);
      outline-offset: 2px;
    }
    dialog.diagram-lightbox {
      width: min(96vw, 1400px);
      height: min(92vh, 920px);
      padding: 0;
      border: 1px solid var(--color-border, #e3dfd7);
      border-radius: 12px;
      background: var(--color-bg-card, #ffffff);
      color: var(--color-text-main, #1e232a);
      box-shadow: 0 24px 64px rgba(0, 0, 0, 0.35);
      overflow: hidden;
    }
    dialog.diagram-lightbox::backdrop {
      background: rgba(15, 23, 42, 0.72);
      backdrop-filter: blur(3px);
    }
    .diagram-lb-shell {
      display: flex;
      flex-direction: column;
      height: 100%;
    }
    .diagram-lb-bar {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 0.75rem;
      padding: 0.6rem 1rem;
      border-bottom: 1px solid var(--color-border, #e3dfd7);
      background: var(--color-bg-subtle, #f4f0e8);
      font-family: var(--font-sans-ui, system-ui, sans-serif);
    }
    .diagram-lb-title {
      font-size: 0.86rem;
      font-weight: 700;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }
    .diagram-lb-controls {
      display: flex;
      align-items: center;
      gap: 0.4rem;
      flex-shrink: 0;
    }
    .diagram-lb-controls button,
    .diagram-lb-controls a {
      min-width: 44px;
      min-height: 44px;
      padding: 0 0.75rem;
      display: inline-flex;
      align-items: center;
      justify-content: center;
      border-radius: 6px;
      border: 1px solid var(--color-border, #e3dfd7);
      background: var(--color-bg-card, #ffffff);
      color: var(--color-text-main, #1e232a);
      font-size: 0.85rem;
      font-weight: 700;
      text-decoration: none;
      cursor: pointer;
    }
    .diagram-lb-stage {
      flex: 1;
      overflow: hidden;
      position: relative;
      cursor: grab;
      display: flex;
      align-items: center;
      justify-content: center;
      background: var(--color-bg-card, #ffffff);
      touch-action: none;
    }
    .diagram-lb-stage.dragging { cursor: grabbing; }
    .diagram-lb-stage img {
      max-width: 92%;
      max-height: 92%;
      transform-origin: center center;
      user-select: none;
      pointer-events: none;
    }
  `;
  document.head.appendChild(style);

  const dialog = document.createElement("dialog");
  dialog.className = "diagram-lightbox";
  dialog.setAttribute("aria-label", "Interactive diagram viewer");
  dialog.innerHTML = `
    <div class="diagram-lb-shell">
      <div class="diagram-lb-bar">
        <span class="diagram-lb-title" id="diagramLbTitle">Architecture Diagram</span>
        <div class="diagram-lb-controls">
          <button type="button" data-action="zoom-out" aria-label="Zoom out">-</button>
          <button type="button" data-action="reset" aria-label="Reset zoom">100%</button>
          <button type="button" data-action="zoom-in" aria-label="Zoom in">+</button>
          <a href="#" id="diagramLbRaw" target="_blank" rel="noopener">Raw SVG</a>
          <button type="button" data-action="close" aria-label="Close viewer">Close</button>
        </div>
      </div>
      <div class="diagram-lb-stage" id="diagramLbStage">
        <img id="diagramLbImg" alt="">
      </div>
    </div>
  `;
  document.body.appendChild(dialog);

  const stage = dialog.querySelector("#diagramLbStage");
  const lbImg = dialog.querySelector("#diagramLbImg");
  const lbTitle = dialog.querySelector("#diagramLbTitle");
  const lbRaw = dialog.querySelector("#diagramLbRaw");
  const resetBtn = dialog.querySelector('[data-action="reset"]');

  let scale = 1;
  let tx = 0;
  let ty = 0;
  let dragging = false;
  let startX = 0;
  let startY = 0;

  const applyTransform = () => {
    lbImg.style.transform = `translate(${tx}px, ${ty}px) scale(${scale})`;
    resetBtn.textContent = `${Math.round(scale * 100)}%`;
  };

  const openViewer = (img) => {
    lbImg.src = img.src;
    lbImg.alt = img.alt || "Architecture diagram";
    lbTitle.textContent = img.alt || "Architecture diagram";
    lbRaw.href = img.src;
    scale = 1;
    tx = 0;
    ty = 0;
    applyTransform();
    dialog.showModal();
  };

  dialog.addEventListener("click", (e) => {
    if (e.target === dialog) dialog.close();
    const btn = e.target.closest("button[data-action]");
    if (!btn) return;
    const action = btn.dataset.action;
    if (action === "zoom-in") { scale = Math.min(4, +(scale + 0.35).toFixed(2)); applyTransform(); }
    if (action === "zoom-out") { scale = Math.max(0.5, +(scale - 0.35).toFixed(2)); applyTransform(); }
    if (action === "reset") { scale = 1; tx = 0; ty = 0; applyTransform(); }
    if (action === "close") dialog.close();
  });

  stage.addEventListener("wheel", (e) => {
    e.preventDefault();
    const delta = e.deltaY < 0 ? 0.18 : -0.18;
    scale = Math.min(4, Math.max(0.5, +(scale + delta).toFixed(2)));
    applyTransform();
  }, { passive: false });

  stage.addEventListener("pointerdown", (e) => {
    dragging = true;
    startX = e.clientX - tx;
    startY = e.clientY - ty;
    stage.classList.add("dragging");
    stage.setPointerCapture(e.pointerId);
  });
  stage.addEventListener("pointermove", (e) => {
    if (!dragging) return;
    tx = e.clientX - startX;
    ty = e.clientY - startY;
    applyTransform();
  });
  stage.addEventListener("pointerup", () => {
    dragging = false;
    stage.classList.remove("dragging");
  });

  imgs.forEach((img) => {
    img.classList.add("diagram-zoom-trigger");
    img.addEventListener("click", () => openViewer(img));
    const parent = img.parentElement;
    if (parent) {
      parent.classList.add("diagram-zoom-wrap");
      const btn = document.createElement("button");
      btn.type = "button";
      btn.className = "diagram-zoom-btn";
      btn.textContent = "Inspect / Zoom";
      btn.addEventListener("click", () => openViewer(img));
      parent.appendChild(btn);
    }
  });
})();
