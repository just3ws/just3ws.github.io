#!/usr/bin/env ruby
# frozen_string_literal: true

# ==============================================================================
# bin/episode_workbench.rb
#
# Episode Semantic Dossier & Production Workbench CLI for "The Sound Above".
# Manages structured episode dossiers (narrative, lexicon, human stories,
# research attachments, workflow tasks) and compiles blended teleprompter
# rundowns for live OBS broadcasting and YouTube syndication.
# ==============================================================================

require 'json'
require 'yaml'
require 'fileutils'
require 'optparse'
require 'erb'

class EpisodeWorkbench
  ROOT_DIR = File.expand_path('..', __dir__)
  EPISODES_DIR = File.join(ROOT_DIR, '_data', 'episodes')
  TEMPLATES_DIR = File.join(ROOT_DIR, 'bin', 'templates', 'teleprompter')
  SEQUENCE_PATH = File.join(ROOT_DIR, '_data', 'sound_above_sequence.json')
  TRANSCRIPTS_DIR = File.join(ROOT_DIR, '_data', 'transcripts')
  OVERLAY_STATE_PATH = File.join(ROOT_DIR, 'obs', 'overlays', 'overlay-state.json')

  def initialize
    FileUtils.mkdir_p(EPISODES_DIR)
    @sequence_data = load_sequence
  end

  def run(args = ARGV)
    command = args.shift || 'help'

    case command
    when 'list', 'status'
      list_episodes
    when 'init', 'scaffold'
      init_dossiers(args)
    when 'show', 'view'
      show_dossier(args.first)
    when 'compile', 'render', 'script'
      compile_episode(args)
    when 'validate', 'audit'
      validate_dossiers
    when 'workshop'
      workshop_episode(args)
    when 'cue'
      cue_episode(args.first)
    when 'help', '--help', '-h'
      print_help
    else
      warn "Unknown command: #{command}"
      print_help
      exit 1
    end
  end

  # Lists all 35 episodes with narrative completeness, human story status, and attachments
  def list_episodes
    puts '=================================================================='
    puts ' 🎙️ THE SOUND ABOVE: EPISODE SEMANTIC DOSSIERS'
    puts '=================================================================='
    printf "%-4s %-24s %-28s %-10s %-8s %s\n", 'EP', 'INTERVIEWEE', 'CONFERENCE', 'STATUS', 'STORIES', 'ATTACHMENTS'
    puts '------------------------------------------------------------------'

    episodes = @sequence_data['episodes'] || []
    pilot_dossier = load_dossier(0)
    if pilot_dossier
      p_status = pilot_dossier['status'] || 'scheduled'
      p_stories = pilot_dossier.dig('human_marginalia', 'host_recollections') ? pilot_dossier['human_marginalia']['host_recollections'].size : 0
      p_attach = pilot_dossier['research_attachments'] ? pilot_dossier['research_attachments'].size : 0
      p_badge = case p_status
                when 'published' then '[PUB]'
                when 'cued' then '[CUED]'
                when 'scheduled' then '[SCHED]'
                when 'workshop' then '[WORK]'
                else '[PLAN]'
                end
      printf "%02d   %-24s %-28s %-10s %-8s %s\n",
             0,
             pilot_dossier['interviewee'].to_s[0..22],
             "#{pilot_dossier['conference']} (#{pilot_dossier['year']})"[0..26],
             p_badge,
             "#{p_stories} note#{p_stories == 1 ? '' : 's'}",
             "#{p_attach} link#{p_attach == 1 ? '' : 's'}"
    end

    episodes.each do |ep|
      num = ep['number']
      dossier = load_dossier(num)

      status = dossier ? dossier['status'] : ep['status'] || 'planned'
      stories_count = dossier && dossier.dig('human_marginalia', 'host_recollections') ? dossier['human_marginalia']['host_recollections'].size : 0
      attach_count = dossier && dossier['research_attachments'] ? dossier['research_attachments'].size : 0

      interviewee = ep['interviewee'].to_s[0..22]
      conf = "#{ep['conference']} (#{ep['year']})"[0..26]

      status_badge = case status
                     when 'published' then '[PUB]'
                     when 'cued' then '[CUED]'
                     when 'scheduled' then '[SCHED]'
                     when 'workshop' then '[WORK]'
                     else '[PLAN]'
                     end

      printf "%02d   %-24s %-28s %-10s %-8s %s\n",
             num,
             interviewee,
             conf,
             status_badge,
             "#{stories_count} note#{stories_count == 1 ? '' : 's'}",
             "#{attach_count} link#{attach_count == 1 ? '' : 's'}"
    end
    puts '=================================================================='
    puts "Total: #{episodes.size} episodes across 6 historical movements."
    puts "Run `bin/episode_workbench.rb show <ep>` to inspect an episode dossier."
    puts "Run `bin/episode_workbench.rb compile <ep>` to generate a teleprompter rundown."
    puts '=================================================================='
  end

  # Scaffolds or initializes episode dossiers from sequence manifest
  def init_dossiers(args)
    target = args.first
    episodes = @sequence_data['episodes'] || []

    if target && target != '--all'
      num = target.to_i
      ep = episodes.find { |e| e['number'] == num }
      if ep
        init_single_dossier(ep, overwrite: args.include?('--force'))
      else
        warn "Error: Episode #{num} not found in sequence manifest."
      end
    else
      episodes.each do |ep|
        init_single_dossier(ep, overwrite: args.include?('--force'))
      end
      puts "Successfully initialized dossiers in #{EPISODES_DIR}."
    end
  end

  # Displays the detailed semantic dossier for a given episode
  def show_dossier(target)
    unless target
      warn 'Usage: bin/episode_workbench.rb show <episode_number>'
      exit 1
    end

    num = target.to_i
    dossier = load_or_build_dossier(num)

    unless dossier
      warn "Error: Episode #{num} not found."
      exit 1
    end

    puts '=================================================================='
    puts " 📜 SEMANTIC DOSSIER: EPISODE #{dossier['episode']}: #{dossier['title']}"
    puts '=================================================================='
    puts "Interviewee: #{dossier['interviewee']} (#{dossier['conference']}, #{dossier['year']})"
    puts "Era:         #{dossier['era_name']}"
    puts "Status:      #{dossier['status']}"
    puts "Target Date: #{dossier['target_broadcast_date'] || 'Unscheduled'}"
    puts '------------------------------------------------------------------'
    puts '📖 NARRATIVE ANATOMY'
    puts "  Theme:        #{dossier.dig('narrative', 'theme')}"
    puts "  Tone:         #{dossier.dig('narrative', 'tone')}"
    puts "  Topic:        #{dossier.dig('narrative', 'topic')}"
    puts "  Core Inquiry: #{dossier.dig('narrative', 'core_inquiry')}"
    puts "  Modern Echo:  #{dossier.dig('narrative', 'ai_era_parallel')}"
    puts '------------------------------------------------------------------'
    puts '🏷️ SEMANTIC LEXICON'
    concepts = dossier.dig('lexicon', 'key_concepts') || []
    triggers = dossier.dig('lexicon', 'trigger_words') || []
    puts "  Key Concepts:  #{concepts.join(', ')}"
    puts "  Trigger Words: #{triggers.join(', ')}"
    puts '------------------------------------------------------------------'
    puts '📝 HUMAN MARGINALIA & RECOLLECTIONS'
    stories = dossier.dig('human_marginalia', 'host_recollections') || []
    if stories.empty?
      puts '  (No personal stories added yet. Edit file to add memories/reflections.)'
    else
      stories.each_with_index do |s, idx|
        puts "  [#{idx + 1}] #{s['scene']}: #{s['story']}"
      end
    end
    prompts = dossier.dig('human_marginalia', 'workshop_prompts') || []
    if prompts.any?
      puts '  Workshop Prompts:'
      prompts.each { |p| puts "    • #{p}" }
    end
    puts '------------------------------------------------------------------'
    puts '📎 RESEARCH ATTACHMENTS & CITATIONS'
    attachments = dossier['research_attachments'] || []
    if attachments.empty?
      puts '  (No research attachments linked yet.)'
    else
      attachments.each do |att|
        puts "  • [#{att['type']}] #{att['title']}: #{att['url'] || att['path']}"
      end
    end
    puts '=================================================================='
  end

  # Compiles the blended 6-act teleprompter script
  def compile_episode(args)
    target = args.first
    unless target
      warn 'Usage: bin/episode_workbench.rb compile <episode_number> [--markdown|--json]'
      exit 1
    end

    num = target.to_i
    format = args.include?('--json') ? :json : (args.include?('--markdown') ? :markdown : :text)
    dossier = load_or_build_dossier(num)

    unless dossier
      warn "Error: Episode #{num} not found."
      exit 1
    end

    rundown = generate_rundown(dossier)

    case format
    when :json
      puts JSON.pretty_generate(rundown)
    when :markdown
      output_markdown_rundown(rundown)
    else
      output_text_rundown(rundown)
    end
  end

  # Validates all dossiers against schemas and invariants (e.g. zero em dashes)
  def validate_dossiers
    puts '=================================================================='
    puts ' 🔍 VALIDATING EPISODE SEMANTIC DOSSIERS'
    puts '=================================================================='

    violations = []
    em_dash_violations = []
    dossier_files = Dir.glob(File.join(EPISODES_DIR, 'episode-*.yml')).sort

    if dossier_files.empty?
      puts '[WARN] No dossier files found in _data/episodes/. Run `bin/episode_workbench.rb init`.'
      return
    end

    dossier_files.each do |f|
      content = File.read(f)
      rel_path = f.sub("#{ROOT_DIR}/", '')

      if content.include?("\u2014") || content.match?(/ -- /)
        em_dash_violations << rel_path
      end

      data = YAML.safe_load(content, permitted_classes: [Date, Time], aliases: true) rescue nil
      unless data && data.is_a?(Hash)
        violations << "#{rel_path}: Invalid YAML formatting"
        next
      end

      # Required top-level fields
      %w[episode title interviewee conference era_name narrative].each do |req|
        violations << "#{rel_path}: Missing required field '#{req}'" unless data[req]
      end
    end

    if em_dash_violations.any?
      puts "[FAIL] Em-dash violations found in: #{em_dash_violations.join(', ')}"
    else
      puts "[PASS] 100% em-dash clean across all #{dossier_files.size} episode dossiers."
    end

    if violations.any?
      puts "[FAIL] Schema validation issues:"
      violations.each { |v| puts "  • #{v}" }
      exit 1
    else
      puts "[PASS] All #{dossier_files.size} episode dossiers conform to semantic schema."
      puts '=================================================================='
    end
  end

  # Cues the episode into OBS overlay state
  def cue_episode(target)
    unless target
      warn 'Usage: bin/episode_workbench.rb cue <episode_number>'
      exit 1
    end

    num = target.to_i
    dossier = load_or_build_dossier(num)
    unless dossier
      warn "Error: Episode #{num} not found."
      exit 1
    end

    if File.exist?(OVERLAY_STATE_PATH)
      state = JSON.parse(File.read(OVERLAY_STATE_PATH))
      state['active_archetype'] = 'THE_SOUND_ABOVE'
      state['active_series'] = 'The Sound Above'
      state['stream_title'] = "Episode #{dossier['episode']}: #{dossier['title']}"
      state['interviewee_name'] = dossier['interviewee']
      state['conference_name'] = "#{dossier['conference']} (#{dossier['year']})"
      state['interview_topic'] = dossier.dig('narrative', 'theme') || dossier['title']
      state['sound_above_prompt'] = dossier.dig('narrative', 'core_inquiry') || ''
      state['sound_above_episode'] = dossier['episode']
      state['sound_above_movement'] = dossier['era_name']

      File.write(OVERLAY_STATE_PATH, JSON.pretty_generate(state) + "\n")
      puts "Successfully cued Episode #{num} into OBS overlay state (#{OVERLAY_STATE_PATH})."
    else
      warn "Overlay state not found at #{OVERLAY_STATE_PATH}."
    end
  end

  # Workshops an episode with custom prompt guidance and re-evaluates teleprompter copy
  def workshop_episode(args)
    target = args.first
    unless target
      warn 'Usage: bin/episode_workbench.rb workshop <episode_number> [--prompt "..." | --regenerate]'
      exit 1
    end

    num = target.to_i
    dossier = load_or_build_dossier(num)
    unless dossier
      warn "Error: Episode #{num} not found."
      exit 1
    end

    prompt_idx = args.index('--prompt')
    if prompt_idx && args[prompt_idx + 1]
      new_prompt = args[prompt_idx + 1]
      dossier['human_marginalia'] ||= {}
      dossier['human_marginalia']['workshop_prompts'] ||= []
      dossier['human_marginalia']['workshop_prompts'] << new_prompt
      puts "Added workshop prompt to Episode #{num}: \"#{new_prompt}\""
    end

    # Save updated dossier preserving all recollections and attachments
    path = dossier_path(num)
    yaml_str = YAML.dump(dossier).gsub("\u2014", ' - ')
    File.write(path, yaml_str)

    # Recompile rundown
    rundown = generate_rundown(dossier)
    puts '=================================================================='
    puts " 🛠️ WORKSHOP REGENERATED: EPISODE #{num} TELEPROMPTER RUNDOWN"
    puts '=================================================================='
    output_text_rundown(rundown)
  end

  private

  def load_sequence
    unless File.exist?(SEQUENCE_PATH)
      warn "Sequence manifest missing at #{SEQUENCE_PATH}"
      return { 'episodes' => [] }
    end
    JSON.parse(File.read(SEQUENCE_PATH))
  end

  def dossier_path(episode_num)
    formatted = sprintf('%02d', episode_num)
    File.join(EPISODES_DIR, "episode-#{formatted}.yml")
  end

  def load_dossier(episode_num)
    path = dossier_path(episode_num)
    return nil unless File.exist?(path)

    YAML.safe_load(File.read(path), permitted_classes: [Date, Time], aliases: true)
  end

  def load_or_build_dossier(episode_num)
    dossier = load_dossier(episode_num)
    return dossier if dossier

    episodes = @sequence_data['episodes'] || []
    ep = episodes.find { |e| e['number'] == episode_num }
    return nil unless ep

    build_default_dossier(ep)
  end

  def build_default_dossier(ep)
    num = ep['number']
    formatted = sprintf('%02d', num)

    {
      'episode' => num,
      'series' => 'The Sound Above',
      'title' => ep['title'],
      'status' => ep['status'] || 'planned',
      'interviewee' => ep['interviewee'],
      'conference' => ep['conference'],
      'year' => ep['year'],
      'location' => ep['location'],
      'slug' => ep['slug'],
      'era_id' => ep['era_id'],
      'era_name' => ep['era_name'],
      'youtube_broadcast_id' => ep['youtube_broadcast_id'],
      'youtube_video_id' => ep['resolved_youtube_id'] || ep['youtube_video_id'],
      'target_broadcast_date' => nil,
      'narrative' => {
        'theme' => derive_theme(ep),
        'tone' => 'Reflective, forensic, and empathetic with craftsman rigor',
        'topic' => ep['title'],
        'plot_arc' => {
          'inciting_incident' => "The technical context and friction in #{ep['year']}",
          'rising_action' => 'The grassroots gathering or breakthrough hallway discussion',
          'climax' => 'The core insight or shift in engineering discipline',
          'resolution' => 'The lasting influence on software craft and practice'
        },
        'core_inquiry' => ep['sound_above_inquiry'],
        'chicago_context' => ep['chicago_context'],
        'ai_era_parallel' => ep['ai_era_parallel']
      },
      'lexicon' => {
        'key_concepts' => derive_concepts(ep),
        'trigger_words' => [ep['interviewee'].split.last, ep['conference'].split.first, 'Craftsmanship'].compact,
        'hashtags' => ['#SoftwareCraftsmanship', '#TheSoundAbove', '#OralHistory', '#SystemCartography']
      },
      'human_marginalia' => {
        'host_recollections' => [],
        'workshop_prompts' => [
          "Connect the #{ep['year']} conversation directly to current engineering challenges.",
          'Ground the technical critique in practitioner empathy.'
        ]
      },
      'research_attachments' => [
        {
          'title' => "#{ep['interviewee']} Interview Profile",
          'type' => 'site_archive_page',
          'url' => "https://just3ws.com/interviews/#{ep['slug']}/"
        }
      ],
      'workflow_tasks' => {
        'autonomous' => [
          { 'task' => 'Whisper transcript alignment', 'status' => 'done' },
          { 'task' => 'Staged metadata generation', 'status' => 'done' },
          { 'task' => 'YouTube caption synchronization', 'status' => 'pending' }
        ],
        'human' => [
          { 'task' => 'Workshop personal recollections', 'status' => 'pending' },
          { 'task' => 'Pre-broadcast OBS audio rehearsal', 'status' => 'pending' },
          { 'task' => 'Live rewatch broadcast', 'status' => 'pending' }
        ]
      }
    }
  end

  def derive_theme(ep)
    inquiry = ep['sound_above_inquiry'].to_s
    if inquiry.include?('monolith') || inquiry.include?('enterprise')
      'Escaping Enterprise Monoliths & Grassroots Autonomy'
    elsif inquiry.include?('apprenticeship') || inquiry.include?('mentor')
      'Apprenticeship, Deliberate Practice & Engineering Lineage'
    elsif inquiry.include?('hospitality') || inquiry.include?('community')
      'Community Hospitality & Radical Practitioner Inclusion'
    elsif inquiry.include?('testing') || inquiry.include?('feedback')
      'Sub-Second Feedback Loops & The Discipline of Testing'
    elsif inquiry.include?('simplicity') || inquiry.include?('architecture')
      'Deconstructing Complexity & Architectures of Simplicity'
    else
      ep['title']
    end
  end

  def derive_concepts(ep)
    concepts = ['Software Craftsmanship', ep['era_name']]
    inquiry = ep['sound_above_inquiry'].to_s.downcase
    concepts << 'Deliberate Practice' if inquiry.include?('practice') || inquiry.include?('kata')
    concepts << 'Apprenticeship' if inquiry.include?('apprenticeship') || inquiry.include?('mentor')
    concepts << 'Sub-Second Feedback' if inquiry.include?('feedback') || inquiry.include?('test')
    concepts << 'Simplicity' if inquiry.include?('simple') || inquiry.include?('complexity')
    concepts << 'Community Hospitality' if inquiry.include?('community') || inquiry.include?('hospitality')
    concepts.uniq
  end

  def init_single_dossier(ep, overwrite: false)
    path = dossier_path(ep['number'])
    if File.exist?(path) && !overwrite
      puts "Skipping existing dossier: #{path}"
      return
    end

    dossier = build_default_dossier(ep)
    yaml_str = YAML.dump(dossier)
    # Ensure zero em dashes
    yaml_str = yaml_str.gsub("\u2014", ' - ')
    File.write(path, yaml_str)
    puts "Created dossier: #{path}"
  end

  def generate_rundown(dossier)
    ep_num = dossier['episode']
    stories = dossier.dig('human_marginalia', 'host_recollections') || []
    attachments = dossier['research_attachments'] || []

    act1_story = stories.find { |s| s['scene']&.include?('Act 1') || s['scene']&.include?('Cold Open') }
    act2_story = stories.find { |s| s['scene']&.include?('Act 2') || s['scene']&.include?('Setting') }
    act4_story = stories.find { |s| s['scene']&.include?('Act 4') || s['scene']&.include?('Hallway') }
    act5_story = stories.find { |s| s['scene']&.include?('Act 5') || s['scene']&.include?('AI-Era') || s['scene']&.include?('Workbench') }

    act1_default = "Welcome back to The Sound Above. I am Mike Hall. Today we enter #{dossier['era_name']}. Before automated code synthesis and agent workflows, developers met face to face to establish standards of craftsmanship. Today we rewatch Episode #{ep_num}: #{dossier['interviewee']} recorded at #{dossier['conference']}."
    act1_default += " [PERSONAL RECOLLECTION: #{act1_story['story']}]" if act1_story

    act2_default = "#{dossier.dig('narrative', 'chicago_context')} When we recorded this in #{dossier['year']} at #{dossier['location']}, practitioners were breaking out of vendor silos and defining the discipline for themselves."
    act2_default += " [SETTING RECOLLECTION: #{act2_story['story']}]" if act2_story

    act3_default = "#{dossier.dig('narrative', 'core_inquiry')} Who inspired #{dossier['interviewee']} before they stepped onto this stage? What records were playing in the background when this movement formed?"

    act4_default = "Roll archive footage (YouTube ID: #{dossier['youtube_video_id']}). Watch for the unvarnished hallway exchanges, the emphasis on craft over speed, and the sheer enthusiasm of engineers taking responsibility for their software."
    act4_default += " [ARCHIVE OBSERVATION: #{act4_story['story']}]" if act4_story

    act5_default = "#{dossier.dig('narrative', 'ai_era_parallel')} When implementation is cheap, verification and clarity become everything. We cannot accept the mirage of competence. Let us inspect the code contracts directly."
    act5_default += " [WORKBENCH STORY: #{act5_story['story']}]" if act5_story
    if attachments.any?
      act5_default += " Cited references: " + attachments.map { |a| "#{a['title']} (#{a['url'] || a['path']})" }.join('; ')
    end

    next_num = (ep_num % 35) + 1
    act6_default = "Thank you for joining today's session. Full transcripts, provenance notes, and companion research are available at just3ws.com. To help underwrite our independent compute, hosting, and digital archive preservation, support us on Patreon at patreon.com/whoistechcmty. In our next broadcast, we explore Episode #{next_num}. Until next time, keep your feedback loops fast and your code humane."

    b = binding
    act1_script = render_template_act('act_01_cold_open.erb', b, act1_default)
    act2_script = render_template_act('act_02_setting.erb', b, act2_default)
    act3_script = render_template_act('act_03_inquiry.erb', b, act3_default)
    act4_script = render_template_act('act_04_rewatch.erb', b, act4_default)
    act5_script = render_template_act('act_05_workbench.erb', b, act5_default)
    act6_script = render_template_act('act_06_outro.erb', b, act6_default)

    {
      episode_number: ep_num,
      era: dossier['era_name'],
      title: dossier['title'],
      interviewee: dossier['interviewee'],
      conference: "#{dossier['conference']} (#{dossier['year']})",
      location: dossier['location'],
      status: dossier['status'],
      theme: dossier.dig('narrative', 'theme'),
      acts: [
        {
          act_number: 1,
          name: 'Cold Open & Personal Grounding',
          scene_target: '01. Starting Soon -> 02. Monologue / Full Camera',
          timing: '00:00 - 03:00',
          host_lead: 'Welcome to The Sound Above. I am Mike Hall.',
          teleprompter_script: act1_script
        },
        {
          act_number: 2,
          name: 'Setting the Historical Scene',
          scene_target: '02. Monologue / Full Camera',
          timing: '03:00 - 08:00',
          host_lead: "Let us return to #{dossier['year']} in #{dossier['location']}.",
          teleprompter_script: act2_script
        },
        {
          act_number: 3,
          name: 'The Core Inquiry: The Sound Above',
          scene_target: '02. Monologue / Full Camera -> 04. Split Screen',
          timing: '08:00 - 14:00',
          host_lead: 'The question that guides our rewatch today:',
          teleprompter_script: act3_script
        },
        {
          act_number: 4,
          name: 'Hallway Rewatch & Video Reaction',
          scene_target: '03. Reaction - Video Focus',
          timing: '14:00 - 28:00',
          host_lead: 'Let us roll the archive tape.',
          teleprompter_script: act4_script
        },
        {
          act_number: 5,
          name: 'The AI-Era Parallel & Terminal Workbench',
          scene_target: '05. Workbench - Code & Terminal',
          timing: '28:00 - 40:00',
          host_lead: 'How does this lesson apply to software engineering in 2026?',
          teleprompter_script: act5_script
        },
        {
          act_number: 6,
          name: 'Community Coda, Outro & Next Stream',
          scene_target: '08. Outro & Next Stream',
          timing: '40:00 - 45:00',
          host_lead: 'Thank you for listening to the sound above.',
          teleprompter_script: act6_script
        }
      ]
    }
  end

  def output_text_rundown(rundown)
    puts '=================================================================='
    puts ' 🎙️ THE SOUND ABOVE: TELEPROMPTER & PRODUCTION RUNDOWN'
    puts '=================================================================='
    puts "Episode:     ##{rundown[:episode_number]}: #{rundown[:title]}"
    puts "Interviewee: #{rundown[:interviewee]}"
    puts "Conference:  #{rundown[:conference]} (#{rundown[:location]})"
    puts "Era:         #{rundown[:era]}"
    puts "Theme:       #{rundown[:theme]}"
    puts '------------------------------------------------------------------'
    rundown[:acts].each do |act|
      puts ''
      puts "▶ ACT #{act[:act_number]}: #{act[:name].upcase} [#{act[:timing]}]"
      puts "  Scene Cue: #{act[:scene_target]}"
      puts "  Prompt:    #{act[:teleprompter_script]}"
    end
    puts '=================================================================='
  end

  def output_markdown_rundown(rundown)
    puts "# Teleprompter Rundown: Episode #{rundown[:episode_number]}"
    puts "## #{rundown[:title]}"
    puts "**Era:** #{rundown[:era]} | **Guest:** #{rundown[:interviewee]} | **Provenance:** #{rundown[:conference]}\n\n"
    puts "**Theme:** #{rundown[:theme]}\n\n"
    rundown[:acts].each do |act|
      puts "### Act #{act[:act_number]}: #{act[:name]} (#{act[:timing]})"
      puts "*Target Scene:* `#{act[:scene_target]}`\n"
      puts "> **Lead:** #{act[:host_lead]}\n"
      puts "#{act[:teleprompter_script]}\n"
    end
  end

  def render_template_act(filename, ctx, fallback)
    path = File.join(TEMPLATES_DIR, filename)
    if File.exist?(path)
      ERB.new(File.read(path)).result(ctx).strip
    else
      fallback
    end
  rescue StandardError => e
    warn "Template render error for #{filename}: #{e.message}. Using fallback."
    fallback
  end

  def print_help
    puts <<~HELP
      Usage: bin/episode_workbench.rb <command> [options]

      Commands:
        list        List all 35 episodes with narrative completeness and story counts
        show <N>    Display semantic dossier for episode N
        compile <N> Compile 6-act teleprompter script (--markdown, --json)
        workshop <N> Workshop episode prompts and regenerate copy (--prompt "...")
        init        Scaffold missing episode dossiers from sequence manifest
        validate    Validate all 35 dossiers against schema and zero em-dash rules
        cue <N>     Cue episode into live OBS overlay state
        help        Show this message
    HELP
  end
end

if __FILE__ == $PROGRAM_NAME
  EpisodeWorkbench.new.run(ARGV)
end
