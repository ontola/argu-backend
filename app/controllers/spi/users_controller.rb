# frozen_string_literal: true

module SPI
  class UsersController < SPI::SPIController
    skip_before_action :authorize_action, only: :current
    skip_after_action :verify_authorized, only: :current

    def current
      current_user.guest? ? head(401) : render(json: current_user, include: :email_addresses)
    end
  end
end
