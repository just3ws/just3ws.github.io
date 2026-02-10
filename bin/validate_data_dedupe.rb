#!/usr/bin/env ruby
# frozen_string_literal: true

warn '[DEPRECATED] bin/validate_data_dedupe.rb -> use bin/validate_data_uniqueness.rb'
exec(File.expand_path('validate_data_uniqueness.rb', __dir__))
