# frozen_string_literal: true

require 'spec_helper'
require 'json'
require 'yaml'

# Guards the recording-day surfaces for the two Errata episodes (Ep 00 Dehum,
# Errata 06 Fluffle Precursor) so every link needed to find and run them on
# localhost stays wired.
RSpec.describe 'Errata episode surfaces' do
  let(:root_dir) { File.expand_path('../..', __dir__) }
  let(:article_path) { '/2026/10/16/the-fluffle-precursor-distributed-whisper-and-the-dead-rabbit-cluster.html' }
  let(:read) { ->(rel) { File.read(File.join(root_dir, rel)) } }

  it 'has a ready Errata 06 dossier and teleprompter file' do
    dossier = YAML.safe_load_file(File.join(root_dir, '_data/episodes/errata-fluffle-precursor.yml'), permitted_classes: [Date, Time])
    expect(dossier['episode']).to eq('errata-06')
    expect(dossier['teleprompter_script'].keys).to include('act_1', 'act_6')
    expect(File.exist?(File.join(root_dir, 'obs/teleprompter/errata-fluffle-precursor.textream'))).to be true
  end

  it 'backs the Errata 06 article with a real post at the linked permalink' do
    post = Dir.glob(File.join(root_dir, '_posts/2026-10-16-the-fluffle-precursor-*.md'))
    expect(post.size).to eq(1)
  end

  it 'exposes errata dossiers in telemetry without changing the 38 numeric dossiers' do
    telemetry = JSON.parse(read.call('_data/youtube_pipeline_telemetry.json'))
    expect(telemetry['episode_dossiers'].size).to eq(38)
    expect(telemetry['errata_dossiers'].map { |d| d['episode'] }).to include('errata-06')
  end

  it 'offers Errata 06 in the teleprompter selector and resolves it client side' do
    html = read.call('youtube/dashboard.html')
    expect(html).to include('<option value="errata-06">')
    expect(html).to include("epNum.indexOf('errata-') === 0")
    expect(html).to include('errata_dossiers')
  end

  %w[
    series/the-sound-above/index.html
    _includes/command-palette.html
    _includes/localhost-subnav.html
    _data/navigation.yml
  ].each do |rel|
    it "links Errata 06 from #{rel}" do
      expect(read.call(rel)).to include(article_path)
    end

    it "does not send #{rel} to the production Dehum dashboard" do
      expect(read.call(rel)).not_to include('just3ws.com/dehum/dashboard.html')
    end
  end

  it 'contains no em dashes in the touched surfaces' do
    %w[series/the-sound-above/index.html _includes/command-palette.html _includes/localhost-subnav.html
       _data/navigation.yml spec/youtube/errata_surfaces_spec.rb].each do |rel|
      expect(read.call(rel)).not_to include("\u2014")
    end
  end
end
