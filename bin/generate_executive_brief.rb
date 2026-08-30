#!/usr/bin/env ruby
# frozen_string_literal: true

# bin/generate_executive_brief.rb
# Generates a tailored 1-page executive pitch brief and interview prep sheet
# using the 3-Act Narrative Architecture, Progressive Disclosure, and canonical datalake.
# Callable from CLI, rake tasks, or external tools (wwworkremote.localhost).

require "optparse"
require "yaml"
require "json"
require "fileutils"

ROOT_DIR = File.expand_path("..", __dir__)
DATA_DIR = File.join(ROOT_DIR, "_data", "resume")
BRIEFS_DIR = File.join(ROOT_DIR, "docs", "executive-briefs")
EXPORTS_BRIEFS_DIR = File.join(ROOT_DIR, "exports", "briefs")
DATALAKE_FILE = File.join(ROOT_DIR, "career_datalake.json")

options = {
  company: nil,
  role: "Principal Software Engineer",
  domain: nil,
  comp_range: nil,
  tier: "principal",
  mandate: nil,
  key_pains: [],
  lead_id: nil,
  posting_id: nil,
  out_dir: BRIEFS_DIR,
  generate_html: true,
  generate_pdf: false,
  json: false
}

OptionParser.new do |opts|
  opts.banner = "Usage: ruby bin/generate_executive_brief.rb [options]"

  opts.on("-c", "--company COMPANY", String, "Target company name (e.g. 'Huntress', 'Coder')") do |v|
    options[:company] = v
  end

  opts.on("-r", "--role ROLE", String, "Target role title (default: 'Principal Software Engineer')") do |v|
    options[:role] = v
  end

  opts.on("-d", "--domain DOMAIN", String, "Target engineering domain (e.g. 'SOC / Rails', 'Platform Architecture')") do |v|
    options[:domain] = v
  end

  opts.on("--comp COMP", String, "Compensation range (e.g. '$200,000 to $260,000 / yr')") do |v|
    options[:comp_range] = v
  end

  opts.on("-t", "--tier TIER", String, "Target tier: 'principal', 'staff', 'founding', 'contractor', 'observability'") do |v|
    options[:tier] = v.downcase
  end

  opts.on("-m", "--mandate MANDATE", String, "Company mandate or engineering challenge description") do |v|
    options[:mandate] = v
  end

  opts.on("-k", "--key-pains PAINS", String, "Comma-separated key technical challenges/pains") do |v|
    options[:key_pains] = v.split(",").map(&:strip)
  end

  opts.on("-l", "--lead-id ID", Integer, "Optional wwworkremote lead ID") do |v|
    options[:lead_id] = v
  end

  opts.on("-p", "--posting-id ID", Integer, "Optional wwworkremote posting ID") do |v|
    options[:posting_id] = v
  end

  opts.on("-o", "--out-dir DIR", String, "Output directory for markdown briefs (default: docs/executive-briefs/)") do |v|
    options[:out_dir] = v
  end

  opts.on("--[no-]html", "Generate localhost HTML page (default: true)") do |v|
    options[:generate_html] = v
  end

  opts.on("--pdf", "Generate PDF export via export_brief_pdfs.js") do
    options[:generate_pdf] = true
  end

  opts.on("-j", "--json", "Output JSON result for machine callers") do
    options[:json] = true
  end

  opts.on("--help", "Show this help message") do
    puts opts
    exit 0
  end
end.parse!

if options[:company].nil? || options[:company].empty?
  warn "Error: --company is required (e.g. ruby bin/generate_executive_brief.rb -c 'Huntress' -r 'Principal Software Engineer')"
  exit 1
end

company = options[:company].strip
role = options[:role].strip
tier = options[:tier]
domain = options[:domain] || "#{role} Platform Architecture"
mandate = options[:mandate] || "scaling high-reliability production platforms and modernizing critical legacy architectures"

