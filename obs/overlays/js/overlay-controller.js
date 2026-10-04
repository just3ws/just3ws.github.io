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
    const ep = state.episode || {};
    const stream = state.stream || {};

    return {
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
      stream: {
        series_title: this.overrides.series || stream.series_title || "The Sound Above",
        series_subtitle: stream.series_subtitle || "UGtastic Rewatch & Craftsmanship in the Age of AI",
        host: this.overrides.host || stream.host || "Mike Hall (Signatory #106)",
        topic: this.overrides.topic || stream.topic || ""
      }
    };
  }
}
