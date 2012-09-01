class UsersController < ApplicationController
	def show
		#let users find themselves by their username
		@user = User.find_by_username(params[:username])


		respond_to do |format|
			format.html
			format.json { render json: @user }
		end
	end
end