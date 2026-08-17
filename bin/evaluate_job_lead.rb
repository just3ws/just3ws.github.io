#!/usr/bin/env ruby
# frozen_string_literal: true

# bin/evaluate_job_lead.rb
# CLI tool to evaluate job leads/postings from wwworkremote.localhost. Fit scoring is delegated to
# `bin/wwwr match` in wwworkremote/core (LLM::ProfileMatcher, the same scorer the web UI uses) --
# this script only adds zdots-ctx personal-strategy calibration and formats the executive brief.
# See docs/inter-tool-communication-protocol.md.

require "optparse"
require "net/http"
require "uri"
require "json"
require "yaml"
require "fileutils"

ROOT_DIR = File.expand_path("..", __dir__)
DATA_DIR = File.join(ROOT_DIR, "_data", "resume")
OUTPUT_DIR = File.join(ROOT_DIR, "docs", "executive-briefs")
ZDOTS_CTX_BIN = File.expand_path("~/.config/zsh/bin/zdots-ctx")
WWWORKREMOTE_CORE_DIR = File.expand_path("~/github.com/wwworkremote/core")
DEFAULT_WWWORKREMOTE_HOST = "http://localhost:31000"

options = {
  host: ENV["WWWORKREMOTE_HOST"] || DEFAULT_WWWORKREMOTE_HOST,
  out_dir: OUTPUT_DIR,
  json: false,
  escalate: false
}

OptionParser.new do |opts|
  opts.banner = "Usage: ruby bin/evaluate_job_lead.rb [options]"

  opts.on("-l", "--lead LEAD_ID", Integer, "Lead ID from wwworkremote (e.g. 112, 126)") do |v|
    options[:lead_id] = v
  end

  opts.on("-p", "--posting POSTING_ID", Integer, "Posting ID from wwworkremote (e.g. 5612, 5624)") do |v|
    options[:posting_id] = v
  end

  opts.on("-u", "--url URL", String, "Full URL to lead or job posting") do |v|
    options[:url] = v
  end

  opts.on("-h", "--host HOST", String, "wwworkremote base host (default: http://localhost:31000)") do |v|
    options[:host] = v
  end

  opts.on("-o", "--out-dir DIR", String, "Output directory for briefs") do |v|
    options[:out_dir] = v
  end

  opts.on("-j", "--json", "Output JSON evaluation result") { options[:json] = true }
  opts.on("-e", "--escalate", "Run a fresh LLM match scan via bin/wwwr (costs tokens, overwrites stored analysis)") {
    options[:escalate] = true
  }

  opts.on("--help", "Show this help message") do
    puts opts
    exit 0
  end
end.parse!

def fetch_json(url_str)
  uri = URI.parse(url_str)
  req = Net::HTTP::Get.new(uri)
  req["Accept"] = "application/json"

  res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
    http.request(req)
  end

  return JSON.parse(res.body) if res.is_a?(Net::HTTPSuccess)

  nil
rescue StandardError => e
  warn "HTTP Fetch Error (#{url_str}): #{e.message}"
  nil
end

def fetch_lead_html(host, lead_id)
  url_str = "#{host}/admin/leads/#{lead_id}"
  uri = URI.parse(url_str)
  res = Net::HTTP.get_response(uri)
  return res.body if res.is_a?(Net::HTTPSuccess)

  nil
rescue StandardError => e
  warn "Lead HTML Fetch Error (#{url_str}): #{e.message}"
  nil
end

# Delegates fit scoring to wwworkremote's real scorer instead of re-implementing it here.
# Default (escalate: false) is read-only -- prints whatever analysis is already on file.
def fetch_match(posting_id, escalate: false)
  wwwr_bin = File.join(WWWORKREMOTE_CORE_DIR, "bin", "wwwr")
  return nil unless File.executable?(wwwr_bin)

  cmd = [wwwr_bin, "match", posting_id.to_s, "--source=just3ws-cli"]
  cmd << "--escalate" if escalate
  IO.popen(cmd, err: %i[child out], &:read)
