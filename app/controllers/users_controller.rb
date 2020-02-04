# frozen_string_literal: true

class UsersController < AuthorizedController
  include VotesHelper
  include UrlHelper

  def wrong_email
    render locals: {email: params[:email], r: r_param}
  end

  private

  def authorized_current_user
    return current_resource_owner unless current_resource_owner&.guest?

    flash[:error] = t('devise.failure.unauthenticated')
    raise Argu::Errors::Unauthorized.new
  end

  def changes_triples
    super + [
      change_triple(NS::SCHEMA[:name], current_resource.display_name)
    ]
  end

  def resource_by_id
    @resource_by_id ||=
      case action_name
      when 'show'
        user = User.preload(:profile).find_via_shortname_or_id(params[:id])
        show_anonymous_user?(user) ? AnonymousUser.new(url: params[:id]) : user
      else
        authorized_current_user
      end
  end

  def show_anonymous_user?(user)
    (current_resource_owner.nil? || current_resource_owner.guest?) &&
      user.present? && !user.profile.is_public?
  end

  def email_changed? # rubocop:disable Metrics/AbcSize
    return if permit_params[:email_addresses_attributes].blank?
    permit_params[:email_addresses_attributes].any? do |email|
      email.second['id'].nil? ||
        email.second['email'].present? &&
          authenticated_resource.email_addresses.find(email.second['id']).email != email.second['email']
    end
  end

  def resource_settings_iri
    settings_iri('/u', tab: tab)
  end

  def permit_params(password = false) # rubocop:disable Metrics/AbcSize
    attrs = policy(authenticated_resource || User).permitted_attribute_names(password)
    pp = params.require(:user).permit(*attrs).to_h
    merge_photo_params(pp)
    merge_placement_params(pp, User)
    pp['email_addresses_attributes'][pp[:primary_email][1..-2]][:primary] = true if pp[:primary_email].present?
    pp.except(:primary_email)
  end

  def redirect_location
    r_param || resource_settings_iri
  end

  def tree_root_fallback
    return super if params[:id].blank? || resource_by_id == current_resource_owner

    user_root_fallback || super
  end

  def active_response_success_message
    if @email_changed
      t('users.registrations.confirm_mail_change_notice')
    else
      t('type_save_success', type: t('type_changes'))
    end
  end

  def update_execute
    @email_changed = email_changed?
    if password_required
      bypass_sign_in(authenticated_resource) if authenticated_resource.update_with_password(permit_params(true))
    else
      authenticated_resource.update_without_password(permit_params) && authenticated_resource.profile.save
    end
  end

  def password_required
    permit_params[:password].present? ||
      params[:user][:primary_email].present? && params[:user][:primary_email] != '[0]'
  end

  def user_root_fallback
    resource_by_id&.edges&.last&.root || Page.argu
  end
end
