# frozen_string_literal: true
# Be sure to restart your server when you modify this file.
require 'active_model_serializers/register_jsonapi_renderer'

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
Mime::Type.register 'font/opentype', :font
Mime::Type.register 'text/widget', :widget
Mime::Type.register 'application/vnd.api+json', :json_api

ActionController::Renderers.add :json_api do |json, options|
  unless json.is_a?(String)
    json = if json.is_a?(ActiveModel::Errors)
             json_api_error(422, json.as_json)[:json].to_json(options)
           else
             serialize_jsonapi(json, options).to_json(options)
           end
  end
  self.content_type ||= Mime[:json_api]
  self.response_body = json
end
