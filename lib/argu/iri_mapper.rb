# frozen_string_literal: true

module Argu
  class IRIMapper < LinkedRails::IRIMapper
    class << self
      def parent_from_params(params, user_context)
        return ActsAsTenant.current_tenant unless params.key?(:parent_iri)

        super
      end

      def opts_from_iri(iri, method: 'GET')
        query = Rack::Utils.parse_nested_query(URI(iri.to_s).query)
        params = Rails.application.routes.recognize_path(sanitized_path(RDF::URI(iri.to_s)), method: method)

        route_params_to_opts(params.merge(query), iri.to_s)
      rescue ActionController::RoutingError
        EMPTY_IRI_OPTS.dup
      end

      def sanitized_path(iri)
        iri.path = "#{iri.path}/" unless iri.path&.ends_with?('/')
        tenant_path = ActsAsTenant.current_tenant&.iri&.path
        URI(tenant_path.present? ? iri.to_s.split("#{tenant_path}/").last : iri).path
      end
    end
  end
end
