# frozen_string_literal: true

require 'benchmark'

module SPI
  class BulkController < LinkedRails::BulkController
    alias_attribute :pundit_user, :user_context

    private

    def handle_resource_error(_opts, error)
      Bugsnag.notify(error)

      super
    end

    def authorized_resource(opts)
      return super if wrong_host?(opts[:iri])

      include = opts[:include].to_s == 'true'
      resource = LinkedRails.resource_from_iri(path_to_url(opts[:iri]))

      return super unless resource.try(:cacheable?)

      response_from_resource(include, resource)
    rescue StandardError => e
      handle_resource_error(opts, e)
    end

    def request_external_resource(iri)
      HTTParty.get(
        iri,
        headers: {
          'ACCEPT' => 'application/hex+x-ndjson; charset=utf-8',
          'ACCEPT_LANGUAGE' => request.env['HTTP_ACCEPT_LANGUAGE'],
          'AUTHORIZATION' => request.env['HTTP_AUTHORIZATION']
        }
      )
    end

    def resource_request(iri)
      req = super
      req.env['User-Context'] = user_context
      req
    end

    def response_from_external(opts)
      iri = opts[:iri]
      include = opts[:include].to_s == 'true'
      response = request_external_resource(iri)

      resource_response(
        iri.to_s,
        body: include ? response.body : nil,
        cache: :private,
        language: response_language(response.headers),
        status: response.code
      )
    end

    def response_from_resource(include, resource)
      resource_policy = policy(resource)
      status = resource_status(resource, resource_policy)

      resource_response(
        resource.iri,
        body: include && status == 200 ? resource_body(resource) : nil,
        cache: resource_cache_control(status, resource_policy),
        language: I18n.locale,
        status: status
      )
    end

    def response_for_wrong_host(opts)
      iri = opts[:iri]
      if ActsAsTenant.current_tenant.allowed_external_sources.any? { |source| iri.start_with?(source) }
        response_from_external(opts)
      else
        resource_response(iri)
      end
    end

    def resource_body(resource)
      return if resource.nil?

      RDF::Serializers.serializer_for(resource)
        .new(resource,
             include: resource&.class.try(:preview_includes),
             params: {
               scope: user_context,
               context: resource&.try(:iri)
             })
        .send(:render_hndjson)
    end

    def resource_cache_control(status, resource_policy)
      return :private unless status == 200
      return 'no-cache' unless resource_policy.try(:granted_group_ids, :show)&.include?(Group::PUBLIC_ID)

      :public
    end

    def resource_status(resource, resource_policy)
      return 404 if resource.nil?

      resource_policy.show? ? 200 : 403
    end
  end
end
