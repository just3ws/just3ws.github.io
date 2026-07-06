# frozen_string_literal: true

require "src/generators/archive_state"
require "src/validators/site_schema"

RSpec.describe "transcript data" do
  it "keeps every public transcript YAML file parseable" do
    transcript_paths = Dir.glob(File.expand_path("../../_data/transcripts/*.yml", __dir__)).sort
    invalid = transcript_paths.filter_map do |path|
      state = Generators::ArchiveState.for_path(path)
      next unless state.invalid?

      "#{path.sub("#{Dir.pwd}/", "")}: #{state.load_error}"
    end

    expect(invalid).to eq([])
  end

  it "validates any transcript that carries an additive diarization block" do
    contract = Validators::DiarizationContract.new
    transcript_paths = Dir.glob(File.expand_path("../../_data/transcripts/*.yml", __dir__)).sort

    failures = transcript_paths.filter_map do |path|
      state = Generators::ArchiveState.for_path(path)
      block = state.data["diarization"]
      next unless block.is_a?(Hash)

      result = contract.call(block)
      next if result.success?

      "#{path.sub("#{Dir.pwd}/", "")}: #{result.errors.to_h}"
    end

    expect(failures).to eq([])
  end

  it "accepts a well-formed diarization block and leaves plain transcripts valid" do
    contract = Validators::DiarizationContract.new

    diarized = {
      "engine" => "pyannote-3.1",
      "model" => "pyannote/speaker-diarization-3.1",
      "asr" => "whisper.cpp",
      "audio_duration" => 865.6,
      "num_speakers_hint" => 2,
      "segments" => [
        { "speaker" => "SPEAKER_00", "start" => 0, "end" => 12.4 },
        { "speaker" => "SPEAKER_01", "start" => 12.4, "end" => 20.0 }
      ]
    }

    expect(contract.call(diarized)).to be_success

    plain = Generators::ArchiveState.from_data({ "content" => "No diarization block." })
    expect(plain.data.key?("diarization")).to be(false)
  end
end
