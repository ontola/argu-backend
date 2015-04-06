class RegistrationsController < Devise::RegistrationsController

  def new
    if within_user_cap?
      super
    else
      redirect_to :root
    end
  end

  def create
    redirect_to :root unless has_valid_token? || within_user_cap?
    super
    session[:omniauth] = nil unless @user.new_record?
  end
=begin
  def edit
    unless current_user.nil?
      @user = User.find(current_user.id)
      render 'edit'
      else
        flash[:error] = 'You need to be signed in for this action'
        redirect_to root_path
      end
  end

  def update
      @user = User.find(current_user.id)
      email_changed = @user.email != params[:email]
      successfully_updated = if email_changed or !params[:password].blank? or @user.invitation_token.present?
        @user.update_with_password(params[:user])
      else
        @user.update_without_password(params[:user])
      end

      if successfully_updated
        # Sign in the user bypassing validation in case his password changed
        sign_in @user, :bypass => true
        redirect_to root_path
      else
        render 'edit'
      end
    end
=end
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
    @user.errors.add(:current_password, t('errors.messages.should_match')) unless @user.valid_password?(params[:user][:current_password])
    @user.errors.add(:repeat_name, t('errors.messages.should_match')) unless params[:user][:repeat_name] == @user.url
    respond_to do |format|
      if @user.valid_password?(params[:user][:current_password]) && @user.destroy
        Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
        format.html { redirect_to root_path, notice: 'Account verwijderd.' }
        format.json { head :no_content }
      else
        format.html { render action: 'cancel' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

protected
  def after_sign_up_path_for(resource)
    edit_profile_url(resource.url)
  end

private

  def build_resource(*args)
    super args.first.merge(access_tokens: get_safe_raw_access_tokens)
    if session[:omniauth]
      @user.apply_omniauth(session[:omniauth])
      @user.valid?
    end
  end
end
