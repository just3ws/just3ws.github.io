#!/usr/bin/env ruby
# frozen_string_literal: true

operation = File.basename($PROGRAM_NAME, ".rb")
warn "#{operation} is retired in the just3ws.github.io content repository."
warn "YouTube API writes belong to media-pipeline. Use its `bin/mp` commands for supported publishing work."
warn "YouTube Live Broadcast scheduling is not available from this legacy entrypoint."
exit 64
