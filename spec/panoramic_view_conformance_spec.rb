# frozen_string_literal: true

require_relative "../src/panoramic_view/conformance"

RSpec.describe PanoramicView::Conformance do
  describe ".verify_dag" do
    it "proves an inverted foreign-key deletion graph is acyclic with valid leaf-to-root order" do
      nodes = %w[clarity_orphans underwriting_orphans credit_pulls document_artifacts applications applicants]
      edges = [
        %w[clarity_orphans credit_pulls],
        %w[underwriting_orphans document_artifacts],
        %w[credit_pulls applications],
        %w[document_artifacts applications],
        %w[applications applicants]
      ]

      result = described_class.verify_dag(nodes: nodes, edges: edges)
      expect(result[:proved]).to be(true)
      expect(result[:cycle_witnesses]).to be_empty
      expect(result[:order].index("clarity_orphans")).to be < result[:order].index("applications")
      expect(result[:order].index("applications")).to be < result[:order].index("applicants")
    end

    it "falsifies a cyclic foreign-key graph and emits the exact cycle witness" do
      nodes = %w[table_a table_b table_c]
      edges = [%w[table_a table_b], %w[table_b table_c], %w[table_c table_a]]

      result = described_class.verify_dag(nodes: nodes, edges: edges)
      expect(result[:proved]).to be(false)
      expect(result[:cycle_witnesses].flatten).to contain_exactly("table_a", "table_b", "table_c")
    end
  end

  describe ".verify_fsm" do
    it "proves the Instant Money two-phase disbursement state gate is reachable and deadlock-free" do
      states = %w[TERMS_SIGNED FUNDS_RESERVED PUSH_IN_FLIGHT SETTLEMENT_PENDING_RECOVERY DISBURSED_SETTLED]
      transitions = {
        "TERMS_SIGNED" => ["FUNDS_RESERVED"],
        "FUNDS_RESERVED" => ["PUSH_IN_FLIGHT"],
        "PUSH_IN_FLIGHT" => %w[DISBURSED_SETTLED SETTLEMENT_PENDING_RECOVERY],
        "SETTLEMENT_PENDING_RECOVERY" => ["DISBURSED_SETTLED"],
        "DISBURSED_SETTLED" => []
      }

      result = described_class.verify_fsm(
        states: states,
        initial: "TERMS_SIGNED",
        terminals: ["DISBURSED_SETTLED"],
        transitions: transitions
      )

      expect(result[:proved]).to be(true)
      expect(result[:unreachable_states]).to be_empty
      expect(result[:deadlock_states]).to be_empty
    end

    it "detects unreachable states and non-terminating deadlocks" do
      states = %w[START ACTIVE STUCK ORPHAN DONE]
      transitions = {
        "START" => %w[ACTIVE STUCK],
        "ACTIVE" => ["DONE"],
        "STUCK" => ["STUCK"],
        "ORPHAN" => ["DONE"],
        "DONE" => []
      }

      result = described_class.verify_fsm(
        states: states,
        initial: "START",
        terminals: ["DONE"],
        transitions: transitions
      )

      expect(result[:proved]).to be(false)
      expect(result[:unreachable_states]).to eq(["ORPHAN"])
      expect(result[:deadlock_states]).to eq(["STUCK"])
    end
  end

  describe ".check_trace_conformance" do
    let(:spec_edges) do
      [
        %w[staged pending],
        %w[pending processing],
        %w[processing enriched],
        %w[enriched published],
        %w[published archived]
      ]
    end

    it "proves full conformance (fitness 1.0, empty delta) for a clean tracer run" do
      observed = %w[staged pending processing enriched published archived]
      result = described_class.check_trace_conformance(spec_edges: spec_edges, observed_sequence: observed)

      expect(result[:conformant]).to be(true)
      expect(result[:fitness]).to eq(1.0)
      expect(result[:unexpected_transitions]).to be_empty
      expect(result[:missing_transitions]).to be_empty
    end

    it "computes exact missing and unexpected transitions when runtime diverges from the map" do
      observed = %w[staged pending processing title_review_required]
      result = described_class.check_trace_conformance(spec_edges: spec_edges, observed_sequence: observed)

      expect(result[:conformant]).to be(false)
      expect(result[:unexpected_transitions]).to eq([%w[processing title_review_required]])
      expect(result[:missing_transitions]).to include(%w[processing enriched], %w[published archived])
    end
  end
end
