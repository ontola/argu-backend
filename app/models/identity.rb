
class Identity < ActiveRecord::Base
  belongs_to :user
  after_destroy :clear_token_connection
  validates_presence_of :uid, :provider
  validates_uniqueness_of :uid, scope: :provider

  def self.find_for_oauth(auth)
    find_or_initialize_by(uid: auth.uid, provider: auth.provider)
  end

  def access_token=(value)
    super ActiveSupport::MessageEncryptor.new(Rails.application.secrets.secret_key_base).encrypt_and_sign(value)
  end

  def access_token
    begin
      ActiveSupport::MessageEncryptor.new(Rails.application.secrets.secret_key_base).decrypt_and_verify(super) if super
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      nil
    end
  end

  def access_secret=(value)
    super ActiveSupport::MessageEncryptor.new(Rails.application.secrets.secret_key_base).encrypt_and_sign(value)
  end

  def access_secret
    begin
      ActiveSupport::MessageEncryptor.new(Rails.application.secrets.secret_key_base).decrypt_and_verify(super) if super
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      nil
    end
  end

  def clear_token_connection
    # TODO: let the auth provider know it can destroy the connection
  end

  def client
    @_wrapper ||= Publishable::Wrappers.const_get(self.provider.classify).new(self.access_token, self.access_secret)
  end

  def publish(publishable)
    Publishable::Publishers.const_get(self.provider.classify).publish(self, publishable)
  end

  def email
    client && client.email
  end

  def name
    client && client.name
  end

  def username
    client && client.username
  end

  def image_url
    client && client.image_url
  end

end
