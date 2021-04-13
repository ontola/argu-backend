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

    raise Argu::Errors::Unauthorized.new
  end

  def changes_triples
    super + [
      change_triple(NS::SCHEMA[:name], current_resource.display_name)
    ]
  end

  def current_user?
    current_resource == current_user
  end

  def delete_meta
    return [] unless current_user?

    [
      RDF::Statement.new(delete_iri('users'), NS::OWL.sameAs, delete_iri(current_resource))
    ]
  end

  def delete_success
    respond_with_resource(
      include: action_form_includes,
      resource: current_resource.action(:destroy, user_context),
      meta: delete_meta
    )
  end

  def destroy_execute
    current_resource.assign_attributes(permit_params)

    ActsAsTenant.without_tenant { super }
  end

  def destroy_success
    if current_user?
      Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    end

    super
  end

  def requested_resource
    @requested_resource ||=
      case action_name
      when 'show', 'delete', 'destroy'
        user = params[:id] ? User.preload(:profile).find_via_shortname_or_id(params[:id]) : current_resource_owner
        show_anonymous_user?(user) ? AnonymousUser.new(url: params[:id]) : user
      else
        authorized_current_user
      end
  end

  def show_anonymous_user?(user)
    (current_resource_owner.nil? || current_resource_owner.guest?) &&
      user.present? && !user.is_public?
  end

  def email_changed? # rubocop:disable Metrics/AbcSize
    return if permit_params[:email_addresses_attributes].blank?

    permit_params[:email_addresses_attributes].any? do |email|
      email.second['id'].nil? ||
        email.second['email'].present? &&
          authenticated_resource.email_addresses.find(email.second['id']).email != email.second['email']
    end
  end

  def permit_params(_password = false)
    attrs = policy(authenticated_resource || User).permitted_attributes
    pp = params.require(:user).permit(*attrs).to_h
    merge_photo_params(pp)
    merge_placement_params(pp, User)
  end

  def redirect_location
    r_param || super
  end

  def active_response_success_message
    return super unless action_name == 'update'

    if @email_changed
      I18n.t('users.registrations.confirm_mail_change_notice')
    else
      I18n.t('type_save_success', type: I18n.t('type_changes'))
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
    permit_params[:password].present?
  end
end
