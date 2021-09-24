# frozen_string_literal: true

class UsersController < AuthorizedController # rubocop:disable Metrics/ClassLength
  skip_before_action :verify_setup

  has_singular_update_action
  has_resource_update_action(
    label: -> { I18n.t('actions.users.update.label') }
  )
  has_resource_destroy_action(
    **confirmed_destroy_options(
      description: -> { I18n.t('actions.users.destroy.description', name: resource.display_name) },
      form: Users::DestroyForm
    )
  )
  has_singular_action(
    :language,
    form: ::Users::LanguageForm,
    http_method: :put,
    image: 'fa-update',
    label: -> { I18n.t('set_language') },
    policy: :update?,
    submit_label: -> { I18n.t('save') },
    type: NS.schema.UpdateAction
  )
  has_singular_destroy_action(
    **confirmed_destroy_options(
      description: -> { I18n.t('actions.users.destroy.description', name: resource.display_name) },
      form: Users::DestroyForm
    )
  )
  has_resource_action(
    :profile,
    form: ::Users::ProfileForm,
    label: -> { I18n.t('profiles.edit.title') },
    http_method: :put,
    image: 'fa-update',
    policy: :update?,
    target_url: -> { resource.iri },
    type: NS.schema.UpdateAction
  )
  has_singular_action(
    :setup,
    form: Users::SetupForm,
    http_method: :put,
    image: 'fa-update',
    policy: :update?,
    target_url: -> { resource.iri },
    type: NS.schema.UpdateAction
  )

  private

  def active_response_success_message
    return super unless action_name == 'update'

    if @email_changed
      I18n.t('users.registrations.confirm_mail_change_notice')
    else
      I18n.t('type_save_success', type: I18n.t('type_changes'))
    end
  end

  def changes_triples
    super + [
      change_triple(NS.schema.name, current_resource.name_with_fallback)
    ]
  end

  def check_if_registered?
    return super unless action_name == 'language'

    false
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

  def language_execute
    return false unless valid_locale?

    I18n.locale = locale_param
    current_user.language = locale_param

    return false unless current_user.guest? || current_user.save

    update_oauth_token(new_oauth_token)
  end

  def language_failure
    respond_with_redirect(location: request.headers['Referer'] || root_path, notice: I18n.t('errors.general'))
  end

  def language_success
    respond_with_redirect(location: request.headers['Referer'] || root_path)
  end

  def locale_param
    (params.permit(:locale)[:locale] || params.require(:user).require(:language)).to_sym
  end

  def new_oauth_token
    generate_access_token(current_user)
  end

  def password_required
    permit_params[:password].present?
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

  def update_execute
    @email_changed = email_changed?
    if password_required
      bypass_sign_in(authenticated_resource) if authenticated_resource.update_with_password(permit_params(true))
    else
      authenticated_resource.update_without_password(permit_params) && authenticated_resource.profile.save
    end
  end

  def valid_locale?
    return true if I18n.available_locales.include?(locale_param)

    Bugsnag.notify(RuntimeError.new("Invalid locale #{locale_param}"))
    false
  end
end
