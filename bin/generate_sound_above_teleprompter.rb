#!/usr/bin/env ruby
# frozen_string_literal: true

# ---
# name: generate_sound_above_teleprompter.rb
# domain: media
# purpose: 6-Act broadcast teleprompter and native .textream document compiler
# usage: bin/pipeline media teleprompter <episode_num> [--textream] [--open]
# description: Generates structured 6-act broadcast teleprompter scripts and native
#   Textream JSON documents aligned with OBS scenes 01 through 08 for live broadcasts.
# ---

require 'json'
require 'yaml'
require 'optparse'
require 'uri'
require 'fileutils'

ROOT_DIR = File.expand_path('..', __dir__)
SEQUENCE_PATH = File.join(ROOT_DIR, '_data', 'sound_above_sequence.json')
EPISODES_DIR = File.join(ROOT_DIR, '_data', 'episodes')
TRANSCRIPTS_DIR = File.join(ROOT_DIR, '_data', 'transcripts')
TELEPROMPTER_DIR = File.join(ROOT_DIR, 'obs', 'teleprompter')

# Resolve episode metadata across episode dossiers (00-37) and sequence manifest
def resolve_episode(ep_num)
  # Check for episode YAML dossier first (_data/episodes/episode-XX.yml)
  slug_num = format('%02d', ep_num)
  dossier_path = File.join(EPISODES_DIR, "episode-#{slug_num}.yml")

  if File.exist?(dossier_path)
    dossier = YAML.safe_load(File.read(dossier_path), permitted_classes: [Date, Time], aliases: true) || {}
    narrative = dossier['narrative'] || {}

    return {
      'number' => dossier['episode'] || ep_num,
      'era_name' => dossier['era_name'] || 'The Sound Above',
      'title' => dossier['title'] || "Episode #{ep_num}",
      'interviewee' => dossier['interviewee'] || 'Featured Guest',
      'conference' => dossier['conference'] ? "#{dossier['conference']} (#{dossier['year']})" : dossier['year'].to_s,
      'location' => dossier['location'] || 'Chicago, IL',
      'year' => dossier['year'] || 2026,
      'slug' => dossier['slug'] || "episode-#{slug_num}",
      'chicago_context' => narrative['chicago_context'] || 'Grassroots practitioner reflections from the Chicago software craftsmanship movement.',
      'sound_above_inquiry' => narrative['core_inquiry'] || 'What records were playing in the room when this technical movement formed?',
      'ai_era_parallel' => narrative['ai_era_parallel'] || 'Maintaining cognitive control and deterministic verification over system boundaries.',
      'resolved_youtube_id' => dossier['resolved_youtube_id'] || dossier['youtube_video_id'] || '',
      'teleprompter_script' => dossier['teleprompter_script'] || {}
    }
  end

  # Fallback to sequence manifest (_data/sound_above_sequence.json)
  if File.exist?(SEQUENCE_PATH)
    sequence_data = JSON.parse(File.read(SEQUENCE_PATH))
    episodes = sequence_data['episodes'] || []
    matched = episodes.find { |e| e['number'] == ep_num }
    return matched if matched
  end

  # Default fallback for unmanifested index
  {
    'number' => ep_num,
    'era_name' => 'The Sound Above',
    'title' => "The Sound Above: Episode #{ep_num}",
    'interviewee' => 'Chicago Craftsmanship Practitioner',
    'conference' => 'SCNA (2011-2015)',
    'location' => 'Chicago, IL',
    'year' => 2011,
    'slug' => "episode-#{slug_num}",
    'chicago_context' => 'Grassroots practitioner discussions and hallway exchanges.',
    'sound_above_inquiry' => 'What influences shaped the movement outside corporate architectures?',
    'ai_era_parallel' => 'Reclaiming craftsmanship and local verification in the automated code era.',
    'resolved_youtube_id' => ''
  }
end

