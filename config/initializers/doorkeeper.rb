# frozen_string_literal: true

Doorkeeper.configure do
  # Change the ORM that doorkeeper will use.
  # Currently supported options are :active_record, :mongoid2, :mongoid3,
  # :mongoid4, :mongo_mapper
  orm :active_record

  api_only
  base_controller 'ApplicationController'
  base_metal_controller 'ApplicationController'

  # This block will be called to check whether the resource owner is authenticated or not.
  resource_owner_authenticator do
    if doorkeeper_token&.acceptable?('user')
      User.find_by(id: doorkeeper_token.resource_owner_id)
    elsif doorkeeper_token&.acceptable?('service') && doorkeeper_token.resource_owner_id.to_i == User::SERVICE_ID
      User.service
    elsif doorkeeper_token&.acceptable?('guest') && doorkeeper_token_payload['user']
      GuestUser.new(
        id: doorkeeper_token.resource_owner_id,
        language: doorkeeper_token_payload['user']['language']
      )
    end
  end

  resource_owner_from_credentials do
    request.params[:user] = request.params[:access_token] || {}
    request.params[:user][:email] ||= (request.params[:username] || request.params[:email])&.downcase
    request.params[:user][:password] ||= request.params[:token] || request.params[:password]
    request.env['devise.allow_params_authentication'] = true
    user = request.params[:scope] == 'guest' ? GuestUser.new : request.env['warden'].authenticate(scope: :user)
    user_from_db = user || User.find_for_database_authentication(request.params[:user])

    if user.blank?
      raise(
        if EmailAddress.find_by(email: request.params[:user][:email]).nil?
          Argu::Errors::UnknownEmail.new
        elsif request.env['warden'].message == :locked
          Argu::Errors::AccountLocked.new
        elsif user_from_db.encrypted_password.blank?
          Argu::Errors::NoPassword.new(user: user_from_db)
        elsif request.env['warden'].message == :invalid || request.env['warden'].message == :last_attempt
          Argu::Errors::WrongPassword.new
        elsif request.env['warden'].message == :not_found_in_database
          Argu::Errors::WrongPassword.new
        else
          "unhandled login state #{request.env['warden'].message}"
        end
      )
    else
      request.env['warden'].logout
      user
    end
  end

  # Authorization Code expiration time (default 10 minutes).
  # authorization_code_expires_in 10.minutes

  # Access token expiration time (default 2 hours).
  # If you want to disable expiration, set this to nil.
  # access_token_expires_in 2.hours

  # Assign a custom TTL for implicit grants.
  # custom_access_token_expires_in do |oauth_client|
  #   oauth_client.application.additional_settings.implicit_oauth_expiration
  # end

  # Use a custom class for generating the access token.
  # https://github.com/doorkeeper-gem/doorkeeper#custom-access-token-generator
  access_token_generator '::Doorkeeper::JWT'

  # Reuse access token for the same resource owner within an application (disabled by default)
  # Rationale: https://github.com/doorkeeper-gem/doorkeeper/issues/383
  # reuse_access_token

  # Issue access tokens with refresh token (disabled by default)
  use_refresh_token

  # Provide support for an owner to be assigned to each registered application (disabled by default)
  # Optional parameter :confirmation => true (default false) if you want to enforce ownership of
  # a registered application
  # Note: you must also run the rails g doorkeeper:application_owner generator to provide the necessary support
  enable_application_owner confirmation: true

  # Define access token scopes for your provider
  # For more information go to
  # https://github.com/doorkeeper-gem/doorkeeper/wiki/Using-Scopes
  default_scopes  :guest
  optional_scopes :user

  # Change the way client credentials are retrieved from the request object.
  # By default it retrieves first from the `HTTP_AUTHORIZATION` header, then
  # falls back to the `:client_id` and `:client_secret` params from the `params` object.
  # Check out the wiki for more information on customization
  client_credentials :from_basic, :from_params

  # Change the way access token is authenticated from the request object.
  # By default it retrieves first from the `HTTP_AUTHORIZATION` header, then
  # falls back to the `:access_token` or `:bearer_token` params from the `params` object.
  # Check out the wiki for more information on customization

  access_token_methods :from_bearer_authorization, :from_access_token_param, :from_bearer_param

  # Change the native redirect uri for client apps
  # When clients register with the following redirect uri, they won't be redirected to any server and
  # the authorization code will be displayed within the provider
  # The value can be any string. Use nil to disable this feature. When disabled, clients must provide a valid URL
  # (Similar behaviour: https://developers.google.com/accounts/docs/OAuth2InstalledApp#choosingredirecturi)
  #
  # native_redirect_uri 'urn:ietf:wg:oauth:2.0:oob'

  # Forces the usage of the HTTPS protocol in non-native redirect uris (enabled
  # by default in non-development environments). OAuth2 delegates security in
  # communication to the HTTPS protocol so it is wise to keep this enabled.
  #
  force_ssl_in_redirect_uri !(Rails.env.development? || Rails.env.test?)

  # Specify what grant flows are enabled in array of Strings. The valid
  # strings and the flows they enable are:
  #
  # "authorization_code" => Authorization Code Grant Flow
  # "implicit"           => Implicit Grant Flow
  # "password"           => Resource Owner Password Credentials Grant Flow
  # "client_credentials" => Client Credentials Grant Flow
  #
  # If not specified, Doorkeeper enables authorization_code and
  # client_credentials.
  #
  # implicit and password grant flows have risks that you should understand
  # before enabling:
  #   http://tools.ietf.org/html/rfc6819#section-4.4.2
  #   http://tools.ietf.org/html/rfc6819#section-4.4.3
  #
  grant_flows %w[authorization_code password client_credentials]

  # Under some circumstances you might want to have applications auto-approved,
  # so that the user skips the authorization step.
  # For example if dealing with a trusted application.
  # skip_authorization do |_, client|
  #   client.id == 0
  # end

  # WWW-Authenticate Realm (default "Doorkeeper").
  # realm "Doorkeeper"
