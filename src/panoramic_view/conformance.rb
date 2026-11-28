# frozen_string_literal: true

require "digest"
require "json"
require "set"
require "tsort"

module PanoramicView
  # Deterministic mathematical verification for formalized Panoramic View seams:
  #   1. DAG cycle-freedom and verified topological ordering (FK / dependency graphs)
  #   2. Finite State Machine soundness (reachability + deadlock-freedom to terminal states)
  #   3. Trace-to-model conformance checking (symmetric delta + fitness score)
  #
  # Epistemic boundary: human mental models remain empirically falsifiable.
  # These checks prove mathematical properties over formalized seams and observed traces.
  module Conformance
    module_function

    class DirectedGraph
      include TSort

      def initialize(nodes, edges)
        @adj = Hash.new { |h, k| h[k] = [] }
        nodes.each { |n| @adj[n] }
        edges.each do |u, v|
          @adj[u] << v
          @adj[v]
        end
      end

      def tsort_each_node(&block)
        @adj.each_key(&block)
      end

      def tsort_each_child(node, &block)
        @adj[node].each(&block)
      end
    end

    # Proves a directed graph G = (V, E) is acyclic and returns a verified
    # topological ordering pi such that for every edge (u, v), pi[u] < pi[v].
    def verify_dag(nodes:, edges:)
      graph = DirectedGraph.new(nodes, edges)
      sccs = graph.strongly_connected_components
      cycles = sccs.select { |c| c.size > 1 || (c.size == 1 && edges.include?([c.first, c.first])) }

      if cycles.any?
        return {
          property: "dag_acyclic_topological_order",
          proved: false,
          cycle_witnesses: cycles,
          order: nil
        }
      end

      order = graph.tsort.reverse
      rank = order.each_with_index.to_h
      invariant_holds = edges.all? { |u, v| rank[u] < rank[v] }

      {
        property: "dag_acyclic_topological_order",
        proved: invariant_holds,
        node_count: order.size,
        edge_count: edges.size,
        order: order,
        cycle_witnesses: []
      }
    end

    # Proves FSM soundness for M = (S, s0, F, delta):
    #   - Closed alphabet: every transition target is in S
    #   - Reachability: every state in S is reachable from s0
    #   - Deadlock-freedom: every reachable state can reach at least one terminal state in F
    def verify_fsm(states:, initial:, terminals:, transitions:)
      state_set = states.to_set
      terminal_set = terminals.to_set

      unknown_targets = transitions.each_with_object([]) do |(from, targets), acc|
        acc << from unless state_set.include?(from)
        Array(targets).each { |t| acc << t unless state_set.include?(t) }
      end.uniq

      # Forward BFS from initial state
      reachable = Set.new([initial])
      queue = [initial]
      until queue.empty?
        curr = queue.shift
        Array(transitions[curr]).each do |nxt|
          next if reachable.include?(nxt)

          reachable << nxt
          queue << nxt
        end
      end

      # Reverse BFS from terminal states
      rev = Hash.new { |h, k| h[k] = [] }
      transitions.each do |from, targets|
        Array(targets).each { |to| rev[to] << from }
      end

      can_terminate = terminal_set.dup
      rqueue = terminals.dup
      until rqueue.empty?
        curr = rqueue.shift
        rev[curr].each do |prev|
          next if can_terminate.include?(prev)

          can_terminate << prev
          rqueue << prev
        end
      end

      unreachable = (state_set - reachable).to_a.sort
      deadlocks = (reachable - can_terminate).to_a.sort
      proved = unknown_targets.empty? && unreachable.empty? && deadlocks.empty?

      {
        property: "fsm_reachability_and_deadlock_freedom",
        proved: proved,
        state_count: state_set.size,
        reachable_count: reachable.size,
        unreachable_states: unreachable,
        deadlock_states: deadlocks,
        unknown_targets: unknown_targets
      }
    end

    # Conformance checking between a formalized model edge set E_spec and
    # an observed runtime trace sequence sigma = [e_1, e_2, ..., e_n].
    # Computes symmetric difference Delta = E_obs XOR E_spec and fitness in [0.0, 1.0].
    def check_trace_conformance(spec_edges:, observed_sequence:)
      spec_set = spec_edges.map { |u, v| [u, v] }.to_set
      obs_edges = observed_sequence.each_cons(2).to_a.to_set

      unexpected = (obs_edges - spec_set).to_a.sort
      missing = (spec_set - obs_edges).to_a.sort
      matched = (obs_edges & spec_set).size
      denom = [obs_edges.size, 1].max
      fitness = (matched.to_f / denom).round(4)

      {
        property: "trace_to_model_conformance",
        conformant: unexpected.empty? && missing.empty?,
        fitness: fitness,
        matched_transitions: matched,
        unexpected_transitions: unexpected,
        missing_transitions: missing
      }
    end

    def digest_record(record)
      Digest::SHA256.hexdigest(JSON.generate(record))
    end
  end
end
