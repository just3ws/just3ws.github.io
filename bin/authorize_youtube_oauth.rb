#!/usr/bin/env ruby
# frozen_string_literal: true

# bin/authorize_youtube_oauth.rb
# Local interactive OAuth 2.0 handshake helper to obtain YouTube API refresh tokens.

require 'json'
require 'fileutils'
require 'net/http'
require 'uri'
require 'webrick'
require 'signet/oauth_2/client'

CREDENTIALS_DIR = ".credentials"
CREDENTIALS_FILE = File.join(CREDENTIALS_DIR, "youtube_oauth.json")
CLIENT_SECRET_FILE = File.join(CREDENTIALS_DIR, "client_secret.json")

SCOPES = [
  "https://www.googleapis.com/auth/youtube.force-ssl",
  "https://www.googleapis.com/auth/youtube.upload"
].freeze

puts "🔐 YouTube OAuth 2.0 Authorization CLI"
puts "=========================================================="

FileUtils.mkdir_p(CREDENTIALS_DIR)

unless File.exist?(CLIENT_SECRET_FILE)
  puts "⚠️  Client secret file not found at #{CLIENT_SECRET_FILE}"
  puts ""
  puts "To set up:"
  puts "1. Go to Google Cloud Console (https://console.cloud.google.com/)"
  puts "2. Enable YouTube Data API v3"
  puts "3. Create OAuth 2.0 Client ID (Desktop Application)"
  puts "4. Download JSON and save as #{CLIENT_SECRET_FILE}"
  puts "=========================================================="
  exit 1
end

raw_secret = JSON.parse(File.read(CLIENT_SECRET_FILE))
installed_config = raw_secret["installed"] || raw_secret["web"] || {}

client_id = installed_config["client_id"]
client_secret = installed_config["client_secret"]

unless client_id && client_secret
  puts "❌ Invalid client_secret.json format. Missing client_id or client_secret."
  exit 1
end

# Spin up local redirect receiver on localhost:8089
port = 8089
redirect_uri = "http://localhost:#{port}/oauth2callback"

client = Signet::OAuth2::Client.new(
  authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
  token_credential_uri: 'https://oauth2.googleapis.com/token',
  client_id: client_id,
  client_secret: client_secret,
  scope: SCOPES,
  redirect_uri: redirect_uri
)

auth_url = client.authorization_uri(
  access_type: 'offline',
  prompt: 'consent'
).to_s

puts "🌐 Starting local listener on #{redirect_uri}..."
puts ""
puts "👉 Open the following URL in your browser to authorize:"
puts ""
puts auth_url
puts ""

server = WEBrick::HTTPServer.new(
  Port: port,
  Logger: WEBrick::Log.new('/dev/null'),
  AccessLog: []
)

auth_code = nil

server.mount_proc '/oauth2callback' do |req, res|
  auth_code = req.query['code']
  res.body = "<h1>YouTube Authorization Successful!</h1><p>You can close this window and return to your terminal.</p>"
  Thread.new { sleep 1; server.stop }
end

trap('INT') { server.stop }
server.start

if auth_code
  puts "🔑 Authorization code received! Exchanging for refresh token..."
  client.code = auth_code
  client.fetch_access_token!

  oauth_data = {
    client_id: client_id,
    client_secret: client_secret,
    refresh_token: client.refresh_token,
    authorized_at: Time.now.utc.iso8601
  }

  File.write(CREDENTIALS_FILE, JSON.pretty_generate(oauth_data))
  puts "✅ Refresh token saved securely to #{CREDENTIALS_FILE}"
  puts "🎉 You are now ready to run `ruby bin/sync_youtube_captions.rb --upload`!"
else
  puts "❌ Failed to capture authorization code."
end
