# frozen_string_literal: true

class JWTBuilder
  attr_accessor :application, :created_at, :expires_in, :user_context, :scopes

  def initialize(opts)
    self.application = opts[:application]
    self.created_at = opts[:created_at]
    self.expires_in = opts[:expires_in]
    self.user_context = opts[:resource_owner]
    self.scopes = opts[:scopes]
  end

  def build
    payload = base
    payload[:user] = user_payload if user_type
    payload[:exp] = (created_at + expires_in.seconds).to_i if expires_in.present?
    payload
  end

  private

  def base
    {
      iat: Time.current.to_i,
      iss: ActsAsTenant.current_tenant&.iri,
      scopes: scopes.entries,
      application_id: application&.uid,
      session_id: user_context&.session_id
    }
  end

  def service?
    scopes.exists?(:service)
  end

  def user
    return User.service if service?

    user_context&.user
  end

  def user_payload
    {
      '@id': user.iri,
      id: user.id.to_s,
      email: user.email,
      language: user_context&.language || I18n.locale,
      type: user_type
    }
  end

  def user_type
    return 'service' if service?
    return unless user

    user.guest? ? 'guest' : 'user'
  end
end

Doorkeeper::JWT.configure do
  # Set the payload for the JWT token. This should contain unique information
  # about the user.
  # Defaults to a randomly generated token in a hash
  # { token: "RANDOM-TOKEN" }
  token_payload do |opts|
    JWTBuilder.new(opts).build
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
