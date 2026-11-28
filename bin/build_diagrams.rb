#!/usr/bin/env ruby
# frozen_string_literal: true

# ---
# name: build_diagrams.rb
# domain: data
# purpose: Compile build-time D2 and Graphviz DOT architecture diagrams to static SVGs
# usage: ruby bin/build_diagrams.rb
# ---

require "fileutils"
require "open3"

ROOT = File.expand_path("..", __dir__)
SRC_DIR = File.join(ROOT, "src", "diagrams")
OUT_DIR = File.join(ROOT, "assets", "diagrams")

FileUtils.mkdir_p(OUT_DIR)

def run_cmd(*cmd)
  stdout, stderr, status = Open3.capture3(*cmd)
  return if status.success?

  warn "Command failed: #{cmd.join(' ')}"
  warn stderr unless stderr.empty?
  warn stdout unless stdout.empty?
  exit status.exitstatus
end

d2_files = Dir[File.join(SRC_DIR, "*.d2")].sort
dot_files = Dir[File.join(SRC_DIR, "*.dot")].sort

d2_files.each do |src|
  name = File.basename(src, ".d2")
  out = File.join(OUT_DIR, "#{name}.svg")
  puts "[d2] #{File.basename(src)} -> assets/diagrams/#{name}.svg"
  run_cmd("d2", "--layout=elk", "--theme=0", "--dark-theme=200", "--pad=24", src, out)
end

dot_files.each do |src|
  name = File.basename(src, ".dot")
  out = File.join(OUT_DIR, "#{name}.svg")
  puts "[dot] #{File.basename(src)} -> assets/diagrams/#{name}.svg"
  run_cmd("dot", "-Tsvg", src, "-o", out)
end

puts "Compiled #{d2_files.size} D2 and #{dot_files.size} Graphviz diagrams into assets/diagrams/."
