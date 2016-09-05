class RegistrationsController < Devise::RegistrationsController
  include NestedResourceHelper

  def new
    if within_user_cap?
      super
    else
      redirect_to :root
    end
  end

  def create
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
    if current_user.present?
      @user = current_user
      render 'cancel'
    else
      flash[:error] = 'Not signed in'
      redirect_to root_path
    end
  end

  def destroy
    @user = User.find current_user.id
    authorize @user, :destroy?
    unless @user.valid_password?(params[:user][:current_password])
      @user.errors.add(:current_password, t('errors.messages.should_match'))
    end
    @user.errors.add(:repeat_name, t('errors.messages.should_match')) unless params[:user][:repeat_name] == @user.url
    respond_to do |format|
      valid_password = @user.has_password? ? @user.valid_password?(params[:user][:current_password]) : true
      if valid_password && @user.destroy
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

  def sign_up(resource_name, resource)
    super
    resource.send_confirmation_instructions
    setup_memberships(resource)
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
    if session[:omniauth]
      @user.apply_omniauth(session[:omniauth])
      @user.valid?
    end
  end
end
