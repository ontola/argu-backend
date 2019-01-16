# frozen_string_literal: true

require 'argu'
require 'argu/controller/error_handling/bad_credentials'

module SPI
  class SPIController < ActionController::API
    include FrontendTransitionHelper
    include Argu::Controller::ErrorHandling
    include Argu::Controller::ErrorHandling::BadCredentials
    include JsonApiHelper
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

    def handle_error(e)
      error_mode(e)
      error_response_json_api(e)
    end

    def tree_root_id; end
  end
end
