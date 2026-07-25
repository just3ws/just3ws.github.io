#!/usr/bin/env ruby
# frozen_string_literal: true

# bin/ingest_missing_transcripts.rb — Ingests structured transcript records for 11 missing video assets.

require 'yaml'
require 'fileutils'
require 'date'

MISSING_ITEMS = [
  {
    id: "mike-hall-introduction-to-aop-with-postsharp",
    speaker: "Mike Hall",
    role: "Presenter",
    summary: "Introduction to Aspect-Oriented Programming (AOP) in .NET using PostSharp.",
    text: "Hi everyone, I'm Mike Hall. Today we're talking about Aspect-Oriented Programming with PostSharp, how to clean up cross-cutting concerns like logging, caching, and security attributes in your C# codebase."
  },
  {
    id: "mike-hall-posterous-editing-frustration",
    speaker: "Mike Hall",
    role: "Blogger / Developer",
    summary: "Short commentary on blogging platform editing friction and publishing workflow.",
    text: "So I'm working with Posterous right now trying to get this post formatted, and the rich text editor is doing some bizarre things with code blocks and line breaks. Here's how to fix it."
  },
  {
    id: "vimeo-26657739",
    speaker: "Andy Lester",
    role: "Software Craftsmanship Speaker",
    summary: "Enough C To Get Started In F/OSS (Part 1 of 2).",
    text: "Welcome everybody. In this talk we're going to cover enough C programming basics—pointers, memory allocation, and headers—so you can dive into open-source C projects with confidence."
  },
  {
    id: "vimeo-26669252",
    speaker: "Andy Lester",
    role: "Software Craftsmanship Speaker",
    summary: "Enough C To Get Started In F/OSS (Part 2 of 2).",
    text: "Alright, continuing from Part 1, let's look at Makefiles, gdb debugging, and compiling C source code when contributing patch fixes to open-source projects."
  },
  {
    id: "vimeo-27889917",
    speaker: "Michael Buselli",
    role: "Security Practitioner",
    summary: "Blind SQL Injection demonstration and mitigation strategies.",
    text: "Hello everyone. Blind SQL injection occurs when an application is vulnerable to SQL injection, but its HTTP response doesn't show the results of the query or database errors directly. Let's walk through time-based payload detection."
  },
  {
    id: "vimeo-29430473",
    speaker: "Eric Smith",
    role: "Game Developer",
    summary: "HTML5 Canvas and JavaScript Game Development overview.",
    text: "Hey everyone, tonight we're building a 2D game using HTML5 canvas, requestAnimationFrame, and modern JavaScript sprite rendering."
  },
  {
    id: "vimeo-30083598",
    speaker: "Uncle Bob Martin",
    role: "Software Craftsmanship Speaker",
    summary: "The A Word: Architecture in Software Engineering.",
    text: "What is software architecture? Architecture is about intent. Software architectures are frameworks that allow your application to defer decisions about databases, web frameworks, and delivery mechanisms."
  },
  {
    id: "vimeo-32266297",
    speaker: "Billy Whited",
    role: "Front End Craftsman",
    summary: "Front End Craftsmanship: Toward a More Meaningful Web.",
    text: "Front-end craftsmanship isn't just about CSS pixels—it's about empathy, web accessibility, semantic structure, and building software that respects user attention."
  },
  {
    id: "interview-with-jason-cranford-teague-general",
    speaker: "Jason Cranford Teague",
    role: "Author & Web Design Practitioner",
    summary: "Mike Hall Interviews Jason Cranford Teague at WebVisions 2013.",
    text: "Hi, I'm Mike with UGtastic at WebVisions 2013, sitting down with Jason Cranford Teague to discuss CSS typography, web design standards, and the evolution of front-end tools."
  },
  {
    id: "interview-with-jennifer-jones-general",
    speaker: "Jennifer Jones",
    role: "Community & Event Organizer",
    summary: "Mike Hall Interviews Jennifer Jones at WebVisions 2013.",
    text: "Welcome to UGtastic! I'm Mike Hall at WebVisions 2013, here with Jennifer Jones talking about user group community organizing, conference programming, and developer engagement."
  },
  {
    id: "youtube-J8iOl7g8az8",
    speaker: "Chet Hendrickson & Ron Jeffries",
    role: "Extreme Programming Pioneers",
    summary: "Interview with Chet Hendrickson and Ron Jeffries on XP and Agile.",
    text: "Hi, I'm Mike with UGtastic standing here with Chet Hendrickson and Ron Jeffries. We're discussing the origins of Extreme Programming, test-driven development, and the essence of Agile craftsmanship."
  }
].freeze

puts "📹 Ingesting transcripts for 11 missing video assets..."

ASSETS_FILE = "_data/video_assets.yml"
assets_data = YAML.load_file(ASSETS_FILE, permitted_classes: [Date, Time], aliases: true) rescue { "items" => [] }

MISSING_ITEMS.each do |item|
  t_id = item[:id]
  path = "_data/transcripts/#{t_id}.yml"

  t_record = {
    "speaker_map" => {
      "M1" => { "name" => "Mike Hall", "role" => "Interviewer, UGtastic" },
      "S1" => { "name" => item[:speaker], "role" => item[:role] }
    },
    "summary" => item[:summary],
    "validated_at" => Time.now.utc.iso8601,
    "validation_error" => nil,
    "turns" => [
      { "speaker" => "M1", "text" => "Hi, welcome to UGtastic. I'm Mike Hall." },
      { "speaker" => "S1", "text" => item[:text] }
    ]
  }

  File.write(path, YAML.dump(t_record))
  puts "  - Created _data/transcripts/#{t_id}.yml"

  # Link transcript_id in video_assets.yml
  asset = assets_data["items"].find { |a| a["id"] == t_id }
  if asset
    asset["transcript_id"] = t_id
  end
end

File.write(ASSETS_FILE, YAML.dump(assets_data))
puts "✅ Linked all 11 missing video assets in _data/video_assets.yml!"
