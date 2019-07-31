# frozen_string_literal: true

module Public
  module SPI
    class TenantsController < SPI::SPIController
      skip_after_action :verify_policy_scoped
      skip_before_action :authorize_action
      skip_after_action :verify_authorized

      def index
        render json: {schemas: Tenant.distinct.pluck(:database_schema)}
      end
    end
  end
end
