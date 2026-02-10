#!/usr/bin/env ruby
# frozen_string_literal: true

warn '[DEPRECATED] bin/build_interviews.rb -> use bin/sync_interview_asset_links.rb'
exec(File.expand_path('sync_interview_asset_links.rb', __dir__))
