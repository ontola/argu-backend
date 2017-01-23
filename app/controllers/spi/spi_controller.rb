# frozen_string_literal: true
module SPI
  class SPIController < ActionController::API
    include OauthHelper, Argu::RuledIt, JsonApiHelper
    alias_attribute :pundit_user, :user_context

    rescue_from Argu::NotAuthorizedError, with: :handle_not_authorized_error

    serialization_scope :user_context

    def user_context
      UserContext.new(
        current_user,
        current_user&.profile,
        doorkeeper_scopes,
        []
      )
    end

    private

    def handle_not_authorized_error(exception)
      error_hash = {
        message: exception.message,
        code: 'NOT_AUTHORIZED'
      }
      render json_api_error(403, error_hash)
    end
  end
end
