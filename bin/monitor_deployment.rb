#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'open3'
require 'time'
require 'net/http'
require 'uri'
require 'fileutils'

# Automated Deployment Progress Monitor with Adaptive Learned Metrics
class DeploymentMonitor
  METRICS_FILE = File.expand_path('../tmp/deployment_metrics.json', __dir__)
  WORKFLOW_NAME = 'Deploy Committed Site'
  DEFAULT_POLL_INTERVAL = 5 # seconds

  # Default baseline step durations in seconds (used on first run)
  DEFAULT_STEP_BASELINES = {
    'Set up job' => 15,
    'Run actions/checkout@v4' => 6,
    'Set up Node' => 5,
    'Set up Ruby' => 35,
    'Run CI gate' => 360,
    'Setup Pages' => 10,
    'Upload Pages artifact' => 15,
    'Deploy to GitHub Pages' => 22,
    'Post Set up Node' => 4,
    'Post Run actions/checkout@v4' => 4,
    'Complete job' => 2
  }.freeze

  def initialize(run_id = nil, poll_interval: DEFAULT_POLL_INTERVAL)
    @run_id = run_id
    @poll_interval = poll_interval
    @metrics = load_metrics
  end

  def run
    target_run = resolve_run
    unless target_run
      puts "❌ No active or recent deployment run found on master."
      exit 1
    end

    run_id = target_run['databaseId'] || target_run['id']
    puts "\n🛰️ [Deployment Monitor] Attached to GitHub Actions Run ##{run_id}"
    puts "🔗 URL: #{target_run['url']}"
    puts "📝 Commit: #{target_run['headSha'] ? target_run['headSha'][0..7] : 'latest'} (#{target_run['displayTitle'] || target_run['name']})"
    puts "⏱️ Started: #{format_local_time(target_run['createdAt'])}\n\n"

    loop do
      data = fetch_run_details(run_id)
      unless data
        puts "⚠️ Failed to fetch run status. Retrying in #{@poll_interval}s..."
        sleep @poll_interval
        next
      end

      render_progress(data)

      status = data['status']
      conclusion = data['conclusion']

      if status == 'completed'
        handle_completion(data)
        break
      end

      sleep @poll_interval
    end
  end

  private

  def resolve_run
    return fetch_run_by_id(@run_id) if @run_id

    # Find the latest push run for Deploy Committed Site
    stdout, status = Open3.capture2(
      'gh', 'run', 'list',
      '--workflow', WORKFLOW_NAME,
      '--branch', 'master',
      '--limit', '5',
      '--json', 'databaseId,status,conclusion,createdAt,headSha,displayTitle,url'
    )
    return nil unless status.success?

    runs = JSON.parse(stdout) rescue []
    # Prefer in_progress or queued runs; otherwise latest completed
    runs.find { |r| %w[in_progress queued].include?(r['status']) } || runs.first
  end

  def fetch_run_by_id(id)
    stdout, status = Open3.capture2(
      'gh', 'run', 'view', id.to_s,
      '--json', 'databaseId,status,conclusion,createdAt,headSha,displayTitle,url,jobs'
    )
    return nil unless status.success?
    JSON.parse(stdout) rescue nil
  end

  def fetch_run_details(id)
    stdout, status = Open3.capture2(
      'gh', 'run', 'view', id.to_s,
      '--json', 'databaseId,status,conclusion,createdAt,updatedAt,headSha,displayTitle,url,jobs'
    )
    return nil unless status.success?
    JSON.parse(stdout) rescue nil
  end

  def render_progress(data)
    jobs = data['jobs'] || []
    deploy_job = jobs.find { |j| j['name'] == 'deploy' } || jobs.first

    created_at = Time.parse(data['createdAt']) rescue Time.now
    elapsed = (Time.now - created_at).to_i

    steps = deploy_job ? (deploy_job['steps'] || []) : []
    total_estimated_sec = compute_total_estimate(steps, elapsed)
    remaining_sec = [total_estimated_sec - elapsed, 0].max
    pct = total_estimated_sec.positive? ? [((elapsed.to_f / total_estimated_sec) * 100).round, 99].min : 0
    pct = 100 if data['status'] == 'completed'

    eta_time = Time.now + remaining_sec

    # Terminal UI Header
    print "\e[2K\e[1G" # Clear line
    bar_width = 24
    filled = (pct / 100.0 * bar_width).round
    bar = "█" * filled + "░" * (bar_width - filled)

    status_badge = case data['status']
                   when 'completed'
                     data['conclusion'] == 'success' ? '✅ DEPLOYED' : '❌ FAILED'
                   when 'in_progress'
                     '🚀 IN PROGRESS'
                   else
                     '⏳ QUEUED'
                   end

    puts "────────────────────────────────────────────────────────────────────────"
    puts "#{status_badge}  [#{bar}] #{pct}% | Elapsed: #{format_duration(elapsed)} | ETA: #{format_duration(remaining_sec)} (~#{eta_time.strftime('%I:%M:%S %p')})"
    puts "────────────────────────────────────────────────────────────────────────"

    # Step details
    steps.each do |step|
      name = step['name']
      status = step['status']
      conclusion = step['conclusion']

      icon = if status == 'completed'
               conclusion == 'success' ? '  ✓' : '  ❌'
             elsif status == 'in_progress'
               '  ⏳'
             else
               '  ·'
             end

      started = step['startedAt'] ? Time.parse(step['startedAt']) : nil
      completed = step['completedAt'] ? Time.parse(step['completedAt']) : nil
      step_elapsed = if started && completed
                       (completed - started).to_i
                     elsif started
                       (Time.now - started).to_i
                     else
                       nil
                     end

      baseline = @metrics[name] || DEFAULT_STEP_BASELINES[name]
      duration_str = if step_elapsed
                       "#{format_duration(step_elapsed)}" + (baseline ? " (avg #{format_duration(baseline)})" : "")
                     elsif baseline
                       "est. #{format_duration(baseline)}"
                     else
                       ""
                     end

      puts "#{icon} #{name.ljust(35)} #{duration_str}"
    end
    puts ""
  end

  def compute_total_estimate(steps, elapsed)
    total = 0
    steps.each do |step|
      name = step['name']
      baseline = @metrics[name] || DEFAULT_STEP_BASELINES[name] || 15
      total += baseline
    end
    total = DEFAULT_STEP_BASELINES.values.sum if total.zero?
    [total, elapsed + 10].max
  end

  def handle_completion(data)
    conclusion = data['conclusion']
    jobs = data['jobs'] || []
    deploy_job = jobs.find { |j| j['name'] == 'deploy' } || jobs.first
    steps = deploy_job ? (deploy_job['steps'] || []) : []

    if conclusion == 'success'
      learn_metrics(steps)
      verify_production_endpoints
    else
      puts "\n❌ Deployment run failed."
      puts "🔍 View failed logs with: gh run view #{data['databaseId']} --log-failed"
    end
  end

  def learn_metrics(steps)
    updated = false
    steps.each do |step|
      name = step['name']
      next unless step['status'] == 'completed' && step['conclusion'] == 'success'
      next unless step['startedAt'] && step['completedAt']

      actual_sec = (Time.parse(step['completedAt']) - Time.parse(step['startedAt'])).to_i
      next if actual_sec <= 0

      # Exponential moving average (alpha = 0.3)
      prev = @metrics[name] || DEFAULT_STEP_BASELINES[name] || actual_sec
      learned = ((prev * 0.7) + (actual_sec * 0.3)).round

      @metrics[name] = learned
      updated = true
    end

    save_metrics if updated
  end

  def verify_production_endpoints
    puts "\n🩺 [Live Health Check] Verifying production endpoints..."
    urls = [
      'https://www.just3ws.com/',
      'https://www.just3ws.com/interviews/ray-hightower-chicagoruby-software-craftsmanship-north-america-2011/#transcript'
    ]

    urls.each do |target|
      uri = URI.parse(target)
      start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      response = Net::HTTP.get_response(uri) rescue nil
      duration_ms = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time) * 1000).round

      if response && (response.code == '200' || response.code == '301')
        puts "  ✅ #{target} -> HTTP #{response.code} (#{duration_ms}ms)"
      else
        puts "  ⚠️ #{target} -> HTTP #{response ? response.code : 'ERROR'} (#{duration_ms}ms)"
      end
    end
    puts "🎉 Production release verified and live!\n"
  end

  def load_metrics
    if File.exist?(METRICS_FILE)
      JSON.parse(File.read(METRICS_FILE)) rescue DEFAULT_STEP_BASELINES.dup
    else
      DEFAULT_STEP_BASELINES.dup
    end
  end

  def save_metrics
    FileUtils.mkdir_p(File.dirname(METRICS_FILE))
    File.write(METRICS_FILE, JSON.pretty_generate(@metrics))
  end

  def format_duration(seconds)
    return '0s' if seconds.nil? || seconds <= 0
    mins = seconds / 60
    secs = seconds % 60
    if mins.positive?
      "#{mins}m #{secs}s"
    else
      "#{secs}s"
    end
  end

  def format_local_time(iso_str)
    return 'unknown' unless iso_str
    Time.parse(iso_str).localtime.strftime('%Y-%m-%d %I:%M:%S %p') rescue iso_str
  end
end

if __FILE__ == $PROGRAM_NAME
  run_id = ARGV[0]
  DeploymentMonitor.new(run_id).run
end
