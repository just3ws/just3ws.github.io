#!/usr/bin/env ruby
# frozen_string_literal: true

# ---
# name: build_publications.rb
# domain: data
# purpose: Compile Typst + Pandoc monograph (PDF/EPUB) and deterministic Typst resume PDF
# usage: ruby bin/build_publications.rb
# ---

require "fileutils"
require "open3"
require "tmpdir"
require "yaml"

ROOT = File.expand_path("..", __dir__)
EXPORTS_DIR = File.join(ROOT, "exports")
RESUMES_DIR = File.join(EXPORTS_DIR, "resumes")
TEMPLATES_DIR = File.join(ROOT, "src", "templates")

FileUtils.mkdir_p(RESUMES_DIR)

def run_cmd(*cmd)
  stdout, stderr, status = Open3.capture3(*cmd)
  return if status.success?

  warn "Command failed: #{cmd.join(' ')}"
  warn stderr unless stderr.empty?
  warn stdout unless stdout.empty?
  exit status.exitstatus
end

# 1. Extract clean Markdown from chicago-craftsmanship/index.html via Pandoc,
#    then compile to both Typst PDF and EPUB monograph.
monograph_html = File.join(ROOT, "chicago-craftsmanship", "index.html")
raw_html = File.read(monograph_html).sub(/\A---\s*\n.*?\n---\s*\n/m, "")
# Strip Liquid includes and nav link bar for clean monograph print/ebook body
clean_html = raw_html
             .gsub(/\{%.*?%\}/m, "")
             .gsub(/<!-- Archival Media Links Bar -->.*?\z/m, "</article>")

