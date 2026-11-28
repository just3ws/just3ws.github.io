#!/usr/bin/env ruby
# frozen_string_literal: true

# ---
# name: verify_smt_proofs.rb
# domain: validate
# purpose: Machine-check Panoramic View SMT-LIB 2 formal proofs via Z3 and emit proof certificate
# usage: ruby bin/verify_smt_proofs.rb
# ---

require "digest"
require "fileutils"
require "json"
require "open3"

ROOT = File.expand_path("..", __dir__)
SMT_PATH = File.join(ROOT, "src", "panoramic_view", "proofs.smt2")
CERT_PATH = File.join(ROOT, "assets", "data", "panoramic_z3_proof_certificate.json")
FileUtils.mkdir_p(File.dirname(CERT_PATH))

z3_ver, _, ver_status = Open3.capture3("z3", "--version")
abort "z3 theorem prover not found on PATH" unless ver_status.success?

stdout, stderr, status = Open3.capture3("z3", SMT_PATH)
unless status.success?
  warn "z3 failed: #{stderr}"
  exit status.exitstatus
end

lines = stdout.lines.map(&:strip).reject(&:empty?)
results = {}
lines.each_slice(2) do |label, verdict|
  key = label.delete_suffix(":")
  results[key] = {
    refutation_verdict: verdict,
    proved: verdict == "unsat"
  }
end

expected_keys = %w[
  THEOREM_1_DAG_STRICT_ORDER
  THEOREM_2A_FSM_STRICT_TERMINATION
  THEOREM_2B_ZERO_DUPLICATE_PAYOUT_INDUCTIVE
  THEOREM_3_CONFORMANCE_EQUIVALENCE
]

all_proved = expected_keys.all? { |k| results.dig(k, :proved) == true }

certificate = {
  schema: "panoramic-view-z3-certificate.v1",
  prover: z3_ver.strip,
  proof_source: "src/panoramic_view/proofs.smt2",
  proof_source_sha256: Digest::SHA256.file(SMT_PATH).hexdigest,
  verification_command: "z3 src/panoramic_view/proofs.smt2",
  all_theorems_proved: all_proved,
  theorems: results
}

File.write(CERT_PATH, JSON.pretty_generate(certificate) + "\n")

unless all_proved
  warn "Z3 formal proof verification FAILED: #{results.inspect}"
  exit 1
end

puts "Z3 formal proof certificate verified (4/4 theorems unsat, prover=#{z3_ver.strip})"
