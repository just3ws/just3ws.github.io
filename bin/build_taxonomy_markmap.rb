#!/usr/bin/env ruby
# frozen_string_literal: true

# ---
# name: build_taxonomy_markmap.rb
# domain: data
# purpose: Generate a self-contained offline Markmap HTML explorer from _data/taxonomy.yml
# usage: ruby bin/build_taxonomy_markmap.rb
# ---

require "fileutils"
require "open3"
require "tmpdir"
require "yaml"

ROOT = File.expand_path("..", __dir__)
TAXONOMY_PATH = File.join(ROOT, "_data", "taxonomy.yml")
OUT_HTML = File.join(ROOT, "assets", "diagrams", "taxonomy-markmap.html")

FileUtils.mkdir_p(File.dirname(OUT_HTML))

taxonomy = YAML.safe_load_file(TAXONOMY_PATH)
conferences = Array(taxonomy["canonical_conference_series"])
communities = Array(taxonomy["canonical_communities"])
topics = Array(taxonomy["canonical_topics"])

lines = []
lines << "# UGtastic & Chicago Craftsmanship Taxonomy"
lines << ""
lines << "## Conference Series (#{conferences.size})"
conferences.each { |c| lines << "- #{c}" }
lines << ""
lines << "## Communities & User Groups (#{communities.size})"
communities.each { |c| lines << "- #{c}" }
lines << ""
lines << "## Technical & Community Topics (#{topics.size})"

# Group topics into readable sub-branches so the mind map stays scannable
goto_topics = topics.select { |t| t.include?("GOTO") }
community_topics = topics.select { |t| t.match?(/community|meetup|user-group|Craftsmanship|SC|Alt\.NET|Chicago|ChiPy|Geekfest|Refresh|LCNUG|Denver|Pittsburgh|Cleveland|Houston|South Sound/i) && !goto_topics.include?(t) }
craft_topics = topics - goto_topics - community_topics

lines << "### Regional & User-Group Threads (#{community_topics.size})"
community_topics.each { |t| lines << "- #{t}" }
lines << "### GOTO Conference Sessions (#{goto_topics.size})"
goto_topics.each { |t| lines << "- #{t}" }
lines << "### Craft, Languages & Speaking (#{craft_topics.size})"
craft_topics.each { |t| lines << "- #{t}" }

Dir.mktmpdir("just3ws-markmap") do |tmp|
  md_path = File.join(tmp, "taxonomy.md")
  File.write(md_path, lines.join("\n") + "\n")

  puts "[markmap] _data/taxonomy.yml -> assets/diagrams/taxonomy-markmap.html"
  stdout, stderr, status = Open3.capture3(
    "npx", "--yes", "markmap-cli", "--no-open", "--offline", md_path, "-o", OUT_HTML
  )
  unless status.success?
    warn "markmap-cli failed:"
    warn stderr unless stderr.empty?
    warn stdout unless stdout.empty?
    exit status.exitstatus
  end
end

puts "Built self-contained Markmap explorer at assets/diagrams/taxonomy-markmap.html."
