# frozen_string_literal: true

require "json"
require "open3"

RSpec.describe "knowledge graph audit" do
  it "reports structural integrity and coverage gaps without external services" do
    stdout, stderr, status = Open3.capture3("ruby", "bin/audit_knowledge_graph.rb")
    expect(status).to be_success, stderr
    expect(stdout).to include("Knowledge graph audit: ok")

    report = JSON.parse(File.read("_data/knowledge_graph_audit.json"))
    expect(report.fetch("schema_version")).to eq("knowledge-graph-audit.v1")
    expect(report.fetch("node_count")).to be > 0
    expect(report.fetch("edge_count")).to be > 0
    expect(report.fetch("duplicate_node_ids")).to be_empty
    expect(report.fetch("missing_edge_endpoints")).to be_empty
    expect(report.fetch("coverage_gaps")).to include("Post", "Position", "Case Study")
  end
end
