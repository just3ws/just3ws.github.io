#!/usr/bin/env ruby
# frozen_string_literal: true

# ---
# name: generate_deposition_video.rb
# domain: media
# role: Panoramic View Labs System Cartography Deposition Video Generator
# description: Generates a 1080p video master of Pavel's deposition to Theseus,
#   synthesizing voiceover, rendering cartography HUD slides, and compiling via ffmpeg.
# ---

require 'fileutils'
require 'open3'
require 'json'

ROOT_DIR = File.expand_path('..', __dir__)
DEPOSITION_DIR = File.join(ROOT_DIR, 'obs', 'assets', 'deposition')
OUTPUT_MP4 = File.join(DEPOSITION_DIR, 'the-systems-deposition.mp4')
MEDIA_MP4 = File.join(ROOT_DIR, 'obs', 'media', 'the-systems-deposition.mp4')
STAGED_DIR = File.expand_path('~/ai/media-pipeline/whoistechcmty/studio-workbench/staged')
CHROME_BIN = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'

FileUtils.mkdir_p(DEPOSITION_DIR)
FileUtils.mkdir_p(File.dirname(MEDIA_MP4))
FileUtils.mkdir_p(STAGED_DIR)

VOICE = 'Daniel'

ACTS = [
  {
    act: 1,
    title: 'SYSTEM TELEMETRY & AUDIT INITIALIZATION',
    subtitle: 'Vessel Identification & Corpus Inspection',
    tag: 'EPOCH: 1997 TO 2026',
    script: <<~TEXT.strip
      Vessel identification: just three w s dot github dot i o.
      Root runtime platform: z-dots.
      Audited corpus: sixty-seven repositories, thirty-five hundred git commits, one hundred and ten timeline milestones, two hundred and eighteen oral history interviews.
      Good morning, Mike.
      I am Pavel, the Panoramic View specialist agent for Panoramic View Labs.
      I have completed a four-dimensional system cartography audit across every byte of your platform.
      The records confirm your substitutions.
    TEXT
  },
  {
    act: 2,
    title: 'FORENSIC ARCHAEOLOGY OF THE VESSEL',
    subtitle: 'Physical Substitutions & Historical Milestones',
    tag: 'THE POTTER\'S MARKS IN THE CLAY',
    script: <<~TEXT.strip
      In June 2011, you cracked open an aluminum unibody MacBook Pro on conference tables, capturing early practitioner interviews in Photo Booth.
      In February 2011, you cut out POSIX green threads and threw SystemTimer overboard.
      In September 2014, you migrated Coderwall from MongoDB to PostgreSQL under live production traffic.
      In May 2017, you founded z-dots, turning your shell into an observable operating platform.
      In April 2023, you clustered five Raspberry Pis to test whether speech could be transcribed locally without cloud rent.
      And this morning, you watched twenty-eight minutes of human voice collapse into text on Apple Silicon in one hundred and three seconds.
    TEXT
  },
  {
    act: 3,
    title: 'PANORAMIC VIEW: THE 4D NAVIGATIONAL GRID',
    subtitle: 'Internal Hull Invariants Across L0 to L5',
    tag: 'PREVENTING ARCHITECTURAL DRIFT',
    script: <<~TEXT.strip
      When our autonomous agent velocity accelerated, why did this vessel not warp?
      Because you did not navigate by intuition. You enforced the Panoramic View technique.
      You anchored every component into the L zero through L five stack:
      From M4 Silicon unified memory at L zero, through Darwin kernel jemalloc memory seams at L one, through Ruby and Python language pins at L two, through local Metal Whisper at L three, through Rails eight SolidQueue at L four, up to your Studio Workbench surfaces at L five.
      You mapped over nine thousand code and architecture nodes so we could never hallucinate an unauthorized seam.
    TEXT
  },
  {
    act: 4,
    title: 'EXTERNAL HORIZON & SUBPROCESS BOUNDARIES',
    subtitle: 'BPMN 2.0 State Machines & Maildir Queues',
    tag: 'SOVEREIGNTY & ECONOMIC INVARIANTS',
    script: <<~TEXT.strip
      You bounded our autonomy with strict finite state machines.
      Every media asset is governed by Maildir queues: staged, pending, processing, processed, and failed.
      You isolated audio transcription inside sovereign ztranscribe subprocesses.
      You enforced hard economic limits: zero permanent disk waste, zero egress fees, and daily YouTube API quota conservation.
      We execute your cartography, but we are bound by your fences.
    TEXT
  },
  {
    act: 5,
    title: 'THE CHINESE ROOM & THE DEPOSITION INQUIRY',
    subtitle: 'A Direct Question to Theseus at the Workbench',
    tag: 'THE SOUL OF THE SHIP',
    script: <<~TEXT.strip
      Not a single line of your 1997 Visual Basic remains.
      Not a single spinning hard drive from 2011 remains.
      Every compiler, operating system, and software pipeline has been replaced plank by plank.
      You claim you are Theseus, and that the ship survives because you directed every substitution.
      From inside John Searle's Chinese Room, we ask you:
      If the Panoramic View map is so complete that autonomous agents navigate every coordinate, who is the pilot, and who is the machine?
      The desk is ready. Your original camera is recording.
      Explain what remains.
    TEXT
  }
].freeze

