# frozen_string_literal: true

require 'spec_helper'
require 'nokogiri'

RSpec.describe 'Season One planning page content boundary', type: :request do
  let(:dashboard_path) { File.expand_path('../../youtube/dashboard.html', __dir__) }
  let(:html) { File.read(dashboard_path) }
  let(:doc) { Nokogiri::HTML(html) }

  it 'presents a plain content outline and recording links' do
    expect(doc.at_css('h1').text).to eq('Season One working plan')
    expect(doc.css('a').map { |link| link['href'] }).to include('/series/the-sound-above/', '/obs/', '/interviews/')
  end

  it 'does not carry the retired publishing cockpit or queue monitor' do
    expect(html).not_to include('youtube_pipeline_telemetry')
    expect(html).not_to include('YouTube Data API')
    expect(html).not_to include('BPMN')
  end
end
