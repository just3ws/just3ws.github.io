#!/usr/bin/env ruby
require "fileutils"
require "erb"
require_relative "../src/generators/core/text"
require_relative "../src/generators/core/yaml_io"

root = File.expand_path("..", __dir__)
interviews_path = File.join(root, "_data", "interviews.yml")
conf_path = File.join(root, "_data", "interview_conferences.yml")
comm_path = File.join(root, "_data", "interview_communities.yml")
index_summary_path = File.join(root, "_data", "index_summaries.yml")
index_template_path = File.join(root, "_templates", "generated", "interview-taxonomy-index.erb")
detail_template_path = File.join(root, "_templates", "generated", "interview-taxonomy-detail.erb")

interviews = Generators::Core::YamlIo.load(interviews_path, key: "items")
confs = Generators::Core::YamlIo.load(conf_path, key: "conferences")
comms = Generators::Core::YamlIo.load(comm_path, key: "communities")
index_summaries = Generators::Core::YamlIo.load(index_summary_path)

def interview_count_label(count)
  count.to_i == 1 ? "1 interview" : "#{count} interviews"
end

def render_template(template_path, output_path, locals)
  template = File.read(template_path)
  renderer = ERB.new(template, trim_mode: "-")

  locals.each do |name, value|
    define_singleton_method(name) { value }
  end

  File.write(output_path, renderer.result(binding))
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

conference_cards = confs.map do |item|
  {
    name: item["name"],
    link: "/interviews/conferences/#{item["slug"]}/",
    summary: item["summary"],
    location: item["location"],
    dates: (item["start_date"] && item["end_date"]) ? "#{item["start_date"]} – #{item["end_date"]}" : nil,
    count_label: interview_count_label(item["interview_count"])
  }
end

render_template(
  index_template_path,
  File.join(confs_dir, "index.html"),
  title: "Interviews by Conference",
  intro: "Browse interviews grouped by conference.",
  cards: conference_cards,
  summary: index_summaries.dig("pages", "interviews_conferences", "summary"),
  highlights: index_summaries.dig("pages", "interviews_conferences", "highlights"),
  parent_name: "Interviews",
  parent_url: "/interviews/",
  grandparent_name: nil,
  grandparent_url: nil
)

community_cards = comms.map do |item|
  {
    name: item["name"],
    link: "/interviews/communities/#{item["slug"]}/",
    summary: item["summary"],
    location: item["location"],
    dates: nil,
    count_label: interview_count_label(item["interview_count"])
  }
end

render_template(
  index_template_path,
  File.join(comms_dir, "index.html"),
  title: "Interviews by Community",
  intro: "Browse interviews grouped by community.",
  cards: community_cards,
  summary: index_summaries.dig("pages", "interviews_communities", "summary"),
  highlights: index_summaries.dig("pages", "interviews_communities", "highlights"),
  parent_name: "Interviews",
  parent_url: "/interviews/",
  grandparent_name: nil,
  grandparent_url: nil
)

confs.each do |conf|
  dir = File.join(confs_dir, conf["slug"])
  FileUtils.mkdir_p(dir)
  conf_name = conf["conference"] || conf["name"]
  conf_year = conf["year"]
  intro = conf["summary"] || (conf_year ? "Interviews recorded at #{conf_name} #{conf_year}." : "Interviews recorded at #{conf_name}.")
  liquid_assign =
    if conf_year
      "{% assign items = site.data.interviews.items | where: \"conference\", \"#{conf_name}\" | where: \"conference_year\", #{conf_year} | sort: \"recorded_date\" | reverse %}"
    else
      "{% assign items = site.data.interviews.items | where: \"conference\", \"#{conf_name}\" | sort: \"recorded_date\" | reverse %}"
    end

  render_template(
    detail_template_path,
    File.join(dir, "index.html"),
    title: conf["name"],
    intro: intro,
    liquid_assign: liquid_assign,
    highlights: conf["highlights"],
    parent_name: "Interviews by Conference",
    parent_url: "/interviews/conferences/",
    grandparent_name: "Interviews",
    grandparent_url: "/interviews/"
  )
end

comms.each do |comm|
  dir = File.join(comms_dir, comm["slug"])
  FileUtils.mkdir_p(dir)
  liquid_assign = "{% assign items = site.data.interviews.items | where: \"community\", \"#{comm["name"]}\" | sort: \"recorded_date\" | reverse %}"

  render_template(
    detail_template_path,
    File.join(dir, "index.html"),
    title: comm["name"],
    intro: comm["summary"] || "Interviews recorded with the #{comm["name"]} community.",
    liquid_assign: liquid_assign,
    highlights: comm["highlights"],
    parent_name: "Interviews by Community",
    parent_url: "/interviews/communities/",
    grandparent_name: "Interviews",
    grandparent_url: "/interviews/"
  )
end

puts "Generated #{confs.size} conference pages and #{comms.size} community pages."
