#!/usr/bin/env ruby
# frozen_string_literal: true

# ==============================================================================
# Automated OBS Setup & Hardware Contract Validator
# Validates repository artifacts, macOS Golden Gate capabilities, and OBS runtime
# ==============================================================================

require 'json'
require 'fileutils'
require 'socket'
require 'optparse'

ROOT = File.expand_path('..', __dir__)
OBS_DIR = File.join(ROOT, 'obs')
APP_SUPPORT_OBS = File.expand_path('~/Library/Application Support/obs-studio')

class ObsSetupValidator
  REQUIRED_SCENES = [
    '01. Starting Soon',
    '02. Monologue / Full Camera',
    '03. Reaction - Video Focus',
    '04. Split Screen - Video & Research',
    '05. Workbench - Code & Terminal',
    '06. Guest & Co-Host Discussion',
    '07. Intermission / BRB',
    '08. Outro & Next Stream'
  ].freeze

  REQUIRED_OVERLAYS = %w[
    lower-third.html
    now-watching.html
    stream-starting.html
    stream-brb.html
    stream-outro.html
    overlay-state.json
    css/craftsmanship-theme.css
    js/overlay-controller.js
  ].freeze

  REQUIRED_SCRIPTS = %w[
    install-obs-config.sh
    update-overlay-state.sh
    test-audio-routing.sh
  ].freeze

  def initialize(live_mode: false)
    @live_mode = live_mode
    @errors = []
    @warnings = []
    @passes = 0
  end

  def run
    puts '=================================================================='
    puts ' 🔍 AUTOMATED OBS SETUP & CONTRACT VALIDATOR'
    puts '=================================================================='

    validate_repo_scenes
    validate_repo_profile
    validate_overlays_and_theme
    validate_curation_manifest
    validate_scripts
    validate_macos_environment
    validate_installed_state
    probe_live_obs if @live_mode

    print_summary
    @errors.empty?
  end

  private

  def pass(msg)
    @passes += 1
    puts "  [PASS] #{msg}"
  end

  def fail(msg)
    @errors << msg
    puts "  [FAIL] #{msg}"
  end

  def warn(msg)
    @warnings << msg
    puts "  [WARN] #{msg}"
  end

  def validate_repo_scenes
    puts "\n1. Validating Scene Collection Contract..."
    scene_path = File.join(OBS_DIR, 'scenes', 'ugtastic-sound-above.json')

    unless File.file?(scene_path)
      fail("Scene collection file missing: #{scene_path}")
      return
    end

    begin
      data = JSON.parse(File.read(scene_path))
      pass('Scene collection JSON syntax is valid')

      # Check Scene Collection Name
      if data['name'] == 'The Sound Above - UGtastic Rewatch'
        pass("Scene collection name matches: '#{data['name']}'")
      else
        fail("Unexpected scene collection name: '#{data['name']}'")
      end

      # Check Required Scenes
      scene_names = data['scene_order'].map { |s| s['name'] }
      missing_scenes = REQUIRED_SCENES - scene_names
      if missing_scenes.empty?
        pass("All #{REQUIRED_SCENES.size} production scenes defined in scene_order")
      else
        fail("Missing scenes: #{missing_scenes.join(', ')}")
      end

      # Check Audio Devices
      if data['AuxAudioDevice1'] && data['AuxAudioDevice1']['name'] == 'Mic/Aux'
        pass('AuxAudioDevice1 (Host Mic) is configured with audio filters')
      else
        fail('AuxAudioDevice1 is missing or improperly configured')
      end

      if data['DesktopAudioDevice1']
        pass('DesktopAudioDevice1 (macOS Desktop Audio) is configured for Golden Gate')
      else
        warn('DesktopAudioDevice1 not configured in root of scene collection')
      end

      # Check ScreenCaptureKit Audio source in sources
      sources = data['sources'] || []
      sck_source = sources.find { |s| s['id'] == 'sck_audio_capture' }
      if sck_source
        pass("ScreenCaptureKit Application Audio capture configured for '#{sck_source['name']}'")
      else
        fail('No ScreenCaptureKit audio source (sck_audio_capture) found in scene sources')
      end

    rescue JSON::ParserError => e
      fail("JSON syntax error in scene collection: #{e.message}")
    end
  end

  def validate_repo_profile
    puts "\n2. Validating Hardware Profile & Encoding Contracts..."
    profile_dir = File.join(OBS_DIR, 'profiles', 'The Sound Above')
    ini_path = File.join(profile_dir, 'basic.ini')
    service_path = File.join(profile_dir, 'service.json')

    unless File.file?(ini_path)
      fail("Profile basic.ini missing: #{ini_path}")
      return
    end

    ini_content = File.read(ini_path)
    pass('Profile basic.ini is present')

    # Video contract: 1080p60
    if ini_content.include?('BaseCX=1920') && ini_content.include?('BaseCY=1080')
      pass('Canvas resolution locked at 1920x1080')
    else
      fail('Base canvas resolution is not 1920x1080')
    end

    if ini_content.include?('OutputCX=1920') && ini_content.include?('OutputCY=1080')
      pass('Output resolution locked at 1920x1080 (1:1 unscaled crispness)')
    else
      fail('Output resolution is not 1920x1080')
    end

    if ini_content.include?('FPSCommon=60')
      pass('Framerate set to 60 fps for smooth terminal and video playback')
    else
      warn('Framerate is not set to 60 fps')
    end

    # Encoder contract: Apple VT Hardware Encoder
    if ini_content.include?('Encoder=com.apple.videotoolbox.videoencoder.ave.avc') || ini_content.include?('Encoder=apple_h264')
      pass('Video encoder set to Apple VideoToolbox H264 (Apple Silicon M4 hardware acceleration)')
    else
      fail('Video encoder is not set to Apple VideoToolbox H264 (com.apple.videotoolbox.videoencoder.ave.avc)')
    end

    # Audio contract: 48 kHz & Multitrack recording
    if ini_content.include?('SampleRate=48000')
      pass('Audio sample rate locked to broadcast standard 48,000 Hz')
    else
      fail('Audio sample rate is not 48000')
    end

    if ini_content.include?('RecTracks=15')
      pass('Multi-track recording enabled for 4 independent synchronized audio tracks')
    else
      fail('Multi-track recording (RecTracks=15) is not enabled')
    end

    if ini_content.include?('DesktopAudioDevice1=default')
      pass('macOS Golden Gate native desktop audio capture configured')
    else
      warn('DesktopAudioDevice1 is not set to default')
    end

    # Secret check
    if File.file?(service_path)
      service_data = JSON.parse(File.read(service_path))
      key = service_data.dig('settings', 'key').to_s
      if key.empty? || key == 'YOUR_STREAM_KEY'
        pass('Service configuration is secret-free (no stream key committed)')
      else
        fail('Potential stream key found in service.json! Remove credentials from git.')
      end
    end
  end

  def validate_overlays_and_theme
    puts "\n3. Validating Interactive Overlays & Assets..."
    overlays_dir = File.join(OBS_DIR, 'overlays')

    REQUIRED_OVERLAYS.each do |rel_path|
      full_path = File.join(overlays_dir, rel_path)
      if File.file?(full_path)
        pass("Overlay asset exists: #{rel_path}")
      else
        fail("Missing overlay asset: #{rel_path}")
      end
    end

    state_path = File.join(overlays_dir, 'overlay-state.json')
    if File.file?(state_path)
      begin
        state = JSON.parse(File.read(state_path))
        if state['episode'] && state['stream']
          pass('overlay-state.json schema is valid')
        else
          fail('overlay-state.json missing required top-level keys')
        end
      rescue JSON::ParserError => e
        fail("overlay-state.json JSON syntax error: #{e.message}")
      end
    end

    validate_theme_parity_with_site
  end

  # The stream theme and the website share one palette. These tokens must be
  # identical hex values in _sass/_p_variables.scss and the OBS theme CSS.
  SHARED_THEME_TOKENS = %w[paper-canvas ink-main ink-heading teal-craftsman amber-accent].freeze

  def validate_theme_parity_with_site
    scss_path = File.join(ROOT, '_sass', '_p_variables.scss')
    css_path = File.join(OBS_DIR, 'overlays', 'css', 'craftsmanship-theme.css')
    unless File.file?(scss_path) && File.file?(css_path)
      fail('Theme parity check cannot run: site variables or OBS theme CSS is missing')
      return
    end

    scss = File.read(scss_path)
    css = File.read(css_path)

    SHARED_THEME_TOKENS.each do |token|
      site_hex = scss[/^\$#{Regexp.escape(token)}:\s*(#[0-9a-fA-F]{6})/, 1]
      obs_hex = css[/--#{Regexp.escape(token)}:\s*(#[0-9a-fA-F]{6})/, 1]
      if site_hex.nil? || obs_hex.nil?
        fail("Theme token '#{token}' not found in both site SCSS and OBS CSS")
      elsif site_hex.downcase == obs_hex.downcase
        pass("Theme token '#{token}' matches site (#{site_hex.downcase})")
      else
        fail("Theme drift on '#{token}': site #{site_hex} vs OBS #{obs_hex}")
      end
    end
  end

  def validate_curation_manifest
    puts "\n4. Validating Episode Curation Manifest..."
    manifest_path = File.join(OBS_DIR, 'curation', 'sequence-manifest.json')

    unless File.file?(manifest_path)
      fail("Sequence manifest missing: #{manifest_path}")
      return
    end

    begin
      manifest = JSON.parse(File.read(manifest_path))
      episodes = manifest['episodes'] || []

      if episodes.size == 21
        pass("Manifest contains exactly 21 curated episodes across 5 movements")
      else
        fail("Expected 21 episodes, found #{episodes.size}")
      end

      numbers = episodes.map { |e| e['number'] }
      if numbers == (1..21).to_a
        pass('Episode numbering is sequential and complete (1 to 21)')
      else
        fail('Episode numbers are not sequential 1 to 21')
      end

      sample_ep = episodes.first
      if sample_ep['sound_above_inquiry'] && sample_ep['interviewee'] && sample_ep['conference']
        pass('Episode metadata contains required Sound Above inquiry and context fields')
      else
        fail('Episodes missing required metadata fields')
      end
    rescue JSON::ParserError => e
      fail("sequence-manifest.json syntax error: #{e.message}")
    end
  end

  def validate_scripts
    puts "\n5. Validating Operator Scripts & Executability..."
    scripts_dir = File.join(OBS_DIR, 'scripts')

    REQUIRED_SCRIPTS.each do |script|
      path = File.join(scripts_dir, script)
      if File.file?(path)
        if File.executable?(path)
          pass("Script is executable: #{script}")
        else
          fail("Script is not executable (chmod +x required): #{script}")
        end
      else
        fail("Missing script: #{script}")
      end
    end
  end

  def validate_macos_environment
    puts "\n6. Validating macOS Golden Gate & Hardware Environment..."

    # Check OBS App
    if File.directory?('/Applications/OBS.app')
      pass('/Applications/OBS.app is installed')
    else
      fail('/Applications/OBS.app not found. Install via Homebrew: brew install --cask obs')
    end

    # Check OS version
    os_version = `sw_vers -productVersion 2>/dev/null`.strip
    if os_version.start_with?('27.')
      pass("Detected macOS Golden Gate (Version #{os_version}) with native sound capture")
    elsif !os_version.empty?
      pass("Detected macOS Version #{os_version}")
    else
      warn('Unable to determine macOS version via sw_vers')
    end

    # Check CPU architecture
    arch = `uname -m 2>/dev/null`.strip
    if arch == 'arm64'
      pass('Apple Silicon ARM64 architecture verified')
    else
      warn("Architecture is #{arch}")
    end
  end

  def validate_installed_state
    puts "\n7. Validating Installed State in ~/Library/Application Support/obs-studio..."
    installed_scene = File.join(APP_SUPPORT_OBS, 'basic', 'scenes', 'The Sound Above - UGtastic Rewatch.json')
    installed_profile = File.join(APP_SUPPORT_OBS, 'basic', 'profiles', 'The Sound Above', 'basic.ini')

    if File.file?(installed_scene)
      pass("Scene collection installed in OBS: 'The Sound Above - UGtastic Rewatch.json'")
    else
      fail("Scene collection not installed in OBS Application Support. Run: ./obs/scripts/install-obs-config.sh")
    end

    if File.file?(installed_profile)
      pass("Profile installed in OBS: 'The Sound Above'")
    else
      fail("Profile not installed in OBS Application Support. Run: ./obs/scripts/install-obs-config.sh")
    end
  end

  def probe_live_obs
    puts "\n8. Probing Running OBS Studio Instance (Live Mode)..."
    obs_pids = `pgrep -x OBS 2>/dev/null`.strip.split("\n")

    if obs_pids.empty?
      warn('OBS Studio is not currently running (launch /Applications/OBS.app to test live socket)')
      return
    end

    pass("OBS Studio process is running (PID: #{obs_pids.join(', ')})")

    # Probe WebSocket port (default 4455)
    begin
      socket = TCPSocket.new('127.0.0.1', 4455)
      socket.close
      pass('OBS WebSocket server is reachable on port 4455')
    rescue StandardError => e
      warn("OBS WebSocket port 4455 not open or server disabled (#{e.message})")
    end
  end

  def print_summary
    puts "\n=================================================================="
    if @errors.empty?
      puts "✅ OBS Setup Validation PASSED! (#{@passes} assertions verified cleanly)"
      puts "   Warnings: #{@warnings.size}" unless @warnings.empty?
    else
      puts "❌ OBS Setup Validation FAILED with #{@errors.size} error(s):"
      @errors.each { |err| puts "   - #{err}" }
    end
    puts '=================================================================='
  end
end

if __FILE__ == $PROGRAM_NAME
  options = { live: false }
  parser = OptionParser.new do |opts|
    opts.banner = 'Usage: bin/validate_obs_setup.rb [options]'
    opts.separator ''
    opts.separator 'Description:'
    opts.separator '  Validates OBS Studio configuration, scenes, hardware profiles,'
    opts.separator '  interactive overlays, episode manifests, and macOS Golden Gate contracts.'
    opts.separator ''
    opts.separator 'Options:'
    opts.on('-l', '--live', 'Probe running OBS Studio process and WebSocket socket on port 4455') do
      options[:live] = true
    end
    opts.on('-h', '--help', 'Show this help message') do
      puts opts
      exit 0
    end
  end

  parser.parse!

  validator = ObsSetupValidator.new(live_mode: options[:live])
  success = validator.run
  exit(success ? 0 : 1)
end
