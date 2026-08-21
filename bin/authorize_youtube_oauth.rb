#!/usr/bin/env ruby
# frozen_string_literal: true

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
  puts "❌ Missing #{CLIENT_SECRET_FILE}"
  exit 1
end

raw_secret = JSON.parse(File.read(CLIENT_SECRET_FILE))
installed_config = raw_secret["installed"] || raw_secret["web"] || {}

client_id = installed_config["client_id"]
client_secret = installed_config["client_secret"]

# Bind to port 8080 (standard Google Desktop client redirect target)
port = 8080
redirect_uri = "http://localhost:#{port}"

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

puts ""
puts "👉 1. Open the following URL in your browser:"
puts "--------------------------------------------------------------------------------"
puts auth_url
puts "--------------------------------------------------------------------------------"
puts ""
puts "⏳ Waiting for authorization callback on #{redirect_uri}..."
puts "💡 (Or copy the 'code=...' parameter from your browser URL and paste it below if needed)"
print "Paste code here (optional): "

auth_code = nil

# Background listener on port 8080
server = WEBrick::HTTPServer.new(
  Port: port,
  Logger: WEBrick::Log.new('/dev/null'),
  AccessLog: []
)

server.mount_proc '/' do |req, res|
  if req.query['code']
    auth_code = req.query['code']
    res.body = "<html><body style='font-family:sans-serif;text-align:center;padding:40px;'><h2>✅ YouTube Authorization Successful!</h2><p>You can close this tab and return to your terminal.</p></body></html>"
    Thread.new { sleep 1; server.stop }
  elsif req.query['error']
    res.body = "<html><body style='font-family:sans-serif;text-align:center;padding:40px;color:red;'><h2>❌ Authorization Failed: #{req.query['error']}</h2></body></html>"
    Thread.new { sleep 1; server.stop }
  end
end

server_thread = Thread.new { server.start }

# Allow manual input or listener
trap('INT') { server.stop; exit 0 }

while auth_code.nil? && server_thread.alive?
  sleep 0.5
end

if auth_code
  puts "\n🔑 Authorization code captured! Exchanging for refresh token..."
  client.code = auth_code
  client.fetch_access_token!

  oauth_data = {
    client_id: client_id,
    client_secret: client_secret,
    refresh_token: client.refresh_token,
    authorized_at: Time.now.utc.iso8601
  }

  File.write(CREDENTIALS_FILE, JSON.pretty_generate(oauth_data))
  puts "✅ SUCCESS! Refresh token saved to #{CREDENTIALS_FILE}"
  puts "🎉 You can now run YouTube sync commands!"
else
  puts "❌ Failed to capture authorization code."
end
