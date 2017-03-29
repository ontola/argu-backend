# frozen_string_literal: true
module RedirectHelper
  VALID_HOSTNAMES = ["https://#{Rails.application.config.host_name}", Rails.application.config.frontend_url].freeze

  def valid_redirect?(r)
    uri = r && URI.parse(r)
    return true if uri.nil? || uri.hostname.nil?
    uri.path = ''
    VALID_HOSTNAMES.include?(uri.to_s)
  end
end
