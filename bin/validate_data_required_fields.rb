#!/usr/bin/env ruby
# frozen_string_literal: true

warn '[DEPRECATED] bin/validate_data_required_fields.rb -> use bin/validate_data_integrity.rb'
exec(File.expand_path('validate_data_integrity.rb', __dir__))
