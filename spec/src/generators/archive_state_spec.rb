# frozen_string_literal: true

require "src/generators/archive_state"

RSpec.describe Generators::ArchiveState do
  def write_yaml(path, data)
    File.write(path, data.to_yaml)
  end

  describe ".for_path" do
    it "reports content-only transcripts as legacy content" do
      Dir.mktmpdir do |dir|
        path = File.join(dir, "legacy.yml")
        write_yaml(path, "content" => "Hello from the archive.")

        state = described_class.for_path(path)

        expect(state.id).to eq("legacy")
        expect(state.load_status).to eq("loaded")
        expect(state).to be_parseable
        expect(state).to have_transcript
        expect(state.transcript_format).to eq("content")
        expect(state.text).to eq("Hello from the archive.")
        expect(state.word_count).to eq(4)
      end
    end

    it "reports turns-only transcripts as structured and joins turn text in order" do
      Dir.mktmpdir do |dir|
        path = File.join(dir, "structured.yml")
        write_yaml(
          path,
          "turns" => [
            { "speaker" => "M1", "text" => "First turn." },
            { "speaker" => "S1", "text" => "Second turn here." }
          ]
        )

        state = described_class.for_path(path)

        expect(state).to have_transcript
        expect(state.transcript_format).to eq("structured")
        expect(state.text).to eq("First turn.\n\nSecond turn here.")
        expect(state.word_count).to eq(5)
        expect(state.turn_count).to eq(2)
        expect(state.speakers).to eq(%w[M1 S1])
      end
    end

    it "reports missing transcript files without attempting to load them" do
      Dir.mktmpdir do |dir|
        path = File.join(dir, "missing.yml")

        state = described_class.for_path(path)

        expect(state.load_status).to eq("missing")
        expect(state).not_to be_parseable
        expect(state).not_to have_transcript
        expect(state.transcript_format).to eq("missing")
        expect(state.text).to eq("")
        expect(state.word_count).to eq(0)
      end
    end

    it "reports invalid yaml without counting it as transcript content" do
      Dir.mktmpdir do |dir|
        path = File.join(dir, "broken.yml")
        File.write(path, "content: [\n")

        state = described_class.for_path(path)

        expect(state.load_status).to eq("invalid")
        expect(state.load_error).not_to be_nil
        expect(state).not_to be_parseable
        expect(state).not_to have_transcript
        expect(state.transcript_format).to eq("invalid")
      end
    end

    it "keeps validation status separate from validation errors" do
      Dir.mktmpdir do |dir|
        path = File.join(dir, "validated-with-error.yml")
        write_yaml(
          path,
          "turns" => [{ "speaker" => "M1", "text" => "Still usable text." }],
          "validated_at" => "2026-05-21T13:25:33-05:00",
          "validation_error" => "Significant Word Count Drift"
        )

        state = described_class.for_path(path)

        expect(state).to be_validated
        expect(state.validation_error).to eq("Significant Word Count Drift")
        expect(state).to have_transcript
      end
    end

    it "reports enriched and indexed transcript fields" do
      Dir.mktmpdir do |dir|
        path = File.join(dir, "enriched.yml")
        write_yaml(
          path,
          "turns" => [{ "speaker" => "S1", "text" => "Indexed transcript text." }],
          "summary" => "A short summary.",
          "topics" => ["Ruby"],
          "insights" => [{ "statement" => "Durable point", "type" => "durable" }],
          "enriched_at" => "2026-05-22T12:28:54-05:00",
          "indexed_at" => "2026-05-22T12:37:38-05:00"
        )

        state = described_class.for_path(path, id: "custom-id")

        expect(state.id).to eq("custom-id")
        expect(state).to be_enriched
        expect(state).to be_indexed
        expect(state.to_h).to include(
          "id" => "custom-id",
          "transcript_format" => "structured",
          "enriched" => true,
          "indexed" => true,
          "text" => "Indexed transcript text."
        )
      end
    end
  end

  describe ".for_id" do
    it "loads transcripts by id from a transcripts directory" do
      Dir.mktmpdir do |dir|
        write_yaml(File.join(dir, "episode-one.yml"), "content" => "Loaded by id")

        state = described_class.for_id("episode-one", transcripts_dir: dir)

        expect(state.id).to eq("episode-one")
        expect(state.path).to eq(File.join(dir, "episode-one.yml"))
        expect(state.load_status).to eq("loaded")
        expect(state.text).to eq("Loaded by id")
      end
    end
  end

  describe ".from_data" do
    it "wraps already-loaded transcript data" do
      state = described_class.from_data(
        {
          "turns" => [{ "speaker" => "M1", "text" => "Already loaded." }]
        },
        id: "loaded"
      )

      expect(state.id).to eq("loaded")
      expect(state).to be_parseable
      expect(state.transcript_format).to eq("structured")
      expect(state.text).to eq("Already loaded.")
    end
  end
end
