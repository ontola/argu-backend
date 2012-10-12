class RegistrationsController < Devise::RegistrationsController
	#load_and_authorize_resource, unless: [:create, :edit] #Not sure yet

	def create
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
      password_changed = !params[:password].blank?
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
