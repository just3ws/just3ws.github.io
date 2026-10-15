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

    it 'displays campaign status and recurring compute fund' do
      stdout, stderr, status = Open3.capture3(patreon_bin, 'status')
      expect(status.success?).to be true
      expect(stdout).to include('PATREON CAMPAIGN STATUS & RECURRING COMPUTE FUNDING')
      expect(stdout).to include('https://patreon.com/whoistechcmty')
      expect(stdout).to include('Monthly Compute Fund:')
      expect(stdout).to include('Archive Preservationist')
      expect(stdout).to include('Workbench Craftsman')
      expect(stdout).to include('Engineering Patron')
    end

    it 'lists patrons and tier breakdowns' do
      stdout, stderr, status = Open3.capture3(patreon_bin, 'members')
      expect(status.success?).to be true
      expect(stdout).to include('ACTIVE PATREON MEMBERS & TIERS')
      expect(stdout).to include('Engineering Patron')
    end

    it 'formats broadcast outro closing credits for teleprompter and YouTube' do
      stdout, stderr, status = Open3.capture3(patreon_bin, 'credits')
      expect(status.success?).to be true
      expect(stdout).to include('BROADCAST OUTRO CLOSING CREDITS')
      expect(stdout).to include('FOR TELEPROMPTER READ-ALONG')
      expect(stdout).to include('FOR YOUTUBE DESCRIPTION')
      expect(stdout).to include('patreon.com/whoistechcmty')
    end

    it 'syncs patron roster to _data/patreon_roster.json' do
      stdout, stderr, status = Open3.capture3(patreon_bin, 'sync')
      expect(status.success?).to be true
      roster_path = File.join(root_dir, '_data', 'patreon_roster.json')
      expect(File.exist?(roster_path)).to be true
      data = JSON.parse(File.read(roster_path))
      expect(data).to have_key('members')
      expect(data['members'].size).to be >= 3
    end
  end

  describe 'Staging Workflow Harness (bin/stage_episode_workflow.rb)' do
    it 'is executable' do
      expect(File.executable?(stage_bin)).to be true
    end

    it 'successfully verifies pilot episode 0 in staging mode' do
      stdout, stderr, status = Open3.capture3(stage_bin, '0')
      expect(status.success?).to be true
      expect(stdout).to include('STAGED EPISODE WORKFLOW VERIFICATION: EPISODE 0')
      expect(stdout).to include('STAGING VERIFIED (READY TO BROADCAST)')
      expect(stdout).to include('The Mirage of Competence: AI Slop & Domain Boundaries')
    end

    it 'successfully verifies Coda 1 (Episode 36) in staging mode' do
      stdout, stderr, status = Open3.capture3(stage_bin, '36')
      expect(status.success?).to be true
      expect(stdout).to include('STAGED EPISODE WORKFLOW VERIFICATION: EPISODE 36')
      expect(stdout).to include('STAGING VERIFIED (READY TO BROADCAST)')
      expect(stdout).to include('Without zdots, There Was Nothing')
    end

    it 'successfully verifies Coda 2 / Grand Finale (Episode 37) in staging mode' do
      stdout, stderr, status = Open3.capture3(stage_bin, '37')
      expect(status.success?).to be true
      expect(stdout).to include('STAGED EPISODE WORKFLOW VERIFICATION: EPISODE 37')
      expect(stdout).to include('STAGING VERIFIED (READY TO BROADCAST)')
      expect(stdout).to include('The Sound Above Roundtable: What We Carry Forward')
    end

    it 'passes complete staging harness across all 38 episodes without errors' do
      stdout, stderr, status = Open3.capture3(stage_bin, '--all')
      expect(status.success?).to be true
      expect(stdout).to include('Summary: 38/38 episodes passed staging verification cleanly.')
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
