class ProfilesController < ApplicationController

	#GET /profiles/1
	def show
		@profile = Profile.find_by_username(params[:id])
		@profile ||= Profile.find_by_id(params[:id])
		@user = User.find_by_id(@profile.user_id)

		respond_to do |format|
			format.html # show.html.erb
		end
	end

	def edit
		@profile = Profile.find_by_id(params[:id])

		respond_to do |format|
			format.html # edit.html.erb
		end
	end

	#PUT /1
	def update
		if signed_in?
			@profile = Profile.find_by_id(params[:id])

			respond_to do |format|
				if @profile.update_attributes(params[:profile])
					format.html { redirect_to @profile, notice: "Profile was successfully updated." }
					format.json { head :no_content }
				else
					format.html { render action: "edit" }
					format.jsoon { render json: @profile.errors, status: :unprocessable_entity }
				end
			end
		else
			respond_to do |format|
				flash.now[:error] = t(:appliction_general_not_allowed)
				format.html { redirect_to root_url }
				format.json { head :no_content}
			end
		end
	end
end
