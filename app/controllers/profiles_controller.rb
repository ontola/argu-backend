class ProfilesController < ApplicationController

	#GET /profiles/1
	def show
    @profile = Profile.find params[:id]
		@user = User.find_by_id(@profile.user_id)

		respond_to do |format|
			format.html # show.html.erb
		end
	end

	#GET /1/edit
	def edit
    @current_user = current_user.profile

		respond_to do |format|
			format.html # edit.html.erb
		end
	end

	#PUT /1
	def update
    @profile = current_user.profile
		respond_to do |format|
			if @profile.update_attributes(params[:profile])
				format.html { redirect_to @profile, notice: "Profile was successfully updated." }
				format.json { head :no_content }
			else
				format.html { render action: "edit" }
				format.jsoon { render json: @profile.errors, status: :unprocessable_entity }
			end
		end
	end
end
