# frozen_string_literal: true

module OauthHelper
  include LanguageHelper
  include JWTHelper
  include FrontendTransitionHelper
  include Doorkeeper::Rails::Helpers
  include Doorkeeper::Helpers::Controller

  def current_user
    current_actor.user
  end

  def current_actor
    return @current_actor if @current_actor.present?
    refresh_guest_token if needs_new_guest_token?
    user = current_resource_owner || GuestUser.new
    @current_actor =
      CurrentActor.new(user: user, actor: current_actor_profile(user))
    @current_actor
  end

  def current_actor_profile(user)
    if request.parameters[:actor_iri].present? && request.parameters[:actor_iri] != '-1'
      resource_from_iri!(request.parameters[:actor_iri]).profile
    else
      user.profile
    end
  end

  def sign_in(resource, *_args)
    update_oauth_token(generate_user_token(resource, application: doorkeeper_token.application).token)
    current_actor.user = resource
    user_context.user = resource
    set_layout
    warden.set_user(resource, scope: :user, store: false) unless warden.user(:user) == resource
  end

  def doorkeeper_guest_token?
    doorkeeper_scopes.include? 'guest'
  end

  def doorkeeper_scopes
    doorkeeper_token&.scopes || []
  end

  def doorkeeper_oauth_header?
    Doorkeeper::OAuth::Token.from_bearer_authorization(request)
  end

  def set_argu_client_token_cookie(token, expires = nil)
    return unless respond_to?(:cookies, true)

    cookies.encrypted['argu_client_token'] = {
      expires: expires,
      value: token,
      secure: request.ssl? && (Rails.env.staging? || Rails.env.production?),
      httponly: true,
      domain: Rails.env.staging? ? nil : :all
    }
  end

  private

  def doorkeeper_token_payload
    @doorkeeper_token_payload ||= decode_token(doorkeeper_token.token)
  end

  def generate_user_token(resource, application: nil)
    application ||= Doorkeeper::Application.argu
    Doorkeeper::AccessToken.find_or_create_for(
      application,
      resource.id,
      new_token_scopes(:user, application.id),
      Doorkeeper.configuration.access_token_expires_in,
      false
    )
  end

  def generate_guest_token(guest_id, application: nil, locale: nil)
    application ||= vnext_request? ? Doorkeeper::Application.argu_front_end : Doorkeeper::Application.argu
    I18n.locale = locale || language_for_guest

    token = Doorkeeper::AccessToken.new(
      application: application,
      resource_owner_id: guest_id,
      scopes: new_token_scopes(:guest, application.id),
      expires_in: 2.days
    )
    token.send(:generate_token)
    token
  end

  def guest_session_id
    return doorkeeper_token&.resource_owner_id || SecureRandom.hex if afe_request?

    session[:load] = true unless session.loaded?
    session_id.to_s
  end

  def new_token_scopes(requested_scope, application_id)
    return requested_scope unless application_id == Doorkeeper::Application::AFE_ID
    [requested_scope, :afe].join(' ')
  end

  def needs_new_guest_token?
    doorkeeper_token.blank? || doorkeeper_token&.expired? || current_resource_owner.blank?
  end

  def refresh_guest_token
    doorkeeper_token.destroy! if doorkeeper_token&.expired?
    @doorkeeper_token = generate_guest_token(guest_session_id)
    update_oauth_token(doorkeeper_token.token)
    true
  end

  def service_token?
    doorkeeper_scopes.include?('service')
  end

  def update_oauth_token(token)
    vnext_request? ? response.headers['New-Authorization'] = token : set_argu_client_token_cookie(token)
  end
end
