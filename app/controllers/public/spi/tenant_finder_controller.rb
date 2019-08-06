# frozen_string_literal: true

module Public
  module SPI
    class TenantFinderController < SPI::SPIController
      include IRIHelper

      TENANT_META_ATTRS =
        %w[uuid iri_prefix accent_background_color accent_color navbar_background navbar_color database_schema].freeze

      skip_before_action :authorize_action
      skip_after_action :verify_authorized

      def show
        render json: tenant_meta
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
        parsed_iri = resource_from_iri(iri_param)&.iri
        TenantFinder.from_url(parsed_iri) if parsed_iri
      end

      def tenant_meta
        Hash[
          TENANT_META_ATTRS.map do |key|
            [key, tenant!.send(key)]
          end
        ]
      end
    end
  end
end
