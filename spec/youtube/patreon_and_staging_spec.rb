# frozen_string_literal: true

require 'spec_helper'
require 'open3'
require 'json'

RSpec.describe 'Patreon Pipeline & Staging Workflow Integration' do
  let(:root_dir) { File.expand_path('../..', __dir__) }
  let(:patreon_bin) { File.join(root_dir, 'bin', 'patreon_pipeline.rb') }
  let(:stage_bin) { File.join(root_dir, 'bin', 'stage_episode_workflow.rb') }
  let(:pipeline_bin) { File.join(root_dir, 'bin', 'pipeline') }

  describe 'Patreon Pipeline CLI (bin/patreon_pipeline.rb)' do
    it 'is executable' do
      expect(File.executable?(patreon_bin)).to be true
    end

    it 'displays campaign status without inventing revenue estimates' do
      stdout, stderr, status = Open3.capture3(patreon_bin, 'status')
      expect(status.success?).to be true
      expect(stdout).to include('PATREON CAMPAIGN STATUS')
      expect(stdout).to include('https://www.patreon.com/c/just3ws')
      expect(stdout).to include('Revenue is not estimated')
    end

    it 'lists patrons and tier breakdowns' do
      stdout, stderr, status = Open3.capture3(patreon_bin, 'members')
      expect(status.success?).to be true
      expect(stdout).to include('PATREON COUNTS BY TIER')
      expect(stdout).to include('Member names and individual membership details are not stored or displayed.')
    end

    it 'points broadcast thank-you copy to the public support page' do
      stdout, stderr, status = Open3.capture3(patreon_bin, 'credits')
      expect(status.success?).to be true
      expect(stdout).to include('TELEPROMPTER')
      expect(stdout).to include('YOUTUBE DESCRIPTION')
      expect(stdout).to include('https://www.just3ws.com/support/')
      expect(stdout).not_to include('patreon.com/c/just3ws')
      expect(stdout).to include('Named credits require an explicit, permissioned list')
    end

    it 'does not sync fake patrons or write an identity roster without API credentials' do
      stdout, stderr, status = Open3.capture3({ 'PATREON_CREATOR_TOKEN' => nil, 'PATREON_CAMPAIGN_ID' => nil }, patreon_bin, 'sync')
      expect(status.exitstatus).to eq(2)
      expect(stdout).not_to include('Chicago Craftsmanship Veteran')
      roster_path = File.join(root_dir, '_data', 'patreon_roster.json')
      expect(File.exist?(roster_path)).to be false
    end
  end

  describe 'Staging Workflow Harness (bin/stage_episode_workflow.rb)' do
    it 'is executable' do
      expect(File.executable?(stage_bin)).to be true
    end

    it 'successfully verifies Episode 1 in staging mode' do
      stdout, stderr, status = Open3.capture3(stage_bin, '1')
      expect(status.success?).to be true
      expect(stdout).to include('STAGED EPISODE WORKFLOW VERIFICATION: EPISODE 1')
      expect(stdout).to include('LOCAL PREPARATION CHECKS PASSED')
      expect(stdout).to include('Sergio Pereira')
    end

    it 'successfully verifies Coda 1 (Episode 36) in staging mode' do
      stdout, stderr, status = Open3.capture3(stage_bin, '36')
      expect(status.success?).to be true
      expect(stdout).to include('STAGED EPISODE WORKFLOW VERIFICATION: EPISODE 36')
      expect(stdout).to include('LOCAL PREPARATION CHECKS PASSED')
      expect(stdout).to include('Without zdots, There Was Nothing')
    end

    it 'successfully verifies Coda 2 / Grand Finale (Episode 37) in staging mode' do
      stdout, stderr, status = Open3.capture3(stage_bin, '37')
      expect(status.success?).to be true
      expect(stdout).to include('STAGED EPISODE WORKFLOW VERIFICATION: EPISODE 37')
      expect(stdout).to include('LOCAL PREPARATION CHECKS PASSED')
      expect(stdout).to include('The Sound Above Roundtable: What We Carry Forward')
    end

    it 'passes complete staging harness across all 37 episodes without errors' do
      stdout, stderr, status = Open3.capture3(stage_bin, '--all')
      expect(status.success?).to be true
      expect(stdout).to include('Summary: 37/37 episodes passed staging verification cleanly.')
    end
  end

  describe 'Pipeline wrapper integration' do
    it 'delegates patreon command from bin/pipeline' do
      stdout, stderr, status = Open3.capture3(pipeline_bin, 'patreon', 'status')
      expect(status.success?).to be true
      expect(stdout).to include('PATREON CAMPAIGN STATUS')
    end

    it 'delegates stage command from bin/pipeline' do
      stdout, stderr, status = Open3.capture3(pipeline_bin, 'stage', '1')
      expect(status.success?).to be true
      expect(stdout).to include('STAGED EPISODE WORKFLOW VERIFICATION: EPISODE 1')
    end
  end
end
