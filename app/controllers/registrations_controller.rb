class RegistrationsController < Devise::RegistrationsController
	def create
		super
		session[:omniauth] = nil unless @user.new_record?
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
