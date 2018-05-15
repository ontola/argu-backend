# frozen_string_literal: true

require 'argu'

module SPI
  class TokensController < Doorkeeper::TokensController
    include Doorkeeper::Rails::Helpers
    include ActionController::Head
    include AbstractController::Logger

    include Argu::Controller::ErrorHandling::DataStructures
    include Argu::Controller::ErrorHandling::Helpers

    def create
      return if doorkeeper_authorize! :service

      token = params[:scope] == 'user' ? user_token : guest_token
      return if token.nil?

      res = Doorkeeper::OAuth::TokenResponse.new(token)
      render json: res.body.to_json, status: 201
    end

    private

    def argu_classic_frontend_request?
      false
    end

    def current_application_id
      doorkeeper_token.application_id
    end

    def current_application
      doorkeeper_token.application
    end

    def guest_token
      Doorkeeper::AccessToken.find_or_create_for(
        current_application,
        SecureRandom.hex,
        new_token_scopes(:guest),
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
        current_application,
        owner.id,
        new_token_scopes(:user),
        Doorkeeper.configuration.access_token_expires_in,
        false
      )
    end

    def r_with_authenticity_token; end

    def new_token_scopes(requested_scope)
      return requested_scope unless current_application_id == Doorkeeper::Application::AFE_ID
      [requested_scope, :afe].join(' ')
    end
  end
end
