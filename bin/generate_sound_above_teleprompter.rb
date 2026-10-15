#!/usr/bin/env ruby
# frozen_string_literal: true

# ==============================================================================
# bin/generate_sound_above_teleprompter.rb
#
# Generates structured 6-act teleprompter scripts and OBS production rundowns
# for "The Sound Above" oral history rewatch series.
#
# Formats each episode into 6 acts aligned with the 8 OBS production scenes:
#   Act 1: Pre-Stream & Cold Open (Scene 01 / 02)
#   Act 2: Setting the Historical Scene & Room Context (Scene 02)
#   Act 3: "The Sound Above" Inquiry Thesis (Scene 02 / 04)
#   Act 4: Hallway Rewatch & Video Reaction (Scene 03)
#   Act 5: The AI-Era Parallel & Terminal Workbench (Scene 04 / 05)
#   Act 6: Community Coda, Outro & Next Stream (Scene 08)
# ==============================================================================

require 'json'
require 'yaml'
require 'optparse'

ROOT_DIR = File.expand_path('..', __dir__)
SEQUENCE_PATH = File.join(ROOT_DIR, '_data', 'sound_above_sequence.json')
TRANSCRIPTS_DIR = File.join(ROOT_DIR, '_data', 'transcripts')

options = {
  episode: 1,
  format: :text
}

OptionParser.new do |opts|
  opts.banner = 'Usage: bin/generate_sound_above_teleprompter.rb [options]'
  opts.on('-e', '--episode NUM', Integer, 'Episode number (1-35)') { |n| options[:episode] = n }
  opts.on('-j', '--json', 'Output script payload as JSON') { options[:format] = :json }
  opts.on('-m', '--markdown', 'Output script as Markdown') { options[:format] = :markdown }
  opts.on('-h', '--help', 'Show help') do
    puts opts
    exit 0
  end
end.parse!

unless File.exist?(SEQUENCE_PATH)
  warn "Error: Sequence file not found at #{SEQUENCE_PATH}"
  exit 1
end

sequence_data = JSON.parse(File.read(SEQUENCE_PATH))
episodes = sequence_data['episodes'] || []
episode = episodes.find { |e| e['number'] == options[:episode] }

unless episode
  warn "Error: Episode #{options[:episode]} not found in sequence manifest."
  exit 1
end

# Check for transcript
slug = episode['slug']
transcript_path = File.join(TRANSCRIPTS_DIR, "#{slug}.yml")
transcript_data = {}
if File.exist?(transcript_path)
  transcript_data = YAML.safe_load(File.read(transcript_path), permitted_classes: [Date, Time], aliases: true) || {}
end

turns = transcript_data['turns'] || []

rundown = {
  episode_number: episode['number'],
  era: episode['era_name'],
  title: episode['title'],
  interviewee: episode['interviewee'],
  conference: "#{episode['conference']} (#{episode['year']})",
  location: episode['location'],
  acts: [
    {
      act_number: 1,
      name: "Cold Open & Personal Grounding",
      scene_target: "01. Starting Soon -> 02. Monologue / Full Camera",
      timing: "00:00 - 03:00",
      host_lead: "Welcome to The Sound Above. I am Mike Hall.",
      teleprompter_script: "Welcome back to The Sound Above. I am Mike Hall. Today we enter #{episode['era_name']}. Before code synthesis models and automated agents, developers in Chicago were building grassroots rooms to escape corporate silos. Today we rewatch Episode #{episode['number']}: #{episode['interviewee']} from #{episode['conference']}."
    },
    {
      act_number: 2,
      name: "Setting the Historical Scene",
      scene_target: "02. Monologue / Full Camera",
      timing: "03:00 - 08:00",
      host_lead: "Let us return to #{episode['year']} in #{episode['location']}.",
      teleprompter_script: "#{episode['chicago_context']} When we recorded this in #{episode['year']}, there were no corporate sponsor filters. Developers were meeting after hours, sharing hard-won lessons on deliberate practice and system boundaries."
    },
    {
      act_number: 3,
      name: "The Core Inquiry: The Sound Above",
      scene_target: "02. Monologue / Full Camera -> 04. Split Screen",
      timing: "08:00 - 14:00",
      host_lead: "The question that guides our rewatch today:",
      teleprompter_script: "#{episode['sound_above_inquiry']} Who inspired #{episode['interviewee']} before they stepped onto this stage? What records were playing in the background when this movement formed?"
    },
    {
      act_number: 4,
      name: "Hallway Rewatch & Video Reaction",
      scene_target: "03. Reaction - Video Focus",
      timing: "14:00 - 28:00",
      host_lead: "Let us roll the archive tape.",
      teleprompter_script: "Roll archive footage (YouTube ID: #{episode['resolved_youtube_id'] || episode['youtube_video_id']}). Watch for the unvarnished hallway exchanges, the emphasis on craft over speed, and the sheer enthusiasm of engineers taking responsibility for their software."
    },
    {
      act_number: 5,
      name: "The AI-Era Parallel & Terminal Workbench",
      scene_target: "05. Workbench - Code & Terminal",
      timing: "28:00 - 40:00",
      host_lead: "How does this lesson apply to software engineering in 2026?",
      teleprompter_script: "#{episode['ai_era_parallel']} When implementation is cheap, verification and clarity become everything. We cannot accept the mirage of competence. Let us examine the terminal contracts directly."
    },
    {
      act_number: 6,
      name: "Community Coda, Outro & Next Stream",
      scene_target: "08. Outro & Next Stream",
      timing: "40:00 - 45:00",
      host_lead: "Thank you for listening to the sound above.",
      teleprompter_script: "Thank you for joining today's session. Full transcripts, provenance notes, and companion research are available at just3ws.com. In our next broadcast, we explore Episode #{(episode['number'] % 35) + 1}. Until next time, keep your feedback loops fast and your code humane."
    }
  ]
}

case options[:format]
when :json
  puts JSON.pretty_generate(rundown)
when :markdown
  puts "# Teleprompter Rundown: Episode #{rundown[:episode_number]}"
  puts "## #{rundown[:title]}"
  puts "**Era:** #{rundown[:era]} | **Guest:** #{rundown[:interviewee]} | **Provenance:** #{rundown[:conference]}\n\n"
  rundown[:acts].each do |act|
    puts "### Act #{act[:act_number]}: #{act[:name]} (#{act[:timing]})"
    puts "*Target Scene:* `#{act[:scene_target]}`\n"
    puts "> **Lead:** #{act[:host_lead]}\n"
    puts "#{act[:teleprompter_script]}\n"
  end
else
  puts "=================================================================="
  puts " 🎙️ THE SOUND ABOVE: TELEPROMPTER & PRODUCTION RUNDOWN"
  puts "=================================================================="
  puts "Episode:     ##{rundown[:episode_number]}: #{rundown[:title]}"
  puts "Interviewee: #{rundown[:interviewee]}"
  puts "Conference:  #{rundown[:conference]} (#{rundown[:location]})"
  puts "Era:         #{rundown[:era]}"
  puts "------------------------------------------------------------------"
  rundown[:acts].each do |act|
    puts ""
    puts "▶ ACT #{act[:act_number]}: #{act[:name].upcase} [#{act[:timing]}]"
    puts "  Scene Cue: #{act[:scene_target]}"
    puts "  Prompt:    #{act[:teleprompter_script]}"
  end
  puts "=================================================================="
end
