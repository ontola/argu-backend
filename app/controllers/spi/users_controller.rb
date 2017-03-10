# frozen_string_literal: true
module SPI
  class UsersController < SPI::SPIController
    def current
      current_user.guest? ? head(401) : render(json: current_user)
    end
  end
end
