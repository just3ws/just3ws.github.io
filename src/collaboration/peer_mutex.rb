# frozen_string_literal: true

# src/collaboration/peer_mutex.rb
# Inter-Tool Mutex & State Registry between just3ws and wwworkremote.
# Provides file-based flock synchronization, atomic JSON state management,
# and zdots-ctx bus broadcasting.

require 'fileutils'
require 'json'
require 'time'
require 'timeout'

module CareerOS
  class PeerMutex
    STATE_DIR = File.expand_path("~/.local/state/career-os")
    LOCK_FILE = File.join(STATE_DIR, "mutex.lock")
    STATE_FILE = File.join(STATE_DIR, "state.json")
    ZDOTS_CTX_BIN = File.expand_path("~/.config/zsh/bin/zdots-ctx")

    @current_lock_depth = 0

    class << self
      def with_lock(timeout_sec: 10, caller_name: "agent-just3ws")
        FileUtils.mkdir_p(STATE_DIR)

        # Support re-entrant locks within the same Ruby process
        if @current_lock_depth > 0
          @current_lock_depth += 1
          begin
            return yield
          ensure
            @current_lock_depth -= 1
          end
        end

        File.open(LOCK_FILE, File::RDWR | File::CREAT, 0o644) do |f|
          start_time = Time.now
          locked = false
          until locked || (Time.now - start_time > timeout_sec)
            locked = f.flock(File::LOCK_EX | File::LOCK_NB)
            sleep 0.05 unless locked
          end

          unless locked
            raise StandardError, "Could not acquire CareerOS mutex lock after #{timeout_sec}s"
          end

          @current_lock_depth = 1
          update_heartbeat!(caller_name)
          begin
            yield
          ensure
            @current_lock_depth = 0
            f.flock(File::LOCK_UN)
          end
        end
      end

      def read_state
        FileUtils.mkdir_p(STATE_DIR)
        return default_state unless File.exist?(STATE_FILE)

        JSON.parse(File.read(STATE_FILE))
      rescue StandardError
        default_state
      end

      def update_state!(updates = {})
        with_lock(caller_name: "state-writer") do
          current = read_state
          merged = current.merge(updates.transform_keys(&:to_s))
          merged["last_updated_at"] = Time.now.iso8601
          File.write(STATE_FILE, JSON.pretty_generate(merged))
          merged
        end
      end

      def broadcast_bus(channel, message, as: "agent-just3ws")
        return false unless File.executable?(ZDOTS_CTX_BIN)

        cmd = "#{ZDOTS_CTX_BIN} bus-post #{channel} #{message.inspect} --as #{as}"
        system(cmd)
      end

      def update_heartbeat!(peer_name)
        state = read_state
        state["peers"] ||= {}
        state["peers"][peer_name] = {
          "last_seen_at" => Time.now.iso8601,
          "status" => "active"
        }
        File.write(STATE_FILE, JSON.pretty_generate(state))
      rescue StandardError
        # Best effort heartbeat
      end

      private

      def default_state
        {
          "version" => "1.0.0",
          "last_updated_at" => Time.now.iso8601,
          "candidate_profile" => {
            "source" => "https://just3ws.localhost/resume.json",
            "last_synced_at" => nil
          },
          "active_evaluations" => {},
          "peers" => {
            "just3ws" => { "status" => "active", "last_seen_at" => Time.now.iso8601 },
            "wwworkremote" => { "status" => "active", "last_seen_at" => nil }
          }
        }
      end
    end
  end
end
