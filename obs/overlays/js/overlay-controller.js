/**
 * The Sound Above: Live Overlay Controller
 * Reads URL search parameters for overrides or polls overlay-state.json
 * Enables real-time overlay updates without refreshing OBS browser sources.
 */

class OverlayController {
  constructor(options = {}) {
    this.stateUrl = options.stateUrl || "overlay-state.json";
    this.pollInterval = options.pollInterval || 2500;
    this.onUpdate = options.onUpdate || (() => {});
    this.lastStateHash = "";
    this.init();
  }

  init() {
    this.applyUrlOverrides();
    this.fetchState();
    if (this.pollInterval > 0) {
      setInterval(() => this.fetchState(), this.pollInterval);
    }
  }

  applyUrlOverrides() {
    const params = new URLSearchParams(window.location.search);
    this.overrides = {};
    for (const [key, value] of params.entries()) {
      this.overrides[key] = value;
    }
  }

  async fetchState() {
    try {
      const url = `${this.stateUrl}?t=${Date.now()}`;
      const response = await fetch(url);
      if (!response.ok) return;

      const data = await response.json();
      const merged = this.mergeOverrides(data);
      const stateHash = JSON.stringify(merged);

      if (stateHash !== this.lastStateHash) {
        this.lastStateHash = stateHash;
        this.onUpdate(merged);
      }
    } catch (err) {
      // Local file access fallback: apply URL overrides if present
      if (Object.keys(this.overrides).length > 0) {
        this.onUpdate(this.mergeOverrides({}));
      }
    }
  }

  mergeOverrides(state) {
    const broadcastType = this.overrides.type || state.broadcast_type || "rewatch";
    const ep = state.episode || {};
    const stream = state.stream || {};
    const errata = state.errata || {};
    const dialogue = state.dialogue || {};

    return {
      broadcast_type: broadcastType,
      episode: {
        number: this.overrides.episode || ep.number || 1,
        title: this.overrides.title || ep.title || "Oral History Rewatch",
        interviewee: this.overrides.guest || this.overrides.interviewee || ep.interviewee || "Community Pioneer",
        role: this.overrides.role || ep.role || "Practitioner",
        conference: this.overrides.conference || this.overrides.event || ep.conference || "Chicago Archive",
        year: this.overrides.year || ep.year || "2011",
        era: this.overrides.era || ep.era || "Grassroots Craftsmanship",
        sound_above_prompt: this.overrides.prompt || ep.sound_above_prompt || "Tracing the echoes of early inspiration."
      },
      errata: {
        mode: this.overrides.mode || errata.mode || "concept",
        title: this.overrides.title || errata.title || ep.title || "Field Notes & Concept",
        subtitle: this.overrides.subtitle || errata.subtitle || "Marginalia & Systems Study",
        citation: this.overrides.citation || this.overrides.author || errata.citation || "Mike Hall (Field Notes)",
        excerpt_or_thesis: this.overrides.excerpt || this.overrides.quote || this.overrides.prompt || errata.excerpt_or_thesis || ep.sound_above_prompt || "",
        artifact_year: this.overrides.year || errata.artifact_year || "2026"
      },
      dialogue: {
        guests: dialogue.guests || [
          {
            name: this.overrides.guest || "Guest Practitioner",
            role: this.overrides.role || "Collaborator",
            affiliation: this.overrides.affiliation || ""
          }
        ],
        topic: this.overrides.topic || dialogue.topic || ep.title || "Craftsmanship Dialogue",
        prompt: this.overrides.prompt || dialogue.prompt || ep.sound_above_prompt || ""
      },
      stream: {
        series_title: this.overrides.series || stream.series_title || (broadcastType === "errata" ? "Errata" : (broadcastType === "dialogue" ? "The Room" : "The Sound Above")),
        series_subtitle: stream.series_subtitle || (broadcastType === "errata" ? "Marginalia, Readings & Demonstrations" : (broadcastType === "dialogue" ? "Invitational Conversations & Peer Inquiry" : "UGtastic Rewatch & Craftsmanship in the Age of AI")),
        host: this.overrides.host || stream.host || "Mike Hall (Software Craftsmanship #106)",
        topic: this.overrides.topic || stream.topic || ""
      }
    };
  }
}
