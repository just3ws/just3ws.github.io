# frozen_string_literal: true

require 'spec_helper'
require 'open3'
require 'tempfile'

RSpec.describe 'YouTube Operations Dashboard Queue Interface & Integration' do
  let(:dashboard_path) { File.expand_path('../../youtube/dashboard.html', __dir__) }
  let(:dashboard_content) { File.read(dashboard_path) }

  describe 'HTML Structure & DOM Contracts (#tab-queue)' do
    it 'defines the primary queue container #tab-pane-queue' do
      expect(dashboard_content).to include('id="tab-pane-queue"')
    end

    it 'defines all 5 Kanban column card containers' do
      expect(dashboard_content).to include('id="col-cards-staged"')
      expect(dashboard_content).to include('id="col-cards-pending"')
      expect(dashboard_content).to include('id="col-cards-processing"')
      expect(dashboard_content).to include('id="col-cards-processed"')
      expect(dashboard_content).to include('id="col-cards-failed"')
    end

    it 'defines all 5 Kanban column badge counters' do
      expect(dashboard_content).to include('id="col-count-staged"')
      expect(dashboard_content).to include('id="col-count-pending"')
      expect(dashboard_content).to include('id="col-count-processing"')
      expect(dashboard_content).to include('id="col-count-processed"')
      expect(dashboard_content).to include('id="col-count-failed"')
    end

    it 'defines all 8 BPMN step indicators in the linear pipeline step bar' do
      expect(dashboard_content).to include('id="bpmn-funnel-step-chain"')
      expect(dashboard_content).to include('1. Ingress')
      expect(dashboard_content).to include('2. Lock &amp; FIFO')
      expect(dashboard_content).to include('3. Ephemeral DSP')
      expect(dashboard_content).to include('4. Whisper STT')
      expect(dashboard_content).to include('5. Metadata')
      expect(dashboard_content).to include('6. YouTube API')
      expect(dashboard_content).to include('7. Captions')
      expect(dashboard_content).to include('8. Receipt &amp; Archival')
    end

    it 'defines operator pipeline controls (halt, stop, resume)' do
      expect(dashboard_content).to include("triggerPipelineAction('halt')")
      expect(dashboard_content).to include("triggerPipelineAction('stop')")
      expect(dashboard_content).to include("triggerPipelineAction('resume')")
    end

    it 'defines channel filter chips for all intake targets' do
      expect(dashboard_content).to include("setFunnelFilter('all'")
      expect(dashboard_content).to include("setFunnelFilter('ramblin-amblin'")
      expect(dashboard_content).to include("setFunnelFilter('the-sound-above'")
      expect(dashboard_content).to include("setFunnelFilter('errata'")
    end

    it 'defines the live pipeline activity stream container' do
      expect(dashboard_content).to include('id="pipeline-activity-stream"')
      expect(dashboard_content).to include('id="auto-intake-badge"')
    end
  end

  describe 'JavaScript Syntax & Function Definition Integrity' do
    it 'parses all script blocks without syntax errors via node --check' do
      scripts = dashboard_content.scan(%r{<script(?![^>]*src=)[^>]*>(.*?)</script>}m).flatten
      expect(scripts).not_to be_empty

      scripts.each_with_index do |script, idx|
        # Clean Jekyll Liquid tags for syntax evaluation
        clean_script = script.gsub(/\{\{[\s\S]*?\}\}/, '[]')
                             .gsub(/\{%[\s\S]*?%\}/, '')

        temp_file = Tempfile.new(["dashboard_spec_#{idx}", '.js'])
        begin
          temp_file.write(clean_script)
          temp_file.flush

          stdout, stderr, status = Open3.capture3('node', '--check', temp_file.path)
          expect(status.exitstatus).to eq(0), "JavaScript syntax error in dashboard script block #{idx + 1}:\n#{stderr}\n#{stdout}"
        ensure
          temp_file.close
          temp_file.unlink
        end
      end
    end

    it 'defines all core rendering and integration functions' do
      expect(dashboard_content).to include('async function triggerPipelineAction(')
      expect(dashboard_content).to include('function renderSubstateBadges(')
      expect(dashboard_content).to include('function renderIngressFunnel(')
      expect(dashboard_content).to include('function applyRealtimeTelemetry(')
      expect(dashboard_content).to include('function initDashboardRealtimeStream(')
      expect(dashboard_content).to include('function setFunnelFilter(')
      expect(dashboard_content).to include('function inspectFunnelStep(')
      expect(dashboard_content).to include('function sanitizeDiagnostic(')
      expect(dashboard_content).to include('function updateQuotaCountdown(')
    end
  end

  describe 'Substate Badge Contract & Status Indicators' do
    it 'maps completed, in_progress, failed, and pending substates to visual badges' do
      expect(dashboard_content).to include("b.status === 'completed'")
      expect(dashboard_content).to include("b.status === 'in_progress'")
      expect(dashboard_content).to include("b.status === 'failed'")
      expect(dashboard_content).to include("icon = '✓'")
      expect(dashboard_content).to include("icon = '🔄'")
      expect(dashboard_content).to include("icon = '❌'")
      expect(dashboard_content).to include("icon = '⏳'")
    end

    it 'renders upload progress bar and sanitizeDiagnostic in cards' do
      expect(dashboard_content).to include('linear-gradient(90deg, #3b82f6, #1d4ed8)')
      expect(dashboard_content).to include('sanitizeDiagnostic(item.diagnostic)')
      expect(dashboard_content).to include('id="quota-reset-pill"')
    end
  end
end
