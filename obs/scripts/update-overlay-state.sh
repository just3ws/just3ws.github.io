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

  opts.on("-a", "--archetype TYPE", %w[rewatch errata dialogue], "Set broadcast archetype (rewatch, errata, dialogue)") do |a|
    options[:archetype] = a
  end

  opts.on("--errata", "Shortcut to set archetype to Errata") do
    options[:archetype] = "errata"
  end

  opts.on("--rewatch", "Shortcut to set archetype to Rewatch") do
    options[:archetype] = "rewatch"
  end

  opts.on("--dialogue", "Shortcut to set archetype to Dialogue") do
    options[:archetype] = "dialogue"
  end

  opts.on("-m", "--mode MODE", %w[reading concept demo story artifact], "Errata mode: reading, concept, demo, story, artifact") do |m|
    options[:mode] = m
  end

  opts.on("-e", "--episode NUMBER", Integer, "Cue episode number from sequence-manifest.json") do |n|
    options[:episode] = n
  end

  opts.on("-g", "--guest NAME", String, "Override interviewee or guest name") do |g|
    options[:guest] = g
  end

  opts.on("-t", "--title TITLE", String, "Override title or essay name") do |t|
    options[:title] = t
  end

  opts.on("--subtitle SUBTITLE", String, "Override subtitle") do |s|
    options[:subtitle] = s
  end

  opts.on("--citation CITATION", String, "Citation, book author, or provenance") do |cit|
    options[:citation] = cit
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

  opts.on("-p", "--prompt PROMPT", String, "Override quote, prompt, or book excerpt") do |p|
    options[:prompt] = p
  end

  opts.on("-s", "--series SERIES", String, "Override series title (e.g. Errata, The Sound Above)") do |s|
    options[:series] = s
  end

  opts.on("-h", "--help", "Show this help message") do
    puts opts
    exit 0
  end
end

parser.parse!

manifest = JSON.parse(File.read(MANIFEST_PATH))
current_state = JSON.parse(File.read(STATE_PATH))

# Update broadcast archetype if provided or inferred
if options[:archetype]
  current_state["broadcast_type"] = options[:archetype]
elsif options[:mode]
  current_state["broadcast_type"] = "errata"
elsif options[:episode]
  current_state["broadcast_type"] = "rewatch"
end

current_state["broadcast_type"] ||= "rewatch"

if current_state["broadcast_type"] == "errata"
  current_state["errata"] ||= {}
  current_state["errata"]["mode"] = options[:mode] || current_state["errata"]["mode"] || "concept"
  current_state["errata"]["title"] = options[:title] if options[:title]
  current_state["errata"]["subtitle"] = options[:subtitle] if options[:subtitle]
  current_state["errata"]["citation"] = options[:citation] || options[:guest] if (options[:citation] || options[:guest])
  current_state["errata"]["excerpt_or_thesis"] = options[:prompt] if options[:prompt]
  current_state["errata"]["artifact_year"] = options[:year] if options[:year]

  current_state["stream"]["series_title"] = options[:series] || "Errata"
  current_state["stream"]["series_subtitle"] = "Marginalia, Readings & Demonstrations"
  current_state["stream"]["topic"] = "#{current_state["errata"]["title"]} (#{current_state["errata"]["mode"]})"
elsif current_state["broadcast_type"] == "dialogue"
  current_state["dialogue"] ||= {}
  if options[:guest]
    current_state["dialogue"]["guests"] = [
      {
        "name" => options[:guest],
        "role" => options[:subtitle] || "Collaborator",
        "affiliation" => options[:conference] || ""
      }
    ]
  end
  current_state["dialogue"]["topic"] = options[:title] if options[:title]
  current_state["dialogue"]["prompt"] = options[:prompt] if options[:prompt]

  current_state["stream"]["series_title"] = options[:series] || "The Room"
  current_state["stream"]["series_subtitle"] = "Invitational Conversations & Peer Inquiry"
  current_state["stream"]["topic"] = current_state["dialogue"]["topic"] || "Craftsmanship Dialogue"
else
  # Rewatch
  current_state["stream"]["series_title"] = options[:series] || "The Sound Above"
  current_state["stream"]["series_subtitle"] = "UGtastic Rewatch: Learning About People in Tech (2009–2026)"

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

  current_state["episode"]["interviewee"] = options[:guest] if options[:guest]
  current_state["episode"]["title"] = options[:title] if options[:title]
  current_state["episode"]["conference"] = options[:conference] if options[:conference]
  current_state["episode"]["year"] = options[:year] if options[:year]
  current_state["episode"]["era"] = options[:era] if options[:era]
  current_state["episode"]["sound_above_prompt"] = options[:prompt] if options[:prompt]
end

File.write(STATE_PATH, JSON.pretty_generate(current_state))

puts "=================================================================="
puts "🎬 Overlay State Updated Successfully!"
puts "=================================================================="
puts "Archetype:   #{current_state["broadcast_type"].upcase}"
puts "Series:      #{current_state["stream"]["series_title"]}"

if current_state["broadcast_type"] == "errata"
  err = current_state["errata"] || {}
  puts "Mode:        #{err["mode"]}"
  puts "Title:       #{err["title"]}"
  puts "Citation:    #{err["citation"]}"
  puts "Excerpt:     #{err["excerpt_or_thesis"]}"
elsif current_state["broadcast_type"] == "dialogue"
  dia = current_state["dialogue"] || {}
  guests = (dia["guests"] || []).map { |g| g["name"] }.join(", ")
  puts "Guests:      #{guests}"
  puts "Topic:       #{dia["topic"]}"
  puts "Prompt:      #{dia["prompt"]}"
else
  conf_disp = current_state["episode"]["conference"].to_s
  year_disp = current_state["episode"]["year"].to_s
  event_label = (conf_disp.include?(year_disp) || year_disp.empty?) ? conf_disp : "#{conf_disp} (#{year_disp})"
  puts "Episode:     ##{current_state["episode"]["number"]} - #{current_state["episode"]["title"]}"
  puts "Guest:       #{current_state["episode"]["interviewee"]}"
  puts "Event:       #{event_label}"
  puts "Prompt:      #{current_state["episode"]["sound_above_prompt"]}"
end
puts "------------------------------------------------------------------"
puts "Live overlays in OBS Studio will update within 2.5 seconds."
puts "=================================================================="
