# frozen_string_literal: true

module Oauth
  class TokensController < Doorkeeper::TokensController
    include ActionController::MimeResponds
    include ActiveResponse::Controller
    include RedisResourcesHelper
    include Argu::Controller::ErrorHandling::Helpers
    include OauthHelper

    def create
      super
      return unless status == 200

      update_oauth_token(authorize_response.token)
      process_previous_token(authorize_response)
    end

    private

    def handle_token_exception(exception)
      active_response_block do
        case active_response_type
        when :json
          handle_token_exception_json(exception)
        else
          respond_with_invalid_resource(resource: token_with_errors(exception))
        end
      end
    end

    def handle_token_exception_json(exception) # rubocop:disable Metrics/AbcSize
      error = get_error_response_from_exception(exception)
      headers.merge!(error.headers)
      Bugsnag.notify(exception)
      Rails.logger.info(error.body.merge(code: error_id(exception)).to_json)
      self.response_body = error.body.merge(code: error_id(exception)).to_json
      self.status = error.status
    end

    def process_previous_token(res)
      return unless doorkeeper_token && !res.token.scopes.scopes?(%i[guest])

      schedule_redis_resource_worker(
        GuestUser.new(id: doorkeeper_token.resource_owner_id),
        User.find(res.token.resource_owner_id),
        params[:r]
      )
    end

    def r_with_authenticity_token; end

    def token_with_errors(exception)
      token_with_errors = Token.new
      field = [Argu::Errors::WrongPassword, Argu::Errors::NoPassword].include?(exception.class) ? :password : :email
      token_with_errors.errors.add(field, exception.message)
      token_with_errors
    end

    class << self
      def controller_class
        AccessToken
      end
    end
  end
end
