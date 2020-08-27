# frozen_string_literal: true

module Oauth
  class TokensController < LinkedRails::Auth::AccessTokensController
    include RedisResourcesHelper
    skip_before_action :current_actor, :set_locale
    skip_around_action :time_zone

    def create
      super
      return unless status == 200

      update_oauth_token(authorize_response.token)
      process_previous_token(authorize_response)
    end

    private

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
