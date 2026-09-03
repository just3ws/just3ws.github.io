require "json"
require "tmpdir"
require_relative "../../bin/lib/corpus_metrics"

RSpec.describe CorpusMetrics do
  it "summarizes a manifest and transcript directory" do
    Dir.mktmpdir do |dir|
      manifest = File.join(dir, "episodes.yml")
      File.write(manifest, {"items" => [
        {"id" => "one", "duration_minutes" => 30, "tags" => ["ruby"], "date" => "2024-01-01"},
        {"id" => "two", "duration" => "01:15:00", "tags" => ["ruby", "rails"], "date" => "2024-01-02"}
      ]}.to_yaml)
      transcript = File.join(dir, "episode-1-transcript.yml")
      File.write(transcript, {"speaker_map" => {"A" => {"name" => "Alex"}}, "turns" => [{"speaker" => "A", "text" => "Hello"}, {"speaker" => "A", "text" => "World"}]}.to_yaml)

      report = described_class.build([{"name" => "Test", "manifests" => [{"path" => manifest, "kind" => "episodes"}], "transcripts" => [File.join(dir, "*-transcript.yml")]}])
      corpus = report.fetch("corpora").first
      expect(corpus["record_counts"]).to eq("episodes" => 2, "transcripts" => 1)
      expect(corpus["duration_seconds"]).to eq(6_300.0)
      expect(corpus.dig("transcripts", "turns")).to eq(2)
      expect(corpus.dig("transcripts", "unique_speaker_labels")).to eq(1)
      expect(corpus["top_tags"]).to include("ruby" => 2)
    end
  end

  it "combines named corpuses without changing their individual reports" do
    report = described_class.build([
      {"name" => "A", "manifests" => []},
      {"name" => "B", "manifests" => []}
    ])
    expect(report["corpora"].map { |corpus| corpus["name"] }).to eq(["A", "B"])
    expect(report.dig("combined", "total_records")).to eq(0)
  end

  it "loads Markdown as a text record" do
    Dir.mktmpdir do |dir|
      path = File.join(dir, "note.md")
      File.write(path, "---\ntitle: A Note\n---\n# Heading\n\nRead [the archive](/interviews/).")
      record = described_class.records(described_class.load_file(path)).first
      expect(record["title"]).to eq("A Note")
      expect(record["content"]).to include("# Heading")
    end
  end
end
