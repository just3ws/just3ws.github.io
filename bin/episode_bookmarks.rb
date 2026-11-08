#!/usr/bin/env ruby
# frozen_string_literal: true

# Generates a Netscape bookmark file and updates Chromium browser bookmarks
# for Localhost (*.localhost), Phalanx Duel, The Sound Above, Studio Workbench,
# and Ramblin' & Amblin' series and platform surfaces.

require 'cgi'
require 'date'
require 'fileutils'
require 'json'
require 'optparse'
require 'securerandom'
require 'yaml'

class EpisodeBookmarks
  ROOT = File.expand_path('..', __dir__)
  SEQUENCE = File.join(ROOT, '_data', 'sound_above_sequence.json')
  EPISODES = File.join(ROOT, '_data', 'episodes')
  DEFAULT_OUTPUT = File.join(ROOT, 'obs', 'bookmarks', 'the-sound-above-rewatch.html')
  CHROMIUM_BOOKMARKS = File.expand_path('~/Library/Application Support/Chromium/Default/Bookmarks')
  SITE = 'https://www.just3ws.localhost'
  HISTORIAN = 'https://hister.localhost'

  PRESERVED_BAR_ITEMS = [
    'LAN System Map',
    'Media Pipeline Cockpit',
    'Hister | Software Craftsmanship & Oral History Research',
    'Mike Hall | Software Engineer - Mike Hall Technical Archive',
    'YouTube Publishing Pipeline & Overview Dashboard'
  ].freeze

  def initialize(output = DEFAULT_OUTPUT)
    @output = File.expand_path(output)
    @sequence = JSON.parse(File.read(SEQUENCE))
  end

  def build_localhost_ecosystem
    folders = []
    folders << folder('Core Platforms', [
      link('zdots.localhost (Platform Bus & Control Plane)', 'https://zdots.localhost/'),
      link('my.localhost (Platform Dashboard)', 'https://my.localhost/'),
      link('just3ws.localhost (Public CareerOS & Archive)', "#{SITE}/"),
      link('wwworkremote.localhost (Career Intelligence)', 'https://wwworkremote.localhost/')
    ])

    folders << folder('Operational Cockpits', [
      link('media-pipeline.localhost (Media Pipeline)', 'https://media-pipeline.localhost/'),
      link('hister.localhost (Search Engine)', HISTORIAN),
      link('dehum Cockpit (Acoustic Forensics)', "#{SITE}/dehum/dashboard.html"),
      link('LAN System Map (Topology)', 'https://lan.just3ws.com/map')
    ])

    folders << folder('Realtime & Gaming', [
      link('play.phalanxduel.localhost (Game Client)', 'https://play.phalanxduel.localhost/'),
      link('admin.phalanxduel.localhost (Admin Console)', 'https://admin.phalanxduel.localhost/'),
      link('phalanxduel.localhost (Rules & Architecture)', 'https://phalanxduel.localhost/'),
      link('phalanxduel.localhost/demo/ (Demo Cockpit)', 'https://phalanxduel.localhost/demo/')
    ])

    folders << folder('AI & Inference', [
      link('llama.localhost (Local LLM Inference)', 'https://llama.localhost/'),
      link('embed.localhost (Vector Embeddings)', 'https://embed.localhost/')
    ])

    folders << folder('Observability & Telemetry', [
      link('o2.localhost (OpenObserve Telemetry)', 'https://o2.localhost/'),
      link('jaeger.localhost (Distributed Tracing)', 'https://jaeger.localhost/')
    ])

    folders << folder('Package Caches', [
      link('gemstash.localhost (RubyGems Cache)', 'https://gemstash.localhost/')
    ])

    folder('Localhost (*.localhost)', folders)
  end

  def build_phalanx_duel
    entries = [
      link('Play Client (play.phalanxduel.localhost)', 'https://play.phalanxduel.localhost/'),
      link('Admin Console (admin.phalanxduel.localhost)', 'https://admin.phalanxduel.localhost/'),
      link('Rules & Architecture (phalanxduel.localhost)', 'https://phalanxduel.localhost/'),
      link('Generated Demo Cockpit (/demo/)', 'https://phalanxduel.localhost/demo/'),
      link('Live Public Platform (phalanxduel.com)', 'https://phalanxduel.com'),
      link('SCMC Presentation & Quickstart', "#{SITE}/phalanx-duel/"),
      link('Retrospective Systems Essay', "#{SITE}/2026/10/20/phalanx-duel-make-the-rules-legible-scmc-presentation-and-game-architecture.html"),
      link('YouTube Architecture Playlist', 'https://www.youtube.com/playlist?list=PLHenvAZhJjHo'),
      link('Local Game Source Directory', 'file:///Users/mike/github.com/phalanxduel/game/')
    ]
    folder('Phalanx Duel', entries)
  end

  def build_sound_above
    folders = []
    folders << folder('Start here', [
      link('The Sound Above series', "#{SITE}/series/the-sound-above/"),
      link('UGtastic interview archive', "#{SITE}/interviews/"),
      link('Hister research search', HISTORIAN),
      link('Public Support & Credits', "#{SITE}/support/")
    ])

    interviews = @sequence.fetch('episodes', [])
    folders << folder('Season One: working target of up to 17 interviews',
                      interviews.select { |episode| episode.fetch('number') <= 17 }
                                .map { |episode| episode_folder(episode.fetch('number')) })
    folders << folder('Archive candidates: not scheduled',
                      interviews.select { |episode| episode.fetch('number') > 17 }
                                .map { |episode| episode_folder(episode.fetch('number')) })

    codas = @sequence.fetch('codas', []).each_index.map { |index| episode_folder(36 + index) }
    folders << folder('Possible later extras', codas) unless codas.empty?

    folder('The Sound Above', folders)
  end

  def build_studio_workbench
    folders = []
    folders << folder('Start here', [
      link('Media Pipeline Cockpit', 'https://media-pipeline.localhost/'),
      link('Live Broadcast Workbench', "#{SITE}/dehum/dashboard.html"),
      link('YouTube Publishing Pipeline & Overview Dashboard', "#{SITE}/youtube/dashboard/#tab-queue"),
      link('Hister research search', HISTORIAN)
    ])

    # 1. Hello, World!
    hw_query = CGI.escape(JSON.generate(text: 'Mike Hall Studio Workbench Hello World 2026', limit: 12))
    folders << folder('Hello, World! (Preparation & Desk Tour)', [
      link('Media Pipeline Architecture & Cockpit', 'https://media-pipeline.localhost/'),
      link('Active Overlay State', "#{SITE}/obs/overlays/overlay-state.json"),
      link('Hister search results', "#{HISTORIAN}/search?query=#{hw_query}"),
      link('Studio Workbench Target Specification', "#{SITE}/series/"),
      link('Site Main Archive', SITE)
    ])

    # 2. Testing the Audio Fix Under the Power Lines
    af_query = CGI.escape(JSON.generate(text: 'Mike Hall Testing the Audio Fix Under the Power Lines Field Recording 2026', limit: 12))
    folders << folder('Testing the Audio Fix Under the Power Lines', [
      link('Under the High-Tension Wires Case Study', "#{SITE}/ai/2026/10/12/under-the-high-tension-wires-building-deterministic-tools-from-nondeterministic-systems/"),
      link('Live Broadcast Workbench & A/B Listening Test', "#{SITE}/dehum/dashboard.html"),
      link('Source recording (YouTube 7YeFpKn5FbU)', 'https://www.youtube.com/watch?v=7YeFpKn5FbU'),
      link('Ramblin\' & Amblin\' Monologue: Revisiting the Dehum Experiment', 'https://just3ws.com/transcripts/ramblin-amblin-ok-next-experiment/'),
      link('Practice Run Recording', 'https://www.youtube.com/watch?v=7YeFpKn5FbU'),
      link('Hister search results', "#{HISTORIAN}/search?query=#{af_query}")
    ])

    # 3. Fluffle: Five Raspberry Pis and 1K+ Transcript Pairs
    fl_query = CGI.escape(JSON.generate(text: 'Mike Hall Fluffle: Five Raspberry Pis and 1K+ Transcript Pairs Errata Studio Walkthrough 2026', limit: 12))
    folders << folder('Fluffle: Five Raspberry Pis and 1K+ Transcript Pairs', [
      link('The Fluffle Precursor Retrospective', "#{SITE}/2026/10/16/the-fluffle-precursor-distributed-whisper-and-the-dead-rabbit-cluster.html"),
      link('GitHub: just3ws/fluffle Repository', 'https://github.com/just3ws/fluffle'),
      link('Local WITC Archive Index', 'file:///Volumes/Dock_1TB/WITC/'),
      link('Dead Rabbit Radio Daily Paranormal Podcast', 'https://deadrabbitradio.com'),
      link('Hister search results', "#{HISTORIAN}/search?query=#{fl_query}")
    ])

    # 4. Mirage of Competence
    folders << folder('The Mirage of Competence (AI Experiment)', [
      link('The Mirage of Competence on LinkedIn', 'https://www.linkedin.com/posts/just3ws_softwareengineering-generativeai-systemsarchitecture-ugcPost-7515895083825770496-e85P/'),
      link('Live Broadcast Workbench & Waveform HUD', "#{SITE}/dehum/dashboard.html")
    ])

    folder('Studio Workbench', folders)
  end

  def build_ramblin_amblin
    folders = []
    folders << folder('Playlists & Archive', [
      link('Active Series Playlist (YouTube)', 'https://www.youtube.com/playlist?list=PLNtb969T2-l0'),
      link('Sovereign Vault Archive Playlist (YouTube)', 'https://www.youtube.com/playlist?list=PLYCKmHMYvC7s'),
      link('Field Transcripts Full Archive', "#{SITE}/transcripts/"),
      link('Hister research search', HISTORIAN)
    ])

    folders << folder('Selected Field Notes & Transcripts', [
      link('Revisiting the Dehum Experiment', 'https://just3ws.com/transcripts/ramblin-amblin-ok-next-experiment/'),
      link('Mapping Ingress & Egress Points to Business Processes', "#{SITE}/transcripts/ramblin-amblin-mapping-ingress-and-egress-points-to-business-processes-ramb/"),
      link('Mapping Business Decisions Across the System', "#{SITE}/transcripts/ramblin-amblin-mapping-business-decisions-across-the-system-ramblin-amblin/"),
      link('When I Started Doing UGtastic', "#{SITE}/transcripts/ramblin-amblin-when-i-started-doing-ugtastic-the-way-i/"),
      link('Good Morning & Mosquito Hood Recording (YouTube)', 'https://www.youtube.com/watch?v=8FyUrHlDFzE&list=PLNtb969T2-l0')
    ])

    folder("Ramblin' & Amblin'", folders)
  end

  def all_series_folders
    [
      build_localhost_ecosystem,
      build_phalanx_duel,
      build_sound_above,
      build_studio_workbench,
      build_ramblin_amblin
    ]
  end

  def generate
    series_folders = all_series_folders
    FileUtils.mkdir_p(File.dirname(@output))
    File.write(@output, document(series_folders))
    puts "Wrote #{series_folders.size} bookmark collections to #{@output}"
  end

  def install_to_chromium
    unless File.file?(CHROMIUM_BOOKMARKS)
      warn "Error: Chromium Bookmarks file not found: #{CHROMIUM_BOOKMARKS}"
      return false
    end

    # Ensure Chromium is stopped to prevent file overwrite on quit
    was_running = system('pgrep Chromium > /dev/null 2>&1')
    if was_running
      puts 'Gracefully stopping Chromium before updating Bookmarks profile...'
      system("osascript -e 'tell application \"Chromium\" to quit' > /dev/null 2>&1")
      10.times do
        break unless system('pgrep Chromium > /dev/null 2>&1')

        sleep 0.5
      end
    end

    # Timestamped backup
    backup_path = "#{CHROMIUM_BOOKMARKS}.backup-#{Time.now.strftime('%Y%m%d-%H%M%S')}"
    FileUtils.cp(CHROMIUM_BOOKMARKS, backup_path)
    puts "Created backup of Chromium bookmarks at: #{backup_path}"

    b_data = JSON.parse(File.read(CHROMIUM_BOOKMARKS))
    existing_ids = []
    scan_ids = lambda do |node|
      existing_ids << node['id'].to_i if node['id']
      node['children']&.each { |child| scan_ids.call(child) }
    end
    b_data['roots'].each_value { |root_node| scan_ids.call(root_node) }

    max_id = existing_ids.max || 1000
    id_gen = Enumerator.new { |y| (max_id + 1).step { |n| y << n.to_s } }
    timestamp = (Time.now.to_f * 1_000_000 + 11644473600000000).to_i.to_s

    bar = b_data['roots']['bookmark_bar']
    preserved_children = bar['children'].select { |c| PRESERVED_BAR_ITEMS.include?(c['name']) }

    bar['children'] = [to_chromium_node(build_localhost_ecosystem, id_gen, timestamp)] +
                      preserved_children +
                      [
                        to_chromium_node(build_phalanx_duel, id_gen, timestamp),
                        to_chromium_node(build_sound_above, id_gen, timestamp),
                        to_chromium_node(build_studio_workbench, id_gen, timestamp),
                        to_chromium_node(build_ramblin_amblin, id_gen, timestamp)
                      ]

    File.write(CHROMIUM_BOOKMARKS, JSON.pretty_generate(b_data))
    puts "Successfully updated Chromium Bookmarks with Localhost and Phalanx Duel folders."

    if was_running
      puts 'Relaunching Chromium...'
      system('open -a Chromium')
    end

    true
  end

  private

  def to_chromium_node(item, id_gen, timestamp)
    if item[:entries]
      {
        'children' => item[:entries].map { |child| to_chromium_node(child, id_gen, timestamp) },
        'date_added' => timestamp,
        'date_last_used' => '0',
        'date_modified' => timestamp,
        'guid' => SecureRandom.uuid,
        'id' => id_gen.next,
        'name' => item[:title],
        'type' => 'folder'
      }
    else
      {
        'date_added' => timestamp,
        'date_last_used' => '0',
        'guid' => SecureRandom.uuid,
        'id' => id_gen.next,
        'name' => item[:title],
        'type' => 'url',
        'url' => item[:url]
      }
    end
  end

  def episode_folder(number)
    dossier = load_yaml(format('episode-%02d.yml', number))
    title = format('Episode %02d: %s', number, dossier.fetch('title'))
    entries = [link('Season One working outline', "#{SITE}/series/the-sound-above/")]
    if number.between?(1, 35)
      entries << link('Episode page', "#{SITE}/series/the-sound-above/episode-#{format('%02d', number)}/")
      entries << link('Archive interview', "#{SITE}/interviews/#{dossier['slug']}/")
    elsif number > 35
      entries << link('Possible later extras in the working outline', "#{SITE}/series/the-sound-above/#series-codas")
    end
    entries << link('Source recording', "https://www.youtube.com/watch?v=#{dossier['youtube_video_id']}") if dossier['youtube_video_id']

    query = [dossier['interviewee'], dossier['title'], dossier['conference'], dossier['year']].compact.join(' ')
    payload = CGI.escape(JSON.generate(text: query, limit: 12))
    entries << link('Hister search results', "#{HISTORIAN}/search?query=#{payload}")

    Array(dossier['research_attachments']).each do |attachment|
      url = attachment['url'] || attachment['path']
      next unless url

      url = "#{SITE}#{url}" if url.start_with?('/')
      entries << link(attachment['title'] || 'Research source', url)
    end
    folder(title, entries)
  rescue Errno::ENOENT
    folder("Episode #{number} dossier missing", [link('Episode workbench', "#{SITE}/series/the-sound-above/")])
  end

  def load_yaml(filename)
    YAML.safe_load_file(File.join(EPISODES, filename), permitted_classes: [Date, Time], aliases: true)
  end

  def link(title, url)
    { title: title, url: url }
  end

  def folder(title, entries)
    { title: title, entries: entries }
  end

  def document(folders)
    rendered_folders = folders.map { |f| render_node(f) }.join("\n")
    "<!DOCTYPE NETSCAPE-Bookmark-file-1>\n<META HTTP-EQUIV=\"Content-Type\" CONTENT=\"text/html; charset=UTF-8\">\n<TITLE>Channel Series & Platform Research Bookmarks</TITLE>\n<H1>Channel Series & Platform Research Bookmarks</H1>\n<DL><p>\n#{rendered_folders}\n</DL><p>\n"
  end

  def render_node(item)
    title = CGI.escapeHTML(item[:title])
    children = item[:entries].map do |entry|
      if entry[:entries]
        render_node(entry)
      else
        %(<DT><A HREF="#{CGI.escapeHTML(entry[:url])}">#{CGI.escapeHTML(entry[:title])}</A>)
      end
    end.join("\n")
    %(<DT><H3>#{title}</H3>\n<DL><p>\n#{children}\n</DL><p>)
  end
end

if __FILE__ == $PROGRAM_NAME
  output = EpisodeBookmarks::DEFAULT_OUTPUT
  install = false

  parser = OptionParser.new do |opts|
    opts.banner = 'Usage: bin/episode_bookmarks.rb [options] [output_file]'
    opts.separator ''
    opts.separator 'Generates and installs research bookmarks for Localhost (*.localhost),'
    opts.separator 'Phalanx Duel, The Sound Above, Studio Workbench, and Ramblin\' & Amblin\'.'
    opts.separator ''

    opts.on('-i', '--install', 'Install bookmarks directly into Chromium browser profile') do
      install = true
    end

    opts.on('-o', '--output FILE', 'Path for Netscape HTML bookmark export') do |f|
      output = f
    end

    opts.on_tail('-h', '--help', 'Show this help message') do
      puts opts
      exit 0
    end
  end

  parser.parse!
  output = ARGV[0] if ARGV[0] && !ARGV[0].start_with?('-')

  eb = EpisodeBookmarks.new(output)
  eb.generate
  eb.install_to_chromium if install
end
