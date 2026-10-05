#!/usr/bin/env ruby
# frozen_string_literal: true

# bin/index_hister_corpus.rb — Index Core Craftsmanship, Agile & Conference Corpus into Hister
#
# Feeds foundational primary sources, conference hubs, user group communities, and
# archival records into the hister.localhost search engine.

require 'open3'
require 'uri'

CORPUS = {
  "Software Craftsmanship Movement" => [
    "http://manifesto.softwarecraftsmanship.org/",
    "http://manifesto.softwarecraftsmanship.org/manifesto/signatories",
    "https://8thlight.com/",
    "https://8thlight.com/insights",
    "https://8thlight.com/about",
    "https://8thlight.com/apprenticeship",
    "http://coreyhaines.com/",
    "https://www.coderetreat.org/",
    "https://cleancoders.com/",
    "https://blog.cleancoder.com/",
    "https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html",
    "https://blog.cleancoder.com/uncle-bob/2014/05/11/TheOpenClosedPrinciple.html",
    "http://butunclebob.com/ArticleS.UncleBob.TheThreeRulesOfTdd",
    "https://codurance.com/",
    "https://codurance.com/publications/software-craftsmanship-manifesto/",
    "https://codurance.com/academy/",
    "https://www.sandromancuso.com/",
    "http://ravimohan.blogspot.com/2005/09/nostalgia-for-guilds-and-other.html"
  ],
  "Agile & Extreme Programming Roots" => [
    "https://agilemanifesto.org/",
    "https://agilemanifesto.org/principles.html",
    "https://agilemanifesto.org/history.html",
    "https://agilemanifesto.org/authors.html",
    "https://martinfowler.com/",
    "https://martinfowler.com/bliki/SoftwareCraftsmanship.html",
    "https://martinfowler.com/bliki/ExtremeProgramming.html",
    "https://martinfowler.com/bliki/ContinuousIntegration.html",
    "https://martinfowler.com/bliki/CodeSmell.html",
    "https://martinfowler.com/articles/refactoring-2nd-ed.html",
    "https://martinfowler.com/articles/mocksArentStubs.html",
    "https://ronjeffries.com/",
    "https://ronjeffries.com/xprog/what-is-extreme-programming/",
    "https://ronjeffries.com/articles/020-craft/",
    "http://xprogramming.com/",
    "http://wiki.c2.com/?SoftwareCraftsmanship",
    "http://wiki.c2.com/?ExtremeProgrammingRoadmap",
    "http://wiki.c2.com/?AgileManifesto",
    "http://wiki.c2.com/?TestDrivenDevelopment",
    "http://wiki.c2.com/?PairProgramming"
  ],
  "Conferences Covered by UGtastic" => [
    "https://gotopia.tech/",
    "https://gotocon.com/chicago-2015",
    "https://gotocon.com/chicago-2014",
    "https://gotocon.com/chicago-2013",
    "https://gotopia.tech/posts",
    "http://scna.softwarecraftsmanship.org/",
    "https://windycityrails.org/",
    "https://chicagoruby.com/",
    "https://railsconf.org/",
    "https://www.just3ws.localhost/interviews/conferences/",
    "https://www.just3ws.localhost/videos/sarah-gray-software-craftsmanship-north-america-2013/",
    "https://www.just3ws.localhost/videos/gary-bernhardt-software-craftsmanship-north-america-2012/",
    "https://www.just3ws.localhost/videos/corey-haines-goto-conference-2015/",
    "https://www.just3ws.localhost/videos/tim-bray-goto-conference-2014/",
    "https://www.just3ws.localhost/videos/trisha-gee-goto-conference-2015/",
    "https://www.just3ws.localhost/videos/stuart-halloway-software-craftsmanship-north-america-2013/",
    "https://www.just3ws.localhost/videos/brian-marick-software-craftsmanship-north-america-2012/",
    "https://www.just3ws.localhost/videos/zach-dennis-software-craftsmanship-north-america-2012/",
    "https://www.just3ws.localhost/videos/ray-hightower-chicagoruby-software-craftsmanship-north-america-2011/",
    "https://www.just3ws.localhost/videos/obie-fernandez-author-the-rails-way-co-founder-hashrocket-railsconf-2014/"
  ],
  "Groups & Communities" => [
    "https://www.just3ws.localhost/interviews/communities/",
    "https://www.just3ws.localhost/scmc/",
    "https://www.just3ws.localhost/ugtastic/",
    "https://www.just3ws.localhost/timeline/community/",
    "https://www.just3ws.localhost/interviews/sergio-pereira-chicago-alt-net-software-craftsmanship-north-america-2011/",
    "https://www.just3ws.localhost/interviews/scott-seely-lake-county-net-user-group-lcnug-lake-county-net-user-group-lcnug/",
    "https://www.just3ws.localhost/interviews/people/",
    "https://www.meetup.com/london-software-craftsmanship/",
    "https://www.meetup.com/Chicago-Alt-Net/",
    "https://www.chipy.org/",
    "https://www.meetup.com/ChicagoRuby/"
  ]
}.freeze

puts "🔍 Hister Corpus Ingestion Engine"
puts "======================================================="

total_indexed = 0
total_failed = 0
total_skipped = 0

CORPUS.each do |section, urls|
  puts "\n📂 Category: #{section} (#{urls.size} target URLs)"
  puts "-------------------------------------------------------"
  
  urls.each_with_index do |url, idx|
    cmd = ["hister", "index", url, "--force"]
    stdout, stderr, status = Open3.capture3(*cmd)
    
    if status.success?
      if stdout.include?("already indexed")
        puts "  [#{idx + 1}/#{urls.size}] ⏭️  SKIP: #{url} (already indexed)"
        total_skipped += 1
      else
        puts "  [#{idx + 1}/#{urls.size}] ✅ INDEXED: #{url}"
        total_indexed += 1
      end
    else
      err_msg = stderr.strip.empty? ? stdout.strip : stderr.strip
      puts "  [#{idx + 1}/#{urls.size}] ⚠️  FAILED: #{url} - #{err_msg}"
      total_failed += 1
    end
    
    # Polite pacing
    sleep 0.2
  end
end

puts "\n======================================================="
puts "Execution Complete:"
puts "  Indexed: #{total_indexed}"
puts "  Skipped: #{total_skipped}"
puts "  Failed:  #{total_failed}"
puts "======================================================="
