class RegistrationsController < Devise::RegistrationsController
	def create
		super
		session[:omniauth] = nil unless @user.new_record?
	end

	def edit
      @user = User.find(current_user.id)
      email_changed = @user.email != params[:email]
      password_changed = @user.encrypted_password.blank? ? false : !params[:password].empty? #if the pass's NULL, the user signed up via an auth service
      successfully_updated = if email_changed or password_changed
        @user.update_with_password(params[:user])
      else
        @user.update_without_password(params[:user])
      end

      if successfully_updated
        # Sign in the user bypassing validation in case his password changed
        sign_in @user, :bypass => true
        redirect_to root_path
      else
        render "edit"
      end
	end

	def cancel
		unless current_user.nil?
			render 'cancel'
		else
			flash[:error] = "Not signed in"
			redirect_to root_path
		end
	end

	def destroy
		super
	end

	private

	def build_resource(*args)
		super
		if session[:omniauth]
			@user.apply_omniauth(session[:omniauth])
			@user.valid?
		end
	end
end
