class RegistrationsController < Devise::RegistrationsController

  def new
    if !Rails.configuration.epics.sign_up
      redirect_to :root
    else
      super
    end
  end

  def create
    redirect_to :root unless has_valid_token? || Rails.configuration.epics.sign_up
    super
    session[:omniauth] = nil unless @user.new_record?
  end

  def edit
    unless current_user.nil?
      @user = User.find(current_user.id)
      render 'edit'
      else
        flash[:error] = "You need to be signed in for this action"
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

  def cancel
    unless current_user.nil?
      render 'cancel'
    else
      flash[:error] = 'Not signed in'
      redirect_to root_path
    end
  end

  def destroy
    super
  end

protected
  def after_sign_up_path_for(resource)
    edit_profile_url(resource.username)
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
