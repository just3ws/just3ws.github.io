require 'yaml'
require 'fileutils'

interviews_path = '_data/interviews.yml'
assets_path = '_data/video_assets.yml'
transcripts_dir = '_data/transcripts'

interviews_data = YAML.safe_load(File.read(interviews_path), permitted_classes: [Date, Time], aliases: true)
assets_data = YAML.safe_load(File.read(assets_path), permitted_classes: [Date, Time], aliases: true)

def slugify(text)
  return "" unless text
  text.downcase.gsub(/[^a-z0-9]+/, '-').gsub(/^-|-$/, '')
end

interviews_data['items'].each do |interview|
  old_id = interview['id']
  next unless old_id.start_with?('youtube-')

  # Generate new slug
  names = Array(interview['interviewees']).map { |n| slugify(n) }.join('-and-')
  context = slugify(interview['conference'])
  context = slugify(interview['community']) if context.empty?
  context = "general" if context.empty?
  year = interview['conference_year'].to_s.strip
  
  new_id_parts = [names, context]
  new_id_parts << year unless year.empty?
  new_id = new_id_parts.reject(&:empty?).join('-')

  # Ensure uniqueness (simple append if exists)
  original_new_id = new_id
  counter = 2
  while interviews_data['items'].any? { |i| i['id'] == new_id && i != interview }
    new_id = "#{original_new_id}-#{counter}"
    counter += 1
  end

  puts "Migrating: #{old_id} -> #{new_id}"

  # 1. Update interview ID
  interview['id'] = new_id

  # 2. Update Video Asset
  asset = assets_data['items'].find { |a| a['interview_id'] == old_id }
  if asset
    asset['interview_id'] = new_id
    if asset['id'] == old_id
      asset['id'] = new_id
    end
    
    # 3. Update Transcript File if it exists
    if asset['transcript_id'] == old_id
      old_transcript_path = File.join(transcripts_dir, "#{old_id}.yml")
      new_transcript_path = File.join(transcripts_dir, "#{new_id}.yml")
      
      if File.exist?(old_transcript_path)
        FileUtils.mv(old_transcript_path, new_transcript_path)
        puts "  Moved transcript: #{old_transcript_path} -> #{new_transcript_path}"
      end
      
      asset['transcript_id'] = new_id
    end
  end
end

File.write(interviews_path, interviews_data.to_yaml)
File.write(assets_path, assets_data.to_yaml)

puts "Migration complete."
