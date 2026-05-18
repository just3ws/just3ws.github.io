#!/usr/bin/env ruby
require 'yaml'
require 'json'
require 'net/http'
require 'uri'

# Config
DOWNLOADS_DIR = File.expand_path("~/Downloads/transcripts")
SAMPLES = {
  "jez-humble-goto-conference-2014" => "vbZjw_Sw73M",
  "rich-hickey-creator-of-clojure-general" => "HF0ZsbUjEDw",
  "david-heinemeier-hansson-dhh-railsconf-2014" => "z94-DGthrfY",
  "charles-oliver-nutter-general" => "Xxb2mEaRSdc",
  "aaron-patterson-ruby-rails-core-team-member-keynote-speaker-railsconf-2014" => "OJf6GxeRiFQ",
  "corey-haines-goto-conference-2015" => "xhkWYAakUgs",
  "michael-t-nygard-goto-conference-2014" => "FwqdaF4lmzk",
  "igor-polevoy-general" => "0YwYKHnEWJk",
  "martin-atkins-chicagowebconf-2012" => "KkrozCdBYHs",
  "adewale-oshineye-software-craftsmanship-north-america-2013" => "GGhUZTBA6L4"
}

def call_ai(prompt)
  uri = URI.parse("http://127.0.0.1:8080/v1/chat/completions")
  http = Net::HTTP.new(uri.host, uri.port)
  http.read_timeout = 600

  request = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json'})
  request.body = {
    model: "local",
    messages: [
      { role: "system", content: "You are an expert technical copywriter and SEO specialist. Your goal is to optimize YouTube metadata for archival technical interviews." },
      { role: "user", content: prompt }
    ],
    temperature: 0.1
  }.to_json

  begin
    response = http.request(request)
    if response.code == "200"
      result = JSON.parse(response.body)
      return result.dig("choices", 0, "message", "content").gsub(/```yaml\n|```/, '').strip
    end
  rescue
  end
  nil
end

interviews = YAML.load_file("_data/interviews.yml")["items"]
assets = YAML.load_file("_data/video_assets.yml")["items"]

SAMPLES.each do |interview_id, yt_id|
  json_path = File.join(DOWNLOADS_DIR, yt_id, "#{yt_id}.json")
  next unless File.exist?(json_path)

  puts "Optimizing: #{interview_id}..."
  json_data = JSON.parse(File.read(json_path))
  
  # Sample text for AI (avoid OOM)
  sample_text = json_data["transcription"].first(50).map { |t| "[#{t['timestamps']['from']}] #{t['text']}" }.join("\n")
  sample_text += "\n...\n"
  sample_text += json_data["transcription"].last(20).map { |t| "[#{t['timestamps']['from']}] #{t['text']}" }.join("\n")

  prompt = <<~PROMPT
    Generate highly engaging, SEO-friendly YouTube metadata for this archival tech interview.
    
    ### CONTEXT
    Interviewer: Mike Hall (UGtastic)
    Interviewee: #{interview_id.gsub('-', ' ').capitalize}
    
    ### TRANSCRIPTION SAMPLE
    #{sample_text}
    
    ### OUTPUT SCHEMA (STRICT YAML)
    title: "Hook: Guest Name on Topic | Archive"
    description: "Engaging 2-sentence hook. Brief summary. CTA: Read full structured transcript at https://just3ws.github.io/interviews/#{interview_id}"
    chapters:
      - 00:00:00 - Introduction
      - 00:XX:XX - [Pivotal Moment 1]
      - 00:XX:XX - [Pivotal Moment 2]
    
    Do not output any prose outside the YAML.
  PROMPT

  optimized_yaml = call_ai(prompt)
  if optimized_yaml
    begin
      metadata = YAML.safe_load(optimized_yaml)
      
      # Update interviews.yml
      interview = interviews.find { |i| i["id"] == interview_id }
      interview["title"] = metadata["title"] if interview

      # Update video_assets.yml
      asset = assets.find { |a| a["id"] == (interview ? interview["video_asset_id"] : nil) } || assets.find { |a| a["id"] == interview_id }
      if asset
        asset["title"] = metadata["title"]
        asset["description"] = metadata["description"]
        # In a real setup we might add chapters to a separate field, but for now we append to description
        asset["description"] += "\n\nChapters:\n" + metadata["chapters"].join("\n")
      end

      puts "  Success!"
    rescue => e
      puts "  Error: #{e.message}"
    end
  end
end

File.write("_data/interviews.yml", { "items" => interviews }.to_yaml)
File.write("_data/video_assets.yml", { "items" => assets }.to_yaml)
