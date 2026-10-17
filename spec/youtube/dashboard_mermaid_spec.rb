# frozen_string_literal: true

require 'spec_helper'
require 'nokogiri'

RSpec.describe 'YouTube Dashboard Architecture Mermaid Specifications', type: :request do
  let(:dashboard_path) { File.expand_path('../../youtube/dashboard.html', __dir__) }
  let(:html) { File.read(dashboard_path) }
  let(:doc) { Nokogiri::HTML(html) }

  it 'contains all 3 architecture diagrams with proper language-mermaid markers' do
    blocks = doc.css('code.language-mermaid')
    expect(blocks.length).to eq(3)

    topology = blocks.find { |b| b['id'] == 'mermaid-topology-code' }
    sequence = blocks.find { |b| b['id'] == 'mermaid-sequence-code' }
    state = blocks.find { |b| b['id'] == 'mermaid-state-code' }

    expect(topology).not_to be_nil
    expect(sequence).not_to be_nil
    expect(state).not_to be_nil

    expect(topology.text).to include('graph TD')
    expect(sequence.text).to include('sequenceDiagram')
    expect(state.text).to include('stateDiagram-v2')
  end

  it 'does not contain syntax markers that trip Mermaid rendering errors' do
    blocks = doc.css('code.language-mermaid')
    blocks.each do |block|
      text = block.text
      expect(text).not_to include('Syntax error in text')
      # Validate unclosed braces or quotes
      expect(text.scan(/\{/).count).to eq(text.scan(/\}/).count)
    end
  end
end
