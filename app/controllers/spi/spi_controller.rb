# frozen_string_literal: true

module SPI
  class SPIController < ActionController::API
    include LinkedRails::Controller::Authorization
    include LinkedRails::Controller::ErrorHandling
    include Argu::Controller::ErrorHandling
    include Argu::Controller::ErrorHandling::BadCredentials
    include JsonAPIHelper
    include Argu::Controller::Authentication
    include Argu::Controller::Authorization

    def user_context
      @user_context ||=
        UserContext.new(
          doorkeeper_token: doorkeeper_token,
          profile: current_user.profile,
          user: current_user
        )
    end

    private

    def handle_error(error)
      error_mode(error)
      error_response_json_api(error)
    end
  end
end
