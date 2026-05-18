#!/usr/bin/env ruby

require "time"
require "fileutils"
require "set"
require_relative "../src/generators/core/yaml_io"

ROOT = File.expand_path("..", __dir__)
INTERVIEWS_PATH = File.join(ROOT, "_data", "interviews.yml")
RELATED_VIDEOS_PATH = File.join(ROOT, "_data", "interview_related_videos.yml")
OUT_DATA_PATH = File.join(ROOT, "_data", "interviewees_index.yml")
PEOPLE_DIR = File.join(ROOT, "interviews", "people")
OUT_INDEX_PATH = File.join(PEOPLE_DIR, "index.html")

def slugify(value)
  value.to_s.downcase
       .gsub(/[^a-z0-9]+/, "-")
       .gsub(/\A-+|-+\z/, "")
end

def normalized_name(name)
  name.to_s.gsub(/\s+/, " ").strip
end

interviews = Generators::Core::YamlIo.load(INTERVIEWS_PATH, key: "items")
related_videos_data = Generators::Core::YamlIo.load(RELATED_VIDEOS_PATH)
related_by_interview = {}

Array(related_videos_data["items"]).each do |entry|
  related_by_interview[entry["interview_id"].to_s] = Array(entry["links"])
end

people = Hash.new { |hash, key| hash[key] = [] }
interviews.each do |interview|
  names = Array(interview["interviewees"]).map { |name| normalized_name(name) }.reject(&:empty?)
  names.each { |name| people[name] << interview }
end

items = people.map do |name, rows|
  sorted_rows = rows.sort_by { |row| row["recorded_date"].to_s }.reverse
  bio_links = []
  presentation_links = []
  bio_summaries = []

  appearances = sorted_rows.map do |row|
    interview_id = row["id"].to_s
    links = related_by_interview.fetch(interview_id, [])
    person_links = links.select { |link| link["kind"].to_s.start_with?("conference-") || link["kind"].to_s == "official-playlist" }

    person_links.each do |link|
      kind = link["kind"].to_s
      normalized = {
        "label" => link["label"].to_s,
        "kind" => kind,
        "url" => link["url"].to_s,
        "embed_url" => link["embed_url"].to_s,
        "description" => link["description"].to_s
      }
      if kind == "conference-bio"
        bio_links << normalized
        bio_summaries << normalized["description"] unless normalized["description"].strip.empty?
      elsif kind == "conference-presentation-page" || kind == "conference-presentation-video"
        presentation_links << normalized
      end
    end

    {
      "id" => interview_id,
      "title" => row["title"].to_s,
      "recorded_date" => row["recorded_date"].to_s,
      "conference" => row["conference"].to_s,
      "conference_year" => row["conference_year"].to_s,
      "community" => row["community"].to_s,
      "topic" => row["topic"].to_s,
      "url" => "/interviews/#{interview_id}/",
      "related_links" => person_links.map do |link|
        {
          "label" => link["label"].to_s,
          "kind" => link["kind"].to_s,
          "url" => link["url"].to_s,
          "embed_url" => link["embed_url"].to_s,
          "description" => link["description"].to_s
        }
      end
    }
  end

  unique_by_key = lambda do |arr|
    seen = Set.new
    arr.each_with_object([]) do |item, memo|
      key = [item["kind"], item["url"], item["label"]].join("|")
      next if key.strip.empty? || seen.include?(key)
      seen << key
      memo << item
    end
  end

  {
    "slug" => slugify(name),
    "name" => name,
    "count" => sorted_rows.size,
    "sample_interview_ids" => sorted_rows.first(5).map { |row| row["id"] },
    "interview_ids" => sorted_rows.map { |row| row["id"] },
    "profile_summary" => bio_summaries.max_by { |summary| summary.length }.to_s,
    "bio_links" => unique_by_key.call(bio_links),
    "presentation_links" => unique_by_key.call(presentation_links),
    "appearances" => appearances
  }
end

items.sort_by! { |item| [-item["count"], item["name"]] }

out_data = {
  "generated_at" => Time.now.utc.iso8601,
  "summary" => {
    "total_people" => items.size,
    "people_with_multiple_interviews" => items.count { |item| item["count"] > 1 }
  },
  "items" => items
}
Generators::Core::YamlIo.dump(OUT_DATA_PATH, out_data)

