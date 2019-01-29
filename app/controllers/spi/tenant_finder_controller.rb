# frozen_string_literal: true

module SPI
  class TenantFinderController < SPIController
    include IRIHelper

    skip_before_action :authorize_action
    skip_after_action :verify_authorized

    def show
      render json: {
        iri_prefix: tenant!.iri_prefix,
        uuid: tenant!.uuid
      }
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
  end
end
