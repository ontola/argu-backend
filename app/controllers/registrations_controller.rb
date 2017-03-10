# frozen_string_literal: true
class RegistrationsController < Devise::RegistrationsController
  skip_before_action :authenticate_scope!, only: :destroy
  include NestedResourceHelper, OauthHelper
  respond_to :json

  def create
    @registration_without_password = !devise_parameter_sanitizer.sanitize(:sign_up).include?(:password)
    super do |resource|
      unless resource.persisted?
        send_event user: resource,
                   category: 'registrations',
                   action: 'create',
                   label: 'failed'
      end
    end
    session[:omniauth] = nil unless @user.new_record?
  end

  def cancel
    if current_user.guest?
      flash[:error] = 'Not signed in'
      redirect_to root_path
    else
      @user = current_user
      render 'cancel'
    end
  end

  def destroy
    @user = User.find current_user.id
    authorize @user, :destroy?
    unless params[:user][:confirmation_string] == t('users_cancel_string')
      @user.errors.add(:confirmation_string, t('errors.messages.should_match'))
    end
    respond_to do |format|
      if @user.errors.empty? && @user.destroy
        Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
        send_event category: 'registrations',
                   action: 'destroy',
                   label: @user.id
        format.html { redirect_to root_path, notice: t('type_destroy_success', type: 'Account') }
        format.json { head :no_content }
      else
        format.html { render action: 'cancel' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  protected

  def after_sign_up_path_for(resource)
    if resource.url
      edit_user_url(resource.url)
    else
      setup_users_path
    end
  end

  def sign_in(scope, resource)
    super(resource, scope)
  end

  def sign_up(resource_name, resource)
    super
    @registration_without_password ? resource.send_set_password_instructions : resource.send_confirmation_instructions
    setup_favorites(resource)
    send_event user: resource,
               category: 'registrations',
               action: 'create',
               label: 'email'
  end

  private

  def build_resource(*args)
    super args.first.merge(access_tokens: get_safe_raw_access_tokens)
    resource.shortname = nil if resource.shortname.shortname.blank?
    resource.build_profile
    resource.language = I18n.locale
    return unless session[:omniauth]
    @user.apply_omniauth(session[:omniauth])
    @user.valid?
  end

  def sign_up_params
    {password: SecureRandom.hex}.merge(super)
  end
end
