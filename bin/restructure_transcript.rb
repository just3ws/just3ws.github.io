#!/usr/bin/env ruby
# frozen_string_literal: true
#
# restructure_transcript.rb — refresh an already-structured transcript from the
# reprocessed (loop-free, name-corrected) ASR WITHOUT the destructive flat
# importer. Automates the deterministic parts of the DHH recipe (commit a55a404);
# the speaker-turn structuring itself is the judgment step done by the operator/LLM.
#
#   list                       transcript_ids whose displayed text still loops
#   prep  <transcript_id>      print the clean interview text (fresh ASR, jingle
#                              trimmed via the recording boundaries) + speaker_map
#   apply <transcript_id> <turns.yml>
#                              replace turns from turns.yml, preserve speaker_map +
#                              recording block, refresh provenance, write + verify
#   auto  <transcript_id>      prep → structure via `claude -p` (frontier quality,
#                              runs on the Claude subscription) → apply. End-to-end.
#
# turns.yml format: a YAML array of { speaker: M1|S1|..., text: "..." }.
require "yaml"
require "json"
require_relative "lib/transcript_sanity"
require_relative "../src/generators/core/yaml_io"
require_relative "../src/generators/archive_state"

ROOT            = File.expand_path("..", __dir__)
TRANSCRIPTS_DIR = File.join(ROOT, "_data", "transcripts")
ASSETS_PATH     = File.join(ROOT, "_data", "video_assets.yml")
ZDOTS_SOURCES   = File.expand_path("~/.local/state/zdots/ingest-sources")

def assets
  @assets ||= (Generators::Core::YamlIo.load(ASSETS_PATH)["items"] || [])
end

# transcript_id → ALL its youtube/vimeo asset_ids. An interview may have several
# videos; the reprocess may have landed under a different one than the primary,
# so we try them all when locating the on-disk source.
def asset_ids_for(tid)
  a = assets.find { |x| x["transcript_id"] == tid || x["id"] == tid }
  return [] unless a
  Array(a["platforms"]).select { |p| %w[youtube vimeo].include?(p["platform"]) && p["asset_id"] }
                       .map { |p| p["asset_id"] }
end

# Whole-file whisper JSON for an asset_id (skip chunk_* and sidecars).
def whisper_json_for(asset_id)
  Dir.glob(File.join(ZDOTS_SOURCES, "**", asset_id, "*.json")).find do |f|
    b = File.basename(f)
    !b.start_with?("chunk_") &&
      %w[.info.json .timeline.json .boundaries.json diarization.json].none? { |s| b.end_with?(s) }
  end
end

# Stitched transcript text for a chunked long source (no whole-file JSON). Prefer
# the known-terms-cleaned stitch. Lives at the retention PARENT, named <id>.stitched*.
def stitched_txt_for(asset_id)
  glob = File.join(ZDOTS_SOURCES, "**", "#{asset_id}.stitched.cleaned.txt")
  Dir.glob(glob).first || Dir.glob(File.join(ZDOTS_SOURCES, "**", "#{asset_id}.stitched.txt")).first
end

# Clean interview text from the fresh ASR, across any of the interview's asset_ids.
# Preference: whole-file whisper JSON (boundary-trimmed via recording) → stitched
# .txt (chunked path; no per-segment offsets, so the jingle is dropped downstream
# by the structurer's content rule, not by timestamp). Returns [text, source_desc].
def source_text(asset_ids, rec)
  asset_ids.each do |aid|
    if (json = whisper_json_for(aid))
      return [interview_text_from_json(json, rec), "json:#{aid}"]
    end
  end
  asset_ids.each do |aid|
    if (txt = stitched_txt_for(aid))
      return [File.read(txt), "stitched:#{aid}"]
    end
  end
  [nil, nil]
end

# Whisper segments whose midpoint is inside [interview_start_sec, interview_end_sec].
def interview_text_from_json(json_path, rec)
  doc  = JSON.parse(File.read(json_path))
  segs = doc["transcription"] || doc["segments"] || []
  start_s = (rec && rec["interview_start_sec"]) || 0.0
  end_s   = (rec && rec["interview_end_sec"]) || Float::INFINITY
  kept = segs.filter_map do |s|
    off = s["offsets"] || {}
    a = (s["start"] || off["from"] || 0).to_f / 1000.0
    b = (s["end"] || off["to"] || 0).to_f / 1000.0
    t = s["text"].to_s.strip
    t unless t.empty? || (a + b) / 2 < start_s || (a + b) / 2 > end_s
  end
  kept.join(" ")
end

def cmd_list
  Dir.glob(File.join(TRANSCRIPTS_DIR, "*.yml")).sort.each do |p|
    st = Generators::ArchiveState.for_path(p) rescue next
    next if st.invalid?
    txt = st.text rescue next
    next if txt.to_s.strip.empty?
    s = TranscriptSanity.loop_score(txt)
    next unless s && %w[high medium].include?(s["severity"])
    puts format("%-8s %-6s %s", s["severity"], s["score"], File.basename(p, ".yml"))
  end
end

def cmd_prep(tid)
  data = Generators::Core::YamlIo.load(File.join(TRANSCRIPTS_DIR, "#{tid}.yml"))
  text, src = source_text(asset_ids_for(tid), data["recording"])
  abort "no fresh ASR on disk for #{tid} (tried #{asset_ids_for(tid).join(',')})" if text.nil?
  warn "# source=#{src}"
  warn "# existing speaker_map: #{data['speaker_map'].to_json}"
  warn "# recording: start=#{data.dig('recording', 'interview_start_sec')} end=#{data.dig('recording', 'interview_end_sec')} chapters=#{data.dig('recording', 'chapters')&.size}"
  warn "# loop check on fresh text: #{TranscriptSanity.loop_score(text)&.slice('severity', 'score')}"
  puts text
