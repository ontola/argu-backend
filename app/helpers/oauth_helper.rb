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

  def current_actor # rubocop:disable Metrics/AbcSize
    return @current_actor if @current_actor.present?
    refresh_guest_token if needs_new_guest_token?
    user = current_resource_owner
    actor = if request.parameters[:actor_iri].present? && request.parameters[:actor_iri] != '-1'
              resource_from_iri!(request.parameters[:actor_iri]).profile
            else
              user.profile
            end
    @current_actor = CurrentActor.new(user: user, actor: actor)
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
    doorkeeper_token&.scopes
  end

  def doorkeeper_oauth_header?
    Doorkeeper::OAuth::Token.from_bearer_authorization(request)
  end

  def set_argu_client_token_cookie(token, expires = nil)
    cookies.encrypted['argu_client_token'] = {
      expires: expires,
      value: token,
      secure: request.ssl? && (Rails.env.staging? || Rails.env.production?),
      httponly: true,
      domain: :all
    }
  end

  private

  def doorkeeper_token
    @_raw_doorkeeper_token || super
  end

  def doorkeeper_token_payload
    @doorkeeper_token_payload ||= decode_token(doorkeeper_token.token)
  end

  def generate_user_token(resource, application: Doorkeeper::Application.argu)
    Doorkeeper::AccessToken.find_or_create_for(
      application,
      resource.id,
      new_token_scopes(:user, application.id),
      Doorkeeper.configuration.access_token_expires_in,
      false
    )
  end

  def generate_guest_token(guest_id, application: Doorkeeper::Application.argu)
    store_guest_language(guest_id)

    Doorkeeper::AccessToken.find_or_create_for(
      application,
      guest_id,
      new_token_scopes(:guest, application.id),
      2.days,
      false
    )
  end

  def new_token_scopes(requested_scope, application_id)
    return requested_scope unless application_id == Doorkeeper::Application::AFE_ID
    [requested_scope, :afe].join(' ')
  end

  def needs_new_guest_token?
    return false if afe_request?

    raw_doorkeeper_token.blank? || raw_doorkeeper_token&.expired? || current_resource_owner.blank?
  end

  def raw_doorkeeper_token
    @_raw_doorkeeper_token ||= Doorkeeper::OAuth::Token.authenticate(
      request,
      *Doorkeeper.configuration.access_token_methods
    )
  end

  def refresh_guest_token
    raw_doorkeeper_token.destroy! if raw_doorkeeper_token&.expired?
    session[:load] = true unless session.loaded?
    @_raw_doorkeeper_token = generate_guest_token(session_id.to_s)
    set_argu_client_token_cookie(raw_doorkeeper_token.token)
    true
  end

  def update_oauth_token(token)
    afe_request? ? response.headers['New-Authorization'] = token : set_argu_client_token_cookie(token)
  end
end
