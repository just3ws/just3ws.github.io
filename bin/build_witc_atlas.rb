#!/usr/bin/env ruby
# frozen_string_literal: true

# Build an interactive-friendly, evidence-linked atlas from the local WITC corpus.

require "json"
require "sqlite3"

root = File.expand_path("..", __dir__)
db_path = ENV.fetch("WITC_CORPUS_DB", File.join(root, "lake", "witc", "corpus.db"))
output = ARGV[0] || File.join(root, "docs", "witc-archive-atlas.json")
abort "Corpus not found: #{db_path}" unless File.file?(db_path)

db = SQLite3::Database.new(db_path)
db.results_as_hash = true

def evidence(db, pattern)
  db.execute("SELECT source_path, source_kind, created_at, time_kind, sha256 FROM documents WHERE source_path LIKE ? ORDER BY created_at", [pattern]).first(50).map do |row|
    { "source_path" => "configured archive root / #{row["source_kind"]}", "source_kind" => row["source_kind"], "source_ref" => "record-#{row["sha256"][0, 12]}", "timestamp" => Time.at(row["created_at"]).utc.iso8601, "timestamp_kind" => row["time_kind"] }
  end
end

series = [
  { "id" => "ugl-st", "label" => "UGl.st intent to launch", "start" => "2012", "end" => "2014", "precision" => "intent-2012, public-capture-2014", "description" => "The User-Group List began as a 2012 idea for helping organizers discover one another. Recovered source exists in 2013, and a January 2014 Wayback capture provides the clearest public evidence of the operating site.", "evidence" => evidence(db, "%UGlst%") },
  { "id" => "windycityrails", "label" => "WindyCityRails", "start" => "2012", "end" => "2013", "precision" => "year", "description" => "Early Chicago Ruby and Rails community coverage.", "evidence" => evidence(db, "%WindyCityRails%") },
  { "id" => "scna", "label" => "SCNA", "start" => "2012", "end" => "2013", "precision" => "year", "description" => "Software Craftsmanship North America interviews and field coverage.", "evidence" => evidence(db, "%SCNA%") },
  { "id" => "goto-chicago", "label" => "GOTO Chicago", "start" => "2013", "end" => "2015", "precision" => "year", "description" => "Conference conversations spanning three event years.", "evidence" => evidence(db, "%GOTO%") },
  { "id" => "chicago-web-conf", "label" => "ChicagoWebConf", "start" => "2012", "end" => "2013", "precision" => "year", "description" => "Chicago web community interviews.", "evidence" => evidence(db, "%ChicagoWebConf%") },
  { "id" => "railsconf", "label" => "RailsConf", "start" => "2014", "end" => "2014", "precision" => "year", "description" => "The large 2014 RailsConf interview series.", "evidence" => evidence(db, "%RailsConf%") },
  { "id" => "ugtastic-production", "label" => "UGtastic production", "start" => "2011", "end" => "2015", "precision" => "year", "description" => "The recording and interview practice launched at SCNA 2011, then expanded across conferences and community series.", "evidence" => evidence(db, "%UGtastic%") },
  { "id" => "caption-consolidation", "label" => "Caption and archive consolidation", "start" => "2016", "end" => "2018", "precision" => "year", "description" => "Downloaded media, captions, converted transcripts, and archive organization.", "evidence" => evidence(db, "%consolidated%") },
  { "id" => "local-curation", "label" => "Local curation and corpus work", "start" => "2019", "end" => "2026", "precision" => "year", "description" => "Later indexing, analysis, and preservation tooling. This does not imply new recordings.", "evidence" => evidence(db, "%_output%") }
]

atlas = {
  "schema_version" => "1.0",
  "title" => "WITC and UGtastic Archive Atlas",
  "generated_from" => "local WITC corpus index",
  "corpus" => { "name" => "witc", "documents" => db.get_first_value("SELECT COUNT(*) FROM documents"), "threads" => db.get_first_value("SELECT COUNT(*) FROM threads"), "source_root" => "configured-at-build-time" },
  "time_semantics" => { "precision" => "year unless a source provides a stronger date", "rule" => "A file, upload, conversion, or curation date is not silently promoted to an event date.", "layers" => ["recording", "publication", "captioning", "consolidation", "curation"] },
  "overlays" => ["production", "conference-series", "transcript-and-caption", "preservation", "local-curation"],
  "eras" => [
    { "id" => "formation", "label" => "SCNA 2011 launch and formation", "start" => "2011", "end" => "2012", "context" => "The first UGtastic conversations at SCNA 2011 establish the recording practice; UGl.st follows as its discovery and coordination substrate." },
    { "id" => "expansion", "label" => "Expansion", "start" => "2013", "end" => "2013", "context" => "More events, communities, and repeatable production habits." },
    { "id" => "peak-production", "label" => "Peak production", "start" => "2014", "end" => "2015", "context" => "RailsConf, GOTO Chicago, and a broad network of technical community voices." },
    { "id" => "preservation", "label" => "Preservation", "start" => "2016", "end" => "2018", "context" => "The active project becomes an archive that can be consolidated and searched." },
    { "id" => "curation", "label" => "Curation", "start" => "2019", "end" => "2026", "context" => "Later tools recover context and connect the archive to the wider body of work." }
  ],
  "series" => series,
  "site_links" => [
    { "label" => "Video archive", "href" => "/videos/", "relation" => "site-index" },
    { "label" => "Interview archive", "href" => "/interviews/", "relation" => "site-index" },
    { "label" => "Temporal Atlas method", "href" => "/archive-atlas/", "relation" => "context" }
  ],
  "external_discovery_links" => [
    { "label" => "Wayback Machine: UGtastic domain discovery", "href" => "https://web.archive.org/web/*/http://ugtastic.com/*", "status" => "discovery-link", "note" => "Use to locate captures; a capture must be individually verified before citing it as evidence." },
    { "label" => "Internet Archive advanced search", "href" => "https://archive.org/advancedsearch.php?q=ugtastic&fl[]=identifier,title,date&rows=50&page=1&output=json", "status" => "discovery-link", "note" => "Search endpoint, not proof that a matching item exists." }
  ],
  "citation_model" => ["local_path_and_sha256", "source_timestamp_and_precision", "site_route", "conference_or_series", "external_url_and_verification_status"]
}

File.write(output, JSON.pretty_generate(atlas) + "\n")
puts "Wrote #{output}"