slug = "#{company}-#{role}".downcase.gsub(/[^a-z0-9]+/, "-").gsub(/^-+|-+$/, "")
filename = "#{company.downcase.gsub(/[^a-z0-9]+/, '_')}_#{role.downcase.gsub(/[^a-z0-9]+/, '_')}.md"
out_markdown_path = File.join(options[:out_dir], filename)

FileUtils.mkdir_p(options[:out_dir])

# Construct 30-second interview calibration script based on tier and company
calibration_script = <<~TEXT.strip
  "I specialize in high-consequence Ruby on Rails and distributed platforms where uptime, data integrity, and deep observability are non-negotiable. At OneMain Financial, I led the Acquisition architecture: mapping seven ingress channels, eliminating a 4% silent traffic drop at e-signing with OpenTelemetry distributed tracing, and safely purging legacy PII across 30+ database tables. #{company} needs calm, deterministic systems leadership for #{domain.downcase}, and my background is built specifically to de-risk those platforms."
TEXT

calibration_hook = <<~TEXT.strip
  "I can dive deeper into how we traced distributed state across Rails and backend gateways, or we can look at how we built the 5-phase database deletion engine. Which direction would you prefer to explore?"
TEXT

# Generate Markdown Content
markdown_content = <<~MARKDOWN
  # Executive Pitch Brief: #{company} (#{role})

  **Candidate:** Mike Hall (`Just3Ws`) · Principal Software Engineer  
  **Target Role:** #{role}  
  **Company:** #{company} (Remote, US)  
  **Core Domain:** #{domain}  
  #{"**Comp Range:** " + options[:comp_range] + "  " if options[:comp_range]}
  ---

  ## 🎯 Executive Summary & Mandate Alignment

  #{company}'s mission: **#{mandate}**: matches my 20+ year track record stabilizing high-consequence monoliths, deploying distributed OpenTelemetry, and isolating critical failure modes under live load.

  I bring calm, deterministic systems leadership to teams where platform reliability directly impacts business execution.

  ---

  ## 🏗️ Direct Architectural Match & Evidence

  ### 1. High-Consequence Platform Architecture & Modernization
  * **Acquisition Lane Architecture (OneMain Financial):** Appointed Software Architect for an acquisition engine processing hundreds of millions in financial throughput. Mapped seven heterogeneous ingress channels, refactored multi-step Rails state machines, and decoupled service boundaries between Acquisition and Originations.
  * **Database Archaeology & Safety:** Architected an automated 5-phase PII remediation deletion engine across 30+ tables, safely purging legacy orphan records under production traffic without table locks.
  * **Craftsmanship Foundations:** 20+ years of production Ruby on Rails expertise (2.x through 8.x), strict TDD discipline, and relational data modeling in PostgreSQL.

  ### 2. Deep Observability, Distributed Tracing & Incident Command
  * **Enterprise Trace Deployment:** Led the enterprise OpenTelemetry deployment across distributed Rails services, MuleSoft APIs, and Mainframe backends. Standardized W3C trace context headers to bridge siloed logs into causal event chains.
  * **Eliminating Silent Outages:** Partnered with Cybersecurity, SRE, and Incident Command to diagnose and eliminate a persistent multi-service defect that caused 4% silent traffic loss at late-stage document signing.
  * **Community Enablement:** Founded Geekfest@OMF and the weekly OpenTelemetry Working Group, scaling cross-lane participation to 40+ engineers before transitioning ongoing facilitation sustainably to SRE.

  ### 3. Agent Tooling, Telemetry & Developer Acceleration
  * **Local AI & Model Context Protocol (Agent Tooling):** Architected and operate three production MCP servers (`ctx-mcp`, `o2-mcp`, `llama-mcp`) exposing live system telemetry and local inference to agent runtimes with strict context budget management.
  * **Edge Telemetry & Privacy Filtering:** Built OTel telemetry ingestion pipelines with automated PII-scrubbing at the collector edge, enabling safe root-cause diagnosis for security investigations.

  ---

  ## 💬 30-Second Interview Calibration (The "Answer, Frame, and Pause" Rule)

  > *"#{calibration_script}"*
  > 
  > *(Pause & Hook): "#{calibration_hook}"*

  ---

  ## 🔗 Authoritative Verification Links
  * **System Cartography Essay:** [just3ws.com/2026/08/29/system-cartography-how-to-map-a-ten-year-old-monolith/](https://just3ws.com/2026/08/29/system-cartography-how-to-map-a-ten-year-old-monolith/)
  * **Portfolio & Case Studies:** [just3ws.com/case-studies/](https://just3ws.com/case-studies/)
  * **Canonical Résumé:** [just3ws.com/resume](https://just3ws.com/resume)
  * **GitHub Profile:** [github.com/just3ws](https://github.com/just3ws)
MARKDOWN

File.write(out_markdown_path, markdown_content)

# Trigger HTML generation if requested
if options[:generate_html]
  system("ruby #{File.join(ROOT_DIR, 'bin', 'generate_executive_brief_pages.rb')} > /dev/null 2>&1")
end

# Trigger PDF export if requested
if options[:generate_pdf]
  system("node #{File.join(ROOT_DIR, 'bin', 'export_brief_pdfs.js')} > /dev/null 2>&1")
end

html_slug = File.basename(out_markdown_path, ".md").downcase.gsub(/[^a-z0-9]+/, "-").gsub(/^-+|-+$/, "")
localhost_url = "https://just3ws.localhost/exports/briefs/#{html_slug}/"
public_url = "https://just3ws.com/briefs/#{html_slug}/"
pdf_path = "exports/briefs/pdfs/#{html_slug}-executive-brief-mike-hall.pdf"

cold_outreach_message = <<~MSG.strip
  Hi [Name],

  I saw #{company} is scaling #{domain} and looking for a #{role}.

  I specialize in high-consequence Ruby on Rails platforms and distributed architecture. Over the past several years, I served as Acquisition Lane Architect at OneMain Financial, decoupling lending funnels, eliminating a 4% silent transaction drop, and driving enterprise OpenTelemetry adoption across Rails and middleware tiers.

  I put together a focused 1-page technical brief mapping my background to your current engineering challenges:
  👉 #{public_url}

  If this aligns with what you need on the team, I would be glad to compare notes. If timing is off, no need to reply.

  Best,
  Mike Hall
  https://just3ws.com
MSG

warm_referral_message = <<~MSG.strip
  Hi [Name],

  Hope you are doing well! It has been a while, and it is great seeing what you are building at #{company}.

  I am exploring my next move into a #{role} / Platform Architecture role and noticed #{company} is expanding around #{domain}.

  Before submitting a cold application, I wanted to ask your take on the engineering culture and how the platform team approaches distributed scale.

  I put together a 1-page overview of my background here:
  👉 #{public_url}

  If you have five minutes for a quick asynchronous exchange, I would value your perspective. No worries at all if you are swamped.

  Best,
  Mike
MSG

if options[:json]
  puts JSON.pretty_generate({
    status: "ok",
    company: company,
    role: role,
    tier: tier,
    markdown_path: out_markdown_path,
    localhost_url: localhost_url,
    public_url: public_url,
    pdf_path: pdf_path,
    calibration_script: calibration_script,
    calibration_hook: calibration_hook,
    cold_outreach_message: cold_outreach_message,
    warm_referral_message: warm_referral_message
  })
else
  puts "✅ Generated Executive Pitch Brief:"
  puts "   • Markdown   : #{out_markdown_path}"
  puts "   • Localhost  : #{localhost_url}"
  puts "   • Public URL : #{public_url}"
  puts "   • PDF Export : #{pdf_path}" if options[:generate_pdf]
  puts "\n📨 Calibrated Cold Outreach Snippet:"
  puts "--------------------------------------------------"
  puts cold_outreach_message
  puts "--------------------------------------------------"
end
