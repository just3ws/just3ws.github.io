#!/usr/bin/env ruby
# frozen_string_literal: true

# ---
# name: verify_panoramic_conformance.rb
# domain: validate
# purpose: Run deterministic mathematical proofs over formalized Panoramic View seams and emit JSON proof ledger
# usage: ruby bin/verify_panoramic_conformance.rb
# ---

require "fileutils"
require "json"
require_relative "../src/panoramic_view/conformance"

ROOT = File.expand_path("..", __dir__)
OUT_PATH = File.join(ROOT, "assets", "data", "panoramic_conformance_proof.json")
FileUtils.mkdir_p(File.dirname(OUT_PATH))

pii_dag = PanoramicView::Conformance.verify_dag(
  nodes: %w[clarity_orphans underwriting_orphans credit_pulls document_artifacts applications applicants],
  edges: [
    %w[clarity_orphans credit_pulls],
    %w[underwriting_orphans document_artifacts],
    %w[credit_pulls applications],
    %w[document_artifacts applications],
    %w[applications applicants]
  ]
)

disbursement_fsm = PanoramicView::Conformance.verify_fsm(
  states: %w[TERMS_SIGNED FUNDS_RESERVED PUSH_IN_FLIGHT SETTLEMENT_PENDING_RECOVERY DISBURSED_SETTLED],
  initial: "TERMS_SIGNED",
  terminals: ["DISBURSED_SETTLED"],
  transitions: {
    "TERMS_SIGNED" => ["FUNDS_RESERVED"],
    "FUNDS_RESERVED" => ["PUSH_IN_FLIGHT"],
    "PUSH_IN_FLIGHT" => %w[DISBURSED_SETTLED SETTLEMENT_PENDING_RECOVERY],
    "SETTLEMENT_PENDING_RECOVERY" => ["DISBURSED_SETTLED"],
    "DISBURSED_SETTLED" => []
  }
)

media_trace = PanoramicView::Conformance.check_trace_conformance(
  spec_edges: [
    %w[staged pending],
    %w[pending processing],
    %w[processing enriched],
    %w[enriched published],
    %w[published archived]
  ],
  observed_sequence: %w[staged pending processing enriched published archived]
)

payload = {
  schema: "panoramic-view-conformance-proof.v1",
  epistemic_boundary: "Proves mathematical properties over formalized seams (DAGs, FSMs, trace conformance). Human mental models remain empirically falsifiable.",
  proofs: {
    pii_purge_fk_dag: pii_dag,
    instant_money_disbursement_fsm: disbursement_fsm,
    media_pipeline_trace_conformance: media_trace
  }
}

all_proved = pii_dag[:proved] && disbursement_fsm[:proved] && media_trace[:conformant]
payload[:all_proved] = all_proved
payload[:sha256_digest] = PanoramicView::Conformance.digest_record(payload[:proofs])

File.write(OUT_PATH, JSON.pretty_generate(payload) + "\n")

unless all_proved
  warn "Panoramic View formal conformance verification FAILED."
  exit 1
end

puts "Panoramic View formal conformance verified (all_proved=true, sha256=#{payload[:sha256_digest][0..15]}...)"
