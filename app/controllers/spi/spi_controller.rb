# frozen_string_literal: true

require 'argu'

module SPI
  class SPIController < ActionController::API
    include Argu::ErrorHandling
    include JsonApiHelper
    include Argu::RuledIt
    include OauthHelper
    alias_attribute :pundit_user, :user_context

    serialization_scope :user_context

    def user_context
      UserContext.new(
        current_user,
        current_user.profile,
        doorkeeper_scopes,
        []
      )
    end

    private

    def handle_error(e)
      error_mode(e)
      render json_api_error(error_status(e), json_api_error_hash(error_id(e), e))
    end
    alias handle_not_authorized_error handle_error
    alias handle_bad_request handle_error
    alias handle_record_not_found handle_error

    def set_guest_language; end
  end
end
