# frozen_string_literal: true

require 'date'

# Shared date semantics for generators and Liquid-facing adapters.
module DateDisplay
  ISO_DATE = /\A\d{4}-\d{2}-\d{2}\z/.freeze

  def self.human(value)
    return 'Present' if value.nil? || value.to_s.strip.empty?

    date = Date.iso8601(value.to_s)
    date.strftime('%B %Y')
  rescue ArgumentError
    value.to_s
  end

  def self.iso_date?(value)
    value.is_a?(String) && value.match?(ISO_DATE) && Date.iso8601(value)
  rescue ArgumentError
    false
  end
end
