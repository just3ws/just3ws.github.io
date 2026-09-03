#!/usr/bin/env ruby
# frozen_string_literal: true

# Turn the WITC corpus metadata into a compact, temporal, human-readable map.

require "fileutils"
require "sqlite3"
require "time"

root = File.expand_path("..", __dir__)
db_path = ENV.fetch("WITC_CORPUS_DB", File.join(root, "lake", "witc", "corpus.db"))
output = ARGV[0] || File.join(root, "docs", "witc-temporal-timeline.md")
abort "Corpus not found: #{db_path}" unless File.file?(db_path)

db = SQLite3::Database.new(db_path)
db.results_as_hash = true
years = db.execute("SELECT strftime('%Y', created_at, 'unixepoch') AS year, source_kind, COUNT(*) AS count FROM documents GROUP BY year, source_kind ORDER BY year, source_kind")
prefixes = db.execute("SELECT substr(source_path, 1, instr(source_path || '/', '/') - 1) AS prefix, COUNT(*) AS count FROM documents GROUP BY prefix ORDER BY count DESC")
first = db.get_first_value("SELECT MIN(created_at) FROM documents")
last = db.get_first_value("SELECT MAX(created_at) FROM documents")

eras = [
  ["UGl.st substrate and first field record", 2012, 2012, "User-group discovery infrastructure, early recordings, and the first durable interview artifacts."],
  ["Expansion through community events", 2013, 2013, "SCNA, GOTO Chicago, ChicagoWebConf, WindyCityRails, and the growing organizer network."],
  ["Peak production and breadth", 2014, 2015, "RailsConf, GOTO Chicago, user groups, conference organizers, and a large transcript surface."],
  ["Consolidation and migration of the record", 2016, 2018, "Archive work, downloads, caption collection, branding, and the transition from active production to preservation."],
  ["Later local curation", 2019, 2026, "Subsequent local processing artifacts. These dates describe archive activity, not new UGtastic recordings."],
]

lines = []
lines << "---"
lines << "title: WITC and UGtastic Temporal Timeline"
lines << "description: A provenance-aware timeline generated from the local WITC corpus."
lines << "type: archive-timeline"
lines << "source: configured archive root"
lines << "generated_from: local WITC corpus index"
lines << "---"
lines << ""
lines << "# WITC and UGtastic: a temporal map"
lines << ""
lines << "This is a generated map of the local WHOIS Tech Community archive. It separates the era of recording from later work that preserved, converted, cataloged, or searched the record. A file timestamp is evidence about the file. It is not automatically evidence about when an interview happened."
lines << ""
lines << "## Corpus boundary"
lines << ""
lines << "The current corpus contains **#{db.get_first_value('SELECT COUNT(*) FROM documents')} searchable documents** across **#{db.get_first_value('SELECT COUNT(*) FROM threads')} archive/project threads**. The searchable representation spans **#{Time.at(first).utc.year} to #{Time.at(last).utc.year}** by the selected primary timestamps. It retains physical duplicates as separate records and links each record to a relative source path, SHA-256, source kind, and timestamp kind."
lines << ""
lines << "## Epochs"
lines << ""
eras.each do |title, from, to, description|
  counts = years.select { |r| (from..to).cover?(r["year"].to_i) }.sum { |r| r["count"].to_i }
  lines << "### #{title} (#{from}#{from == to ? '' : " to #{to}"})"
  lines << ""
  lines << "#{description} The corpus currently associates **#{counts} searchable records** with this interval."
  lines << ""
end
lines << "## Records by selected year and kind"
lines << ""
lines << "| Year | Documentation | Metadata | Source | Transcript | Total |"
lines << "| --- | ---: | ---: | ---: | ---: | ---: |"
years.group_by { |r| r["year"] }.each do |year, rows|
  counts = rows.to_h { |r| [r["source_kind"], r["count"].to_i] }
  lines << "| #{year} | #{counts.fetch('documentation', 0)} | #{counts.fetch('metadata', 0)} | #{counts.fetch('source', 0)} | #{counts.fetch('transcript', 0)} | #{counts.values.sum} |"
end
lines << ""
lines << "## Archive layers represented"
lines << ""
prefixes.first(12).each { |row| lines << "- `#{row['prefix']}`: #{row['count']} searchable records" }
lines << ""
lines << "## Reading the map"
lines << ""
lines << "The important historical movement is not simply a count of videos. It is the growth of a communication system: recording, interviewing, publishing, captioning, consolidating, and later making the material searchable. That sequence is why the archive is useful as an engineering history. Each layer carries a different kind of evidence, and the temporal model keeps those layers from being flattened into one false date."
lines << ""
lines << "The corpus is local and AI-assisted tooling may be used to retrieve or summarize it. The source files remain the evidence. Generated excerpts are not replacements for the recording, transcript, or metadata from which they were derived."
lines << ""
FileUtils.mkdir_p(File.dirname(output))
File.write(output, lines.join("\n") + "\n")
puts "Wrote #{output}"
