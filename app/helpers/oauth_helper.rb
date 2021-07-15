# frozen_string_literal: true

module OauthHelper
  include LanguageHelper

  private

  def create_guest_user
    User.guest(session_id)
  end

  def current_actor
    user_context.current_actor
  end

  def current_actor_profile(user) # rubocop:disable Metrics/AbcSize
    if request.parameters[:actor_iri].present? && !request.parameters[:actor_iri].try(:literal?)
      LinkedRails.iri_mapper.resource_from_iri!(request.parameters[:actor_iri], nil).profile
    else
      user.profile
    end
  end

  def current_user
    user_context&.user
  end

  # @return [Profile] The {Profile} used by the {User}
  def current_profile
    user_context.profile
  end

  def generate_access_token(resource_owner)
    Doorkeeper::AccessToken.find_or_create_for(
      application: doorkeeper_token&.application,
      resource_owner: UserContext.new(language: I18n.locale, session_id: session_id, user: resource_owner),
      scopes: resource_owner.guest? ? :guest : :user,
      expires_in: Doorkeeper.configuration.access_token_expires_in,
      use_refresh_token: true
    )
  end

  def sign_in(resource, otp_verified: true)
    raise('2fa not verified') if resource.otp_active? && !otp_verified

    super
    user_context.user = resource
  end

  def session_id
    user_context.session_id
  end

  def service_token?
    doorkeeper_scopes.include?('service')
  end

  def user_context
    @user_context ||= request.env['User-Context'] || user_context_from_token
  end

  def user_context_from_token
    context = current_resource_owner
    context.profile = current_actor_profile(current_resource_owner.user)
    context
  end
end
