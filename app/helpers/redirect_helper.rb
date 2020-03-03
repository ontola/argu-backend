# frozen_string_literal: true

module RedirectHelper
  VALID_HOSTNAMES = [
    'https://argu.co',
    "https://#{Rails.application.config.host_name}",
    Rails.env.test? ? 'https://127.0.0.1:42000' : nil
  ].uniq.compact.freeze

  def argu_iri_or_relative?(redirect)
    uri = redirect && URI.parse(redirect)
    return true if uri.nil? || uri.hostname.nil?

    uri.scheme = 'https' if Rails.env.test?
    port = [nil, 80, 443].include?(uri.port) ? '' : ":#{uri.port}"
    VALID_HOSTNAMES.include?("#{uri.scheme}://#{uri.hostname}#{port}")
  end
end
