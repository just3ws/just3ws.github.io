#!/usr/bin/env ruby

require "time"
require "fileutils"
require_relative "../src/generators/core/yaml_io"

ROOT = File.expand_path("..", __dir__)
INTERVIEWS_PATH = File.join(ROOT, "_data", "interviews.yml")
OUT_DATA_PATH = File.join(ROOT, "_data", "community_stories.yml")
OUT_PAGE_PATH = File.join(ROOT, "interviews", "stories", "index.html")

interviews = Generators::Core::YamlIo.load(INTERVIEWS_PATH, key: "items")
sorted = interviews.sort_by { |item| item["recorded_date"].to_s }

craftsmanship = sorted.select do |item|
  item["conference"].to_s.downcase.include?("software craftsmanship")
end

user_group_communities = [
  "Chicago Software Craftsmanship",
  "ChiPy",
  "Lake County .NET User Group (LCNUG)",
  "Gathers.us and ChicagoDB",
  "ChicagoRuby",
  "angleBracket",
  "Geekfest"
]
user_groups = sorted.select do |item|
  community = item["community"].to_s
  user_group_communities.include?(community)
end

conference_ecosystem = sorted.select do |item|
  conference = item["conference"].to_s
  conference.include?("GOTO") || conference.include?("RailsConf") || conference.include?("WindyCityRails") || conference.include?("ChicagoWebConf")
end

tracks = [
  {
    "id" => "craftsmanship-lineage",
    "title" => "Craftsmanship Lineage",
    "summary" => "A sequence of interviews from Software Craftsmanship North America that traces how practitioners discussed deliberate practice, mentorship, and professional standards over time.",
    "why_it_matters" => "These interviews document the working language of software craftsmanship as it moved from hallway conversations into durable community practice.",
    "interview_ids" => craftsmanship.first(10).map { |item| item["id"] }
  },
  {
    "id" => "user-groups-as-learning-systems",
    "title" => "User Groups as Learning Systems",
    "summary" => "Conversations rooted in user-group ecosystems where engineers shared methods, tested ideas, and built local continuity.",
    "why_it_matters" => "User groups are where durable habits form. This track shows how local working groups turned participation into long-term growth.",
    "interview_ids" => user_groups.first(10).map { |item| item["id"] }
  },
  {
    "id" => "conference-ecosystem-shifts",
    "title" => "Conference Ecosystem Shifts",
    "summary" => "Interviews across conference contexts that show how topics, constraints, and priorities shifted as communities matured.",
    "why_it_matters" => "Conference interviews capture each period's practical concerns. In sequence, they show where the industry changed and where it stayed consistent.",
    "interview_ids" => conference_ecosystem.first(10).map { |item| item["id"] }
  }
]

if tracks[0]["interview_ids"].empty?
  fallback = sorted.select { |item| item["conference"].to_s.downcase.include?("scna") }
  tracks[0]["interview_ids"] = fallback.first(10).map { |item| item["id"] }
end

data = {
  "generated_at" => Time.now.utc.iso8601,
  "tracks" => tracks
}
Generators::Core::YamlIo.dump(OUT_DATA_PATH, data)

FileUtils.mkdir_p(File.dirname(OUT_PAGE_PATH))
File.write(OUT_PAGE_PATH, <<~HTML)
  ---
  layout: minimal
  title: Community Stories
  description: Curated interview tracks that document long-arc patterns in software craftsmanship, user-group practice, and conference ecosystems.
  breadcrumb: Community Stories
  breadcrumb_parent_name: Interviews
  breadcrumb_parent_url: /interviews/
  ---

  <article class="page">
    {% include breadcrumbs.html %}
    {% assign stories = site.data.community_stories.tracks %}
    {% assign interview_items = site.data.interviews.items | where_exp: "i", "i.video_asset_id" %}
    {% include json-ld-itemlist.html
      collection_name="Community Stories"
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
      <h1>Community Stories</h1>
      <p class="intro">These tracks are curated sequences from the archive. Each one follows a specific line of practice instead of presenting interviews as an undifferentiated list.</p>
    </header>

    {% for track in stories %}
      <section class="index-summary" id="{{ track.id }}">
        <h2>{{ track.title }}</h2>
        <p>{{ track.summary }}</p>
        <p><strong>Why this track:</strong> {{ track.why_it_matters }}</p>
        {% for interview_id in track.interview_ids %}
          {% assign interview = site.data.interviews.items | where: "id", interview_id | first %}
          {% if interview %}
            {% include interview-card.html interview=interview %}
          {% endif %}
        {% endfor %}
      </section>
    {% endfor %}
  </article>
HTML

puts "Generated community stories data and page (tracks=#{tracks.size})."
