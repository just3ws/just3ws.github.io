# frozen_string_literal: true

require 'json'
require 'yaml'

RSpec.describe "OBS Studio Production Artifacts & Contracts" do
  let(:scenes_file) { File.expand_path("../../obs/scenes/ugtastic-sound-above.json", __dir__) }
  let(:overlay_state_file) { File.expand_path("../../obs/overlays/overlay-state.json", __dir__) }
  let(:theme_css_file) { File.expand_path("../../obs/overlays/css/craftsmanship-theme.css", __dir__) }
  let(:basic_ini_file) { File.expand_path("../../obs/profiles/The Sound Above/basic.ini", __dir__) }

  it "verifies scene collection defines all 8 required production scenes and proper audio routing" do
    expect(File.exist?(scenes_file)).to be true
    data = JSON.parse(File.read(scenes_file))

    expected_scenes = [
      "01. Starting Soon",
      "02. Monologue / Full Camera",
      "03. Reaction - Video Focus",
      "04. Split Screen - Video & Research",
      "05. Workbench - Code & Terminal",
      "06. Guest & Co-Host Discussion",
      "07. Intermission / BRB",
      "08. Outro & Next Stream"
    ]

    scene_names = data["scene_order"].map { |s| s["name"] }
    expect(scene_names).to match_array(expected_scenes)

    # Audio capture verification
    mic = data["AuxAudioDevice1"]
    expect(mic).not_to be_nil, "Expected AuxAudioDevice1 in OBS scenes"
    expect(mic["id"]).to eq("coreaudio_input_capture")
    expect(mic["filters"].size).to be >= 3
    expect(mic["mixers"]).to eq(3)

    desktop_audio = data["DesktopAudioDevice1"]
    expect(desktop_audio).not_to be_nil, "Expected DesktopAudioDevice1 in OBS scenes"
    expect(desktop_audio["id"]).to eq("coreaudio_output_capture")
    expect(desktop_audio["mixers"]).to eq(0)
    expect(desktop_audio["enabled"]).to be(false)

    chromium_audio = data["sources"].find { |source| source["id"] == "sck_audio_capture" }
    expect(chromium_audio).not_to be_nil
    expect(chromium_audio["mixers"]).to eq(5)
    guest_track_sources = data["sources"].select do |source|
      source["id"] == "sck_audio_capture" && (source["mixers"].to_i & 8).positive?
    end
    expect(guest_track_sources).to be_empty

    reaction = data["sources"].find { |source| source["name"] == "03. Reaction - Video Focus" }
    camera = reaction.dig("settings", "items").find { |item| item["name"] == "Host Camera" }
    expect(camera["pos"]).to eq({ "x" => 1380.0, "y" => 750.0 })
    expect(camera["bounds"]).to eq({ "x" => 480.0, "y" => 270.0 })
  end

  it "verifies basic.ini configures 1080p60 and Apple VideoToolbox hardware acceleration" do
    expect(File.exist?(basic_ini_file)).to be true
    ini_content = File.read(basic_ini_file)

    expect(ini_content).to match(/BaseCX=1920/)
    expect(ini_content).to match(/BaseCY=1080/)
    expect(ini_content).to match(/OutputCX=1920/)
    expect(ini_content).to match(/OutputCY=1080/)
    expect(ini_content).to match(/FPSCommon=60/)
    expect(ini_content).to match(/videotoolbox|apple_h264|vt_h264/)
    expect(ini_content).to include('DesktopAudioDevice1=disabled')
    expect(ini_content).to match(/Track1Bitrate=320/)
    expect(ini_content).to match(/RecSplitFileTime=0/)
    expect(ini_content).to match(/RecSplitFileSize=0/)

    staging_ini = File.read(File.expand_path('../../obs/profiles/The Sound Above - Staging/basic.ini', __dir__))
    expect(staging_ini).to match(/Track1Bitrate=320/)
    expect(staging_ini).to match(/RecSplitFileTime=0/)
    expect(staging_ini).to match(/RecSplitFileSize=0/)
  end

  it "verifies overlay state matches craftsmanship design tokens" do
    expect(File.exist?(overlay_state_file)).to be true
    state = JSON.parse(File.read(overlay_state_file))

    expect(state["episode"]["number"]).to be >= 0
    expect(state["episode"]["interviewee"]).not_to be_empty
    expect(state["stream"]["series_title"]).to match(/The Sound Above|Errata|Ramblin' & Amblin'|The Room/)

    expect(File.exist?(theme_css_file)).to be true
    css = File.read(theme_css_file)
    expect(css).to include("--teal-craftsman: #0f766e;")
    expect(css).to include("--amber-accent: #b45309;")
  end

  it "prevents the installer from overwriting OBS files while OBS is running" do
    installer = File.read(File.expand_path('../../obs/scripts/install-obs-config.sh', __dir__))
    expect(installer).to include('pgrep -x OBS')
    expect(installer).to include('Close OBS before installing this configuration')
  end
end