rescue StandardError => e
  warn "bin/wwwr match failed: #{e.message}"
  nil
end

def query_zdots_ctx(keyword)
  return nil unless File.executable?(ZDOTS_CTX_BIN)

  cmd = "#{ZDOTS_CTX_BIN} query #{Shellwords.escape(keyword)} 2>/dev/null"
  output = `#{cmd}`
  output.empty? ? nil : output
rescue StandardError
  nil
end

# Resolves a lead's linked posting id, or exits loudly -- a lead that fails to resolve must not
# silently fall through to the bare-invocation default and evaluate an unrelated posting.
def resolve_posting_id_from_lead(host, lead_id)
  html = fetch_lead_html(host, lead_id)
  return Regexp.last_match(1).to_i if html && html =~ %r{/job_postings/(\d+)}

  warn "Could not resolve a job posting from lead ##{lead_id} at #{host}/admin/leads/#{lead_id}."
  exit 1
end

def parse_lead_info(options)
  host = options[:host]
  posting_id = options[:posting_id]
  lead_id = options[:lead_id]

  if options[:url]
    if options[:url] =~ %r{/admin/leads/(\d+)}
      lead_id = Regexp.last_match(1).to_i
    elsif options[:url] =~ %r{/job_postings/(\d+)}
      posting_id = Regexp.last_match(1).to_i
    end
  end

  posting_id ||= resolve_posting_id_from_lead(host, lead_id) if lead_id
  posting_id ||= 5612 if lead_id.nil? && posting_id.nil?

  posting_data = fetch_json("#{host}/api/v0/job_postings/#{posting_id}")
  unless posting_data
    warn "Failed to retrieve job posting ##{posting_id} from #{host}"
    exit 1
  end

  title = posting_data["title"] || "Software Engineer"
  body = posting_data["body"] || ""

  company = posting_data["company_name"]
  if company.to_s.empty?
    lines = body.split("\n").map(&:strip).reject(&:empty?)
    company = lines[lines.index(title) + 1] if lines.include?(title) && lines.index(title) + 1 < lines.size
    company ||= "Target Company"
  end

  {
    lead_id: lead_id,
    posting_id: posting_id,
    title: title,
    company: company,
    body: body,
    raw: posting_data
  }
end

info = parse_lead_info(options)
match_output = fetch_match(info[:posting_id], escalate: options[:escalate])
zdots_res = query_zdots_ctx("Principal")

report = <<~MARKDOWN
  # Job Lead Evaluation: #{info[:company]}

  **Target Role:** #{info[:title]}
  **Lead Record:** [`wwworkremote` Lead ##{info[:lead_id] || 'N/A'}](http://localhost:31000/admin/leads/#{info[:lead_id]}) / [Posting ##{info[:posting_id]}](http://localhost:31000/api/v0/job_postings/#{info[:posting_id]})
  **Company Profile:** #{info[:company]}

  ---

  ## Match Analysis (wwworkremote / LLM::ProfileMatcher)

  #{match_output || '_bin/wwwr match unavailable -- is wwworkremote/core checked out at ~/github.com/wwworkremote/core?_'}

  ---

  ## Personal Strategy Calibration (zdots-ctx)

  #{zdots_res || '_no zdots-ctx signal for "Principal"_'}
MARKDOWN

FileUtils.mkdir_p(options[:out_dir])
slug = "#{info[:company].downcase.gsub(/[^a-z0-9]/, '_')}_#{info[:title].downcase.gsub(/[^a-z0-9]/, '_')}"
out_path = File.join(options[:out_dir], "#{slug}.md")

File.write(out_path, report)

if options[:json]
  puts JSON.pretty_generate({ info: info, match_output: match_output, report_path: out_path })
else
  puts "Evaluation completed:"
  puts "   - Role: #{info[:title]} at #{info[:company]}"
  puts "   - Match: #{match_output ? match_output.lines.first&.strip : 'unavailable'}"
  puts "   - Report Saved: #{out_path}"
end
