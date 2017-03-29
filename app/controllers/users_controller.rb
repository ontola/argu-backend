# frozen_string_literal: true
class UsersController < ApplicationController
  include NestedResourceHelper, UrlHelper

  def show
    @user = User.preload(:profile).find_via_shortname!(params[:id])
    @profile = @user.profile
    authorize @user, :show?

    respond_to do |format|
      format.html do
        if (/[a-zA-Z]/i =~ params[:id]).nil?
          redirect_to url_for(@user), status: 307
        else
          render 'show'
        end
      end
      format.json { render json: @user }
      format.json_api do
        render json: @user,
               include: [:profile_photo, vote_match_collection: INC_NESTED_COLLECTION]
      end
    end
  end

  def current_actor
    skip_authorization
    actor = CurrentActor.new(user: current_user, actor: current_profile)
    respond_to do |format|
      format.json { render json: actor }
      format.json_api { render json: actor, include: [:profile_photo, :user, :actor] }
    end
  end

  def settings
    get_user_or_redirect(settings_path)
    authorize @user
    @user.build_home_placement if @user.home_placement.nil?
    render 'settings', locals: {tab: tab, active: tab, profile: @user.profile}
  end

  # PUT /settings
  def update
    @user = User.find(current_user.id)
    authorize @user
    email_changed = email_changed?
    respond_to do |format|
      if update_user
        notice = if email_changed
                   t('users.registrations.confirm_mail_change_notice')
                 else
                   t('type_save_success', type: t('type_changes'))
                 end
        format.html { redirect_to r_param || settings_path(tab: tab), notice: notice }
        format.json { head :no_content }
      else
        format.html do
          if params[:user][:form] == 'wrong_email'
            email = params[:user][:emails_attributes]['99999'][:email]
            if current_user.emails.any? { |e| e.email == email }
              redirect_to r_param
            else
              render 'wrong_email', locals: {email: email, r: r_param}
            end
          else
            render 'settings', locals: {tab: tab, active: tab, profile: @user.profile}
          end
        end
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def connect
    payload = decode_token params[:token]
    identity = Identity.find payload['identity']
    user = User.find_via_shortname! params[:id]

    skip_authorization
    render locals: {
      identity: identity,
      user: user,
      token: params[:token]
    }
  end

  def connect!
    user = User.find_via_shortname! params[:id].presence || params[:user][:id]
    user.r = r_param
    setup_favorites(user)

    payload = decode_token params[:token]
    @identity = Identity.find payload['identity']

    skip_authorization
    if @identity.email == user.email && user.valid_password?(params[:user][:password])
      # Connect user to identity
      @identity.user = user
      if @identity.save
        flash[:success] = 'Account connected'
        sign_in user
        redirect_with_r(user)
      else
        render 'users/connect',
               locals: {
                 identity: @identity,
                 user: user,
                 token: params[:token]
               }
      end
    else
      user.errors.add(:password, t('errors.messages.invalid'))
      render 'users/connect',
             locals: {
               identity: @identity,
               user: user,
               token: params[:token]
             }
    end
  end

  # When shortname isn't set yet
  def setup
    get_user_or_redirect
    authorize @user, :setup?
    @user.build_shortname if @user.shortname.blank?

    render 'setup_shortname', layout: 'closed'
  end

  def setup!
    get_user_or_redirect
    authorize @user, :setup?
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

  def tab
    policy(@user || User).verify_tab(params[:tab] || params[:user].try(:[], :tab))
  end

  def wrong_email
    skip_authorization
    render locals: {email: params[:email], r: r_param}
  end

  def language
    authorize :static_page, :home?
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

  def email_changed?
    return unless permit_params[:emails_attributes].present?
    permit_params[:emails_attributes].any? do |email|
      email.second['id'].nil? ||
        email.second['email'].present? && @user.emails.find(email.second['id']).email != email.second['email']
    end
  end

  def get_user_or_redirect(redirect = nil)
    @user = current_user
    return unless current_user.guest?
    flash[:error] = t('devise.failure.unauthenticated')
    raise Argu::NotAUserError.new(r: redirect)
  end

  def permit_locale_params
    params.require(:locale)
  end

  def permit_params
    pp = params.require(:user).permit(*policy(@user || User).permitted_attributes(true)).to_h
    merge_photo_params(pp, @user.class)
    merge_placement_params(pp, User)
    if pp[:primary_email].present?
      pp['emails_attributes'][pp[:primary_email][1..-2]][:primary] = true
    end
    pp.except(:primary_email)
  end

  def passwordless_permit_params
    pp = params.require(:user).permit(*policy(@user || User).permitted_attributes).to_h
    merge_photo_params(pp, @user.class)
    merge_placement_params(pp, User)
    pp
  end

  def r_param
    r = (params[:user]&.permit(:r) || params.permit(:r)).try(:[], :r)
    r if valid_redirect?(r)
  end

  def redirect_with_r(user)
    if user.r.present? && user.finished_intro?
      r = URI.decode(user.r)
      user.update r: ''
    end
    redirect_to r.presence || root_path
  end

  def update_user
    if params[:user][:primary_email].present? || permit_params[:password].present?
      bypass_sign_in(@user) if @user.update_with_password(permit_params)
    else
      @user.update_without_password(passwordless_permit_params)
    end
  end
end
