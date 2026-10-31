#!/usr/bin/env ruby
# frozen_string_literal: true

# Generates a Netscape bookmark file for The Sound Above episode research.
# Import the resulting HTML file in Chromium's Bookmark Manager.

require 'cgi'
require 'json'
require 'yaml'

class EpisodeBookmarks
  ROOT = File.expand_path('..', __dir__)
  SEQUENCE = File.join(ROOT, '_data', 'sound_above_sequence.json')
  EPISODES = File.join(ROOT, '_data', 'episodes')
  DEFAULT_OUTPUT = File.join(ROOT, 'obs', 'bookmarks', 'the-sound-above-rewatch.html')
  SITE = 'https://www.just3ws.localhost'
  HISTORIAN = 'https://hister.localhost'

  def initialize(output = DEFAULT_OUTPUT)
    @output = File.expand_path(output)
    @sequence = JSON.parse(File.read(SEQUENCE))
  end

  def generate
    folders = []
    folders << folder('Start here', [
      link('The Sound Above series', "#{SITE}/series/the-sound-above/"),
      link('UGtastic interview archive', "#{SITE}/interviews/"),
      link('Hister research search', HISTORIAN)
    ])

    folders << folder('Setup episodes', [episode_folder(-1), episode_folder(0)])

    interviews = @sequence.fetch('episodes', [])
    folders << folder('Season One: working target of up to 17 interviews',
                      interviews.select { |episode| episode.fetch('number') <= 17 }
                                .map { |episode| episode_folder(episode.fetch('number')) })
    folders << folder('Archive candidates: not scheduled',
                      interviews.select { |episode| episode.fetch('number') > 17 }
                                .map { |episode| episode_folder(episode.fetch('number')) })

    codas = @sequence.fetch('codas', []).each_index.map { |index| episode_folder(36 + index) }
    folders << folder('Possible later extras', codas) unless codas.empty?

    FileUtils.mkdir_p(File.dirname(@output))
    File.write(@output, document(folders))
    puts "Wrote #{folders.size} research folders to #{@output}"
  end

  private

  def episode_folder(number)
    dossier = if number == -1
                load_yaml('errata-fluffle-precursor.yml')
              else
                load_yaml(format('episode-%02d.yml', number))
              end
    title = format('Episode %s: %s', number.negative? ? 'Minus One' : number.to_s.rjust(2, '0'), dossier.fetch('title'))
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
    root = render_node(folder('The Sound Above Rewatch', folders))
    "<!DOCTYPE NETSCAPE-Bookmark-file-1>\n<META HTTP-EQUIV=\"Content-Type\" CONTENT=\"text/html; charset=UTF-8\">\n<TITLE>The Sound Above Rewatch</TITLE>\n<H1>The Sound Above Rewatch</H1>\n<DL><p>\n#{root}\n</DL><p>\n"
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

require 'date'
require 'fileutils'

output = ARGV[0] && !ARGV[0].start_with?('-') ? ARGV[0] : EpisodeBookmarks::DEFAULT_OUTPUT
EpisodeBookmarks.new(output).generate
