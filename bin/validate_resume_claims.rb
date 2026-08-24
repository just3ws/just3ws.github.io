#!/usr/bin/env ruby
# frozen_string_literal: true

# Provenance guardrail: every quantified career claim on a public surface must
# resolve to the resume source data -- a position file or a case_study block --
# or it does not ship.
#
# This exists because generated prose invents numbers. Three published posts
# claimed a "214" interview archive that has always held 207, and the
# /case-studies page kept showing "36+ Vendors" and "130+ Clinics" as proofs
# after the case study behind them was withdrawn for having no numbers.
#
# Deliberately mechanical. It does not judge whether a claim is *true*, only
# whether anything in the career data backs it. Semantic judgement -- is this a
# self-attributed outcome or an industry aside? -- is what --explain hands to
# Gemini, and that stays advisory rather than gating.
#
#   ruby bin/validate_resume_claims.rb            # gate: exit 1 on unattested
#   ruby bin/validate_resume_claims.rb --explain  # adjudicate findings via gemini

require 'json'
require 'net/http'
require 'set'
require 'yaml'

ROOT = File.expand_path('..', __dir__)

# The corpus is deliberately narrow. Widening it to all of _data/ makes the
# check vacuous -- 2,603 numbers match anything by coincidence, and a check that
# cannot go red is not a check.
CORPUS = Dir[File.join(ROOT, '_data/resume/**/*.yml')] + [File.join(ROOT, '_data/case_studies.yml')]

# Public surfaces that speak in Mike's voice about his own career. Interview and
# community-history posts are out of scope: they cite the archive, a different
# corpus with its own validators.
TARGETS = [
  '_data/engagements.yml',
  'case-studies/index.html',
  'exports/resume.md',
  *Dir[File.join(ROOT, 'docs/executive-briefs/*.md')].map { |f| f.delete_prefix("#{ROOT}/") }
].freeze

ALLOWLIST_PATH = File.join(ROOT, '_data/resume_claim_allowlist.yml')

# Only claim-shaped numbers: percentages, "N+" scale claims, "Nx" multipliers.
# Bare integers are unusable -- they match CSS hex, font weights and pixels.
CLAIM = /(?<![\w.#])(\d[\d,]*)\s*(%|\+|x\b)/
NOISE = /style="[^"]*"|<style.*?<\/style>|#[0-9a-fA-F]{3,8}\b/m

def attested
  @attested ||= CORPUS.each_with_object(Set.new) do |path, set|
    next unless File.file?(path)

    File.read(path).scan(/\d[\d,]*/) { |n| set << n.delete(',') }
  end
end

def register
  @register ||= File.exist?(ALLOWLIST_PATH) ? Hash(YAML.safe_load_file(ALLOWLIST_PATH)) : {}
end

# Sourced, just not as that literal number. Silent.
def allowlist = Hash(register['allowed'])

# No source found. Reported every run until sourced, reworded, or pulled --
# an allowlist you can hide something in forever is not a guardrail.
def pending = Hash(register['pending'])

def findings
  TARGETS.flat_map do |rel|
    path = File.join(ROOT, rel)
    next [] unless File.file?(path)

    File.readlines(path).each_with_index.flat_map do |line, idx|
      scan_line(rel, idx + 1, line.gsub(NOISE, ' '))
    end
  end
end

def scan_line(rel, lineno, line)
  line.scan(CLAIM).filter_map do
    raw = Regexp.last_match(1).delete(',')
    claim = "#{raw}#{Regexp.last_match(2)}"
    next if raw.to_i.between?(1990, 2030) || attested.include?(raw) || allowlist.key?(claim)
    next pending_hit(claim, rel, lineno) if pending.key?(claim)

    { claim: claim, file: rel, line: lineno, text: line.strip[0, 120] }
  end
end

def pending_hit(claim, rel, lineno)
  warn "  PENDING #{claim}  #{rel}:#{lineno} -- #{pending[claim].to_s.split("\n").first}"
  nil
end

GEMINI_MODEL = ENV.fetch('GEMINI_MODEL', 'gemini-flash-latest')

def explain(results)
  # Deliberately does NOT shell out to the gemini CLI. That CLI is pinned to
  # selectedAuthType "oauth-personal" in ~/.gemini/settings.json, so it ignores
  # GEMINI_API_KEY, opens a browser auth prompt, and still exits 0 -- its status
  # cannot be trusted to mean the adjudication happened. Calling the API with
  # the key keeps this opt-in per run instead of changing a global auth setting
  # that every other Gemini caller on the box shares.
  key = ENV['GEMINI_API_KEY']
  return warn_missing_key unless key

  answer = gemini_verdicts(key, results)
  return warn("\ngemini adjudication unavailable; findings above stand.") unless answer

  warn "\nGemini (advisory, not a gate):"
  warn answer
end

def warn_missing_key
  warn "\n--explain needs GEMINI_API_KEY, which is not in the environment."
  warn 'It currently lives only in wwworkremote/core/.env.local, which nothing here reads.'
  warn 'Keychain is how the rest of the platform holds secrets:'
  warn '  export GEMINI_API_KEY="$(security find-generic-password -s zdots -a GEMINI_API_KEY -w)"'
end

def gemini_verdicts(key, results)
  uri = URI("https://generativelanguage.googleapis.com/v1beta/models/#{GEMINI_MODEL}:generateContent")
  req = Net::HTTP::Post.new(uri)
  req['content-type'] = 'application/json'
  req['x-goog-api-key'] = key
  req.body = { contents: [ { role: "user", parts: [ { text: adjudication_prompt(results) } ] } ] }.to_json

  res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, read_timeout: 60) { |http| http.request(req) }
  return warn("gemini HTTP #{res.code}") && nil unless res.is_a?(Net::HTTPSuccess)

  JSON.parse(res.body).dig('candidates', 0, 'content', 'parts', 0, 'text')&.strip
rescue StandardError => e
  warn "gemini call failed: #{e.class}: #{e.message}"
  nil
end

def adjudication_prompt(results)
  <<~PROMPT
    These quantified claims appear on public career surfaces but no number in the
    resume source data backs them. For each, answer KEEP (a general/industry or
    quoted statement, not a self-attributed outcome) or PULL (reads as this
    person's own result and needs a source). One line each, no preamble.

    #{results.map { |r| "#{r[:claim]} -- #{r[:file]}:#{r[:line]} -- #{r[:text]}" }.join("\n")}
  PROMPT
end

results = findings
if results.empty?
  puts "resume claims: OK (#{attested.size} attested numbers, #{TARGETS.size} surfaces, " \
       "#{allowlist.size} allowlisted, #{pending.size} pending a source)"
  exit 0
end

warn "Unattested quantified career claims (#{results.size}):"
results.each { |r| warn "  #{r[:claim]}  #{r[:file]}:#{r[:line]}\n      #{r[:text]}" }
warn "\nEach must resolve to a position file or a case_study block, or be recorded"
warn "in #{ALLOWLIST_PATH.delete_prefix("#{ROOT}/")} with a reason."

explain(results) if ARGV.include?('--explain')
exit 1
