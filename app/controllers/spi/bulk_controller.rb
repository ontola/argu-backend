# frozen_string_literal: true

module SPI
  class BulkController < SPI::SPIController
    include NestedResourceHelper
    skip_after_action :verify_authorized

    def show
      render json: authorized_resources
    end

    private

    def authorize_action; end

    def authorized_resource(opts)
      return response_for_wrong_host(opts[:iri]) if wrong_host?(opts[:iri])

      include = opts[:include].to_s == 'true'
      resource = LinkedRails.resource_from_iri(path_to_url(opts[:iri]))

      return response_from_request(include, RDF::URI(opts[:iri])) unless resource.try(:cacheable?)

      response_from_resource(include, resource)
    end

    def authorized_resources
      @authorized_resources ||= params.require(:resources).map do |param|
        param.permit(:include, :iri)
      end.map(&method(:authorized_resource))
    end

    def require_doorkeeper_token?
      false
    end

    def resource_request(iri)
      path = "/#{LinkedRails.iri_mapper_class.send(:sanitized_path, iri.dup, ActsAsTenant.current_tenant)}"
      env = Rack::MockRequest.env_for(
        path,
        'HTTP_ACCEPT' => 'application/hex+x-ndjson',
        'HTTP_AUTHORIZATION' => request.env['HTTP_AUTHORIZATION']
      )
      req = ActionDispatch::Request.new(env)
      req.path_info = ActionDispatch::Journey::Router::Utils.normalize_path(req.path_info)

      req
    end

    def response_from_request(include, iri)
      response = Rails.application.routes.router.serve(resource_request(iri))
      {
        body: include ? response.last.body : nil,
        cache: response[1]['Cache-Control'] || :private,
        iri: iri.to_s,
        status: response.first
      }
    end

    def response_from_resource(include, resource)
      resource_policy = policy(resource)
      status = resource_status(resource, resource_policy)

      response = {
        body: include && status == 200 ? resource_body(resource) : nil,
        cache: resource_cache_control(status, resource_policy),
        iri: resource.iri,
        status: status
      }
      response
    end

    def response_for_wrong_host(iri)
      {
        cache: :private,
        iri: iri,
        status: 404
      }
    end

    def resource_body(resource)
      return if resource.nil?

      RDF::Serializers.serializer_for(resource)
        .new(resource, {params: {scope: user_context}})
        .send(:render_hndjson)
    end

    def resource_cache_control(status, resource_policy)
      return :private unless status == 200
      return 'no-cache' unless resource_policy.granted_group_ids(:show).include?(Group::PUBLIC_ID)

      :public
    end

    def resource_status(resource, resource_policy)
      return 404 if resource.nil?

      resource_policy.show? ? 200 : 403
    end

    def wrong_host?(iri)
      !iri.starts_with?(ActsAsTenant.current_tenant.iri)
    end
  end
end
