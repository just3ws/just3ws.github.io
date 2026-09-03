# frozen_string_literal: true

require "json"
require "fileutils"
require "open3"
require "tmpdir"

RSpec.describe "WITC corpus tooling" do
  ROOT = File.expand_path("../..", __dir__)
  BUILDER = File.join(ROOT, "bin", "build_witc_corpus.rb")
  QUERY = File.join(ROOT, "bin", "query_witc_corpus.rb")

  it "builds a bounded searchable corpus with provenance and excludes credential-like files" do
    Dir.mktmpdir("witc-fixture") do |dir|
      FileUtils.mkdir_p(File.join(dir, "project", ".git"))
      FileUtils.mkdir_p(File.join(dir, "project", "cache"))
      File.write(File.join(dir, "project", "notes.md"), "UGtastic organizer perspective\n")
      File.write(File.join(dir, "project", "duplicate.txt"), "same evidence\n")
      File.write(File.join(dir, "project", "copy.txt"), "same evidence\n")
      File.write(File.join(dir, "project", ".env"), "DO_NOT_INDEX=secret\n")
      File.write(File.join(dir, "project", "cache", "ignored.md"), "DO_NOT_INDEX\n")
      db_path = File.join(dir, "corpus.db")
      # Keep the environment-cleanliness assertion while loading the locked
      # project dependencies. A bare Ruby process finds sqlite3 on developer
      # machines with a global gem, but not on the GitHub Actions runner.
      clean_ruby = ["env", "-i", "PATH=#{ENV.fetch('PATH')}", "HOME=#{ENV.fetch('HOME')}", "bundle", "exec", "ruby"]
      output, status = Open3.capture2(*clean_ruby, BUILDER, "--source", dir, "--output", db_path, "--apply")
      expect(status).to be_success
      expect(output).to include('"scanned_records": 3')
      query, query_status = Open3.capture2(*clean_ruby, QUERY, "--db", db_path, "--search", "organizer perspective", "--limit", "5", "--json")
      expect(query_status).to be_success
      result = JSON.parse(query)
      expect(result["count"]).to eq(1)
      expect(result.dig("records", 0, "source_path")).to eq("project/notes.md")
      expect(result.dig("records", 0, "sha256")).to match(/\A[0-9a-f]{64}\z/)
    end
  end
end
