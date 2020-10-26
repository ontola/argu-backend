# frozen_string_literal: true

module OauthHelper
  include LinkedRails::Auth::AuthHelper
  include LanguageHelper

  private

  def create_guest_user
    GuestUser.new(id: :transient_session, language: language_for_guest)
  end

  def current_actor
    @current_actor ||= CurrentActor.new(user: current_user, actor: current_actor_profile(current_user))
  end

  def current_actor_profile(user) # rubocop:disable Metrics/AbcSize
    if request.parameters[:actor_iri].present? && !request.parameters[:actor_iri].try(:literal?)
      LinkedRails.resource_from_iri!(request.parameters[:actor_iri]).profile
    else
      user.profile
    end
  end

  def current_user
    request.env['Current-User'] || super
  end

  def doorkeeper_token
    request.env['Doorkeeper-Token'] || super
  end

  def doorkeeper_unauthorized_render_options(error: nil)
    @user_context ||= UserContext.new(doorkeeper_scopes: [], profile: nil, user: nil)

    super
  end

  def handle_invalid_token
    doorkeeper_render_error
  end

  def sign_in(resource, *_args)
    super
    current_actor.user = resource
    user_context.user = resource
  end

  def session_id
    @session_id ||= doorkeeper_token.resource_owner_id
  end

  def service_token?
    doorkeeper_scopes.include?('service')
  end
end
