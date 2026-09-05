# frozen_string_literal: true

require 'image_optim'
require 'image_optim_pack'

Jekyll::Hooks.register :site, :post_write do |site|
  # Verification builds consume committed assets. Re-optimizing them here is
  # expensive and does not change tracked source, so the committed-artifact
  # pipeline can opt out while full local builds retain the quality pass.
  next if Jekyll.env == 'development' || ENV['SKIP_IMAGE_OPTIMIZATION'] == 'true'

  image_optim = ImageOptim.new(
    advpng: false, # slow
    gifsicle: true,
    jhead: true,
    jpegoptim: true,
    jpegrecompress: true,
    jpegtran: true,
    optipng: true,
    pngcrush: true,
    pngout: false, # slow
    pngquant: true,
    svgo: true
  )

  assets_dir = File.join(site.dest, 'assets')
  next unless Dir.exist?(assets_dir)

  puts "Optimizing images in #{assets_dir}..."
  
  image_optim.optimize_images!(Dir.glob(File.join(assets_dir, '**', '*.{png,jpg,jpeg,gif,svg}'))) do |src, dst|
    if dst
      percent = (100 - (File.size(dst).to_f / File.size(src) * 100)).round(2)
      puts "  Optimized #{File.basename(src)} (#{percent}% smaller)"
    end
  end
end