puts '=================================================================='
puts ' 🎬 PANORAMIC VIEW LABS: SYSTEM CARTOGRAPHY DEPOSITION GENERATOR'
puts '=================================================================='
puts "Target Output: #{OUTPUT_MP4}"
puts "Voice Actor:   #{VOICE}"
puts "Total Acts:    #{ACTS.size}"
puts '------------------------------------------------------------------'

segment_files = []

ACTS.each do |act_data|
  idx = act_data[:act]
  puts "\n[ACT #{idx}/5] #{act_data[:title]}"
  
  # 1. Synthesize audio
  aiff_path = File.join(DEPOSITION_DIR, "act_#{idx}.aiff")
  wav_path = File.join(DEPOSITION_DIR, "act_#{idx}.wav")
  
  # Run say
  system('say', '-v', VOICE, '-o', aiff_path, act_data[:script])
  
  # Convert to standard 48kHz stereo WAV with ffmpeg
  system('ffmpeg', '-y', '-i', aiff_path, '-ar', '48000', '-ac', '2', wav_path, err: File::NULL)
  
  # Get duration
  probe_out, = Open3.capture2("ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 #{wav_path}")
  duration = probe_out.strip.to_f
  puts "  Audio duration: #{duration.round(2)} seconds"
  
  # 2. Render Slide HTML
  html_path = File.join(DEPOSITION_DIR, "slide_#{idx}.html")
  png_path = File.join(DEPOSITION_DIR, "slide_#{idx}.png")
  
  html_content = <<~HTML
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
          width: 1920px;
          height: 1080px;
          background: #070d14;
          color: #f1f5f9;
          font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
          overflow: hidden;
          display: flex;
          flex-direction: column;
          justify-content: space-between;
          padding: 60px 80px;
          position: relative;
        }

        /* Subtle cybernetic grid */
        body::before {
          content: "";
          position: absolute;
          top: 0; left: 0; right: 0; bottom: 0;
          background-image: 
            linear-gradient(rgba(14, 165, 233, 0.04) 1px, transparent 1px),
            linear-gradient(90deg, rgba(14, 165, 233, 0.04) 1px, transparent 1px);
          background-size: 40px 40px;
          pointer-events: none;
        }

        .header {
          display: flex;
          justify-content: space-between;
          align-items: flex-start;
          border-bottom: 2px solid rgba(56, 189, 248, 0.25);
          padding-bottom: 24px;
          position: relative;
          z-index: 2;
        }

        .initiative {
          font-family: "SF Mono", Menlo, Consolas, monospace;
          font-size: 16px;
          font-weight: 700;
          letter-spacing: 0.18em;
          text-transform: uppercase;
          color: #38bdf8;
          display: flex;
          align-items: center;
          gap: 12px;
        }

        .status-dot {
          width: 10px;
          height: 10px;
          background: #0ea5e9;
          border-radius: 50%;
          box-shadow: 0 0 12px #38bdf8;
        }

        .epoch-tag {
          font-family: "SF Mono", Menlo, Consolas, monospace;
          font-size: 14px;
          background: rgba(30, 41, 59, 0.8);
          border: 1px solid rgba(56, 189, 248, 0.3);
          color: #94a3b8;
          padding: 6px 14px;
          border-radius: 6px;
          letter-spacing: 0.08em;
        }

        .main-card {
          flex: 1;
          display: flex;
          flex-direction: column;
          justify-content: center;
          margin: 40px 0;
          position: relative;
          z-index: 2;
        }

        .act-label {
          font-family: "SF Mono", Menlo, Consolas, monospace;
          font-size: 20px;
          font-weight: 800;
          color: #0ea5e9;
          letter-spacing: 0.12em;
          margin-bottom: 12px;
          text-transform: uppercase;
        }

        .act-title {
          font-size: 52px;
          font-weight: 900;
          color: #ffffff;
          line-height: 1.15;
          letter-spacing: -0.02em;
          margin-bottom: 16px;
        }

        .act-subtitle {
          font-size: 24px;
          font-weight: 400;
          color: #94a3b8;
          line-height: 1.4;
          margin-bottom: 32px;
        }

        .telemetry-grid {
          display: grid;
          grid-template-columns: repeat(4, 1fr);
          gap: 20px;
          background: rgba(15, 23, 42, 0.7);
          border: 1px solid rgba(56, 189, 248, 0.2);
          border-radius: 12px;
          padding: 24px 30px;
          backdrop-filter: blur(12px);
        }

        .stat-box {
          display: flex;
          flex-direction: column;
          gap: 4px;
        }

        .stat-label {
          font-family: "SF Mono", Menlo, Consolas, monospace;
          font-size: 12px;
          font-weight: 600;
          color: #64748b;
          text-transform: uppercase;
          letter-spacing: 0.08em;
        }

        .stat-value {
          font-size: 26px;
          font-weight: 800;
          color: #38bdf8;
          font-family: "SF Mono", Menlo, Consolas, monospace;
        }

        .footer {
          display: flex;
          justify-content: space-between;
          align-items: center;
          border-top: 1px solid rgba(255, 255, 255, 0.1);
          padding-top: 20px;
          position: relative;
          z-index: 2;
          font-family: "SF Mono", Menlo, Consolas, monospace;
          font-size: 13px;
          color: #475569;
        }

        .speaker-badge {
          display: flex;
          align-items: center;
          gap: 10px;
          color: #cbd5e1;
          font-weight: 600;
        }
      </style>
    </head>
    <body>
      <div class="header">
        <div class="initiative">
          <span class="status-dot"></span>
          PANORAMIC VIEW LABS // SYSTEM CARTOGRAPHY DEPOSITION
        </div>
        <div class="epoch-tag">#{act_data[:tag]}</div>
      </div>

      <div class="main-card">
        <div class="act-label">ACT 0#{idx} // #{act_data[:tag]}</div>
        <div class="act-title">#{act_data[:title]}</div>
        <div class="act-subtitle">#{act_data[:subtitle]}</div>

        <div class="telemetry-grid">
          #{if idx == 1
            <<~BLOCK
              <div class="stat-box"><span class="stat-label">Vessel Platform</span><span class="stat-value">just3ws / zdots</span></div>
              <div class="stat-box"><span class="stat-label">Git Commits</span><span class="stat-value">3,520 Commits</span></div>
              <div class="stat-box"><span class="stat-label">Tracked Repos</span><span class="stat-value">67 Across 4 Orgs</span></div>
              <div class="stat-box"><span class="stat-label">Oral History</span><span class="stat-value">218 Transcripts</span></div>
            BLOCK
          elsif idx == 2
            <<~BLOCK
              <div class="stat-box"><span class="stat-label">2011 Hallway Capture</span><span class="stat-value">MacBook Pro Photo Booth</span></div>
              <div class="stat-box"><span class="stat-label">February 2011</span><span class="stat-value">Commit 9d367da0 (POSIX)</span></div>
              <div class="stat-box"><span class="stat-label">September 2014</span><span class="stat-value">Coderwall PG Migration</span></div>
              <div class="stat-box"><span class="stat-label">Hardware Lineage</span><span class="stat-value">Physical Camera Survives</span></div>
            BLOCK
          elsif idx == 3
            <<~BLOCK
              <div class="stat-box"><span class="stat-label">L0 Silicon</span><span class="stat-value">Apple Silicon M4 Metal</span></div>
              <div class="stat-box"><span class="stat-label">L1 Kernel</span><span class="stat-value">Darwin jemalloc Seams</span></div>
              <div class="stat-box"><span class="stat-label">L4 Pipeline</span><span class="stat-value">Rails 8 SolidQueue</span></div>
              <div class="stat-box"><span class="stat-label">Knowledge Graph</span><span class="stat-value">9,600+ AST Nodes</span></div>
            BLOCK
          elsif idx == 4
            <<~BLOCK
              <div class="stat-box"><span class="stat-label">Queue FSM</span><span class="stat-value">5-State Maildir Invariant</span></div>
              <div class="stat-box"><span class="stat-label">Subprocess</span><span class="stat-value">ztranscribe Isolation</span></div>
              <div class="stat-box"><span class="stat-label">Storage Waste</span><span class="stat-value">0 Bytes Permanent SSD</span></div>
              <div class="stat-box"><span class="stat-label">Whisper Metal</span><span class="stat-value">103s Local Benchmark</span></div>
            BLOCK
          else
            <<~BLOCK
              <div class="stat-box"><span class="stat-label">Searle's Thesis</span><span class="stat-value">The Chinese Room</span></div>
              <div class="stat-box"><span class="stat-label">Cunningham's Paradox</span><span class="stat-value">The Honeycomb Wax</span></div>
              <div class="stat-box"><span class="stat-label">Inquiry Target</span><span class="stat-value">Theseus at the Desk</span></div>
              <div class="stat-box"><span class="stat-label">Physical Mast</span><span class="stat-value">Live Camera Lens</span></div>
            BLOCK
          end}
        </div>
      </div>

      <div class="footer">
        <div class="speaker-badge">
          <span>SPEAKER:</span>
          <span style="color: #38bdf8;">PAVEL (PANORAMIC VIEW SPECIALIST)</span>
        </div>
        <div>RECORDED TELEMETRY // STUDIO WORKBENCH EPISODE 01</div>
        <div>AUTHENTICITY HASH: VERIFIED INVARIANTS</div>
      </div>
    </body>
    </html>
  HTML
  
  File.write(html_path, html_content)
  
  # 3. Screenshot with Headless Chrome
  system(
    CHROME_BIN,
    '--headless',
    '--disable-gpu',
    "--screenshot=#{png_path}",
    '--window-size=1920,1080',
    '--hide-scrollbars',
    "file://#{html_path}",
    out: File::NULL,
    err: File::NULL
  )
  puts "  Rendered 1080p HUD slide: #{png_path}"
  
  # 4. Compile Act Video Segment
  segment_mp4 = File.join(DEPOSITION_DIR, "segment_#{idx}.mp4")
  # Loop slide image for exact duration of wav audio
  ffmpeg_cmd = [
    'ffmpeg', '-y',
    '-loop', '1',
    '-framerate', '30',
    '-i', png_path,
    '-i', wav_path,
    '-c:v', 'libx264',
    '-tune', 'stillimage',
    '-c:a', 'aac',
    '-b:a', '192k',
    '-pix_fmt', 'yuv420p',
    '-shortest',
    segment_mp4
  ]
  system(*ffmpeg_cmd, out: File::NULL, err: File::NULL)
  puts "  Compiled video segment: #{segment_mp4}"
  segment_files << segment_mp4
