require 'yaml'

interviews_path = '_data/interviews.yml'
assets_path = '_data/video_assets.yml'

interviews = YAML.safe_load(File.read(interviews_path), permitted_classes: [Date, Time], aliases: true)
assets = YAML.safe_load(File.read(assets_path), permitted_classes: [Date, Time], aliases: true)

mapping = {
  'aaron-holbrook-general' => "Building Community from Scratch: Aaron Holbrook on WordPress User Groups and WordCamps",
  'andrea-magnorsky-general' => "From Prototypes to Podcasts: Andrea Magnorsky on Game Jams, Alt.NET, and Community Hand-offs",
  'angelique-martin-general' => "Crafting a Community: Angelique Martin on Organizing Software Craftsmanship North America",
  'arthur-kay-general' => "Building Corporate Communities: Arthur Kay on Sencha, Ext JS, and Local Meetups"
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
