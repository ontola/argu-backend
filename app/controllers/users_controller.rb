class UsersController < ApplicationController
	load_and_authorize_resource

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

	# PUT /settings
	def update
		@user = current_user unless current_user.blank?
		puts "=============" + params.to_s

		respond_to do |format|
			if @user.update_attributes(params[:user]) && @user.profile.update_attributes(params[:profile])
				format.html { redirect_to settings_path, notice: "Wijzigingen opgeslagen." }
				format.json { head :no_content }
			else
				format.html { render action: "edit" }
				format.jsoon { render json: @profile.errors, status: :unprocessable_entity }
			end
		end
	end
end