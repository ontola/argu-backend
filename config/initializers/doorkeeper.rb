# frozen_string_literal: true

Doorkeeper.configure do
  # Change the ORM that doorkeeper will use.
  # Currently supported options are :active_record, :mongoid2, :mongoid3,
  # :mongoid4, :mongo_mapper
  orm :active_record

  api_only
  base_controller 'ApplicationController'
  base_metal_controller 'ApplicationController'

  use_polymorphic_resource_owner

  # This block will be called to check whether the resource owner is authenticated or not.
  resource_owner_authenticator do
    UserContext.new(doorkeeper_token: doorkeeper_token)
  end

  resource_owner_from_credentials do
    request.params[:user] = request.params[:access_token] || {}
    request.params[:user][:email] ||= (request.params[:username] || request.params[:email])&.downcase
    request.params[:user][:password] ||= request.params[:token] || request.params[:password]
    request.env['devise.allow_params_authentication'] = true
    guest = request.params[:scope] == 'guest'
    user = guest ? User.guest : request.env['warden'].authenticate(scope: :user, store: false)
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
      UserContext.new(user: user)
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
  optional_scopes :user, :openid

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
  grant_flows %w[authorization_code password client_credentials implicit_oidc]

  # Under some circumstances you might want to have applications auto-approved,
  # so that the user skips the authorization step.
  # For example if dealing with a trusted application.
  skip_authorization do |_user_context, client|
    client.scopes.include?('service')
  end

  # WWW-Authenticate Realm (default "Doorkeeper").
  # realm "Doorkeeper"
end
