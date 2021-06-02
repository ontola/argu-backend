# frozen_string_literal: true

# Helper to determine the parent of the nested resource
# It is to be used with {AuthorizedController} inherited resource controllers
# @note Has been designed with a single parent resource in mind (route wise)
# @author Fletcher91 <thom@argu.co>
module NestedResourceHelper
  def path_to_url(path)
    return path unless relative_path?(path)

    port = [80, 443].include?(request.port) ? nil : request.port
    URI::Generic.new(request.scheme, nil, request.host, port, nil, path, nil, nil, nil).to_s
  end

  def relative_path?(string)
    string.is_a?(String) && string.starts_with?('/') && !string.starts_with?('//')
  end
end
