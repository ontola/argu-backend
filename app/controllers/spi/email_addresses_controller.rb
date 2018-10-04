# frozen_string_literal: true

module SPI
  class EmailAddressesController < SPI::SPIController
    def show
      head 200 if email_by_param
    end

    private

    def email_by_param
      @email_by_param ||= EmailAddress.find_by!(email: params[:email])
    end
  end
end
