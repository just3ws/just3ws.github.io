#!/usr/bin/env ruby
# frozen_string_literal: true

# Review aid for publishable content. It deliberately scans a small public
# surface manifest and never reads secrets, environment files, private
# handoffs, credentials, or arbitrary repository files.

require "json"
require "digest"
require "fileutils"
require "optparse"
require "pathname"
require "set"
require "time"

ROOT = ENV.fetch("PUBLIC_SURFACE_AUDIT_ROOT", File.expand_path("..", __dir__))
REPORT_DIR = ENV.fetch("PUBLIC_SURFACE_AUDIT_REPORT_DIR", File.join(ROOT, "tmp", "public-surface-audit"))
DECISIONS = %w[pending verify rewrite generalize recorded hold].freeze
SCAN_ROOTS = %w[_data _includes _layouts _posts _sass archive-atlas assets docs pages search timeline panoramic-view].freeze
SCAN_FILES = %w[index.html 404.html].freeze
ALLOWED_EXTENSIONS = %w[.html .htm .md .markdown .yml .yaml .json .scss .css .js].freeze
EXCLUDED_PARTS = Set.new(%w[.git .bundle node_modules vendor bundle tmp cache caches log logs coverage dist build private secrets credentials handoffs]).freeze
EXCLUDED_BASENAMES = Set.new(%w[.env .env.local .env.production AGENTS.md CLAUDE.md GEMINI.md]).freeze
EXCLUDED_EXTENSIONS = Set.new(%w[.key .pem .p12 .pfx .crt .cer .asc .secret .secrets .credential .credentials]).freeze
EXCLUDED_SOURCE_PATHS = %w[
  docs/agents
  docs/runbooks
  docs/mcp-setup-guide.md
  docs/career-datalake-and-mcp-guide.md
  docs/inter-tool-communication-protocol.md
  docs/executive-brief-generator-protocol.md
  docs/video-archive-platform-and-migration-inventory.md
  docs/witc-corpus.md
  docs/witc-temporal-timeline.md
].freeze
PUBLIC_ROOT_INTERNAL_FILES = %w[
  AGENTS.md Backlog.md CLAUDE.md CODEX.md CONTEXT.md GEMINI.md HUMAN.md
  mcp.json package.json package-lock.json playwright.config.js
].freeze
PUBLIC_INTERNAL_PREFIXES = %w[
  /backlog/
  /docs/agents/
  /docs/runbooks/
  /graphify-out/
  /src/
  /lib/
  /spec/
  /tests/
  /lake/
  /logs/
  /scratch/
].freeze

Detector = Struct.new(:id, :category, :risk, :confidence, :pattern, :explanation, keyword_init: true)
Finding = Struct.new(:detector, :path, :line, :snippet, keyword_init: true) do
  def id
    Digest::SHA256.hexdigest([path, line, detector.id].join("\0"))[0, 12]
  end
  def source_backed_transcript?
    path.start_with?("_data/transcripts/") || path.match?(%r{\A_site/(?:interviews|videos)/})
  end

  def quarantine?
    detector.category == "claim-boundary" && !source_backed_transcript?
  end

  def recorded_uncertainty?
    detector.category == "claim-boundary" && source_backed_transcript?
  end

  def to_h(decision: "pending")
    { "detector" => detector.id, "category" => detector.category,
      "risk" => detector.risk, "confidence" => detector.confidence,
      "id" => id, "path" => path, "line" => line, "source_ref" => "#{path}:#{line}",
      "snippet" => snippet, "decision" => decision,
      "explanation" => detector.explanation }
  end
end