end

# Structure the clean interview text into speaker turns via `claude -p` (frontier
# quality on the Claude subscription — local llama drifts on attribution, and the
# OpenRouter lane is credit-limited). Returns a turns array or nil.
def structure_via_claude(text, speaker_map)
  roles = speaker_map.map { |id, m| "#{id} = #{m['name']} (#{m['role']})" }.join("; ")
  prompt = <<~PROMPT
    Segment this interview transcript into speaker turns. Speakers: #{roles}.
    M1 is always the interviewer (Mike Hall — asks the questions, brief meta-commentary);
    the S# speakers are the guest(s) giving the answers.

    Output ONLY a YAML array — no preamble, no markdown fences, no trailing prose.
    Each item exactly:
    - speaker: M1
      text: >-
        the spoken text
    Attribute every sentence to whoever is actually speaking. Keep wording faithful —
    do NOT paraphrase or summarize the substance. BUT collapse ASR repetition loops:
    when whisper has stuttered the SAME sentence/phrase two or more times in a row,
    keep ONE clean instance and drop the duplicates (this is transcription noise, not
    speech). If the tail (or head) contains theme-song / jingle lyrics ("user groups
    with lots to say", "plethora of information", "find out for yourself today"), drop it.

    TRANSCRIPT:
    #{text}
  PROMPT
  prompt_file = "/tmp/restructure-prompt-#{Process.pid}.txt"
  File.write(prompt_file, prompt)
  # </dev/null: claude -p otherwise blocks waiting on stdin. Capture stderr so a
  # session-limit / auth message surfaces instead of a silent empty parse.
  out = `claude -p "$(cat #{prompt_file})" </dev/null 2>/tmp/claude-struct-err.log`
  File.delete(prompt_file) rescue nil
  if out.strip.empty? && File.exist?("/tmp/claude-struct-err.log")
    warn "claude -p returned nothing: #{File.read('/tmp/claude-struct-err.log').lines.grep(/limit|error|auth/i).first&.strip}"
  end
  # Strip any preamble/markdown fences: keep from the first "- speaker:" line on,
  # and stop at a closing fence if present.
  lines = out.lines
  start = lines.index { |l| l =~ /^\s*-\s+speaker:/ }
  return nil unless start
  body = lines[start..].take_while { |l| !l.start_with?("```") }.join
  YAML.safe_load(body)
rescue StandardError => e
  warn "structure failed: #{e.message}"
  nil
end

def cmd_auto(tid)
  data = Generators::Core::YamlIo.load(File.join(TRANSCRIPTS_DIR, "#{tid}.yml"))
  text, src = source_text(asset_ids_for(tid), data["recording"])
  abort "no fresh ASR on disk for #{tid}" if text.nil?
  warn "structuring #{tid} (#{text.length} chars, #{src}) via claude -p…"
  turns = structure_via_claude(text, data["speaker_map"] || {})
  abort "structuring produced no turns for #{tid}" if turns.nil? || turns.empty?
  tmp = "/tmp/turns-#{tid}.yml"
  File.write(tmp, turns.to_yaml)
  cmd_apply(tid, tmp)
end

def cmd_apply(tid, turns_path)
  path  = File.join(TRANSCRIPTS_DIR, "#{tid}.yml")
  data  = Generators::Core::YamlIo.load(path)
  turns = YAML.safe_load(File.read(turns_path))
  abort "turns.yml must be a non-empty array" unless turns.is_a?(Array) && !turns.empty?
  turns.each { |t| abort "bad turn: #{t.inspect}" unless t.is_a?(Hash) && t["speaker"] && t["text"] }

  data["turns"] = turns.map { |t| { "speaker" => t["speaker"].to_s, "text" => t["text"].to_s } }
  data["normalized_at"] = Time.now.strftime("%Y-%m-%dT%H:%M:%S%:z")
  data["validation_error"] = nil
  data["source_note"] = "restructured from reprocessed loop-free ASR (jingle trimmed via recording boundaries)"
  Generators::Core::YamlIo.dump(path, data)

  # Verify: loop gone, recording preserved, no leaked jingle.
  full = data["turns"].map { |t| t["text"] }.join(" ")
  s = TranscriptSanity.loop_score(full)
  jingle = full.downcase.include?("plethora of information") || full.downcase.include?("user groups with lots to say")
  ok = (s.nil? || s["severity"] != "high") && !data["recording"].nil? && !jingle
  puts format("%-8s %s: turns=%d loop=%s jingle=%s recording=%s",
              ok ? "OK" : "CHECK", tid, data["turns"].size,
              s ? s["severity"] : "clean", jingle, !data["recording"].nil?)
  exit(ok ? 0 : 1)
end

case ARGV.shift
when "list"  then cmd_list
when "prep"  then cmd_prep(ARGV.shift || abort("usage: prep <transcript_id>"))
when "apply" then cmd_apply(ARGV.shift || abort("usage: apply <id> <turns.yml>"), ARGV.shift || abort("usage: apply <id> <turns.yml>"))
when "auto"  then cmd_auto(ARGV.shift || abort("usage: auto <transcript_id>"))
else abort "usage: restructure_transcript.rb {list|prep <id>|apply <id> <turns.yml>|auto <id>}"
end
