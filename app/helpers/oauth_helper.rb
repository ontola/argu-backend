# frozen_string_literal: true
module OauthHelper
  include Doorkeeper::Helpers::Controller, Doorkeeper::Rails::Helpers, Doorkeeper::OAuth::Token::Methods

  def current_user
    @_current_user ||= current_resource_owner
  end

  def sign_in(resource, *_args)
    t = Doorkeeper::AccessToken.find_or_create_for(
      Doorkeeper::Application.argu,
      resource.id,
      'user',
      Doorkeeper.configuration.access_token_expires_in,
      false
    )
    cookies.encrypted['argu_client_token'] = {
      value: t.token,
      secure: !Rails.env.test?,
      httponly: true,
      domain: :all
    }
  end

  def write_client_access_token
    migrate_token
    refresh_guest_token if needs_new_guest_token
  end

  def doorkeeper_guest_token?
    doorkeeper_scopes.include? 'guest'
  end

  def doorkeeper_scopes
    doorkeeper_token&.scopes
  end

  def doorkeeper_oauth_header?
    from_bearer_authorization(request)
  end

  private

  def doorkeeper_token
    @_raw_doorkeeper_token || super
  end

  def generate_guest_token
    session[:load] = true unless session.loaded?
    Doorkeeper::AccessToken.find_or_create_for(
      Doorkeeper::Application.argu,
      session.id.to_s,
      'guest',
      1.hour,
      false
    )
  end

  def needs_new_guest_token
    if Rails.env.production?
      # Ensure that the host ends with 'argu.co' to unmatch e.g. argu.co.malicious.net
      return false unless request.env['HTTP_HOST'] =~ /argu\.co$/
    end
    raw_doorkeeper_token.blank? || raw_doorkeeper_token&.expired?
  end

  def raw_doorkeeper_token
    @_raw_doorkeeper_token ||= Doorkeeper::OAuth::Token.authenticate(
      request,
      *Doorkeeper.configuration.access_token_methods
    )
  end

  def refresh_guest_token
    raw_doorkeeper_token.destroy! if raw_doorkeeper_token&.expired?
    @_raw_doorkeeper_token = generate_guest_token
    cookies.encrypted['argu_client_token'] = {
      value: raw_doorkeeper_token.token,
      secure: !Rails.env.test?,
      httponly: true,
      domain: :all
    }
    true
  end

  # @todo remove when enough people had the chance to migrate to the new token
  def migrate_token
    return unless cookies['client_token'].present?
    cookies.encrypted['argu_client_token'] = {
      value: cookies.encrypted['client_token'],
      secure: !Rails.env.test?,
      httponly: true,
      domain: :all
    }
    request.cookies['argu_client_token'] = cookies['argu_client_token']
    cookies.delete 'client_token', domain: :all
  end
end
