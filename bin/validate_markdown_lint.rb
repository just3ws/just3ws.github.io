#!/usr/bin/env ruby
# frozen_string_literal: true

# Validates markdown files across docs/ and root markdown files for formatting integrity.
puts "🔍 [Validate] Checking Markdown formatting and structure..."

markdown_files = Dir.glob("{docs,exports,backlog,case-studies,scmc,studio}/**/*.md") + Dir.glob("*.md")
errors = []

markdown_files.each do |file|
  content = File.read(file)
  
  # Check for unresolved merge conflict markers
  if content.match?(/^<<<<<<< /) || content.match?(/^=======$/) || content.match?(/^>>>>>>> /)
    errors << "#{file}: Contains unresolved Git merge conflict markers."
  end

  # Check for trailing whitespace on headers
  lines = content.lines
  lines.each_with_index do |line, idx|
    if line.start_with?("#") && line.end_with?(" \n")
      errors << "#{file}:L#{idx + 1}: Header has trailing whitespace."
    end
  end
end

if errors.any?
  puts "❌ Markdown Lint Errors Found (#{errors.size}):"
  errors.each { |err| puts "  - #{err}" }
  exit 1
else
  puts "✅ Markdown Lint Validation Passed cleanly across #{markdown_files.size} Markdown files."
end
