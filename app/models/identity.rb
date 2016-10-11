# frozen_string_literal: true
require 'publishable'

class Identity < ApplicationRecord
  belongs_to :user
  after_destroy :clear_token_connection
  validates :uid, :provider, presence: true
  validates :uid, uniqueness: {scope: :provider}

  def self.find_for_oauth(auth)
    find_or_initialize_by(uid: auth.uid, provider: auth.provider)
  end

  def access_token=(value)
    super ActiveSupport::MessageEncryptor.new(Rails.application.secrets.secret_key_base).encrypt_and_sign(value)
  end

  def access_token
    ActiveSupport::MessageEncryptor.new(Rails.application.secrets.secret_key_base).decrypt_and_verify(super) if super
  rescue ActiveSupport::MessageVerifier::InvalidSignature => e
    Bugsnag.notify(e)
  end

  def access_secret=(value)
    super ActiveSupport::MessageEncryptor.new(Rails.application.secrets.secret_key_base).encrypt_and_sign(value)
  end

  def access_secret
    ActiveSupport::MessageEncryptor.new(Rails.application.secrets.secret_key_base).decrypt_and_verify(super) if super
  rescue ActiveSupport::MessageVerifier::InvalidSignature => e
    Bugsnag.notify(e)
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
end
