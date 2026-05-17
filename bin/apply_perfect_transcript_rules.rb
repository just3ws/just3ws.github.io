#!/usr/bin/env ruby
require 'yaml'

RULES = [
  # --- Brand: UGtastic ---
  [/\b(?:you|yu|u|ub|uk|uke|uge|evo|e|ute|uget)[ -]?g?[ -]?tastic(?:\.com)?\b/i, "UGtastic"],
  [/\b[Uu]ktasek(?:\.com)?\b/i, "UGtastic"],
  [/\b[Uu]btastic(?:\.com)?\b/i, "UGtastic"],
  [/\b[Uu]g[ -]?l[ -]?st\b/i, "UGl.st"],
  
  # --- Industry Terms ---
  [/\b[Gg]oto[ -]?[Cc]onf(?:erence)?\b/i, "GOTO Conference"],
  [/\b[Rr]ails[ -]?[Cc]onf\b/i, "RailsConf"],
  [/\b[Ww]indy[ -]?[Cc]ity[ -]?[Rr]ails\b/i, "WindyCityRails"],
  [/\b[Cc]hicago[ -]?[Rr]uby\b/i, "ChicagoRuby"],
  [/\b[Cc]hipy\b/i, "ChiPy"],
  [/\b[Ss]cna\b/i, "SCNA"],
  [/\b[Rr]ails[ -]?[Bb]ridge\b/i, "RailsBridge"],
  [/\b[Cc]raftmanship\b/i, "craftsmanship"],
  [/\b[Ss]oftware[ -]?[Cc]raftsmanship\b/i, "Software Craftsmanship"],
  [/\b[Tt]hought[ -]?[Ww]orks\b/i, "ThoughtWorks"],
  [/\b[Oo]ps[ -]?[Cc]ode\b/i, "Opscode"],
  [/\b[Bb]dd\b/i, "BDD"],
  [/\b[Tt]dd\b/i, "TDD"],
  [/\b[Aa]gile\b/i, "Agile"],
  [/\b[Kk]anban\b/i, "Kanban"],
  [/\b[Ss]crum\b/i, "Scrum"],
  [/\b[Yy]ou[ -]?[Tt]ube\b/i, "YouTube"],
  [/\b[Vv]imeo\b/i, "Vimeo"],
  [/\b[Pp]ay[ -]?[Pp]al\b/i, "PayPal"],
  [/\b[Nn]etflix\b/i, "Netflix"],
  [/\b[Ee]tsy\b/i, "Etsy"],
  [/\b[Hh]eroku\b/i, "Heroku"],
  [/\b[Rr]uby[ -]?[Oo]n[ -]?[Rr]ails\b/i, "Ruby on Rails"],
  [/\b[Rr]ubinius\b/i, "Rubinius"],
  [/\b[Cc]ucumber\b/i, "Cucumber"],
  [/\b[Jj]behave\b/i, "JBehave"],
  [/\b[Rr]spec\b/i, "RSpec"],
  [/\b[Vv]ooza\b/i, "Vooza"],
  
  # --- Remove Whisper hallucinations ---
  [/\b[Tt]hanks for watching\b/i, ""],
  [/\b[Ss]ubscribe to my channel\b/i, ""],
  [/\b[Hh]it the bell icon\b/i, ""],
  [/\b[Pp]lease like and subscribe\b/i, ""],
  
  # --- Punctuation & Whitespace ---
  [/ {2,}/, " "],
  [/\n{3,}/, "\n\n"]
]

def apply_to_text(text)
  return text unless text
  RULES.each { |pattern, replacement| text.gsub!(pattern, replacement) }
  text
end

ARGV.each do |path|
  next unless File.exist?(path)
  begin
    data = YAML.safe_load(File.read(path), permitted_classes: [Date, Time], aliases: true)
    if data["turns"]
      data["turns"].each { |turn| apply_to_text(turn["text"]) }
    elsif data["content"]
      apply_to_text(data["content"])
    end
    File.write(path, data.to_yaml)
    puts "Applied perfection rules to #{path}"
  rescue => e
    puts "Error in #{path}: #{e.message}"
  end
end
