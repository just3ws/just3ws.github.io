#!/usr/bin/env ruby
# frozen_string_literal: true

# ---
# name: remap_legacy_routes.rb
# domain: site
# purpose: Test, resolve, and audit inbound legacy URLs from ugtastic.com, chicagocodecamp.com, scmchenry, and social handles
# usage: ruby bin/remap_legacy_routes.rb --test <url_or_path> OR ruby bin/remap_legacy_routes.rb --report <log_file>
# ---

require 'json'
require 'yaml'
require 'uri'
require 'optparse'

ROOT = File.expand_path('..', __dir__) unless defined?(ROOT)
LEGACY_MAP_PATH = File.join(ROOT, 'assets', 'data', 'legacy_route_map.json') unless defined?(LEGACY_MAP_PATH)
LEGACY_CONFIG_PATH = File.join(ROOT, '_data', 'legacy_routes.yml') unless defined?(LEGACY_CONFIG_PATH)

class LegacyRouteResolver
  attr_reader :map, :config

  def initialize(map_path = LEGACY_MAP_PATH, config_path = LEGACY_CONFIG_PATH)
    unless File.file?(map_path)
      system("ruby #{File.join(ROOT, 'bin', 'generate_legacy_route_map.rb')}")
    end
    @map = JSON.parse(File.read(map_path))
    @config = YAML.safe_load(File.read(config_path)) || {}
  end

  def normalize_path(path)
    p = path.to_s.strip
    return '/' if p.empty?
    p = "/#{p}" unless p.start_with?('/')
    p.gsub(%r{/{2,}}, '/')
  end

  def resolve(input)
    uri_str = input.to_s.strip
    uri_str = "http://#{uri_str}" unless uri_str =~ %r{\A[a-zA-Z]+://}

    begin
      parsed = URI.parse(uri_str)
      host = parsed.host.to_s.downcase
      path = normalize_path(parsed.path)
      query = parsed.query.to_s
    rescue URI::InvalidURIError
      host = ''
      path = normalize_path(input)
      query = ''
    end

    result = {
      'input' => input,
      'host' => host,
      'path' => path,
      'query' => query,
      'target_url' => nil,
      'target_title' => nil,
      'match_type' => 'unmapped',
      'confidence' => 0.0
    }

    # 1. Query parameter check (e.g. ?v=YOUTUBE_ID or ?p=POST_ID)
    if !query.empty?
      params = Hash[URI.decode_www_form(query)] rescue {}
      if params['v'] && @map['video_assets'] && @map['video_assets'][params['v']]
        match = @map['video_assets'][params['v']]
        result['target_url'] = match['url']
        result['target_title'] = match['title']
        result['match_type'] = 'video_query'
        result['confidence'] = 1.0
        return result
      end
    end

    # 2. Exact route match
    clean_path = path.chomp('/')
    clean_path = '/' if clean_path.empty?

    if @map['exact_routes'] && @map['exact_routes'][path]
      result['target_url'] = @map['exact_routes'][path]
      result['match_type'] = 'exact_route'
      result['confidence'] = 1.0
      return result
    elsif @map['exact_routes'] && @map['exact_routes'][clean_path]
      result['target_url'] = @map['exact_routes'][clean_path]
      result['match_type'] = 'exact_route'
      result['confidence'] = 1.0
      return result
    end

    # 3. Pattern rules
    patterns = @map['pattern_rules'] || []
    patterns.each do |rule|
      regex = Regexp.new(rule['pattern'], Regexp::IGNORECASE)
      if (m = path.match(regex))
        slug = m[1].to_s.downcase

        if rule['target_template']
          target = rule['target_template'].gsub('%{slug}', slug)
          # Verify target existence if slug is known
          if @map['interviews'] && @map['interviews'][slug]
            item = @map['interviews'][slug]
            result['target_url'] = item['url']
            result['target_title'] = item['title']
            result['match_type'] = 'interview_slug'
            result['confidence'] = 0.99
            return result
          elsif @map['interviewees'] && @map['interviewees'][slug]
            item = @map['interviewees'][slug]
            result['target_url'] = item['url']
            result['target_title'] = item['name']
            result['match_type'] = 'interviewee_slug'
            result['confidence'] = 0.99
            return result
          else
            result['target_url'] = target
            result['match_type'] = 'pattern_rule'
            result['confidence'] = 0.85
            return result
          end
        elsif rule['lookup'] == 'posts' && @map['posts']
          post_item = @map['posts'][slug] || @map['posts'][path] || @map['posts'][clean_path]
          if post_item
            result['target_url'] = post_item['url']
            result['target_title'] = post_item['title']
            result['match_type'] = 'post_slug'
            result['confidence'] = 0.95
            return result
          end
        end
      end
    end

    # 4. Direct video asset lookup by path (e.g. /video/YOUTUBE_ID or /videos/YOUTUBE_ID)
    if path =~ %r{\A/(?:videos?|vimeo)/([^/]+)/?\z}
      vid = Regexp.last_match(1)
      if @map['video_assets'] && @map['video_assets'][vid]
        match = @map['video_assets'][vid]
        result['target_url'] = match['url']
        result['target_title'] = match['title']
        result['match_type'] = 'video_path'
        result['confidence'] = 0.98
        return result
      end
    end

    # 5. Direct interview or post slug lookup
    clean_post_path = path.sub(%r{/+\z}, '').sub(/\.[^.]+\z/, '')
    if @map['posts'] && @map['posts'][clean_post_path]
      item = @map['posts'][clean_post_path]
      result['target_url'] = item['url']
      result['target_title'] = item['title']
      result['match_type'] = 'post_direct'
      result['confidence'] = 0.95
      return result
    end

    slug_candidate = path.sub(%r{\A/}, '').sub(%r{/+\z}, '').sub(/\.[^.]+\z/, '')
    if @map['interviews'] && @map['interviews'][slug_candidate]
      item = @map['interviews'][slug_candidate]
      result['target_url'] = item['url']
      result['target_title'] = item['title']
      result['match_type'] = 'interview_direct'
      result['confidence'] = 0.95
      return result
    end

    if @map['posts'] && @map['posts'][slug_candidate]
      item = @map['posts'][slug_candidate]
      result['target_url'] = item['url']
      result['target_title'] = item['title']
      result['match_type'] = 'post_direct'
      result['confidence'] = 0.95
      return result
    end

    # Match post by date conversion (e.g. 2010/04/12/chicago-code-camp-2 -> 2010-04-12-chicago-code-camp-2)
    if slug_candidate =~ %r{\A(\d{4})/(\d{2})/(\d{2})/(.+)\z}
      dashed = "#{Regexp.last_match(1)}-#{Regexp.last_match(2)}-#{Regexp.last_match(3)}-#{Regexp.last_match(4)}"
      if @map['posts'] && @map['posts'][dashed]
        item = @map['posts'][dashed]
        result['target_url'] = item['url']
        result['target_title'] = item['title']
        result['match_type'] = 'post_direct'
        result['confidence'] = 0.95
        return result
      end
    end

    # 6. Domain Fallback
    if !host.empty? && @map['domain_fallbacks'] && @map['domain_fallbacks'][host]
      result['target_url'] = @map['domain_fallbacks'][host]
      result['match_type'] = 'domain_fallback'
      result['confidence'] = 0.70
      return result
    end

    result
  end
end

if __FILE__ == $PROGRAM_NAME
  options = {}
  parser = OptionParser.new do |opts|
    opts.banner = 'Usage: ruby bin/remap_legacy_routes.rb [options]'
    opts.on('-t', '--test URL_OR_PATH', 'Test resolution of a single URL or path') do |v|
      options[:test] = v
    end
    opts.on('-r', '--report FILE', 'Analyze a CSV or JSONL log file of requests') do |v|
      options[:report] = v
    end
    opts.on('-j', '--json', 'Output results as JSON') do
      options[:json] = true
    end
    opts.on('-h', '--help', 'Show this help message') do
      puts opts
      exit 0
    end
  end

  parser.parse!

  resolver = LegacyRouteResolver.new

  if options[:test]
    res = resolver.resolve(options[:test])
    if options[:json]
      puts JSON.pretty_generate(res)
    else
      puts "Input:        #{res['input']}"
      puts "Host:         #{res['host'].empty? ? '(none)' : res['host']}"
      puts "Path:         #{res['path']}"
      puts "Match Type:   #{res['match_type']} (Confidence: #{(res['confidence'] * 100).round}%)"
      puts "Target URL:   #{res['target_url'] || '(unmapped)'}"
      puts "Target Title: #{res['target_title'] || '(none)'}"
    end
    exit 0
  elsif options[:report]
    path = options[:report]
    abort "File not found: #{path}" unless File.file?(path)

    recovered = []
    unmapped = []

    lines = File.readlines(path)
    lines.each do |line|
      line = line.strip
      next if line.empty?
      url = line
      res = resolver.resolve(url)
      if res['target_url']
        recovered << res
      else
        unmapped << res
      end
    end

    puts "Total requests: #{lines.size}"
    puts "Recovered:      #{recovered.size}"
    puts "Unmapped:       #{unmapped.size}"
    exit 0
  else
    puts parser
    exit 1
  end
end
