require 'yaml'

interviews_path = '_data/interviews.yml'
assets_path = '_data/video_assets.yml'

interviews = YAML.safe_load(File.read(interviews_path), permitted_classes: [Date, Time], aliases: true)
assets = YAML.safe_load(File.read(assets_path), permitted_classes: [Date, Time], aliases: true)

mapping = {
  'robert-martin-software-craftsmanship-north-america-2012' => "Filling the Vessel: Robert 'Uncle Bob' Martin on the Craft of Performance and Clean Coders",
  'avdi-grimm-general' => "The Art of Remote Pairing: Avdi Grimm on Ruby Tapas, Wide Teams, and Community",
  'corey-haines-general' => "Cranking Design to 11: Corey Haines on the Global Day of Code Retreat and the Art of Practice"
}

interviews['items'].each do |interview|
  if mapping.key?(interview['id'])
    new_title = mapping[interview['id']]
    puts "Updated: #{interview['title']} -> #{new_title}"
    interview['title'] = new_title
    
    asset = assets['items'].find { |a| a['id'] == interview['video_asset_id'] }
    asset['title'] = new_title if asset
  end
end

File.write(interviews_path, interviews.to_yaml)
File.write(assets_path, assets.to_yaml)
