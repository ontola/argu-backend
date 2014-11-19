class Moderators::MotionsController < ApplicationController

  # POST /motions/:motion_id/moderator/:user_id
  def create
    @motion = Motion.find_by_id(params[:motion_id])
    authorize! :create_mod, @motion
    @user = User.find_by_id params[:user_id]
    @user.add_role :mod, @motion
    respond_to do |format|
      format.js
      format.json
    end
  end
  # GET /motions/:motion_id/moderators/
  def index
    @motion = Motion.find_by_id(params[:motion_id])
    authorize! :edit_mods, @motion
    @moderators = User.with_role :mod, @motion
  end

  # DELETE /motions/:motion_id/moderators/:user_id
  def destroy
    @motion = Motion.find_by_id params[:motion_id]
    authorize! :destroy_mod, @motion
    user = User.find params[:user_id]
    respond_to do |format|
      if user.remove_role :mod, @motion
        format.js
        format.json
      else
        format.js { head :not_found }
      end
    end
  end

end