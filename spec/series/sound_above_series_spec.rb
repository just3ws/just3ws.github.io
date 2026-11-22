# frozen_string_literal: true

require 'json'
require 'yaml'

RSpec.describe "The Sound Above Rewatch Series Artifacts" do
  let(:manifest_file) { File.expand_path("../../obs/curation/sequence-manifest.json", __dir__) }
  let(:schema_file) { File.expand_path("../../obs/schemas/sequence-manifest.schema.json", __dir__) }
  let(:episode_one_html) { File.expand_path("../../series/the-sound-above/episode-01.html", __dir__) }

  it "verifies the archive catalog and flexible Season One target" do
    expect(File.exist?(manifest_file)).to be true
    manifest = JSON.parse(File.read(manifest_file))
    expect(manifest["status"]).to eq("working_plan")
    expect(manifest["season_one_target"]).to eq(17)
    expect(manifest["archive_record_count"]).to eq(35)
    expect(manifest["episodes"].size).to eq(35)

    numbers = manifest["episodes"].map { |ep| ep["number"] }
    expect(numbers).to eq((1..35).to_a)
  end

  it "keeps non-interview broadcasts as codas, separate from the rewatch episodes" do
    manifest = JSON.parse(File.read(manifest_file))
    expect(manifest["total_codas"]).to eq(2)
    expect(manifest["codas"].map { |c| c["kind"] }.uniq).to eq(["coda"])
    expect(manifest["episodes"].map { |e| e["kind"] }.uniq).to eq(["interview"])
  end

  it "maps every episode to a real archive interview" do
    manifest = JSON.parse(File.read(manifest_file))
    interviews = YAML.safe_load(File.read(File.expand_path("../../_data/interviews.yml", __dir__)), permitted_classes: [Date, Time], aliases: true)["items"]
    ids = interviews.map { |i| i["id"] }
    manifest["episodes"].each do |ep|
      expect(ids).to include(ep["slug"]), "Episode #{ep['number']} (#{ep['slug']}) is not an archive interview"
    end
  end

  it "verifies each manifest episode has required editorial inquiry and historical context" do
    manifest = JSON.parse(File.read(manifest_file))
    manifest["episodes"].each do |ep|
      expect(ep["title"]).to be_a(String), "Missing title for episode #{ep['number']}"
      expect(ep["interviewee"]).to be_a(String), "Missing interviewee for episode #{ep['number']}"
      expect(ep["sound_above_inquiry"]).to be_a(String), "Missing inquiry for episode #{ep['number']}"
      expect(ep["chicago_context"]).to be_a(String), "Missing chicago context for episode #{ep['number']}"
      expect(ep["ai_era_parallel"]).to be_nil.or(be_a(String))
      expect(ep["slug"]).to be_a(String), "Missing slug for episode #{ep['number']}"
    end
  end

  it "verifies episode-01.html has valid frontmatter, player embed, and Schema.org VideoObject" do
    expect(File.exist?(episode_one_html)).to be true
    content = File.read(episode_one_html)

    # Jekyll frontmatter check
    expect(content).to match(/\A---\s*\n.*?\n---\s*\n/m)
    frontmatter = YAML.safe_load(content.match(/\A---\s*\n(.*?)\n---\s*\n/m)[1])
    expect(["minimal", "series_episode"]).to include(frontmatter["layout"])
    expect(frontmatter["permalink"]).to eq("/series/the-sound-above/episode-01/")
    expect(frontmatter["title"]).to include("Episode 1")

    # Templatized layout provides player embed and Schema.org VideoObject
    layout_file = File.expand_path("../../_layouts/series_episode.html", __dir__)
    expect(File.exist?(layout_file)).to be true
    layout_content = File.read(layout_file)
    expect(layout_content).to include("embedUrl")
    expect(layout_content).to include("canonical-stage-heading")
    expect(layout_content).to include('"@type": "VideoObject"')
  end

  it "enforces canonical casing for Alt.NET in series narrative prose and metadata" do
    content = File.read(episode_one_html)
    # Prohibit Alt.Net, alt.net, or AltNet in narrative text
    expect(content).not_to match(/\bAlt\.Net\b/)
    expect(content).not_to match(/\balt\.net\b/)
    expect(content).to include("Alt.NET")
  end
end
