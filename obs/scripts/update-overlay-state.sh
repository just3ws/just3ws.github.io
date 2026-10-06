#!/usr/bin/env ruby
# frozen_string_literal: true
# ==============================================================================
# The Sound Above: Live Overlay State Updater
# Synchronizes episode metadata between sequence-manifest.json and overlays
# ==============================================================================

require "json"
require "optparse"
require "fileutils"

SCRIPT_DIR = __dir__
PROJECT_DIR = File.expand_path("..", SCRIPT_DIR)
MANIFEST_PATH = File.join(PROJECT_DIR, "curation", "sequence-manifest.json")
STATE_PATH = File.join(PROJECT_DIR, "overlays", "overlay-state.json")

options = {}
parser = OptionParser.new do |opts|
  opts.banner = "Usage: obs/scripts/update-overlay-state.sh [options]"

  opts.on("-e", "--episode NUMBER", Integer, "Cue episode number from sequence-manifest.json") do |n|
    options[:episode] = n
  end

  opts.on("-g", "--guest NAME", String, "Override interviewee or guest name") do |g|
    options[:guest] = g
  end

  opts.on("-t", "--title TITLE", String, "Override episode title") do |t|
    options[:title] = t
  end

  opts.on("-c", "--conference CONF", String, "Override conference or event name") do |c|
    options[:conference] = c
  end

  opts.on("-y", "--year YEAR", String, "Override year") do |y|
    options[:year] = y
  end

  opts.on("-r", "--era ERA", String, "Override era label") do |r|
    options[:era] = r
  end

  opts.on("-p", "--prompt PROMPT", String, "Override the Sound Above prompt or quote") do |p|
    options[:prompt] = p
  end

  opts.on("-h", "--help", "Show this help message") do
    puts opts
    exit 0
  end
end

parser.parse!

manifest = JSON.parse(File.read(MANIFEST_PATH))
current_state = JSON.parse(File.read(STATE_PATH))

if options[:episode]
  ep = manifest["episodes"].find { |item| item["number"] == options[:episode] }
  unless ep
    puts "❌ Episode #{options[:episode]} not found in sequence-manifest.json (available 1-#{manifest["episodes"].size})"
    exit 1
  end

  current_state["episode"]["number"] = ep["number"]
  current_state["episode"]["title"] = ep["title"]
  current_state["episode"]["interviewee"] = ep["interviewee"]
  current_state["episode"]["conference"] = ep["conference"]
  current_state["episode"]["location"] = ep["location"]
  current_state["episode"]["year"] = ep["year"].to_s
  current_state["episode"]["era"] = ep["era_name"]
  current_state["episode"]["sound_above_prompt"] = ep["sound_above_inquiry"]
  current_state["stream"]["topic"] = "Rewatching #{ep["interviewee"]} (#{ep["conference"]}): #{ep["title"]}"
end

# Apply manual overrides if provided
current_state["episode"]["interviewee"] = options[:guest] if options[:guest]
current_state["episode"]["title"] = options[:title] if options[:title]
current_state["episode"]["conference"] = options[:conference] if options[:conference]
current_state["episode"]["year"] = options[:year] if options[:year]
current_state["episode"]["era"] = options[:era] if options[:era]
current_state["episode"]["sound_above_prompt"] = options[:prompt] if options[:prompt]

File.write(STATE_PATH, JSON.pretty_generate(current_state))

puts "=================================================================="
puts "🎬 Overlay State Updated Successfully!"
puts "=================================================================="
conf_disp = current_state["episode"]["conference"].to_s
year_disp = current_state["episode"]["year"].to_s
event_label = (conf_disp.include?(year_disp) || year_disp.empty?) ? conf_disp : "#{conf_disp} (#{year_disp})"
puts "Event:       #{event_label}"
puts "Era:         #{current_state["episode"]["era"]}"
puts "Prompt:      #{current_state["episode"]["sound_above_prompt"]}"
puts "------------------------------------------------------------------"
puts "Live overlays in OBS Studio will update within 2.5 seconds."
puts "=================================================================="
