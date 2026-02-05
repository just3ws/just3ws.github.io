#!/usr/bin/env ruby
require "yaml"
require "fileutils"
require "date"

root = File.expand_path("..", __dir__)
interviews_path = File.join(root, "_data", "interviews.yml")
conf_path = File.join(root, "_data", "interview_conferences.yml")
comm_path = File.join(root, "_data", "interview_communities.yml")

interviews = YAML.safe_load(File.read(interviews_path), permitted_classes: [Time, Date], aliases: true)["items"] || []
confs = YAML.safe_load(File.read(conf_path), permitted_classes: [Date], aliases: true)["conferences"] || []
comms = YAML.safe_load(File.read(comm_path), permitted_classes: [Date], aliases: true)["communities"] || []

def yaml_quote(value)
  str = value.to_s.tr("\n", ' ')
  "\"#{str.gsub('"', '\"')}\""
end

def write_index(path, title, intro, items, link_prefix, count_label)
  File.open(path, "w") do |f|
    f.puts "---"
    f.puts "layout: minimal"
    f.puts "title: #{yaml_quote(title)}"
    f.puts "description: #{yaml_quote(intro)}"
    f.puts "---"
    f.puts ""
    f.puts "<article class=\"page\">"
    f.puts "  <header>"
    f.puts "    <h1>#{title}</h1>"
    f.puts "    <p class=\"intro\">#{intro}</p>"
    f.puts "  </header>"
    f.puts ""
    f.puts "  <div class=\"conference-list\">"
    items.each do |item|
      f.puts "    <div class=\"conference-card\">"
      f.puts "      <h2><a href=\"#{link_prefix}/#{item["slug"]}/\">#{item["name"]}</a></h2>"
      if item["location"] && !item["location"].to_s.empty?
        f.puts "      <div class=\"conference-meta\">#{item["location"]}</div>"
      end
      if item["start_date"] && item["end_date"]
        f.puts "      <div class=\"conference-dates\">#{item["start_date"]} – #{item["end_date"]}</div>"
      end
      f.puts "      <div class=\"conference-count\">#{item[count_label]} interviews</div>"
      f.puts "    </div>"
    end
    f.puts "  </div>"
    f.puts "</article>"
  end
end

def write_detail(path, title, intro, filter_field, filter_value, year)
  File.open(path, "w") do |f|
    f.puts "---"
    f.puts "layout: minimal"
    f.puts "title: #{yaml_quote(title)}"
    f.puts "description: #{yaml_quote(intro)}"
    f.puts "---"
    f.puts ""
    f.puts "<article class=\"page\">"
    f.puts "  <header>"
    f.puts "    <h1>#{title}</h1>"
    f.puts "    <p class=\"intro\">#{intro}</p>"
    f.puts "  </header>"
    f.puts ""
    if year
      f.puts "  {% assign items = site.data.interviews.items | where: \"#{filter_field}\", \"#{filter_value}\" | where: \"conference_year\", #{year} | sort: \"recorded_date\" | reverse %}"
    else
      f.puts "  {% assign items = site.data.interviews.items | where: \"#{filter_field}\", \"#{filter_value}\" | sort: \"recorded_date\" | reverse %}"
    end
    f.puts "  {% for interview in items %}"
    f.puts "    {% include interview-card.html interview=interview %}"
    f.puts "  {% endfor %}"
    f.puts "</article>"
  end
end

confs_dir = File.join(root, "interviews", "conferences")
comms_dir = File.join(root, "interviews", "communities")
FileUtils.mkdir_p(confs_dir)
FileUtils.mkdir_p(comms_dir)

confs.each do |conf|
  conf_name = conf["conference"] || conf["name"]
  conf_year = conf["year"]
  conf["interview_count"] = interviews.count do |i|
    i["conference"] == conf_name && (!conf_year || i["conference_year"] == conf_year)
  end
end

comms.each do |comm|
  comm["interview_count"] = interviews.count { |i| i["community"] == comm["name"] }
end

write_index(
  File.join(confs_dir, "index.html"),
  "Interviews by Conference",
  "Browse interviews grouped by conference.",
  confs,
  "/interviews/conferences",
  "interview_count"
)

write_index(
  File.join(comms_dir, "index.html"),
  "Interviews by Community",
  "Browse interviews grouped by community.",
  comms,
  "/interviews/communities",
  "interview_count"
)

confs.each do |conf|
  dir = File.join(confs_dir, conf["slug"])
  FileUtils.mkdir_p(dir)
  conf_name = conf["conference"] || conf["name"]
  conf_year = conf["year"]
  intro = conf_year ? "Interviews recorded at #{conf_name} #{conf_year}." : "Interviews recorded at #{conf_name}."
  write_detail(
    File.join(dir, "index.html"),
    conf["name"],
    intro,
    "conference",
    conf_name,
    conf_year
  )
end

comms.each do |comm|
  dir = File.join(comms_dir, comm["slug"])
  FileUtils.mkdir_p(dir)
  write_detail(
    File.join(dir, "index.html"),
    comm["name"],
    "Interviews recorded with the #{comm["name"]} community.",
    "community",
    comm["name"],
    interviews
  )
end

puts "Generated #{confs.size} conference pages and #{comms.size} community pages."
