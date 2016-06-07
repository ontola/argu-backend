class FollowsController < ApplicationController
  before_action :check_user
  before_action :set_thing

  def create
    authorize @thing, :follow?

    if current_user.follow @thing.edge, permit_params[:follow_type] || :reactions
      respond_to do |format|
        format.html { redirect_to :back, notification: t('followed') }
        format.js { head 201 }
        format.json { head 201 }
      end
    else
      respond_to do |format|
        format.json { head 304 }
      end
    end
  end

  def destroy
    authorize @thing, :follow?

    resp = current_user.stop_following @thing.edge
    if resp == nil || resp
      respond_to do |format|
        format.html { redirect_to :back, notification: t('unfollowed') }
        format.json { head 204 }
      end
    else
      respond_to do |format|
        format.json { head 400 }
      end
    end
  end

  private

  def check_user
    return if current_user.present?
    flash[:error] = t('devise.failure.unauthenticated')
    redirect_to :back
  end

  def set_thing
    @thing = Edge.find_by!(fragment: permit_params[:gid]).owner
    @forum = @thing.try :forum
  end

  def permit_params
    params.permit %i(follow_type gid)
  end
end
