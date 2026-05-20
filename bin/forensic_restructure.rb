#!/usr/bin/env ruby
require 'yaml'
require 'json'
require 'net/http'
require 'uri'

# --- CONFIG ---
AI_ENDPOINT = "http://127.0.0.1:8080/v1/chat/completions"

def call_ai(prompt, system_prompt = "You are a professional technical transcript editor.")
  uri = URI.parse(AI_ENDPOINT)
  http = Net::HTTP.new(uri.host, uri.port)
  http.read_timeout = 600

  request = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json'})
  request.body = {
    model: "local",
    messages: [
      { role: "system", content: system_prompt },
      { role: "user", content: prompt }
    ],
    temperature: 0.1
  }.to_json

  begin
    response = http.request(request)
    if response.code == "200"
      result = JSON.parse(response.body)
      return result.dig("choices", 0, "message", "content").strip
    end
  rescue
  end
  nil
end

def process_file(path)
  begin
    data = YAML.load_file(path, permitted_classes: [Date, Time], aliases: true)
    
    # Extract full text from turns or content
    text = data["turns"] ? data["turns"].map{|t| t["text"]}.join("\n\n") : data["content"]
    return unless text && !text.strip.empty?
    
    interview_id = File.basename(path, ".yml")
    interviews = YAML.load_file("_data/interviews.yml")["items"]
    metadata = interviews.find { |i| i["id"] == interview_id } || {}
    guest_name = metadata["interviewees"]&.join(", ") || "the guest"

    puts "Structuring: #{path}..."
    
    # Split into ~500 word chunks to avoid OOM
    words = text.split(/\s+/)
    chunks = words.each_slice(500).map{|s| s.join(" ")}
    
    all_turns = []
    
    chunks.each_with_index do |chunk, i|
      print "  Processing chunk #{i+1}/#{chunks.size}... "
      
      prompt = <<~PROMPT
        Break the following interview text into a back-and-forth dialogue.
        Speakers: M1 (Mike Hall - Interviewer), S1 (#{guest_name}).
        Mike asks the questions, #{guest_name} provides the technical answers.
        
        TEXT:
        #{chunk}
        
        Output ONLY valid YAML matching this structure:
        turns:
          - speaker: M1|S1
            text: "..."
      PROMPT

      yaml_resp = call_ai(prompt, "Output only YAML. No prose.")
      if yaml_resp
        begin
          clean_yaml = yaml_resp.gsub(/```yaml\n|```/, '').strip
          parsed = YAML.safe_load(clean_yaml)
          if parsed && parsed["turns"]
            all_turns.concat(parsed["turns"])
            puts "OK"
          else
            puts "FAILED (Invalid Schema)"
          end
        rescue => e
          puts "FAILED (Parse Error: #{e.message})"
        end
      else
        puts "FAILED (AI Error)"
      end
    end

    if all_turns.any?
      # Merge consecutive turns by the same speaker
      merged = []
      all_turns.each do |t|
        if merged.any? && merged.last["speaker"] == t["speaker"]
          merged.last["text"] += " " + t["text"]
        else
          merged << t
        end
      end
      
      data["turns"] = merged
      data.delete("content")
      
      # Ensure speaker map is present
      data["speaker_map"] ||= {
        "M1" => { "name" => "Mike Hall", "role" => "Interviewer, UGtastic" },
        "S1" => { "name" => guest_name, "role" => metadata["topic"] || "Guest" }
      }
      
      File.write(path, data.to_yaml)
      puts "Successfully structured #{path}"
    else
      puts "No turns generated for #{path}"
    end
    
  rescue => e
    puts "Error processing #{path}: #{e.message}"
  end
end

# Main loop
ARGV.each do |f|
  process_file(f)
end
