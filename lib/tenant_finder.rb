# frozen_string_literal: true

require_relative '../app/helpers/uuid_helper'

class TenantFinder
  class << self
    def from_url(url)
      uri = URI(url)
      new(uri.host, uri.port, uri.path).page
    rescue URI::InvalidURIError
      nil
    end

    def from_request(request)
      new(request.host, request.port, request.path, request.get_header('HTTP_WEBSITE_IRI')).page
    end
  end

  include UUIDHelper

  def initialize(host, port, path, website_iri = nil)
    @host = host
    @port = port
    @path = path.downcase
    @website_iri = website_iri
  end

  def page
    page = same_page? ? ActsAsTenant.current_tenant : find_page
    return if page.blank?

    page
  end

  private

  def find_page
    ActsAsTenant.without_tenant do
      (tenant_by_website_iri || tenant_by_prefix || tenant_by_uuid || tenant_by_shortname)&.page
    end
  end

  def host_with_port
    @host_with_port ||= [0, 80, 443].include?(@port.to_i) ? @host : [@host, @port].join(':')
  end

  def iri_suffix
    @iri_suffix ||= @path.split('/').second&.split('.')&.first
  end

  def matching_iris
    [host_with_port, uri_with_suffix]
  end

  def same_page?
    ActsAsTenant.current_tenant && matching_iris.any? do |iri|
      iri.start_with?(ActsAsTenant.current_tenant&.iri_prefix)
    end
  end

  def tenant_by_prefix
    Tenant.find_by('lower(iri_prefix) IN (?)', matching_iris)
  end

  def tenant_by_shortname
    return unless Rails.application.config.host_name == @host

    match = Shortname.find_resource(iri_suffix)

    match.root.tenant if match.is_a?(Edge)
  end

  def tenant_by_uuid
    Tenant.find_by(root_id: iri_suffix) if uuid?(iri_suffix)
  end

  def tenant_by_website_iri
    Tenant.find_by(iri_prefix: @website_iri.split('://').last) if @website_iri
  end

  def uri_with_suffix
    @uri_with_suffix ||= [host_with_port, iri_suffix].join('/')
  end
end
