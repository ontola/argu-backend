# frozen_string_literal: true

require 'benchmark'
require 'prometheus_exporter/client'

module SPI
  class BulkController < LinkedRails::BulkController # rubocop:disable Metrics/ClassLength
    include Empathy::EmpJson::Helpers::Slices
    include Empathy::EmpJson::Helpers::Primitives

    alias_attribute :pundit_user, :user_context

    private

    def allowed_external_host?(iri)
      ActsAsTenant.current_tenant.allowed_external_sources.any? { |source| iri.to_s.start_with?(source) }
    end

    def authorized_resources
      grant_tree = user_context.grant_tree_for(ActsAsTenant.current_tenant)
      grant_tree.grants_in_scope
      grant_tree.grant_resets_in_scope

      process_in_threads(
        params
          .require(:resources)
          .map { |param| resource_params(param) }
      )
    end

    def available_connections
      stats = ActiveRecord::Base.connection_pool.stat

      stats[:size] - stats[:busy] - stats[:waiting]
    end

    def body_from_other_tenant(opts, resource, tenant)
      ActsAsTenant.with_tenant(tenant) do
        response_from_resource(opts[:include], opts[:iri], resource)
      end
    end

    def client
      PrometheusExporter::Client.default unless ENV['DISABLE_PROMETHEUS']
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

    def process_in_threads(resources)
      result = []
      until resources.empty?
        process_count = [[available_connections, 1].max, (ENV['RAILS_MAX_THREADS'] || 5).to_i].min
        process_set = resources.shift(process_count)
        result.concat(process_set.map(&method(:timed_authorized_resource)).each(&:join).map(&:value))
      end
      result
    end

    def resource_hash_with_same_as(resource, iri) # rubocop:disable Metrics/AbcSize
      hash = resource_hash(resource)

      if iri.to_s != "#{ActsAsTenant.current_tenant.iri}/" && resource.iri.to_s && !hash.keys.include?(iri.to_s)
        add_record_to_slice(hash, iri)
        hash[iri.to_s][NS.owl.sameAs.to_s] = object_to_value(resource.iri)
      end

      hash
    end

    def resource_body_with_same_as(resource, iri)
      Oj.fast_generate(resource_hash_with_same_as(resource, iri))
    end

    def resource_from_other_tenant(iri, tenant)
      ActsAsTenant.with_tenant(tenant) do
        LinkedRails.iri_mapper.resource_from_iri(request_path_to_url(iri), user_context)
      end
    end

    def resource_request(iri)
      req = super
      req.env['User-Context'] = user_context
      req
    end

    def response_from_resource_body(include, iri, resource, status)
      include && status == 200 ? resource_body_with_same_as(resource, iri) : nil
    end

    def response_for_wrong_host(opts)
      iri = opts[:iri]
      return super unless allowed_external_host?(iri)

      tenant = TenantFinder.from_url(iri)
      resource = resource_from_other_tenant(iri, tenant)
      return body_from_other_tenant(opts, resource, tenant) if resource

      include = opts[:include].to_s == 'true'

      response_from_resource(
        include,
        iri,
        LinkedRecord.requested_single_resource({iri: iri}, user_context)
      )
    end

    def resource_cache_control(cacheable, status, resource_policy)
      cache_control = super

      return 'no-cache' if cache_control == :public && resource_policy.try(:has_unpublished_ancestors?)

      cache_control
    end

    def resource_thread(&block)
      Thread.new(ActsAsTenant.current_tenant, I18n.locale, request.env, &block)
    end

    def threaded_authorized_resource(resource, &block)
      resource_thread do |tenant, locale, env|
        Bugsnag.configuration.set_request_data(:rack_env, env)
        ActsAsTenant.with_tenant(tenant) do
          I18n.with_locale(locale, &block)
        end
      rescue StandardError, ScriptError => e
        handle_resource_error(resource, e)
      ensure
        ActiveRecord::Base.clear_active_connections!
      end
    end

    def timed_authorized_resource(resource)
      threaded_authorized_resource(resource) do
        super
      end
    end
  end
end
