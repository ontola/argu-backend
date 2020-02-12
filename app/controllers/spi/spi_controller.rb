# frozen_string_literal: true

module SPI
  class SPIController < ActionController::API
    include Argu::Controller::ErrorHandling
    include Argu::Controller::ErrorHandling::BadCredentials
    include JsonAPIHelper
    include Argu::Controller::Authorization
    include OauthHelper

    serialization_scope :user_context

    def user_context
      @user_context ||=
        UserContext.new(
          doorkeeper_scopes: doorkeeper_scopes,
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
