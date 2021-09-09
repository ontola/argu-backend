# frozen_string_literal: true

module Oauth
  class TokensController < LinkedRails::Auth::AccessTokensController
    include JWTHelper
    include RedisResourcesHelper
    include UriTemplateHelper
    skip_before_action :current_actor, :set_locale
    skip_around_action :time_zone
    controller_class LinkedRails.access_token_class

    private

    def handle_new_token
      super
      process_previous_token(authorize_response)
    end

    def handle_token_exception(exception)
      return super unless exception.is_a?(Argu::Errors::AccountLocked)

      headers['Location'] = LinkedRails.iri(path: 'u/unlock/new').to_s

      head 200
    end

    def otp_setup_required?
      User.find_by(id: authorize_response.token.resource_owner_id)&.requires_2fa?
    end

    def process_previous_token(res)
      return unless doorkeeper_token && !res.token.scopes.scopes?(%i[guest])

      schedule_redis_resource_worker(
        GuestUser.new(id: doorkeeper_token.resource_owner_id),
        User.find(res.token.resource_owner_id),
        redirect_url_param
      )
    end

    def redirect_to_otp_secret
      add_exec_action_header(
        headers,
        ontola_snackbar_action('2fa is verplicht')
      )
      super
    end

    def token_with_errors(exception)
      token_with_errors = LinkedRails::Auth::AccessToken.new
      field = [Argu::Errors::WrongPassword, Argu::Errors::NoPassword].include?(exception.class) ? :password : :email
      token_with_errors.errors.add(field, exception.message)
      token_with_errors
    end
  end
end
