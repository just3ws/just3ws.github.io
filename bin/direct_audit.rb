require 'yaml'
require 'fileutils'

def process(slug)
  interviews = YAML.safe_load(File.read('_data/interviews.yml'), permitted_classes: [Date, Time], aliases: true)
  interview = interviews['items'].find { |i| i['id'] == slug }
  
  asset = YAML.safe_load(File.read('_data/video_assets.yml'), permitted_classes: [Date, Time], aliases: true)['items'].find { |a| a['id'] == interview['video_asset_id'] }
  transcript_path = "_data/transcripts/#{asset['transcript_id']}.yml"
  
  # Check if already processed (has 'turns')
  payload = YAML.safe_load(File.read(transcript_path), permitted_classes: [Date, Time], aliases: true)
  return puts "Already processed: #{slug}" if payload['turns']

  puts "Audit needed for: #{slug}"
end

slugs = ['interview-with-anthony-zinni-and-jon-buda-and-shay-howe-general', 'interview-with-anna-lear-general', 'interview-with-james-edward-gray-ii-general']
slugs.each { |s| process(s) }
