class UsersController < ApplicationController
	authorize_resource
	def show
		@user = current_user

		@tab = params['tab']
		@tab ||= "account"
		@tab = @tab.downcase
		
		unless @user.nil? 
			@authentications = @user.authentications
			respond_to do |format|
				format.html
				format.json { render json: @user }
			end
		else
			flash['User not found']
			request.env['HTTP_REFERER'] ||= root_path
			respond_to do |format|
				format.html { redirect_to :back }
				format.json { render json: "Error: user not found" }
			end
		end
	end
end