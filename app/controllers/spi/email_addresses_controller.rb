# frozen_string_literal: true

module SPI
  class EmailAddressesController < SPI::SPIController
    def show
      head 200
    end

    private

    def current_resource
      @current_resource ||= EmailAddress.find_by(email: params[:email])
    end

    def current_resource!
      current_resource || raise(ActiveRecord::RecordNotFound)
    end
  end
end
