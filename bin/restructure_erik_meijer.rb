#!/usr/bin/env ruby
require 'yaml'
require 'json'
require 'net/http'
require 'uri'

FILE_PATH = "_data/transcripts/erik-meijer-creator-reactive-framework-general.yml"
data = YAML.load_file(FILE_PATH, permitted_classes: [Date, Time], aliases: true)

# Flatten current text
text = data["turns"].map { |t| t["text"] }.join("\n")

prompt = <<~PROMPT
  You are an expert transcript editor. Below is a monolithic block of interview text between an interviewer (Mike Hall) and an interviewee (Erik Meijer).
  Carefully read the text and separate it into a back-and-forth dialogue using M1 for Mike Hall and S1 for Erik Meijer.
  Mike Hall asks the questions and provides prompts (like "Right.", "Okay."), Erik Meijer gives the long answers. 
  Output ONLY valid YAML matching this structure:
  
  turns:
  - speaker: M1
    text: "Mike's text..."
  - speaker: S1
    text: "Erik's response..."
    
  Do not include anything outside of the YAML block. Avoid any extra commentary or markup.
  
  TEXT:
  #{text}
PROMPT

uri = URI.parse("http://127.0.0.1:8080/v1/chat/completions")
http = Net::HTTP.new(uri.host, uri.port)
http.read_timeout = 600

request = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json'})
request.body = {
  model: "local",
  messages: [
    { role: "system", content: "You are a precise data formatting tool. Output only YAML." },
    { role: "user", content: prompt }
  ],
  temperature: 0.1
}.to_json

response = http.request(request)
if response.code == "200"
  result = JSON.parse(response.body)
  yaml_output = result.dig("choices", 0, "message", "content").gsub(/```yaml\n|```/, '').strip
  
  begin
    parsed_yaml = YAML.safe_load(yaml_output)
    if parsed_yaml && parsed_yaml["turns"]
      data["turns"] = parsed_yaml["turns"]
      File.write(FILE_PATH, data.to_yaml)
      puts "Successfully restructured Erik Meijer's transcript."
    else
      puts "YAML parsed but no 'turns' found."
    end
  rescue => e
    puts "Error parsing YAML: #{e.message}"
    puts yaml_output
  end
else
  puts "Error from LLM: #{response.code}"
end
