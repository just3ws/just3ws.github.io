#!/usr/bin/env ruby

require "time"
require "fileutils"
require_relative "../src/generators/core/yaml_io"

ROOT = File.expand_path("..", __dir__)
INTERVIEWS_PATH = File.join(ROOT, "_data", "interviews.yml")
OUT_DATA_PATH = File.join(ROOT, "_data", "interviewees_index.yml")
OUT_PAGE_PATH = File.join(ROOT, "interviews", "people", "index.html")

def slugify(value)
  value.to_s.downcase
       .gsub(/[^a-z0-9]+/, "-")
       .gsub(/\A-+|-+\z/, "")
end

interviews = Generators::Core::YamlIo.load(INTERVIEWS_PATH, key: "items")
people = Hash.new { |hash, key| hash[key] = [] }

interviews.each do |interview|
  names = Array(interview["interviewees"]).map { |name| name.to_s.gsub(/\s+/, " ").strip }.reject(&:empty?)
  names.each { |name| people[name] << interview }
end

items = people.map do |name, rows|
  sorted_rows = rows.sort_by { |row| row["recorded_date"].to_s }.reverse
  {
    "slug" => slugify(name),
    "name" => name,
    "count" => sorted_rows.size,
    "sample_interview_ids" => sorted_rows.first(5).map { |row| row["id"] }
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

FileUtils.mkdir_p(File.dirname(OUT_PAGE_PATH))
File.write(OUT_PAGE_PATH, <<~HTML)
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
    {% assign interview_items = site.data.interviews.items | where_exp: "i", "i.video_asset_id" %}
    {% include json-ld-itemlist.html
      collection_name="Interviewees"
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
      <h1>Interviewees</h1>
      <p class="intro">This index tracks interviewees across the archive so repeated voices and long-term participation are easy to follow.</p>
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
            <strong>{{ person.name }}</strong> ({{ person.count }} interviews)
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

puts "Generated interviewees index data and page (people=#{items.size})."
