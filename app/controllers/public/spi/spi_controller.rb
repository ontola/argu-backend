# frozen_string_literal: true

module Public
  module SPI
    class SPIController < ::SPI::SPIController
      before_action :verify_public_schema

      private

      def verify_public_schema
        return if Apartment::Tenant.current == 'public'

        raise("Accessing schema #{Apartment::Tenant.current} in a public controller")
      end
    end
  end
end
