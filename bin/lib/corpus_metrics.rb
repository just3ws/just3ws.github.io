#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "json"
require "time"
require "yaml"

module CorpusMetrics
  class Error < StandardError; end

  module_function

  def load_file(path)
    return markdown_record(path) if File.extname(path).downcase == ".md"

    content = File.read(path)
    case File.extname(path).downcase
    when ".json", ".jsonl"
      File.extname(path).downcase == ".jsonl" ? content.lines.map { |line| JSON.parse(line) } : JSON.parse(content)
    else
      YAML.safe_load(content, permitted_classes: [Date, Time], aliases: true) || {}
    end
  rescue StandardError => e
    raise Error, "#{path}: #{e.message}"
  end

  def markdown_record(path)
    source = File.read(path)
    frontmatter = {}
    body = source
    if source.match?(/\A---\s*\n/)
      match = source.match(/\A---\s*\n(.*?)\n---\s*\n?(.*)\z/m)
      if match
        frontmatter = YAML.safe_load(match[1], permitted_classes: [Date, Time], aliases: true) || {}
        body = match[2].to_s
      end
    end
    title = frontmatter["title"] || body[/^#\s+(.+)$/, 1] || File.basename(path, ".md").tr("-_", " ").capitalize
    frontmatter.merge("id" => (frontmatter["id"] || File.basename(path, ".md")), "title" => title, "content" => body)
  rescue StandardError => e
    raise Error, "#{path}: #{e.message}"
  end

  def records(data)
    return data if data.is_a?(Array)
    return [] unless data.is_a?(Hash)

    %w[items records documents entries episodes].each do |key|
      return Array(data[key]) if data[key].is_a?(Array)
    end
    [data]
  end

  def source_kind(path, configured_kind = nil)
    return configured_kind.to_s unless configured_kind.to_s.empty?

    base = File.basename(path).downcase
    return "transcripts" if base.include?("transcript")
    return "interviews" if base.include?("interview")
    return "video_assets" if base.include?("video") || base.include?("asset")

    "records"
  end

  def duration_seconds(record)
    return record.dig("recording", "duration_sec").to_f if record.dig("recording", "duration_sec")
    return record["duration_seconds"].to_f if record["duration_seconds"]
    return record["duration_minutes"].to_f * 60 if record["duration_minutes"]
    return record["duration_hours"].to_f * 3600 if record["duration_hours"]

    value = record["duration"]
    return 0 unless value.is_a?(String)

    parts = value.split(":").map(&:to_i)
    return parts[0] * 3600 + parts[1] * 60 + parts[2] if parts.size == 3
    return parts[0] * 60 + parts[1] if parts.size == 2

    0
  end

  def transcript_record?(record)
    record.is_a?(Hash) && (record.key?("content") || record.key?("turns") || record.key?("speaker_map"))
  end

  def transcript_metrics(records)
    maps = records.filter_map { |record| record["speaker_map"] if record.is_a?(Hash) }
    names = maps.flat_map do |speaker_map|
      speaker_map.values.map { |value| value.is_a?(Hash) ? value["name"] : value }
    end.map(&:to_s).reject(&:empty?).uniq
    turns = records.sum { |record| record["turns"].is_a?(Array) ? record["turns"].size : 0 }
    with_content = records.count do |record|
      record["content"].to_s.strip != "" || record["turns"].is_a?(Array) && !record["turns"].empty?
    end

    {"files" => records.size, "with_content" => with_content, "turns" => turns,
     "speaker_labels" => maps.sum(&:size), "unique_speaker_labels" => names.size}
  end

  def summarize(name, sources)
    by_kind = Hash.new { |hash, key| hash[key] = [] }
    sources.each { |source| by_kind[source[:kind]].concat(source[:records]) }
    all_records = by_kind.values.flatten
    tags = all_records.flat_map { |record| Array(record["tags"]) }.map(&:to_s).reject(&:empty?).tally
    years = all_records.filter_map do |record|
      value = record["published_date"] || record["recorded_date"] || record["recorded_at"] || record["date"]
      value.to_s[0, 4] if value
    end.tally
    durations = by_kind.values.flatten.sum { |record| duration_seconds(record) }
    transcript_records = by_kind.fetch("transcripts", []).select { |record| transcript_record?(record) }
    text_records = all_records.select { |record| record.is_a?(Hash) && record["content"].is_a?(String) }

    {
      "name" => name,
      "sources" => sources.map { |source| {"path" => source[:path], "kind" => source[:kind], "records" => source[:records].size} },
      "record_counts" => by_kind.transform_values(&:size),
      "total_records" => all_records.size,
      "duration_seconds" => durations.round(3),
      "duration_hours" => (durations / 3600.0).round(3),
      "duration_records" => all_records.count { |record| duration_seconds(record) > 0 },
      "transcripts" => transcript_metrics(transcript_records),
      "text" => {"records" => text_records.size,
                  "words" => text_records.sum { |record| record["content"].split.size },
                  "headings" => text_records.sum { |record| record["content"].scan(/^#+\s+/).size },
                  "links" => text_records.sum { |record| record["content"].scan(/\[[^\]]+\]\([^\)]+\)/).size }},
      "unique_tags" => tags.size,
      "top_tags" => tags.sort_by { |tag, count| [-count, tag] }.first(25).to_h,
      "years" => years.sort.to_h
    }
  end

  def configuration(path)
    data = load_file(path)
    corpora = data.is_a?(Hash) ? data["corpora"] : data
    raise Error, "#{path}: expected a corpora array" unless corpora.is_a?(Array)

    corpora
  end

  def expand_paths(paths)
    Array(paths).flat_map { |path| Dir[path.to_s].sort }.select { |path| File.file?(path) }
  end

  def build(config)
    corpus_reports = config.map do |corpus|
      name = corpus["name"].to_s.strip
      raise Error, "Every corpus needs a name" if name.empty?

      sources = []
      Array(corpus["manifests"]).each do |manifest|
        manifest = manifest.is_a?(Hash) ? manifest : {"path" => manifest}
        expand_paths(manifest["path"]).each do |path|
          sources << {path: path, kind: source_kind(path, manifest["kind"]), records: records(load_file(path))}
        end
      end
      expand_paths(corpus["transcripts"]).each do |path|
        records_for_path = records(load_file(path))
        sources << {path: path, kind: "transcripts", records: records_for_path}
      end
      summarize(name, sources)
    end

    combined = corpus_reports.each_with_object({"name" => "Combined corpus"}) do |report, result|
      result["record_counts"] ||= Hash.new(0)
      report["record_counts"].each { |kind, count| result["record_counts"][kind] += count }
      result["total_records"] = result.fetch("total_records", 0) + report["total_records"]
      result["duration_seconds"] = result.fetch("duration_seconds", 0) + report["duration_seconds"]
      result["transcripts"] ||= {"files" => 0, "with_content" => 0, "turns" => 0, "speaker_labels" => 0, "unique_speaker_labels" => 0}
      report["transcripts"].each { |key, value| result["transcripts"][key] += value }
    end
    combined["duration_hours"] = (combined["duration_seconds"] / 3600.0).round(3)

    {"schema_version" => 1, "generated_at" => Time.now.utc.iso8601,
     "corpora" => corpus_reports, "combined" => combined}
  end

  def markdown(report)
    lines = ["# Corpus Metrics", "", "Generated: #{report['generated_at']}", ""]
    report["corpora"].each do |corpus|
      lines += ["## #{corpus['name']}", "", "| Measure | Value |", "| --- | ---: |",
                "| Records | #{corpus['total_records']} |",
                "| Duration | #{corpus['duration_hours']} hours |",
                "| Sources with duration | #{corpus['duration_records']} |",
                "| Transcript files | #{corpus.dig('transcripts', 'files')} |",
                "| Transcript files with content | #{corpus.dig('transcripts', 'with_content')} |",
                "| Structured turns | #{corpus.dig('transcripts', 'turns')} |",
                "| Unique speaker labels | #{corpus.dig('transcripts', 'unique_speaker_labels')} |", ""]
    end
    lines += ["## Combined corpus", "", "```json", JSON.pretty_generate(report["combined"]), "```", ""]
    lines.join("\n")
  end
end
