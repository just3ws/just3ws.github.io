# frozen_string_literal: true

RSpec.describe "transcript availability templates" do
  let(:interview_card) { File.read(File.expand_path("../../_includes/interview-card.html", __dir__)) }
  let(:video_asset_card) { File.read(File.expand_path("../../_includes/video-asset-card.html", __dir__)) }
  let(:video_asset_player) { File.read(File.expand_path("../../_includes/video-asset-player.html", __dir__)) }

  it "treats non-empty structured turns as available on interview cards" do
    expect(interview_card).to include("transcript_entry.content")
    expect(interview_card).to include("transcript_entry.turns and transcript_entry.turns.size > 0")
    expect(interview_card).to include('<span class="editorial-card-badge">Transcript</span>')
  end

  it "treats non-empty structured turns as available on video asset cards" do
    expect(video_asset_card).to include("transcript_entry.content")
    expect(video_asset_card).to include("transcript_entry.turns and transcript_entry.turns.size > 0")
    expect(video_asset_card).to include("has-transcript")
    expect(video_asset_card).to include("Transcript Available")
  end

  it "keeps the player aligned with the non-empty structured transcript predicate" do
    expect(video_asset_player).to include("transcript_data.turns and transcript_data.turns.size > 0")
    expect(video_asset_player).to include('{% assign transcript_content = "structured" %}')
  end
end
