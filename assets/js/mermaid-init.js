import mermaid from "https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs";

const renderMermaid = async () => {
  const sourceBlocks = document.querySelectorAll("pre > code.language-mermaid");

  if (!sourceBlocks.length) return;

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
      fontSize: "16px"
    }
  });

  sourceBlocks.forEach((source) => {
    const diagram = document.createElement("div");
    diagram.className = "mermaid-diagram";
    diagram.setAttribute("role", "img");
    diagram.setAttribute("aria-label", "Engineering process diagram");
    diagram.textContent = source.textContent.trim();
    source.parentElement.replaceWith(diagram);
  });

  try {
    await mermaid.run({ querySelector: ".mermaid-diagram" });
  } catch (error) {
    document.querySelectorAll(".mermaid-diagram").forEach((diagram) => {
      diagram.classList.add("mermaid-diagram-error");
      diagram.setAttribute("role", "region");
      diagram.setAttribute("aria-label", "Diagram source, rendering unavailable");
    });
    console.warn("Mermaid diagram rendering failed; source remains available.", error);
  }
};

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", renderMermaid, { once: true });
} else {
  renderMermaid();
}
