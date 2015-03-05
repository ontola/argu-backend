class ActorsController < ApplicationController
  def update
    @new_actor = Profile.find params[:na]

    if @new_actor.present?
      authorize @new_actor
      cookies[:a_a] = @new_actor.id
      status = 200
    else
      status = 404
    end

    respond_to do |format|
      if status == 200
        format.html { redirect_to :back }
        format.json { render }
      else
        format.html { render 404 }
        format.json { head status: 404 }
      end
    end
  end
end
