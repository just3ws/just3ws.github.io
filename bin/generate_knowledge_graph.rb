#!/usr/bin/env ruby
# frozen_string_literal: true

# bin/generate_knowledge_graph.rb — Taxonomical Entity & Knowledge Graph Generator
#
# Extracts entities (Interviewees, Conferences, User Groups, Open Source Projects, Topics)
# and builds node/edge/cluster relationships for the Knowledge Graph Network.

require 'yaml'
require 'json'
require 'fileutils'
require 'date'

class KnowledgeGraphGenerator
  TRANSCRIPTS_DIR = "_data/transcripts"
  INTERVIEWS_FILE = "_data/interviews.yml"
  ASSETS_FILE = "_data/video_assets.yml"
  CONCEPTS_FILE = "_data/concepts.yml"
  POSTS_DIR = "_posts"
  OUTPUT_DATA = "_data/knowledge_graph.json"
  ASSETS_OUTPUT_DATA = "assets/data/knowledge_graph.json"

  PROJECT_PATTERNS = {
    "Ruby on Rails" => [/ruby\s+on\s+rails|rails\b/i],
    "Clojure" => [/clojure\b/i],
    "Brakeman" => [/brakeman\b/i],
    "JRuby" => [/jruby\b/i],
    "Ember.js" => [/ember(?:\.js)?\b/i],
    "Fluentd" => [/fluentd\b/i],
    "ActiveJDBC" => [/activejdbc\b/i],
    "Rubinius" => [/rubinius\b/i],
    "Puma" => [/puma(?:\s+app\s+server)?\b/i],
    "Heroku" => [/heroku\b/i]
  }.freeze

  USER_GROUPS = {
    "ChiPy (Chicago Python)" => [/chipy\b|chicago\s+python/i],
    "ChicagoRuby" => [/chicagoruby\b|chicago\s+ruby/i],
    "Chicago ALT.NET" => [/chicago\s+alt\.net|alt\.net/i],
    "Denver SC" => [/denver\s+community|denver\s+sc/i],
    "Pittsburgh SC" => [/pittsburgh\s+sc/i],
    "Lake County .NET" => [/lake\s+county\s+\.net|lcnug/i],
    "London SC" => [/london\s+software\s+craftsmanship/i]
  }.freeze

  CONFERENCES = {
    "SCNA (Software Craftsmanship)" => [/software\s+craftsmanship\s+north\s+america|scna/i],
    "RailsConf" => [/railsconf/i],
    "GOTO Chicago" => [/goto\s+conference|goto\s+chicago/i],
    "ChicagoWebConf" => [/chicagowebconf/i],
    "WindyCityRails" => [/windycityrails/i]
  }.freeze

  TOPICS = {
    "Software Craftsmanship" => [/software\s+craftsmanship|clean\s+code/i],
    "TDD / BDD" => [/tdd|test\s+driven|bdd/i],
    "Continuous Delivery" => [/continuous\s+delivery|devops/i],
    "Microservices & Architecture" => [/microservices?|monolith/i],
    "Empathy in Engineering" => [/empathy|empathetic/i],
    "Developer & Product Flow" => [/developer\s+flow|product\s+flow/i]
  }.freeze

  def run
    puts "🕸️ Building Knowledge Network & Taxonomy Graph..."

    interviews_raw = YAML.load_file(INTERVIEWS_FILE, permitted_classes: [Date, Time], aliases: true)["items"] rescue []
    
    nodes = []
    links = []
    node_ids = Set.new

    def add_node(nodes, node_ids, id, label, type, group, url = nil, details = {})
      return if node_ids.include?(id)
      node_ids.add(id)
      nodes << {
        id: id,
        label: label,
        type: type,
        group: group,
        url: url || "/interviews/#{id}/",
        val: details[:val] || 10,
        description: details[:description] || ""
      }
    end

    def add_link(links, source, target, relationship, weight = 1)
      links << {
        source: source,
        target: target,
        relationship: relationship,
        weight: weight
      }
    end

    # 1. Register Taxonomy Nodes (Conferences, User Groups, Open Source Projects, Topics)
    CONFERENCES.each do |conf_name, _|
      add_node(nodes, node_ids, "conf-#{conf_name.downcase.tr('^a-z0-9', '-')}", conf_name, "Conference", 1, "/archive-status/", val: 25, description: "Historical tech conference event")
    end

    USER_GROUPS.each do |ug_name, _|
      add_node(nodes, node_ids, "ug-#{ug_name.downcase.tr('^a-z0-9', '-')}", ug_name, "User Group", 2, "/archive-status/", val: 20, description: "Regional developer community group")
    end

    PROJECT_PATTERNS.each do |proj_name, _|
      add_node(nodes, node_ids, "proj-#{proj_name.downcase.tr('^a-z0-9', '-')}", proj_name, "Open Source Project", 3, "/intelligence/", val: 22, description: "Featured open-source software project")
    end

    TOPICS.each do |topic_name, _|
      add_node(nodes, node_ids, "topic-#{topic_name.downcase.tr('^a-z0-9', '-')}", topic_name, "Technical Topic", 4, "/intelligence/", val: 18, description: "Core engineering discipline & methodology")
    end

    # 1b. Register the public context wiki as a graph layer. These nodes are
    # curated, article-backed vocabulary rather than model-inferred guesses.
    concepts = File.exist?(CONCEPTS_FILE) ? YAML.load_file(CONCEPTS_FILE, aliases: true) : []
    concepts.each do |concept|
      concept_id = concept["graph_id"] || "concept-#{concept['slug']}"
      add_node(nodes, node_ids, concept_id, concept["label"], "Concept", 7, concept["url"], val: 14, description: concept["definition"])
    end
    concepts.each do |concept|
      source = concept["graph_id"] || "concept-#{concept['slug']}"
      Array(concept["related"]).each do |related_slug|
        related = concepts.find { |candidate| candidate["slug"] == related_slug }
        next unless related

        target = related["graph_id"] || "concept-#{related_slug}"
        add_link(links, source, target, "related_concept", 2)
      end
    end

    # Article frontmatter can add explicit graph context without requiring a
    # second registry. This keeps relationship intent close to the prose while
    # still producing a deterministic graph artifact.
    Dir[File.join(POSTS_DIR, '*')].each do |path|
      raw = File.read(path)
      next unless raw.start_with?("---")

      frontmatter = raw.split(/^---\s*$/, 3)[1]
      metadata = YAML.safe_load(frontmatter, permitted_classes: [Date, Time], aliases: true) || {}
      wiki = metadata["context_wiki"]
      next unless wiki.is_a?(Hash)

      filename = File.basename(path).sub(/\.(md|html)\z/, '')
      article_id = "article-#{filename.downcase.tr('^a-z0-9', '-')}"
      article_url = metadata["permalink"] || "/#{filename.sub(/\A\d{4}-\d{2}-\d{2}-/, '')}/"
      add_node(nodes, node_ids, article_id, metadata["title"] || filename, "Archive Article", 8, article_url, val: 16, description: metadata["description"].to_s)

      Array(wiki["concepts"]).each do |slug|
        concept = concepts.find { |candidate| candidate["slug"] == slug.to_s }
        next unless concept

        add_link(links, article_id, concept["graph_id"] || "concept-#{concept['slug']}", "explains", 3)
      end
    rescue Psych::Exception => error
      warn "Skipping invalid frontmatter in #{path}: #{error.message}"
    end

    # 2. Process Interviews & Connect Nodes
    interviews_raw.each do |interview|
      id = interview["id"]
      title = interview["title"] || id
      interviewees = Array(interview["interviewees"])

      # Interviewee Node
      interviewees.each do |person|
        p_id = "person-#{person.downcase.tr('^a-z0-9', '-')}"
        add_node(nodes, node_ids, p_id, person, "Interviewee", 5, "/interviews/#{id}/", val: 15, description: "Featured speaker & practitioner")
        
        # Link Interviewee -> Interview/Transcript
        add_node(nodes, node_ids, id, title, "Interview", 6, "/interviews/#{id}/", val: 12, description: "UGtastic oral history recording")
        add_link(links, p_id, id, "featured_in", 2)
      end

      # Load transcript to detect mentions
      path = File.join(TRANSCRIPTS_DIR, "#{id}.yml")
      next unless File.exist?(path)

      t_data = YAML.load_file(path, permitted_classes: [Date, Time], aliases: true) rescue next
      turns = t_data["turns"] || []
      full_text = turns.map { |t| t["text"].to_s }.join(" ")

      # Check Conferences
      CONFERENCES.each do |conf_name, regexes|
        if regexes.any? { |r| full_text.match?(r) || id.match?(r) }
          conf_node_id = "conf-#{conf_name.downcase.tr('^a-z0-9', '-')}"
          add_link(links, id, conf_node_id, "recorded_at", 3)
        end
      end

      # Check User Groups
      USER_GROUPS.each do |ug_name, regexes|
        if regexes.any? { |r| full_text.match?(r) || id.match?(r) }
          ug_node_id = "ug-#{ug_name.downcase.tr('^a-z0-9', '-')}"
          add_link(links, id, ug_node_id, "discusses_community", 2)
        end
      end

      # Check OSS Projects
      PROJECT_PATTERNS.each do |proj_name, regexes|
        if regexes.any? { |r| full_text.match?(r) || id.match?(r) }
          proj_node_id = "proj-#{proj_name.downcase.tr('^a-z0-9', '-')}"
          add_link(links, id, proj_node_id, "discusses_project", 2)
        end
      end

      # Check Topics
      TOPICS.each do |topic_name, regexes|
        if regexes.any? { |r| full_text.match?(r) }
          topic_node_id = "topic-#{topic_name.downcase.tr('^a-z0-9', '-')}"
          add_link(links, id, topic_node_id, "covers_topic", 1)
        end
      end
    end

    graph_data = {
      generated_at: Time.now.iso8601,
      total_nodes: nodes.size,
      total_links: links.size,
      clusters: {
        "Conference" => { color: "#0284c7", group: 1 },
        "User Group" => { color: "#10b981", group: 2 },
        "Open Source Project" => { color: "#f59e0b", group: 3 },
        "Technical Topic" => { color: "#8b5cf6", group: 4 },
        "Interviewee" => { color: "#ec4899", group: 5 },
        "Interview" => { color: "#64748b", group: 6 },
        "Concept" => { color: "#0f766e", group: 7 },
        "Archive Article" => { color: "#b45309", group: 8 }
      },
      nodes: nodes,
      links: links
    }

    FileUtils.mkdir_p(File.dirname(ASSETS_OUTPUT_DATA))
    File.write(OUTPUT_DATA, JSON.pretty_generate(graph_data))
    File.write(ASSETS_OUTPUT_DATA, JSON.pretty_generate(graph_data))
    puts "✅ Knowledge Network Graph generated at #{OUTPUT_DATA} (#{nodes.size} nodes, #{links.size} edges)."
  end
end

KnowledgeGraphGenerator.new.run
