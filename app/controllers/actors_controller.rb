class ActorsController < ApplicationController
  def update
    @profile = Profile.find params[:na]

    if @profile.present?
      authorize @profile.profileable, :update?
      cookies[:a_a] = @profile.id
      status = 200
    else
      status = 404
    end

    respond_to do |format|
      if status == 200
        format.html { redirect_back(fallback_location: root_path) }
        format.json { render 'users/current_actor' }
      else
        format.html { render 404 }
        format.json { head status: 404 }
      end
    end
  end
end
