# frozen_string_literal: true
class UsersController < AuthorizedController
  include NestedResourceHelper,
          UrlHelper,
          VotesHelper
  helper_method :authenticated_resource, :complete_feed_param
  skip_before_action :authorize_action, only: :current_actor
  skip_before_action :check_if_registered, only: :current_actor

  def show
    respond_to do |format|
      format.html do
        @activities = policy_scope(Activity.feed_for_profile(authenticated_resource.profile))
                        .order(created_at: :desc)
                        .limit(10)
        preload_user_votes(vote_event_ids_from_activities(@activities))

        if (/[a-zA-Z]/i =~ params[:id]).nil?
          redirect_to url_for(authenticated_resource), status: 307
        else
          render 'show'
        end
      end
      format.json { respond_with_200(authenticated_resource, :json) }
      format.json_api do
        render json: authenticated_resource,
               include: [
                 :profile_photo,
                 vote_match_collection: INC_NESTED_COLLECTION
               ]
      end
    end
  end

  def current_actor
    skip_authorization
    actor = CurrentActor.new(user: current_user, actor: current_profile)
    respond_to do |format|
      format.json { respond_with_200(actor, :json) }
      format.json_api { render json: actor, include: [:profile_photo, :user, :actor] }
    end
  end

  def settings
    authenticated_resource.build_home_placement if authenticated_resource.home_placement.nil?
    render 'settings', locals: {
      tab: tab,
      active: tab,
      profile: authenticated_resource.profile
    }
  end

  # PUT /settings
  def update
    @email_changed = email_changed?
    exec_action
  end

  # When shortname isn't set yet
  def setup
    authenticated_resource.build_shortname if authenticated_resource.shortname.blank?

    render 'setup_shortname', layout: 'closed'
  end

  def setup!
    if current_user.url.blank?
      current_user.build_shortname shortname: params[:user][:shortname_attributes][:shortname]

      if current_user.save
        flash[:success] = t('devise.registrations.signed_up') if current_user.finished_intro?
        redirect_with_r(current_user)
      else
        render 'setup_shortname'
      end
    else
      flash[:success] = t('users.shortname.not_changeable')
      redirect_to root_path
    end
  end

  def wrong_email
    render locals: {email: params[:email], r: r_param}
  end

  def language
    locale = permit_locale_params
    if I18n.available_locales.include?(locale.to_sym)
      success = current_user.guest? ? cookies['locale'] = locale : current_user.update(language: locale)
      respond_to do |format|
        flash[:error] = t('errors.general') unless success.present?
        format.html { redirect_back(fallback_location: root_path) }
      end
    else
      Bugsnag.notify(RuntimeError.new("Invalid locale #{params[:locale]} (#{locale})"))
      flash[:error] = t('errors.general')
      redirect_back(fallback_location: root_path)
    end
  end

  private

  def authenticated_resource!
    @user ||= case action_name
              when 'show'
                User.preload(:profile).find_via_shortname!(params[:id])
              when 'update'
                User.find(current_user.id)
              when 'current_actor'
                current_user
              else
                if current_user.guest?
                  flash[:error] = t('devise.failure.unauthenticated')
                  raise Argu::NotAUserError.new
                end
                current_user
              end
  end

  def authenticated_tree; end

  def complete_feed_param; end

  def email_changed?
    return unless permit_params[:emails_attributes].present?
    permit_params[:emails_attributes].any? do |email|
      email.second['id'].nil? ||
        email.second['email'].present? &&
          authenticated_resource.emails.find(email.second['id']).email != email.second['email']
    end
  end

  def permit_locale_params
    params.require(:locale)
  end

  def permit_params(password = false)
    attrs = policy(authenticated_resource || User).permitted_attributes(password)
    pp = params.require(:user).permit(*attrs).to_h
    merge_photo_params(pp, authenticated_resource.class)
    merge_placement_params(pp, User)
    if pp[:primary_email].present?
      pp['emails_attributes'][pp[:primary_email][1..-2]][:primary] = true
    end
    pp.except(:primary_email)
  end

  def redirect_model_success(_)
    r_param || settings_user_path(tab: tab)
  end

  def respond_with_form_js(resource)
    respond_js(
      'users/settings',
      resource: resource,
      profile: resource.profile,
      tab: tab,
      active: tab
    )
  end

  def tab
    t = params[:tab] || params[:user].try(:[], :tab)
    policy(authenticated_resource || User).verify_tab(t)
  end

  def update_respond_failure_html(resource)
    if params[:user][:form] == 'wrong_email'
      email = params[:user][:emails_attributes]['99999'][:email]
      if current_user.emails.any? { |e| e.email == email }
        redirect_to r_param
      else
        render 'wrong_email', locals: {email: email, r: r_param}
      end
    else
      render 'settings',
             locals: {tab: tab, active: tab, profile: resource.profile}
    end
  end

  def message_success(_resource, _action)
    if @email_changed
      t('users.registrations.confirm_mail_change_notice')
    else
      t('type_save_success', type: t('type_changes'))
    end
  end

  def execute_update
    if password_required
      if authenticated_resource.update_with_password(permit_params(true))
        bypass_sign_in(authenticated_resource)
      end
    else
      authenticated_resource.update_without_password(permit_params)
    end
  end

  def password_required
    permit_params[:password].present? ||
      params[:user][:primary_email].present? && params[:user][:primary_email] != '[0]'
  end
end
