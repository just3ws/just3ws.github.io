# frozen_string_literal: true

require "json"
require "fileutils"
require "open3"
require "spec_helper"

RSpec.describe "audit_public_surface" do
  let(:command) { ["ruby", File.expand_path("../../bin/audit_public_surface.rb", __dir__)] }

  it "emits a redacted, structured report" do
    Dir.mktmpdir("public-surface-structured") do |root|
      FileUtils.mkdir_p(File.join(root, "_posts"))
      File.write(File.join(root, "_posts", "fixture.md"), "A safe historical note.\n")
      output, status = Open3.capture2e({ "PUBLIC_SURFACE_AUDIT_ROOT" => root }, *command, "--json")
      expect(status.exitstatus).to eq(0)
      report = JSON.parse(output)
      expect(report.fetch("scanned_files")).to be > 0
      expect(report).to include("findings", "quarantine", "recorded_uncertainty")
      expect(File).to exist(File.join(root, "tmp", "public-surface-audit", "report.json"))
      expect(File).to exist(File.join(root, "tmp", "public-surface-audit", "README.md"))
    end
  end

  it "does not report excluded private paths" do
    Dir.mktmpdir("public-surface-exclusions") do |root|
      FileUtils.mkdir_p(File.join(root, "_posts"))
      FileUtils.mkdir_p(File.join(root, "handoffs"))
      File.write(File.join(root, "_posts", "fixture.md"), "A safe historical note.\n")
      File.write(File.join(root, "handoffs", "private.md"), "password: fake-private-value\n")
      output, status = Open3.capture2e({ "PUBLIC_SURFACE_AUDIT_ROOT" => root }, *command, "--json")
      expect(status.exitstatus).to eq(0)
      paths = JSON.parse(output).fetch("findings").map { |finding| finding.fetch("path") }
      expect(paths.none? { |path| path.match?(%r{(?:\.env|handoff|secret|credential|AGENTS\.md|CLAUDE\.md)}) }).to be(true)
    end
  end

  it "detects and redacts credential and personal-data fixtures" do
    Dir.mktmpdir("public-surface-audit") do |root|
      FileUtils.mkdir_p(File.join(root, "_posts"))
      File.write(File.join(root, "_posts", "fixture.md"), <<~MARKDOWN)
        ---
        title: Safe historical fixture
        ---
        I think this recollection needs review.
        Contact fixture.person@example.test.
        password: fake-public-fixture-value
      MARKDOWN

      output, status = Open3.capture2e({ "PUBLIC_SURFACE_AUDIT_ROOT" => root }, *command, "--json")
      expect(status.exitstatus).to eq(1)
      report = JSON.parse(output)
      findings = report.fetch("findings")
      expect(findings.map { |finding| finding.fetch("detector") }).to include("credential-assignment", "email-address")
      expect(report.fetch("quarantine").map { |finding| finding.fetch("detector") }).to include("uncertainty-or-recollection")
      expect(findings.all? { |finding| !finding.fetch("snippet").include?("fake-public-fixture-value") }).to be(true)
      expect(findings.all? { |finding| !finding.fetch("snippet").include?("fixture.person@example.test") }).to be(true)
    end
  end

  it "places uncertain historical language in quarantine" do
    Dir.mktmpdir("public-surface-quarantine") do |root|
      FileUtils.mkdir_p(File.join(root, "_posts"))
      File.write(File.join(root, "_posts", "fixture.md"), "I think this date is approximate, based on memory.\n")

      output, status = Open3.capture2e({ "PUBLIC_SURFACE_AUDIT_ROOT" => root }, *command, "--json")
      expect(status.exitstatus).to eq(0)
      report = JSON.parse(output)
      expect(report.fetch("findings")).to be_empty
      expect(report.fetch("quarantine").map { |finding| finding.fetch("detector") }).to include("uncertainty-or-recollection")
    end
  end

  it "fails the strict gate when quarantine is present" do
    Dir.mktmpdir("public-surface-strict") do |root|
      FileUtils.mkdir_p(File.join(root, "_posts"))
      File.write(File.join(root, "_posts", "fixture.md"), "Maybe this date is approximate.\n")

      _output, status = Open3.capture2e({ "PUBLIC_SURFACE_AUDIT_ROOT" => root }, *command, "--strict", "--json")
      expect(status.exitstatus).to eq(1)
    end
  end

  it "treats uncertainty inside a source-backed transcript as recorded speech" do
    Dir.mktmpdir("public-surface-transcript") do |root|
      FileUtils.mkdir_p(File.join(root, "_data", "transcripts"))
      File.write(File.join(root, "_data", "transcripts", "recorded.yml"), "text: I think that was the date.\n")

      output, status = Open3.capture2e({ "PUBLIC_SURFACE_AUDIT_ROOT" => root }, *command, "--json")
      expect(status.exitstatus).to eq(0)
      report = JSON.parse(output)
      expect(report.fetch("quarantine")).to be_empty
      expect(report.fetch("findings")).to be_empty
      expect(report.fetch("recorded_uncertainty").map { |finding| finding.fetch("detector") }).to include("uncertainty-or-recollection")
    end
  end

  it "detects internal files and missing quarantine metadata in the built site" do
    Dir.mktmpdir("public-surface-site") do |root|
      FileUtils.mkdir_p(File.join(root, "_posts"))
      FileUtils.mkdir_p(File.join(root, "_site", "ai", "2026", "01", "01", "example"))
      FileUtils.mkdir_p(File.join(root, "_site", "backlog"))
      File.write(File.join(root, "_site", "CONTEXT.md"), "private build context\n")
      File.write(File.join(root, "_site", "ai", "2026", "01", "01", "example", "index.html"), "<html></html>\n")
      File.write(File.join(root, "_site", "backlog", "task.html"), "internal task\n")

      output, status = Open3.capture2e({ "PUBLIC_SURFACE_AUDIT_ROOT" => root }, *command, "--strict", "--json")
      expect(status.exitstatus).to eq(1)
      report = JSON.parse(output)
      detectors = report.fetch("findings").map { |finding| finding.fetch("detector") }
      expect(detectors).to include("public-internal-surface", "quarantine-missing-robots")
    end
  end

  it "uses a recorded decision to clear a strict high-risk finding" do
    Dir.mktmpdir("public-surface-decision") do |root|
      FileUtils.mkdir_p(File.join(root, "_posts"))
      File.write(File.join(root, "_posts", "fixture.md"), "Contact fixture.person@example.test.\n")
      environment = { "PUBLIC_SURFACE_AUDIT_ROOT" => root }

      output, status = Open3.capture2e(environment, *command, "--json")
      expect(status.exitstatus).to eq(0)
      finding_id = JSON.parse(output).fetch("findings").find { |finding| finding.fetch("detector") == "email-address" }.fetch("id")

      _output, decision_status = Open3.capture2e(environment, *command, "--strict", "--decide", "#{finding_id}=recorded", "--json")
      expect(decision_status.exitstatus).to eq(0)
      decisions = JSON.parse(File.read(File.join(root, "tmp", "public-surface-audit", "decisions.json")))
      expect(decisions.dig(finding_id, "decision")).to eq("recorded")
    end
  end
end
