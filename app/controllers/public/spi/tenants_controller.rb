# frozen_string_literal: true

module Public
  module SPI
    class TenantsController < SPI::SPIController
      skip_after_action :verify_policy_scoped
      skip_before_action :authorize_action
      skip_after_action :verify_authorized

      def index
        info = Tenant.joins(:page).map { |t| [t.page.display_name, t.iri_prefix] }

        render json: {
          sites: info.map { |i| {name: i.first, location: "https://#{i.second}"} }
        }
      end
    end
  end
end
