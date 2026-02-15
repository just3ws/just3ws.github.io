#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "open3"
require "pathname"
require "set"
require "uri"

ROOT = Pathname(__dir__).join("..").expand_path
WAYBACK_DIR = ROOT.join("docs", "wayback")

SPECS = [
  {
    key: "frogsbrain_blogger",
    query: "http://frogsbrain.blogspot.com/*",
    output: WAYBACK_DIR.join("targets-personal-blogger-frogsbrain-posts-cdx.txt"),
    matcher: lambda do |host, path|
      host == "frogsbrain.blogspot.com" && path.match?(%r{\A/\d{4}/\d{2}/[^/?#]+\.html\z}i)
    end
  },
  {
    key: "just3ws_blogger",
    query: "http://just3ws.blogspot.com/*",
    output: WAYBACK_DIR.join("targets-personal-blogger-just3ws-posts-cdx.txt"),
    matcher: lambda do |host, path|
      host == "just3ws.blogspot.com" && path.match?(%r{\A/\d{4}/\d{2}/[^/?#]+\.html\z}i)
    end
  },
  {
    key: "just3ws_wordpress",
    query: "http://just3ws.wordpress.com/*",
    output: WAYBACK_DIR.join("targets-personal-wordpress-posts-cdx.txt"),
    matcher: lambda do |host, path|
      host == "just3ws.wordpress.com" && path.match?(%r{\A/\d{4}/\d{2}/\d{2}/[^/?#]+/?\z}i)
    end
  },
  {
    key: "ironlanguages",
    query: "http://ironlanguages.net/*",
    output: WAYBACK_DIR.join("targets-personal-ironlanguages-posts-cdx.txt"),
    matcher: lambda do |host, path|
      next false unless host == "ironlanguages.net"
      next false unless path.match?(%r{\A/[^/?#]+\z})
      next false if path.match?(%r{\A/(archive|tag|posts|responses|likes|images|themes|mp3player|feed|rss)\b}i)

      true
    end
  }
].freeze

def normalize_original(original)
  value = original.to_s.strip
  value = value.sub(%r{\Ahttps?://}i, "http://")
  value = value.sub(%r{:80(?=/|\z)}, "")
  value = value.sub(%r{/\z}, "")
  value
end

def wayback_url(stamp, original)
  "https://web.archive.org/web/#{stamp}/#{original}"
end

def fetch_cdx_rows(query, retries: 6)
  url = "https://web.archive.org/cdx/search/cdx?url=#{query}" \
        "&output=json&fl=timestamp,original,statuscode,mimetype&filter=statuscode:200&collapse=urlkey"
  attempts = 0
  begin
    stdout, stderr, status = Open3.capture3("curl", "-fsSL", "--max-time", "180", url)
    raise stderr.strip unless status.success?

    parsed = JSON.parse(stdout)
    parsed.is_a?(Array) ? parsed : []
  rescue StandardError => e
    attempts += 1
    raise "CDX fetch failed for #{query}: #{e}" if attempts > retries

    sleep(1.0 * attempts)
    retry
  end
end

def build_manifest_rows(rows, matcher:)
  selected = {}
  rows.drop(1).each do |row|
    stamp, original = row[0].to_s, row[1].to_s
    next if stamp.empty? || original.empty?

    normalized = normalize_original(original)
    begin
      uri = URI(normalized)
    rescue StandardError
      next
    end
    host = uri.host.to_s.downcase
    path = uri.path.to_s
    next unless matcher.call(host, path)

    current = selected[normalized]
    if current.nil? || stamp > current[:stamp]
      selected[normalized] = { stamp: stamp }
    end
  end

  selected
    .keys
    .sort
    .map { |original| wayback_url(selected[original][:stamp], original) }
end

def write_manifest(path, title, query, urls)
  body = +""
  body << "# #{title}\n"
  body << "# Source: CDX query #{query}\n"
  urls.each { |url| body << "#{url}\n" }
  path.write(body)
end

SPECS.each do |spec|
  begin
    rows = fetch_cdx_rows(spec[:query])
    urls = build_manifest_rows(rows, matcher: spec[:matcher])
    write_manifest(spec[:output], "Discovered posts for #{spec[:key]}", spec[:query], urls)
    puts "Wrote #{spec[:output].relative_path_from(ROOT)} (#{urls.size} URLs)"
  rescue StandardError => e
    warn e.message
  end
end
