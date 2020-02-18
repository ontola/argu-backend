# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
Mime::Type.register 'font/opentype', :font
Mime::Type.register 'text/widget', :widget
Mime::Type.register 'application/vnd.api+json', :json_api
Mime::Type.register 'application/hex+x-ndjson', :hndjson
