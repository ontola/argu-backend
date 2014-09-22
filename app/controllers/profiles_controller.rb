class ProfilesController < ApplicationController

  #GET /profiles/1
  def show
    @profile = Profile.find params[:id]
    authorize @profile, :show?

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  #GET /1/edit
  def edit
    @profile = Profile.find params[:id]
    authorize @profile

    respond_to do |format|
      format.html # edit.html.erb
    end
  end

  #PUT /1
  def update
    @profile = Profile.find params[:id]
    authorize @profile

    respond_to do |format|
      if @profile.update_attributes permit_params
        format.html { redirect_to @profile, notice: "Profile was successfully updated." }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.jsoon { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

private
  def permit_params
    params.require(:profile).permit :name, :about, :profile_photo
  end
end
