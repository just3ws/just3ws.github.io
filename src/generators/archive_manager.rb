# frozen_string_literal: true

require 'yaml'
require 'date'
require 'set'
require 'pathname'

module Generators
  module ArchiveManager
    TEXT_NORMALIZATION_RULES = [
      [/\b(?:u|y|e)[a-z-]{0,10}tastic\.com\b/i, "ugtastic.com"],
      [/\b(?:u|y|e)[a-z-]{0,10}tastic\b/i, "UGtastic"],
      [/\bhugh[ -]+tastic\b/i, "UGtastic"],
      [/\bu[ -]?task\b/i, "UGtastic"],
      [/\bug[\s._-]*tastic\b/i, "UGtastic"],
      [/\b(?:you|yu)g[\s._-]*tastic\b/i, "UGtastic"],
      [/\bYouTask\b/i, "UGtastic"],
      [/\b(?:UBITASIC|UCTASIC|uTasic|Ute\s*TASC)\b/i, "UGtastic"],
      [/\bug[\s._-]*l[\s._-]*st\b/i, "UGl.st"],
      [/\bcraftmanship\b/i, "craftsmanship"],
      [/\bsoft[ -]?ware craftsmanship\b/i, "Software craftsmanship"],
      [/\bchipy\b/i, "ChiPy"],
      [/\bscna\b/i, "SCNA"],
      [/\bGoToConf(?:erence)?(\d{4})\b/i, "GOTO Conf \\1"],
      [/\bGoToConf(?:erence)?\b/i, "GOTO Conf"],
      [/\bGoToComp\b/i, "GOTO Conf"],
      [/\bGoToConferences\b/i, "GOTO Conferences"],
      [/\bGoToChicago\b/i, "GOTO Chicago"],
      [/\bGoToNight(s)?\b/i, "GOTO Night\\1"],
      [/\bGoTo\b/i, "GOTO"],
      [/\bCensure\b/i, "Sencha"],
      [/\bEFTJS\b/i, "Ext JS"],
      [/\bSandro\s+Ancuso\b/i, "Sandro Mancuso"],
      [/\bBrian\s+Merrick\b/i, "Brian Marick"],
      [/\bUGtastic\.com\b/, "ugtastic.com"]
    ].freeze

    module_function

    def normalize_transcript(text)
      cleaned = text.to_s.dup
      cleaned.gsub!(/\r\n?/, "\n")
      cleaned.gsub!(/[ \t]+$/, "")
      cleaned.gsub!(/\n{3,}/, "\n\n")
      cleaned.strip!

      TEXT_NORMALIZATION_RULES.each do |pattern, replacement|
        cleaned.gsub!(pattern, replacement)
      end

      cleaned
    end

    class TranscriptAuditor
      attr_reader :root, :assets_path, :transcripts_dir

      def initialize(root)
        @root = Pathname.new(root)
        @assets_path = @root.join("_data", "video_assets.yml")
        @transcripts_dir = @root.join("_data", "transcripts")
      end

      def run
        assets = load_yaml(assets_path, "items")
        transcript_files = Dir.glob(transcripts_dir.join("*.yml")).sort
        transcript_ids_from_files = transcript_files.map { |p| File.basename(p, ".yml") }.to_set

        assets_with_transcript_id = assets.select { |a| !a["transcript_id"].to_s.strip.empty? }
        used_transcript_ids = assets_with_transcript_id.map { |a| a["transcript_id"].to_s.strip }.to_set

        report = {
          assets_total: assets.size,
          assets_with_transcript_id: assets_with_transcript_id.size,
          unique_transcript_ids_used: used_transcript_ids.size,
          transcript_files_count: transcript_ids_from_files.size,
          missing_files: [],
          missing_content: [],
          invalid_files: [],
          orphan_files: (transcript_ids_from_files - used_transcript_ids).to_a.sort,
          duplicate_usage: assets_with_transcript_id
            .group_by { |a| a["transcript_id"].to_s.strip }
            .select { |id, rows| rows.size > 1 }
        }

        assets_with_transcript_id.each do |asset|
          id = asset["id"] || "<missing-id>"
          t_id = asset["transcript_id"].to_s.strip
          path = transcripts_dir.join("#{t_id}.yml")

          if !path.exist?
            report[:missing_files] << { asset_id: id, transcript_id: t_id, path: path.to_s }
          else
            begin
              transcript = YAML.safe_load(path.read, permitted_classes: [Date, Time], aliases: true)
              if !transcript.is_a?(Hash)
                report[:invalid_files] << { asset_id: id, transcript_id: t_id, path: path.to_s, error: "Not a Hash" }
              elsif transcript["content"].to_s.strip.empty?
                report[:missing_content] << { asset_id: id, transcript_id: t_id, path: path.to_s }
              end
            rescue => e
              report[:invalid_files] << { asset_id: id, transcript_id: t_id, path: path.to_s, error: e.message }
            end
          end
        end

        report
      end

      private

      def load_yaml(path, key)
        return [] unless File.exist?(path)
        data = YAML.safe_load(File.read(path), permitted_classes: [Date, Time], aliases: true) || {}
        data[key] || []
      end
    end
  end
end
