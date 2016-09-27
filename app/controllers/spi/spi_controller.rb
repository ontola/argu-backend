# frozen_string_literal: true
module SPI
  class SPIController < ActionController::API
    include OauthHelper, Argu::RuledIt, JsonApiHelper
    rescue_from Argu::NotAuthorizedError, with: :handle_not_authorized_error

    serialization_scope :doorkeeper_scopes

    private

    def handle_not_authorized_error(exception)
      error_hash = {
        message: exception.message,
        code: 'NOT_AUTHORIZED'
      }
      render json_api_error(403, error_hash)
    end

    def pundit_user
      UserContext.new(
        current_user,
        current_user&.profile,
        []
      )
    end
  end
end
