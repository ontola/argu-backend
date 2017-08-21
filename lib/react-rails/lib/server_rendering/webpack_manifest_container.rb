# frozen_string_literal: true

module React
  module ServerRendering
    class WebpackerManifestContainer
      def find_asset(logical_path)
        path = ::Rails.root.join(File.join(Webpacker::Configuration.output_path, '/pre-render/manifest.json'))
        full_path = ::Rails.root.join(JSON.parse(File.read(path))[logical_path.to_s])

        return File.read(full_path) if full_path
        # do original find_asset stuff

        # raises if not found
        asset_path = Webpacker::Manifest.lookup(logical_path).to_s
        if asset_path.start_with?('http')
          # Get a file from the webpack-dev-server
          dev_server_asset = open(asset_path).read
          # Remove `webpack-dev-server/client/index.js` code which causes ExecJS to
          dev_server_asset.sub!(CLIENT_REQUIRE, '//\0')
          dev_server_asset
        else
          # Read the already-compiled pack:
          full_path = Webpacker::Manifest.lookup_path(logical_path).to_s
          File.read(full_path)
        end
      end
    end
  end
end
