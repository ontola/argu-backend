# frozen_string_literal: true

require 'benchmark'

module SPI
  class BulkController < LinkedRails::BulkController
    alias_attribute :pundit_user, :user_context

    private

    def authorized_resources
      grant_tree = user_context.grant_tree_for(ActsAsTenant.current_tenant)
      grant_tree.grants_in_scope
      grant_tree.grant_resets_in_scope

      super.map(&:join).map(&:value)
    end

    def handle_resource_error(_opts, error)
      Bugsnag.notify(error) do |report|
        Bugsnag.configuration.middleware.run(report)
      end

      super
    end

    def authorized_resource(opts)
      return super if wrong_host?(opts[:iri])

      include = opts[:include].to_s == 'true'
      resource = LinkedRails.resource_from_iri(path_to_url(opts[:iri]))

      return super unless resource.try(:cacheable?)

      response_from_resource(include, resource)
    end

    def resource_request(iri)
      req = super
      req.env['User-Context'] = user_context
      Bugsnag.configuration.set_request_data(:rack_env, req.env)
      req
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
        include = opts[:include].to_s == 'true'

        response_from_request(include, LinkedRecord.find_or_initialize_by_iri(opts[:iri]).iri).merge(
          iri: opts[:iri]
        )
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
      return 'no-cache' if resource_policy.has_unpublished_ancestors?
      return 'no-cache' unless resource_policy.try(:granted_group_ids, :show)&.include?(Group::PUBLIC_ID)

      :public
    end

    def resource_status(resource, resource_policy)
      return 404 if resource.nil?

      resource_policy.show? ? 200 : 403
    rescue ActiveRecord::RecordNotFound
      404
    rescue Argu::Errors::Unauthorized
      401
    rescue Pundit::NotAuthorizedError, Argu::Errors::Forbidden
      403
    rescue StandardError
      500
    end

    def threaded_authorized_resource(resource) # rubocop:disable Metrics/MethodLength
      Thread.new(Apartment::Tenant.current, ActsAsTenant.current_tenant) do |apartment, tenant|
        ActiveRecord::Base.connection_pool.with_connection do
          Apartment::Tenant.switch(apartment) do
            ActsAsTenant.with_tenant(tenant) do
              yield
            end
          end
        end
      rescue StandardError => e
        handle_resource_error(resource, e)
      end
    end

    def timed_authorized_resource(resource)
      threaded_authorized_resource(resource) do
        super
      end
    end
  end
end
