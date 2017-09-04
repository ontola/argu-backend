# frozen_string_literal: true

module OauthHelper
  include LanguageHelper
  include Doorkeeper::OAuth::Token::Methods
  include Doorkeeper::Rails::Helpers
  include Doorkeeper::Helpers::Controller

  def current_user
    current_actor.user
  end

  def current_actor
    return @current_actor if @current_actor.present?
    user = current_resource_owner || GuestUser.new(
      cookies: request.cookie_jar,
      headers: request.headers,
      language: set_guest_language,
      session: session
    )
    actor = if request.parameters[:actor_iri].present? && request.parameters[:actor_iri] != '-1'
              resource_from_iri(request.parameters[:actor_iri]).profile
            else
              user.profile
            end
    @current_actor = CurrentActor.new(user: user, actor: actor)
  end

  def sign_in(resource, *_args)
    t = Doorkeeper::AccessToken.find_or_create_for(
      Doorkeeper::Application.argu,
      resource.id,
      'user',
      Doorkeeper.configuration.access_token_expires_in,
      false
    )
    set_argu_client_token_cookie(t.token)
    warden.set_user(resource, scope: :user, store: false) unless warden.user(:user) == resource
  end

  def write_client_access_token
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

  def set_argu_client_token_cookie(token, expires = nil)
    cookies.encrypted['argu_client_token'] = {
      expires: expires,
      value: token,
      secure: Rails.env.production?,
      httponly: true,
      domain: :all
    }
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
      2.days,
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
    set_argu_client_token_cookie(raw_doorkeeper_token.token)
    true
  end
end
