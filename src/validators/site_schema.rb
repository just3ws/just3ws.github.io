# frozen_string_literal: true

require 'dry-validation'

module Validators
  class BaseContract < Dry::Validation::Contract
    config.messages.backend = :yaml
  end

  class PlatformContract < BaseContract
    params do
      required(:platform).filled(:string)
      required(:url).filled(:string)
      optional(:embed_url).maybe(:string)
    end
  end

  class InterviewContract < BaseContract
    params do
      required(:id).filled(:string)
      required(:title).filled(:string)
      required(:interviewer).filled(:string)
      required(:recorded_date).filled(:date)
      required(:video_asset_id).filled(:string)
      optional(:interviewees).array(:string)
      optional(:topic).maybe(:string)
      optional(:conference).maybe(:string)
      optional(:conference_year).maybe(:integer)
      optional(:community).maybe(:string)
    end
  end

  class VideoAssetContract < BaseContract
    params do
      required(:id).filled(:string)
      required(:title).filled(:string)
      required(:primary_platform).filled(:string)
      required(:published_date).filled(:date)
      required(:platforms).array(:hash)
      optional(:interview_id).maybe(:string)
      optional(:description).maybe(:string)
      optional(:topic).maybe(:string)
      optional(:tags).array(:string)
    end

    rule(:platforms).each do
      if value.is_a?(Hash)
        contract = PlatformContract.new
        result = contract.call(value)
        result.errors.to_h.each do |field, messages|
          key([:platforms, index, field]).failure(messages.join(', '))
        end
      end
    end
  end

  class ConferenceContract < BaseContract
    params do
      required(:name).filled(:string)
      required(:slug).filled(:string)
      optional(:conference).maybe(:string)
      optional(:year).maybe(:integer)
      optional(:location).maybe(:string)
      optional(:start_date).maybe(:date)
      optional(:end_date).maybe(:date)
      optional(:summary).maybe(:string)
      optional(:highlights).array(:string)
    end
  end

  class CommunityContract < BaseContract
    params do
      required(:name).filled(:string)
      required(:slug).filled(:string)
      optional(:summary).maybe(:string)
      optional(:highlights).array(:string)
    end
  end

  # Additive, backward-compatible diarization block. Legacy transcripts carry
  # no `diarization` key and are never routed here; when the block is present it
  # must describe the acoustic engine and its speaker segments. `start`/`end`
  # are left untyped on purpose (YAML yields Integer for `0` and Float for
  # `12.4`); the numeric + ordering constraints are enforced in a rule so a
  # bare Integer timestamp is not rejected by float coercion.
  class DiarizationSegmentContract < BaseContract
    params do
      required(:speaker).filled(:string)
      required(:start).filled
      required(:end).filled
      optional(:text).maybe(:string)
    end

    rule(:start) do
      key.failure('must be numeric') unless value.is_a?(Numeric)
    end

    rule(:end) do
      key.failure('must be numeric') unless value.is_a?(Numeric)
    end

    rule(:end, :start) do
      start_value = values[:start]
      end_value = values[:end]
      if start_value.is_a?(Numeric) && end_value.is_a?(Numeric) && end_value < start_value
        key([:end]).failure('must be greater than or equal to start')
      end
    end
  end

  class DiarizationContract < BaseContract
    params do
      required(:engine).filled(:string)
      required(:segments).array(:hash)
      optional(:model).maybe(:string)
      optional(:asr).maybe(:string)
      # Remaining metadata (generated_at, audio_duration, num_speakers_hint) is
      # left undeclared on purpose: dry-schema ignores unknown keys, so optional
      # producer fields never trip validation nor float coercion.
    end

    rule(:segments).each do |index:|
      if value.is_a?(Hash)
        contract = DiarizationSegmentContract.new
        result = contract.call(value)
        result.errors.to_h.each do |field, messages|
          key([:segments, index, field]).failure(Array(messages).join(', '))
        end
      end
    end
  end

  class ResumePositionContract < BaseContract
    params do
      required(:id).filled(:string)
      required(:title).filled(:string)
      required(:company).hash do
        required(:name).filled(:string)
        optional(:location).maybe(:string)
      end
      required(:start_date).filled
      optional(:end_date).maybe(:string)
      required(:summary).filled(:string)
      optional(:context).maybe(:string)
      optional(:action).maybe(:string)
      optional(:impact).maybe(:string)
      required(:highlights).value(:array)
    end

    rule(:highlights).each do
      next if value.is_a?(String) && !value.strip.empty?
      next if value.is_a?(Hash) && !value['text'].to_s.strip.empty?

      key([:highlights, index]).failure('must be a string or hash with text')
    end
  end
end