DETECTORS = [
  Detector.new(id: "public-internal-surface", category: "operational-exposure", risk: "high", confidence: "high",
               pattern: nil,
               explanation: "Internal project instructions, task records, runtime configuration, and agent interfaces do not belong in a static public site. Exclude them from the build or replace them with a deliberately public document."),
  Detector.new(id: "quarantine-missing-robots", category: "publication-boundary", risk: "high", confidence: "high",
               pattern: nil,
               explanation: "A quarantined AI synthesis must carry noindex metadata. Without it, feeds, previews, and crawlers can treat exploratory material as canonical."),
  Detector.new(id: "credential-assignment", category: "credential", risk: "critical", confidence: "high",
               pattern: /(?:api[_-]?key|access[_-]?token|client[_-]?secret|private[_-]?key|password)\s*[:=]\s*["']?[^\s"']{8,}/i,
               explanation: "A credential-shaped assignment should never be public. Rotate it if real, then remove it from source and history."),
  Detector.new(id: "private-key-block", category: "credential", risk: "critical", confidence: "high",
               pattern: /-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----/,
               explanation: "A private key block is an immediate public exposure. Revoke or rotate it before editorial review."),
  Detector.new(id: "email-address", category: "personal-data", risk: "high", confidence: "high",
               pattern: /\b[A-Z0-9._%+\-]+@[A-Z0-9.\-]+\.[A-Z]{2,}\b/i,
               explanation: "Confirm this is an intentional public contact address, not a private person's address."),
  Detector.new(id: "phone-number", category: "personal-data", risk: "high", confidence: "medium",
               pattern: /(?<!\d)(?:\+?1[\s.-]?)?\(?\d{3}\)?[\s.-]\d{3}[\s.-]\d{4}(?!\d)/,
               explanation: "A phone number is directly identifying. Keep it only when it is an intentional public contact channel."),
  Detector.new(id: "financial-or-government-identifier", category: "personal-data", risk: "critical", confidence: "medium",
               pattern: /\b(?:SSN|social\s+security|MRN|medical\s+record\s+number)\b.{0,40}\b\d{3}[ -]\d{2}[ -]\d{4}\b|\b(?:account|routing|credit\s+card|tax\s+id|passport)\b.{0,40}\b\d{4,}\b/i,
               explanation: "A financial or government identifier requires immediate removal or verification against the public source."),
  Detector.new(id: "health-or-care-context", category: "private-context", risk: "high", confidence: "medium",
               pattern: /\b(?:diagnos(?:is|ed)|medical|hospital|NICU|pneumonia|treatment|medication|therapy|health\s+condition|patient|care\s+location)\b/i,
               explanation: "Health and care details may identify another person when combined with dates, places, or relationships."),
  Detector.new(id: "family-or-child-detail", category: "private-context", risk: "high", confidence: "medium",
               pattern: /\b(?:my\s+(?:son|daughter|child|children|spouse|wife|husband|partner|mother|father|mom|dad|mother-in-law|father-in-law)|newborn|infant|minor)\b/i,
               explanation: "Family and child details can become identifying in combination. Preserve the lesson while reducing particulars."),
  Detector.new(id: "private-workplace-detail", category: "workplace-context", risk: "high", confidence: "medium",
               pattern: /\b(?:confidential|non[- ]public|internal[- ]only|customer\s+(?:name|data|record)|production\s+(?:credential|password)|PIP|performance\s+improvement\s+plan|fired|terminated|laid\s+off)\b/i,
               explanation: "Private workplace circumstances or customer information need a factual, generalized treatment."),
  Detector.new(id: "uncertainty-or-recollection", category: "claim-boundary", risk: "medium", confidence: "high",
               pattern: /\b(?:I\s+(?:think|recall|remember)|if\s+I\s+recall|maybe|perhaps|I\s+can't\s+remember|not\s+sure|to\s+the\s+best\s+of\s+my\s+memory)\b/i,
               explanation: "This is not a privacy violation. Frame it as recollection or link surviving evidence instead of settled fact."),
  Detector.new(id: "identity-context", category: "identity-context", risk: "medium", confidence: "medium",
               pattern: /\b(?:autistic|autism|ADHD|AuDHD|neurodiverg(?:ent|ence)|impost(?:er|or)\s+syndrome|mental\s+health)\b/i,
               explanation: "Identity and health-adjacent language should match the author's intended level of disclosure and avoid implying diagnosis."),
  Detector.new(id: "local-or-private-url", category: "operational-exposure", risk: "medium", confidence: "high",
               pattern: %r{(?:https?://(?:localhost|127\.0\.0\.1|\[::1\])(?::\d+)?|/Users/[^\s)]+|/Volumes/[^\s)]+)},
               explanation: "A local path or development URL exposes private structure and should be replaced with a public route or general description.")
].freeze

def relative_path(path)
  Pathname.new(path).relative_path_from(Pathname.new(ROOT)).to_s
end

def eligible_file?(path)
  relative = relative_path(path)
  parts = relative.split(File::SEPARATOR)
  return false if EXCLUDED_SOURCE_PATHS.any? { |prefix| relative == prefix || relative.start_with?("#{prefix}/") }
  return false if parts.any? { |part| EXCLUDED_PARTS.include?(part) }
  return false if EXCLUDED_BASENAMES.include?(File.basename(path))
  return false if EXCLUDED_EXTENSIONS.include?(File.extname(path).downcase)
  ALLOWED_EXTENSIONS.include?(File.extname(path).downcase)
end

def public_files
  rooted = SCAN_ROOTS.flat_map { |root| Dir.glob(File.join(ROOT, root, "**", "*")).select { |path| File.file?(path) && eligible_file?(path) } }
  root_files = SCAN_FILES.map { |name| File.join(ROOT, name) }.select { |path| File.file?(path) && eligible_file?(path) }
  (rooted + root_files).uniq.sort
end

def redact(value)
  value
    .gsub(/\b[A-Z0-9._%+\-]+@[A-Z0-9.\-]+\.[A-Z]{2,}\b/i, "[email redacted]")
    .gsub(/(?<!\d)(?:\+?1[\s.-]?)?\(?\d{3}\)?[\s.-]\d{3}[\s.-]\d{4}(?!\d)/, "[phone redacted]")
    .gsub(/-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----.+?-----END (?:RSA |EC |OPENSSH )?PRIVATE KEY-----/m, "[private key redacted]")
    .gsub(%r{https?://(?:localhost|127\.0\.0\.1|\[::1\])(?::\d+)?}, "[local URL redacted]")
    .gsub(%r{/(?:Users|Volumes)/[^\s)\"']+}, "[local path redacted]")
    .gsub(/(?:api[_-]?key|access[_-]?token|client[_-]?secret|private[_-]?key|password)\s*[:=]\s*["']?[^\s"']{8,}/i) { |match| match.sub(/([:=]\s*["']?)[^\s"']+/, '\\1[secret redacted]') }
end

def audit(files)
  files.flat_map do |path|
    File.readlines(path, encoding: "UTF-8", invalid: :replace, undef: :replace, replace: "�").flat_map.with_index(1) do |line, line_number|
      DETECTORS.filter_map do |detector|
        next if detector.pattern.nil?
        next unless detector.pattern.match?(line)
        Finding.new(detector: detector, path: relative_path(path), line: line_number, snippet: redact(line.strip)[0, 180])
      end
    end
  end
end

def site_surface_findings
  site_root = File.join(ROOT, "_site")
  return [] unless Dir.exist?(site_root)

  findings = []
  PUBLIC_ROOT_INTERNAL_FILES.each do |basename|
    path = File.join(site_root, basename)
    next unless File.file?(path)
    findings << Finding.new(detector: DETECTORS.find { |detector| detector.id == "public-internal-surface" },
                            path: relative_path(path), line: 1, snippet: basename)
  end

  Dir.glob(File.join(site_root, "ai", "**", "index.html")).sort.each do |path|
    content = File.read(path, encoding: "UTF-8", invalid: :replace, undef: :replace, replace: "�")
    next if content.match?(/<meta\s+name=["']robots["']\s+content=["']noindex(?:,follow)?["']/i)
    findings << Finding.new(detector: DETECTORS.find { |detector| detector.id == "quarantine-missing-robots" },
                            path: relative_path(path), line: 1, snippet: "AI route is missing noindex metadata")
  end

  Dir.glob(File.join(site_root, "backlog", "**", "*")).select { |path| File.file?(path) }.first(100).each do |path|
    findings << Finding.new(detector: DETECTORS.find { |detector| detector.id == "public-internal-surface" },
                            path: relative_path(path), line: 1, snippet: "backlog route")
  end

  PUBLIC_INTERNAL_PREFIXES.each do |prefix|
    directory = File.join(site_root, prefix.delete_prefix("/").delete_suffix("/"))
    next unless Dir.exist?(directory)
    Dir.glob(File.join(directory, "**", "*")).select { |path| File.file?(path) }.first(100).each do |path|
      findings << Finding.new(detector: DETECTORS.find { |detector| detector.id == "public-internal-surface" },
                              path: relative_path(path), line: 1, snippet: "internal repository surface")
    end
  end
  findings
end

def load_decisions(report_dir)
  decisions_path = File.join(report_dir, "decisions.json")
  return {} unless File.file?(decisions_path)
  JSON.parse(File.read(decisions_path))
rescue JSON::ParserError
  {}
end

def write_reports(findings, files, decisions, report_dir)
  FileUtils.mkdir_p(report_dir)
  quarantine, remaining = findings.partition(&:quarantine?)
  recorded_uncertainty, review_findings = remaining.partition(&:recorded_uncertainty?)
  decorate = ->(items) { items.map { |finding| finding.to_h(decision: decisions.fetch(finding.id, "pending")) } }
  report = {
    "tool" => "audit_public_surface",
    "generated_at" => Time.now.utc.iso8601,
    "local_only" => true,
    "scanned_files" => files.size,
    "scan_roots" => SCAN_ROOTS,
    "built_site_checked" => Dir.exist?(File.join(ROOT, "_site")),
    "findings" => decorate.call(review_findings),
    "quarantine" => decorate.call(quarantine),
    "recorded_uncertainty" => decorate.call(recorded_uncertainty)
  }
  File.write(File.join(report_dir, "report.json"), JSON.pretty_generate(report) + "\n")
  File.write(File.join(report_dir, "decisions.json"), JSON.pretty_generate(decisions) + "\n") unless File.file?(File.join(report_dir, "decisions.json"))
  File.write(File.join(report_dir, "README.md"), <<~MARKDOWN)
    # Local public-surface review queue

    This report is local-only and ignored by git. It is not a publication
    surface. Review each item using its redacted excerpt and source reference.

    Record a decision with:

    `ruby bin/audit_public_surface.rb --decide ID=DECISION`

    Decisions: `pending`, `verify`, `rewrite`, `generalize`, `recorded`, `hold`.
    The strict gate remains blocked by `pending`, `verify`, and `hold` for high
    risk findings or quarantine. `rewrite`, `generalize`, and `recorded` mean
    the public-safe action has been completed and documented.

    The site pass also checks the built `_site` boundary for internal root files,
    public backlog material, and AI routes missing `noindex` metadata.
  MARKDOWN
  report
end

def render_text(findings, files, decisions, verbose: false)
  puts "Public surface oversharing audit"
  puts "Scanned #{files.size} files from #{SCAN_ROOTS.join(', ')}"
  puts "Excluded secrets, environment files, private handoffs, credentials, VCS, dependencies, caches, and build trees."
  puts "Built-site boundary checks: internal files, backlog routes, and quarantine metadata."
  puts
  quarantine, remaining = findings.partition(&:quarantine?)
  recorded_uncertainty, review_findings = remaining.partition(&:recorded_uncertainty?)
  if findings.empty?
    puts "No review candidates detected. This is not a guarantee that the public surface is risk-free."
    return
  end
  review_findings.group_by { |finding| finding.detector.risk }.each do |risk, group|
    puts "#{risk.upcase} (#{group.size})"
    group.group_by { |finding| finding.detector.id }.sort_by { |_, items| -items.size }.each do |detector_id, items|
      detector = items.first.detector
      puts "  #{items.size} #{detector_id} [#{detector.category}/#{detector.confidence}]"
      puts "    Review: #{detector.explanation}"
      items.first(verbose ? items.size : 3).each do |finding|
        puts "    - #{finding.id} #{finding.path}:#{finding.line} [#{decisions.fetch(finding.id, "pending")}] #{finding.snippet}"
      end
      puts "    ... #{items.size - [items.size, verbose ? items.size : 3].min} more" if !verbose && items.size > 3
    end
    puts
  end

  if quarantine.any?
    puts "QUARANTINE (#{quarantine.size})"
    puts "  These passages contain uncertainty markers. Verify the source, rewrite as recollection, or hold them from publication."
    quarantine.first(verbose ? quarantine.size : 10).each do |finding|
      puts "  - #{finding.id} #{finding.path}:#{finding.line} [#{decisions.fetch(finding.id, "pending")}] #{finding.snippet}"
    end
    puts "  ... #{quarantine.size - [quarantine.size, verbose ? quarantine.size : 10].min} more" if !verbose && quarantine.size > 10
  end

  return if recorded_uncertainty.empty?

  puts "RECORDED UNCERTAINTY (#{recorded_uncertainty.size})"
  puts "  These markers occur in source-backed transcript material. Preserve the wording, but do not restate it as verified certainty."
  recorded_uncertainty.first(verbose ? recorded_uncertainty.size : 10).each do |finding|
    puts "  - #{finding.id} #{finding.path}:#{finding.line} [#{decisions.fetch(finding.id, "pending")}] #{finding.snippet}"
  end
  puts "  ... #{recorded_uncertainty.size - [recorded_uncertainty.size, verbose ? recorded_uncertainty.size : 10].min} more" if !verbose && recorded_uncertainty.size > 10
end

options = { format: "text", verbose: false, strict: false, report_dir: REPORT_DIR, decide: nil }
OptionParser.new do |parser|
  parser.banner = "Usage: ruby bin/audit_public_surface.rb [options]"
  parser.on("--json", "Emit a redacted JSON report") { options[:format] = "json" }
  parser.on("--verbose", "Print every redacted finding in text mode") { options[:verbose] = true }
  parser.on("--strict", "Fail on high-risk findings or quarantined recollections") { options[:strict] = true }
  parser.on("--report-dir PATH", "Write local reports under PATH") { |path| options[:report_dir] = path }
  parser.on("--man", "Print the manual page when available") do
    man = File.expand_path("../man/man1/audit-public-surface.1", __dir__)
    exec("man", man) if File.file?(man) && ENV["TERM"]
    puts "See man/man1/audit-public-surface.1"
    exit 0
  end
  parser.on("--completion SHELL", %w[zsh bash], "Print shell completion definitions") do |shell|
    completion = File.expand_path("../completions/audit_public_surface.#{shell}", __dir__)
    abort "No completion definition found for #{shell}" unless File.file?(completion)
    puts File.read(completion)
    exit 0
  end
  parser.on("--decide ID=DECISION", "Record a local review decision") { |value| options[:decide] = value }
  parser.on("--help", "Show help") { puts parser; exit 0 }
end.parse!

files = public_files
findings = audit(files) + site_surface_findings
report_dir = options[:report_dir]
decisions = load_decisions(report_dir)
if options[:decide]
  id, decision = options[:decide].split("=", 2)
  abort "Decision must be one of: #{DECISIONS.join(", ")}" unless DECISIONS.include?(decision)
  finding = findings.find { |candidate| candidate.id == id }
  abort "Unknown finding ID #{id}. Generate the report first and use an ID from #{File.join(report_dir, "report.json")}." unless finding
  decisions[id] = { "decision" => decision, "decided_at" => Time.now.utc.iso8601 }
  FileUtils.mkdir_p(report_dir)
  File.write(File.join(report_dir, "decisions.json"), JSON.pretty_generate(decisions) + "\n")
end
report = write_reports(findings, files, decisions, report_dir)
if options[:format] == "json"
  puts JSON.pretty_generate(report)
else
  render_text(findings, files, decisions, verbose: options[:verbose])
end

# Critical findings always fail. Strict publication checks also fail on high
# risk findings and quarantine, because neither privacy nor evidence review is
# safely inferable from pattern matching alone.
fails = findings.any? { |finding| finding.detector.risk == "critical" }
blocking = findings.select { |finding| finding.detector.risk == "high" || finding.quarantine? }
blocking_unresolved = blocking.any? do |finding|
  decision = decisions.dig(finding.id, "decision") || "pending"
  !%w[rewrite generalize recorded].include?(decision)
end
fails ||= options[:strict] && blocking_unresolved
exit(fails ? 1 : 0)
