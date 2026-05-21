#!/usr/bin/env ruby
require 'yaml'

# --- LEXICAL NAME REPAIRS ---
NAME_REPAIRS = {
  "Gil Tene" => [/Gail Tenney/i, /Gil Ten\b/i, /Galtin/i],
  "Rich Hickey" => [/Richie Hickey/i, /Richie Hicky/i],
  "Adewale Oshineye" => [/Adeo Shinyea/i, /Eddie Oceanea/i],
  "Sandro Mancuso" => [/Sandra Mancuso/i],
  "DHH" => [/\bD\.? ?H\.? ?H\.?\b/i],
  "Igor Polevoy" => [/\bIgor Fal[ae]voy\b/i, /\bIgor Pol[ao]v[oi]y\b/i],
  "Dave Thomas" => [/Dave Thomas/i, /Dave "pragdave" Thomas/i]
}

# --- JINGLE REGEX ---
JINGLE_REGEX = /User groups with lots to say.*?(?:UGtastic|uktastic|euketastic|ubtastic|evotasic|ugetastic|ukt|euke|uke|yugetastic|yuge|uktasek)(?:\s*\.?\s*com)?\.?\s*/im

RULES = [
  # --- Brand: UGtastic ---
  [/\b(?:you|yu|u|ub|uk|uke|uge|evo|e|ute|uget|ukt|yug|yuget|yuge|ugtasc)[ -]?g?[ -]?tastic(?:\.com)?\b/i, "UGtastic"],
  [/\bugtasc\b/i, "UGtastic"],
  [/\b[Uu]ktasek(?:\.com)?\b/i, "UGtastic"],
  [/\b[Uu]btastic(?:\.com)?\b/i, "UGtastic"],
  [/\b[Ee]vo[ -]?Tasic\b/i, "UGtastic"],
  [/\b[Uu]g[ -]?l[ -]?st\b/i, "UGl.st"],

  # --- Specific Communities & Groups ---
  [/\b[Cc]hicago[ -]?alt\.?\s*net\b/i, "Chicago Alt.NET"],
  [/\balt\.?\s*net\b/i, "Alt.NET"],
  [/\b[Cc]hicago[ -]?[Rr]uby\b/i, "ChicagoRuby"],
  [/\b[Ww]indy[ -]?[Cc]ity[ -]?[Rr]ails\b/i, "WindyCityRails"],
  [/\b[Cc]hipy\b/i, "ChiPy"],
  [/\b[Ss]cnn\b/i, "SCNA"],
  [/\b[Ss]cna\b/i, "SCNA"],
  [/\b[Rr]ails[ -]?[Bb]ridge\b/i, "RailsBridge"],
  
  # --- Languages & Ecosystems ---
  [/\b[Cc]losure[ -]?[Cc]onf\b/i, "ClojureConf"],
  [/\b[Ee]nclosure\b/i, "Clojure"],
  [/\b[Cc]losure\b/i, "Clojure"],
  [/\b[Cc]lojure\b/i, "Clojure"],
  [/\b[Rr]uby[ -]?[Oo]n[ -]?[Rr]ails\b/i, "Ruby on Rails"],
  [/\b[Rr]ubinius\b/i, "Rubinius"],
  [/\b[Jj][ -]?[Rr]uby\b/i, "JRuby"],
  [/\b[Nn]ode\.?js\b/i, "Node.js"],
  [/\b[Cc]ucumber\b/i, "Cucumber"],
  [/\b[Rr]spec\b/i, "RSpec"],
  [/\b[Pp]ost[ -]?[Ss]harp\b/i, "PostSharp"],
  [/\b[Ff]luent[ -]?[Dd]\b/i, "Fluentd"],

  # --- Methodologies & Industry Terms ---
  [/\b[Cc]raftmanship\b/i, "craftsmanship"],
  [/\b[Ss]oftware[ -]?[Cc]raftsmanship\b/i, "Software Craftsmanship"],
  [/\b[Bb]dd\b/i, "BDD"],
  [/\b[Tt]dd\b/i, "TDD"],
  [/\b[Aa]gile\b/i, "Agile"],
  [/\b[Kk]anban\b/i, "Kanban"],
  [/\b[Ss]crum\b/i, "Scrum"],
  [/\b[Dd]ev[ -]?[Oo]ps\b/i, "DevOps"],

  # --- Companies & Organizations ---
  [/\b[Gg]oto[ -]?[Cc]onf(?:erence)?\b/i, "GOTO Conference"],
  [/\b(?:eighth|8th)[ -]?light\b/i, "8th Light"],
  [/\b[Rr]ails[ -]?[Cc]onf\b/i, "RailsConf"],
  [/\b[Tt]hought[ -]?[Ww]orks\b/i, "ThoughtWorks"],
  [/\b[Oo]ps[ -]?[Cc]ode\b/i, "Opscode"],
  [/\b[Pp]ay[ -]?[Pp]al\b/i, "PayPal"],
  [/\b[Nn]etflix\b/i, "Netflix"],
  [/\b[Ee]tsy\b/i, "Etsy"],
  [/\b[Hh]eroku\b/i, "Heroku"],
  [/\b[Vv]ooza\b/i, "Vooza"],
  [/\b[Vv]imeo\b/i, "Vimeo"],
  [/\b[Yy]ou[ -]?[Tt]ube\b/i, "YouTube"],

  # --- Remove Whisper hallucinations ---
  [/\b[Tt]hanks for watching\b/i, ""],
  [/\b[Ss]ubscribe to my channel\b/i, ""],
  [/\b[Hh]it the bell icon\b/i, ""],
  [/\b[Pp]lease like and subscribe\b/i, ""],
  
  # --- Punctuation & Whitespace ---
  [/ {2,}/, " "],
  [/\n{3,}/, "\n\n"]
]

