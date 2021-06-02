# frozen_string_literal: true

module Public
  module SPI
    class TenantFinderController < SPI::SPIController
      TENANT_META_ATTRS = %w[
        uuid all_shortnames iri_prefix header_background header_text secondary_color primary_color
        database_schema display_name
      ].freeze

      skip_before_action :authorize_action
      skip_after_action :verify_authorized

      def show
        Apartment::Tenant.switch(tenant!.database_schema) do
          render json: tenant_meta
        end
      end

      private

      def iri_param
        @iri_param ||= params[:iri].include?('://') ? params[:iri] : "//#{params[:iri]}"
      end

      def tenant!
        @tenant ||= tenant_from_iri || tenant_from_parsed_iri || raise(ActiveRecord::RecordNotFound)
      end

      def tenant_from_iri
        TenantFinder.from_url(iri_param)
      end

      def tenant_from_parsed_iri
        parsed_iri = LinkedRails.iri_mapper.resource_from_iri(iri_param, user_context)&.iri
        TenantFinder.from_url(parsed_iri) if parsed_iri
      end

      def tenant_meta
        TENANT_META_ATTRS.index_with do |key|
          tenant!.send(key)
        end
      end
    end
  end
end
