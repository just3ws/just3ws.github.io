#!/usr/bin/env ruby
# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

KEY = '8d7a1e4c2b9f0a3e5c7d1e8b2a4f6c9e'
HOST = 'www.just3ws.com'
KEY_LOCATION = "https://#{HOST}/#{KEY}.txt"

URLS = [
  "https://#{HOST}/",
  "https://#{HOST}/resume/",
  "https://#{HOST}/resumes/mike-hall-principal-software-engineer/",
  "https://#{HOST}/resumes/mike-hall-staff-platform-lead/",
  "https://#{HOST}/resumes/mike-hall-senior-ruby-rails-contractor/",
  "https://#{HOST}/resumes/mike-hall-founding-staff-engineer/",
  "https://#{HOST}/resumes/mike-hall-observability-resilience-specialist/",
  "https://#{HOST}/case-studies/",
  "https://#{HOST}/2026/08/29/system-cartography-how-to-map-a-ten-year-old-monolith/",
  "https://#{HOST}/career_datalake.json",
  "https://#{HOST}/llms.txt"
].freeze

puts "🚀 Initiating Search Engine Recrawl Notification..."
puts "------------------------------------------------------------"
puts "Target Host: #{HOST}"
puts "Key Location: #{KEY_LOCATION}"
puts "URLs to submit: #{URLS.size}"
URLS.each { |u| puts "  • #{u}" }
puts "------------------------------------------------------------"

payload = {
  host: HOST,
  key: KEY,
  keyLocation: KEY_LOCATION,
  urlList: URLS
}.to_json

endpoints = [
  'https://api.indexnow.org/indexnow',
  'https://www.bing.com/indexnow',
  'https://yandex.com/indexnow'
]

endpoints.each do |ep|
  uri = URI.parse(ep)
  puts "📡 Submitting to #{uri.host} (#{ep})..."
  begin
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    http.open_timeout = 10
    http.read_timeout = 10

    req = Net::HTTP::Post.new(uri.request_uri, {
      'Content-Type' => 'application/json; charset=utf-8',
      'User-Agent' => 'Just3ws-CareerOS-Ping/1.0'
    })
    req.body = payload

    res = http.request(req)
    case res.code.to_i
    when 200
      puts "  ✅ #{uri.host}: 200 OK (URLs successfully submitted for immediate indexing)"
    when 202
      puts "  ✅ #{uri.host}: 202 Accepted (URLs queued for immediate crawl)"
    else
      puts "  ℹ️  #{uri.host}: HTTP #{res.code} - #{res.body}"
    end
  rescue StandardError => e
    puts "  ⚠️ Error connecting to #{uri.host}: #{e.message}"
  end
end

puts "------------------------------------------------------------"
puts "ℹ️ Note on Google:"
puts "Google deprecated HTTP sitemap pings in Dec 2023."
puts "To trigger an immediate Google re-crawl of https://#{HOST}/:"
puts "1. Open Google Search Console: https://search.google.com/search-console"
puts "2. Paste https://#{HOST}/ into the top URL Inspection bar."
puts "3. Click 'Request Indexing'."
puts "------------------------------------------------------------"
