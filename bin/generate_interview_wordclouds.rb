#!/usr/bin/env ruby

require "date"
require "fileutils"
require "yaml"

ROOT = File.expand_path("..", __dir__)
DATA_DIR = File.join(ROOT, "_data")
TRANSCRIPTS_DIR = File.join(DATA_DIR, "transcripts")
OUTPUT = File.join(DATA_DIR, "interview_wordclouds.yml")

STOPWORDS = %w[
  about after again all also and are around ask asking back because been being but can
  could did does doing don down during each even for from get getting had has have having
  her here him his how i if in into is it its just like little lot make making me more most
  much my not now of off oh on one only or our out over people really said say saying see
  so some something than that the their them then there these they thing think this those
  through to too up us use using very want was way we well what when where which who will
  with would yeah you your
  actually basically okay ok right uh um hmm hello thanks welcome know going got get
  thing things something someone everybody people interview interviews interviewer
  speaker speakers talking talk question questions answer answers episode again
  kind were it would still always really mean means maybe much many another
].to_set

def load_yaml(path)
  YAML.load_file(path, aliases: true) || {}
end

def transcript_text(data)
  rows = data["turns"] || data["segments"] || []
  text = rows.filter_map { |row| row.is_a?(Hash) ? row["text"] : row }.join(" ")
  text = data["content"].to_s if text.strip.empty?
  text
end

def words(text)
  text.to_s.downcase.scan(/[a-z][a-z0-9+#-]{2,}/).reject do |word|
    STOPWORDS.include?(word) || word.match?(/\A\d+\z/) || word.length > 28
  end
end

def cloud(text, labels = [])
  counts = Hash.new(0)
  words(text).each { |word| counts[word] += 1 }
  labels.each { |label| words(label).each { |word| counts[word] += 6 } }
  counts.sort_by { |word, count| [-count, word] }.first(36).map do |word, count|
    { "text" => word, "count" => count, "weight" => Math.log(count + 1).round(3) }
  end
end

def group_record(id, label, rows, transcripts, kind, url = nil)
  corpus = rows.map { |row| transcripts[row["id"]].to_s }.join(" ")
  labels = rows.flat_map { |row| [row["title"], row["topic"], *(row["tags"] || [])] }
  {
    "id" => id,
    "label" => label,
    "kind" => kind,
    "count" => rows.size,
    "url" => url,
    "words" => cloud(corpus, labels),
    "items" => rows.sort_by { |row| [row["recorded_date"].to_s, row["id"].to_s] }.reverse.first(12).map do |row|
      { "id" => row["id"], "title" => row["title"], "topic" => row["topic"], "recorded_date" => row["recorded_date"] }
    end
  }
end

interviews = load_yaml(File.join(DATA_DIR, "interviews.yml"))["items"] || []
assets = load_yaml(File.join(DATA_DIR, "video_assets.yml"))["items"] || []
assets_by_id = assets.to_h { |asset| [asset["id"], asset] }

usable = interviews.filter_map do |row|
  asset = assets_by_id[row["video_asset_id"]] || {}
  transcript_id = asset["transcript_id"] || row["id"]
  path = File.join(TRANSCRIPTS_DIR, "#{transcript_id}.yml")
  next unless File.file?(path)

  data = load_yaml(path)
  row.merge(
    "transcript_id" => transcript_id,
    "event" => asset["event"],
    "category" => asset["category"]
  ).then { |item| [item, transcript_text(data)] }
end

rows = usable.map(&:first)
transcripts = usable.to_h { |row, text| [row["id"], text] }

groups = []
groups << group_record("ugtastic", "UGtastic oral history", rows, transcripts, "archive", "/interviews/")

rows.group_by { |row| row["event"].to_s.strip }.reject { |key, _| key.empty? }.sort.each do |label, items|
  groups << group_record("conference-#{label.downcase.gsub(/[^a-z0-9]+/, "-")}", label, items, transcripts, "conference", "/interviews/topics/")
end

rows.group_by { |row| row["community"].to_s.strip }.reject { |key, _| key.empty? || key.casecmp("general").zero? }.sort.each do |label, items|
  groups << group_record("community-#{label.downcase.gsub(/[^a-z0-9]+/, "-")}", label, items, transcripts, "community", "/interviews/communities/")
end

presentation_rows = rows.select do |row|
  row["category"].to_s.casecmp("presentation").zero? || row["title"].to_s.match?(/talk|keynote|presentation|pechakucha/i)
end
groups << group_record("presentations", "Presentations and talks", presentation_rows, transcripts, "presentation", "/videos/") unless presentation_rows.empty?

interview_records = rows.map do |row|
  group_record("interview-#{row["id"]}", row["title"], [row], transcripts, "interview", "/interviews/#{row["id"]}/")
end

output = {
  "generated_at" => DateTime.now.new_offset(0).iso8601,
  "summary" => { "interviews" => rows.size, "groups" => groups.size, "individual_clouds" => interview_records.size },
  "groups" => groups,
  "interviews" => interview_records
}
File.write(OUTPUT, output.to_yaml)
puts "Generated #{OUTPUT} (#{rows.size} interviews, #{groups.size} groups, #{interview_records.size} individual clouds)."
