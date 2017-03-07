# frozen_string_literal: true
module RedirectHelper
  VALID_HOSTNAMES = ["https://#{Rails.application.config.host_name}", Rails.application.config.frontend_url].freeze

  def valid_redirect?(r)
    uri = r && URI.parse(r)
    uri.nil? || uri.hostname.nil? || VALID_HOSTNAMES.include?("#{uri.scheme}://#{uri.host}")
  end
end
