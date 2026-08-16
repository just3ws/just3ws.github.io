#!/usr/bin/env ruby
# frozen_string_literal: true

# bin/generate_semantic_cross_links.rb — Cross-Interview Semantic Linking Engine
#
# Implements TASK-254:
# 1. Ingests all 207 YAML transcripts from _data/transcripts/
# 2. Computes TF-IDF & Cosine Similarity vector matrices across technical topics, terms, and quotes
# 3. Classifies relation kinds: 'person', 'topic', 'thread'
# 4. Writes cross_links data to _data/semantic_cross_links.json & site datasets

require 'yaml'
require 'json'
require 'fileutils'
require 'matrix'

class SemanticCrossLinker
  TRANSCRIPTS_DIR = "_data/transcripts"
  INTERVIEWS_FILE = "_data/interviews.yml"
  OUTPUT_FILE     = "_data/semantic_cross_links.json"

  STOPWORDS = %w[
    a an the and or in on at to for with by about as of is was were be been being
    that this these those it its they them their we us our you your I me my have has had
    do does did will would shall should can could may might must just also like get got
  ].to_set.freeze

  def run
    puts "🧠 [Semantic Linker] Ingesting 207 transcripts for vector cross-linking..."

    interviews = YAML.load_file(INTERVIEWS_FILE, permitted_classes: [Date, Time], aliases: true)["items"] rescue []
    interview_map = interviews.map { |i| [i["id"], i] }.to_h

    documents = []
    vocab = Hash.new { |h, k| h[k] = h.size }

    Dir.glob(File.join(TRANSCRIPTS_DIR, "*.yml")).sort.each do |path|
      t_id = File.basename(path, ".yml")
      iv = interview_map[t_id]
      next unless iv # Skip if not a valid interview page route

      data = YAML.load_file(path, permitted_classes: [Date, Time], aliases: true) rescue next

      title = iv["title"] || t_id
      topics = (iv["topics"] || []) + (data["topics"] || [])
      turns = data["turns"] || []

      # Combine text for indexing
      full_text = turns.map { |t| t["text"].to_s }.join(" ")
      tokens = tokenize("#{title} #{topics.join(' ')} #{full_text}")

      # Count term frequencies
      tf = Hash.new(0)
      tokens.each { |tok| tf[vocab[tok]] += 1 }

      documents << {
        id: t_id,
        title: title,
        speaker: iv["speaker"] || data.dig("speaker_map", "S1") || "Guest",
        topics: topics.map(&:downcase).uniq,
        tf: tf,
        length: tokens.size
      }
    end

    puts "📊 [Semantic Linker] Vocabulary size: #{vocab.size} unique terms across #{documents.size} documents."

    # Compute Inverse Document Frequency (IDF)
    num_docs = documents.size.to_f
    idf = Hash.new(0.0)
    vocab.each_value do |term_idx|
      doc_freq = documents.count { |d| d[:tf].key?(term_idx) }
      idf[term_idx] = Math.log((num_docs + 1.0) / (doc_freq + 1.0)) + 1.0
    end

    # Build normalized TF-IDF vectors
    vectors = documents.map do |doc|
      vec = {}
      doc[:tf].each do |term_idx, count|
        vec[term_idx] = (count.to_f / doc[:length]) * idf[term_idx]
      end
      
      # L2 normalize
      norm = Math.sqrt(vec.values.map { |v| v**2 }.sum)
      norm = 1.0 if norm == 0
      vec.transform_values { |v| v / norm }
    end

    # Compute pairwise Cosine Similarity & classify relationship kinds
    cross_links = {}

    documents.each_with_index do |doc_a, idx_a|
      vec_a = vectors[idx_a]
      related = []

      documents.each_with_index do |doc_b, idx_b|
        next if idx_a == idx_b

        vec_b = vectors[idx_b]
        score = cosine_similarity(vec_a, vec_b)

        # Classify relationship kind
        shared_topics = (doc_a[:topics] & doc_b[:topics])
        same_speaker = doc_a[:speaker] == doc_b[:speaker] && doc_a[:speaker] != "Mike Hall"

        kind = if same_speaker
                 "person"
               elsif shared_topics.size >= 2
                 "topic"
               else
                 "thread"
               end

        if score > 0.15 || shared_topics.any? || same_speaker
          related << {
            id: doc_b[:id],
            title: doc_b[:title],
            speaker: doc_b[:speaker],
            score: score.round(4),
            kind: kind,
            shared_topics: shared_topics.take(4)
          }
        end
      end

      # Top 5 most relevant links
      top_related = related.sort_by { |r| -r[:score] }.take(6)
      cross_links[doc_a[:id]] = {
        title: doc_a[:title],
        speaker: doc_a[:speaker],
        related: top_related
      }
    end

    payload = {
      generated_at: Time.now.utc.iso8601,
      total_interviews_indexed: documents.size,
      vocabulary_size: vocab.size,
      cross_links: cross_links
    }

    FileUtils.mkdir_p(File.dirname(OUTPUT_FILE))
    File.write(OUTPUT_FILE, JSON.pretty_generate(payload))

    puts "✅ [Semantic Linker] Complete! Generated cross-interview semantic map for #{documents.size} interviews."
  end

  private

  def tokenize(text)
    text.downcase
        .gsub(/[^a-z0-9\s\-]/, ' ')
        .split
        .reject { |w| w.size < 3 || STOPWORDS.include?(w) }
  end

  def cosine_similarity(vec_a, vec_b)
    common_keys = vec_a.keys & vec_b.keys
    return 0.0 if common_keys.empty?

    common_keys.map { |k| vec_a[k] * vec_b[k] }.sum
  end
end

SemanticCrossLinker.new.run if __FILE__ == $PROGRAM_NAME
