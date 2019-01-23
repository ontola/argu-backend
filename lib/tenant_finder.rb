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
    @path = path
  end

  def tenant
    ActsAsTenant.without_tenant { tenant_by_prefix || tenant_by_uuid }
  end

  private

  def host_with_port
    @host_with_port ||= [0, 80, 443].include?(@port.to_i) ? @host : [@host, @port].join(':')
  end

  def iri_suffix
    @iri_suffix ||= @path.split('/').second&.split('.')&.first
  end

  def matching_iris
    [host_with_port, uri_with_suffix, "app.#{uri_with_suffix}"]
  end

  def tenant_by_prefix
    Page.find_by(iri_prefix: matching_iris)
  end

  def tenant_by_uuid
    Page.find_by(uuid: iri_suffix) if uuid?(iri_suffix)
  end

  def uri_with_suffix
    @uri_with_suffix ||= [host_with_port, iri_suffix].join('/')
  end
end
