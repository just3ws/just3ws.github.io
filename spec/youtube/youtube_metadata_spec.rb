# frozen_string_literal: true

require 'json'
require 'yaml'
require_relative '../../src/validators/site_schema'

RSpec.describe "YouTube Metadata & 1:1 Parity Suite" do
  let(:staged_file) { "_data/youtube_metadata_staged.json" }
  let(:contract) { Validators::YouTubeStagedMetadataContract.new }

  it "validates all staged metadata packages against the Dry-Validation schema contract" do
    expect(File.exist?(staged_file)).to be true
    staged_data = JSON.parse(File.read(staged_file))

    staged_data.each do |item|
      result = contract.call(item)
      expect(result).to be_success, "Validation failed for #{item['youtube_video_id']}: #{result.errors.to_h}"
    end
  end

  it "enforces humane title lengths (<= 100 characters) and conference/event provenance" do
    staged_data = JSON.parse(File.read(staged_file))
    staged_data.each do |item|
      title = item["title"]
      expect(title.length).to be <= 100
      expect(title).to match(/\|/)
    end
  end

  it "enforces description safety (no raw hashtags, contains canonical link and speakers)" do
    staged_data = JSON.parse(File.read(staged_file))
    staged_data.each do |item|
      desc = item["description"]
      expect(desc).not_to match(/#\w+/), "Description should not contain social media hashtags"
      expect(desc).to include("https://www.just3ws.com/interviews/")
      expect(desc).to match(/🎙️ SPEAKERS:|🏛️ ORAL HISTORY RECORD:/)
      expect(desc).to include("⏱️ CHAPTERS:")
    end
  end

  it "ensures chapter timestamps always start at 00:00 for YouTube player compatibility" do
    staged_data = JSON.parse(File.read(staged_file))
    staged_data.each do |item|
      chapters = item["chapters"]
      expect(chapters).not_to be_empty
      expect(chapters.first["time"]).to eq("00:00")
    end
  end
end
