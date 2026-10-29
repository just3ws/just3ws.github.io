# frozen_string_literal: true

require 'spec_helper'
require 'open3'
require 'yaml'
require 'tmpdir'
require 'fileutils'
require 'rbconfig'

RSpec.describe 'Pipeline Namespacing, Ponytail Discipline & Staged Queues' do
  let(:root_dir) { File.expand_path('../..', __dir__) }
  let(:pipeline_runner) { File.join(root_dir, 'bin', 'pipeline') }
  let(:ponytail_skill) { File.join(root_dir, '.agents', 'skills', 'ponytail', 'SKILL.md') }
  let(:gemini_md) { File.join(root_dir, 'GEMINI.md') }
  let(:targets_yml) { File.join(root_dir, '_data', 'media_intake_targets.yml') }
  let(:bpmn_readme) { File.join(root_dir, 'docs', 'bpmn', 'README.md') }

  describe 'Ponytail Skill & Architectural Discipline' do
    it 'exists and contains the 4-rung ladder' do
      expect(File.exist?(ponytail_skill)).to be true
      content = File.read(ponytail_skill)
      expect(content).to include('Omission')
      expect(content).to include('Inlining')
      expect(content).to include('Stdlib Simplicity')
      expect(content).to include('Annotated Seam')
      expect(content).to include('# ponytail:')
    end

    it 'contains zero em dashes in ponytail SKILL.md' do
      content = File.read(ponytail_skill)
      expect(content).not_to include("\u2014")
      expect(content).not_to match(/\s--\s/)
    end

    it 'references Ponytail skill and tool namespacing in GEMINI.md' do
      expect(File.exist?(gemini_md)).to be true
      content = File.read(gemini_md)
      expect(content).to include('.agents/skills/ponytail/SKILL.md')
      expect(content).to include('The Ponytail Principle: Reducing Premature Technical Debt')
      expect(content).to include('Tool Namespacing, Modularity & Pruning Taxonomy')
      expect(content).not_to include("\u2014")
      expect(content).not_to match(/\s--\s/)
    end

    it 'has annotated # ponytail: seams in the repository' do
      stdout, stderr, status = Open3.capture3('git grep -n "ponytail:" bin/')
      expect(status.success?).to be true
      expect(stdout).to include('ponytail:')
    end
  end

  describe 'Namespaced Pipeline Router (bin/pipeline)' do
    it 'exposes domain verbs in help' do
      stdout, stderr, status = Open3.capture3(pipeline_runner, 'help')
      expect(status.success?).to be true
      expect(stdout).to include('media')
      expect(stdout).to include('validate')
      expect(stdout).to include('data')
      expect(stdout).to include('site')
    end

    it 'supports media namespace subcommands' do
      stdout, stderr, status = Open3.capture3(pipeline_runner, 'media', 'help')
      expect(status.success?).to be true
      expect(stdout).to include('Usage: ./bin/pipeline media')
      expect(stdout).to include('intake')
      expect(stdout).to include('stream')
      expect(stdout).to include('swiftbar')
    end

    it 'supports validate namespace subcommands' do
      stdout, stderr, status = Open3.capture3(pipeline_runner, 'validate', 'help')
      expect(status.success?).to be true
      expect(stdout).to include('Usage: ./bin/pipeline validate')
      expect(stdout).to include('fast')
      expect(stdout).to include('obs')
      expect(stdout).to include('site')
    end

    it 'supports data namespace subcommands' do
      stdout, stderr, status = Open3.capture3(pipeline_runner, 'data', 'help')
      expect(status.success?).to be true
      expect(stdout).to include('Usage: ./bin/pipeline data')
      expect(stdout).to include('generate')
      expect(stdout).to include('graph')
      expect(stdout).to include('semantic-graph')
    end

    it 'supports site namespace subcommands' do
      stdout, stderr, status = Open3.capture3(pipeline_runner, 'site', 'help')
      expect(status.success?).to be true
      expect(stdout).to include('Usage: ./bin/pipeline site')
      expect(stdout).to include('build')
      expect(stdout).to include('test')
      expect(stdout).to include('ci')
    end

    it 'executes media swiftbar cleanly through namespaced router' do
      stdout, stderr, status = Open3.capture3(pipeline_runner, 'media', 'swiftbar')
      expect(status.success?).to be true
      expect(stdout.lines.first).to match(/^(🎬|⚡|⚠️|⏸️|🎥)/)
    end

    it 'preserves flat legacy aliases' do
      stdout, stderr, status = Open3.capture3(pipeline_runner, 'swiftbar')
      expect(status.success?).to be true
      expect(stdout.lines.first).to match(/^(🎬|⚡|⚠️|⏸️|🎥)/)
    end

    it 'fails closed instead of invoking legacy media workers when the service is unavailable' do
      Dir.mktmpdir('pipeline-router') do |tmp_dir|
        fake_bin = File.join(tmp_dir, 'bin')
        FileUtils.mkdir_p(fake_bin)
        File.write(File.join(fake_bin, 'curl'), "#!/bin/sh\nexit 7\n")
        ruby_shim = File.join(fake_bin, 'ruby')
        File.write(ruby_shim, <<~SH)
          #!/bin/sh
          case "${1:-}" in
            bin/intake_drive_video.rb|bin/live_dashboard_streamer.rb)
              echo "$*" >> "$LEGACY_CALL_MARKER"
              exit 98
              ;;
          esac
          exec "$REAL_RUBY" "$@"
        SH
        FileUtils.chmod(0o755, [File.join(fake_bin, 'curl'), ruby_shim])

        env = {
          'PATH' => "#{fake_bin}:#{ENV.fetch('PATH')}",
          'REAL_RUBY' => RbConfig.ruby,
          'LEGACY_CALL_MARKER' => File.join(tmp_dir, 'legacy-called')
        }
        %w[intake scan stream halt stop resume].each do |action|
          _stdout, stderr, status = Open3.capture3(env, pipeline_runner, 'media', action, chdir: root_dir)
          expect(status.success?).to be false
          expect(stderr).to include('media-pipeline service is unavailable')
        end

        expect(File.exist?(env.fetch('LEGACY_CALL_MARKER'))).to be false
      end
    end
  end

  describe 'Staged Ingress Directory State' do
    it 'defines staged directory state in media_intake_targets.yml' do
      expect(File.exist?(targets_yml)).to be true
      targets = YAML.safe_load(File.read(targets_yml))
      channel_targets = targets.dig('channels', 'whoistechcmty', 'targets')
      expect(channel_targets).not_to be_empty
      expect(File.read(targets_yml)).to include('staged/')
    end

    it 'documents staged queue state in docs/bpmn/README.md' do
      content = File.read(bpmn_readme)
      expect(content).to include('staged/')
      expect(content).to include('staged hold directory')
      expect(content).not_to include("\u2014")
    end

    it 'delegates queue monitoring to the media-pipeline SwiftBar plugin' do
      source = File.read(File.join(root_dir, 'bin', 'youtube-swiftbar'))
      expect(source).to include('just3ws-media-pipeline-swiftbar')
      expect(source).not_to include('Staged:')
    end
  end

  describe 'Cross-Channel Concurrency Lock & FIFO Queue Serialization' do
    it 'documents cross-channel 1-at-a-time serialization and FIFO in docs/bpmn/README.md' do
      content = File.read(bpmn_readme)
      expect(content).to include('One Video at a Time Across All Channels')
      expect(content).to include('Oldest-First FIFO Discipline')
      expect(content).not_to include("\u2014")
    end
  end

  describe 'Media Pipeline Operator Skill & Processor Pulse' do
    let(:media_skill) { File.join(root_dir, '.agents', 'skills', 'media-pipeline-operator', 'SKILL.md') }
    let(:subnav_html) { File.join(root_dir, '_includes', 'localhost-subnav.html') }
    let(:dashboard_html) { File.join(root_dir, 'youtube', 'dashboard.html') }

    it 'exists and codifies Maildir lifecycle, Concurrency Lock, and FIFO discipline' do
      expect(File.exist?(media_skill)).to be true
      content = File.read(media_skill)
      expect(content).to include('Zero Permanent Local SSD Footprint')
      expect(content).to include('Cross-Channel Concurrency Lock')
      expect(content).to include('Strict FIFO Queue Discipline')
      expect(content).to include('staged/')
      expect(content).to include('pending/')
      expect(content).to include('processing/')
      expect(content).to include('processed/')
      expect(content).to include('failed/')
      expect(content).not_to include("\u2014")
    end

    it 'includes live processor pulse in localhost-subnav.html' do
      content = File.read(subnav_html)
      expect(content).to include('id="lh-processor-pulse"')
      expect(content).to include('id="lh-pulse-dot"')
      expect(content).to include('id="lh-pulse-label"')
      expect(content).to include('updateProcessorPulse')
      expect(content).to include('animation: pulse-green')
      expect(content).to include('animation: pulse-blue')
    end

    it 'includes background processor badge in youtube/dashboard.html' do
      content = File.read(dashboard_html)
      expect(content).to include('id="bg-processor-badge"')
      expect(content).to include('id="bg-processor-dot"')
      expect(content).to include('id="bg-processor-text"')
      expect(content).to include('Processor: Idle (FIFO Ready)')
    end
  end
end


