# frozen_string_literal: true

require 'spec_helper'
require_relative '../../bin/lib/pipeline_classifier'

RSpec.describe PipelineClassifier do
  subject(:classifier) { described_class.new }

  describe '#classify' do
    it 'normalizes probability distributions across arbitrary options' do
      scores = { 'option_a' => 8.0, 'option_b' => 2.0, 'option_c' => 0.0 }
      result = classifier.normalize_distribution(scores)

      expect(result['option_a']).to be > result['option_b']
      expect(result['option_b']).to be > result['option_c']
      sum = result.values.sum
      expect((sum - 1.0).abs).to be < 0.001
    end
  end

  describe '#classify_archetype' do
    it 'classifies outdoor stream-of-consciousness video into freeform_field_notes' do
      text = "Good morning everyone. I am walking along the suburban trail today. It is a bit chilly out, and I am wearing a hood because of the mosquitoes. I wanted to talk about a lesser man who had some thoughts on production incidents."
      result = classifier.classify_archetype(text)

      expect(result[:decision]).to eq('freeform_field_notes')
      expect(result[:confidence]).to be >= 0.60
      expect(result[:probabilities]['freeform_field_notes']).to be > result[:probabilities]['structured_errata']
    end

    it 'classifies forensic audio DSP walkthrough into structured_errata' do
      text = "In this Errata episode we are doing a technical demonstration of audio DSP recovery under 345kV power lines. We show how Gemini hallucinated a 20 percent clock drift when in reality it was inductive loop antenna rumble that 4 lines of scipy code eliminated."
      result = classifier.classify_archetype(text)

      expect(result[:decision]).to eq('structured_errata')
      expect(result[:confidence]).to be >= 0.60
      expect(result[:probabilities]['structured_errata']).to be > result[:probabilities]['freeform_field_notes']
    end

    it 'classifies historical conference retrospective into technical_rewatch' do
      text = "Welcome to Movement 1 of The Sound Above curriculum. Today we rewatch the 2011 SCNA interview with Sergio Pereira discussing Chicago Alt.NET, practical autonomy in enterprise software, and the foundational practices of software craftsmanship."
      result = classifier.classify_archetype(text)

      expect(result[:decision]).to eq('technical_rewatch')
      expect(result[:confidence]).to be >= 0.60
      expect(result[:probabilities]['technical_rewatch']).to be > result[:probabilities]['freeform_field_notes']
    end
  end

  describe '#classify_error_triage' do
    it 'routes network reset and timeout errors to transient_network_retry' do
      error = Errno::ECONNRESET.new('Connection reset by peer')
      result = classifier.classify_error_triage(error.message, backtrace: ['/lib/net/http.rb:120'])

      expect(result[:decision]).to eq('transient_network_retry')
      expect(result[:confidence]).to be >= 0.70
    end

    it 'routes YouTube API rate limits and 503 errors to transient_network_retry' do
      msg = 'Google::Apis::ServerError: 503 Service Unavailable Backend Error'
      result = classifier.classify_error_triage(msg)

      expect(result[:decision]).to eq('transient_network_retry')
      expect(result[:confidence]).to be >= 0.70
    end

    it 'routes audio conversion and ffmpeg stream errors to audio_codec_resample' do
      msg = 'ffmpeg: Invalid audio stream, unsupported sample rate 44100Hz or corrupted pcm_s16le track'
      result = classifier.classify_error_triage(msg)

      expect(result[:decision]).to eq('audio_codec_resample')
      expect(result[:confidence]).to be >= 0.65
    end

    it 'routes invalid_grant and token expiration errors to credential_refresh' do
      msg = 'Signet::AuthorizationError: Authorization failed. Server message: { "error": "invalid_grant" }'
      result = classifier.classify_error_triage(msg)

      expect(result[:decision]).to eq('credential_refresh')
      expect(result[:confidence]).to be >= 0.80
    end

    it 'routes unhandled runtime exceptions to quarantine_operator_review' do
      msg = "NoMethodError: undefined method 'foo' for nil:NilClass"
      result = classifier.classify_error_triage(msg)

      expect(result[:decision]).to eq('quarantine_operator_review')
      expect(result[:confidence]).to be >= 0.70
    end
  end
end
