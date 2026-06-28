# frozen_string_literal: true

require_relative "core/yaml_io"

module Generators
  module ArchiveState
    LOAD_STATUS_LOADED = "loaded"
    LOAD_STATUS_MISSING = "missing"
    LOAD_STATUS_INVALID = "invalid"

    FORMAT_STRUCTURED = "structured"
    FORMAT_CONTENT = "content"
    FORMAT_MISSING = "missing"
    FORMAT_INVALID = "invalid"

    module_function

    def for_path(path, id: nil)
      path_value = path.to_s
      id_value = present_string(id) || File.basename(path_value, ".yml")

      return missing_state(id: id_value, path: path_value) unless File.file?(path_value)

      data = Generators::Core::YamlIo.load(path_value)
      return invalid_state(id: id_value, path: path_value, error: "Not a Hash") unless data.is_a?(Hash)

      TranscriptState.new(id: id_value, path: path_value, data: data, load_status: LOAD_STATUS_LOADED)
    rescue StandardError => e
      invalid_state(id: id_value, path: path_value, error: e.message)
    end

    def for_id(transcript_id, root: Dir.pwd, transcripts_dir: nil)
      id_value = present_string(transcript_id)
      return missing_state(id: id_value, path: nil) unless id_value

      dir = transcripts_dir || File.join(root, "_data", "transcripts")
      for_path(File.join(dir, "#{id_value}.yml"), id: id_value)
    end

    def from_data(data, id: nil, path: nil)
      return missing_state(id: present_string(id), path: path) if data.nil?
      return invalid_state(id: present_string(id), path: path, error: "Not a Hash") unless data.is_a?(Hash)

      TranscriptState.new(id: present_string(id), path: path, data: data, load_status: LOAD_STATUS_LOADED)
    end

    def missing_state(id:, path:)
      TranscriptState.new(id: id, path: path, data: {}, load_status: LOAD_STATUS_MISSING)
    end

    def invalid_state(id:, path:, error:)
      TranscriptState.new(id: id, path: path, data: {}, load_status: LOAD_STATUS_INVALID, load_error: error)
    end

    def present_string(value)
      string = value.to_s.strip
      string.empty? ? nil : string
    end

    class TranscriptState
      attr_reader :id, :path, :data, :load_status, :load_error

      def initialize(id:, path:, data:, load_status:, load_error: nil)
        @id = id
        @path = path
        @data = data
        @load_status = load_status
        @load_error = load_error
      end

      def loaded?
        load_status == LOAD_STATUS_LOADED
      end

      def parseable?
        loaded?
      end

      def missing?
        load_status == LOAD_STATUS_MISSING
      end

      def invalid?
        load_status == LOAD_STATUS_INVALID
      end

      def has_transcript?
        return false unless loaded?

        !content_text.empty? || !turn_texts.empty?
      end

      def transcript_format
        return FORMAT_INVALID if invalid?
        return FORMAT_STRUCTURED unless turn_texts.empty?
        return FORMAT_CONTENT unless content_text.empty?

        FORMAT_MISSING
      end

      def text
        return "" unless has_transcript?
        return turn_texts.join("\n\n") if transcript_format == FORMAT_STRUCTURED

        content_text
      end

      def word_count
        normalized = text.gsub(/\s+/, " ").strip
        return 0 if normalized.empty?

        normalized.split(/\s+/).size
      end

      def validated?
        present?(data["validated_at"])
      end

      def validation_error
        value = data["validation_error"]
        present?(value) ? value.to_s.strip : nil
      end

      def enriched?
        present?(data["enriched_at"])
      end

      def indexed?
        present?(data["indexed_at"])
      end

      def turn_count
        turn_texts.size
      end

      def speakers
        return [] unless data["turns"].is_a?(Array)

        data["turns"].each_with_object([]) do |turn, list|
          next unless turn.is_a?(Hash)

          speaker = turn["speaker"].to_s.strip
          list << speaker if !speaker.empty? && !list.include?(speaker)
        end
      end

      def to_h(include_text: true)
        {
          "id" => id,
          "path" => path,
          "load_status" => load_status,
          "parseable" => parseable?,
          "load_error" => load_error,
          "has_transcript" => has_transcript?,
          "transcript_format" => transcript_format,
          "word_count" => word_count,
          "turn_count" => turn_count,
          "speakers" => speakers,
          "validated" => validated?,
          "validation_error" => validation_error,
          "enriched" => enriched?,
          "indexed" => indexed?
        }.tap do |summary|
          summary["text"] = text if include_text
        end
      end

      private

      def content_text
        normalize_text(data["content"])
      end

      def turn_texts
        return [] unless data["turns"].is_a?(Array)

        data["turns"].each_with_object([]) do |turn, texts|
          next unless turn.is_a?(Hash)

          text = normalize_text(turn["text"])
          texts << text unless text.empty?
        end
      end

      def normalize_text(value)
        value.to_s.gsub(/\r\n?/, "\n").gsub(/[ \t]+$/, "").strip
      end

      def present?(value)
        !value.to_s.strip.empty?
      end
    end
  end
end
