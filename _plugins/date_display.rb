# frozen_string_literal: true

require_relative '../lib/date_display'

module Jekyll
  module DateDisplayFilter
    def human_date(value)
      DateDisplay.human(value)
    end
  end
end

Liquid::Template.register_filter(Jekyll::DateDisplayFilter)