# Construct standardized 6-act rundown
def build_rundown(episode)
  ep_num = episode['number']
  next_ep_num = ep_num >= 37 ? 0 : ep_num + 1
  custom = episode['teleprompter_script'] || {}

  act1 = custom['act_1'] || "Welcome back to The Sound Above. I am Mike Hall. Today we enter #{episode['era_name']}. Before code synthesis models and automated agents, developers met face to face to establish standards of craftsmanship. Today we rewatch Episode #{ep_num}: #{episode['interviewee']} from #{episode['conference']}."
  act2 = custom['act_2'] || episode['chicago_context'].to_s
  act3 = custom['act_3'] || "#{episode['sound_above_inquiry']} What principles guided #{episode['interviewee']} when this conversation was recorded? How do those lessons inform the software systems we design today?"
  act4 = custom['act_4'] || "Roll archive footage (YouTube ID: #{episode['resolved_youtube_id'] || episode['youtube_video_id'] || 'archive'}). Watch for the unvarnished hallway exchanges, the emphasis on craft over speed, and the sheer enthusiasm of engineers taking responsibility for their software."
  act5 = custom['act_5'] || "#{episode['ai_era_parallel']} When implementation is cheap, verification and clarity become everything. We cannot accept the mirage of competence. Let us examine the terminal contracts directly."
  act6 = custom['act_6'] || "Thank you for joining today's session. Full transcripts, provenance notes, and companion research are available at just3ws.com. In our next broadcast, we explore Episode #{next_ep_num}. Until next time, keep your feedback loops fast and your code humane."

  {
    episode_number: ep_num,
    era: episode['era_name'],
    title: episode['title'],
    interviewee: episode['interviewee'],
    conference: episode['conference'],
    location: episode['location'],
    acts: [
      {
        act_number: 1,
        name: 'Cold Open & Personal Grounding',
        scene_target: '01. Starting Soon -> 02. Monologue / Full Camera',
        timing: '00:00 - 03:00',
        host_lead: 'Welcome to The Sound Above. I am Mike Hall.',
        teleprompter_script: act1
      },
      {
        act_number: 2,
        name: 'Setting the Historical Scene',
        scene_target: '02. Monologue / Full Camera',
        timing: '03:00 - 08:00',
        host_lead: "Let us return to #{episode['year']} in #{episode['location']}.",
        teleprompter_script: act2
      },
      {
        act_number: 3,
        name: 'The Core Inquiry: The Sound Above',
        scene_target: '02. Monologue / Full Camera -> 04. Split Screen',
        timing: '08:00 - 14:00',
        host_lead: 'The question that guides our rewatch today:',
        teleprompter_script: act3
      },
      {
        act_number: 4,
        name: 'Hallway Rewatch & Video Reaction',
        scene_target: '03. Reaction - Video Focus',
        timing: '14:00 - 28:00',
        host_lead: 'Let us roll the archive tape.',
        teleprompter_script: act4
      },
      {
        act_number: 5,
        name: 'The AI-Era Parallel & Terminal Workbench',
        scene_target: '05. Workbench - Code & Terminal',
        timing: '28:00 - 40:00',
        host_lead: 'How does this lesson apply to software engineering in 2026?',
        teleprompter_script: act5
      },
      {
        act_number: 6,
        name: 'Community Coda, Outro & Next Stream',
        scene_target: '08. Outro & Next Stream',
        timing: '40:00 - 45:00',
        host_lead: 'Thank you for listening to the sound above.',
        teleprompter_script: act6
      }
    ]
  }
end

# Build native Textream document pages: JSON Array of Strings [String]
# Each page in the array corresponds to an act in the teleprompter presentation.
def build_textream_pages(rundown)
  rundown[:acts].map do |act|
    [
      "ACT #{act[:act_number]}: #{act[:name].upcase} [#{act[:timing]}]",
      "Scene: #{act[:scene_target]}",
      "",
      act[:teleprompter_script]
    ].join("\n")
  end
end

# Build textream:// URL for instant reading
def build_textream_url(text)
  encoded = URI.encode_www_form_component(text).gsub('+', '%20')
  "textream://read?text=#{encoded}"
end

# Save textream document to disk
def save_textream_file(path, pages)
  FileUtils.mkdir_p(File.dirname(path))
  File.write(path, JSON.pretty_generate(pages))
  path
end

options = {
  episode: 1,
  format: :text,
  save_path: nil,
  open_app: false,
  all_episodes: false,
  act: 1
}

