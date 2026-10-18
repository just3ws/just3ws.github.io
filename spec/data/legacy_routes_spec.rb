# frozen_string_literal: true

require 'spec_helper'
require 'yaml'
require 'json'
require_relative '../../bin/remap_legacy_routes'

RSpec.describe 'Legacy Routes, Social Provenance and 404 Recovery' do
  let(:root_dir) { File.expand_path('../..', __dir__) }
  let(:social_path) { File.join(root_dir, '_data', 'social_provenance.yml') }
  let(:domain_path) { File.join(root_dir, '_data', 'domain_migration.yml') }
  let(:routes_path) { File.join(root_dir, '_data', 'legacy_routes.yml') }
  let(:map_path) { File.join(root_dir, 'assets', 'data', 'legacy_route_map.json') }
  let(:page_404_path) { File.join(root_dir, '404.html') }

  describe 'Social Provenance (_data/social_provenance.yml)' do
    it 'exists and is valid YAML' do
      expect(File.exist?(social_path)).to be true
      data = YAML.safe_load(File.read(social_path))
      expect(data).to be_a(Hash)
      expect(data['accounts']).to be_an(Array)
    end

    it 'contains all 5 canonical social identities with verified handles' do
      data = YAML.safe_load(File.read(social_path))
      handles = data['accounts'].map { |a| a['handle'] }

      expect(handles).to include('@WHOISTechCmty')
      expect(handles).to include('@ugtastic')
      expect(handles).to include('@scmchenry')
      expect(handles).to include('@just3ws')
      expect(handles).to include('@chicagocodecamp')
    end

    it 'records the volunteer and website developer era for Chicago Code Camp' do
      data = YAML.safe_load(File.read(social_path))
      ccc = data['accounts'].find { |a| a['handle'] == '@chicagocodecamp' }
      expect(ccc).not_to be_nil
      expect(ccc['era']).to eq('2010 - 2012')
      expect(ccc['role']).to include('Volunteer')
      expect(ccc['connected_services']['schedule_tool_artifact']).to eq('/assets/images/portfolio/chicago-code-camp-print-schedule.jpg')
      expect(File.exist?(File.join(root_dir, 'assets/images/portfolio/chicago-code-camp-print-schedule.jpg'))).to be true
    end

    it 'contains zero em dashes' do
      content = File.read(social_path)
      expect(content).not_to include("\u2014")
      expect(content).not_to include("\u2013")
    end
  end

  describe 'Domain Migration Configuration (_data/domain_migration.yml)' do
    it 'includes all required legacy domains' do
      data = YAML.safe_load(File.read(domain_path))
      domains = data['legacy_domains'].map { |d| d['domain'] }

      expect(domains).to include('ugtastic.com')
      expect(domains).to include('whoistech.com')
      expect(domains).to include('whoistechcmty.com')
      expect(domains).to include('chicagocodecamp.com')
      expect(domains).to include('scmchenry.org')
      expect(domains).to include('ugl.st')
    end

    it 'contains zero em dashes' do
      content = File.read(domain_path)
      expect(content).not_to include("\u2014")
      expect(content).not_to include("\u2013")
    end
  end

  describe 'Legacy Route Map Generation & Resolution' do
    let(:resolver) { LegacyRouteResolver.new(map_path, routes_path) }

    it 'generates a valid legacy_route_map.json' do
      expect(File.exist?(map_path)).to be true
      raw = JSON.parse(File.read(map_path))
      expect(raw['exact_routes']).not_to be_empty
      expect(raw['interviews']).not_to be_empty
      expect(raw['posts']).not_to be_empty
    end

    it 'resolves Chicago Code Camp paths to the wayback archive snapshot' do
      expect(resolver.resolve('chicagocodecamp.com/sessions')['target_url']).to eq('/backlog/docs/wayback/snapshots/20121228074319-https-chicagocodecamp-com-80/')
      expect(resolver.resolve('chicagocodecamp.com/speakers')['target_url']).to eq('/backlog/docs/wayback/snapshots/20121228074319-https-chicagocodecamp-com-80/')
      expect(resolver.resolve('chicagocodecamp.com/schedule')['target_url']).to eq('/backlog/docs/wayback/snapshots/20121228074319-https-chicagocodecamp-com-80/')
      expect(resolver.resolve('/chicagocodecamp')['target_url']).to eq('/backlog/docs/wayback/snapshots/20121228074319-https-chicagocodecamp-com-80/')
    end

    it 'resolves SCMC user group paths to /scmc/' do
      expect(resolver.resolve('scmchenry.org/meetings')['target_url']).to eq('/scmc/')
      expect(resolver.resolve('/scmc')['target_url']).to eq('/scmc/')
      expect(resolver.resolve('scmchenry.org/')['target_url']).to eq('/scmc/')
    end

    it 'resolves UGtastic interview and single routes to canonical URLs' do
      res = resolver.resolve('https://ugtastic.com/interviews/sandro-mancuso-software-craftsmanship-north-america-2013')
      expect(res['target_url']).to eq('/interviews/sandro-mancuso-software-craftsmanship-north-america-2013/')
      expect(res['confidence']).to be >= 0.95
    end

    it 'resolves YouTube video query parameters to the canonical interview page' do
      res = resolver.resolve('https://www.just3ws.com/watch?v=nZSaZ2kETT8')
      expect(res['target_url']).to eq('/interviews/aaron-bedra-general/')
      expect(res['match_type']).to eq('video_query')
    end

    it 'resolves historical blog post slugs' do
      res = resolver.resolve('/2010/04/12/chicago-code-camp-2')
      expect(res['target_url']).to eq('/2010/04/12/chicago-code-camp-2.html')
    end
  end

  describe '404 In-Browser Recovery Page (404.html)' do
    let(:content) { File.read(page_404_path) }

    it 'contains recovery and suggestion containers' do
      expect(content).to include('id="legacy-recovery-banner"')
      expect(content).to include('id="legacy-suggestions-banner"')
      expect(content).to include('id="not-found-default"')
    end

    it 'emits GoatCounter telemetry for missed, recovered, suggested, and unmapped paths' do
      expect(content).to include('/event/missed-path')
      expect(content).to include('/event/legacy-route-recovered')
      expect(content).to include('/event/legacy-route-suggested')
      expect(content).to include('/event/legacy-route-unmapped')
    end

    it 'contains zero em dashes' do
      expect(content).not_to include("\u2014")
      expect(content).not_to include("\u2013")
    end
  end
end