OUTRO_RULES = [
  [/\b(?:Bye\.?\s*){2,}/i, "Bye."],
  [/\b(?:Thank you\.?\s*){2,}/i, "Thank you."],
  [/^Thank you very much for taking the time to speak with me\.?$/i, "Thank you very much for taking the time to speak with me today. Find out for yourself today at UGtastic.com."]
]

def apply_to_text(text)
  return text unless text
  # 1. Clean the jingle
  text.gsub!(JINGLE_REGEX, "[Music] ")
  
  # 2. Apply general rules
  RULES.each { |pattern, replacement| text.gsub!(pattern, replacement) }
  
  # 3. Apply Name Repairs
  NAME_REPAIRS.each do |correct_name, patterns|
    patterns.each do |p|
      text.gsub!(p, correct_name)
    end
  end

  # 4. Clean up artifacts
  text.gsub!(/\[Music\]\s+(?:com\.)?\s*/i, "[Music] ")
  text.gsub!(/\s{2,}/, " ")
  text.strip!
  text
end

def apply_outro_rules(text)
  return text unless text
  OUTRO_RULES.each { |pattern, replacement| text.gsub!(pattern, replacement) }
  text
end

ARGV.each do |path|
  next unless File.exist?(path)
  begin
    if path.end_with?(".yml")
      data = YAML.load_file(path, permitted_classes: [Date, Time], aliases: true)
      
      if data["turns"]
        data["turns"].each { |turn| turn["text"] = apply_to_text(turn["text"]) }
        apply_outro_rules(data["turns"].last["text"]) if data["turns"].last
      elsif data["content"]
        data["content"] = apply_to_text(data["content"])
      end
      
      File.write(path, data.to_yaml)
    else
      # Handle raw text files (txt, srt, vtt)
      content = File.read(path)
      updated = apply_to_text(content)
      File.write(path, updated)
    end
  rescue => e
    puts "Error in #{path}: #{e.message}"
  end
end