OptionParser.new do |opts|
  opts.banner = 'Usage: bin/generate_sound_above_teleprompter.rb [options]'
  opts.on('-e', '--episode NUM', Integer, 'Episode number (0-37)') { |n| options[:episode] = n }
  opts.on('-j', '--json', 'Output script payload as JSON') { options[:format] = :json }
  opts.on('-m', '--markdown', 'Output script as Markdown') { options[:format] = :markdown }
  opts.on('-t', '--textream', 'Output native Textream document JSON [String] to stdout') { options[:format] = :textream }
  opts.on('-s', '--save-textream [PATH]', 'Save native .textream document to disk') do |p|
    options[:save_path] = p || :default
  end
  opts.on('-o', '--open', 'Open generated .textream document in /Applications/Textream.app') { options[:open_app] = true }
  opts.on('-u', '--url', 'Print textream://read deep link URL for speech tracking') { options[:format] = :url }
  opts.on('-a', '--act NUM', Integer, 'Specific act for deep link or single view (1-6)') { |a| options[:act] = a }
  opts.on('--all-textream', 'Generate native .textream documents for all 38 episodes into obs/teleprompter/') do
    options[:all_episodes] = true
  end
  opts.on('-h', '--help', 'Show help') do
    puts opts
    exit 0
  end
end.parse!

# Batch generation for all 38 episodes
if options[:all_episodes]
  FileUtils.mkdir_p(TELEPROMPTER_DIR)
  puts "📜 Generating native .textream documents for all 38 episodes in #{TELEPROMPTER_DIR}..."
  (0..37).each do |ep_num|
    ep_data = resolve_episode(ep_num)
    rd = build_rundown(ep_data)
    pages = build_textream_pages(rd)
    file_path = File.join(TELEPROMPTER_DIR, format('episode-%02d.textream', ep_num))
    save_textream_file(file_path, pages)
    puts "  [PASS] Episode #{format('%02d', ep_num)}: #{file_path} (6 pages)"
  end
  puts "✅ All 38 .textream documents compiled cleanly!"
  exit 0
end

episode = resolve_episode(options[:episode])
rundown = build_rundown(episode)
textream_pages = build_textream_pages(rundown)

# Save .textream file if requested or if opening
target_save_path = nil
if options[:save_path] || options[:open_app]
  target_save_path = if options[:save_path] && options[:save_path] != :default
                       options[:save_path]
                     else
                       File.join(TELEPROMPTER_DIR, format('episode-%02d.textream', rundown[:episode_number]))
                     end
  save_textream_file(target_save_path, textream_pages)
  warn "💾 Saved native Textream document to #{target_save_path}" unless options[:format] == :textream
end

if options[:open_app]
  target_save_path ||= File.join(TELEPROMPTER_DIR, format('episode-%02d.textream', rundown[:episode_number]))
  save_textream_file(target_save_path, textream_pages) unless File.exist?(target_save_path)
  app_path = '/Applications/Textream.app'
  if File.exist?(app_path)
    system('open', '-a', app_path, target_save_path)
    warn "🚀 Launched Episode #{rundown[:episode_number]} in #{app_path}"
  else
    warn "⚠️ Textream.app not found at #{app_path}. Opened file with default handler: #{target_save_path}"
    system('open', target_save_path)
  end
end

case options[:format]
when :textream
  puts JSON.pretty_generate(textream_pages)
when :url
  target_act = rundown[:acts].find { |a| a[:act_number] == options[:act] } || rundown[:acts].first
  full_prompt = [
    "ACT #{target_act[:act_number]}: #{target_act[:name].upcase}",
    target_act[:teleprompter_script]
  ].join("\n\n")
  puts build_textream_url(full_prompt)
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
    puts "```textream"
    puts build_textream_url(act[:teleprompter_script])
    puts "```\n"
  end
else
  puts '=================================================================='
  puts ' 🎙️ THE SOUND ABOVE: TELEPROMPTER & PRODUCTION RUNDOWN'
  puts '=================================================================='
  puts "Episode:     ##{rundown[:episode_number]}: #{rundown[:title]}"
  puts "Interviewee: #{rundown[:interviewee]}"
  puts "Conference:  #{rundown[:conference]} (#{rundown[:location]})"
  puts "Era:         #{rundown[:era]}"
  puts "Textream:    obs/teleprompter/episode-#{format('%02d', rundown[:episode_number])}.textream"
  puts '------------------------------------------------------------------'
  rundown[:acts].each do |act|
    puts ''
    puts "▶ ACT #{act[:act_number]}: #{act[:name].upcase} [#{act[:timing]}]"
    puts "  Scene Cue: #{act[:scene_target]}"
    puts "  Prompt:    #{act[:teleprompter_script]}"
    puts "  Textream:  #{build_textream_url(act[:teleprompter_script])[0..80]}..."
  end
  puts '=================================================================='
  puts "Run with `--open` to launch in Textream.app or `--save-textream` to persist."
  puts '=================================================================='
end
