module Jekyll
  module ResumeSignals
    def group_by_signal(positions)
      signals = {}

      positions.each do |id, data|
        next unless data.is_a?(Hash)

        highlights = data['highlights'] || []
        company_name = data.dig('company', 'name') || id
        position_title = data['title'] || 'Engineering Leadership'
        date_str = "#{data['start_date']} — #{data['end_date'] || 'Present'}"

        highlights.each do |h|
          text = h.is_a?(Hash) ? h['text'] : h.to_s
          label = (h.is_a?(Hash) && h['label']) ? h['label'] : infer_signal(text, data['skills'])

          signals[label] ||= []
          signals[label] << {
            'text' => text,
            'company' => company_name,
            'title' => position_title,
            'date' => date_str,
            'position_id' => id
          }
        end
      end

      # Sort by label name deterministically
      signals.sort.to_h
    end

    private

    def infer_signal(text, skills)
      combined = "#{text} #{Array(skills).join(' ')}".downcase
      if combined.include?('incident') || combined.include?('downtime') || combined.include?('resilience') || combined.include?('escalation')
        'Incident Leadership & Reliability'
      elsif combined.include?('telemetry') || combined.include?('observability') || combined.include?('monitoring') || combined.include?('visibility')
        'Observability & Production Visibility'
      elsif combined.include?('legacy') || combined.include?('moderniz') || combined.include?('refactor') || combined.include?('decouple')
        'Legacy Modernization & Refactoring'
      elsif combined.include?('enablement') || combined.include?('onboard') || combined.include?('mentor') || combined.include?('community') || combined.include?('craftsmanship')
        'Engineering Enablement & Mentorship'
      else
        'Platform Architecture & System Ownership'
      end
    end
  end
end

Liquid::Template.register_filter(Jekyll::ResumeSignals)
