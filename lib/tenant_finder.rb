# frozen_string_literal: true

require_relative '../app/helpers/uuid_helper'

class TenantFinder
  class << self
    def from_url(url)
      uri = URI(url)
      new(uri.host, uri.port, uri.path).tenant
    end

    def from_request(request)
      new(request.host, request.port, request.path).tenant
    end
  end

  include UUIDHelper

  def initialize(host, port, path)
    @host = host
    @port = port
    @path = path.downcase
  end

  def tenant
    tenant = ActsAsTenant.without_tenant { tenant_by_prefix || tenant_by_uuid || tenant_by_shortname }
    return if tenant.blank?

    Apartment::Tenant.switch(tenant.database_schema) { tenant.page }
  end

  private

  def host_with_port
    @host_with_port ||= [0, 80, 443].include?(@port.to_i) ? @host : [@host, @port].join(':')
  end

  def iri_suffix
    @iri_suffix ||= @path.split('/').second&.split('.')&.first
  end

  def matching_iris
    [host_with_port, uri_with_suffix]
  end

  def tenant_by_prefix
    Tenant.find_by('lower(iri_prefix) IN (?)', matching_iris)
  end

  def tenant_by_shortname
    return unless Rails.application.config.host_name == @host

    Apartment::Tenant.each do
      match = Page.find_via_shortname(iri_suffix)
      return match.tenant if match
    end

    nil
  end

  def tenant_by_uuid
    Tenant.find_by(root_id: iri_suffix) if uuid?(iri_suffix)
  end

  def uri_with_suffix
    @uri_with_suffix ||= [host_with_port, iri_suffix].join('/')
  end
end