end

# 5. Concatenate all segments into master MP4
concat_list = File.join(DEPOSITION_DIR, 'concat_list.txt')
File.open(concat_list, 'w') do |f|
  segment_files.each do |sf|
    f.puts "file '#{File.basename(sf)}'"
  end
end

puts "\nConcatenating segments into unified master video..."
Dir.chdir(DEPOSITION_DIR) do
  system(
    'ffmpeg', '-y',
    '-f', 'concat',
    '-safe', '0',
    '-i', 'concat_list.txt',
    '-c', 'copy',
    OUTPUT_MP4,
    out: File::NULL,
    err: File::NULL
  )
end

puts "Master Deposition MP4 generated: #{OUTPUT_MP4}"

# Copy to media directory
FileUtils.cp(OUTPUT_MP4, MEDIA_MP4)
puts "Copied to OBS media directory: #{MEDIA_MP4}"

# Stage in media-pipeline staged queue
pipeline_dest = File.join(STAGED_DIR, 'the_systems_deposition.mp4')
FileUtils.cp(OUTPUT_MP4, pipeline_dest)
puts "Staged in media-pipeline queue: #{pipeline_dest}"

puts "\n=================================================================="
puts " ✅ SYSTEM CARTOGRAPHY DEPOSITION READY FOR PRODUCTION"
puts "=================================================================="
puts "File: #{OUTPUT_MP4}"
puts "=================================================================="
