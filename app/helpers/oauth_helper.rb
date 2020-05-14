# frozen_string_literal: true

module OauthHelper
  include LanguageHelper
  include JWTHelper
  include Doorkeeper::Rails::Helpers
  include Doorkeeper::Helpers::Controller

  def current_user
    current_actor.user
  end

  def current_actor
    return @current_actor if @current_actor.present?

    user = current_resource_owner || GuestUser.new(language: language_for_guest)
    doorkeeper_render_error unless valid_token?

    @current_actor =
      CurrentActor.new(user: user, actor: current_actor_profile(user))
    @current_actor
  end

  def current_actor_profile(user)
    if request.parameters[:actor_iri].present? && request.parameters[:actor_iri] != '-1'
      LinkedRails.resource_from_iri!(request.parameters[:actor_iri]).profile
    else
      user.profile
    end
  end

  def doorkeeper_unauthorized_render_options(error: nil)
    @user_context ||= UserContext.new(doorkeeper_scopes: [], profile: nil, user: nil)

    {
      json: {
        error: :invalid_token,
        error_description: error&.description
      }
    }
  end

  def sign_in(resource, *_args)
    update_oauth_token(generate_access_token(resource))
    current_actor.user = resource
    user_context.user = resource
    warden.set_user(resource, scope: :user, store: false) unless warden.user(:user) == resource
  end

  def sign_out(*args)
    super

    update_oauth_token(generate_access_token(GuestUser.new))
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

  def session_id
    @session_id ||= doorkeeper_token.resource_owner_id
  end

  private

  def doorkeeper_token_payload
    @doorkeeper_token_payload ||= decode_token(doorkeeper_token.token)
  end

  def generate_access_token(resource_owner)
    doorkeeper_token.revoke if doorkeeper_token&.resource_owner_id

    Doorkeeper::AccessToken.find_or_create_for(
      application: doorkeeper_token&.application || Doorkeeper::Application.argu_front_end,
      resource_owner: resource_owner,
      scopes: resource_owner.guest? ? :guest : :user,
      expires_in: Doorkeeper.configuration.access_token_expires_in,
      use_refresh_token: true
    )
  end

  def new_token_scopes(requested_scope, _application_id)
    requested_scope
  end

  def service_token?
    doorkeeper_scopes.include?('service')
  end

  def update_oauth_token(token)
    response.headers['New-Refresh-Token'] = token.refresh_token
    response.headers['New-Authorization'] = token.token
  end

  def valid_token?
    return ApplicationController::SAFE_METHODS.include?(request.method) if doorkeeper_token.blank?

    doorkeeper_token&.accessible?
  end
end
