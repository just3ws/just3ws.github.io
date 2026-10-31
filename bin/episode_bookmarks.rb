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

    folders << episode_folder(-1, 'Setup episode: Minus One')
    folders << episode_folder(0, 'Setup episode: Zero')

    @sequence.fetch('episodes', []).each do |episode|
      number = episode.fetch('number')
      group = number <= 17 ? 'Season One working target: interviews 1 to 17' : 'Archive candidates: not scheduled'
      folders << episode_folder(number, group)
    end

    @sequence.fetch('codas', []).each_with_index do |coda, index|
      number = 36 + index
      folders << episode_folder(number, 'Possible later codas')
    end

    FileUtils.mkdir_p(File.dirname(@output))
    File.write(@output, document(folders))
    puts "Wrote #{folders.size} research folders to #{@output}"
  end

  private

  def episode_folder(number, label)
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
    folder("#{label} / #{title}", entries)
  rescue Errno::ENOENT
    folder("#{label} / Episode #{number} dossier missing", [link('Episode workbench', "#{SITE}/series/the-sound-above/")])
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
    body = folders.map do |item|
      children = item[:entries].map do |entry|
        %(<DT><A HREF="#{CGI.escapeHTML(entry[:url])}">#{CGI.escapeHTML(entry[:title])}</A>)
      end.join("\n")
      %(<DT><H3>#{CGI.escapeHTML(item[:title])}</H3>\n<DL><p>\n#{children}\n</DL><p>)
    end.join("\n")
    "<!DOCTYPE NETSCAPE-Bookmark-file-1>\n<META HTTP-EQUIV=\"Content-Type\" CONTENT=\"text/html; charset=UTF-8\">\n<TITLE>The Sound Above Rewatch</TITLE>\n<H1>The Sound Above Rewatch</H1>\n<DL><p>\n#{body}\n</DL><p>\n"
  end
end

require 'date'
require 'fileutils'

output = ARGV[0] && !ARGV[0].start_with?('-') ? ARGV[0] : EpisodeBookmarks::DEFAULT_OUTPUT
EpisodeBookmarks.new(output).generate