end

Doorkeeper::JWT.configure do
  # Set the payload for the JWT token. This should contain unique information
  # about the user.
  # Defaults to a randomly generated token in a hash
  # { token: "RANDOM-TOKEN" }
  token_payload do |opts|
    user =
      if opts[:scopes].include?('guest')
        GuestUser.new(
          id: opts[:resource_owner_id],
          language: I18n.locale
        )
      elsif opts[:resource_owner_id]
        User.find(opts[:resource_owner_id])
      end

    payload = {
      iat: Time.current.to_i,
      iss: ActsAsTenant.current_tenant&.iri,
      scopes: opts[:scopes].entries,
      application_id: opts[:application]&.uid
    }
    if user
      payload[:user] = {
        type: user.guest? ? 'guest' : 'user',
        '@id': user.iri,
        id: user.id.to_s,
        email: user.email,
        language: user.language
      }
    end
    payload[:exp] = (opts[:created_at] + opts[:expires_in].seconds).to_i if opts[:expires_in].present?
    payload
  end

  # Use the application secret specified in the Access Grant token
  # Defaults to false
  # If you specify `use_application_secret true`, both secret_key and secret_key_path will be ignored
  # use_application_secret true

  # Set the encryption secret. This would be shared with any other applications
  # that should be able to read the payload of the token.
  # Defaults to "secret"
  secret_key Rails.application.secrets.jwt_encryption_token

  # If you want to use RS* encoding specify the path to the RSA key
  # to use for signing.
  # If you specify a secret_key_path it will be used instead of secret_key
  # secret_key_path 'path/to/file.pem'

  # Specify encryption type. Supports any algorithim in
  # https://github.com/progrium/ruby-jwt
  # defaults to nil
  encryption_method Rails.application.config.jwt_encryption_method
end

module Doorkeeper
  class AccessToken < ActiveRecord::Base
    extend JWTHelper

    validate :validate_scope_for_resource_owner

    private

    def validate_scope_for_resource_owner
      return if resource_owner_id || scopes.to_s == 'guest'

      raise Doorkeeper::Errors::DoorkeeperError.new(:invalid_grant)
    end
  end

  class Application < ActiveRecord::Base
    ARGU_ID = 0
    def self.argu
      Doorkeeper::Application.find(Doorkeeper::Application::ARGU_ID)
    end

    AFE_ID = 1
    def self.argu_front_end
      Doorkeeper::Application.find(Doorkeeper::Application::AFE_ID)
    end

    SERVICE_ID = 2
    def self.argu_service
      Doorkeeper::Application.find(Doorkeeper::Application::SERVICE_ID)
    end
  end

  module OAuth
    class PasswordAccessTokenRequest < BaseRequest
      private

      def validate_client
        client.present?
      end
    end
  end
end
