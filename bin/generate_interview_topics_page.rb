#!/usr/bin/env ruby

require "yaml"
require "date"
require "time"
require "fileutils"
require_relative "../src/generators/core/yaml_io"

ROOT = File.expand_path("..", __dir__)
INTERVIEWS_PATH = File.join(ROOT, "_data", "interviews.yml")
VIDEO_ASSETS_PATH = File.join(ROOT, "_data", "video_assets.yml")
OUT_DATA_PATH = File.join(ROOT, "_data", "interview_topics.yml")
OUT_PAGE_PATH = File.join(ROOT, "interviews", "topics", "index.html")

def normalize_topic(value)
  topic = value.to_s.gsub(/\s+/, " ").strip
  return "" if topic.empty?
  return "" if topic.match?(/\AGOPR\d+\z/i)
  return "" if topic.casecmp("general").zero?

  topic
end

def slugify(value)
  value.to_s.downcase
       .gsub(/[^a-z0-9]+/, "-")
       .gsub(/\A-+|-+\z/, "")
end

interviews = Generators::Core::YamlIo.load(INTERVIEWS_PATH, key: "items")
assets = Generators::Core::YamlIo.load(VIDEO_ASSETS_PATH, key: "items")
assets_by_id = assets.each_with_object({}) { |asset, acc| acc[asset["id"]] = asset }

topics = Hash.new { |hash, key| hash[key] = [] }
interviews.each do |interview|
  topic = normalize_topic(interview["topic"])
  next if topic.empty?

  topics[topic] << interview
end

topic_items = topics.map do |topic, rows|
  sorted_rows = rows.sort_by { |row| row["recorded_date"].to_s }.reverse
  transcript_count = sorted_rows.count do |row|
    asset = assets_by_id[row["video_asset_id"]]
    asset && !asset["transcript_id"].to_s.strip.empty?
  end

  {
    "slug" => slugify(topic),
    "topic" => topic,
    "count" => sorted_rows.size,
    "transcript_count" => transcript_count,
    "sample_interview_ids" => sorted_rows.first(8).map { |row| row["id"] }
  }
end

topic_items.sort_by! { |item| [-item["count"], item["topic"]] }

out_data = {
  "generated_at" => Time.now.utc.iso8601,
  "summary" => {
    "total_topics" => topic_items.size,
    "total_interviews_with_topics" => topic_items.sum { |item| item["count"] },
    "topics_with_transcripts" => topic_items.count { |item| item["transcript_count"].to_i > 0 }
  },
  "items" => topic_items
}
Generators::Core::YamlIo.dump(OUT_DATA_PATH, out_data)

FileUtils.mkdir_p(File.dirname(OUT_PAGE_PATH))
File.write(OUT_PAGE_PATH, <<~HTML)
  ---
  layout: minimal
  title: Interviews by Topic
  description: Topic-first interview index for finding conversations by practice, tradeoff, and technical context.
  breadcrumb: Interviews by Topic
  breadcrumb_parent_name: Interviews
  breadcrumb_parent_url: /interviews/
  ---

  <article class="page">
    {% include breadcrumbs.html %}
    {% assign topic_data = site.data.interview_topics %}
    {% assign topics = topic_data.items %}
    {% assign interview_items = site.data.interviews.items | where_exp: "i", "i.video_asset_id" %}
    {% include json-ld-itemlist.html
      collection_name="Interviews by Topic"
      collection_description=page.description
      items=interview_items
      item_id_key="id"
      item_name_key="title"
      url_prefix="/interviews/"
      item_schema_type="Interview"
      entity_id_prefix="/id/interview/"
    %}
    {% include json-ld-interview-entities.html
      items=interview_items
      url_prefix="/interviews/"
    %}
    <header>
      <h1>Interviews by Topic</h1>
      <p class="intro">This index groups interviews by topic so you can follow lines of practice instead of browsing a flat list.</p>
      {% if topic_data.summary %}
        <p>
          Topics: {{ topic_data.summary.total_topics }} |
          Interviews with topics: {{ topic_data.summary.total_interviews_with_topics }} |
          Topics with transcript coverage: {{ topic_data.summary.topics_with_transcripts }}
        </p>
      {% endif %}
    </header>

    {% if topics and topics.size > 0 %}
      {% for topic in topics %}
        <section class="index-summary" id="{{ topic.slug }}">
          <h2>{{ topic.topic }}</h2>
          <p>{{ topic.count }} interviews{% if topic.transcript_count > 0 %} | {{ topic.transcript_count }} with transcripts{% endif %}</p>
          {% for interview_id in topic.sample_interview_ids %}
            {% assign interview = site.data.interviews.items | where: "id", interview_id | first %}
            {% if interview %}
              {% include interview-card.html interview=interview %}
            {% endif %}
          {% endfor %}
        </section>
      {% endfor %}
    {% else %}
      <p>No topic groupings are available yet.</p>
    {% endif %}
  </article>
HTML

puts "Generated interview topics data and page (topics=#{topic_items.size})."
