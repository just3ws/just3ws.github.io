# frozen_string_literal: true

require "src/validators/site_schema"

RSpec.describe Validators::DiarizationContract do
  subject(:contract) { described_class.new }

  def block(overrides = {})
    {
      "engine" => "pyannote-3.1",
      "model" => "pyannote/speaker-diarization-3.1",
      "asr" => "whisper.cpp",
      "audio_duration" => 865.6,
      "num_speakers_hint" => 2,
      "segments" => [
        { "speaker" => "SPEAKER_00", "start" => 0, "end" => 12.4 },
        { "speaker" => "SPEAKER_01", "start" => 12.4, "end" => 20.0 }
      ]
    }.merge(overrides)
  end

  it "accepts a well-formed diarization block" do
    expect(contract.call(block)).to be_success
  end

  it "accepts integer timestamps without float coercion errors" do
    result = contract.call(
      block("segments" => [{ "speaker" => "SPEAKER_00", "start" => 0, "end" => 30 }])
    )

    expect(result).to be_success
  end

  it "requires an engine string" do
    result = contract.call(block("engine" => ""))

    expect(result).not_to be_success
    expect(result.errors.to_h).to have_key(:engine)
  end

  it "requires a segments array" do
    result = contract.call(block.reject { |k, _| k == "segments" })

    expect(result).not_to be_success
    expect(result.errors.to_h).to have_key(:segments)
  end

  it "rejects a segment whose start is after its end" do
    result = contract.call(
      block("segments" => [{ "speaker" => "SPEAKER_00", "start" => 20.0, "end" => 5.0 }])
    )

    expect(result).not_to be_success
    expect(result.errors.to_h[:segments]).to be_truthy
  end

  it "rejects a segment missing its speaker label" do
    result = contract.call(
      block("segments" => [{ "start" => 0.0, "end" => 5.0 }])
    )

    expect(result).not_to be_success
    expect(result.errors.to_h[:segments]).to be_truthy
  end

  it "rejects a non-numeric timestamp" do
    result = contract.call(
      block("segments" => [{ "speaker" => "SPEAKER_00", "start" => "zero", "end" => 5.0 }])
    )

    expect(result).not_to be_success
    expect(result.errors.to_h[:segments]).to be_truthy
  end
end
