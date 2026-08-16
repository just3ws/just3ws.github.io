# frozen_string_literal: true

# bin/lib/diarization_map.rb — Diarization Schema Validator & Speaker Mapping Module
#
# Implements TASK-244:
# - Validates additive `diarization:` schema block on transcript YAML files
# - Provides helpers for mapping acoustic speaker labels (SPEAKER_00, SPEAKER_01) to named speakers (M1, S1, S2)

module DiarizationMap
  REQUIRED_DIARIZATION_KEYS = %w[engine model asr generated_at audio_duration num_speakers_hint segments].freeze
  REQUIRED_SEGMENT_KEYS = %w[speaker start end text].freeze

  class ValidationError < StandardError; end

  def self.validate_transcript_diarization(data, filepath = "transcript")
    return true unless data.key?("diarization")

    diag = data["diarization"]
    unless diag.is_a?(Hash)
      raise ValidationError, "#{filepath}: 'diarization' block must be a Hash"
    end

    missing_keys = REQUIRED_DIARIZATION_KEYS - diag.keys
    unless missing_keys.empty?
      raise ValidationError, "#{filepath}: 'diarization' block missing keys: #{missing_keys.join(', ')}"
    end

    segments = diag["segments"]
    unless segments.is_a?(Array)
      raise ValidationError, "#{filepath}: 'diarization.segments' must be an Array"
    end

    segments.each_with_index do |seg, idx|
      unless seg.is_a?(Hash)
        raise ValidationError, "#{filepath}: segment #{idx} must be a Hash"
      end

      missing_seg = REQUIRED_SEGMENT_KEYS - seg.keys
      unless missing_seg.empty?
        raise ValidationError, "#{filepath}: segment #{idx} missing keys: #{missing_seg.join(', ')}"
      end

      unless seg["start"].is_a?(Numeric) && seg["end"].is_a?(Numeric)
        raise ValidationError, "#{filepath}: segment #{idx} 'start' and 'end' must be numeric floats"
      end
    end

    true
  end

  def self.map_acoustic_labels(segments, speaker_map)
    # speaker_map: e.g. { "M1" => "Mike Hall", "S1" => "Dave Thomas" }
    segments.map do |seg|
      speaker_id = seg["speaker"]
      named_speaker = speaker_map[speaker_id] || speaker_id
      seg.merge("named_speaker" => named_speaker)
    end
  end
end
