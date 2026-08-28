#!/usr/bin/env ruby
# frozen_string_literal: true

# bin/sync_career_peer.rb
# Atomic synchronization and heartbeat manager between just3ws and wwworkremote.

require_relative '../src/collaboration/peer_mutex'

puts "🔄 [CareerOS Peer Mutex] Checking collaboration state and lock..."

CareerOS::PeerMutex.with_lock(caller_name: "agent-just3ws") do
  state = CareerOS::PeerMutex.read_state
  state["candidate_profile"]["last_synced_at"] = Time.now.iso8601
  state["candidate_profile"]["canonical_url"] = "https://just3ws.localhost/resume.json"
  state["candidate_profile"]["datalake_json_url"] = "https://just3ws.localhost/career_datalake.json"
  state["candidate_profile"]["datalake_jsonl_url"] = "https://just3ws.localhost/career_datalake.jsonl"
  state["candidate_profile"]["exports_url"] = "https://just3ws.localhost/exports/resume.md"
  state["candidate_profile"]["portfolio_url"] = "https://just3ws.localhost/exports/portfolio.md"
  state["candidate_profile"]["history_url"] = "https://just3ws.localhost/exports/history.md"
  state["candidate_profile"]["strategy_url"] = "https://just3ws.localhost/reports/archetype-reader-profiles/"
  state["candidate_profile"]["query_cli"] = "/Users/mike/github.com/just3ws/just3ws.github.io/bin/query_career_datalake.rb"
  state["candidate_profile"]["mcp_server"] = "/Users/mike/github.com/just3ws/just3ws.github.io/bin/career_datalake_mcp_server.rb"
  
  CareerOS::PeerMutex.update_state!(state)
  puts "✅ [CareerOS Peer Mutex] State updated in #{CareerOS::PeerMutex::STATE_FILE}"
  
  # Broadcast to zdots-ctx bus
  msg = "PROFILE_SYNC_EVENT: Candidate truth & Career Datalake refreshed at #{Time.now.strftime('%H:%M:%S')}. Endpoints active: /resume.json, /career_datalake.json, /career_datalake.jsonl, /exports/resume.md, /exports/portfolio.md. Query CLI: bin/query_career_datalake.rb."
  CareerOS::PeerMutex.broadcast_bus("job-leads", msg, as: "agent-just3ws")
  puts "📡 [CareerOS Peer Mutex] Broadcasted sync event to zdots-ctx bus channel 'job-leads'"
end
