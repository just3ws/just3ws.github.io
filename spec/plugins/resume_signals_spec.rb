# frozen_string_literal: true

require 'spec_helper'
require_relative '../../_plugins/resume_signals'

RSpec.describe Jekyll::ResumeSignals do
  include Jekyll::ResumeSignals

  let(:positions) do
    {
      'onemain' => {
        'title' => 'Associate Director, Staff Engineer',
        'company' => { 'name' => 'OneMain Financial' },
        'start_date' => 'January 2021',
        'end_date' => 'February 2026',
        'summary' => 'Owned platform architecture under load.',
        'highlights' => [
          { 'text' => 'Extended downtime during high-severity production incidents was minimized by serving as technical escalation point.' },
          { 'text' => 'Operational blind spots were eliminated by driving adoption of OpenTelemetry.' }
        ],
        'skills' => ['Platform Architecture', 'OpenTelemetry']
      }
    }
  end

  it 'groups highlights into inferred architectural signal categories' do
    grouped = group_by_signal(positions)
    expect(grouped.keys).to include('Incident Leadership & Reliability', 'Observability & Production Visibility')
    expect(grouped['Incident Leadership & Reliability'].first['company']).to eq('OneMain Financial')
  end
end
