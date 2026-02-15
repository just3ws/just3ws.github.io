#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "optparse"
require "pathname"
require "yaml"
require_relative "../src/generators/core/yaml_io"

ROOT = Pathname(__dir__).join("..").expand_path
ASSETS_PATH = ROOT.join("_data", "video_assets.yml")
CONTEXT_PATH = ROOT.join("docs", "wayback", "ugtastic-interview-context.yml")

def normalize_text(value)
  value.to_s.downcase.gsub(/[^a-z0-9]+/, " ").strip.gsub(/\s+/, " ")
end

def title_key(value)
  text = value.to_s.dup
  text = text.sub(/\Ainterview with\s+/i, "")
  text = text.sub(/\s+@\s+.+\z/i, "")
  text = text.sub(/\s+\bat\b.+\z/i, "")
  normalize_text(text)
end

def generic_description?(value)
  text = value.to_s.strip
  return true if text.empty?
  return true if text.length < 90

  patterns = [
    /on developer community and conference conversations/i,
    /\Ainterview with .+ on conference speaking/i,
    /\Ainterview with .+ on web development/i,
    /\Ainterview with .+ on software craftsmanship/i,
    /themes include/i
  ]
  patterns.any? { |pattern| text.match?(pattern) }
end

def parse_date(value)
  return nil if value.to_s.strip.empty?

  Date.parse(value.to_s)
rescue StandardError
  nil
end

options = {
  apply: false
}

OptionParser.new do |opts|
  opts.banner = "Usage: bin/apply_ugtastic_context_to_video_assets.rb [--apply]"
  opts.on("--apply", "Write changes to _data/video_assets.yml") { options[:apply] = true }
end.parse!

assets_data = Generators::Core::YamlIo.load(ASSETS_PATH.to_s)
context_data = YAML.safe_load(CONTEXT_PATH.read, permitted_classes: [Date, Time], aliases: true) || {}
assets = assets_data["items"] || []
contexts = context_data["items"] || []

context_by_asset = Hash.new { |h, k| h[k] = [] }
contexts.each do |ctx|
  Array(ctx["matched_video_asset_ids"]).each do |asset_id|
    context_by_asset[asset_id] << ctx
  end
end

changes = []

assets.each do |asset|
  asset_id = asset["id"].to_s
  candidates = context_by_asset[asset_id]
  next if candidates.empty?

  current_title_key = title_key(asset["title"])
  current_date = parse_date(asset["published_date"])

  scored = candidates.map do |ctx|
    score = 0
    score += 4 if title_key(ctx["title"]) == current_title_key
    ctx_date = parse_date(ctx["published_at"])
    score += 2 if current_date && ctx_date && current_date == ctx_date
    score += 1 if normalize_text(ctx["summary"]).length >= 120
    [ctx, score]
  end.sort_by { |pair| [-pair[1], -(pair[0]["summary"].to_s.length)] }

  best, best_score = scored.first
  second_score = scored[1]&.[](1)
  next if best.nil?
  next if second_score && second_score == best_score && best_score < 5

  new_desc = best["summary"].to_s.gsub(/\s+/, " ").strip
  next if new_desc.empty?

  old_desc = asset["description"].to_s
  should_replace =
    generic_description?(old_desc) ||
    (new_desc.length > old_desc.length + 40 && old_desc.length < 180)

  next unless should_replace

  asset["description"] = new_desc
  changes << {
    "id" => asset_id,
    "title" => asset["title"],
    "old_description" => old_desc,
    "new_description" => new_desc,
    "context_title" => best["title"],
    "context_url" => best["source_url"]
  }
end

if options[:apply] && changes.any?
  Generators::Core::YamlIo.dump(ASSETS_PATH.to_s, assets_data)
end

puts "UGtastic context candidates: #{context_by_asset.keys.size}"
puts "Descriptions updated: #{changes.size}"
changes.first(40).each do |change|
  puts "- #{change['id']} <= #{change['context_title']} (#{change['context_url']})"
end

exit(0)
