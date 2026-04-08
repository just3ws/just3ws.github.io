module Jekyll
  module ResumeSignals
    def group_by_signal(positions)
      signals = {}
      
      positions.each do |id, data|
        highlights = data['highlights'] || []
        company_name = data.dig('company', 'name')
        
        highlights.each do |h|
          label = h['label'] || 'Other'
          signals[label] ||= []
          signals[label] << {
            'text' => h['text'],
            'company' => company_name,
            'date' => data['start_date']
          }
        end
      end
      
      # Sort by label name
      signals.sort.to_h
    end
  end
end

Liquid::Template.register_filter(Jekyll::ResumeSignals)
