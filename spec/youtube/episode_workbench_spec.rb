# frozen_string_literal: true

require 'spec_helper'
require 'yaml'
require 'json'
require 'open3'

RSpec.describe 'Episode Semantic Dossier & Workbench (TASK-287)' do
  let(:root_dir) { File.expand_path('../..', __dir__) }
  let(:workbench_bin) { File.join(root_dir, 'bin', 'episode_workbench.rb') }
  let(:episodes_dir) { File.join(root_dir, '_data', 'episodes') }
  let(:ep1_path) { File.join(episodes_dir, 'episode-01.yml') }

  describe 'CLI executability and interface' do
    it 'is executable' do
      expect(File.executable?(workbench_bin)).to be true
    end

    it 'supports list command' do
      stdout, stderr, status = Open3.capture3(workbench_bin, 'list')
      expect(status.success?).to be true
      expect(stdout).to include('THE SOUND ABOVE: EPISODE SEMANTIC DOSSIERS')
      expect(stdout).to include('Sergio Pereira')
      expect(stdout).to include('Ray Hightower')
    end

    it 'supports show command for Episode 1' do
      stdout, stderr, status = Open3.capture3(workbench_bin, 'show', '1')
      expect(status.success?).to be true
      expect(stdout).to include('SEMANTIC DOSSIER: EPISODE 1')
      expect(stdout).to include('Sergio Pereira')
      expect(stdout).to include('NARRATIVE ANATOMY')
      expect(stdout).to include('SEMANTIC LEXICON')
      expect(stdout).to include('HUMAN MARGINALIA & RECOLLECTIONS')
      expect(stdout).to include('RESEARCH ATTACHMENTS & CITATIONS')
    end

    it 'supports compile command for Episode 1' do
      stdout, stderr, status = Open3.capture3(workbench_bin, 'compile', '1', '--markdown')
      expect(status.success?).to be true
      expect(stdout).to include('# Teleprompter Rundown: Episode 1')
      expect(stdout).to include('Act 1: Cold Open & Personal Grounding')
      expect(stdout).to include('Act 2: Setting the Historical Scene')
      expect(stdout).to include('Act 3: The Core Inquiry: The Sound Above')
      expect(stdout).to include('Act 4: Hallway Rewatch & Video Reaction')
      expect(stdout).to include('Act 5: The AI-Era Parallel & Terminal Workbench')
      expect(stdout).to include('Act 6: Community Coda, Outro & Next Stream')
    end

    it 'merges human marginalia into compiled teleprompter acts' do
      stdout, stderr, status = Open3.capture3(workbench_bin, 'compile', '1', '--markdown')
      expect(status.success?).to be true
      expect(stdout).to include('[PERSONAL RECOLLECTION: Remembering walking into that first downtown meeting on a rainy Tuesday in 2008 with a ThinkPad and seeing people arguing passionately about IoC containers and testing.]')
      expect(stdout).to include('[SETTING RECOLLECTION: That was the era before meetups were corporate sponsored recruiting events; developers paid for their own pizza and gathered purely to learn from each other.]')
      expect(stdout).to include('Cited references: Sergio Pereira Interview Profile')
    end

    it 'supports validate command and passes cleanly' do
      stdout, stderr, status = Open3.capture3(workbench_bin, 'validate')
      expect(status.success?).to be true
      expect(stdout).to include('[PASS] 100% em-dash clean across all 38 episode dossiers.')
      expect(stdout).to include('[PASS] All 38 episode dossiers conform to semantic schema.')
    end

    it 'supports compile for Episode 0 (Pilot) with personal marginalia' do
      stdout, stderr, status = Open3.capture3(workbench_bin, 'compile', '0', '--markdown')
      expect(status.success?).to be true
      expect(stdout).to include('# Teleprompter Rundown: Episode 0')
      expect(stdout).to include('The Mirage of Competence: AI Slop & Domain Boundaries')
      expect(stdout).to include('under the high-tension wires')
      expect(stdout).to include('patreon.com/whoistechcmty')
    end

    it 'includes Patreon archive callout in teleprompter Act 6 outro' do
      stdout, stderr, status = Open3.capture3(workbench_bin, 'compile', '1')
      expect(status.success?).to be true
      expect(stdout).to include('patreon.com/whoistechcmty')
    end

    it 'supports workshop command to add prompts and recompile' do
      stdout, stderr, status = Open3.capture3(workbench_bin, 'workshop', '1', '--prompt', 'Test workshop prompt')
      expect(status.success?).to be true
      expect(stdout).to include('WORKSHOP REGENERATED: EPISODE 1 TELEPROMPTER RUNDOWN')
    end

    it 'supports stage command to verify episode in staging mode' do
      stdout, stderr, status = Open3.capture3(workbench_bin, 'stage', '0')
      expect(status.success?).to be true
      expect(stdout).to include('STAGED EPISODE WORKFLOW VERIFICATION: EPISODE 0')
      expect(stdout).to include('STAGING VERIFIED (READY TO BROADCAST)')
    end
  end

  describe 'Dossier Schema & Invariants' do
    let(:dossier_files) { Dir.glob(File.join(episodes_dir, 'episode-*.yml')).sort }

    it 'has 38 episodes scaffolded (pilot episode 00, 35 rewatches, and 2 codas)' do
      expect(dossier_files.size).to eq(38)
    end

    it 'contains required fields across all dossiers' do
      dossier_files.each do |f|
        data = YAML.safe_load(File.read(f), permitted_classes: [Date, Time], aliases: true)
        expect(data).to be_a(Hash)
        expect(data['episode']).to be_a(Integer)
        expect(data['title']).not_to be_empty
        expect(data['interviewee']).not_to be_empty
        expect(data['conference']).not_to be_empty
        expect(data['era_name']).not_to be_empty
        expect(data['narrative']).to be_a(Hash)
        expect(data['narrative']['core_inquiry']).not_to be_empty
        expect(data['narrative']['ai_era_parallel']).not_to be_empty
        expect(data['lexicon']).to be_a(Hash)
        expect(data['human_marginalia']).to be_a(Hash)
        expect(data['workflow_tasks']).to be_a(Hash)
      end
    end

    it 'contains zero em dashes across all 35 dossier files' do
      dossier_files.each do |f|
        content = File.read(f)
        expect(content).not_to include("\u2014"), "Em dash found in #{f}"
      end
    end
  end

  describe 'Pipeline wrapper integration' do
    it 'delegates episode subcommand from bin/pipeline' do
      pipeline_bin = File.join(root_dir, 'bin', 'pipeline')
      stdout, stderr, status = Open3.capture3(pipeline_bin, 'episode', 'list')
      expect(status.success?).to be true
      expect(stdout).to include('THE SOUND ABOVE: EPISODE SEMANTIC DOSSIERS')
    end
  end
end
