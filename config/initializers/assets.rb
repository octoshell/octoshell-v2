# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )
# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.1'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )

Rails.application.config.assets.precompile += %w( favicon.ico )
Rails.application.config.assets.precompile += %w( apple-touch-icon-precomposed.png )
Rails.application.config.assets.precompile += %w( *.png )
Rails.application.config.assets.precompile += %w( catch_all.css )

# Rails.root.join('/app/assets/stylesheets').glob('*.css').each{|d|
#   Rails.application.config.assets.precompile += [d.to_s]
# }
#
# Rails.root.join('app/assets/javascripts').glob('*.js').each{|d|
# #  warn "JS+ #{d}"
#   Rails.application.config.assets.precompile += [d.to_s]
# }
#
# Rails.root.glob('engines/*/app/assets/javascripts/*').each{|dir|
#   dir.glob('*.js').each{|f|
#     Rails.application.config.assets.precompile += [f.to_s]
#   }
#   dir.glob('*.coffee').each{|f|
#     Rails.application.config.assets.precompile += [f.to_s]
#   }
# }
# Rails.root.glob('engines/*/app/assets/stylesheets/*').each{|dir|
#   dir.glob('*.css').each{|f|
#     Rails.application.config.assets.precompile += [f.to_s]
#   }
#   dir.glob('*.scss').each{|f|
#     Rails.application.config.assets.precompile += [f.to_s]
#   }
# }

dirs = Rails.root.glob('engines/*/app/assets/config/*/manifest.js').map do |dir|
   "//=link #{dir.to_s.split('/')[-2]}/manifest.js"
end.join("\n")

File.write("#{Rails.root}/app/assets/config/manifest.js",
           File.read("#{Rails.root}/app/assets/config/manifest.js").sub(/\/\/\s*START.*\z/m, "// START\n" + dirs))
