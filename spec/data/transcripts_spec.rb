# frozen_string_literal: true

require "src/generators/archive_state"

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
end