Dir.mktmpdir("just3ws-pubs") do |tmp|
  monograph_src = File.join(tmp, "chicago-craftsmanship.html")
  File.write(monograph_src, clean_html)

  pdf_out = File.join(EXPORTS_DIR, "chicago-craftsmanship-monograph.pdf")
  epub_out = File.join(EXPORTS_DIR, "chicago-craftsmanship-monograph.epub")

  puts "[typst+pandoc] chicago-craftsmanship -> exports/chicago-craftsmanship-monograph.pdf"
  run_cmd(
    "pandoc", monograph_src,
    "--from=html",
    "--pdf-engine=typst",
    "--template=#{File.join(TEMPLATES_DIR, 'monograph.typ')}",
    "-o", pdf_out
  )

  puts "[pandoc] chicago-craftsmanship -> exports/chicago-craftsmanship-monograph.epub"
  run_cmd(
    "pandoc", monograph_src,
    "--from=html",
    "--to=epub3",
    "--metadata=title:The Chicago Software Craftsmanship Movement (2006-2015)",
    "--metadata=author:Mike Hall",
    "--metadata=lang:en-US",
    "-o", epub_out
  )

  # 2. Compile canonical exports/resume.md to deterministic Typst PDF (no Chromium)
  resume_md = File.join(EXPORTS_DIR, "resume.md")
  if File.exist?(resume_md)
    resume_body = File.read(resume_md).sub(/\A---\s*\n.*?\n---\s*\n/m, "")
    resume_src = File.join(tmp, "resume.md")
    File.write(resume_src, resume_body)

    resume_pdf = File.join(RESUMES_DIR, "mike-hall-resume-typst.pdf")
    puts "[typst+pandoc] exports/resume.md -> exports/resumes/mike-hall-resume-typst.pdf"
    run_cmd(
      "pandoc", resume_src,
      "--from=gfm",
      "--pdf-engine=typst",
      "--template=#{File.join(TEMPLATES_DIR, 'resume.typ')}",
      "-o", resume_pdf
    )
  end

  # 3. Compile the 4-part Geekfest@OMF series into a combined Field Guide (PDF + EPUB)
  gf_posts = Dir[File.join(ROOT, "_posts", "2026-11-27-geekfest-at-omf-part-*.md")].sort
  if gf_posts.any?
    combined = [
      "# Geekfest@OMF: Building a Grassroots Enterprise Engineering Community",
      "",
      "**Author:** Mike Hall (Staff Software Engineer) · **Canonical Archive:** https://www.just3ws.com/",
      "",
      "A four-part field guide documenting how Obtiva's Tuesday study tradition inspired a weekly enterprise peer-learning forum, grew into an OpenTelemetry Community of Practice across six lanes, and transitioned cleanly to funded full-time stewardship.",
      ""
    ]
    gf_posts.each do |post_path|
      raw = File.read(post_path)
      title = raw[/^title:\s*"?([^"\n]+)"?/, 1] || File.basename(post_path, ".md")
      body = raw.sub(/\A---\s*\n.*?\n---\s*\n/m, "")
                .gsub(/```mermaid.*?```/m, "")
                .gsub(/## Series Navigation.*\z/m, "")
      combined << "## #{title}"
      combined << ""
      combined << body.strip
      combined << ""
    end

    gf_src = File.join(tmp, "geekfest-field-guide.md")
    File.write(gf_src, combined.join("\n"))

    gf_pdf = File.join(EXPORTS_DIR, "geekfest-at-omf-field-guide.pdf")
    gf_epub = File.join(EXPORTS_DIR, "geekfest-at-omf-field-guide.epub")

    puts "[typst+pandoc] Geekfest@OMF 4-part series -> exports/geekfest-at-omf-field-guide.pdf"
    run_cmd(
      "pandoc", gf_src,
      "--from=gfm",
      "--pdf-engine=typst",
      "--template=#{File.join(TEMPLATES_DIR, 'monograph.typ')}",
      "-o", gf_pdf
    )

    puts "[pandoc] Geekfest@OMF 4-part series -> exports/geekfest-at-omf-field-guide.epub"
    run_cmd(
      "pandoc", gf_src,
      "--from=gfm",
      "--to=epub3",
      "--metadata=title:Geekfest@OMF: Building a Grassroots Enterprise Engineering Community",
      "--metadata=author:Mike Hall",
      "--metadata=lang:en-US",
      "-o", gf_epub
    )
  end

  # 4. Compile Panoramic View Field Manual (PDF + EPUB) from _data/panoramic_view.yml
  pv_path = File.join(ROOT, "_data", "panoramic_view.yml")
  if File.exist?(pv_path)
    pv = YAML.safe_load_file(pv_path)
    pv_md = [
      "# Panoramic View: System Cartography Field Manual",
      "",
      "**Author:** Mike Hall (Staff Software Engineer) · **Canonical Route:** https://www.just3ws.com/panoramic-view/",
      "",
      pv.dig("meta", "lede").to_s,
      "",
      pv.dig("meta", "scope").to_s,
      "",
      "## Origin & Flagship Context",
      "",
      pv.dig("meta", "origin").to_s,
      "",
      "**#{pv.dig('flagship_context', 'title')}** #{pv.dig('flagship_context', 'text')}",
      "",
      "## Three Accounts of One System",
      ""
    ]
    Array(pv.dig("reconciliation", "models")).each do |m|
      pv_md << "- **#{m['name']}:** #{m['text']}"
    end
    pv_md << ""
    pv_md << pv.dig("reconciliation", "delta").to_s
    pv_md << ""
    pv_md << "## The Four Dimensions"
    pv_md << ""
    Array(pv["dimensions"]).each do |d|
      pv_md << "- **#{d['name']} (#{d['label']}):** #{d['summary']}"
    end
    pv_md << ""
    pv_md << "## The 5-Step Discovery Loop"
    pv_md << ""
    Array(pv["discovery_loop"]).each_with_index do |step, idx|
      pv_md << "#{idx + 1}. **#{step['title']}:** #{step['text']}"
    end
    pv_md << ""
    pv_md << "## One Method, Four Proof Terrains"
    pv_md << ""
    pv_md << "- **OneMain Financial (Enterprise Legacy Lending):** Mapped 7 acquisition funnels end-to-end from browser through Rails and MuleSoft to IBM z/OS mainframe; eliminated a 4% silent e-sign cookie overflow via zero-downtime DynamoDB migration; engineered a 5-phase PII purge across 30+ tables."
    pv_md << "- **media-pipeline (Autonomous Media Ops):** 11-checkpoint synthetic tracer, OMG BPMN 2.0 subprocess orchestration, explicit failure offramps, and honest calibration snapshots."
    pv_md << "- **Phalanx Duel (Deterministic Game Engine):** Living architecture with 12 wiki diagrams, a Groma C4 explorer, and automated freshness gates synchronized to production TypeScript and Go code."
    pv_md << "- **zdots & just3ws.com (Personal Control Plane & Archive):** Observable Zsh control plane (founded May 2017) serving as the root platform for Panoramic View Labs (PVL), paired with adots, vdots, and a 185-interview oral history datalake."
    pv_md << ""
    pv_md << "## Field Vocabulary"
    pv_md << ""
    Array(pv.dig("vocabulary", "mappings")).each do |v|
      pv_md << "- **#{v['plain']}** (*#{v['related']}*): #{v['meaning']}"
    end

    pv_src = File.join(tmp, "panoramic-view-field-manual.md")
    File.write(pv_src, pv_md.join("\n") + "\n")

    pv_pdf = File.join(EXPORTS_DIR, "panoramic-view-field-manual.pdf")
    pv_epub = File.join(EXPORTS_DIR, "panoramic-view-field-manual.epub")

    puts "[typst+pandoc] _data/panoramic_view.yml -> exports/panoramic-view-field-manual.pdf"
    run_cmd(
      "pandoc", pv_src,
      "--from=gfm",
      "--pdf-engine=typst",
      "--template=#{File.join(TEMPLATES_DIR, 'monograph.typ')}",
      "-o", pv_pdf
    )

    puts "[pandoc] _data/panoramic_view.yml -> exports/panoramic-view-field-manual.epub"
    run_cmd(
      "pandoc", pv_src,
      "--from=gfm",
      "--to=epub3",
      "--metadata=title:Panoramic View: System Cartography Field Manual",
      "--metadata=author:Mike Hall",
      "--metadata=lang:en-US",
      "-o", pv_epub
    )
  end
end

puts "Built Typst + Pandoc monographs (Chicago Craftsmanship, Geekfest@OMF, Panoramic View Field Manual) and Typst resume PDF."
