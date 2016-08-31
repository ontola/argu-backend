# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = ::VERSION

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

Rails.application.config.assets.initialize_on_precompile = true
Rails.application.config.assets.paths << Rails.root.join('app', 'assets', 'webpack')
Rails.application.config.assets.paths << Rails.root.join('lib', 'assets', 'javascripts')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += %w(
  polyfill.js server-bundle.js components.js
  mail.css testing.css
)

type = ENV['REACT_ON_RAILS_ENV'] == 'HOT' ? 'non_webpack' : 'static'
Rails.application.config.assets.precompile += %W(application_#{type}.js application_#{type}.css)
