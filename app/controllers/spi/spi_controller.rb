# frozen_string_literal: true

require 'argu'
require 'argu/controller/error_handling/bad_credentials'

module SPI
  class SPIController < ActionController::API
    include Argu::Controller::ErrorHandling
    include Argu::Controller::ErrorHandling::BadCredentials
    include JsonApiHelper
    include Argu::RuledIt
    include OauthHelper
    alias_attribute :pundit_user, :user_context

    serialization_scope :user_context

    def user_context
      @user_context ||=
        UserContext.new(
          doorkeeper_scopes: doorkeeper_scopes,
          profile: current_user.profile,
          tree_root_id: GrantTree::ANY_ROOT,
          user: current_user
        )
    end

    private

    def handle_error(e)
      error_mode(e)
      error_response_json_api(e)
    end

    def set_guest_language; end
  end
end
