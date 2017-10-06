# frozen_string_literal: true

require 'argu'

module SPI
  class TokensController < Doorkeeper::TokensController
    include Doorkeeper::Rails::Helpers
    include ActionController::Head
    include AbstractController::Logger

    include Argu::ErrorHandling::DataStructures
    include Argu::ErrorHandling::Helpers

    def create
      return if doorkeeper_authorize! :service

      token = params[:scope] == 'user' ? user_token : guest_token
      return if token.nil?

      res = Doorkeeper::OAuth::TokenResponse.new(token)
      render json: res.body.to_json
    end

    private

    def argu_classic_frontend_request?
      false
    end

    def guest_token
      Doorkeeper::AccessToken.find_or_create_for(
        Doorkeeper::Application.argu,
        SecureRandom.hex,
        'guest',
        Doorkeeper.configuration.access_token_expires_in,
        false
      )
    end

    def handle(e)
      render status: error_status(e), json: json_error_hash(e).to_json
      nil
    end

    def user_token
      owner = resource_owner_from_credentials
      return handle(owner) if owner.is_a?(StandardError)

      Doorkeeper::AccessToken.find_or_create_for(
        Doorkeeper::Application.argu,
        owner.id,
        'user',
        Doorkeeper.configuration.access_token_expires_in,
        false
      )
    end

    def r_with_authenticity_token; end
  end
end
