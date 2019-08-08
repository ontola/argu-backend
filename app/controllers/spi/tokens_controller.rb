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
    include LinkedRails::Helpers::OntolaActionsHelper

    def create
      return if doorkeeper_authorize! :service, :guest

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

    def current_user; end

    def guest_token
      generate_guest_token(SecureRandom.hex, application: current_application)
    end

    def handle(e)
      user = user_without_password(e)
      if user
        token = set_reset_password_token
        SendEmailWorker.perform_async(
          :set_password,
          id,
          token_url: iri_from_template(:user_set_password, reset_password_token: token)
        )
        body = {code: :NO_PASSWORD}
      else
        body = json_error_hash(e)
      end

      render status: error_status(e), json: body.to_json
      nil
    end

    def user_without_password(e)
      return false unless e.is_a?(Argu::Errors::WrongPassword) && params[:password].blank?
      user = EmailAddress.find_by(email: params[:username])&.user
      user unless user&.has_password?
    end

    def previous_token
      @previous_token ||=
        params[:userToken] &&
        Doorkeeper::AccessToken.by_token(params[:userToken])
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
