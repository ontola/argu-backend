# frozen_string_literal: true

module Public
  module SPI
    class TenantsController < SPI::SPIController
      skip_after_action :verify_policy_scoped
      skip_before_action :authorize_action
      skip_after_action :verify_authorized

      def index
        info = Tenant.pluck(:database_schema, :iri_prefix)

        render json: {
          schemas: info.transpose.first.uniq,
          sites: info.map { |i| {name: i.first, location: "https://#{i.second}"} }
        }
      end
    end
  end
end
