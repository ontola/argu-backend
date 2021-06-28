# frozen_string_literal: true

class UsersController < AuthorizedController
  skip_before_action :verify_setup

  private

  def changes_triples
    super + [
      change_triple(NS.schema.name, current_resource.display_name)
    ]
  end

  def current_user?
    current_resource == current_user
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