FileUtils.mkdir_p(PEOPLE_DIR)
File.write(OUT_INDEX_PATH, <<~HTML)
  ---
  layout: minimal
  title: Interviewees
  description: People-first index of interviewees with appearance counts and direct links into related conversations.
  breadcrumb: Interviewees
  breadcrumb_parent_name: Interviews
  breadcrumb_parent_url: /interviews/
  ---

  <article class="page">
    {% include breadcrumbs.html %}
    {% assign people = site.data.interviewees_index %}
    <header>
      <h1>Interviewees</h1>
      <p class="intro">Browse dedicated profile pages for interviewees, including all appearances and conference context links.</p>
      {% if people.summary %}
        <p>
          Interviewees: {{ people.summary.total_people }} |
          With multiple appearances: {{ people.summary.people_with_multiple_interviews }}
        </p>
      {% endif %}
    </header>

    <section>
      <ul class="home-list">
        {% for person in people.items %}
          <li id="{{ person.slug }}">
            <strong><a href="/interviews/people/{{ person.slug }}/">{{ person.name }}</a></strong> ({{ person.count }} interviews)
            {% if person.sample_interview_ids and person.sample_interview_ids.size > 0 %}
              <br>
              {% for interview_id in person.sample_interview_ids %}
                {% assign interview = site.data.interviews.items | where: "id", interview_id | first %}
                {% if interview %}
                  <a href="/interviews/{{ interview.id }}/">{{ interview.title }}</a>{% unless forloop.last %}, {% endunless %}
                {% endif %}
              {% endfor %}
            {% endif %}
          </li>
        {% endfor %}
      </ul>
    </section>
  </article>
HTML

items.each do |person|
  person_dir = File.join(PEOPLE_DIR, person["slug"])
  FileUtils.mkdir_p(person_dir)
  page_path = File.join(person_dir, "index.html")
  File.write(page_path, <<~HTML)
    ---
    layout: minimal
    title: #{person["name"]} Interviews
    description: Interview archive page for #{person["name"]}, including appearances, related conference profiles, and presentation links.
    breadcrumb: #{person["name"]}
    breadcrumb_parent_name: Interviewees
    breadcrumb_parent_url: /interviews/people/
    ---

    <article class="page">
      {% include breadcrumbs.html %}
      {% assign person = site.data.interviewees_index.items | where: "slug", "#{person["slug"]}" | first %}
      {% if person %}
        <header>
          <h1>{{ person.name }}</h1>
          <p>{{ person.count }} interview{% if person.count != 1 %}s{% endif %} in the archive.</p>
          {% if person.profile_summary and person.profile_summary != "" %}
            <p>{{ person.profile_summary }}</p>
          {% endif %}
        </header>

        {% if person.bio_links and person.bio_links.size > 0 %}
          <section>
            <h2>Profile Links</h2>
            <ul>
              {% for link in person.bio_links %}
                <li><a href="{{ link.url }}">{{ link.label }}</a></li>
              {% endfor %}
            </ul>
          </section>
        {% endif %}

        {% if person.presentation_links and person.presentation_links.size > 0 %}
          <section>
            <h2>Related Talks</h2>
            <ul>
              {% for link in person.presentation_links %}
                <li>
                  <a href="{{ link.url }}">{{ link.label }}</a>
                  {% if link.description and link.description != "" %}<br>{{ link.description }}{% endif %}
                </li>
              {% endfor %}
            </ul>
          </section>
        {% endif %}

        {% if person.appearances and person.appearances.size > 0 %}
          <section>
            <h2>Interview Appearances</h2>
            <ul class="home-list">
              {% for appearance in person.appearances %}
                <li>
                  <a href="{{ appearance.url }}">{{ appearance.title }}</a>
                  {% if appearance.recorded_date and appearance.recorded_date != "" %} · {{ appearance.recorded_date }}{% endif %}
                  {% if appearance.conference and appearance.conference != "" %} · {{ appearance.conference }}{% if appearance.conference_year and appearance.conference_year != "" %} {{ appearance.conference_year }}{% endif %}{% endif %}
                  {% if appearance.topic and appearance.topic != "" %}<br>Topic: {{ appearance.topic }}{% endif %}
                </li>
              {% endfor %}
            </ul>
          </section>
        {% endif %}
      {% endif %}
    </article>
  HTML
end

puts "Generated interviewees index and profile pages (people=#{items.size})."
