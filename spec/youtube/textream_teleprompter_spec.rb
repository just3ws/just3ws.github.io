# frozen_string_literal: true

require 'spec_helper'
require 'open3'
require 'json'

RSpec.describe 'Textream Teleprompter Integration & The Sound Above Broadcast Process' do
  let(:root_dir) { File.expand_path('../..', __dir__) }
  let(:generator_script) { File.join(root_dir, 'bin', 'generate_sound_above_teleprompter.rb') }
  let(:pipeline_runner) { File.join(root_dir, 'bin', 'pipeline') }
  let(:staging_script) { File.join(root_dir, 'bin', 'stage_episode_workflow.rb') }
  let(:teleprompter_dir) { File.join(root_dir, 'obs', 'teleprompter') }
  let(:dashboard_html) { File.join(root_dir, 'youtube', 'dashboard.html') }

  describe 'Textream Native Document Format (.textream)' do
    it 'outputs a valid JSON Array of 6 Strings for Episode 1' do
      stdout, stderr, status = Open3.capture3('ruby', generator_script, '-e', '1', '-t')
      expect(status.success?).to be true
      expect(stderr).to be_empty

      pages = JSON.parse(stdout)
      expect(pages).to be_an(Array)
      expect(pages.size).to eq(6)
      expect(pages[0]).to include('Sergio Pereira')
      expect(pages[0]).not_to include('ACT 1:')
      expect(pages[0]).not_to include('Scene:')
      expect(pages[1]).not_to include('ACT 2:')
      expect(pages[2]).not_to include('ACT 3:')
      expect(pages[3]).not_to include('ACT 4:')
      expect(pages[4]).not_to include('ACT 5:')
      expect(pages[5]).not_to include('ACT 6:')
    end

    it 'outputs valid 6-act Textream pages for Episode 00 (Preparatory Pilot)' do
      stdout, stderr, status = Open3.capture3('ruby', generator_script, '-e', '0', '-t')
      expect(status.success?).to be true
      expect(stderr).to be_empty

      pages = JSON.parse(stdout)
      expect(pages.size).to eq(6)
      expect(pages[0]).to include('The Sound Above: Minus Zero')
      expect(pages[0]).to include('345,000-volt transmission lines')
      expect(pages[0]).not_to include('ACT 1:')
      expect(pages[3]).not_to include('ACT 4:')
      expect(pages[3]).not_to include('YouTube ID:')
    end

    it 'rejects an unknown episode instead of generating fabricated fallback content' do
      _stdout, stderr, status = Open3.capture3('ruby', generator_script, '-e', '999', '-t')
      expect(status.success?).to be false
      expect(stderr).to include("Episode '999' was not found")
    end

    it 'generates valid textream://read deep link URLs with only spoken words' do
      stdout, stderr, status = Open3.capture3('ruby', generator_script, '-e', '1', '-u')
      expect(status.success?).to be true
      expect(stderr).to be_empty
      expect(stdout.strip).to start_with('textream://read?text=')
      expect(stdout).to include('Sergio%20Pereira')
      expect(stdout).not_to include('ACT%201')
    end

    it 'saves .textream files to obs/teleprompter with zero em dashes' do
      test_dest = File.join(teleprompter_dir, 'test-episode-01.textream')
      stdout, stderr, status = Open3.capture3('ruby', generator_script, '-e', '1', '-s', test_dest)
      expect(status.success?).to be true
      expect(File.exist?(test_dest)).to be true

      content = File.read(test_dest)
      expect(content).not_to include("\u2014")
      expect(content).not_to match(/\s--\s/)

      pages = JSON.parse(content)
      expect(pages.size).to eq(6)
      FileUtils.rm_f(test_dest)
    end

    it 'compiles all 38 episodes into obs/teleprompter with zero em dashes' do
      stdout, stderr, status = Open3.capture3('ruby', generator_script, '--all-textream')
      expect(status.success?).to be true
      expect(stdout).to include('All 38 .textream documents compiled cleanly')

      (0..37).each do |n|
        slug = format('episode-%02d.textream', n)
        path = File.join(teleprompter_dir, slug)
        expect(File.exist?(path)).to be true

        content = File.read(path)
        expect(content).not_to include("\u2014")
        expect(content).not_to match(/\s--\s/)

        pages = JSON.parse(content)
        expect(pages.size).to eq(6)
      end
    end
  end

  describe 'Pipeline Namespaced Grammar (bin/pipeline)' do
    it 'supports media teleprompter action' do
      stdout, stderr, status = Open3.capture3(pipeline_runner, 'media', 'teleprompter', '-e', '1', '-t')
      expect(status.success?).to be true
      pages = JSON.parse(stdout)
      expect(pages.size).to eq(6)
    end

    it 'supports media textream action' do
      stdout, stderr, status = Open3.capture3(pipeline_runner, 'media', 'textream', '-e', '1', '-t')
      expect(status.success?).to be true
      pages = JSON.parse(stdout)
      expect(pages.size).to eq(6)
    end

    it 'preserves flat aliases for teleprompter and textream' do
      stdout, _stderr, status = Open3.capture3(pipeline_runner, 'teleprompter', '-e', '1', '-t')
      expect(status.success?).to be true
      expect(JSON.parse(stdout).size).to eq(6)

      stdout2, _stderr, status2 = Open3.capture3(pipeline_runner, 'textream', '-e', '1', '-t')
      expect(status2.success?).to be true
      expect(JSON.parse(stdout2).size).to eq(6)
    end
  end

  describe 'Staged Episode Workflow Verification (bin/stage_episode_workflow.rb)' do
    it 'passes Teleprompter Compilation gate with Textream document verification for Episode 0' do
      stdout, stderr, status = Open3.capture3('ruby', staging_script, '0')
      expect(status.success?).to be true
      expect(stdout).to include('Teleprompter compilation     [✅ PASS]')
      expect(stdout).to include('Textream document verified')
    end

    it 'passes Teleprompter Compilation gate with Textream document verification for Episode 1' do
      stdout, stderr, status = Open3.capture3('ruby', staging_script, '1')
      expect(status.success?).to be true
      expect(stdout).to include('Teleprompter compilation     [✅ PASS]')
      expect(stdout).to include('Textream document verified')
    end
  end

  describe 'Dashboard Studio Teleprompter Integration (youtube/dashboard.html)' do
    it 'includes Textream launch and export controls in teleprompter studio' do
      content = File.read(dashboard_html)
      expect(content).to include('launchInTextream')
      expect(content).to include('downloadTextream')
      expect(content).to include('Launch in Textream')
      expect(content).to include('Export .textream')
      expect(content).to include('textream://read?text=')
      expect(content).to include('Read in Textream')
      expect(content).to include('Recording Day Launchpad')
      expect(content).to include('cueLiveEpisodeInObs')
      expect(content).to include('openLiveTeleprompter')
      expect(content).to include('live-cue-feedback')
      expect(content).to include('/youtube/recording-playbook/')
      expect(content).to include("bin/broadcast --preflight")
      expect(content).not_to include("\u2014")
    end
  end
end
