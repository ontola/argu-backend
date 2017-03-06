# frozen_string_literal: true
require 'publishable'

class Identity < ApplicationRecord
  belongs_to :user
  after_destroy :clear_token_connection
  validates :uid, :provider, presence: true
  validates :uid, uniqueness: {scope: :provider}
  KEY_GENERATOR = ActiveSupport::KeyGenerator.new(Rails.application.secrets.secret_key_base)

  def self.find_for_oauth(auth)
    find_or_initialize_by(uid: auth.uid, provider: auth.provider)
  end

  def access_token=(value)
    super encrypt_value(value)
  end

  def access_token
    decrypt_value(super)
  end

  def access_secret=(value)
    super encrypt_value(value)
  end

  def access_secret
    decrypt_value(super)
  end

  def clear_token_connection
    # TODO: let the auth provider know it can destroy the connection
  end

  def client
    @_wrapper ||= Publishable::Wrappers.const_get(provider.classify).new(access_token, access_secret)
  end

  def publish(publishable)
    Publishable::Publishers.const_get(provider.classify).publish(self, publishable)
  end

  delegate :email, to: :client

  delegate :name, to: :client

  delegate :username, to: :client

  delegate :image_url, to: :client

  private

  def encrypt_value(value)
    salt = SecureRandom.random_bytes(64)
    key = KEY_GENERATOR.generate_key(salt, 32)
    "#{Base64.encode64(salt)}.#{ActiveSupport::MessageEncryptor.new(key, digest: 'RIPEMD160').encrypt_and_sign(value)}"
  end

  def decrypt_value(value)
    return if value.nil?
    salt, value = value.split('.')
    key = KEY_GENERATOR.generate_key(Base64.decode64(salt), 32)
    ActiveSupport::MessageEncryptor.new(key, digest: 'RIPEMD160').decrypt_and_verify(value)
  rescue ActiveSupport::MessageVerifier::InvalidSignature => e
    Bugsnag.notify(e)
  end
end
