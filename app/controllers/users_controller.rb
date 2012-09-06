class UsersController < ApplicationController
	authorize_resource
	def show
		#let users find themselves by their username or id
		# !username  regex must be configured!
		# !to require at least one alpha char!
		@user = User.find_by_username(params[:login])
		@user ||= User.find_by_id(params[:login])

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