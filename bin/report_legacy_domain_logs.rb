#!/usr/bin/env ruby
require "csv"
require "json"

file_path = ARGV[0]
abort "Usage: ruby ./bin/report_legacy_domain_logs.rb <cloudflare-log.csv|jsonl>" unless file_path && File.file?(file_path)

def normalize_path(path)
  raw = path.to_s.strip
  return "/" if raw.empty?
  return raw if raw.start_with?("/")

  "/#{raw}"
end

def parse_csv(path)
  rows = []
  CSV.foreach(path, headers: true) do |row|
    rows << {
      host: row["ClientRequestHost"] || row["host"],
      path: row["ClientRequestPath"] || row["path"],
      query: row["ClientRequestQuery"] || row["query"],
      status: row["EdgeResponseStatus"] || row["status"]
    }
  end
  rows
end

def parse_jsonl(path)
  rows = []
  File.foreach(path) do |line|
    next if line.strip.empty?
    obj = JSON.parse(line)
    rows << {
      host: obj["ClientRequestHost"] || obj["host"],
      path: obj["ClientRequestPath"] || obj["path"],
      query: obj["ClientRequestQuery"] || obj["query"],
      status: obj["EdgeResponseStatus"] || obj["status"]
    }
  end
  rows
end

rows =
  if File.extname(file_path).downcase == ".jsonl"
    parse_jsonl(file_path)
  else
    parse_csv(file_path)
  end

rows.each do |row|
  row[:host] = row[:host].to_s.strip.downcase
  row[:path] = normalize_path(row[:path])
  row[:query] = row[:query].to_s.strip
  row[:status] = row[:status].to_i
end

rows.reject! { |r| r[:host].empty? }

puts "rows=#{rows.size}"
puts

by_host = rows.group_by { |r| r[:host] }
puts "Top hosts:"
by_host.sort_by { |_host, host_rows| -host_rows.size }.first(10).each do |host, host_rows|
  puts "  #{host}: #{host_rows.size}"
end
puts

puts "Top redirected paths (status 301):"
paths_301 = rows.select { |r| r[:status] == 301 }.group_by { |r| r[:path] }
paths_301.sort_by { |_path, path_rows| -path_rows.size }.first(20).each do |path, path_rows|
  puts "  #{path}: #{path_rows.size}"
end
puts

puts "Top non-301 paths (candidate redirect gaps):"
non_301 = rows.reject { |r| r[:status] == 301 }.group_by { |r| [r[:host], r[:path], r[:status]] }
non_301.sort_by { |_k, v| -v.size }.first(20).each do |(host, path, status), group_rows|
  puts "  #{host} #{path} status=#{status} count=#{group_rows.size}"
end
