# frozen_string_literal: true

class UsersController < AuthorizedController
  include VotesHelper
  include UrlHelper
  include NestedResourceHelper
  helper_method :authenticated_resource

  def wrong_email
    render locals: {email: params[:email], r: r_param}
  end

  private

  def authenticated_resource! # rubocop:disable Metrics/AbcSize
    @user ||= case action_name
              when 'show'
                User.preload(:profile).find_via_shortname_or_id(params[:id])
              when 'update'
                User.find_by(id: current_user.id)
              else
                if current_user.guest?
                  flash[:error] = t('devise.failure.unauthenticated')
                  raise Argu::Errors::Unauthorized.new
                end
                current_user
              end
  end

  def email_changed? # rubocop:disable Metrics/AbcSize
    return if permit_params[:email_addresses_attributes].blank?
    permit_params[:email_addresses_attributes].any? do |email|
      email.second['id'].nil? ||
        email.second['email'].present? &&
          authenticated_resource.email_addresses.find(email.second['id']).email != email.second['email']
    end
  end

  def permit_params(password = false) # rubocop:disable Metrics/AbcSize
    attrs = policy(authenticated_resource || User).permitted_attribute_names(password)
    pp = params.require(:user).permit(*attrs).to_h
    merge_photo_params(pp, authenticated_resource.class)
    merge_placement_params(pp, User)
    pp['email_addresses_attributes'][pp[:primary_email][1..-2]][:primary] = true if pp[:primary_email].present?
    pp.except(:primary_email)
  end

  def redirect_location
    r_param || settings_iri('/u', tab: tab)
  end

  def settings_success_html
    authenticated_resource.build_home_placement if authenticated_resource.home_placement.nil?
    authenticated_resource.build_shortname if authenticated_resource.shortname.nil?
    super
  end

  def settings_view_locals
    super.merge(profile: authenticated_resource.profile)
  end

  def show_success_html # rubocop:disable Metrics/AbcSize
    if (/[a-zA-Z]/i =~ params[:id]).nil? && authenticated_resource.url.present?
      redirect_to authenticated_resource.iri, status: 307
    else
      available_pages = authenticated_resource.profile.active_pages(current_profile.granted_root_ids(nil))
      render 'show', locals: {
        available_pages: available_pages,
        organization_feed: "#{feeds_iri(authenticated_resource)}.js"
      }
    end
  end

  def update_failure_html # rubocop:disable Metrics/AbcSize
    if params[:user][:form] == 'wrong_email'
      email = params[:user][:email_addresses_attributes]['99999'][:email]
      if current_user.email_addresses.any? { |e| e.email == email }
        redirect_to r_param
      else
        render 'wrong_email', locals: {email: email, r: r_param}
      end
    else
      render 'settings',
             locals: {tab: tab!, active: tab!, profile: authenticated_resource.profile}
    end
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
end
