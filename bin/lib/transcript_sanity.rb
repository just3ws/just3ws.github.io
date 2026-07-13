# frozen_string_literal: true

# Shared sanity checks for the transcription virtuous loop (produce → detect →
# correct → reprocess → promote). ONE definition of "is this output sane",
# called by both the detector (report_transcript_loops.rb) and the staging gate
# (stage_completed_transcripts.rb) — so a transcript flagged as looping is the
# same transcript refused promotion, with no threshold drift between them.
module TranscriptSanity
  module_function

  # ── Loop scoring (extracted verbatim from report_transcript_loops.rb) ──────
  # Returns { score, severity, consecutive_duplicates, max_sentence_run,
  #           line_repeat_ratio, ngram_repeat_ratio, reasons }. Empty text → nil.
  def loop_score(text)
    return nil if text.nil? || text.strip.empty?

    normalized = text.gsub(/\r\n?/, "\n")
    lines = normalized.lines.map(&:strip).reject(&:empty?)
    sentences = sentence_split(normalized)
    words = tokenize(normalized)

    consec_dup = 0
    max_run = 1
    run = 1
    (1...sentences.length).each do |i|
      if sentences[i].downcase == sentences[i - 1].downcase
        consec_dup += 1
        run += 1
        max_run = [max_run, run].max
      else
        run = 1
      end
    end

    line_counts = Hash.new(0)
    lines.each { |line| line_counts[line.downcase] += 1 }
    repeated_lines = line_counts.values.select { |v| v > 1 }.sum { |v| v - 1 }
    line_repeat_ratio = lines.empty? ? 0.0 : repeated_lines.to_f / lines.length

    n = 6
    grams = []
    (0..words.length - n).each { |i| grams << words[i, n].join(' ') } if words.length >= n
    gram_counts = Hash.new(0)
    grams.each { |g| gram_counts[g] += 1 }
    repeated_grams = gram_counts.values.select { |v| v > 1 }.sum { |v| v - 1 }
    gram_repeat_ratio = grams.empty? ? 0.0 : repeated_grams.to_f / grams.length

    score = (consec_dup * 3.0) + (max_run > 2 ? 5.0 : 0.0) +
            (line_repeat_ratio * 20.0) + (gram_repeat_ratio * 30.0)

    severity = if score >= 150 || max_run >= 20 then 'high'
               elsif score >= 35 || max_run >= 6 then 'medium'
               else 'low'
               end

    reasons = []
    reasons << "#{consec_dup} consecutive duplicate sentence pairs" if consec_dup > 0
    reasons << "max repeated sentence run #{max_run}" if max_run > 2
    reasons << format('line repeat ratio %.3f', line_repeat_ratio) if line_repeat_ratio >= 0.15
    reasons << format('6-gram repeat ratio %.3f', gram_repeat_ratio) if gram_repeat_ratio >= 0.20

    {
      'score' => score.round(2), 'severity' => severity,
      'consecutive_duplicates' => consec_dup, 'max_sentence_run' => max_run,
      'line_repeat_ratio' => line_repeat_ratio.round(3),
      'ngram_repeat_ratio' => gram_repeat_ratio.round(3), 'reasons' => reasons
    }
  end

  # report_transcript_loops keeps only score >= 6.0; mirror that cutoff so the
  # gate and the report agree on what counts as "flagged".
  def looping?(text, min_score: 6.0)
    s = loop_score(text)
    s && s['score'] >= min_score
  end

  # ── Diarization sanity ────────────────────────────────────────────────────
  # The mock diarizer (bin/diarize with HF_TOKEN="mock") and pyannote failures
  # both emit a degenerate sidecar — one speaker spanning the whole file. This
  # session shipped exactly that before the token fix. Returns [ok, reason].
  #   expect_multi: caller knows this is an interview (interviewees + 1 >= 2).
  def diarization_sane?(sidecar, expect_multi: false)
    return [true, nil] if sidecar.nil? # no sidecar is fine — diarize is opt-in
    return [false, "mock engine (#{sidecar['engine']})"] if sidecar['engine'].to_s.include?('mock')

    segs = Array(sidecar['segments'])
    return [false, 'no segments'] if segs.empty?

    # A single segment spanning (nearly) the whole file is the mock/pyannote-
    # failure shape — no real turn-taking was found. Suspicious regardless of
    # whether we know the expected speaker count.
    dur = sidecar['audio_duration'].to_f
    if segs.size == 1 && dur > 0 && (segs[0]['end'].to_f - segs[0]['start'].to_f) >= dur * 0.95
      return [false, 'single segment spans whole file']
    end

    speakers = segs.map { |s| s['speaker'] }.compact.uniq
    if expect_multi && speakers.size < 2
      return [false, "expected multiple speakers, found #{speakers.size}"]
    end
    [true, nil]
  end

  # ── shared tokenizers (verbatim from report_transcript_loops.rb) ───────────
  def sentence_split(text)
    text.split(/(?<=[.!?])\s+/).map { |s| s.strip.gsub(/\s+/, ' ') }.reject(&:empty?)
  end

  def tokenize(text)
    text.downcase.scan(/[a-z0-9']+/)
  end
end

# --- self-check: ruby bin/lib/transcript_sanity.rb -------------------------
if __FILE__ == $PROGRAM_NAME
  include TranscriptSanity
  # 25 identical sentences → max_sentence_run 25 (>= 20) → high (cf. the real
  # DHH loop, which had runs in the hundreds).
  loop_text = (["they're trying to do a lot of work."] * 25).join(' ')
  s = TranscriptSanity.loop_score(loop_text)
  raise "loop not high: #{s.inspect}" unless s['severity'] == 'high'
  raise 'looping? false negative' unless TranscriptSanity.looping?(loop_text)

  clean = 'Sure, so I think the identity of most programmers comes from a different age. ' \
          'That angle is software engineering. What they do is they write.'
  raise 'clean flagged as loop' if TranscriptSanity.looping?(clean)

  mock = { 'engine' => 'pyannote-3.1-mock', 'segments' => [{ 'start' => 0, 'end' => 942, 'speaker' => 'SPEAKER_00' }] }
  ok, why = TranscriptSanity.diarization_sane?(mock)
  raise 'mock passed' if ok
  raise "wrong reason: #{why}" unless why.include?('mock')

  real = { 'engine' => 'pyannote-3.1', 'segments' => [
    { 'start' => 0, 'end' => 10, 'speaker' => 'SPEAKER_00' },
    { 'start' => 10, 'end' => 20, 'speaker' => 'SPEAKER_01' }
  ] }
  ok2, = TranscriptSanity.diarization_sane?(real, expect_multi: true)
  raise 'real multi rejected' unless ok2

  degenerate = { 'engine' => 'pyannote-3.1', 'segments' => [{ 'start' => 0, 'end' => 942, 'speaker' => 'SPEAKER_00' }] }
  ok3, why3 = TranscriptSanity.diarization_sane?(degenerate, expect_multi: true)
  raise 'degenerate multi passed' if ok3
  raise "wrong degenerate reason: #{why3}" unless why3.include?('speaker')

  raise 'nil sidecar should pass' unless TranscriptSanity.diarization_sane?(nil).first

  puts 'transcript_sanity self-check OK'
end
