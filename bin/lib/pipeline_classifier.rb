# frozen_string_literal: true

# ---
# name: pipeline_classifier.rb
# domain: media
# role: Local Jev-style System One decision classifier and state router
# description: Evaluates candidate transcripts, errors, and metadata against discrete option sets, returning strictly typed probability distributions and routing decisions with zero external cloud egress.
# ---

require 'json'

class PipelineClassifier
  ARCHETYPES = %w[freeform_field_notes structured_errata technical_rewatch].freeze
  ERROR_ACTIONS = %w[transient_network_retry audio_codec_resample credential_refresh quarantine_operator_review].freeze

  ARCHETYPE_MARKERS = {
    'freeform_field_notes' => {
      keywords: %w[walking trail morning mosquitoes hood woods suburban park weather path ramble ramblin casual stroll stream],
      weights: 1.5
    },
    'structured_errata' => {
      keywords: %w[errata demonstration dsp frequency waterfall 60hz 345kv clock drift scipy scipy.signal filter antenna hardware bug fix reproduction],
      weights: 2.0
    },
    'technical_rewatch' => {
      keywords: %w[rewatch movement curriculum scna railsconf goto chicago alt.net thoughtworks interview craftsmanship legacy paired episode acts],
      weights: 1.8
    }
  }.freeze

  ERROR_MARKERS = {
    'transient_network_retry' => {
      patterns: [
        /connection reset/i,
        /timeout/i,
        /econnreset/i,
        /etimedout/i,
        /503 service unavailable/i,
        /500 internal server error/i,
        /502 bad gateway/i,
        /504 gateway timeout/i,
        /429 too many requests/i,
        /backend error/i,
        /rate limit/i,
        /chunk upload failed/i,
        /broken pipe/i
      ],
      weight: 3.0
    },
    'audio_codec_resample' => {
      patterns: [
        /invalid audio stream/i,
        /unsupported sample rate/i,
        /unsupported codec/i,
        /pcm_s16le conversion error/i,
        /corrupted.*audio/i,
        /ffmpeg.*error/i,
        /sample rate/i,
        /channel count/i
      ],
      weight: 3.0
    },
    'credential_refresh' => {
      patterns: [
        /invalid_grant/i,
        /token expired/i,
        /authorization failed/i,
        /unauthorized/i,
        /401 unauthorized/i,
        /oauth/i,
        /credentials missing/i
      ],
      weight: 3.5
    },
    'quarantine_operator_review' => {
      patterns: [
        /nomethoderror/i,
        /syntaxerror/i,
        /typeerror/i,
        /argumenterror/i,
        /no such file or directory/i,
        /fatal/i,
        /unhandled/i
      ],
      weight: 2.5
    }
  }.freeze

  def initialize(options = {})
    @options = options
  end

  # Normalizes a hash of raw option scores into a probability distribution summing to 1.0
  def normalize_distribution(raw_scores)
    return {} if raw_scores.empty?

    # Shift scores to prevent numerical overflow with exponentiation
    max_score = raw_scores.values.max || 0.0
    exp_scores = raw_scores.transform_values { |score| Math.exp(score - max_score) }
    total_exp = exp_scores.values.sum

    if total_exp <= 0.0
      uniform = 1.0 / raw_scores.size
      return raw_scores.keys.each_with_object({}) { |k, h| h[k] = uniform.round(4) }
    end

    exp_scores.transform_values { |v| (v / total_exp).round(4) }
  end

  # Classifies raw spoken text into an ingestion archetype
  def classify_archetype(text, metadata: {})
    clean_text = text.to_s.downcase
    scores = ARCHETYPES.each_with_object({}) { |opt, h| h[opt] = 0.5 }

    ARCHETYPE_MARKERS.each do |archetype, cfg|
      cfg[:keywords].each do |kw|
        count = clean_text.scan(/\b#{Regexp.escape(kw)}\b/).size
        scores[archetype] += (count * cfg[:weights]) if count > 0
      end
    end

    # Metadata hints
    if metadata[:filename]
      fn = metadata[:filename].downcase
      scores['freeform_field_notes'] += 3.0 if fn.start_with?('vid_') || fn.include?('ramblin')
      scores['structured_errata'] += 3.0 if fn.include?('errata')
    end

    probabilities = normalize_distribution(scores)
    best_option, highest_prob = probabilities.max_by { |_opt, prob| prob }

    {
      decision: best_option,
      confidence: highest_prob,
      probabilities: probabilities,
      rationale: build_archetype_rationale(best_option, clean_text)
    }
  end

  # Classifies an error message into an actionable self-healing recovery decision
  def classify_error_triage(error_message, backtrace: [], context: {})
    full_diagnostic = "#{error_message}\n#{backtrace.first(5).join("\n")}"
    scores = ERROR_ACTIONS.each_with_object({}) { |act, h| h[act] = 0.2 }

    ERROR_MARKERS.each do |action, cfg|
      cfg[:patterns].each do |pattern|
        if full_diagnostic =~ pattern
          scores[action] += cfg[:weight]
        end
      end
    end

    # If no specific transient or auth error triggered, bias slightly to operator quarantine
    if scores.values.all? { |v| v <= 0.2 }
      scores['quarantine_operator_review'] += 2.0
    end

    probabilities = normalize_distribution(scores)
    best_action, highest_prob = probabilities.max_by { |_act, prob| prob }

    {
      decision: best_action,
      confidence: highest_prob,
      probabilities: probabilities,
      diagnostic: error_message.to_s.strip
    }
  end

  private

  def build_archetype_rationale(archetype, clean_text)
    markers = ARCHETYPE_MARKERS[archetype][:keywords].select { |kw| clean_text.include?(kw) }
    if markers.any?
      "Matched domain markers: #{markers.first(4).join(', ')}"
    else
      "Default confidence distribution across option set"
    end
  end
end
