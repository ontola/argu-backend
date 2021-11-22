# frozen_string_literal: true

require 'benchmark'

module SPI
  class BulkController < LinkedRails::BulkController
    alias_attribute :pundit_user, :user_context

    private

    def allowed_external_host?(iri)
      ActsAsTenant.current_tenant.allowed_external_sources.any? { |source| iri.to_s.start_with?(source) }
    end

    def authorized_resources
      grant_tree = user_context.grant_tree_for(ActsAsTenant.current_tenant)
      grant_tree.grants_in_scope
      grant_tree.grant_resets_in_scope

      super.map(&:join).map(&:value)
    end

    def authorized_resource(opts)
      return super if wrong_host?(opts[:iri])

      include = opts[:include].to_s == 'true'
      resource = LinkedRails.iri_mapper.resource_from_iri(path_to_url(opts[:iri]), user_context)

      return super if resource.blank?

      response_from_resource(include, opts[:iri], resource)
    rescue StandardError => e
      handle_resource_error(opts, e)
    end

    def log_resource_error(error, iri)
      super

      return if error_status(error) < 500

      Bugsnag.notify(error) do |report|
        report.add_metadata(
          :resource,
          {iri: iri}
        )
        Bugsnag.configuration.middleware.run(report)
      end
    end

    def resource_body_with_same_as(resource, iri)
      body = resource_body(resource)
      return body if iri.to_s == resource.iri.to_s
      return body if body.include?(iri.to_s)

      "#{value_to_hex(iri, NS.owl.sameAs, resource.iri)}\n#{body}"
    end

    def resource_request(iri)
      req = super
      req.env['User-Context'] = user_context
      req
    end

    def response_from_resource(include, iri, resource)
      resource_policy = policy(resource)
      status = resource_status(resource, resource_policy)

      resource_response(
        iri,
        body: include && status == 200 ? resource_body_with_same_as(resource, iri) : nil,
        cache: resource_cache_control(resource.try(:cacheable?), status, resource_policy),
        language: I18n.locale,
        status: status
      )
    end

    def response_for_wrong_host(opts)
      iri = opts[:iri]
      return super unless allowed_external_host?(iri)

      include = opts[:include].to_s == 'true'

      response_from_resource(
        include,
        iri,
        LinkedRecord.requested_single_resource({iri: iri}, user_context)
      )
    end

    def resource_cache_control(cacheable, status, resource_policy)
      return :private unless status == 200 && cacheable
      return 'no-cache' if resource_policy.try(:has_unpublished_ancestors?)
      return 'no-cache' unless resource_policy.try(:public_resource?)

      :public
    end

    def resource_status(resource, resource_policy)
      return 404 if resource.nil?

      raise(Argu::Errors::Forbidden.new(query: :show?)) unless resource_policy.show?

      200
    end

    def resource_thread(&block)
      Thread.new(Apartment::Tenant.current, ActsAsTenant.current_tenant, I18n.locale, request.env, &block)
    end

    def threaded_authorized_resource(resource, &block) # rubocop:disable Metrics/MethodLength
      resource_thread do |apartment, tenant, locale, env|
        Bugsnag.configuration.set_request_data(:rack_env, env)
        ActiveRecord::Base.connection_pool.with_connection do
          Apartment::Tenant.switch(apartment) do
            ActsAsTenant.with_tenant(tenant) do
              I18n.with_locale(locale, &block)
            end
          end
        end
      rescue StandardError, ScriptError => e
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
