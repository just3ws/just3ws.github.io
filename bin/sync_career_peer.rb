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
  state["candidate_profile"]["exports_url"] = "https://just3ws.localhost/exports/resume.md"
  
  CareerOS::PeerMutex.update_state!(state)
  puts "✅ [CareerOS Peer Mutex] State updated in #{CareerOS::PeerMutex::STATE_FILE}"
  
  # Broadcast to zdots-ctx bus
  msg = "PROFILE_SYNC_EVENT: Candidate truth refreshed at #{Time.now.strftime('%H:%M:%S')}. Endpoints active: /resume.json, /exports/resume.md, /exports/portfolio.md."
  CareerOS::PeerMutex.broadcast_bus("job-leads", msg, as: "agent-just3ws")
  puts "📡 [CareerOS Peer Mutex] Broadcasted sync event to zdots-ctx bus channel 'job-leads'"
end
