# frozen_string_literal: true

# Get asset content by reading the compiled file from disk using a Sprockets::Manifest.
#
# This is good for Rails production when assets are compiled to public/assets
# but sometimes, they're compiled to other directories (or other servers)
class ManifestContainer
  def initialize
    @manifest = ::Rails.application.assets_manifest
  end

  def find_asset(logical_path)
    asset_path = @manifest.assets[logical_path] || raise("No compiled asset for #{logical_path}, was it precompiled?")
    asset_full_path = ::Rails.root.join('public', @manifest.directory, asset_path)
    File.read(asset_full_path)
  end
end
