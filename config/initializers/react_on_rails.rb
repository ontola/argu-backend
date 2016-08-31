# Shown below are the defaults for configuration

ReactOnRails.configure do |config|
  # Client bundles are configured in application.js
  # Directory where your generated assets go
  config.generated_assets_dir = File.join(%w(app assets webpack))

  # Define the files for we need to check for webpack compilation when running tests
  config.webpack_generated_files = %w(client-bundle.js server-bundle.js)
  # Server rendering:
  # Server bundle is a single file for all server rendering of components.
  # Set the server_bundle_js_file to "" if you know that you will not be server rendering.
  config.server_bundle_js_file = 'server-bundle.js'
  # If set to true, this forces Rails to reload the server bundle if it is modified
  config.development_mode = Rails.env.development?
  # For server rendering. This can be set to false so that server side messages are discarded.
  # Default is true. Be cautious about turning this off.
  config.replay_console = true
  # Default is true. Logs server rendering messags to Rails.logger.info
  config.logging_on_server = true
  # change to true to raise exception on server if the JS code throws
  config.raise_on_prerender_error = true
  # Server rendering only (not for render_component helper)
  # You can configure your pool of JS virtual machines and specify where it should load code:
  # On MRI, use `therubyracer` for the best performance
  # (see [discussion](https://github.com/reactjs/react-rails/pull/290))
  # On MRI, you'll get a deadlock with `pool_size` > 1
  # If you're using JRuby, you can increase `pool_size` to have real multi-threaded rendering.
  config.server_renderer_pool_size = 1 # increase if you're on JRuby
  config.server_renderer_timeout = 50 # seconds
  # The following options can be overriden by passing to the helper method:
  # Default is false
  config.prerender = true
  # Default is true for development, off otherwise
  config.trace = Rails.env.development?
  ################################################################################
  # MISCELLANEOUS OPTIONS
  ################################################################################
  # Default is false, enable if your content security policy doesn't include `style-src: 'unsafe-inline'`
  config.skip_display_none = true

  # This allows you to add additional values to the Rails Context. Implement one static method
  # called `custom_context(view_context)` and return a Hash.
  config.rendering_extension = nil

  # The server render method - either ExecJS or NodeJS
  config.server_render_method = 'ExecJS'

  # Client js uses assets not digested by rails.
  # For any asset matching this regex, non-digested symlink will be created
  # To disable symlinks set this parameter to nil.
  config.symlink_non_digested_assets_regex = /\.(png|jpg|jpeg|gif|tiff|woff|ttf|eot|svg)/
end
