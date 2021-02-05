# frozen_string_literal: true

module Oauth
  class TokensController < LinkedRails::Auth::AccessTokensController
    include JWTHelper
    include RedisResourcesHelper
    include UriTemplateHelper
    skip_before_action :current_actor, :set_locale
    skip_around_action :time_zone

    private

    def create_success_effects
      if otp_activated? && !strategy.is_a?(Doorkeeper::Request::RefreshToken)
        response.headers['Location'] = otp_form_iri.to_s
        @authorize_response = Doorkeeper::OAuth::TokenResponse.new(Doorkeeper::AccessToken.new)
      else
        super

        process_previous_token(authorize_response)
      end
    end

    def otp_activated?
      OtpSecret.exists?(user_id: authorize_response.token.resource_owner_id, active: true)
    end

    def otp_form_iri
      session = sign_payload(user_id: authorize_response.token.resource_owner_id, exp: 10.minutes.from_now.to_i)

      new_iri('users/otp_attempts', nil, query: {session: session})
    end

    def process_previous_token(res)
      return unless doorkeeper_token && !res.token.scopes.scopes?(%i[guest])

      schedule_redis_resource_worker(
        GuestUser.new(id: doorkeeper_token.resource_owner_id),
        User.find(res.token.resource_owner_id),
        redirect_url_param
      )
    end

    def token_with_errors(exception)
      token_with_errors = LinkedRails::Auth::AccessToken.new
      field = [Argu::Errors::WrongPassword, Argu::Errors::NoPassword].include?(exception.class) ? :password : :email
      token_with_errors.errors.add(field, exception.message)
      token_with_errors
    end
  end
end
