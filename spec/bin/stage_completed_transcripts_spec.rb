# frozen_string_literal: true

require_relative "../../bin/stage_completed_transcripts"

RSpec.describe "preferred_transcript_files" do
  it "prefers the corrected .cleaned.txt over raw variants for a video id" do
    files = %w[
      /r/ABC123.txt
      /r/ABC123.stitched.txt
      /r/ABC123.stitched.cleaned.txt
    ]
    expect(preferred_transcript_files(files)).to eq(["/r/ABC123.stitched.cleaned.txt"])
  end

  it "falls back to .stitched.txt when no cleaned variant exists" do
    files = %w[/r/ABC123.txt /r/ABC123.stitched.txt]
    expect(preferred_transcript_files(files)).to eq(["/r/ABC123.stitched.txt"])
  end

  it "keeps the plain <id>.txt when it is the only variant" do
    expect(preferred_transcript_files(["/d/ABC123.txt"])).to eq(["/d/ABC123.txt"])
  end

  it "returns exactly one file per distinct video id" do
    files = %w[/r/ABC.txt /r/ABC.cleaned.txt /r/XYZ.txt]
    expect(preferred_transcript_files(files).sort).to eq(["/r/ABC.cleaned.txt", "/r/XYZ.txt"])
  end
end
