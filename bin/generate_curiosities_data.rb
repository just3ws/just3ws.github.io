#!/usr/bin/env ruby
# frozen_string_literal: true

# bin/generate_curiosities_data.rb — Archive Curiosities & Hidden Gems Generator

require 'yaml'
require 'json'
require 'fileutils'

class CuriositiesDataGenerator
  INTERVIEWS_FILE = "_data/interviews.yml"
  OUTPUT_DATA = "_data/archive_curiosities.json"
  ASSETS_OUTPUT = "assets/data/archive_curiosities.json"

  CURIOSITIES = [
    {
      id: "curiosity-1",
      title: "🔮 Predictions vs 2026 Reality: What Came True?",
      category: "Tech Prophecies",
      summary: "In 2011–2015, interviewees made bold predictions about functional programming, microservices, mobile UX, and test automation. Discover which predictions were shockingly prophetic and which aged like milk.",
      key_interviews: [
        { title: "Rich Hickey on Simplicity & Immutability", url: "/interviews/rich-hickey-creator-of-clojure-general/" },
        { title: "Jez Humble on Continuous Delivery", url: "/interviews/jez-humble-goto-conference-2014/" },
        { title: "Tim Bray on the Future of Browsers", url: "/interviews/tim-bray-goto-conference-2014/" }
      ]
    },
    {
      id: "curiosity-2",
      title: "⚡ The Lost Dialects & Forgotten Tooling Era",
      category: "Historical Technology",
      summary: "A living museum of technologies that shaped today's web—IronRuby, DLR, ASP.NET MVC 1.0, Posterous, and early Ember.js—and the historical lessons learned from their rise and fall.",
      key_interviews: [
        { title: "Shay Friedman on IronRuby & DLR", url: "/interviews/vimeo-26657739/" },
        { title: "Brian Hogan on ASP.NET MVC", url: "/interviews/vimeo-26669252/" },
        { title: "Posterous Editing Friction with Mike Hall", url: "/interviews/mike-hall-posterous-editing-frustration/" }
      ]
    },
    {
      id: "curiosity-3",
      title: "🧩 Untold Origin Stories of Modern Open Source",
      category: "Open Source Lore",
      summary: "The human stories behind tools used by millions: How Justin Collins created Brakeman for Rails security, how Kiyoto Tamura built Fluentd for log aggregation, and how Corey Haines started Coderetreat.",
      key_interviews: [
        { title: "Justin Collins on Creating Brakeman", url: "/interviews/justin-collins-creator-of-brakeman-railsconf-2014/" },
        { title: "Kiyoto Tamura on Maintaining Fluentd", url: "/interviews/kiyoto-tamura-maintainer-of-fluentd-a-log-integration-tool-railsconf-2014/" }
      ]
    },
    {
      id: "curiosity-4",
      title: "🧠 Empathy, Apprenticeship & Engineering Ethics",
      category: "Culture & Ethics",
      summary: "Why soft skills are the hardest technical requirement: how to mentor without burnout, conduct retrospectives without blame, and treat code maintainability as a professional ethical duty.",
      key_interviews: [
        { title: "Aino Vonge Corry on Retrospective Antipatterns", url: "/speakers/" },
        { title: "Angelique Martin on Community Building", url: "/interviews/angelique-martin-software-craftsmanship-north-america-2013/" },
        { title: "Sandro Mancuso on Software Apprenticeship", url: "/interviews/sandro-mancuso-software-craftsmanship-north-america-2013/" }
      ]
    },
    {
      id: "curiosity-5",
      title: "🗺️ The Midwest Software Craftsmanship Renaissance",
      category: "Regional Movement",
      summary: "How Chicago and the Midwest forged an independent, craftsman-led engineering culture (SCNA, ChicagoRuby, Chicago ALT.NET, 8th Light) distinct from Silicon Valley hype.",
      key_interviews: [
        { title: "Ray Hightower on ChicagoRuby Scaling", url: "/interviews/ray-hightower-chicagoruby-software-craftsmanship-north-america-2011/" },
        { title: "Robert C. Martin on SCNA & Craftsmanship", url: "/interviews/robert-martin-software-craftsmanship-north-america-2012/" }
      ]
    }
  ].freeze

  def run
    puts "🔮 Generating Archive Curiosities & Hidden Gems..."

    data = {
      generated_at: Time.now.iso8601,
      total_curiosities: CURIOSITIES.size,
      curiosities: CURIOSITIES
    }

    FileUtils.mkdir_p(File.dirname(ASSETS_OUTPUT))
    File.write(OUTPUT_DATA, JSON.pretty_generate(data))
    File.write(ASSETS_OUTPUT, JSON.pretty_generate(data))
    puts "✅ Curiosities data generated at #{OUTPUT_DATA} (#{CURIOSITIES.size} curated topics)."
  end
end

CuriositiesDataGenerator.new.run
