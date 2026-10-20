import mermaid from "https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs";

const isElementHidden = (el) => {
  if (!el) return false;
  if (el.closest('[hidden], details:not([open])')) return true;
  let curr = el;
  while (curr && curr !== document.body) {
    if (curr.style && curr.style.display === "none") return true;
    curr = curr.parentElement;
  }
  return false;
};

const renderMermaid = async (root = document) => {
  const container = typeof root === "string" ? document.querySelector(root) : root;
  if (!container) return;

  const sourceBlocks = container.querySelectorAll("pre > code.language-mermaid");

  mermaid.initialize({
    startOnLoad: false,
    securityLevel: "strict",
    theme: "base",
    look: "classic",
    flowchart: {
      curve: "basis",
      htmlLabels: true,
      useMaxWidth: true
    },
    sequence: {
      useMaxWidth: true,
      wrap: true,
      mirrorActors: false
    },
    themeVariables: {
      background: "transparent",
      primaryColor: "#e6f4f1",
      primaryTextColor: "#1e232a",
      primaryBorderColor: "#0f766e",
      lineColor: "#64706c",
      secondaryColor: "#f7efe1",
      secondaryTextColor: "#1e232a",
      secondaryBorderColor: "#b45309",
      tertiaryColor: "#f4f6f5",
      tertiaryTextColor: "#1e232a",
      tertiaryBorderColor: "#8c9a96",
      actorBkg: "#e6f4f1",
      actorBorder: "#0f766e",
      actorTextColor: "#1e232a",
      signalColor: "#0f766e",
      signalTextColor: "#1e232a",
      noteBkgColor: "#f7efe1",
      noteBorderColor: "#b45309",
      noteTextColor: "#1e232a",
      fontFamily: "Inter, system-ui, sans-serif",
      fontSize: "13.5px"
    }
  });

  sourceBlocks.forEach((source) => {
    const rawText = source.textContent.trim();
    const sourceId = source.id;
    const diagram = document.createElement("div");
    diagram.className = "mermaid-diagram";
    if (sourceId) diagram.id = sourceId;
    diagram.dataset.mermaidSource = rawText;
    diagram.setAttribute("role", "img");
    diagram.setAttribute("aria-label", "Engineering process diagram");
    diagram.textContent = rawText;
    source.parentElement.replaceWith(diagram);
  });

  const allDiagrams = Array.from(container.querySelectorAll(".mermaid-diagram:not([data-processed='true'])"));
  const visibleDiagrams = allDiagrams.filter((diag) => !isElementHidden(diag));

  if (!visibleDiagrams.length) return;

  for (const diagram of visibleDiagrams) {
    try {
      await mermaid.run({ nodes: [diagram] });
    } catch (error) {
      diagram.classList.add("mermaid-diagram-error");
      diagram.setAttribute("role", "region");
      diagram.setAttribute("aria-label", "Diagram source, rendering unavailable");
      console.warn("Mermaid diagram rendering failed; source remains available.", error);
    }
  }
};

window.renderMermaid = renderMermaid;
window.addEventListener("render-mermaid", (e) => {
  renderMermaid(e.detail && e.detail.root ? e.detail.root : document);
});

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", () => renderMermaid(), { once: true });
} else {
  renderMermaid();
}
