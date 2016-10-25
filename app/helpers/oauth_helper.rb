# frozen_string_literal: true
module OauthHelper
  include Doorkeeper::Helpers::Controller, Doorkeeper::Rails::Helpers

  def current_user
    @_current_user ||= current_resource_owner
  end

  def sign_in(resource, *_args)
    t = Doorkeeper::AccessToken.find_or_create_for(
      Doorkeeper::Application.find(0),
      resource.id,
      'user',
      2.weeks,
      false
    )
    cookies.encrypted['client_token'] = t.token
  end

  def write_client_access_token
    refresh_guest_token if needs_new_guest_token
  end

  private

  def doorkeeper_token
    @_raw_doorkeeper_token || super
  end

  def generate_guest_token
    session[:load] = true unless session.loaded?
    Doorkeeper::AccessToken.find_or_create_for(
      Doorkeeper::Application.find(0),
      session.id.to_s,
      'guest',
      1.hour,
      false
    )
  end

  def needs_new_guest_token
    if Rails.env.production?
      # Ensure that the host ends with 'argu.co' to unmatch e.g. argu.co.malicious.net
      return false if request.env['HTTP_HOST'] =~ /argu\.co$/
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
    cookies.encrypted['client_token'] = raw_doorkeeper_token.token
    true
  end
end
