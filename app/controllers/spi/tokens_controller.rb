# frozen_string_literal: true

require 'argu'

module SPI
  class TokensController < Doorkeeper::TokensController
    include RedisResourcesHelper
    include OauthHelper
    include JWTHelper
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
      process_previous_token(res)
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
      generate_guest_token(SecureRandom.hex, application: current_application)
    end

    def handle(e)
      render status: error_status(e), json: json_error_hash(e).to_json
      nil
    end

    def previous_token
      @previous_token ||=
        params[:userToken] &&
        Doorkeeper::AccessToken.find_by(token: params[:userToken])
    end

    def process_previous_token(res)
      return unless previous_token
      schedule_redis_resource_worker(
        GuestUser.new(id: previous_token.resource_owner_id),
        User.find(res.token.resource_owner_id),
        params[:r]
      )
    end

    def user_token
      owner = resource_owner_from_credentials
      return handle(owner) if owner.is_a?(StandardError)

      generate_user_token(owner, application: current_application)
    end

    def r_with_authenticity_token; end
  end
end
